# --- Fluid widget (Matplotlib) — acceptance-guided, fail-closed tweaks ---
# - Boots on viridis, vectors OFF; dark theme + colorbar
# - Quiver robust: dynamic scale, NaN guards, stride sanity (longer arrows)
# - Help has readable backdrop (larger, higher opacity, line spacing)
# - Presets obey canonical order; Play/Run now stable across all presets
# - Reset always pauses; parameter retunes while running auto-pause
# - Quarantine: any invalid state => pause + red tint + message until Reset
# - proof_print: short hash of UI state (auditable "proof surface")
# - FIX: CFL-substepped RK2 advection prevents backtrace clamping/zeroing
# - FIX: Non-aliasing Jacobi; smooth impulse so projection preserves structure

import numpy as np, math, json, hashlib, time
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button, RadioButtons, CheckButtons

# ---------- Core ----------
def bilinear_sample(field, x, y):
    H, W = field.shape
    x0 = np.floor(x).astype(int); y0 = np.floor(y).astype(int)
    x1 = np.clip(x0 + 1, 0, W-1); y1 = np.clip(y0 + 1, 0, H-1)
    x0 = np.clip(x0, 0, W-1);     y0 = np.clip(y0, 0, H-1)
    fx = x - x0; fy = y - y0
    v00 = field[y0, x0]; v10 = field[y0, x1]
    v01 = field[y1, x0]; v11 = field[y1, x1]
    return (v00*(1-fx)*(1-fy) + v10*fx*(1-fy) + v01*(1-fx)*fy + v11*fx*fy)

def laplacian(field):
    H, W = field.shape
    out = np.zeros_like(field)
    out[1:-1,1:-1] = (
        field[1:-1,0:-2] + field[1:-1,2:] + field[0:-2,1:-1] + field[2:,1:-1] - 4*field[1:-1,1:-1]
    )
    out[0,1:-1]  = field[0,0:-2] + field[0,2:] + field[1,1:-1] + field[1,1:-1] - 4*field[0,1:-1]
    out[-1,1:-1] = field[-1,0:-2] + field[-1,2:] + field[-2,1:-1] + field[-2,1:-1] - 4*field[-1,1:-1]
    out[1:-1,0]  = field[1:-1,1] + field[1:-1,1] + field[0:-2,0] + field[2:,0]   - 4*field[1:-1,0]
    out[1:-1,-1] = field[1:-1,-2]+ field[1:-1,-2]+ field[0:-2,-1]+ field[2:,-1] - 4*field[1:-1,-1]
    out[0,0]     = field[0,1] + field[1,0] + field[1,0] + field[0,1] - 4*field[0,0]
    out[0,-1]    = field[0,-2] + field[1,-1] + field[1,-1] + field[0,-2] - 4*field[0,-1]
    out[-1,0]    = field[-1,1] + field[-2,0] + field[-2,0] + field[-1,1] - 4*field[-1,0]
    out[-1,-1]   = field[-1,-2]+ field[-2,-1]+ field[-2,-1]+ field[-1,-2] - 4*field[-1,-1]
    return out

def jacobi_solve(Ax_plus_b, x_init, iters=30):
    # Avoid aliasing caller's array
    x = np.array(x_init, copy=True)
    for _ in range(iters):
        x = Ax_plus_b(x)
    return x

