
"""
    smithchart(z; kwargs...)

Plot lines on the Smith Chart.

# Valid Keywords:

- `background=:white` sets color of the background.
- `grid_color=:black` sets the color of the grid lines.
- `grid_width=0.7` sets width of the grid lines in pixel units.
- `grid=true` controls de visibility of the grid.
- `limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` 
- `prev_limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` internally used observable.
- `text_markers=true` control the visibility of the text annotations on the horizontal line.
- `exterior_markers=true` control the visibility of the text annotations around the Smith Chart.
- `n_grid_arcs=27` control de maximum number of grid arcs. Should not be changed.
- `cutgrid=false` controls the cut of the lines.
- `subgrid=false` controls if the grid is updated while zooming.
- `zoomupdate=true` controls the interactive `subgrid` update while zooming. 
- `textupdate=false` controls the interactive text annotations. When `true` the annotations appears in the image.
"""
@recipe(Smithchart, z) do scene
    Attributes(
        background=:white,
        grid_color=:black,
        grid_width=0.7,
        grid=true,
        limits=Rect2f(-1.2, -1.2, 2.4, 2.4),
        prev_limits=Rect2f(-1.2, -1.2, 2.4, 2.4),
        text_markers=true,
        exterior_markers=true,
        n_grid_arcs=27,
        cutgrid=true,
        subgrid=false,
        zoomupdate=true,
        textupdate=false
    )
end


"""
    smithplot(z; kwargs...)

Plot lines on the Smith Chart.

# Valid Keywords:

- `color`  sets the color of the marker. Read `? scatter`.
- `colormap = :viridis` sets the colormap that is sampled for numeric colors. 
- `linestyle = :rect` sets the pattern of the line e.g. :solid, :dot, :dashdot.
- `line_width = 2.8` sets the width of the line in pixel units.
- `label = nothing`
- `reflection = false`: Specifies whether it is a normalized impedance or a reflection coefficient.
- `freq = Float64[]` Array of frequencies associated with each represented value. Mainly used to represent the data with the `DataInspector`.
"""
@recipe(SmithPlot, z) do scene
    Attributes(
        color=:teal,
        colormap=:viridis,
        line_width=2.8,
        linestyle=:solid,
        label=nothing,
        reflection=false,
        freq = Float64[],
        cycle=[:color]
    )
end

"""
    smithscatter(z; kwargs...)

Scatter points on the Smith Chart.

# Valid Keywords:

- `color`  sets the color of the marker. Read `? scatter`.
- `colormap = :viridis` sets the colormap that is sampled for numeric colors. 
- `marker = :rect` sets the scatter marker.
- `markersize = 9` sets the size of the marker.
- `label = nothing`
- `reflection = false`: Specifies whether it is a normalized impedance or a reflection coefficient.
- `freq = Float64[]` Array of frequencies associated with each represented value. Mainly used to represent the data with the `DataInspector`.
"""
@recipe(SmithScatter, z) do scene
    Attributes(
        color=:teal,
        colormap=:viridis,
        marker=:circle,
        markersize=9,
        label="",
        reflection=false,
        freq = Float64[],
        cycle=[:color]
    )
end

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
    end
    on(update_zdata, z)
    update_zdata(z[])
    lines!(sp, z_data, color=color, colormap=colormap, linewidth=line_width, linestyle=linestyle, label=label)
    return sp
end


function Makie.plot!(sc::SmithScatter)
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
    end
    on(update_zdata, z)
    update_zdata(z[])

    scatter!(sc, z_data, color=color, colormap=colormap, markersize=markersize, marker=marker, label=label)

    return sc
end

