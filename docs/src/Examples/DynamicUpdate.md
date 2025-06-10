# Dynamic Annotation Update

You can enable experimental real-time curve annotation using the `textupdate = true` keyword when creating the SmithAxis:

```@example
using GLMakie
using SmithChart
GLMakie.activate!()
fig = Figure(size = (500,500))
ax = SmithAxis(fig[1, 1]; subgrid = true, cutgrid = true, zoomupdate = true, textupdate = true, threshold = (150, 150))
fig
```

The result would be something like the following gif.

![Dynamic](../assets/SmithChart_zoom.gif)