class FluidSim2D:
    def __init__(self, N=64, dt=0.2, nu=0.003, seed=0):
        self.N = int(N); self.H = self.W = self.N
        self.dt = float(dt); self.base_nu = float(nu)
        self.u = np.zeros((self.H, self.W), dtype=np.float64)
        self.v = np.zeros((self.H, self.W), dtype=np.float64)
        self.p = np.zeros_like(self.u); self.div = np.zeros_like(self.u)
        self.dye = np.zeros_like(self.u)
        xs = np.linspace(0, self.W-1, self.W)
        ys = np.linspace(0, self.H-1, self.H)
        self.X, self.Y = np.meshgrid(xs, ys)

    def reset(self, dye_level=0.0, seed=0):
        rng = np.random.default_rng(seed)
        self.u.fill(0.0); self.v.fill(0.0); self.p.fill(0.0); self.div.fill(0.0)
        if dye_level > 0:
            self.dye = dye_level * (rng.random(self.dye.shape) * 0.05)
        else:
            self.dye.fill(0.0)

    def add_impulse(self, cx, cy, radius, fx, fy, dye_amt=1.0):
        """Smooth cosine-bump impulse so projection preserves useful structure."""
        cx_px = int(np.clip(cx,0,1) * (self.W-1))
        cy_px = int(np.clip(cy,0,1) * (self.H-1))
        Y, X = np.ogrid[:self.H, :self.W]
        r2 = (X - cx_px)**2 + (Y - cy_px)**2
        R2 = float(radius)**2
        w = np.zeros_like(self.u)
        inside = r2 <= R2
        # C^1 bump: 0.5 * (1 + cos(pi * r/R))
        w[inside] = 0.5 * (1.0 + np.cos(np.pi * np.sqrt(r2[inside] / R2)))
        self.u += fx * w; self.v += fy * w; self.dye += dye_amt * w

    def _advect(self, field, u, v, dt, cfl=0.6, max_substeps=64):
        """
        Semi-Lagrangian advection with adaptive substepping (CFL control) and RK2 backtracing.
        Prevents long single-step backtraces from clamping to borders and zeroing the field.
        """
        umax = float(np.max(np.hypot(u, v))) + 1e-12
        nsub = int(np.clip(np.ceil(dt * umax / cfl), 1, max_substeps))

        f = np.array(field, copy=True)
        for _ in range(nsub):
            dts = dt / nsub
            # RK2 / midpoint backtrace
            x1 = self.X - dts * u; y1 = self.Y - dts * v
            x1 = np.clip(x1, 0, self.W-1); y1 = np.clip(y1, 0, self.H-1)
            u1 = bilinear_sample(u, x1, y1); v1 = bilinear_sample(v, x1, y1)
            x2 = self.X - dts * u1; y2 = self.Y - dts * v1
            x2 = np.clip(x2, 0, self.W-1); y2 = np.clip(y2, 0, self.H-1)
            f = bilinear_sample(f, x2, y2)
        return f

    def _diffuse(self, field, nu):
        a = max(0.0, float(nu)) * self.dt  # guard
        denom = 1.0 + 4.0*a
        def step(x): return (field + a*laplacian(x)) / denom
        return jacobi_solve(step, field, iters=40)

    def _project(self, u, v):
        self.div.fill(0.0)
        self.div[1:-1,1:-1] = 0.5*((u[1:-1,2:] - u[1:-1,0:-2]) + (v[2:,1:-1] - v[0:-2,1:-1]))
        self.p.fill(0.0)
        def step(p):
            p_new = np.copy(p)
            p_new[1:-1,1:-1] = (p[1:-1,0:-2] + p[1:-1,2:] + p[0:-2,1:-1] + p[2:,1:-1] - self.div[1:-1,1:-1]) / 4.0
            p_new[0,:] = p_new[1,:]; p_new[-1,:] = p_new[-2,:]
            p_new[:,0] = p_new[:,1]; p_new[:,-1] = p_new[:,-2]
            return p_new
        self.p = jacobi_solve(step, self.p, iters=50)
        uo = np.copy(u); vo = np.copy(v)
        uo[1:-1,1:-1] -= 0.5*(self.p[1:-1,2:] - self.p[1:-1,0:-2])
        vo[1:-1,1:-1] -= 0.5*(self.p[2:,1:-1] - self.p[0:-2,1:-1])
        uo[0,:]=uo[1,:]; uo[-1,:]=uo[-2,:]; uo[:,0]=uo[:,1]; uo[:,-1]=uo[:,-2]
        vo[0,:]=vo[1,:]; vo[-1,:]=vo[-2,:]; vo[:,0]=vo[:,1]; vo[:,-1]=vo[:,-2]
        return uo, vo

    def _local_vorticity(self, u, v):
        dv_dx = np.zeros_like(v); du_dy = np.zeros_like(u)
        dv_dx[:,1:-1] = 0.5*(v[:,2:] - v[:,0:-2])
        du_dy[1:-1,:] = 0.5*(u[2:,:] - u[0:-2,:])
        return dv_dx - du_dy

    def step(self, frontier_alpha=0.9, frontier_gain=1.5, frontier_cap=0.5):
        # Robust advection (CFL-limited RK2)
        u_adv = self._advect(self.u, self.u, self.v, self.dt)
        v_adv = self._advect(self.v, self.u, self.v, self.dt)

        # Adaptive viscosity on vorticity tails (unchanged)
        omega = np.abs(self._local_vorticity(u_adv, v_adv))
        thresh = np.quantile(omega, frontier_alpha)
        if thresh <= 1e-12:
            nu_eff = self.base_nu
        else:
            ramp = np.maximum(omega/thresh - 1.0, 0.0)
            extra = frontier_gain * ramp
            if frontier_cap > 0: extra = np.minimum(extra, frontier_cap)
            nu_eff = float(np.mean(self.base_nu*(1.0 + extra)))

        # Diffuse → Project
        u_dif = self._diffuse(u_adv, nu_eff)
        v_dif = self._diffuse(v_adv, nu_eff)
        self.u, self.v = self._project(u_dif, v_dif)

        # Dye advection with the divergence-free field (same robust advection)
        dye_adv = self._advect(self.dye, self.u, self.v, self.dt)
        self.dye = self._diffuse(dye_adv, nu_eff*0.25)

