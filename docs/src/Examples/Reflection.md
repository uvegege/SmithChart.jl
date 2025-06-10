# Plot Reflection Coefficients

The functions `smithplot` and `smithscatter` allow plotting normalized impedance and reflection coefficient data on a Smith chart.

By default, the keyword argument reflection is set to `false`, meaning that the input is interpreted as normalized impedance.
To plot reflection coefficient data instead (e.g., S-parameters), set `reflection = true`.

This is particularly useful when visualizing results from simulations or measurements in terms of scattering parameters (S-parameters).

```@example
using CairoMakie
using SmithChart
CairoMakie.activate!() #hide
zi = 3.8 - 1.9im
function simline(z, l)
    bl = 2 * pi * l 
    return (z + im * tan(bl)) / (1 + im * z * tan(bl))
end
l = range(0.0, 0.22, 101) 
z = simline.(zi, l)
fig = Figure(size = (900,600))
ax = SmithAxis(fig[1,1])
smithplot!(ax, z, label = "Impedance")
# Convert impedance z to reflection
Γ = @. (z-1)/(z+1)
# Plot with `reflection = true`
smithscatter!(ax, Γ[1:5:end], reflection = true, markersize = 11, color = :orange, marker = :cross, label = "Reflection\nreflection = true")
fig[1,2] = Legend(fig, ax)
fig
```