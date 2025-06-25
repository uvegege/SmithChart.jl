"""
    smithplot(z; kwargs...)

Plot lines on the Smith Chart.

## Valid Keywords:

- `color`  sets the color of the marker. Read `? scatter`.
- `colormap = :viridis` sets the colormap that is sampled for numeric colors. 
- `linestyle = :rect` sets the pattern of the line e.g. :solid, :dot, :dashdot.
- `line_width = 2.8` sets the width of the line in pixel units.
- `label = nothing`
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
    color=:teal
    colormap=:viridis
    line_width=2.8
    linestyle=:solid
    label=nothing
    reflection=false
    freq = Float64[]
    cycle=[:color]
end

Makie.preferred_axis_type(plot::SmithPlot) = SmithAxis 

"""
    smithscatter(z; kwargs...)

Scatter points on the Smith Chart.

## Valid Keywords:

- `color`  sets the color of the marker. Read `? scatter`.
- `colormap = :viridis` sets the colormap that is sampled for numeric colors. 
- `marker = :rect` sets the scatter marker.
- `markersize = 9` sets the size of the marker.
- `label = nothing`
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
        color=:teal
        colormap=:viridis
        marker=:circle
        markersize=9
        label=""
        reflection=false
        freq = Float64[]
        cycle=[:color]
end

Makie.preferred_axis_type(plot::SmithScatter) = SmithAxis 


function Makie.show_data(inspector::DataInspector, plot::SmithPlot, idx, ::Lines)
    # Get the tooltip plot
    tt = inspector.plot
    a = plot.attributes
    zi = plot[1][][idx]

    if a.reflection[] == false
        pos = smith_transform(zi)
    else
        pos = Point2f(real(zi), imag(zi))
    end
    # Get the scene BarPlot lives in
    scene = Makie.parent_scene(plot)

    # project to screen space and shift it to be correct on the root scene
    proj_pos = Makie.shift_project(scene, to_ndim(Point3f, pos, 0))
    # anchor the tooltip at the projected position
    Makie.update_tooltip_alignment!(inspector, proj_pos)

    if imag(zi) < 0
        txt = @sprintf("z=%.3f-j%.3f", real(zi), abs(imag(zi)))
    else
        txt = @sprintf("z=%.3f+j%.3f", real(zi), abs(imag(zi)))
    end

    if !isempty(a.freq[])
        f = a.freq[][idx]
        ftext = f < 1.0e3 ? @sprintf("%.3f Hz", f) :
                f < 1.0e6 ? @sprintf("%.3f kHz", f/1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f/1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f/1.0e9) :
                @sprintf("%.3f THz", f/1.0e12)
        txt *= "\n f = " * ftext
    end

    tt.text[] = txt
    # Show the tooltip
    tt.visible[] = true
    # return true to indicate that we have updated the tooltip
    return true
end


function Makie.show_data(inspector::DataInspector, plot::SmithScatter, idx, ::Scatter)
    # Get the tooltip plot
    tt = inspector.plot
    a = plot.attributes
    zi = plot[1][][idx]
    if a.reflection[] == false
        pos = smith_transform(zi)
    else
        pos = Point2f(real(zi), imag(zi))
    end
    # Get the scene BarPlot lives in
    scene = Makie.parent_scene(plot)

    # project to screen space and shift it to be correct on the root scene
    proj_pos = Makie.shift_project(scene, to_ndim(Point3f, pos, 0))
    # anchor the tooltip at the projected position
    Makie.update_tooltip_alignment!(inspector, proj_pos)

    if imag(zi) < 0
        txt = @sprintf("z=%.3f-j%.3f", real(zi), abs(imag(zi)))
    else
        txt = @sprintf("z=%.3f+j%.3f", real(zi), abs(imag(zi)))
    end

    if !isempty(a.freq[])
        f = a.freq[][idx]
        ftext = f < 1.0e3 ? @sprintf("%.3f Hz", f) :
                f < 1.0e6 ? @sprintf("%.3f kHz", f/1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f/1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f/1.0e9) :
                @sprintf("%.3f THz", f/1.0e12)
        txt *= "\n f = " * ftext
    end

    tt.text[] = txt
    # Show the tooltip
    tt.visible[] = true
    # return true to indicate that we have updated the tooltip
    return true
end

function Makie.plot!(sp::SmithPlot)
    z = sp[1]
    color = sp[:color]
    line_width = sp[:line_width]
    linestyle = sp[:linestyle]
    label = sp[:label]
    reflection = sp[:reflection]
    colormap = sp[:colormap]

    z_data = Observable(Point2f[])
    function update_zdata(z)
        empty!(z_data[])
        if !isempty(z)
            for zi in z
                if reflection[] == false
                    push!(z_data[], smith_transform(zi))
                else
                    push!(z_data[], Point2f(real(zi), imag(zi)))
                end
            end
        else
            push!(z_data[], Point2f(NaN))
            push!(z_data[], Point2f(NaN))
        end
        notify(z_data)
    end
    on(update_zdata, z)
    update_zdata(z[])

    lines!(sp, z_data, color=color, colormap=colormap, linewidth=line_width, linestyle=linestyle, label=label)
    return sp
end


function Makie.plot!(sc::SmithScatter)
    @show sc.attributes
    z = sc[1]
    color = sc[:color]
    markersize = sc[:markersize]
    marker = sc[:marker]
    label = sc[:label]
    reflection = sc[:reflection]
    colormap = sc[:colormap]

    z_data = Observable(Point2f[])
    function update_zdata(z)
        empty!(z_data[])
        if !isempty(z)
            for zi in z
                if reflection[] == false
                    push!(z_data[], smith_transform(zi))
                else
                    push!(z_data[], Point2f(real(zi), imag(zi)))
                end
            end
        else
            push!(z_data[], Point2f(NaN))
            push!(z_data[], Point2f(NaN))
        end
        notify(z_data)
    end
    on(update_zdata, z)
    update_zdata(z[])

    scatter!(sc, z_data, color=color, colormap=colormap, markersize=markersize, marker=marker, label=label)

    return sc
end