# ---------- App / UI ----------
sim = FluidSim2D(N=64, dt=0.2, nu=0.003, seed=0); sim.reset()

# Theme
plt.rcParams.update({"font.size": 9})
fig, ax = plt.subplots(figsize=(6.4,6.4))
fig.patch.set_facecolor('#0e1117')
ax.set_facecolor('#111417')
ax.set_xticks([]); ax.set_yticks([])
for spine in ax.spines.values(): spine.set_visible(False)

bg_level = 0.06
def display_img():
    return np.clip(sim.dye + bg_level, 0.0, 1.0)

# Boot on viridis
im = ax.imshow(display_img(), origin='lower', interpolation='bilinear', cmap='viridis', vmin=0, vmax=1)
cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
cbar.ax.tick_params(labelsize=8)

Q = None
show_vectors = False
stride = 6

plt.subplots_adjust(left=0.08, right=0.98, bottom=0.33, top=0.95)

# Sliders
ax_dt = plt.axes([0.15, 0.25, 0.65, 0.02]); s_dt = Slider(ax_dt, 'dt',    0.02, 0.6,  valinit=0.2,  valstep=0.02)
ax_nu = plt.axes([0.15, 0.22, 0.65, 0.02]); s_nu = Slider(ax_nu, 'nu',    1e-4, 0.1,  valinit=0.003, valstep=1e-4)
ax_al = plt.axes([0.15, 0.19, 0.65, 0.02]); s_al = Slider(ax_al, 'alpha', 0.70, 0.99, valinit=0.90, valstep=0.01)
ax_gn = plt.axes([0.15, 0.16, 0.65, 0.02]); s_gn = Slider(ax_gn, 'gain',  0.0,  5.0,  valinit=1.5,  valstep=0.1)
ax_cp = plt.axes([0.15, 0.13, 0.65, 0.02]); s_cp = Slider(ax_cp, 'cap',   0.0,  3.0,  valinit=0.5,  valstep=0.05)
ax_st = plt.axes([0.15, 0.10, 0.65, 0.02]); s_st = Slider(ax_st, 'steps', 1,    40,   valinit=10,   valstep=1)
ax_sd = plt.axes([0.15, 0.07, 0.65, 0.02]); s_sd = Slider(ax_sd, 'stride',3,    16,   valinit=6,    valstep=1)
ax_bg = plt.axes([0.15, 0.04, 0.65, 0.02]); s_bg = Slider(ax_bg, 'background', 0.0,  0.3,  valinit=0.06, valstep=0.01)