function Makie.plot!(chart::Smithchart)
    background = chart[:background]
    grid_color = chart[:grid_color]
    lwgrid = chart[:grid_width]
    grid = chart[:grid]
    text_markers = chart[:text_markers]
    exterior_markers = chart[:exterior_markers]
    limits = chart[:limits]
    prev_limits = chart[:prev_limits]
    n_grid_arcs = chart[:n_grid_arcs]
    cutgrid = chart[:cutgrid]
    subgrid = chart[:subgrid]
    zoomupdate = chart[:zoomupdate]
    textupdate = chart[:textupdate]

    nvals = 7

    cutfunction = lift(cutgrid) do cut
        if cut == true
            start_end_angles
        else
            (x...) -> return (-pi, pi)
        end
    end

    rtext = Observable([Point2f(Inf) for _ in 1:nvals])
    itext = Observable([Point2f(Inf) for _ in 1:nvals])
    vrtext = Observable([0.0 for _ in 1:nvals])
    vitext = Observable([0.0 for _ in 1:nvals])

    zoomlevel = Observable(1)

    txtvisible = lift(text_markers, textupdate) do marker, txtupdate
        visible = false
        if txtupdate == true
            visible = false
        else
            visible = marker
        end
        visible
    end

    function update_zoomlevel(limits)
        !zoomupdate[] && return
        minspan = minimum(limits.widths)
        act_zoomlevel = zoomlevel[]
        zlevel = 10000 >= minspan >= 1.8 ? 0 :
                 1.8 > minspan >= 1.5 ? 1 :
                 1.5 > minspan >= 1.2 ? 2 :
                 3
        if zlevel != act_zoomlevel
            zoomlevel[] = zlevel
        end
        move_textlabels(limits, zoomlevel[], rtext[], itext[], vrtext[], vitext[], textupdate[], nvals)
        notify(itext)
        notify(rtext)
        notify(vitext)
        notify(vrtext)
    end
    on(update_zoomlevel, limits)
    update_zoomlevel(limits[])

    for i in 1:nvals
        posr = lift(c -> c[i], rtext)
        s = scatter!(posr, marker=:rect, color=:white, markersize=30, visible=textupdate, inspectable=false)
        translate!(s, 0, 0, -1.5)
        v = lift(c -> "$(c[i])", vrtext)
        txt = text!(v, position=posr, align=(:center, :center), fontsize=12, visible=textupdate, inspectable=false)
        translate!(txt, 0, 0, -1)
    end

    for i in 1:nvals
        posi = lift(c -> c[i], itext)
        s = scatter!(posi, marker=:rect, color=:white, markersize=28, visible=textupdate, inspectable=false)
        translate!(s, 0, 0, -2.5)
        v = lift(c -> "$(c[i])j", vitext)
        txt = text!(v, position=posi, align=(:center, :center), fontsize=12, visible=textupdate, inspectable=false)
        translate!(txt, 0, 0, -2)
    end

    for i in 1:nvals
        posi = lift(c -> Point2(c[i][1], -c[i][2]), itext)
        s = scatter!(posi, marker=:rect, color=:white, markersize=28, visible=textupdate, inspectable=false)
        translate!(s, 0, 0, -2.5)
        v = lift(c -> "$(-c[i])j", vitext)
        txt = text!(v, position=posi, align=(:center, :center), fontsize=12, visible=textupdate, inspectable=false)
        translate!(txt, 0, 0, -2)
    end

    ZL = Observable(Float64[NaN for _ in 1:n_grid_arcs[]])
    function update_Rl(zoomlevel)
        split_intervals = 3
        if zoomlevel >= 1
            empty!(ZL[])
            ZL[] = [NaN for _ in 1:n_grid_arcs[]]
            intervals = [0 .. 0.2, 0.2 .. 0.4, 0.4 .. 0.6, 0.6 .. 1.0, 1.0 .. 2.0, 2.0 .. 5.0, 5.0 .. 10.0, 10.0 .. 20.0, 20.0 .. 80]
            values = reduce(vcat, splitintervals(intervals, split_intervals))
            for i in eachindex(values)
                ZL[][i] = values[i]
            end
            notify(ZL)
        else
            if all(>(1.8), limits[].widths) & !all(>(1.8), prev_limits[].widths)
                ZL[] = [NaN for _ in 1:n_grid_arcs[]]
                notify(ZL)
            end
            nothing
        end
    end
    on(update_Rl, zoomlevel)
    update_Rl(zoomlevel[])

    resistance_centers = Observable(zeros(Point2f, n_grid_arcs[]))
    resistance_rads = Observable(zeros(n_grid_arcs[],))
    ir = Observable(zeros(n_grid_arcs[],))
    er = Observable(zeros(n_grid_arcs[],))
    function update_R_arcs(r)
        subgrid[] || return
        empty!(resistance_centers[])
        empty!(resistance_rads[])
        empty!(ir[])
        empty!(er[])
        for zl in r
            center, rad = resistance_arcs(zl)
            i, e = cutfunction[](zl, center, rad, zoomlevel[], true, true)
            push!(resistance_rads[], rad)
            push!(resistance_centers[], center)
            push!(ir[], isnan(i) ? 0.0 : i)
            push!(er[], isnan(e) ? 0.0 : e)
        end
        notify(resistance_centers)
        notify(resistance_rads)
        notify(ir)
        notify(er)
    end
    on(update_R_arcs, ZL)
    update_R_arcs(ZL[])

    # This lines are always drawn
    for z in (0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0)
        center, rad = resistance_arcs(z)
        ie = @lift $cutfunction(z, center, rad, $zoomlevel, true)
        i = lift(c -> c[1], ie)
        e = lift(c -> c[2], ie)
        arcline = arc!(center, rad, i, e, color=grid_color, linestyle=:solid, linewidth=lwgrid, visible=grid, inspectable=false)
        translate!(arcline, 0, 0, -5)
        s = scatter!(Point2f(center[1] - rad, center[2]), marker=:rect, color=:white, markersize=28, visible=txtvisible, inspectable=false)
        translate!(s, 0, 0, -2.5)
        txt = text!(textval(z), position=Point2f(center[1] - rad, center[2]), align=(:center, :center), fontsize=12, visible=txtvisible, inspectable=false) # Ajustar offset según sea necesario
        translate!(txt, 0, 0, -2)
    end

    # DASHED RESISTANCES
    for z in (0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.25, 1.5, 3.5)
        center, rad = resistance_arcs(z)
        ie = @lift $cutfunction(z, center, rad, $zoomlevel, true, true)
        i = lift(c -> c[1], ie)
        e = lift(c -> c[2], ie)
        arcline = arc!(center, rad, i, e, color=grid_color, linestyle=:dash, linewidth=lwgrid, visible=subgrid, inspectable=false)
        translate!(arcline, 0, 0, -6)
    end

    # ZOOMED RESISTANCES
    for i in 1:n_grid_arcs[]
        center = lift(c -> c[i], resistance_centers)
        rad = lift(c -> c[i], resistance_rads)
        zl = lift(c -> c[i], ZL)
        i_ = lift(c -> c[i], ir)
        e_ = lift(c -> c[i], er)
        style = :dash
        arcline = arc!(center, rad, i_, e_, color=grid_color, linestyle=style, linewidth=lwgrid, visible=subgrid, inspectable=false)
        translate!(arcline, 0, 0, -5)
    end

    XL = Observable(Float64[NaN for _ in 1:2*n_grid_arcs[]])
    function update_Xl(zoomlevel)
        split_intervals = 3
        if zoomlevel >= 1
            empty!(XL[])
            XL[] = [NaN for _ in 1:2*n_grid_arcs[]]
            intervals = [0 .. 0.2, 0.2 .. 0.4, 0.4 .. 0.6, 0.6 .. 1.0, 1.0 .. 2.0, 2.0 .. 5.0, 5.0 .. 10.0, 10.0 .. 20.0, 20.0 .. 80]
            values = reduce(vcat, splitintervals(intervals, split_intervals))
            for i in eachindex(values)
                XL[][i] = values[i]
            end
            for i in eachindex(values)
                XL[][i+length(values)] = -values[i]
            end
            notify(XL)
        else
            if all(>(1.8), limits[].widths) & !all(>(1.8), prev_limits[].widths)
                XL[] = [NaN for _ in 1:2*n_grid_arcs[]]
                notify(XL)
            end
        end
    end
    on(update_Xl, zoomlevel)
    update_Xl(zoomlevel[])

    reactance_centers = Observable(zeros(Point2f, 2 * n_grid_arcs[],))
    reactance_rads = Observable(zeros(2 * n_grid_arcs[],))
    ex = Observable(zeros(2 * n_grid_arcs[],))
    ix = Observable(zeros(2 * n_grid_arcs[],))
    function update_X_arcs(r)
        subgrid[] || return
        empty!(reactance_centers[])
        empty!(reactance_rads[])
        empty!(ix[])
        empty!(ex[])
        for xl in r
            center, rad = reactance_arcs(xl)
            i, e = cutfunction[](xl, center, rad, zoomlevel[], false, true)
            push!(reactance_rads[], rad)
            push!(reactance_centers[], center)
            push!(ix[], isnan(i) ? 0.0 : i)
            push!(ex[], isnan(e) ? 0.0 : e)
        end
        notify(reactance_centers)
        notify(reactance_rads)
        notify(ix)
        notify(ex)
    end
    on(update_X_arcs, XL) #onany(XL, zoomlevel) do xl, zoom ...
    update_X_arcs(XL[])

    # This lines are always drawn
    for z in (-0.2, 0.2, -0.4, 0.4, -0.6, 0.6, -1.0, 1.0, -2.0, 2.0, -5.0, 5.0, -10.0, 10.0, -20.0, 20.0)
        center, rad = reactance_arcs(z)
        x = circles_intersection(Point2f(0.0), center, 1.0, rad)
        angulo_inicio = atan(x[1][2] - center[2], x[1][1] - center[1])
        angulo_fin = atan(x[2][2] - center[2], x[2][1] - center[1])
        if angulo_inicio > angulo_fin
            angulo_inicio = angulo_inicio - 2 * pi
        end
        cond_cuadrant = center[2] < 0
        text_center = cond_cuadrant ? x[2] : x[1]
        center_angle = atan(text_center[2], text_center[1])
        #text_rot = cond_cuadrant ? atan(text_center[2], text_center[1]) + pi/2 : atan(text_center[2], text_center[1]) - pi/2
        text_rot = 0
        desp_mag = 0.1
        new_center = Point2f(text_center[1] + desp_mag * cos(center_angle), text_center[2] + desp_mag * sin(center_angle))
        txt = text!(textval(z, true), position=new_center, align=(:center, :center), fontsize=12, offset=(0, 0), rotation=text_rot, visible=exterior_markers) # Ajustar offset según sea necesario 
        translate!(txt, 0, 0, 1)
        ie = @lift $cutfunction(z, center, rad, $zoomlevel, false)
        i = lift(c -> c[1], ie)
        e = lift(c -> c[2], ie)
        arcline = arc!(center, rad, i, e, color=grid_color, linestyle=:solid, linewidth=lwgrid, visible=grid, inspectable=false)
        translate!(arcline, 0, 0, -5)
    end

    # DASHED REACTANCES
    for z in (-0.1, 0.1, -0.2, 0.2, -0.3, 0.3, -0.4, 0.4, -0.6, 0.6, -0.8, 0.8, 0.6, -1.0, 1.0, -1.25, 1.25, -1.5, 1.5, -3.5, 3.5, -7.5, 7.5)
        center, rad = reactance_arcs(z)
        ie = @lift $cutfunction(z, center, rad, $zoomlevel, false, true)
        i = lift(c -> c[1], ie)
        e = lift(c -> c[2], ie)
        arcline = arc!(center, rad, i, e, color=grid_color, linestyle=:dash, linewidth=lwgrid, visible=subgrid, inspectable=false)
        translate!(arcline, 0, 0, -5)
    end

    for i in 1:2*n_grid_arcs[]
        center = lift(c -> c[i], reactance_centers)
        rad = lift(c -> c[i], reactance_rads)
        zl = lift(c -> c[i], XL)
        ix_ = lift(c -> c[i], ix)
        ex_ = lift(c -> c[i], ex)
        style = :dash
        arcline = arc!(center, rad, ix_, ex_, color=grid_color, linestyle=style, linewidth=lwgrid, visible=subgrid, inspectable=false)
        translate!(arcline, 0, 0, -5)
    end

    # Exterior mask
    c_shape = circular_shape()
    r_shape = rectangular_shape()
    outer_shape = Polygon(r_shape, [c_shape])
    polc = poly!(c_shape, color=background, visible=true, inspectable=false)
    translate!(polc, 0, 0, -10)
    pol = poly!(outer_shape, color=background, visible=true, inspectable=false)
    translate!(pol, 0, 0, -1)
    # Draw exterior circle
    arc!(chart, Point2f(0), 1, -π, π, linewidth=4, color=:black, inspectable=false)
    hline = hlines!(0.0, 0.5, 0.75, linewidth=2.7, color=:black, inspectable=false)
    translate!(hline, 0, 0, -3)

    return chart
