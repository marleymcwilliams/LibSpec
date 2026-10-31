# The pilot's report on the release

openai/math at `7ef5c0c`, θ = 0 on every axis, no leases. It grades 724 manuscripts: the 721 that `CONTENTS.md` lists, and the 3 withdrawn ones it no longer lists. Every verdict is proved by the kernel (`JSG.Pilot.CatalogueCalibration`): none is accepted today, so each report says what evidence is missing.

Comparator results come from our trusted shard runs, [run 41146560423](https://github.com/marleymcwilliams/LibSpec/actions/runs/41146560423), [run 41170918445](https://github.com/marleymcwilliams/LibSpec/actions/runs/41170918445), [run 41181960510](https://github.com/marleymcwilliams/LibSpec/actions/runs/41181960510) and [run 41222068108](https://github.com/marleymcwilliams/LibSpec/actions/runs/41222068108). Of the 418 challenges, 396 were accepted, 2 were too large to check yet, 11 ended in a build error and on 9 the kernels disagreed; none was rejected. A build error, a timeout or the kernels disagreeing leaves `formal_proof` unknown, never failing.

## What's missing, by axis

A report names every axis that holds its manuscript back, so a manuscript counts under each one.

| Axis | Manuscripts | Why, and how many |
| --- | --- | --- |
| `withdrawn` | 3 | its authors withdrew it on October 6, 2026: 3 |
| `dependency_withdrawn` | 724 | unknown: its dependencies aren't read yet: 722; through Algebraicity of Weil classes on split abelian eightfolds: 2 |
| `formal_proof` | 411 | unknown: no formalization: 380; unknown: the kernels disagree: nanoda failed while Lean's kernel accepted: 12; unknown: its build failed or was stopped: 16; unknown: too large to check yet: 3 |
| `statement_fidelity` | 724 | unknown: no named reviewer has checked its statement: 724 |
| `axioms` | 380 | unknown: no challenge: 380 |
| `independent_review` | 724 | unknown: 724 |
| `novelty` | 724 | unknown: 724 |

## The reports

Every manuscript's report is one of these.

1. **313 manuscripts:** not accepted: evidence incomplete on `dependency_withdrawn` (unknown: its dependencies aren't read yet), `statement_fidelity` (unknown: no named reviewer has checked its statement), `independent_review` (unknown), `novelty` (unknown)
2. **377 manuscripts:** not accepted: evidence incomplete on `dependency_withdrawn` (unknown: its dependencies aren't read yet), `formal_proof` (unknown: no formalization), `statement_fidelity` (unknown: no named reviewer has checked its statement), `axioms` (unknown: no challenge), `independent_review` (unknown), `novelty` (unknown)
3. **12 manuscripts:** not accepted: evidence incomplete on `dependency_withdrawn` (unknown: its dependencies aren't read yet), `formal_proof` (unknown: the kernels disagree: nanoda failed while Lean's kernel accepted), `statement_fidelity` (unknown: no named reviewer has checked its statement), `independent_review` (unknown), `novelty` (unknown)
4. **16 manuscripts:** not accepted: evidence incomplete on `dependency_withdrawn` (unknown: its dependencies aren't read yet), `formal_proof` (unknown: its build failed or was stopped), `statement_fidelity` (unknown: no named reviewer has checked its statement), `independent_review` (unknown), `novelty` (unknown)
5. **2 manuscripts:** not accepted: evidence incomplete on `withdrawn` (its authors withdrew it on October 6, 2026), `dependency_withdrawn` (through Algebraicity of Weil classes on split abelian eightfolds), `formal_proof` (unknown: no formalization), `statement_fidelity` (unknown: no named reviewer has checked its statement), `axioms` (unknown: no challenge), `independent_review` (unknown), `novelty` (unknown)
6. **1 manuscript:** not accepted: evidence incomplete on `withdrawn` (its authors withdrew it on October 6, 2026), `dependency_withdrawn` (unknown: its dependencies aren't read yet), `formal_proof` (unknown: no formalization), `statement_fidelity` (unknown: no named reviewer has checked its statement), `axioms` (unknown: no challenge), `independent_review` (unknown), `novelty` (unknown)
7. **3 manuscripts:** not accepted: evidence incomplete on `dependency_withdrawn` (unknown: its dependencies aren't read yet), `formal_proof` (unknown: too large to check yet), `statement_fidelity` (unknown: no named reviewer has checked its statement), `independent_review` (unknown), `novelty` (unknown)

## Every manuscript

By family. The withdrawn ones, which `CONTENTS.md` no longer lists, come first. Challenges counts the Comparator challenges on the family's docs page that cover it.

| Family | Manuscript | Challenges | Report |
| --- | --- | --- | --- |
| — | Algebraicity of Kuga-Satake Correspondences for K3 Surfaces | 0 | 5 |
| — | Algebraicity of Weil classes on split abelian eightfolds | 0 | 6 |
| — | The rational Hodge conjecture for products of K3 surfaces | 0 | 5 |
| 001 | Milne's rationality conjecture for abelian varieties | 0 | 2 |
| 002 | Exact Birch–Swinnerton-Dyer Formula from Low Selmer Corank | 0 | 2 |
| 002 | The Selmer converse for elliptic curves at every prime | 0 | 2 |
| 002 | The two-primary Birch–Swinnerton-Dyer formula in Selmer corank at most one | 0 | 2 |
| 003 | The Quasi-Riemann Hypothesis | 0 | 2 |
| 003 | The Quasi-Riemann Hypothesis: A Zero-Free Half-Plane Re(s)>7/8 | 4 | 1 |
| 003 | Uniform exclusion of Landau–Siegel zeros | 4 | 1 |
| 004 | A pointwise 2-converse for elliptic curves with rational two-torsion | 0 | 2 |
| 004 | Hilbert's tenth problem over the rational numbers | 0 | 2 |
| 005 | Catalan's constant is irrational | 1 | 1 |
| 006 | Goldfeld's analytic density conjecture and the 2-converse for elliptic curves | 0 | 2 |
| 006 | The mean analytic rank of quadratic twists of elliptic curves | 0 | 2 |
| 007 | Ordinary two-point correlations of multiplicative functions | 2 | 1 |
| 008 | The Deligne-Drinfeld conjecture | 1 | 1 |
| 009 | Reconstruction from Milnor K-theory modulo the characteristic | 0 | 2 |
| 009 | Reconstruction of Function Fields from Mod-ℓ Milnor K-Theory | 0 | 2 |
| 009 | The Bogomolov-Pop reconstruction theorem | 1 | 1 |
| 010 | Fontaine–Mazur modularity at the prime 2 | 0 | 2 |
| 010 | The Dimension of the Two-Adic Hecke Algebra at Odd Level | 0 | 2 |
| 010 | Unrestricted pro-modularity at the prime two | 0 | 2 |
| 011 | Prime Predecessors with an Even Number of Prime Factors | 0 | 2 |
| 011 | The Poisson-Dirichlet law for prime predecessors | 0 | 2 |
| 011 | Weighted dilation graphs, smooth shifted primes and totient fibers | 0 | 2 |
| 012 | The joint Dickman law for consecutive integers | 1 | 1 |
| 013 | The additive indecomposability of the primes | 2 | 1 |
| 014 | Constructible tame Hecke eigensheaves in positive characteristic | 0 | 2 |
| 014 | Frobenius Structures on Tame Hecke Eigensheaves | 0 | 2 |
| 014 | Global Arthur Enhancements of Cuspidal Excursion Parameters | 0 | 2 |
| 014 | Ramanujan-Arthur Decompositions of Cuspidal Functions at Full Finite Level | 0 | 2 |
| 014 | Rationality of the Canonical Unramified Arthur Filtration | 0 | 2 |
| 014 | Tame Hecke Eigensheaves with Several Marked Points | 0 | 2 |
| 014 | Temperedness at ramified places for globally generic exceptional groups | 0 | 2 |
| 014 | The Restricted Geometric Langlands Equivalence in Positive Characteristic | 0 | 2 |
| 015 | Equidistribution of Prime-Degree Torus Packets with Arbitrary Local Type | 1 | 1 |
| 015 | Equidistribution of Primitive Sextic Torus Packets | 0 | 2 |
| 015 | Equidistribution of primitive quartic torus packets for arbitrary orders | 0 | 2 |
| 016 | Elliptic squares and Zilber-Pink for curves in A2 | 0 | 2 |
| 016 | Quaternionic division points on curves in the Siegel threefold | 0 | 2 |
| 016 | The E×CM component of Zilber-Pink for curves in A2 | 0 | 2 |
| 016 | The abelian Zilber-Pink conjecture | 0 | 2 |
| 017 | The irrationality exponent of π is 2 | 1 | 1 |
| 018 | The Margulis–Platonov conjecture over global function fields | 0 | 2 |
| 018 | The Margulis–Platonov conjecture over number fields | 0 | 2 |
| 019 | The p-adic section conjecture | 0 | 2 |
| 019 | Étale covers with a prescribed exterior sheet | 0 | 2 |
| 020 | Squarefree values of quartics and power-free values of polynomials | 1 | 1 |
| 021 | A quadratic bound for Jacobsthal's function | 2 | 1 |
| 022 | The Weak Inhomogeneous Duffin–Schaeffer Conjecture | 0 | 2 |
| 023 | An unconditional first moment for cubic Gauss sums | 1 | 1 |
| 024 | An asymptotic formula for the number of totients | 2 | 1 |
| 025 | Short Egyptian fractions | 2 | 1 |
| 026 | Positive lower density of large prime gaps | 1 | 1 |
| 027 | Integral points on character varieties of curves | 1 | 1 |
| 028 | Bounded-Step Walks on Gaussian Primes | 1 | 1 |
| 029 | Primitive roots for every admissible integer base | 0 | 2 |
| 029 | Simultaneous primitive roots: a conditional lower bound for prime bases | 0 | 2 |
| 030 | Modularity of elliptic curves over imaginary quadratic fields | 0 | 2 |
| 031 | Open Homomorphisms of Global Solvably Closed Galois Groups | 0 | 2 |
| 032 | A Conditional Reduction for Algebraic Kuga–Satake Correspondences | 0 | 2 |
| 032 | Abelian covers, Gale correspondences, and the Hodge conjecture for powers | 0 | 2 |
| 032 | Algebraic Kuga–Satake correspondences and Hodge conjectures on a K3 quadratic locus | 0 | 2 |
| 032 | The rational Hodge conjecture for CM abelian varieties | 0 | 2 |
| 032 | Weil classes and Hodge classes on abelian powers | 0 | 2 |
| 033 | B-semiampleness for compact log-smooth Kähler fibrations | 0 | 2 |
| 033 | Logarithmic Kodaira dimension and whole-fiber variation | 0 | 2 |
| 033 | Orbifold and logarithmic Iitaka subadditivity | 0 | 2 |
| 033 | Projective Hodge lines and ordinary Iitaka subadditivity | 0 | 2 |
| 033 | The reverse logarithmic Kodaira inequality and additivity | 1 | 1 |
| 034 | Abundance after nonvanishing for compact Kähler fourfolds | 0 | 2 |
| 034 | Arithmetic Stein-degree bounds for log Calabi–Yau pairs | 0 | 2 |
| 034 | Conditional good minimal models for compact Kähler fourfolds | 0 | 2 |
| 034 | Fourfold nonvanishing by minimal metrics and moving jets | 0 | 2 |
| 034 | Lifting sections from the reduced support of an adjoint | 0 | 2 |
| 034 | Log abundance for compact Kähler spaces under logarithmic Iitaka subadditivity | 0 | 2 |
| 034 | Log abundance in characteristic zero | 0 | 2 |
| 034 | Minimal metrics and interior injectivity for nef adjoints | 0 | 2 |
| 034 | Relative denominators and effective systems for log Calabi-Yau fibrations | 0 | 2 |
| 034 | Schnell fiber spaces and good canonical models | 0 | 2 |
| 034 | Uniform Pluricanonical Iitaka Fibrations | 0 | 2 |
| 034 | Uniform effective log Iitaka fibrations for fourfolds | 0 | 2 |
| 034 | Uniform indices for semi-log-canonical log Calabi–Yau pairs | 0 | 2 |
| 034 | Uniform log Iitaka fibrations and bounded moduli denominators | 0 | 2 |
| 035 | Abundance in numerical dimension one for terminal threefolds in positive characteristic | 0 | 2 |
| 035 | Log abundance in numerical dimension one for threefolds in positive characteristic | 0 | 2 |
| 036 | Minimal models and Mori fibre spaces for generalized log canonical Q-pairs | 0 | 2 |
| 036 | Minimal models in numerical dimension one | 0 | 2 |
| 036 | Numerical Semiampleness of Nef Adjoint Divisors | 0 | 2 |
| 036 | Numerical semiampleness of nef adjoint classes on compact Kähler manifolds | 0 | 2 |
| 037 | The normalized-volume gap in dimension four | 0 | 2 |
| 037 | The ordinary-double-point gap in every dimension | 0 | 2 |
| 038 | Fujita's freeness conjecture | 0 | 2 |
| 039 | Maximal Multipoint Seshadri Constants in Higher Dimensions | 0 | 2 |
| 039 | Maximal Seshadri constants on arbitrary polarized surfaces | 2 | 1 |
| 039 | Maximal multipoint Seshadri constants in positive characteristic | 0 | 2 |
| 039 | Nagata's conjecture for plane curves | 2 | 1 |
| 040 | Bloch’s conjecture for surfaces with p_g=0 | 0 | 2 |
| 041 | Projective-space bases of Lagrangian fibrations | 0 | 2 |
| 041 | The strong hyperkähler SYZ conjecture | 0 | 2 |
| 042 | Every complex K3 surface is Oka | 0 | 2 |
| 043 | P=W in composite rank for fixed determinant | 0 | 2 |
| 044 | The equivariant cohomological Hikita conjecture for arbitrary quivers | 0 | 2 |
| 046 | A projective fourfold with large fundamental group and non-Stein universal cover | 0 | 2 |
| 046 | A surface counterexample to Shafarevich holomorphic convexity | 0 | 2 |
| 047 | An explicit failure of complex affine-space cancellation | 1 | 1 |
| 048 | A singular normal affine surface with free tangent sheaf | 0 | 2 |
| 049 | A stable coordinate that is not a coordinate in four variables | 3 | 1 |
| 049 | An explicit noncoordinate polynomial with affine three-space zero fibre | 3 | 1 |
| 050 | Ample rank-two bundles on the quadric surface without Griffiths-positive metrics | 1 | 1 |
| 051 | Canonical ampleness of compact hyperbolic Kähler manifolds | 0 | 2 |
| 052 | Integrability of split tangent bundles on rationally connected manifolds | 2 | 1 |
| 052 | Universal-cover splitting for compact Kähler manifolds | 2 | 1 |
| 053 | A high-arity counterexample to Pixton completeness in Chow | 0 | 2 |
| 054 | Irrational cubic fourfolds with geometric K3 categories | 0 | 2 |
| 055 | A Gepner stability condition on every smooth quintic threefold | 0 | 2 |
| 055 | Prescribed large-volume charges on threefolds with trivial canonical bundle | 0 | 2 |
| 056 | Finite ordinary minimal model programs on compact Kähler fourfolds | 0 | 2 |
| 056 | Finite ordinary minimal model programs on compact Kähler fourfolds | 0 | 2 |
| 056 | Termination for projective log canonical fourfolds with rational boundary | 0 | 2 |
| 056 | Termination of generalized log canonical flips on compact Kähler fourfolds | 0 | 2 |
| 056 | Termination of generalized-canonical flips on compact Kähler fourfolds | 0 | 2 |
| 057 | A conditional abelianity theorem for special fourfold pairs with a half-weight divisor | 0 | 2 |
| 057 | The abelianity conjecture for special compact Kähler manifolds | 0 | 2 |
| 057 | Two-step monodromy of special quasi-projective varieties | 0 | 2 |
| 058 | Semialgebraic universal covers of normal projective varieties | 0 | 2 |
| 058 | Symmetry of semialgebraic bounded domains with compact quotient | 1 | 1 |
| 059 | Ambiently homeomorphic isolated hypersurface germs in $\mathbb{C}^4$ with multiplicities four and five | 0 | 2 |
| 059 | Ambiently homeomorphic isolated hypersurfaces of multiplicities two and three | 0 | 2 |
| 060 | Global Spherical Shells on Minimal Surfaces of Class VII | 0 | 2 |
| 062 | Contact Fano manifolds and the LeBrun–Salamon conjecture | 0 | 2 |
| 063 | The generalized Mukai conjecture | 0 | 2 |
| 064 | Topological triviality of $\mu$-constant families of surface singularities | 0 | 2 |
| 065 | Virasoro Constraints for Projective Complete Intersections | 0 | 2 |
| 065 | Virasoro Constraints under Projectivization | 0 | 2 |
| 066 | Bounded klt complements for Fano contractions | 0 | 2 |
| 066 | Uniform Cartier sections for Fano type contractions | 1 | 1 |
| 067 | The Campana–Peternell conjecture in dimension six | 0 | 2 |
| 068 | Anticanonical nonvanishing from smooth semipositivity | 0 | 2 |
| 068 | Bounded anticanonical metrics on klt pairs and torus quotients | 0 | 2 |
| 068 | Cohomological transfer and equivariant anticanonical sections | 0 | 2 |
| 068 | Exact orders and invariant anticanonical linear systems | 0 | 2 |
| 068 | Integrable metrics and effectivity with controlled boundary | 0 | 2 |
| 068 | Invariant anticanonical indices and conversion of twisted differentials | 0 | 2 |
| 068 | Metric descent and rank-preserving contractions | 0 | 2 |
| 069 | Global quantum geometric Langlands at irrational level | 0 | 2 |
| 071 | Koebe's Circle-Domain Conjecture | 1 | 1 |
| 071 | Removable Boundaries and Rigidity of Circle Domains | 1 | 1 |
| 072 | A strict inverse-first-power bound for univalent functions | 3 | 1 |
| 072 | Brennan's conjecture and sharp inverse-square integral means | 3 | 1 |
| 073 | The Falconer distance conjecture in all dimensions | 2 | 1 |
| 074 | Every Four-Dimensional Kakeya Set Has Full Hausdorff Dimension | 0 | 2 |
| 074 | The Kakeya maximal conjecture in three dimensions | 0 | 2 |
| 075 | Almost-everywhere Fourier convergence in $L\log L$ | 1 | 1 |
| 076 | Asymptotically minimal maxima of real Littlewood polynomials | 2 | 1 |
| 076 | Nearly minimal maxima and positive minima of Littlewood polynomials | 0 | 2 |
| 076 | Ultraflat real Littlewood polynomials | 0 | 2 |
| 077 | Diagonal Fourier extension for positively curved surfaces in three dimensions | 0 | 2 |
| 077 | Elliptic capacity propagation and Fourier restriction to the sphere | 0 | 2 |
| 078 | Bochner–Riesz multipliers in three dimensions | 0 | 2 |
| 079 | Critical local smoothing for the three-dimensional wave equation | 1 | 1 |
| 079 | Local smoothing for the Euclidean wave equation | 1 | 1 |
| 080 | Endpoint convergence for the planar Schrödinger equation | 0 | 2 |
| 080 | Endpoint pointwise convergence for the Schrödinger equation in higher dimensions | 0 | 2 |
| 081 | Riesz transforms and uniform rectifiability in higher codimension | 1 | 1 |
| 082 | An L³ bound for the dyadic triangular Hilbert form | 0 | 2 |
| 082 | Annular variation of the triangular Hilbert transform at the symmetric point | 0 | 2 |
| 082 | The maximal triangular Hilbert transform at the symmetric point | 1 | 1 |
| 083 | A uniform Hilbert transform estimate for Lipschitz directions | 1 | 1 |
| 084 | The dyadic case of the Erdős similarity conjecture | 1 | 1 |
| 084 | The geometric case of the Erdős similarity conjecture | 0 | 2 |
| 085 | An Endpoint Gradient Bound for the Centered Disk Maximal Operator | 2 | 1 |
| 086 | An $L^3$ bound for the trilinear Hilbert transform | 0 | 2 |
| 087 | Symplectic Balls in Symmetric Polar Products | 4 | 1 |
| 087 | The Mahler Conjecture for General Convex Bodies | 4 | 1 |
| 087 | The symmetric Mahler conjecture and its equality cases | 4 | 1 |
| 088 | A product counterexample to the simplex maximum for projection-body volume | 3 | 1 |
| 088 | Petty’s projection-volume conjecture in dimensions at least four | 3 | 1 |
| 089 | $L_1$ Embeddings of Graphs of Bounded Treewidth | 2 | 1 |
| 089 | Planar Graph Metrics Embed into $L_1$ with Constant Distortion | 2 | 1 |
| 090 | A sharp Fourier certificate for planar circle packing | 4 | 4 |
| 090 | An atomic certificate for triangular-lattice universal optimality | 4 | 4 |
| 090 | Triangular minimality for planar Coulomb renormalized energy | 0 | 2 |
| 090 | Universal optimality of the triangular lattice | 0 | 2 |
| 091 | The logarithmic Brunn–Minkowski conjecture | 1 | 1 |
| 092 | A single-lattice covering bound of order n log n | 2 | 1 |
| 092 | Translative covering densities of order n log n | 2 | 1 |
| 093 | A dimension-free logarithmic Sobolev inequality for subgaussian log-concave measures | 0 | 2 |
| 094 | Subpolynomial dimension reduction in $L_p$ | 1 | 1 |
| 095 | A nonspectrahedral hyperbolicity cone | 1 | 1 |
| 095 | An Exact Semidefinite Lift of a Nonspectrahedral Hyperbolicity Cone | 0 | 2 |
| 095 | Hyperbolicity Cones Without Semidefinite Lifts | 0 | 2 |
| 096 | The Gaussian propeller bound in every dimension | 1 | 1 |
| 097 | The Euclidean Steinitz–Bergström theorem | 1 | 1 |
| 098 | A doubling Hilbert subset with no finite-dimensional bi-Lipschitz embedding | 2 | 1 |
| 099 | Edit Distance in $\ell_1$: Matching Bounds up to Constants in the Exponent | 4 | 1 |
| 099 | Finite-Circle Obstructions, Binary Codes, and Histogram Embeddings for Edit Distance | 4 | 1 |
| 099 | Tree Constructions for the $\ell_1$ Distortion of Binary Edit Distance | 4 | 1 |
| 100 | Finite angular cylinder covers below the half-area bound | 3 | 1 |
| 100 | Finite cylinder approximation of ruled sets | 3 | 1 |
| 100 | Finite triangular approximation of radial sweeps | 3 | 1 |
| 100 | Slope-field perturbations of the two-cylinder covering | 3 | 1 |
| 101 | A sharp entropy bound and the simplex inequality for isotropic constants | 0 | 2 |
| 102 | A Direct Proof of Optimal Max-Cut Hardness | 5 | 1 |
| 102 | Constant-factor hardness of Min-UnCut | 5 | 1 |
| 102 | Constant-factor hardness of directed feedback vertex set | 5 | 1 |
| 102 | The Factor-Two Hardness Threshold for Vertex Cover | 5 | 1 |
| 102 | The Unique Games Theorem | 5 | 1 |
| 103 | Exact Derandomization of Logarithmic Space: L = RL = BPL | 1 | 3 |
| 104 | Deterministic quasipolynomial-time mean-payoff games | 2 | 3 |
| 104 | Mean-payoff parity games in quasipolynomial time | 0 | 2 |
| 104 | Randomized quasipolynomial-time mean-payoff games | 2 | 3 |
| 104 | Turn-Based Stochastic Mean-Payoff Games in Deterministic Quasipolynomial Time | 0 | 2 |
| 105 | Perfect completeness for 2-to-1 games | 1 | 1 |
| 106 | Hardness of finding large independent sets in three-colorable graphs | 1 | 1 |
| 107 | An Upper Bound of 9/4 for the Matrix Multiplication Exponent | 0 | 2 |
| 107 | Complex Matrix Multiplication Below 2.258 and Rectangular Bounds | 2 | 1 |
| 107 | Staggered extraction for exact matrix multiplication over every field | 2 | 1 |
| 108 | A cubic lower bound for border determinantal complexity of the permanent | 2 | 1 |
| 109 | Integer multiplication below n log n | 0 | 2 |
| 110 | Squared-logarithmic randomized k-server on arbitrary metrics | 2 | 1 |
| 110 | Uniform computation of the squared-logarithmic k-server bound | 2 | 1 |
| 111 | One Sample Suffices for Matroid Prophet Inequalities against an Almighty Adversary | 2 | 1 |
| 112 | Beyond the Square-Root Exponent for Depth-Three Boolean Circuits | 1 | 1 |
| 113 | A Fully Polynomial Randomized Approximation Scheme for Perfect Matchings in General Graphs | 6 | 3 |
| 113 | Entropy and Face Dimension of the Perfect-Matching Polytope | 6 | 3 |
| 114 | An FPRAS for Common Integer Polymatroid Bases with Binary Capacities | 0 | 2 |
| 114 | Approximate counting of common bases of two matroids | 1 | 1 |
| 115 | An FPRAS for Cell-Bounded Contingency Tables | 1 | 3 |
| 115 | Exact Uniform Sampling of Contingency Tables with Arbitrary Margins | 1 | 3 |
| 116 | One Rational Matrix Hitting Point for Noncommutative Formulas | 2 | 1 |
| 116 | Polynomial Hitting Lists for Noncommutative Rational Formulas | 2 | 1 |
| 116 | Uniform Matrix Hitting Points in Every Positive Characteristic | 0 | 2 |
| 117 | Constant-factor hardness of uniform sparsest cut | 0 | 2 |
| 117 | Near-square-root logarithmic integrality gaps for uniform sparsest cut | 1 | 1 |
| 118 | Additive hardness and unbounded configuration gaps in bin packing | 1 | 1 |
| 119 | Hellinger contraction with arbitrary Boolean output bias | 0 | 2 |
| 119 | Sharp binary-information contraction on the discrete cube | 2 | 1 |
| 120 | Almost-Linear-Time Maximum-Cardinality Matching in General Graphs | 0 | 2 |
| 121 | An Almost-Linear Approximation Scheme for Edit Distance | 1 | 1 |
| 122 | A latest-anchor induction with spectrally compact masks for worst-case trace reconstruction | 0 | 2 |
| 122 | Quantitative lower bounds for trace reconstruction | 1 | 1 |
| 122 | Uniform quasipolynomial-time trace reconstruction | 0 | 2 |
| 124 | A Polynomial-Time Algorithm for Three-Machine Unit-Job Scheduling | 1 | 1 |
| 125 | Single-exponential recovery and bounded-price strictness for metric k-median | 4 | 1 |
| 125 | The approximation threshold for metric k-median | 4 | 1 |
| 126 | Exponential PSD rank of positively shifted matching matrices | 2 | 1 |
| 127 | Average sensitivity of polynomial threshold functions | 1 | 1 |
| 128 | A Polynomial-Time 2-Approximation for Shortest Common Superstring | 1 | 1 |
| 129 | An exponential state lower bound for two-way nondeterministic complementation | 3 | 1 |
| 129 | An exponential two-way deterministic state lower bound for one-way liveness | 3 | 1 |
| 130 | An explicit power saving for the exact discrete Fourier transform | 2 | 1 |
| 130 | Finite tensor savings and exact Fourier circuits | 2 | 1 |
| 131 | Polynomial mixing of the switch chain for every graphical degree sequence | 1 | 1 |
| 132 | A superquadratic separation between sensitivity and block sensitivity | 1 | 1 |
| 133 | Parity lifts and bounded-treewidth witnesses for Weisfeiler–Leman equivalence | 4 | 1 |
| 133 | The complexity of identifying a graph by Weisfeiler–Leman refinement | 4 | 1 |
| 133 | Unconditional time lower bounds for Weisfeiler–Leman equivalence | 4 | 1 |
| 133 | Variable-dimension Weisfeiler–Leman equivalence on general and subcubic graphs | 4 | 1 |
| 134 | Finite Monoid Computations and a Uniform Generalized Star-Height Bound | 1 | 1 |
| 134 | Generalized Star Height at Most Four | 1 | 1 |
| 134 | Generalized Star Height at Most Three | 1 | 1 |
| 135 | Homogeneous depth-five lower bounds for iterated matrix multiplication | 1 | 1 |
| 136 | The PCP-for-PPAD conjecture: a quasilinear reduction | 0 | 2 |
| 137 | Simulating One-Tape Time in Two-Fifths-Power Space | 1 | 1 |
| 138 | A Low-Space Algorithm for Worst-Case Subset Sum | 0 | 2 |
| 138 | Subset Sum in Time $O(2^{0.49n})$ | 0 | 2 |
| 139 | Subpolynomial query complexity for well-conditioned log-concave sampling | 1 | 1 |
| 140 | Localization costs and information growth for exact Gaussian observations | 8 | 1 |
| 140 | Memory and precision in noiseless Gaussian regression | 8 | 1 |
| 140 | Posterior replicas and conditional information in Gaussian regression | 8 | 1 |
| 140 | Projection moments, positive cap domination, and Riesz estimates on the sphere | 8 | 1 |
| 140 | Replacing Gaussian observations in memory-constrained inference | 8 | 1 |
| 140 | Subsphere methods for memory–sample lower bounds in noiseless Gaussian regression | 8 | 1 |
| 141 | Existential–universal real sentences in the counting hierarchy | 0 | 2 |
| 142 | Deterministic Polynomial Factorization over Prime Fields | 0 | 2 |
| 143 | Two limit cycles for quintic Liénard systems | 1 | 1 |
| 143 | Uniform bounds for planar polynomial limit cycles | 0 | 2 |
| 144 | A smooth three-torus diffeomorphism with simple Lebesgue spectrum | 1 | 1 |
| 145 | Rokhlin's multiple-mixing problem for one transformation | 1 | 1 |
| 146 | Positive Metric Entropy for the Standard Map at Large Parameters | 3 | 1 |
| 147 | Continuous Phase Foliations Create Analytic Caustic Collars | 0 | 2 |
| 147 | Rigidity of Smooth Billiards with a Continuous Caustic Collar | 0 | 2 |
| 148 | The entropy-rate dimension formula for self-similar measures on the line | 2 | 1 |
| 149 | Boundedness and persistence of weakly reversible mass-action systems | 1 | 1 |
| 149 | Uniform Permanence in Weakly Reversible Mass-Action Systems | 0 | 2 |
| 150 | Ergodicity of triangular billiards with an irrational angle | 1 | 1 |
| 150 | Weak mixing of triangular billiards with an irrational angle | 0 | 2 |
| 151 | A C¹ Counterexample to the Entropy Conjecture | 1 | 1 |
| 152 | A zero-entropy system without a smooth positive-volume model | 1 | 1 |
| 153 | Arithmetic classification and non-Pisot singularity for Bernoulli convolutions | 0 | 2 |
| 154 | Pointwise Multiple Ergodic Averages for Mixing Transformations | 0 | 2 |
| 154 | Pointwise convergence of fourfold ergodic averages for mixing transformations | 0 | 2 |
| 154 | Pointwise convergence of triple ergodic averages for mixing transformations | 0 | 2 |
| 154 | Triple ergodic averages with distinct integer slopes | 0 | 2 |
| 155 | A translational tile with no fully periodic tiling in dimension three | 1 | 1 |
| 156 | A nine-dimensional counterexample to Borsuk's covering assertion | 1 | 1 |
| 157 | A counterexample to Hadwiger's conjecture | 2 | 1 |
| 157 | A counterexample to the Colin de Verdière chromatic conjecture | 0 | 2 |
| 157 | A linear list-coloring bound in terms of the Hadwiger number | 2 | 1 |
| 158 | The Euclidean plane is not five-colorable | 2 | 1 |
| 159 | Quasipolynomial Bounds for Arithmetic Progressions | 1 | 7 |
| 160 | Quantitative Superexponential Bounds for van der Waerden Numbers | 1 | 1 |
| 161 | A counterexample to Sidorenko's conjecture | 1 | 1 |
| 162 | A counterexample to Ryser's covering conjecture | 3 | 1 |
| 162 | Balanced counterexamples to Ryser's conjecture at prime orders | 3 | 1 |
| 164 | Monochromatic finite sums and products in the positive integers | 0 | 2 |
| 165 | The crossing number of complete bipartite graphs | 2 | 1 |
| 165 | The crossing number of complete graphs | 2 | 1 |
| 166 | The higher-dimensional Erdős distinct-distances conjecture | 0 | 2 |
| 167 | A power saving for planar unit distances | 2 | 1 |
| 167 | The weak pinned planar distance theorem | 2 | 1 |
| 168 | Combinatorial invariance of Kazhdan–Lusztig polynomials | 1 | 1 |
| 169 | Elementary positivity of chromatic quasisymmetric functions | 1 | 1 |
| 170 | Sharp Logarithmic Exponents for Fixed Off-Diagonal Ramsey Numbers | 2 | 1 |
| 170 | The sharp logarithmic exponent of r(5,t) | 2 | 1 |
| 171 | The hypercube Ramsey number has linear order | 0 | 2 |
| 172 | A classification of finite Euclidean Ramsey configurations | 7 | 1 |
| 173 | A proof of Seymour’s second-neighborhood conjecture | 1 | 1 |
| 174 | A polynomial-time construction of strong thin trees | 2 | 1 |
| 174 | The strong thin tree conjecture | 2 | 1 |
| 175 | Graph Decompositions at the Integral Expectation Threshold | 0 | 2 |
| 175 | Integral and fractional expectation thresholds are equivalent | 2 | 1 |
| 175 | Talagrand's discrete-convexity conjecture | 2 | 1 |
| 176 | The second Kahn–Kalai conjecture | 1 | 1 |
| 177 | Bounded-degree coboundary expanders in every dimension | 1 | 1 |
| 178 | Deterministic nonbipartite Ramanujan graphs in every fixed degree | 0 | 2 |
| 179 | The circulant Hadamard conjecture | 2 | 1 |
| 180 | Paired states and Hamiltonian cycles in cubic bipartite planar graphs | 1 | 1 |
| 181 | A linear cycle-and-edge decomposition of every graph | 1 | 1 |
| 182 | A Power Saving for Polynomial Differences at Prime Arguments | 0 | 2 |
| 182 | A power saving for intersective polynomial differences with an exponent depending only on the degree | 0 | 2 |
| 182 | A power saving for square-difference-free sets | 1 | 3 |
| 183 | A power saving for planar halving lines | 1 | 1 |
| 184 | A logarithmic independence bound for clique-free graphs | 1 | 1 |
| 184 | Correspondence coloring graphs with a forbidden clique | 0 | 2 |
| 185 | A Counterexample to the Infinite Matroid Packing/Covering Conjecture | 2 | 1 |
| 186 | A Sharp Threshold Bound for Monotone Graph Properties | 1 | 1 |
| 186 | A uniform influence bound for hypergraph properties | 0 | 2 |
| 187 | Snaky in 21 Maker moves | 3 | 4 |
| 188 | The sharp terminal leave in random triangle removal | 1 | 1 |
| 189 | Cycle–clique Ramsey numbers | 1 | 4 |
| 190 | Polynomial removal fails for ordered binary matrices | 1 | 1 |
| 191 | A power improvement in the Heilbronn triangle lower bound | 1 | 1 |
| 192 | Unbounded Violations of the Square-Root Degree Bound | 1 | 1 |
| 193 | Positivity of Serre's Intersection Multiplicity | 0 | 2 |
| 194 | Lech's multiplicity conjecture | 1 | 1 |
| 195 | A Complete Local Domain without a Small Cohen-Macaulay Module | 1 | 1 |
| 196 | A Torsion-Free Group Algebra with Zero Divisors | 1 | 1 |
| 197 | A Counterexample to Kaplansky's Direct-Finiteness Conjecture in Characteristic Two | 4 | 3 |
| 197 | A Counterexample to Kaplansky's Direct-Finiteness Conjecture in Odd Characteristic | 4 | 3 |
| 197 | A Counterexample to the Group-Ring Determinant Conjecture | 4 | 3 |
| 197 | A Torsion-Free Group Algebra That Is Not Directly Finite | 0 | 2 |
| 198 | An algebra of infinite little finitistic dimension | 2 | 1 |
| 199 | A counterexample to Tachikawa's second conjecture | 2 | 1 |
| 199 | An explicit counterexample to the Auslander-Reiten conjecture | 2 | 1 |
| 200 | Commuting Division-Coefficient Forms and the Artinian Eisenbud-Green-Harris Conjecture | 0 | 2 |
| 200 | The Artinian Lex-Plus-Powers Betti Theorem | 0 | 2 |
| 201 | A Counterexample to Kurosh’s Division-Ring Problem | 0 | 2 |
| 202 | The Blockwise Alperin Weight Conjecture | 0 | 2 |
| 203 | Donovan's Conjecture over Algebraically Closed Fields | 0 | 2 |
| 203 | Integral Donovan Finiteness over Witt Vectors | 0 | 2 |
| 204 | Tensor saturation for even spin groups | 0 | 2 |
| 205 | A Cyclic Polytabloid Proof of Saxl's Conjecture | 2 | 4 |
| 205 | Universal Tensor Squares for Symmetric Groups | 2 | 4 |
| 206 | A negative solution to the finite lattice representation problem | 0 | 2 |
| 206 | Finite congruence lattices: characterization and undecidability | 1 | 1 |
| 207 | The $\ell^1$-Bass Conjecture for Discrete Groups | 0 | 2 |
| 207 | The Bass trace conjecture and the characteristic-zero Kaplansky idempotent conjecture | 2 | 1 |
| 208 | Fiber functors for finite symmetric tensor categories in positive characteristic | 0 | 2 |
| 209 | An integral counterexample to Gersten's conjecture | 0 | 2 |
| 209 | An integral degree-three Gersten counterexample | 0 | 2 |
| 210 | Foulkes' conjecture for the sixth symmetric power | 0 | 2 |
| 210 | Quadratic stabilization of the canonical Foulkes–Howe map | 1 | 1 |
| 211 | A Linear Clock for Random Walk on Tree-Weighted Planar Maps | 0 | 2 |
| 211 | Brownian continuum random tree limits of finite Fortuin–Kasteleyn maps above four | 1 | 1 |
| 211 | Canonical conformal limits of subcritical FK planar maps | 0 | 2 |
| 211 | Metric-measure limits of subcritical FK and spanning-tree planar maps | 0 | 2 |
| 211 | Random Walks on Critical FK–Ising Maps and Liouville Brownian Motion | 0 | 2 |
| 211 | Spectral convergence for critical FK–Ising planar maps | 0 | 2 |
| 211 | The critical Liouville quantum sphere and geometric limits of FK maps at q=4 | 0 | 2 |
| 212 | No bigeodesics in planar first-passage percolation | 0 | 2 |
| 212 | Strict convexity and differentiability of the planar exponential first-passage limit shape | 2 | 1 |
| 213 | Critical bond and site percolation on the cubic lattice | 2 | 1 |
| 213 | No percolation at criticality on quasi-transitive graphs | 2 | 1 |
| 214 | Nonuniqueness of percolation on nonamenable quasi-transitive graphs | 2 | 1 |
| 215 | An Isolated Particle Pole for the Two-Dimensional O(3) Spin Field | 0 | 2 |
| 215 | Exact mass asymptotics for the two-dimensional O(4) lattice model | 0 | 2 |
| 215 | Exponential decay in two-dimensional classical O(n) models | 1 | 1 |
| 215 | Sharp mass bounds for the two-dimensional O(4) model | 0 | 2 |
| 215 | The canonical massive continuum limit of the two-dimensional O(3) model | 0 | 2 |
| 216 | BKT universality for height and planar spin fields | 0 | 2 |
| 216 | Critical Center Magnetization in the Planar XY Model | 0 | 2 |
| 216 | Essential Singularity of the Correlation Length in the Planar XY Model | 0 | 2 |
| 216 | The Critical Spin Field of the Planar XY Model | 0 | 2 |
| 216 | The critical correlation exponent of the planar XY model | 0 | 2 |
| 216 | The critical logarithmic correction for the planar XY model | 0 | 2 |
| 217 | The low-temperature Sherrington–Kirkpatrick fluctuation scale | 0 | 2 |
| 217 | The low-temperature Sherrington–Kirkpatrick free-energy limiting law | 0 | 2 |
| 218 | $\mathrm{SLE}_3$ universality for weak finite-range Ising interactions | 0 | 2 |
| 218 | Buffered comparison and stopping-band resolution in critical Ising | 1 | 1 |
| 218 | Conformal universality of bulk Ising correlations under weak interactions | 0 | 2 |
| 218 | Logarithmic Relative Fluctuations in the Weakly Disordered Planar Ising Model | 0 | 2 |
| 218 | Quenched SLE₃ Universality for the Weak Random-Bond Ising Model | 0 | 2 |
| 218 | Quenched SLE₃ limits for general weak random-bond Ising models | 0 | 2 |
| 219 | Fixed-energy universality for weak Anderson disorder on random regular graphs | 0 | 2 |
| 219 | GOE bulk universality for fixed-degree random regular graphs | 0 | 2 |
| 220 | A directional zero-one law for finite-range-dependent random environments | 0 | 2 |
| 220 | A directional zero–one law under strict ellipticity | 3 | 1 |
| 220 | Directional transience implies ballisticity | 3 | 1 |
| 221 | The Mézard–Parisi formula for diluted spin glasses | 1 | 1 |
| 222 | Microscopic jamming in the negative spherical perceptron | 0 | 2 |
| 222 | The free energy of the Ising random perceptron | 3 | 1 |
| 222 | The free energy of the spherical random perceptron | 3 | 1 |
| 222 | The spherical perceptron with bi-orthogonally invariant disorder | 0 | 2 |
| 223 | Conformal Limits of Critical Square-Lattice Random-Cluster Interfaces | 0 | 2 |
| 223 | Natural Occupation Measures for Critical Square-Lattice FK Interfaces | 0 | 2 |
| 223 | Quenched SLE Universality for Weakly Disordered FK–Ising Interfaces | 0 | 2 |
| 223 | Self-dual random-cluster interfaces below one | 0 | 2 |
| 223 | Square-lattice FK interfaces and nested loops for 1 ≤ q < 4 | 0 | 2 |
| 223 | Thermal FK–Ising interfaces and massive SLE | 0 | 2 |
| 224 | A Pivotal Amplitude for Voronoi Percolation from Cardy's Formula | 0 | 2 |
| 224 | Cardy’s formula for critical Poisson–Voronoi percolation | 0 | 2 |
| 224 | From critical crossings to quenched near-critical universality in Voronoi percolation | 0 | 2 |
| 225 | The Gaussian free field limit of the balanced six-vertex model with variance multiplier 1/arcsin(c/2) | 0 | 2 |
| 226 | The Curve Scaling Limit of Half-Plane Double Dimers | 0 | 2 |
| 227 | A spectral gap throughout the high-temperature Sherrington–Kirkpatrick phase | 5 | 1 |
| 227 | A typical-start upper bound for low-temperature SK Glauber dynamics | 0 | 2 |
| 227 | Critical mixing in the Sherrington–Kirkpatrick model | 0 | 2 |
| 227 | Critical slowing down in the Sherrington–Kirkpatrick model | 5 | 1 |
| 227 | Cutoff throughout the high-temperature Sherrington–Kirkpatrick phase | 5 | 1 |
| 227 | Functional universality of critical SK autocorrelations | 0 | 2 |
| 227 | Stretched-exponential barriers for typical SK initial states | 5 | 1 |
| 227 | Universality of critical quench autocorrelations in the Sherrington–Kirkpatrick model | 0 | 2 |
| 228 | A continuum temperature singularity for a radial pair potential | 3 | 1 |
| 228 | A radial continuum phase transition with algebraic decay | 3 | 1 |
| 229 | A Capacity Criterion for Four-State Potts Reconstruction on Trees | 0 | 2 |
| 229 | The Reconstruction Threshold for the Ferromagnetic Four-State Potts Model | 0 | 2 |
| 229 | The exact reconstruction threshold for the three-state symmetric channel | 2 | 1 |
| 230 | An exact Hausdorff gauge for SLE: A moment-integral and finite-batch construction | 1 | 1 |
| 230 | An explicit exact Hausdorff gauge for SLE: A regular formula from quantitative tails and dense visits | 1 | 1 |
| 231 | The free uniform spanning forest is a factor of IID | 2 | 1 |
| 232 | Gaussian free-field limits of weighted integer Lipschitz heights | 0 | 2 |
| 232 | The Gaussian free field limit of integer Lipschitz heights with two-arc boundary data | 0 | 2 |
| 232 | Uniform real Lipschitz surfaces on the triangular lattice | 0 | 2 |
| 233 | The joint scaling limit of critical Ashkin–Teller currents | 0 | 2 |
| 234 | All-temperature pressure for orthogonally invariant Ising spin glasses | 1 | 1 |
| 235 | A Limiting Satisfiability Threshold for Every Fixed Clause Size | 4 | 1 |
| 235 | Computing the Random 3-SAT Threshold | 4 | 1 |
| 235 | Linear Variance of the Random 3-SAT Hitting Time | 0 | 2 |
| 235 | Variance of the Random k-SAT Hitting Time | 4 | 1 |
| 236 | The sharp factor-of-IID threshold for the free Ising model on regular trees | 1 | 1 |
| 237 | Cap-selected amplitudes and triangle chords for honeycomb walks | 0 | 2 |
| 237 | Critical honeycomb chords with prescribed boundary endpoints | 4 | 4 |
| 237 | Critical strip-crossing mass on the honeycomb lattice | 4 | 4 |
| 237 | Cylinder amplitudes and logarithmic bridge-length windows on the honeycomb lattice | 0 | 2 |
| 237 | Cylinder loop weights and planar nesting | 0 | 2 |
| 237 | Disk transfer representations and confined bridge mass | 0 | 2 |
| 237 | Marked polygon correlations and one-arc bounds | 0 | 2 |
| 237 | Mass and covering exponents for fixed-length honeycomb walks | 0 | 2 |
| 237 | Polynomial vacuum representations and bridge mass for honeycomb walks | 4 | 4 |
| 237 | Radial transfer estimates and polygon length laws for honeycomb walks | 0 | 2 |
| 237 | Renewal and changes of law for critical honeycomb walks | 4 | 4 |
| 237 | Signed cylinder propagation and marked polygons on the honeycomb lattice | 0 | 2 |
| 237 | Uniform marked-polygon estimates and sharp finite bridge moments | 0 | 2 |
| 238 | A strict four-row permanent inequality and permutation moments | 13 | 1 |
| 238 | Compatibility entropy and the spectrum of a Thorp sweep | 13 | 1 |
| 238 | Conditional coordinate sweeps and analytic transfer | 13 | 1 |
| 238 | Conditional information under deterministic coordinate sweeps | 0 | 2 |
| 238 | Conditional permutations in a revealed switching environment | 13 | 1 |
| 238 | From partial permutation information to Fourier bounds | 13 | 1 |
| 238 | Optimal-order mixing of the Thorp shuffle | 13 | 1 |
| 238 | Random coordinate frames and partial permutation laws | 0 | 2 |
| 238 | Random-subspace tests and trace smoothing for coordinate sweeps | 13 | 1 |
| 238 | Routing densities and representation contraction for Thorp sweeps | 13 | 1 |
| 238 | Row–column symmetry and contraction of coordinate sweeps | 13 | 1 |
| 238 | Signed tensor densities and diagram budgets for the Thorp shuffle | 13 | 1 |
| 239 | The sharp exponential rate of singularity for symmetric Bernoulli matrices | 0 | 2 |
| 239 | The sharp singularity rate for biased symmetric sign matrices | 0 | 2 |
| 240 | A CH obstruction to a prescribed categoricity threshold | 1 | 1 |
| 240 | Eventual categoricity for abstract elementary classes | 0 | 2 |
| 241 | Rigidity of the Turing degrees | 1 | 1 |
| 242 | Single-fold Diophantine representations | 1 | 1 |
| 243 | Choiceless polynomial time with counting does not capture polynomial time | 2 | 1 |
| 243 | Witnessed symmetric choice is strictly stronger than choiceless polynomial time with counting | 2 | 1 |
| 244 | The Partition Principle does not imply Choice | 2 | 1 |
| 245 | Weak and strong normalization in pure type systems | 1 | 1 |
| 246 | A Modulus Proof of Cannon’s Conjecture | 1 | 1 |
| 247 | An infinite finitely presented periodic group | 1 | 3 |
| 247 | An infinite finitely presented residually finite 2-group | 0 | 2 |
| 248 | Thompson's group F is nonamenable | 1 | 1 |
| 249 | A finitely generated counterexample to the Eilenberg–Ganea conjecture | 1 | 1 |
| 250 | A universal group of type F∞ | 3 | 1 |
| 250 | Finite algebraic envelopes and the Boone–Higman conjecture | 3 | 1 |
| 250 | Simple F∞ overgroups of groups with decidable word problem | 3 | 1 |
| 251 | Strong Ulam Stability Characterizes Amenability | 0 | 2 |
| 251 | Unitarizability implies amenability for discrete groups | 2 | 1 |
| 252 | A torsion-free hyperbolic group that is not residually finite | 1 | 1 |
| 253 | An infinite finitely presented simple amenable group | 1 | 1 |
| 254 | An Artin group with no geometric CAT(0) action | 3 | 1 |
| 254 | Harmonic heights and the Artin K(π,1) conjecture | 3 | 1 |
| 254 | Parabolic Intersections in Artin Groups | 3 | 1 |
| 255 | Quasi-isometric Recognition of Virtually Polycyclic Groups | 1 | 1 |
| 256 | Nonsingular systems of equations over arbitrary groups | 0 | 2 |
| 256 | The Kervaire theorem for groups | 1 | 1 |
| 257 | A hyperbolic group with no geometric CAT(0) action | 1 | 1 |
| 258 | Baumslag–Solitar-free one-relator groups are hyperbolic | 0 | 2 |
| 258 | Virtual compact specialness of hyperbolic one-relator groups | 0 | 2 |
| 259 | A group without fixed price | 0 | 2 |
| 260 | A Charged Reduction of the Spacetime Penrose Inequality in Spatial Dimensions at Least Four | 0 | 2 |
| 260 | A local Penrose inequality for conformal perturbations of Schwarzschild–anti-de Sitter data | 0 | 2 |
| 260 | Area-controlled end replacement and the Bondi–Penrose inequality in the CKS class | 1 | 1 |
| 260 | Boundary graph deformations for the spacetime Penrose inequality | 0 | 2 |
| 260 | Conformal flow and the Riemannian Penrose inequality with minimizing frontiers | 0 | 2 |
| 260 | Electromagnetic tails and the Kerr–Newman Penrose inequality | 0 | 2 |
| 260 | Equality and rigidity in the spacetime Penrose inequality | 0 | 2 |
| 260 | Spacetime Penrose inequalities: enclosing area, charge, and rigidity | 0 | 2 |
| 260 | The Kerr–Newman Penrose Inequality for Axisymmetric Electrovacuum Exteriors | 0 | 2 |
| 260 | The Penrose inequality for maximal asymptotically hyperbolic initial data | 0 | 2 |
| 260 | The nonmaximal anti-de Sitter Penrose Inequality and original-data rigidity | 0 | 2 |
| 260 | The spacetime Penrose inequality and enclosing area | 0 | 2 |
| 260 | The spacetime Penrose inequality with charge and original-data rigidity | 0 | 2 |
| 261 | Absolutely Continuous Spectrum for Weak-Disorder Anderson Models in Dimensions at Least Three | 0 | 2 |
| 261 | Pure-Point Spectrum for the Two-Dimensional Anderson Model at Every Positive Disorder | 1 | 1 |
| 262 | Equality cases in the sharp one-dimensional matrix Lieb–Thirring inequality | 0 | 2 |
| 262 | Sharp one-dimensional Lieb–Thirring constants | 1 | 1 |
| 262 | Sharp one-dimensional Lieb–Thirring inequalities for matrix potentials | 0 | 2 |
| 263 | Generalized ionization energies for full Coulomb atoms | 2 | 1 |
| 263 | Generalized outer-electron radii of neutral Coulomb atoms | 2 | 1 |
| 263 | Uniform excess charge for Coulomb molecules and the outer radius of neutral atoms | 0 | 2 |
| 264 | Generic C¹ Future Inextendibility Near Rotating Subextremal Kerr Spacetimes | 0 | 2 |
| 264 | Generic Future Inextendibility with Square-Integrable Connection Near a Fixed Kerr Spacetime | 0 | 2 |
| 264 | Quantitative Near-Kerr Evolution and Generic C² Future Inextendibility | 0 | 2 |
| 265 | A two-dimensional area law from a global spectral gap | 0 | 2 |
| 265 | Polynomial PEPS approximation of gapped square-grid ground states | 0 | 2 |
| 266 | Exact Fourier certificates for complex Hadamard matrices of order six | 2 | 7 |
| 266 | The maximum number of mutually unbiased bases in dimension six | 2 | 7 |
| 267 | A density-uniform condensate bound for dilute Bose gases | 0 | 2 |
| 267 | Bose–Einstein condensation at positive temperature in the dilute hard-sphere gas | 0 | 2 |
| 267 | Ground-state condensation in the dilute hard-sphere gas | 1 | 1 |
| 267 | Quantum Depletion and Momentum Distribution in the Dilute Hard-Sphere Bose Gas | 0 | 2 |
| 267 | Quantum Depletion for Fixed Bounded Repulsive Potentials | 0 | 2 |
| 268 | A boundary-field gap for the spin-one Heisenberg chain | 0 | 2 |
| 268 | The periodic spin-one Haldane gap | 0 | 2 |
| 269 | A Fock-space inequality and the Laughlin spectral gap | 4 | 1 |
| 269 | Uniform Stability of the Spherical Laughlin Gap | 4 | 1 |
| 270 | Positive eigenvalues of the relative SU(2) BFSS Hamiltonian | 0 | 2 |
| 270 | The unique threshold bound state of the SU(N) BFSS model | 0 | 2 |
| 271 | Bloch's Law for Finite-Range Heisenberg Ferromagnets in Three Dimensions | 0 | 2 |
| 271 | Spontaneous magnetization in the quantum Heisenberg ferromagnet | 1 | 1 |
| 271 | The first lattice correction to Bloch's law | 0 | 2 |
| 271 | The spherical magnetization law for the three-dimensional quantum Heisenberg ferromagnet | 0 | 2 |
| 272 | Entanglement with zero distillable secret key in local dimension ten | 2 | 1 |
| 273 | The entropy photon-number inequality | 1 | 1 |
| 274 | Product-projection localization and the QAC⁰ parity lower bound | 2 | 1 |
| 274 | Regular trajectories, pruning and quantum parity | 2 | 1 |
| 275 | Continuum Coulomb hardness with binary nuclear charges | 1 | 4 |
| 275 | QMA-hardness of continuum Coulomb energy with unit nuclear charges | 1 | 4 |
| 276 | Classical capacity and entropy inequalities for generalized amplitude damping | 1 | 1 |
| 277 | Threshold parallel repetition for finite-dimensional entangled games | 1 | 1 |
| 278 | A Coulomb ground-state density without Kohn–Sham ensemble representation | 0 | 2 |
| 279 | Exact quantum factoring over a fixed finite gate set | 1 | 1 |
| 280 | Strongly rational unitary vertex operator algebras and conformal nets | 1 | 1 |
| 281 | Full support of the zero-temperature Sherrington–Kirkpatrick order parameter | 2 | 1 |
| 281 | QAOA attains the SK ground-state energy in the thermodynamic-first limit | 2 | 1 |
| 282 | Scale and conformal symmetry in four-dimensional operational quantum field theory | 0 | 2 |
| 283 | Polynomial-Time Unitary Synthesis from a Boolean Oracle | 0 | 2 |
| 284 | A Nearly Quartic Separation Between Randomized and Quantum Query Complexity | 0 | 2 |
| 285 | A torsion-free counterexample to reduced Baum–Connes injectivity | 0 | 2 |
| 285 | A torsion-free counterexample to the Kadison–Kaplansky projection conjecture | 0 | 2 |
| 285 | An irrational-trace counterexample to reduced Baum–Connes | 0 | 2 |
| 286 | Arithmeticity of twisted finite correspondences for lattices over local fields | 0 | 2 |
| 286 | The arithmetic category and stable recovery of lattice factors | 0 | 2 |
| 287 | An isomorphism of the free group factors | 1 | 1 |
| 288 | Kadison's similarity theorem through uniform derivation estimates | 2 | 1 |
| 289 | Close Separable C*-Algebras Without Spatial Conjugacy | 0 | 2 |
| 289 | Near Inclusions of von Neumann Algebras Without Small Spatial Embeddings | 0 | 2 |
| 289 | Universal strong Kadison–Kastler stability | 1 | 1 |
| 290 | Bounded recovery for modular spectral averages | 1 | 1 |
| 290 | Expected amenable subalgebras preserving core commutants | 0 | 2 |
| 291 | Cuntz comparison and Jiang–Su absorption | 0 | 2 |
| 291 | Equivariant Jiang–Su Stability for Amenable Actions in the Unital Stably Finite Case | 0 | 2 |
| 291 | Nuclear dimension and Jiang–Su stability without elementary subquotients | 0 | 2 |
| 291 | Tracial projection methods and uniform property Γ | 1 | 1 |
| 292 | An explicit obstruction to nuclear norm-ultrapower embeddings | 1 | 4 |
| 293 | Backward intertwiners and a transitive commutant | 6 | 1 |
| 293 | Invariant-projection counterexamples for every irrational rotation | 6 | 1 |
| 294 | A counterexample to Kaplansky's quasitrace conjecture and failure of tensor-product stable finiteness | 2 | 1 |
| 295 | Vanishing of higher bounded Hochschild cohomology | 1 | 1 |
| 296 | Relative generation and the generator problem for finite factors | 2 | 1 |
| 297 | A counterexample to Naimark's problem in ZFC | 1 | 1 |
| 298 | A finite-entropy separation of microstates and nonmicrostates free entropy | 1 | 1 |
| 299 | The Kirchberg–Rørdam character criterion | 1 | 1 |
| 300 | Approximation Paving over Arbitrary Maximal Abelian Subalgebras | 0 | 2 |
| 300 | Quadratic Strong-Operator Paving over Arbitrary Maximal Abelian Subalgebras | 0 | 2 |
| 301 | The trace cone classifies Razak–Jacelon stabilizations | 1 | 1 |
| 302 | Filtered products and boundary-preserving compression in complex cobordism | 0 | 2 |
| 302 | Radius of comparison equals half the mean dimension | 0 | 2 |
| 303 | Weak pure infiniteness and O-infinity absorption | 2 | 1 |
| 304 | The Hilbert–Smith conjecture in every finite dimension | 0 | 2 |
| 305 | A PD4 group without an aspherical manifold model | 0 | 2 |
| 305 | A boundary-only obstruction to four-dimensional disk embedding | 0 | 2 |
| 305 | A marked tensor obstruction to four-dimensional disk embedding | 0 | 2 |
| 306 | Purely cosmetic surgery on knots in the three-sphere | 0 | 2 |
| 307 | A counterexample to the coarse Novikov conjecture | 1 | 4 |
| 307 | Failure of rational injectivity for maximal coarse assembly | 0 | 2 |
| 308 | A finite Smith–Toda complex V(4) at the prime 1009 | 0 | 2 |
| 308 | Finite Smith–Toda Complexes at Varying Primes | 0 | 2 |
| 309 | The Kervaire invariant problem at the prime three | 0 | 2 |
| 310 | Rational homology and Quillen's conjecture | 0 | 2 |
| 311 | Stabilizer orbits and thick tensor ideals of dualizable K(n)-local spectra | 0 | 2 |
| 312 | The Grothendieck homotopy hypothesis via elementary expansions | 1 | 1 |
| 313 | Finite generation for the K(n)-local sphere | 0 | 2 |
| 314 | Cyclic length and chromatic fixed-point loss | 0 | 2 |
| 315 | The Singer conjecture in dimension four | 0 | 2 |
| 316 | The Stable Hurewicz Image of the Sphere at Two | 0 | 2 |
| 317 | Thomason Model Structures in Every Strict Higher Dimension | 1 | 1 |
| 318 | A rational obstruction to strong chromatic splitting at height three | 0 | 2 |
| 318 | Counterexamples to weak chromatic splitting: sphere kernels and descent exponents | 0 | 2 |
| 318 | Failure of finite assembly for a chromatic overlap at the prime three | 0 | 2 |
| 318 | Filtered chromatic splitting at generic primes | 0 | 2 |
| 318 | The height-three chromatic overlap: an explicit filtration and its attachments | 0 | 2 |
| 319 | Counterexamples to the Hahn-Wilson conjecture at height two | 0 | 2 |
| 320 | Nonhomeomorphic closed aspherical four-manifolds with the same homotopy type | 0 | 2 |
| 321 | A Counterexample to Wall's D(2) Problem | 0 | 2 |
| 322 | A positive solution to Tingley's problem | 1 | 1 |
| 323 | Relative independence of the separable quotient problem | 1 | 1 |
| 324 | Bi-Lipschitz Absorption of $c_0$ Without a Linear Copy of $c_0$ | 2 | 1 |
| 324 | Lipschitz Equivalent Separable Banach Spaces Need Not Be Linearly Isomorphic | 2 | 1 |
| 325 | A direct proof of the complete Crouzeix inequality | 5 | 1 |
| 325 | The complete Crouzeix theorem: optimal similarity and a common positive boundary representation | 5 | 1 |
| 326 | The cotype–cotype conjecture under the approximation property | 1 | 1 |
| 327 | Nontrivial Markov Type Forces Superreflexivity | 1 | 1 |
| 328 | Fixed Points of Nonexpansive Maps in Reflexive Banach Spaces | 1 | 1 |
| 329 | Counterexamples to the duality conjecture for metric entropy | 1 | 1 |
| 330 | A uniformly discrete counterexample to bounded approximation in Lipschitz-free spaces | 2 | 1 |
| 331 | Asymptotic midpoint uniform convexity and unbounded diamond distortion in a reflexive tree space | 7 | 1 |
| 331 | Distortion of countably branching diamonds from midpoint and tree energies | 7 | 1 |
| 331 | Exact asymptotic moduli in a Daugavet subspace of L1 | 7 | 1 |
| 331 | Independent products in real L1: asymptotic midpoint convexity without AUC renormings | 7 | 1 |
| 331 | Midpoint convexity from bounded tree potentials and path costs | 7 | 1 |
| 331 | Midpoint convexity from two recursive potentials | 7 | 1 |
| 331 | Midpoint lenses in segment spaces | 7 | 1 |
| 332 | Metric Markov Cotype Two of $\ell_1$ | 0 | 2 |
| 333 | Smooth isometric immersions of closed surfaces into Euclidean four-space | 1 | 1 |
| 334 | A Smooth Metric with No Local Isometric Immersion into Three-Space | 1 | 1 |
| 335 | An integral scalar curvature bound for real simplicial volume | 0 | 2 |
| 335 | Positive scalar curvature forces rational inessentiality | 0 | 2 |
| 336 | Positive scalar curvature and uniform codimension-two width | 0 | 2 |
| 336 | Spectral scalar curvature and Urysohn width in dimension three | 0 | 2 |
| 336 | Spectral scalar curvature and uniform Urysohn width | 0 | 2 |
| 337 | Generalized Cartan–Hadamard isoperimetry and Euclidean equality rigidity | 0 | 2 |
| 337 | Sharp integral fillings in CAT(0) spaces | 2 | 1 |
| 338 | Uniformization of complete Kähler manifolds with positive bisectional curvature | 0 | 2 |
| 339 | Entropy equality and local symmetry in negative curvature | 0 | 2 |
| 340 | A counterexample to the nearby Lagrangian conjecture | 0 | 2 |
| 341 | Deforming hypersymplectic four-manifolds to hyperkähler triples | 0 | 2 |
| 342 | Taming implies compatibility on four-manifolds | 1 | 4 |
| 343 | Symplectic Ball Packings in Higher Dimensions | 2 | 1 |
| 344 | The metric Blaschke theorem | 0 | 2 |
| 345 | Infinitely many closed geodesic images on every Riemannian sphere | 0 | 2 |
| 346 | A Codimension-One Bound for the Singular Set of a Stationary Integral Varifold | 0 | 2 |
| 346 | Almost-everywhere regularity of stationary integral varifolds | 0 | 2 |
| 347 | A nondegenerate counterexample to the Morse-number Arnold bound | 0 | 2 |
| 347 | Hamiltonian Fixed Points Below the Stable Morse Number | 0 | 2 |
| 347 | Hamiltonian Fixed Points Below the Stable Morse Number in Dimension Twenty-Two | 0 | 2 |
| 347 | Sharpness of the Cyclic Integral Floer Bound Below the Stable Morse Number | 0 | 2 |
| 347 | Three fixed points on the symplectic quadric threefold | 1 | 1 |
| 348 | An $L^2$ Einstein Gap for Nonnegatively Curved Four-Manifolds | 0 | 2 |
| 348 | Positively curved Einstein four-manifolds | 1 | 1 |
| 348 | Zero-Plane Rigidity for Einstein Four-Manifolds | 0 | 2 |
| 349 | The Solomon–Yau least-volume theorem | 0 | 2 |
| 350 | Power-law violations of Yau's nodal upper bound | 3 | 1 |
| 350 | Sharp nodal length on smooth surfaces | 3 | 1 |
| 350 | Smooth counterexamples to Yau's nodal upper bound in dimensions three and four | 3 | 1 |
| 351 | A closed Ricci flow with bounded scalar curvature and finite-time curvature blowup | 0 | 2 |
| 351 | Bounded scalar curvature and smooth extension of four-dimensional Ricci flow | 0 | 2 |
| 351 | Path selection and an elliptic inequality on degenerating Ricci-flat trees | 0 | 2 |
| 352 | A finite-time singularity of Calabi flow on projective space | 0 | 2 |
| 353 | A Smooth Nonquadratic Entire Affine Maximal Graph in Dimension Ten | 0 | 2 |
| 353 | The affine Bernstein theorem in dimensions three through nine | 1 | 1 |
| 354 | The Isoperimetric Conjecture for the Cubic Flat Three-Torus | 1 | 1 |
| 355 | Uniqueness of tangent flows at the first singular time of embedded surface mean-curvature flow | 0 | 2 |
| 356 | Gigli's distributional curvature characterization of Alexandrov spaces | 0 | 2 |
| 356 | Weak Hessian bounds along every geodesic in RCD spaces | 1 | 1 |
| 357 | Bi-Lipschitz Coordinates at Regular Points of Noncollapsed RCD Spaces | 0 | 2 |
| 358 | A Three-Manifold Without Conjugate Points and Without a Nonpositively Curved Metric | 1 | 1 |
| 359 | A negatively pinched Kähler threefold without bounded holomorphic coordinates | 1 | 1 |
| 359 | One-sided negative sectional curvature and the holomorphic Liouville property | 0 | 2 |
| 360 | Global Support and Convex Injectivity Domains under Weak MTW | 2 | 1 |
| 360 | Uniform Bi-Hölder Transport from Weak MTW | 2 | 1 |
| 361 | A Three-Dimensional Counterexample to Integer-Degree Harmonic Dimension Comparison | 0 | 2 |
| 361 | A counterexample to integer-degree harmonic dimension comparison | 1 | 1 |
| 362 | Global classical solutions of the three-dimensional relativistic Vlasov–Maxwell system | 1 | 1 |
| 363 | Nonuniqueness for the periodic hard-sphere Boltzmann equation | 1 | 1 |
| 363 | Nonuniqueness with local conservation for the hard-sphere Boltzmann equation | 0 | 2 |
| 364 | Hard-sphere fluctuations on the regular Boltzmann lifespan | 0 | 2 |
| 364 | The Boltzmann–Grad limit for stable radial potentials on regular kinetic intervals | 0 | 2 |
| 365 | Determination of a metric and a unitary connection from one boundary patch | 0 | 2 |
| 365 | Nonuniqueness for Bounded Measurable Scalar Conductivities in Three Dimensions | 1 | 1 |
| 365 | Smooth anisotropic uniqueness in the Calderón problem from one boundary patch | 0 | 2 |
| 366 | Interior regularity of planar Mumford–Shah minimizers | 0 | 2 |
| 367 | The critical dimension for one-phase Bernoulli minimizers | 1 | 1 |
| 368 | Strong diffeomorphic approximation in three dimensions for 1≤p≤2 | 0 | 2 |
| 368 | Strong diffeomorphic approximation in three dimensions for p>2 | 0 | 2 |
| 369 | Strict hot spots and absence of interior critical points on smooth simply connected planar domains | 1 | 1 |
| 370 | The Subcritical Hénon–Lane–Emden Conjecture | 1 | 1 |
| 371 | Stable self-similar blowup for a supercritical defocusing Schrödinger equation on the torus | 1 | 1 |
| 372 | Global Uniqueness for the Smooth Isotropic Elasticity Inverse Problem | 1 | 1 |
| 373 | A counterexample to the Monge ansatz for the three-marginal Coulomb cost | 1 | 1 |
| 374 | Sharp One-Third Stability of Brenier Maps | 1 | 1 |
| 375 | A positive resolution of De Giorgi's conjecture in dimension eight | 0 | 2 |
| 376 | A Fixed Particle Test for Computation in a Forced Viscous Flow | 0 | 2 |
| 376 | Computation under Rapidly Vanishing Navier–Stokes Forcing | 6 | 1 |
| 376 | Finite Instructions and Solenoidal Shear Flows | 0 | 2 |
| 376 | Geometric Programs for Solenoidal Forcing | 6 | 1 |
| 376 | Incompressible Box Transport and Finite Computation | 6 | 1 |
| 376 | Prefix Instructions and Incompressible Flows | 0 | 2 |
| 376 | Scalar Potentials and Slow Clocks for Forced Fluid Computation | 0 | 2 |
| 376 | Universal Computation with Eventually Stationary Navier–Stokes Forcing | 0 | 2 |
| 376 | Velocity-Field Detection of Computation in Forced Navier–Stokes Flows | 6 | 1 |
| 377 | Uniform Interior $C^{1,\alpha}$ Estimates for Infinity-Harmonic Functions | 0 | 2 |
| 378 | The Exponential Time Hypothesis is False | 1 | 4 |

## Not graded

27 folders under `preprints/` are earlier versions of listed manuscripts: the same title, with an earlier date. They aren't graded.

| Earlier version | Listed as |
| --- | --- |
| A-pointwise-2-converse-for-elliptic-curves-with-rational-two-torsion-September-24-2026 | A-pointwise-2-converse-for-elliptic-curves-with-rational-two-torsion-October-7-2026 |
| Abelian-covers-Gale-correspondences-and-the-Hodge-conjecture-for-powers-September-30-2026 | Abelian-covers-Gale-correspondences-and-the-Hodge-conjecture-for-powers-October-6-2026 |
| Conditional-good-minimal-models-for-compact-Kahler-fourfolds-October-5-2026 | Conditional-good-minimal-models-for-compact-Kahler-fourfolds-October-6-2026 |
| Deforming-hypersymplectic-four-manifolds-to-hyperkahler-triples-September-23-2026 | Deforming-hypersymplectic-four-manifolds-to-hyperkahler-triples-October-7-2026 |
| Exact-Birch-Swinnerton-Dyer-Formula-from-Low-Selmer-Corank-October-3-2026 | Exact-Birch-Swinnerton-Dyer-Formula-from-Low-Selmer-Corank-October-7-2026 |
| Finite-ordinary-minimal-model-programs-on-compact-Kahler-fourfolds-October-5-2026 | Finite-ordinary-minimal-model-programs-on-compact-Kahler-fourfolds-October-6-2026, Finite-ordinary-minimal-model-programs-on-compact-Kahler-fourfolds-September-24-2026 |
| Fontaine-Mazur-modularity-at-the-prime-2-September-23-2026 | Fontaine-Mazur-modularity-at-the-prime-2-October-6-2026 |
| Gaussian-free-field-limits-of-weighted-integer-Lipschitz-heights-September-25-2026 | Gaussian-free-field-limits-of-weighted-integer-Lipschitz-heights-October-6-2026 |
| Goldfelds-analytic-density-conjecture-and-the-2-converse-for-elliptic-curves-September-23-2026 | Goldfelds-analytic-density-conjecture-and-the-2-converse-for-elliptic-curves-October-7-2026 |
| Hilberts-tenth-problem-over-the-rational-numbers-September-24-2026 | Hilberts-tenth-problem-over-the-rational-numbers-October-6-2026 |
| Incompressible-Box-Transport-and-Finite-Computation-September-27-2026 | Incompressible-Box-Transport-and-Finite-Computation-October-6-2026 |
| Log-abundance-for-compact-Kahler-spaces-under-logarithmic-Iitaka-subadditivity-October-4-2026 | Log-abundance-for-compact-Kahler-spaces-under-logarithmic-Iitaka-subadditivity-October-6-2026 |
| Milnes-rationality-conjecture-for-abelian-varieties-September-23-2026 | Milnes-rationality-conjecture-for-abelian-varieties-October-7-2026 |
| Numerical-semiampleness-of-nef-adjoint-classes-on-compact-Kahler-manifolds-October-4-2026 | Numerical-semiampleness-of-nef-adjoint-classes-on-compact-Kahler-manifolds-October-6-2026 |
| Taming-implies-compatibility-on-four-manifolds-September-23-2026 | Taming-implies-compatibility-on-four-manifolds-October-6-2026 |
| Termination-of-generalized-canonical-flips-on-compact-Kahler-fourfolds-October-5-2026 | Termination-of-generalized-canonical-flips-on-compact-Kahler-fourfolds-October-6-2026 |
| Termination-of-generalized-log-canonical-flips-on-compact-Kahler-fourfolds-October-5-2026 | Termination-of-generalized-log-canonical-flips-on-compact-Kahler-fourfolds-October-7-2026 |
| The-Gaussian-free-field-limit-of-integer-Lipschitz-heights-with-two-arc-boundary-data-September-25-2026 | The-Gaussian-free-field-limit-of-integer-Lipschitz-heights-with-two-arc-boundary-data-October-6-2026 |
| The-Selmer-converse-for-elliptic-curves-at-every-prime-September-24-2026 | The-Selmer-converse-for-elliptic-curves-at-every-prime-October-7-2026 |
| The-joint-scaling-limit-of-critical-Ashkin-Teller-currents-September-25-2026 | The-joint-scaling-limit-of-critical-Ashkin-Teller-currents-October-6-2026 |
| The-mean-analytic-rank-of-quadratic-twists-of-elliptic-curves-September-23-2026 | The-mean-analytic-rank-of-quadratic-twists-of-elliptic-curves-October-6-2026 |
| The-p-adic-section-conjecture-September-24-2026 | The-p-adic-section-conjecture-October-6-2026 |
| The-rational-Hodge-conjecture-for-CM-abelian-varieties-September-30-2026 | The-rational-Hodge-conjecture-for-CM-abelian-varieties-October-6-2026 |
| The-two-primary-Birch-Swinnerton-Dyer-formula-in-Selmer-corank-at-most-one-September-24-2026 | The-two-primary-Birch-Swinnerton-Dyer-formula-in-Selmer-corank-at-most-one-October-6-2026 |
| Uniform-real-Lipschitz-surfaces-on-the-triangular-lattice-September-25-2026 | Uniform-real-Lipschitz-surfaces-on-the-triangular-lattice-October-6-2026 |
| Unrestricted-pro-modularity-at-the-prime-two-October-4-2026 | Unrestricted-pro-modularity-at-the-prime-two-October-6-2026 |
| Weil-classes-and-Hodge-classes-on-abelian-powers-September-30-2026 | Weil-classes-and-Hodge-classes-on-abelian-powers-October-6-2026 |

## Notes

- `Incompressible-Box-Transport-and-Finite-Computation-October-6-2026`: its family's docs page links `Incompressible-Box-Transport-and-Finite-Computation-September-27-2026`, an earlier version with the same title, so the page's challenges count for the listed one. A named reviewer still has to check their statements against it.
- `Taming-implies-compatibility-on-four-manifolds-October-6-2026`: its family's docs page links `Taming-implies-compatibility-on-four-manifolds-September-23-2026`, an earlier version with the same title, so the page's challenges count for the listed one. A named reviewer still has to check their statements against it.
