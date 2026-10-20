# === Fluid widget (Matplotlib) — Hi-res, smooth, accurate upgrade =================
# Key upgrades:
# - PERIODIC "spectral exact" mode: diffusion by exp(-nu*k^2*dt), Helmholtz–Hodge
#   projection in Fourier space (no Jacobi noise, truly div-free).
# - BFECC/MacCormack advection with CFL substepping + RK2 tracing (sharp w/o ringing).
# - Strang splitting: Advect(dt/2) → Diffuse+Project(dt) → Advect(dt/2).
# - Boundary switch: Periodic (spectral) vs Neumann (Jacobi), same UI.
# - Resolution switch: 64 / 128 / 256 (rebuilds fields, keeps UI flow).
# - Robust vectors, quarantine, help box, white UI text for dark theme preserved.

import numpy as np, math, json, hashlib, time
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button, RadioButtons, CheckButtons

# --------------------------- Sampling helpers ------------------------------------
def bilinear_sample_clamped(field, x, y):
    H, W = field.shape
    x0 = np.floor(x).astype(int); y0 = np.floor(y).astype(int)
    x1 = np.clip(x0 + 1, 0, W-1); y1 = np.clip(y0 + 1, 0, H-1)
    x0 = np.clip(x0, 0, W-1);     y0 = np.clip(y0, 0, H-1)
    fx = x - x0; fy = y - y0
    v00 = field[y0, x0]; v10 = field[y0, x1]
    v01 = field[y1, x0]; v11 = field[y1, x1]
    return (v00*(1-fx)*(1-fy) + v10*fx*(1-fy) + v01*(1-fx)*fy + v11*fx*fy)

def bilinear_sample_periodic(field, x, y):
    H, W = field.shape
    x0 = np.floor(x).astype(int); y0 = np.floor(y).astype(int)
    fx = x - x0; fy = y - y0
    x0m = np.mod(x0, W); x1m = np.mod(x0+1, W)
    y0m = np.mod(y0, H); y1m = np.mod(y0+1, H)
    v00 = field[y0m, x0m]; v10 = field[y0m, x1m]
    v01 = field[y1m, x0m]; v11 = field[y1m, x1m]
    return (v00*(1-fx)*(1-fy) + v10*fx*(1-fy) + v01*(1-fx)*fy + v11*fx*fy)

# --------------------------- Diffusion / Laplacian (Jacobi) ----------------------
def laplacian_neumann(field):
    H, W = field.shape
    out = np.zeros_like(field)
    out[1:-1,1:-1] = (
        field[1:-1,0:-2] + field[1:-1,2:] + field[0:-2,1:-1] + field[2:,1:-1] - 4*field[1:-1,1:-1]
    )
    # Neumann "mirror" edges (duplicate interior neighbor)
    out[0,1:-1]  = field[0,0:-2] + field[0,2:] + field[1,1:-1] + field[1,1:-1] - 4*field[0,1:-1]
    out[-1,1:-1] = field[-1,0:-2] + field[-1,2:] + field[-2,1:-1] + field[-2,1:-1] - 4*field[-1,1:-1]
    out[1:-1,0]  = field[1:-1,1] + field[1:-1,1] + field[0:-2,0] + field[2:,0]   - 4*field[1:-1,0]
    out[1:-1,-1] = field[1:-1,-2]+ field[1:-1,-2]+ field[0:-2,-1]+ field[2:,-1] - 4*field[1:-1,-1]
    out[0,0]     = field[0,1] + field[1,0] + field[1,0] + field[0,1] - 4*field[0,0]
    out[0,-1]    = field[0,-2] + field[1,-1] + field[1,-1] + field[0,-2] - 4*field[0,-1]
    out[-1,0]    = field[-1,1] + field[-2,0] + field[-2,0] + field[-1,1] - 4*field[-1,0]
    out[-1,-1]   = field[-1,-2]+ field[-2,-1]+ field[-2,-1]+ field[-1,-2] - 4*field[-1,-1]
    return out