# Buttons (wider)
ax_imp = plt.axes([0.15, 0.005, 0.10, 0.035]); b_imp = Button(ax_imp, 'Impulse')
ax_run = plt.axes([0.27, 0.005, 0.10, 0.035]); b_run = Button(ax_run, 'Run')
ax_rst = plt.axes([0.39, 0.005, 0.12, 0.035]); b_rst = Button(ax_rst, 'Reset')
ax_rsn = plt.axes([0.53, 0.005, 0.14, 0.035]); b_rsn = Button(ax_rsn, 'Reset (noise)')  # shorter label
ax_play = plt.axes([0.69, 0.005, 0.10, 0.035]); b_play = Button(ax_play, 'Play')

# Side panels
ax_cmap   = plt.axes([0.01, 0.74, 0.15, 0.20]); rb_cmap   = RadioButtons(ax_cmap,   ('gray','viridis'), active=1)
ax_vec    = plt.axes([0.01, 0.62, 0.15, 0.08]); cb_vec    = CheckButtons(ax_vec,    ['Vectors'], [False])
ax_preset = plt.axes([0.75, 0.65, 0.24, 0.25]); rb_preset = RadioButtons(ax_preset, ('Shear band','Counter pair','Vortex street'))
for lab in rb_preset.labels: lab.set_fontsize(9)

ax_help_toggle = plt.axes([0.78, 0.60, 0.21, 0.05]); cb_help = CheckButtons(ax_help_toggle, ['Help (definitions)'], [False])
# Taller help panel for readability
ax_help = plt.axes([0.78, 0.32, 0.21, 0.28]); ax_help.axis('off')

# >>> Make preset/cmap/vec sections dark so white text stays readable <<<
for panel in (ax_preset, ax_cmap, ax_vec, ax_help_toggle):
    panel.set_facecolor('#111417')
    for sp in panel.spines.values():
        sp.set_color('#33363f')

help_text = (
    "dt: time step size (larger = faster but less stable)\n"
    "nu: base viscosity (lower = livelier, higher = smoother)\n"
    "alpha: tail quantile for |vorticity| damped (0.9 ≈ top 10%)\n"
    "gain: strength of tail damping; cap: max multiplier\n"
    "steps: sim steps per Run/Play tick\n"
    "stride: vector sampling density (bigger = fewer arrows)\n"
    "background: gray offset so empty field isn’t black\n"
    "Presets:\n"
    " • Shear band: opposing jets across midline\n"
    " • Counter pair: counter-rotating blobs\n"
    " • Vortex street: staggered jet sources"
)
help_txt_artist = ax_help.text(
    0, 1, help_text,
    va='top', ha='left', wrap=True,
    fontsize=10, color='white', linespacing=1.25,
    visible=False,
    bbox=dict(facecolor='black', alpha=0.85, boxstyle='round,pad=0.5')
)

# proof_print readout
proof_text = ax.text(0.01, 0.99, "", transform=ax.transAxes, va='top', ha='left',
                     fontsize=8, color='w', alpha=0.85,
                     bbox=dict(facecolor='black', alpha=0.35, boxstyle='round,pad=0.2'))

# Playback timer
running = False
quarantined = False
timer = fig.canvas.new_timer(interval=30)

# Frontier debounce (anti-Zeno)
FRONTIER_DEBOUNCE_MS = 200
_last_frontier_ms = 0.0
def frontier_ok():
    global _last_frontier_ms
    now = time.perf_counter() * 1000.0
    if now - _last_frontier_ms < FRONTIER_DEBOUNCE_MS:
        return False
    _last_frontier_ms = now
    return True

