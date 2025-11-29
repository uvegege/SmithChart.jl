function smithplot_attributes()
    Makie.@DocumentedAttributes begin
        "The color of the line."
        color = @inherit linecolor
        "Sets the width of the line in screen units"
        linewidth = @inherit linewidth
        """
        Sets the dash pattern of the line. Options are `:solid` (equivalent to `nothing`), `:dot`, `:dash`, `:dashdot` and `:dashdotdot`.
        These can also be given in a tuple with a gap style modifier, either `:normal`, `:dense` or `:loose`.
        For example, `(:dot, :loose)` or `(:dashdot, :dense)`.

        """
        linestyle = nothing
        """
        Sets the type of line cap used. Options are `:butt` (flat without extrusion),
        `:square` (flat with half a linewidth extrusion) or `:round`.
        """
        linecap = @inherit linecap
        """
        Controls the rendering at corners. Options are `:miter` for sharp corners,
        `:bevel` for "cut off" corners, and `:round` for rounded corners. If the corner angle
        is below `miter_limit`, `:miter` is equivalent to `:bevel` to avoid long spikes.
        """
        joinstyle = @inherit joinstyle
        "Sets the minimum inner join angle below which miter joins truncate. See also `Makie.miter_distance_to_angle`."
        miter_limit = @inherit miter_limit
        """
        Sets which attributes to cycle when creating multiple plots. The values to
        cycle through are defined by the parent Theme. Multiple cycled attributes can
        be set by passing a vector. Elements can
        - directly refer to a cycled attribute, e.g. `:color`
        - map a cycled attribute to a palette attribute, e.g. `:linecolor => :color`
        - map multiple cycled attributes to a palette attribute, e.g. `[:linecolor, :markercolor] => :color`
        """
        cycle = [:color]
        Makie.mixin_generic_plot_attributes()...
        Makie.mixin_colormap_attributes()...
        fxaa = false
    end
end

function smithscatter_attributes()
    Makie.@DocumentedAttributes begin
        "Sets the color of the marker. If no color is set, multiple calls to `scatter!` will cycle through the axis color palette."
        color = @inherit markercolor
        "Sets the scatter marker."
        marker = @inherit marker
        """
        Sets the size of the marker by scaling it relative to its base size which can differ for each marker.
        A `Real` scales x and y dimensions by the same amount.
        A `Vec` or `Tuple` with two elements scales x and y separately.
        An array of either scales each marker separately.
        Humans perceive the area of a marker as its size which grows quadratically with `markersize`,
        so multiplying `markersize` by 2 results in a marker that is 4 times as large, visually.
        """
        markersize = @inherit markersize
        "Sets the color of the outline around a marker."
        strokecolor = @inherit markerstrokecolor
        "Sets the width of the outline around a marker."
        strokewidth = @inherit markerstrokewidth
        "Sets the color of the glow effect around the marker."
        glowcolor = (:black, 0.0)
        "Sets the size of a glow effect around the marker."
        glowwidth = 0.0

        "Sets the rotation of the marker. A `Billboard` rotation is always around the depth axis."
        rotation = Billboard()
        "The offset of the marker from the given position in `markerspace` units. An offset of 0 corresponds to a centered marker."
        marker_offset = Vec3f(0)
        "Controls whether the model matrix (without translation) applies to the marker itself, rather than just the positions. (If this is true, `scale!` and `rotate!` will affect the marker."
        transform_marker = false
        "Sets the font used for character markers. Can be a `String` specifying the (partial) name of a font or the file path of a font file"
        font = @inherit markerfont
        "Optional distancefield used for e.g. font and bezier path rendering. Will get set automatically."
        distancefield = nothing
        """
        Sets the font to be used for character markers
        """
        font = "default"
        "Sets the space in which `markersize` is given. See `Makie.spaces()` for possible inputs"
        markerspace = :pixel
        """
        Sets which attributes to cycle when creating multiple plots. The values to
        cycle through are defined by the parent Theme. Multiple cycled attributes can
        be set by passing a vector. Elements can
        - directly refer to a cycled attribute, e.g. `:color`
        - map a cycled attribute to a palette attribute, e.g. `:linecolor => :color`
        - map multiple cycled attributes to a palette attribute, e.g. `[:linecolor, :markercolor] => :color`
        """
        cycle = [:color]
        "Enables depth-sorting of markers which can improve border artifacts. Currently supported in GLMakie only."
        depthsorting = false
        Makie.mixin_generic_plot_attributes()...
        Makie.mixin_colormap_attributes()...
        fxaa = false
    end
end

"""
    smithplot(z; kwargs...)

Plot lines on the Smith Chart.

## Valid Keywords:

- `reflection = false`: Specifies whether it is a normalized impedance or a reflection coefficient.
- `freq = Float64[]` Array of frequencies associated with each represented value. Mainly used by `DataInspector`.

## Examples

```
using SmithChart
using CairoMakie

fig = Figure(size = (800, 600))
sc = SmithAxis(fig[1, 1], cutgrid = true)
r = 0.6 .+ 0.15 * exp.(1im .* range(0, 2π; length = 300))
smithplot!(sc, r; color = :dodgerblue, linewidth = 2)
fig
```

```

"""
@recipe SmithPlot (z,) begin
    "Specifies whether it is a normalized impedance or a reflection coefficient."
    reflection = false
    " Array of frequencies associated with each represented value. Mainly used by `DataInspector`"
    freq = Float64[]
    smithplot_attributes()...
