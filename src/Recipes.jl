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
@recipe SmithPlot (z, ) begin
    "Specifies whether it is a normalized impedance or a reflection coefficient."
    reflection=false
    " Array of frequencies associated with each represented value. Mainly used by `DataInspector`"
    freq = Float64[]
    Makie.documented_attributes(Lines)...
end

argument_names(::Type{<: SmithPlot}, N) = (:z, )
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
@recipe SmithScatter (z, ) begin 
    "Specifies whether it is a normalized impedance or a reflection coefficient."
    reflection=false
    " Array of frequencies associated with each represented value. Mainly used by `DataInspector`"
    freq = Float64[]
    Makie.documented_attributes(Scatter)...
end

argument_names(::Type{<: SmithScatter}, N) = (:z, )
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
                f < 1.0e6 ? @sprintf("%.3f kHz", f/1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f/1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f/1.0e9) :
                @sprintf("%.3f THz", f/1.0e12)
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
                f < 1.0e6 ? @sprintf("%.3f kHz", f/1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f/1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f/1.0e9) :
                @sprintf("%.3f THz", f/1.0e12)
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