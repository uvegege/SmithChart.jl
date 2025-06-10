# Chart type and grid colors

Change type and control color of the grid or subgrid. The keywords `zgridcolor` and `ygridcolor` allow controlling both axes with a single keyword. Each of them takes precedence over their respective individual grid color settings (`rgridcolor` and `xgridcolor` for the Z-axis, and `bgridcolor` and `ggridcolor` for the Y-axis).

```@example
using SmithChart
using CairoMakie
CairoMakie.activate!() #hide
f = Figure(size = (1200, 800))
sc1 = SmithAxis(f[1,1], type = :Z, subtitle = "type :Z (default)")
sc2 = SmithAxis(f[1,2], type = :Y, subtitle = "type :Y")
sc3 = SmithAxis(f[1,3], type = :ZY, subtitle = "type :ZY", gtickvisible = false, btickvisible = false)
sc4 = SmithAxis(f[2,1], type = :Z, subtitle = "rgridcolor = :red, xgridcolor = :green", rgridcolor = :red, xgridcolor = :green)
sc5 = SmithAxis(f[2,2], type = :Y, subtitle = "ygridcolor = :blue", ygridcolor = :blue)
sc6 = SmithAxis(f[2,3], type = :ZY, subtitle = "zgridcolor = :orange, ygridcolor = :green", zgridcolor = :orange, ygridcolor = :green, gtickvisible = false, btickvisible = false)
f
```