end



"""
    drawsmithchart(z; kwargs...)

Draw the Smith Chart and applies the functions

```
    fig = Figure(s)
    ax = Axis(fig[1, 1], aspect=1, limits=(-1.2, 1.2, -1.2, 1.2))
    hidedecorations!(ax)
    hidespines!(ax)
    interactivity_smithchart(ax)
```

# Valid Keywords:

- `size = (800,600) ` sets the size of the Figure.
- `background=:white` sets color of the background.
- `grid_color=:black` sets the color of the grid lines.
- `grid_width=0.7` sets width of the grid lines in pixel units.
- `grid=true` controls de visibility of the grid.
- `limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` 
- `prev_limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` internally used observable.
- `text_markers=true` control the visibility of the text annotations on the horizontal line.
- `exterior_markers=true` control the visibility of the text annotations around the Smith Chart.
- `n_grid_arcs=27` control de maximum number of grid arcs. Should not be changed.
- `cutgrid=false` controls the cut of the lines.
- `subgrid=false` controls if the grid is updated while zooming.
- `zoomupdate=true` controls the interactive `subgrid` update while zooming. 
- `textupdate=false` controls the interactive text annotations. When `true` the annotations appears in the image.

"""
function drawsmithchart(; args...)
    if haskey(args, :size)
        s = args[:size]
    else
        s = (800, 600)
    end
    fig = Figure(s)
    ax = Axis(fig[1, 1], aspect=1, limits=(-1.2, 1.2, -1.2, 1.2))
    smithchart!(ax; args...)
    hidedecorations!(ax)
    hidespines!(ax)
    interactivity_smithchart(ax)
    return fig, ax