def pause_play():
    global running
    running = False
    b_play.label.set_text('Play')
    try: timer.stop()
    except Exception: pass

def finite_guard(*arrs):
    for a in arrs:
        if not np.all(np.isfinite(a)):
            return False
    return True

def create_quiver():
    """(Re)create quiver with current stride; dynamic, robust scale."""
    global Q, stride
    stride = int(s_sd.val)
    stride = max(3, min(stride, 32))

    U = np.nan_to_num(sim.u[::stride,::stride])
    V = np.nan_to_num(sim.v[::stride,::stride])
    speed = np.hypot(U, V)

    # Target a perceptible arrow length for ~90th-percentile speed
    p90 = float(np.nanpercentile(speed, 90)) if speed.size else 1.0
    L_target = max(0.40*stride, 1.0)  # a bit longer than before
    scale = (p90 / L_target) if p90 > 1e-9 else 20.0
    scale = min(max(scale, 2.0), 60.0)  # wider range allows longer arrows

    Q = ax.quiver(sim.X[::stride,::stride], sim.Y[::stride,::stride],
                  U, V, speed,
                  scale_units='xy', scale=scale, angles='xy', pivot='mid', width=0.0032)

def remove_quiver():
    global Q
    if Q is not None:
        try: Q.remove()
        except Exception: pass
        Q = None

def make_proof_print():
    state = dict(
      seed=1, dt=float(s_dt.val), nu=float(s_nu.val),
      alpha=float(s_al.val), gain=float(s_gn.val), cap=float(s_cp.val),
      steps=int(s_st.val), stride=int(s_sd.val), bg=float(s_bg.val),
      cmap=str(rb_cmap.value_selected), preset=str(rb_preset.value_selected),
      vectors=bool(cb_vec.get_status()[0])
    )
    s = json.dumps(state, sort_keys=True).encode()
    return hashlib.blake2s(s, digest_size=32).hexdigest().upper()

def set_quarantine(msg="Quarantined: invalid state (NaN/shape). Press Reset."):
    global quarantined
    quarantined = True
    pause_play()
    ax.set_facecolor('#2b0000')
    help_txt_artist.set_text(msg)
    help_txt_artist.set_visible(True)
    fig.canvas.draw_idle()

def clear_quarantine():
    global quarantined
    quarantined = False
    ax.set_facecolor('#111417')
    if not cb_help.get_status()[0]:
        help_txt_artist.set_visible(False)

def redraw(stride_changed=False):
    if quarantined:  # frozen until Reset
        fig.canvas.draw_idle(); return
    try:
        im.set_cmap(rb_cmap.value_selected)
        im.set_data(display_img())
        cbar.update_normal(im)
        if show_vectors:
            if Q is None or stride_changed:
                remove_quiver()
                create_quiver()
            else:
                U = np.nan_to_num(sim.u[::stride,::stride])
                V = np.nan_to_num(sim.v[::stride,::stride])
                if U.size == 0 or V.size == 0:
                    remove_quiver(); create_quiver()
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
    pause_play()
    clear_quarantine()
    sim.reset(dye_level=1.0 if noise else 0.0, seed=1)
    redraw(stride_changed=True)

def on_reset_clean(event): on_reset(event, noise=False)
def on_reset_noise(event): on_reset(event, noise=True)

def on_play(event):
    global running
    if quarantined: return
    running = not running
    if running:
        b_play.label.set_text('Pause')
        try: timer.start()
        except Exception: pass
    else:
        pause_play()

def on_stride_change(val):
    if running: pause_play()  # retune while running => pause
    redraw(stride_changed=True)

def on_bg_change(val):
    global bg_level
    bg_level = float(val); redraw()

