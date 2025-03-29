Makie.interactions(sc::SmithAxis) = sc.interactions

function register_events!(sc::SmithAxis, scene)
    mouseeventhandle = addmouseevents!(scene)
    setfield!(sc, :mouseeventhandle, mouseeventhandle)
    scrollevents = Observable(ScrollEvent(0, 0))
    setfield!(sc, :scrollevents, scrollevents)
    keysevents = Observable(KeysEvent(Set()))
    setfield!(sc, :keysevents, keysevents)
    evs = events(scene)

    on(scene, evs.scroll) do s
        if is_mouseinside(scene)
            result = setindex!(scrollevents, ScrollEvent(s[1], s[2]))
            return Consume(result)
        end
        return Consume(false)
    end

    # TODO this should probably just forward KeyEvent from Makie
    on(scene, evs.keyboardbutton) do e
        keysevents[] = KeysEvent(evs.keyboardstate)
        return Consume(false)
    end

    interactions = Dict{Symbol, Tuple{Bool, Any}}()
    setfield!(sc, :interactions, interactions)

    onany(process_smithchart_event, scene, sc, mouseeventhandle.obs)
    onany(process_smithchart_event, scene, sc, scrollevents)
    onany(process_smithchart_event, scene, sc, keysevents)

    #register_interaction!(sc, :rectanglezoom, RectangleZoom(sc))
    register_interaction!(sc, :limitreset, LimitReset())
    register_interaction!(sc, :scrollzoom, ScrollZoom(0.1, 0.2))
    register_interaction!(sc, :dragpan, DragPan(0.2))

    return
end


function process_smithchart_event(sc, event)
    sc.scene.visible[] || return Consume(false)
    for (active, interaction) in values(sc.interactions)
        if active
            maybe_consume = Makie.process_interaction(interaction, event, sc)
            maybe_consume == Consume(true) && return Consume(true)
        end
    end
    return Consume(false)
end


function Makie.process_interaction(dp::DragPan, event::MouseEvent, sc::SmithAxis)

    if event.type !== MouseEventTypes.rightdrag
        return Consume(false)
    end

    tlimits = sc.targetlimits
    xpanlock = sc.xpanlock
    ypanlock = sc.ypanlock
    xpankey = sc.xpankey
    ypankey = sc.ypankey

    wx, wy = widths(tlimits[])

    #sclimits = scdefaultlimits(sc.limits[])
    sclimits = Makie.BBox(-1.5, 1.5, -1.5, 1.5)
    scene = sc.scene
    cam = camera(scene)
    pa = viewport(scene)[]

    mp_axscene = Vec4f((event.px .- pa.origin)..., 0, 1)
    mp_axscene_prev = Vec4f((event.prev_px .- pa.origin)..., 0, 1)

    mp_axfraction, mp_axfraction_prev = map((mp_axscene, mp_axscene_prev)) do mp
        # first to normal -1..1 space
        (cam.pixel_space[]*mp)[Vec(1, 2)] .*
        # now to 1..-1 if an axis is reversed to correct zoom point
        (-2 .* ((sc.xreversed[], sc.yreversed[])) .+ 1) .*
        # now to 0..1
        0.5 .+ 0.5
    end

    movement_frac = mp_axfraction .- mp_axfraction_prev

    xori, yori = tlimits[].origin .- movement_frac .* widths(tlimits[])

    # Check 4 points
    !in(Point2f(xori, yori), sclimits) && return Consume(true)
    !in(Point2f(xori + wx, yori), sclimits) && return Consume(true)
    !in(Point2f(xori, yori + wy), sclimits) && return Consume(true)
    !in(Point2f(xori + wx, yori + wy), sclimits) && return Consume(true)

    if xpanlock[] || ispressed(scene, ypankey[])
        xori = tlimits[].origin[1]
    end

    if ypanlock[] || ispressed(scene, xpankey[])
        yori = tlimits[].origin[2]
    end

    #Makie.timed_ticklabelspace_reset(sc, dp.reset_timer, dp.prev_xticklabelspace, dp.prev_yticklabelspace, dp.reset_delay)
    newrect_trans = Rectf(Vec2(xori, yori), widths(tlimits[]))
    tlimits[] = newrect_trans

    return Consume(true)
end


