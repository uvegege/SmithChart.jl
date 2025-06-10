# Visual Details

## Tick options

There are multiple keywords related to the position and visual details of the ticks. Two of the main ones are `tickbox` and `tickalign`. 

```@example
using SmithChart
using CairoMakie

f = Figure(size = (1000, 750))
sc = SmithAxis(f[1,1], tickbox = true, tickalign = (:center, :center), subtitle = "tickbox = true, tickalign = (:center, :center)")
sc = SmithAxis(f[1,2], tickbox = false, tickalign = (:center, :center), subtitle = "tickbox = false, tickalign = (:center, :center)")
sc = SmithAxis(f[2,1], tickbox = false, tickalign = (:right, :bottom), subtitle = "tickbox = false, tickalign = (:center, :top)")
sc = SmithAxis(f[2,2], tickbox = false, tickalign = (:left, :bottom), subtitle = "tickbox = false, tickalign = (:center, :bottom)")
f
```

## `splitgrid` keyword

The `splitgrid` keyword is a tuple that controls the number of lines into which each interval in the subgrid is divided. Each element of the tuple determines the number for a particular zoom value, so in this case we are only interested in the first one.

```@example
using SmithChart
using CairoMakie
CairoMakie.activate!() #hide
f = Figure(size = (1000, 750))
sc = SmithAxis(f[1,1], subgrid = true, splitgrid = (1,), subtitle = "splitgrid = (1,)")
sc = SmithAxis(f[1,2], subgrid = true, splitgrid = (2,), subtitle = "splitgrid = (2,)")
sc = SmithAxis(f[2,1], subgrid = true, splitgrid = (3,), subtitle = "splitgrid = (3,)")
sc = SmithAxis(f[2,2], subgrid = true, splitgrid = (4,), subtitle = "splitgrid = (4,)")

f
```

## `threshold` keyword

`threshold` keyword controls the cut of the lines in the intersection with other arcs.

```@example
using SmithChart
using CairoMakie

f = Figure(size = (1000, 750))
sc = SmithAxis(f[1,1], subgrid = true, splitgrid = (2, 2), threshold = (50, 50), subtitle = "Threshold (50, 50)")
sc = SmithAxis(f[1,2], subgrid = true, splitgrid = (2, 2), threshold = (50, 125), subtitle = "Threshold (50, 125)")
sc = SmithAxis(f[2,1], subgrid = true, splitgrid = (2, 2), threshold = (25, 25), subtitle = "Threshold (25, 25)")
sc = SmithAxis(f[2,2], subgrid = true, splitgrid = (2, 2), threshold = (25, 200), subtitle = "Threshold (25, 200)")
f
```