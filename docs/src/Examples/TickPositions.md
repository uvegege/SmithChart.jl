# Change tick positions

You can customize the position of the ticks on the Smith chart using the `xvals` and `rvals` keywords. These control the placement of the reactance arcs (`xvals`) and resistance circles (`rvals`) respectively. 

```@example
using CairoMakie
using SmithChart

f = Figure()
sc = SmithAxis(f[1,1], xvals = [0.1, 0.3, 0.7, 1.0, 2.0, 4.0, 10.0], rvals = [0.2, 0.4, 0.6, 1.0, 2.5, 7.0, 15.0])
f
```