function Makie.process_interaction(s::ScrollZoom, event::ScrollEvent, sc::SmithAxis)
    # use vertical zoom
    zoom = event.y

    tlimits = sc.targetlimits
    xzoomlock = sc.xzoomlock
    yzoomlock = sc.yzoomlock
    xzoomkey = sc.xzoomkey
    yzoomkey = sc.yzoomkey

    scene = sc.scene
    e = events(scene)
    cam = camera(scene)

    ispressed(scene, sc.zoombutton[]) || return Consume(false)

    if zoom != 0
        pa = viewport(scene)[]

        z = (1.0 - s.speed)^zoom

        mp_axscene = Vec4f((e.mouseposition[] .- pa.origin)..., 0, 1)

        # first to normal -1..1 space
        mp_axfraction =  (cam.pixel_space[] * mp_axscene)[Vec(1, 2)] .*
            # now to 1..-1 if an axis is reversed to correct zoom point
            (-2 .* ((sc.xreversed[], sc.yreversed[])) .+ 1) .*
            # now to 0..1
            0.5 .+ 0.5

        tlimits_trans = tlimits[]

        xorigin = tlimits_trans.origin[1]
        yorigin = tlimits_trans.origin[2]

        xwidth = tlimits_trans.widths[1]
        ywidth = tlimits_trans.widths[2]

        newxwidth = xzoomlock[] ? xwidth : xwidth * z
        newywidth = yzoomlock[] ? ywidth : ywidth * z

        newxorigin = xzoomlock[] ? xorigin : xorigin + mp_axfraction[1] * (xwidth - newxwidth)
        newyorigin = yzoomlock[] ? yorigin : yorigin + mp_axfraction[2] * (ywidth - newywidth)

        #sclimits = scdefaultlimits(sc.limits[])
        sclimits = Makie.BBox(-1.5, 1.5, -1.5, 1.5)
        #sclimits = Rect2f(-1.2, 2.4, -1.2, 2.4) #TODO: change this
        ox, oy = sclimits.origin
        wx, wy = widths(sclimits)

        if (newxorigin + newxwidth > ox+wx || newxorigin < ox || newyorigin + newywidth > oy+wy || newyorigin < oy) && sign(zoom) == -1
            reset_limits!(sc)
            return Consume(true)
        end

        #Makie.timed_ticklabelspace_reset(sc, s.reset_timer, s.prev_xticklabelspace, s.prev_yticklabelspace, s.reset_delay)

        newrect_trans = if ispressed(scene, xzoomkey[])
            Rectf(newxorigin, yorigin, newxwidth, ywidth)
        elseif ispressed(scene, yzoomkey[])
            Rectf(xorigin, newyorigin, xwidth, newywidth)
        else
            Rectf(newxorigin, newyorigin, newxwidth, newywidth)
        end

        tlimits[] =  newrect_trans
    end

    return Consume(true)
end


function Makie.process_interaction(::LimitReset, event::MouseEvent, sc::SmithAxis)
    if event.type === MouseEventTypes.leftclick
        if ispressed(sc.scene, Keyboard.left_control)
            if ispressed(sc.scene, Keyboard.left_shift)
                autolimits!(sc)
            else
                reset_limits!(sc)
            end
            return Consume(true)
        end
    end
    return Consume(false)
end

function ztotext(zi, reflection, freq, idx)

    if reflection == true
        if imag(zi) < 0
            txt = @sprintf("Γ = %.3f - j%.3f", real(zi), abs(imag(zi)))
        else
            txt = @sprintf("Γ = %.3f + j%.3f", real(zi), abs(imag(zi)))
        end
    else
        if imag(zi) < 0
            txt = @sprintf("z = %.3f - j%.3f", real(zi), abs(imag(zi)))
        else
            txt = @sprintf("z = %.3f + j%.3f", real(zi), abs(imag(zi)))
        end
    end

    if !isempty(freq)
        f = freq[idx]
        ftext = f < 1.0e3 ? @sprintf("%.3f Hz", f) :
                f < 1.0e6 ? @sprintf("%.3f kHz", f/1.0e3) :
                f < 1.0e9 ? @sprintf("%.3f MHz", f/1.0e6) :
                f < 1.0e12 ? @sprintf("%.3f GHz", f/1.0e9) :
                @sprintf("%.3f THz", f/1.0e12)
        txt *= " f = " * ftext
    end
    return txt
end