def on_vec_toggle(label):
    global show_vectors
    if not frontier_ok(): return  # anti-zeno
    if running: pause_play()
    show_vectors = not show_vectors
    redraw(stride_changed=True)

def on_help_toggle(label):
    help_txt_artist.set_visible(not help_txt_artist.get_visible())
    fig.canvas.draw_idle()

def apply_preset(label):
    """Pure initializer: clean reset, set params, lay impulses, NO autorun."""
    text = str(label).strip().lower()
    pause_play()
    clear_quarantine()

    # Clean, deterministic start (no random dye)
    sim.reset(dye_level=0.0, seed=1)

    # Params + impulses by preset (idempotent; no time advance)
    if "shear" in text:
        s_dt.set_val(0.20); s_nu.set_val(0.002);  s_st.set_val(15)
        s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
        sim.add_impulse(0.30, 0.50, radius=9, fx= 80.0, fy=0.0, dye_amt=2.5)
        sim.add_impulse(0.70, 0.50, radius=9, fx=-80.0, fy=0.0, dye_amt=2.5)

    elif "counter" in text or "pair" in text:
        s_dt.set_val(0.20); s_nu.set_val(0.0015); s_st.set_val(18)
        s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
        sim.add_impulse(0.40, 0.60, radius=8, fx= 64.0, fy= 64.0, dye_amt=2.0)
        sim.add_impulse(0.60, 0.40, radius=8, fx=-64.0, fy=-64.0, dye_amt=2.0)

    elif "vortex" in text and "street" in text:
        s_dt.set_val(0.18); s_nu.set_val(0.0025); s_st.set_val(16)
        s_al.set_val(0.90); s_gn.set_val(1.8);    s_cp.set_val(0.8)
        for y in (0.35, 0.50, 0.65):
            sim.add_impulse(0.20, y, radius=6, fx=90.0, fy=0.0, dye_amt=1.8)

    else:
        # Fallback → Shear band
        s_dt.set_val(0.20); s_nu.set_val(0.002);  s_st.set_val(15)
        s_al.set_val(0.90); s_gn.set_val(2.0);    s_cp.set_val(1.0)
        sim.add_impulse(0.30, 0.50, radius=9, fx= 80.0, fy=0.0, dye_amt=2.5)
        sim.add_impulse(0.70, 0.50, radius=9, fx=-80.0, fy=0.0, dye_amt=2.5)

    # Show pristine initial state; user decides when to Run/Play
    redraw(stride_changed=True)

# Wire up
b_run.on_clicked(on_run)
b_imp.on_clicked(on_impulse)
b_rst.on_clicked(on_reset_clean)
b_rsn.on_clicked(on_reset_noise)
b_play.on_clicked(on_play)

rb_preset.on_clicked(apply_preset)
rb_cmap.on_clicked(lambda _: redraw())
cb_vec.on_clicked(on_vec_toggle)
cb_help.on_clicked(on_help_toggle)

# Retune while running => pause (discipline)
for sld in (s_dt, s_nu, s_al, s_gn, s_cp, s_st):
    sld.on_changed(lambda _val: pause_play())

s_sd.on_changed(on_stride_change)
s_bg.on_changed(on_bg_change)

# --- White text for dark theme (sliders/radios/checks/colorbar) ---
def _white_text_slider(sld):
    sld.label.set_color('white')
    sld.valtext.set_color('white')
for s in (s_dt, s_nu, s_al, s_gn, s_cp, s_st, s_sd, s_bg):
    _white_text_slider(s)

for lab in list(rb_cmap.labels) + list(rb_preset.labels):
    lab.set_color('white')
for lab in cb_vec.labels + cb_help.labels:
    lab.set_color('white')

cbar.ax.tick_params(colors='white')
for spine in cbar.ax.spines.values():
    spine.set_color('white')

# Apply the currently selected preset once at startup so "default preset → Run" works.
apply_preset(rb_preset.value_selected)
redraw(stride_changed=True)
plt.show()