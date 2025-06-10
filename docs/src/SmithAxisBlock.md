# SmithAxis Block

The `SmithAxis` is a layoutable visual block built on top of [`Makie.jl`](https://makie.juliaplots.org/) using the `@Block` macro. It provides an intuitive and familiar interface for plotting complex reflection and impedance data on a Smith chart.

It behaves like any other axis block (such as `Axis`, `PolarAxis`, or `LScene`) in Makie. You can place it inside a `GridLayout`, style it, and compose it freely with other visual components.

---

## Usage

To use a `SmithAxis`, simply add it in a figure layout:

```@example
using SmithChart
using CairoMakie

fig = Figure()
sc = SmithAxis(fig[1, 1]; cutgrid = true, type = :Z)
fig
```

This creates a Smith chart axis. You can then use functions like `smithplot!` or `smithscatter!` to draw data onto it.


---

## Keyword Options

You can explore all keyword arguments by calling:

```julia
?SmithAxis
```

Here are some of the most commonly used:

| Keyword         | Description                                                              | Default     |
|------------------|--------------------------------------------------------------------------|-------------|
| `cutgrid`       | Whether to cut the Smith grid at ±90° for a clearer display              | `false`     |
| `type`          | The Smith chart type: `:Z` (impedance) or `:Y` (admittance)              | `:Z`        |
| `tickalign`     | Alignment of tick marks             | `(:center, :center)`   |
| `tickbox`       | Show bounding boxes behind tick labels                                   | `true`      |
| `zoomupdate`    | Dynamically adjust grid resolution based on zoom level                   | `false`     |
| `textupdate`    | Enables dynamic hover annotations on plotted data (experimental)         | `false`     |
| `spinewidth`    | Linewidth of the exterior circumference.                                 | `2.2`       |
| `spinehorizontalwidth`    | Linewidth of the spine horizontal line .                       | `1.7`       |


---

## Full List of SmithAxis fields and keywords

Below is a comprehensive list of the fields and keywords available for the `SmithAxis` block. Note that some fields are intentionally omitted because they are not intended for direct user manipulation and are used internally to control specific implementation details.

Also, some keywords related to the scene or internal aspects of Makie may have no visible effect. These were included preventively during the development of the block in case they might be needed later, even if they are not currently used.

---

####  Contents

```@contents
Pages = ["SmithAxisBlock.md"]
Depth = 3:3
```
---

### Smith Chart Settings

- `type::Symbol = :Z`  
  Smith Chart type. Valid values are `:Z`, `:Y`, and `:ZY`.
- `cutgrid::Bool = true`  
  Controls the cut of the lines.
- `cutgridalg::Int = 2`  
  Select cutgrid algorithm (1 or 2).
- `subgrid::Bool = false`  
  Controls if there is a subgrid drawn in the image.
- `zoomupdate::Bool = false`  
  Controls the interactive `subgrid` update while zooming.
- `textupdate::Bool = false`  
  Controls if there are interactive text annotations while moving and zooming.
- `ntextvals::Int = 7`  
  Controls the maximum number of text labels.
- `threshold = (100, 100)`
  Threshold controling the cut of the grid

### Scene Settings
- `height = nothing`  
  The height setting of the scene.
- `width = nothing`  
  The width setting of the scene.
- `tellwidth::Bool = true`  
  Controls if the parent layout can adjust to this element's width.
- `tellheight::Bool = true`  
  Controls if the parent layout can adjust to this element's height.
- `halign = :center`  
  The horizontal alignment of the scene in its suggested bounding box.
- `valign = :center`  
  The vertical alignment of the scene in its suggested bounding box.
- `alignmode = Inside()`  
  The alignment mode of the scene in its suggested bounding box.
- `xreversed::Bool = false`  
  Controls if the x axis goes rightwards (false) or leftwards (true) in default camera orientation.
- `yreversed::Bool = false`  
  Controls if the y axis goes leftwards (false) or rightwards (true) in default camera orientation.

### Background and Clipping
- `sample_density::Int = 361`  
  The density at which curved lines are sampled (grid lines, spine lines, clip).
- `backgroundcolor`  
  The background color of the axis.
- `backgroundcolorint`  
  The internal background color of the axis.
- `clip::Bool = true`  
  Controls whether to activate the nonlinear clip feature.
- `clipcolor`  
  Sets the color of the clip polygon (mainly for debugging).
- `innerclipz::Float32 = -100.0`  
  Sets the z value of inner clip.
- `outerclipz::Float32 = 100.0`  
  Sets the z value of outer clip.

### Limits and Transformations
- `limits = ((-1., 1.), (-1., 1.))`  
  Define axis limits.
- `aspect::Float32 = 1.0`  
  Controls the forced aspect ratio of the Smith Chart.
- `vlimit::Float32 = 1.0`  
  Radial limit of the Smith Chart.
- `xautolimitmargin::Tuple{Float64, Float64} = (0.05, 0.05)`  
  Relative margins added to the autolimits in x direction.
- `yautolimitmargin::Tuple{Float64, Float64} = (0.05, 0.05)`  
  Relative margins added to the autolimits in y direction.

### Title and Subtitle
- `title = ""`  
  The title of the plot.
- `titlegap::Float32 = 4.0`  
  The gap between the title and the top of the axis.
- `titlealign = :center`  
  The alignment of the title (`:center`, `:left`, or `:right`).
- `titlesize::Float32 = 16.0`  
  The fontsize of the title.
- `titlefont = :bold`  
  The font of the title.
- `titlecolor = :black`  
  The color of the title.
- `titlevisible::Bool = true`  
  Controls if the title is visible.
- `subtitle = ""`  
  The content of the axis subtitle.
- `subtitlefont = :regular`  
  The font family of the subtitle.
- `subtitlesize::Float64 = 16.0`  
  The subtitle's font size.
- `subtitlegap::Float64 = 0`  
  The gap between subtitle and title.
- `subtitlevisible::Bool = true`  
  Controls if the subtitle is visible.
- `subtitlecolor::RGBAf = :black`  
  The color of the subtitle.
- `subtitlelineheight::Float64 = 1`  
  The axis subtitle line height multiplier.

### Spine Settings
- `spinez::Float32 = 9000`  
  Sets the z value of the exterior circumference. To place the grid above plots set a value > 1.
- `spinecolor = :black`  
  Color of the exterior circumference.
- `spinewidth::Float32 = 2.2`  
  Linewidth of the exterior circumference.
- `spinehorizontalwidth::Float32 = 1.7`  
  Linewidth of the horizontal line.
- `spinestyle`  
  Linestyle of the exterior circumference.
- `spinevisible::Bool = true`  
  Controls if the exterior circumference is visible.

### Grid Settings

#### General Grid
- `gridcolor = nothing`  
  Controls the color of ALL the grid. This has preference over other color keywords. 
- `zgridcolor = nothing`  
  Controls the color of Z smith chart grid. This has preference over `rgridcolor` and `xgridcolor` when is not equal to `nothing`.
- `ygridcolor = nothing`  
  Controls the color of Y smith chart grid. This has preference over `bgridcolor` and `ggridcolor` when is not equal to `nothing`.
- `splitgrid = (1, 1, 3)`  
  Controls the number of times the grid is split for each zoom level.

#### Resistance Grid
- `rvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]`  
  Resistance grid positions.
- `rgridz::Float32 = -50`  
  Sets the z value of the Resistance arcs grid.
- `rgridcolor = :black`  
  Color of the Resistance grid.
- `rgridwidth::Float32 = 0.7`  
  Linewidth of the Resistance grid.
- `rgridstyle`  
  Linestyle of the Resistance grid.
- `rgridvisible::Bool = true`  
  Controls if the Resistance grid is visible.
- `rsubgridstyle = :dash`  
  Resistance subgrid style.
- `rsubgridwidth::Float32 = 0.7`  
  Linewidth of the Resistance subgrid.
- `rsubgridcolor = :black`  
  Color of the Resistance subgrid.

#### Reactance Grid
- `xvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]`  
  Reactance grid positions.
- `xgridz::Float32 = -50`  
  Sets the z value of the Reactance arcs grid.
- `xgridcolor = :black`  
  Color of the Reactance grid.
- `xgridwidth::Float32 = 0.7`  
  Linewidth of the Reactance grid.
- `xgridstyle`  
  Linestyle of the Reactance grid.
- `xgridvisible::Bool = true`  
  Controls if the Reactance grid is visible.
- `xsubgridstyle = :dash`  
  Reactance subgrid style.
- `xsubgridwidth::Float32 = 0.7`  
  Linewidth of the Reactance subgrid.
- `xsubgridcolor = :black`  
  Color of the Reactance subgrid.

#### Conductance Grid
- `gvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]`  
  Conductance grid positions.
- `ggridz::Float32 = -50`  
  Sets the z value of the Conductance arcs grid.
- `ggridcolor = :black`  
  Color of the Conductance grid.
- `ggridwidth::Float32 = 0.7`  
  Linewidth of the Conductance grid.
- `ggridstyle`  
  Linestyle of the Conductance grid.
- `ggridvisible::Bool = true`  
  Controls if the Conductance grid is visible.
- `gsubgridstyle = :dash`  
  Conductance subgrid style.
- `gsubgridwidth::Float32 = 0.7`  
  Linewidth of the Conductance subgrid.
- `gsubgridcolor = :black`  
  Color of the Conductance subgrid.

#### Susceptance Grid

- `bvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]`  
  Susceptance grid positions.
- `bgridz::Float32 = -50`  
  Sets the Susceptance value of the arcs grid.
- `bgridcolor = :black`  
  Color of the Susceptance grid.
- `bgridwidth::Float32 = 0.7`  
  Linewidth of the Susceptance grid.
- `bgridstyle`  
  Linestyle of the Susceptance grid.
- `bgridvisible::Bool = true`  
  Controls if the Susceptance grid is visible.
- `bsubgridstyle = :dash`  
  Susceptance subgrid style.
- `bsubgridwidth::Float32 = 0.7`  
  Linewidth of the Susceptance subgrid.
- `bsubgridcolor = :black`  
  Color of the Susceptance subgrid.

### Tick Settings

-   `tickalign = (:center, :center)`
  Align of the R ticks
-  `tickbox::Bool = true`
  Controls if we draw a box behind the text

#### Reactance Ticks 
- `xtickvisible::Bool = true`
  Controls if the exterior circunference ticks are visible
- `xtickformat = Makie.automatic`
  The formatter for the exterior ticks.
- `xticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), inherit(scene, :fontsize, 16))`
  The fontsize of the exterior tick labels.
- `xticklabelfont = inherit(scene, (:Axis, :yticklabelfont), inherit(scene, :font, Makie.defaultfont()))`
  The font of the exterior tick labels.
- `xticklabelcolor = inherit(scene, (:Axis, :yticklabelcolor), inherit(scene, :textcolor, :black))`
  The color of the exterior tick labels.
- `xticklabelpad::Float32 = 4.5f0`
  Padding of the exterior ticks label.
- `xticklabelstrokewidth::Float32 = 0.0`
  The width of the outline of exterior ticks. Setting this to 0 will remove the outline.
- `xticklabelstrokecolor = automatic`
  The color of the outline of exterior ticks. By default this uses the background color.

#### Resistance Ticks
- `rtickformat = Makie.automatic`
    The formatter for the r ticks
- `rticklabelsize::Float32 = inherit(scene, (:Axis, :yticklabelsize), inherit(scene, :fontsize, 16))`
    The fontsize of the RESISTANCE tick labels.
- `rticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))`
    The font of the r tick labels.
- `rticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))`
    The color of the r tick labels.
- `rticklabelstrokewidth::Float32 = 0.0`
    The width of the outline of r ticks. Setting this to 0 will remove the outline.
- `rticklabelstrokecolor = automatic`
    The color of the outline of r ticks. By default this uses the background color.
- `rticklabelpad::Float32 = 4f0`
    Padding of the r ticks label.
- `rtickvisible::Bool = inherit(scene, (:Axis, :xticklabelsvisible), true)`
    Controls if the r ticks are visible.
- `rtickangle::Float32 = 0.0`
    The angle in radians along which the r ticks are printed.

#### Susceptance Ticks 
- `btickvisible::Bool = true`
    Controls if the exterior circunference ticks are visible
- `btickformat = Makie.automatic`
    The formatter for the exterior ticks.
- `bticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), inherit(scene, :fontsize, 16))`
    The fontsize of the exterior tick labels.
- `bticklabelfont = inherit(scene, (:Axis, :yticklabelfont), inherit(scene, :font, Makie.defaultfont()))`
    The font of the exterior tick labels.
- `bticklabelcolor = inherit(scene, (:Axis, :yticklabelcolor), inherit(scene, :textcolor, :black))`
    The color of the exterior tick labels.
- `bticklabelpad::Float32 = 4f0`
    Padding of the exterior ticks label.
- `bticklabelstrokewidth::Float32 = 0.0`
    The width of the outline of exterior ticks. Setting this to 0 will remove the outline.
- `bticklabelstrokecolor = automatic`
    The color of the outline of exterior ticks. By default this uses the background color.

#### Conductance Ticks
- `gtickformat = Makie.automatic`
    The formatter for the Conductance ticks.
- `gticklabelsize::Float32 = inherit(scene, (:Axis, :yticklabelsize), inherit(scene, :fontsize, 16))`
    The fontsize of the Conductance btick labels.
- `gticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))`
    The font of the Conductance tick labels.
- `gticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))`
    The color of the Conductance tick labels.
- `gticklabelstrokewidth::Float32 = 0.0`
    The width of the outline of Conductance ticks. Setting this to 0 will remove the outline.
- `gticklabelstrokecolor = automatic`
    The color of the outline of Conductance ticks. By default this uses the background color.
- `gticklabelpad::Float32 = 4f0`
    Padding of the Conductance ticks label.
- `gtickvisible::Bool = true`
    Controls if the Conductance ticks are visible.
- `gtickangle::Float32 = 0.0`
    The angle in radians along which the Conductance ticks are printed.


---

##  Example

```@example
using SmithChart
using CairoMakie

fig = Figure(size = (800, 600))
sc = SmithAxis(fig[1, 1], cutgrid = true)
r = 0.6 .+ 0.15 * cis.(range(0, 2π; length = 300))
smithplot!(sc, r; color = :dodgerblue, linewidth = 2)
fig

```

---