end


"""
    smithchart(z; kwargs...)

Draw the Smith Chart and applies the functions

```
    hidedecorations!(ax)
    hidespines!(ax)
    interactivity_smithchart(ax)
```

# Valid Keywords:

- `background=:white` sets color of the background.
- `grid_color=:black` sets the color of the grid lines.
- `grid_width=0.7` sets width of the grid lines in pixel units.
- `grid=true` controls de visibility of the grid.
- `limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` 
- `prev_limits=Rect2f(-1.2, -1.2, 2.4, 2.4)` internally used observable.
- `text_markers=true` control the visibility of the text annotations on the horizontal line.
- `exterior_markers=true` control the visibility of the text annotations around the Smith Chart.
- `n_grid_arcs=27` control de maximum number of grid arcs. Should not be changed.
- `cutgrid=false` controls the cut of the lines.
- `subgrid=false` controls if the grid is updated while zooming.
- `zoomupdate=true` controls the interactive `subgrid` update while zooming. 
- `textupdate=false` controls the interactive text annotations. When `true` the annotations appears in the image.
"""
function drawsmithchart!(x; args...)
    if x isa GridPosition
        ax = Axis(x, aspect=1, limits=(-1.2, 1.2, -1.2, 1.2))
        smithchart!(ax; args...)
        hidedecorations!(ax)
        hidespines!(ax)
        interactivity_smithchart(ax)
        return ax
    elseif x isa Axis
        smithchart!(x; args...)
        hidedecorations!(x)
        hidespines!(x)
        interactivity_smithchart(x)
        return x
    else
        @error "argument must be an Axis or GridPosition"
    end
end