end

argument_names(::Type{<:SmithPlot}, N) = (:z,)
Makie.preferred_axis_type(plot::SmithPlot) = SmithAxis

"""
    smithscatter(z; kwargs...)

Scatter points on the Smith Chart.

## Valid Keywords:

- `reflection = false`: Specifies whether it is a normalized impedance or a reflection coefficient.
- `freq = Float64[]` Array of frequencies associated with each represented value. Mainly used Mainly used by `DataInspector`.

## Examples

```
using SmithChart
using CairoMakie

fig = Figure(size = (800, 600))
sc = SmithAxis(fig[1, 1], cutgrid = true)
r = 0.6 .+ 0.15 * exp.(1im .* range(0, 2π; length = 300))
smithscatter!(sc, r; color = :dodgerblue, linewidth = 2)
fig
```

"""
@recipe SmithScatter (z,) begin
    "Specifies whether it is a normalized impedance or a reflection coefficient."
    reflection = false
    " Array of frequencies associated with each represented value. Mainly used by `DataInspector`"
    freq = Float64[]
    smithscatter_attributes()...
end

argument_names(::Type{<:SmithScatter}, N) = (:z,)
Makie.preferred_axis_type(plot::SmithScatter) = SmithAxis


function Makie.show_data(inspector::DataInspector, plot::SmithPlot, idx, ::Lines)
    a = plot.attributes
    zi = plot[1][][idx]

    if a.reflection[] == false
        pos = smith_transform(zi)
    else
        pos = Point2f(real(zi), imag(zi))
    end

    scene = Makie.parent_scene(plot)
    proj_pos = Makie.shift_project(scene, to_ndim(Point3f, pos, 0))

    if imag(zi) < 0
        text = @sprintf("z=%.3f-j%.3f", real(zi), abs(imag(zi)))
    else
        text = @sprintf("z=%.3f+j%.3f", real(zi), abs(imag(zi)))
    end

    if !isempty(a.freq[])
        f = a.freq[][idx]
        ftext = f < 1.0e3 ? @sprintf("%.3f Hz", f) :
                f < 1.0e6 ? @sprintf("%.3f kHz", f / 1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f / 1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f / 1.0e9) :
                @sprintf("%.3f THz", f / 1.0e12)
        text *= "\n f = " * ftext
    end
    Makie.update_tooltip_alignment!(inspector, proj_pos; text)
    return true
end


function Makie.show_data(inspector::DataInspector, plot::SmithScatter, idx, ::Scatter)
    a = plot.attributes
    zi = plot[1][][idx]
    if a.reflection[] == false
        pos = smith_transform(zi)
    else
        pos = Point2f(real(zi), imag(zi))
    end

    scene = Makie.parent_scene(plot)
    proj_pos = Makie.shift_project(scene, to_ndim(Point3f, pos, 0))


    if imag(zi) < 0
        text = @sprintf("z=%.3f-j%.3f", real(zi), abs(imag(zi)))
    else
        text = @sprintf("z=%.3f+j%.3f", real(zi), abs(imag(zi)))
    end

    if !isempty(a.freq[])
        f = a.freq[][idx]
        ftext = f < 1.0e3 ? @sprintf("%.3f Hz", f) :
                f < 1.0e6 ? @sprintf("%.3f kHz", f / 1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f / 1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f / 1.0e9) :
                @sprintf("%.3f THz", f / 1.0e12)
        text *= "\n f = " * ftext
    end

    Makie.update_tooltip_alignment!(inspector, proj_pos; text)

    return true
end

function Makie.plot!(sp::SmithPlot)
    output_nodes = :lines
    map!(sp.attributes, [:z, :reflection], output_nodes) do z, r
        lines = Point2f[]
        if !isempty(z)
            for zi in z
                if r == false
                    push!(lines, smith_transform(zi))
                else
                    push!(lines, Point2f(real(zi), imag(zi)))
                end
            end
        else
            append!(lines, [Point2f(NaN), Point2f(NaN)])
        end
        return lines
    end
    lines!(sp, Attributes(sp), sp.lines)
    return sp
end


function Makie.plot!(sc::SmithScatter)
    output_nodes = :scatter
    map!(sc.attributes, [:z, :reflection], output_nodes) do z, r
        scatter = Point2f[]
        if !isempty(z)
            for zi in z
                if r == false
                    push!(scatter, smith_transform(zi))
                else
                    push!(scatter, Point2f(real(zi), imag(zi)))
                end
            end
        else
            append!(scatter, [Point2f(NaN), Point2f(NaN)])
        end
        return scatter
    end
    scatter!(sc, Attributes(sc), sc.scatter)
    return sc
end