def jacobi_solve(Ax_plus_b, x_init, iters=40):
    x = np.array(x_init, copy=True)
    for _ in range(iters):
        x = Ax_plus_b(x)
    return x

# --------------------------- Fluid core ------------------------------------------
class FluidSim2D:
    """
    High-accuracy incompressible 2D sim.
      boundary='periodic' → spectral diffusion + spectral projection (exact, smooth)
      boundary='neumann'  → Jacobi diffusion + Jacobi pressure solve (legacy-compatible)

    Advection: BFECC/MacCormack with CFL substeps + RK2 tracing (sharper than plain SL).
    Time split: Strang (A(dt/2) → D+P(dt) → A(dt/2)).
    """
    def __init__(self, N=128, dt=0.15, nu=0.003, boundary='periodic', scheme='bfecc'):
        self.set_grid(N)
        self.dt = float(dt)
        self.base_nu = float(nu)
        self.boundary = boundary.lower()
        self.scheme = scheme.lower()
        self._setup_spectral()  # precompute KX,KY,k2 for periodic mode
        self.reset(dye_level=0.0, seed=1)

    # ----- grid / spectral -----
    def set_grid(self, N):
        self.N = int(N); self.H = self.W = self.N
        xs = np.linspace(0, self.W-1, self.W)
        ys = np.linspace(0, self.H-1, self.H)
        self.X, self.Y = np.meshgrid(xs, ys)
        # fields
        self.u = np.zeros((self.H, self.W), dtype=np.float64)
        self.v = np.zeros_like(self.u)
        self.p = np.zeros_like(self.u)
        self.div = np.zeros_like(self.u)
        self.dye = np.zeros_like(self.u)

    def _setup_spectral(self):
        # Angular frequencies (2π * cycles per sample)
        kx = 2.0*np.pi*np.fft.fftfreq(self.W)  # shape (W,)
        ky = 2.0*np.pi*np.fft.fftfreq(self.H)  # shape (H,)
        self.KX, self.KY = np.meshgrid(kx, ky)
        self.K2 = self.KX**2 + self.KY**2
        self.K2[0,0] = 1.0  # avoid division by zero; we'll special-case back

    # ----- state management -----
    def reset(self, dye_level=0.0, seed=1):
        rng = np.random.default_rng(seed)
        self.u.fill(0.0); self.v.fill(0.0); self.p.fill(0.0); self.div.fill(0.0)
        if dye_level > 0:
            self.dye = dye_level * (rng.random(self.dye.shape) * 0.05)
        else:
            self.dye.fill(0.0)

    def add_impulse(self, cx, cy, radius, fx, fy, dye_amt=1.0):
        cx_px = int(np.clip(cx,0,1) * (self.W-1))
        cy_px = int(np.clip(cy,0,1) * (self.H-1))
        Y, X = np.ogrid[:self.H, :self.W]
        r2 = (X - cx_px)**2 + (Y - cy_px)**2
        R2 = float(radius)**2
        w = np.zeros_like(self.u)
        inside = r2 <= R2
        # smooth C^1 bump
        w[inside] = 0.5 * (1.0 + np.cos(np.pi * np.sqrt(r2[inside] / R2)))
        self.u += fx * w; self.v += fy * w; self.dye += dye_amt * w

    # ----- advection (BFECC or RK2 SL) with CFL substeps -----
    def _trace_rk2(self, x, y, u, v, dt, sample_vec):
        # 1st stage
        x1 = x - dt * sample_vec(u, x, y); y1 = y - dt * sample_vec(v, x, y)
        # clamp/wrap in sampling function, so keep raw coords here
        # 2nd stage velocities
        u1 = sample_vec(u, x1, y1); v1 = sample_vec(v, x1, y1)
        x2 = x - dt * u1; y2 = y - dt * v1
        return x2, y2

    def _advect_field_bfecc(self, f, u, v, dt, sample_s):
        # Backtrace (predictor)
        xb, yb = self._trace_rk2(self.X, self.Y, u, v, dt, sample_s)
        fb = sample_s(f, xb, yb)
        # Forward trace to estimate error (back to grid)
        xf, yf = self._trace_rk2(self.X, self.Y, u, v, -dt, sample_s)
        ff = sample_s(fb, xf, yf)
        # Error-corrected value
        f_corr = fb + 0.5*(f - ff)
        # Simple limiter to prevent overshoots
        f_min = np.minimum(f, fb); f_max = np.maximum(f, fb)
        return np.clip(f_corr, f_min, f_max)

    def _advect_field_rk2(self, f, u, v, dt, sample_s):
        xb, yb = self._trace_rk2(self.X, self.Y, u, v, dt, sample_s)
        return sample_s(f, xb, yb)

    def _advect(self, field, u, v, dt, cfl=0.6, max_substeps=64):
        umax = float(np.max(np.hypot(u, v))) + 1e-12
        nsub = int(np.clip(np.ceil(dt * umax / cfl), 1, max_substeps))
        dts = dt / nsub
        f = np.array(field, copy=True)
        sample_s = bilinear_sample_periodic if self.boundary=='periodic' else bilinear_sample_clamped
        for _ in range(nsub):
            if self.scheme == 'bfecc':
                f = self._advect_field_bfecc(f, u, v, dts, sample_s)
            else:
                f = self._advect_field_rk2(f, u, v, dts, sample_s)
        return f

    # ----- diffusion + projection -----
    def _diffuse_project_periodic(self, u, v, nu, dt):
        # Exact diffusion in Fourier: exp(-nu*k^2*dt), then Helmholtz–Hodge projection
        U = np.fft.fft2(u); V = np.fft.fft2(v)
        diff = np.exp(-nu * self.K2 * dt)
        U *= diff; V *= diff
        # Projection: U <- (I - kk^T/k^2) U_hat
        dot = self.KX*U + self.KY*V
        U -= self.KX * (dot / self.K2)
        V -= self.KY * (dot / self.K2)
        U[0,0] = 0.0; V[0,0] = 0.0  # mean mode
        u_np = np.fft.ifft2(U).real; v_np = np.fft.ifft2(V).real
        return u_np, v_np

    def _diffuse_jacobi(self, field, nu, dt):
        a = max(0.0, float(nu)) * dt
        denom = 1.0 + 4.0*a
        def step(x): return (field + a*laplacian_neumann(x)) / denom
        return jacobi_solve(step, field, iters=50)

    def _project_neumann(self, u, v):
        self.div.fill(0.0)
        self.div[1:-1,1:-1] = 0.5*((u[1:-1,2:] - u[1:-1,0:-2]) + (v[2:,1:-1] - v[0:-2,1:-1]))
        p0 = self.p
        def step(p):
            pn = np.copy(p)
            pn[1:-1,1:-1] = (p[1:-1,0:-2] + p[1:-1,2:] + p[0:-2,1:-1] + p[2:,1:-1] - self.div[1:-1,1:-1]) / 4.0
            pn[0,:]=pn[1,:]; pn[-1,:]=pn[-2,:]; pn[:,0]=pn[:,1]; pn[:,-1]=pn[:,-2]
            return pn
        self.p = jacobi_solve(step, p0, iters=80)
        uo = np.copy(u); vo = np.copy(v)
        uo[1:-1,1:-1] -= 0.5*(self.p[1:-1,2:] - self.p[1:-1,0:-2])
        vo[1:-1,1:-1] -= 0.5*(self.p[2:,1:-1] - self.p[0:-2,1:-1])
        uo[0,:]=uo[1,:]; uo[-1,:]=uo[-2,:]; uo[:,0]=uo[:,1]; uo[:,-1]=uo[:,-2]
        vo[0,:]=vo[1,:]; vo[-1,:]=vo[-2,:]; vo[:,0]=vo[:,1]; vo[:,-1]=vo[:,-2]
        return uo, vo

    # ----- vorticity (optional diagnostics) -----
    def _local_vorticity(self, u, v):
        dv_dx = np.zeros_like(v); du_dy = np.zeros_like(u)
        dv_dx[:,1:-1] = 0.5*(v[:,2:] - v[:,0:-2])
        du_dy[1:-1,:] = 0.5*(u[2:,:] - u[0:-2,:])
        return dv_dx - du_dy

    # ----- single timestep (Strang split) -----
    def step(self, frontier_alpha=0.9, frontier_gain=1.5, frontier_cap=0.5):
        dt = self.dt
        # 1) Advect half step (velocity)
        u1 = self._advect(self.u, self.u, self.v, 0.5*dt)
        v1 = self._advect(self.v, self.u, self.v, 0.5*dt)

        # Adaptive viscosity from vorticity tails (unchanged policy)
        omega = np.abs(self._local_vorticity(u1, v1))
        thresh = np.quantile(omega, frontier_alpha)
        if thresh <= 1e-12:
            nu_eff = self.base_nu
        else:
            ramp = np.maximum(omega/thresh - 1.0, 0.0)
            extra = frontier_gain * ramp
            if frontier_cap > 0: extra = np.minimum(extra, frontier_cap)
            nu_eff = float(np.mean(self.base_nu*(1.0 + extra)))

        # 2) Diffuse+Project full step
        if self.boundary == 'periodic':
            u2, v2 = self._diffuse_project_periodic(u1, v1, nu_eff, dt)
        else:
            ud = self._diffuse_jacobi(u1, nu_eff, dt)
            vd = self._diffuse_jacobi(v1, nu_eff, dt)
            u2, v2 = self._project_neumann(ud, vd)

        # 3) Advect half step with updated velocity
        self.u = self._advect(u2, u2, v2, 0.5*dt)
        self.v = self._advect(v2, u2, v2, 0.5*dt)

        # Dye: full-step advection with final velocity + mild diffusion
        dye_a = self._advect(self.dye, self.u, self.v, dt)
        if self.boundary == 'periodic':
            # diffuse dye spectrally but milder
            D = np.fft.fft2(dye_a)
            D *= np.exp(-(nu_eff*0.25) * self.K2 * dt)
            D[0,0] = D[0,0].real  # keep real mean
            self.dye = np.fft.ifft2(D).real
        else:
            self.dye = self._diffuse_jacobi(dye_a, nu_eff*0.25, dt)