#TODO: Dragg markers
#TODO: Associate markers to a specific plot.
#TODO: save marker's DATA
"""
    datamarkers(ax::SmithAxis, gp::GridPosition, priority = 100; fontsize = 10.0, title = true, kwargs...)

Allows creating data markers with DOUBLE CLICK on the lines or scatter plots.

- ax::SmithAxis is the `SmithAxis`.
- gp::GridPosition is a GridPosition. Example: fig[1,2]
- markerdict::Dict{Int, ComplexF64} is a Dict that stores the data of each marker. If you don't need
the values you can ignore this argument.

"""
function datamarkers(ax::SmithAxis, gp::GridPosition, markerdict = Dict{Int, ComplexF64}(), priority = 100; fontsize = 10.0, title = true, kwargs...)
    
    rowpos = gp.span.rows[end]
    colpos = gp.span.cols[end]
    lbl_txt = Observable("")
    gl = GridLayout(gp, tellwidth = false, aspect = 1, tellheight = false, halign = :center, valign = :center, protrusions = (0,0,0,0))
    Label(gl[0, 1], "Data Markers", fontsize = fontsize)
    Box(gl[1, 1], color = ax.scene.backgroundcolor, strokecolor = :black, strokewidth = 1)
    lbl = Label(gl[1, 1], lbl_txt, rotation = 0, padding = (10, 10, 10, 10), fontsize = fontsize)
    #colsize!(ax.parent.layout, colpos, Aspect(1, 0.5))
    #rowgap!(gl, 0)

    on(ax.temp_plots) do tplots
        l = length(tplots)
        i = 1
        lbl_txt.val = ""
        for (plt, txt) in tplots
            plt[2].val = string(i)
            notify(plt[2])
            lbl_txt.val *= "[$i]: " * txt * "\n"
            i = i + 1
        end

        sortedkeys = sort(collect(keys(markerdict)))
        for (id, k) in enumerate(sortedkeys)
            vk = markerdict[k]
            delete!(markerdict, k)
            markerdict[id] = vk
        end

        resize_to_layout!(ax.parent)
        notify(lbl_txt)
    end

    register_interaction!(ax, :doubleclickinteraction) do event::MouseEvent, ax
        if event.type === MouseEventTypes.leftdoubleclick
            plots = filter(ax.scene.plots) do p
                isa(p, SmithChart.SmithPlot) | isa(p, SmithChart.SmithScatter)
            end

            posvectors = map(plots) do p
                a = p.attributes
                zs = p[1][]
                if a.reflection[] == false
                    pos = (smith_transform.(zs), zs, a.reflection[], a.freq[])
                else
                    zs = p[1][]
                    pos = (Point2f.(real.(zs), imag.(zs)), zs, a.reflection[], a.freq[])
                end
                return pos
            end

            #position = events(ax.scene).mouseposition[]
            plt, idx = pick(ax.scene)
            if isa(plt, Makie.Scatter) | isa(plt, Makie.Lines)
                if to_value(get(plt.attributes, :inspectable, true)) 
                    id = 0
                    for (i, pv) in enumerate(posvectors)
                        if plt[1][][idx] in pv[1]
                            id = i
                        end
                    end
                    if id != 0
                        reflection = posvectors[id][3]
                        freq = posvectors[id][4]
                        zi = posvectors[id][2]
                        markerdict[length(keys(markerdict))+1] = zi[idx]
                        txt = ztotext(zi[idx], reflection, freq, idx)
                        tp = tooltip!(ax, Observable(plt[1][][idx]), string(length(ax.temp_plots.val) + 1), inspectable = true)
                        translate!(tp, 0, 0, 8000)
                        push!(ax.temp_plots.val, (tp, txt))
                        notify(ax.temp_plots)
                    end
                end
            else
                position = mouseposition_px(ax.scene)
                # Use tooltip's bounding box
                for (id, ttips) in enumerate(ax.temp_plots.val)
                    bb = boundingbox(ttips[1])
                    ox, oy, oz = bb.origin
                    wx, wy, wz = bb.widths
                    if (ox <= position[1] <= ox+wx) & (oy <= position[2] <= oy+wy)
                        delete!(ax, ax.temp_plots[][id][1])
                        popat!(ax.temp_plots[], id)
                        delete!(markerdict, id)
                        notify(ax.temp_plots)
                    end
                end
                return
            end
        end
    end
    return nothing
end