# --------------------------- UI / App --------------------------------------------
def make_app(N0=128, dt0=0.15, nu0=0.003, boundary0='periodic'):
    sim = FluidSim2D(N=N0, dt=dt0, nu=nu0, boundary=boundary0, scheme='bfecc')

    plt.rcParams.update({"font.size": 9})
    fig, ax = plt.subplots(figsize=(6.6,6.6))
    fig.patch.set_facecolor('#0e1117')
    ax.set_facecolor('#111417')
    ax.set_xticks([]); ax.set_yticks([])
    for spine in ax.spines.values(): spine.set_visible(False)

    bg_level = 0.06
    def display_img():
        return np.clip(sim.dye + bg_level, 0.0, 1.0)

    im = ax.imshow(display_img(), origin='lower', interpolation='bilinear',
                   cmap='viridis', vmin=0, vmax=1)
    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.ax.tick_params(labelsize=8)

    Q = None
    show_vectors = False
    stride = 6

    plt.subplots_adjust(left=0.08, right=0.985, bottom=0.36, top=0.96)

    # Sliders
    ax_dt = plt.axes([0.15, 0.28, 0.65, 0.02]); s_dt = Slider(ax_dt, 'dt',    0.02, 0.6,  valinit=dt0,  valstep=0.02)
    ax_nu = plt.axes([0.15, 0.25, 0.65, 0.02]); s_nu = Slider(ax_nu, 'nu',    1e-4, 0.1,  valinit=nu0,  valstep=1e-4)
    ax_al = plt.axes([0.15, 0.22, 0.65, 0.02]); s_al = Slider(ax_al, 'alpha', 0.70, 0.99, valinit=0.90, valstep=0.01)
    ax_gn = plt.axes([0.15, 0.19, 0.65, 0.02]); s_gn = Slider(ax_gn, 'gain',  0.0,  5.0,  valinit=1.5,  valstep=0.1)
    ax_cp = plt.axes([0.15, 0.16, 0.65, 0.02]); s_cp = Slider(ax_cp, 'cap',   0.0,  3.0,  valinit=0.5,  valstep=0.05)
    ax_st = plt.axes([0.15, 0.13, 0.65, 0.02]); s_st = Slider(ax_st, 'steps', 1,    40,   valinit=12,   valstep=1)
    ax_sd = plt.axes([0.15, 0.10, 0.65, 0.02]); s_sd = Slider(ax_sd, 'stride',3,    16,   valinit=6,    valstep=1)
    ax_bg = plt.axes([0.15, 0.07, 0.65, 0.02]); s_bg = Slider(ax_bg, 'background', 0.0,  0.3,  valinit=0.06, valstep=0.01)

    # Action buttons
    ax_imp = plt.axes([0.15, 0.005, 0.10, 0.045]); b_imp = Button(ax_imp, 'Impulse')
    ax_run = plt.axes([0.27, 0.005, 0.10, 0.045]); b_run = Button(ax_run, 'Run')
    ax_rst = plt.axes([0.39, 0.005, 0.12, 0.045]); b_rst = Button(ax_rst, 'Reset')
    ax_rsn = plt.axes([0.53, 0.005, 0.14, 0.045]); b_rsn = Button(ax_rsn, 'Reset (noise)')
    ax_play = plt.axes([0.69, 0.005, 0.10, 0.045]); b_play = Button(ax_play, 'Play')

    # Side panels
    ax_cmap   = plt.axes([0.01, 0.78, 0.16, 0.18]); rb_cmap   = RadioButtons(ax_cmap,   ('gray','viridis'), active=1)
    ax_vec    = plt.axes([0.01, 0.68, 0.16, 0.08]); cb_vec    = CheckButtons(ax_vec,    ['Vectors'], [False])
    ax_preset = plt.axes([0.77, 0.68, 0.22, 0.24]); rb_preset = RadioButtons(ax_preset, ('Shear band','Counter pair','Vortex street'))

    # New: boundary + resolution + scheme
    ax_bnd    = plt.axes([0.01, 0.58, 0.16, 0.08]); rb_bnd    = RadioButtons(ax_bnd, ('Periodic','Neumann'), active=0)
    ax_res    = plt.axes([0.01, 0.48, 0.16, 0.08]); rb_res    = RadioButtons(ax_res, ('64','128','256'), active=1)
    ax_sch    = plt.axes([0.01, 0.38, 0.16, 0.08]); rb_sch    = RadioButtons(ax_sch, ('bfecc','rk2'), active=0)

    for pnl in (ax_preset, ax_cmap, ax_vec, ax_bnd, ax_res, ax_sch):
        pnl.set_facecolor('#111417')
        for sp in pnl.spines.values(): sp.set_color('#33363f')

    ax_help_toggle = plt.axes([0.78, 0.62, 0.21, 0.05]); cb_help = CheckButtons(ax_help_toggle, ['Help (definitions)'], [False])
    ax_help = plt.axes([0.78, 0.34, 0.21, 0.26]); ax_help.axis('off')
    help_text = (
        "Periodic: spectral diffusion & projection (exact, smooth)\n"
        "Neumann: Jacobi diffusion, Jacobi Poisson projection\n"
        "Advection: BFECC (sharper) or RK2 SL (safer)\n"
        "dt: time step; nu: viscosity; steps: sim steps per tick\n"
        "alpha/gain/cap: adaptive tail damping on |ω| (nu_eff)\n"
        "stride: quiver density; background: gray offset\n"
        "Presets lay clean impulses; use Run/Play to evolve."
    )
    help_txt_artist = ax_help.text(
        0, 1, help_text, va='top', ha='left', wrap=True,
        fontsize=10, color='white', linespacing=1.25, visible=False,
        bbox=dict(facecolor='black', alpha=0.85, boxstyle='round,pad=0.5')
    )

    # Proof surface (short)
    proof_text = ax.text(0.01, 0.99, "", transform=ax.transAxes, va='top', ha='left',
                         fontsize=8, color='w', alpha=0.85,
                         bbox=dict(facecolor='black', alpha=0.35, boxstyle='round,pad=0.2'))

    running=False; quarantined=False
    timer = fig.canvas.new_timer(interval=30)

    FRONTIER_DEBOUNCE_MS = 200
    _last_frontier_ms = 0.0
    def frontier_ok():
        nonlocal _last_frontier_ms
        now = time.perf_counter()*1000.0
        if now - _last_frontier_ms < FRONTIER_DEBOUNCE_MS: return False
        _last_frontier_ms = now; return True

    def pause_play():
        nonlocal running
        running=False; b_play.label.set_text('Play')
        try: timer.stop()
        except Exception: pass

    def finite_guard(*arrs): return all(np.all(np.isfinite(a)) for a in arrs)

    def create_quiver(stride):
        U = np.nan_to_num(sim.u[::stride,::stride])
        V = np.nan_to_num(sim.v[::stride,::stride])
        speed = np.hypot(U, V)
        p90 = float(np.nanpercentile(speed, 90)) if speed.size else 1.0
        L_target = max(0.40*stride, 1.0)
        scale = (p90 / L_target) if p90 > 1e-9 else 20.0
        scale = min(max(scale, 2.0), 60.0)
        return ax.quiver(sim.X[::stride,::stride], sim.Y[::stride,::stride],
                         U, V, speed, scale_units='xy', scale=scale,
                         angles='xy', pivot='mid', width=0.0032)

    def remove_quiver():
        nonlocal Q
        if Q is not None:
            try: Q.remove()
            except Exception: pass
            Q=None

    def make_proof_print():
        state = dict(
          dt=float(s_dt.val), nu=float(s_nu.val),
          alpha=float(s_al.val), gain=float(s_gn.val), cap=float(s_cp.val),
          steps=int(s_st.val), stride=int(s_sd.val), bg=float(s_bg.val),
          cmap=str(rb_cmap.value_selected), preset=str(rb_preset.value_selected),
          vectors=bool(cb_vec.get_status()[0]),
          boundary=str(rb_bnd.value_selected).lower(),
          N=int(rb_res.value_selected),
          scheme=str(rb_sch.value_selected)
        )
        s = json.dumps(state, sort_keys=True).encode()
        return hashlib.blake2s(s, digest_size=32).hexdigest().upper()

    def set_quarantine(msg="Quarantined: invalid state (NaN/shape). Press Reset."):
        nonlocal quarantined
        quarantined=True; pause_play()
        ax.set_facecolor('#2b0000')
        help_txt_artist.set_text(msg); help_txt_artist.set_visible(True)
        fig.canvas.draw_idle()

    def clear_quarantine():
        nonlocal quarantined
        quarantined=False; ax.set_facecolor('#111417')
        if not cb_help.get_status()[0]: help_txt_artist.set_visible(False)

    def redraw(stride_changed=False):
        if quarantined: fig.canvas.draw_idle(); return
        try:
            im.set_cmap(rb_cmap.value_selected)
            im.set_data(display_img()); cbar.update_normal(im)
            nonlocal Q, stride, show_vectors
            stride = int(s_sd.val); stride = max(3, min(stride, 32))
            if cb_vec.get_status()[0]:
                if Q is None or stride_changed:
                    remove_quiver(); Q = create_quiver(stride)
                else:
                    U = np.nan_to_num(sim.u[::stride,::stride])
                    V = np.nan_to_num(sim.v[::stride,::stride])
                    if U.size == 0 or V.size == 0:
                        remove_quiver(); Q = create_quiver(stride)
                    else:
                        Q.set_UVC(U, V, np.hypot(U, V))
            else:
                remove_quiver()
            proof_text.set_text("proof_print: " + make_proof_print()[:12])
            fig.canvas.draw_idle()
        except Exception:
            set_quarantine()

    def on_timer():
        if not running or quarantined: return
        sim.dt = float(s_dt.val); sim.base_nu = float(s_nu.val)
        try:
            for _ in range(int(s_st.val)):
                sim.step(frontier_alpha=float(s_al.val),
                         frontier_gain=float(s_gn.val),
                         frontier_cap=float(s_cp.val))
            if not finite_guard(sim.u, sim.v, sim.dye):
                set_quarantine("Quarantined: non-finite values detected. Press Reset."); return
            redraw()
        except Exception:
            set_quarantine()

    timer.add_callback(on_timer)

    # --- Callbacks ---
    def on_run(event):
        if quarantined: return
        pause_play()
        sim.dt = float(s_dt.val); sim.base_nu = float(s_nu.val)
        try:
            for _ in range(int(s_st.val)):
                sim.step(frontier_alpha=float(s_al.val),
                         frontier_gain=float(s_gn.val),
                         frontier_cap=float(s_cp.val))
            if not finite_guard(sim.u, sim.v, sim.dye):
                set_quarantine("Quarantined: non-finite values detected. Press Reset."); return
            redraw()
        except Exception:
            set_quarantine()

    def on_impulse(event):
        if quarantined: return
        sim.add_impulse(0.35, 0.55, radius=8, fx=60.0, fy=0.0,  dye_amt=1.5)
        sim.add_impulse(0.65, 0.45, radius=8, fx=-60.0, fy=10.0, dye_amt=1.5)
        redraw()

    def on_reset(event, noise=False):
        pause_play(); clear_quarantine()
        sim.reset(dye_level=1.0 if noise else 0.0, seed=1)
        redraw(stride_changed=True)

    def on_play(event):
        nonlocal running
        if quarantined: return
        running = not running
        if running:
            b_play.label.set_text('Pause')
            try: timer.start()
            except Exception: pass
        else:
            pause_play()

    def on_stride_change(val):
        if running: pause_play()
        redraw(stride_changed=True)

    def on_bg_change(val):
        nonlocal bg_level
        bg_level = float(val); redraw()

    def on_help_toggle(label):
        help_txt_artist.set_visible(not help_txt_artist.get_visible()); fig.canvas.draw_idle()

    def apply_preset(label):
        text = str(label).strip().lower()
        pause_play(); clear_quarantine()
        sim.reset(dye_level=0.0, seed=1)
        if "shear" in text:
            s_dt.set_val(0.18); s_nu.set_val(0.0020); s_st.set_val(16)
            s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
            sim.add_impulse(0.30, 0.50, radius=9, fx= 80.0, fy=0.0, dye_amt=2.5)
            sim.add_impulse(0.70, 0.50, radius=9, fx=-80.0, fy=0.0, dye_amt=2.5)
        elif "counter" in text or "pair" in text:
            s_dt.set_val(0.18); s_nu.set_val(0.0015); s_st.set_val(18)
            s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
            sim.add_impulse(0.40, 0.60, radius=8, fx= 64.0, fy= 64.0, dye_amt=2.0)
            sim.add_impulse(0.60, 0.40, radius=8, fx=-64.0, fy=-64.0, dye_amt=2.0)
        elif "vortex" in text and "street" in text:
            s_dt.set_val(0.16); s_nu.set_val(0.0025); s_st.set_val(16)
            s_al.set_val(0.90); s_gn.set_val(1.8);    s_cp.set_val(0.8)
            for y in (0.35, 0.50, 0.65):
                sim.add_impulse(0.20, y, radius=6, fx=90.0, fy=0.0, dye_amt=1.8)
        else:
            s_dt.set_val(0.18); s_nu.set_val(0.0020); s_st.set_val(16)
            s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
            sim.add_impulse(0.30, 0.50, radius=9, fx= 80.0, fy=0.0, dye_amt=2.5)
            sim.add_impulse(0.70, 0.50, radius=9, fx=-80.0, fy=0.0, dye_amt=2.5)
        redraw(stride_changed=True)

    def on_boundary_change(label):
        # Rebuild sim with same N, dt, nu but new boundary
        nonlocal sim
        if running: pause_play()
        boundary = str(label).lower()
        sim2 = FluidSim2D(N=sim.N, dt=float(s_dt.val), nu=float(s_nu.val),
                          boundary=boundary, scheme=str(rb_sch.value_selected))
        sim = sim2
        redraw(stride_changed=True)

    def on_resolution_change(label):
        nonlocal sim
        if running: pause_play()
        Nnew = int(label)
        sim2 = FluidSim2D(N=Nnew, dt=float(s_dt.val), nu=float(s_nu.val),
                          boundary=str(rb_bnd.value_selected).lower(),
                          scheme=str(rb_sch.value_selected))
        sim = sim2
        redraw(stride_changed=True)

    def on_scheme_change(label):
        sim.scheme = str(label).lower()
        if running: pause_play()
        redraw()

    # Wire up
    b_run.on_clicked(on_run); b_imp.on_clicked(on_impulse)
    b_rst.on_clicked(lambda e: on_reset(e, noise=False))
    b_rsn.on_clicked(lambda e: on_reset(e, noise=True))
    b_play.on_clicked(on_play)

    rb_preset.on_clicked(apply_preset)
    rb_cmap.on_clicked(lambda _: redraw())
    cb_vec.on_clicked(lambda _lbl: (pause_play(), redraw(True)))
    cb_help.on_clicked(on_help_toggle)

    rb_bnd.on_clicked(on_boundary_change)
    rb_res.on_clicked(on_resolution_change)
    rb_sch.on_clicked(on_scheme_change)

    # Retune while running => pause
    for sld in (s_dt, s_nu, s_al, s_gn, s_cp, s_st):
        sld.on_changed(lambda _val: pause_play())
    s_sd.on_changed(on_stride_change)
    s_bg.on_changed(on_bg_change)

    # White text for dark theme
    def _white_label(obj):
        try: obj.label.set_color('white')
        except Exception: pass
        try: obj.valtext.set_color('white')
        except Exception: pass
    for s in (s_dt,s_nu,s_al,s_gn,s_cp,s_st,s_sd,s_bg): _white_label(s)
    for lab in list(rb_cmap.labels) + list(rb_preset.labels) + \
               list(rb_bnd.labels)  + list(rb_res.labels) + list(rb_sch.labels):
        lab.set_color('white')
    for lab in cb_vec.labels + cb_help.labels: lab.set_color('white')
    cbar.ax.tick_params(colors='white')
    for spine in cbar.ax.spines.values(): spine.set_color('white')

    # Default preset & render
    apply_preset(rb_preset.value_selected)
    redraw(stride_changed=True)
    return fig

# Boot the app
if __name__ == "__main__":
    fig = make_app(N0=128, dt0=0.15, nu0=0.003, boundary0='periodic')
    plt.show()