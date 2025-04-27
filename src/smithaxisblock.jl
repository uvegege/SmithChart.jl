function Makie.initialize_block!(sc::SmithAxis; palette=nothing)

    #setfield!(sc, :temp_plots, Observable(Tuple{Makie.Plot, String, Makie.Plot, Int64, Bool, Vector{<:Real}}[]) )
    setfield!(sc, :temp_plots, Observable([]))
    targetlimits = Observable{Rect2f}(scdefaultlimits(sc.limits[]))
    setfield!(sc, :targetlimits, targetlimits)
    
    # Scene
    cb = sc.layoutobservables.computedbbox
    scenearea = Makie.sceneareanode!(cb, sc.targetlimits, sc.aspect)

    sc.scene = Scene(
        sc.blockscene, scenearea, backgroundcolor = sc.backgroundcolor, clear = true
    )
    map!(to_color, sc.scene, sc.scene.backgroundcolor, sc.backgroundcolor)

    # Overlay
    sc.overlay = Scene(
        sc.scene, scenearea, clear = false, backgroundcolor = :transparent,
        transformation = Transformation(sc.scene, transform_func = identity)
    )

    if !isnothing(palette)
        # Backwards compatibility for when palette was part of axis!
        palette_attr = palette isa Attributes ? palette : Attributes(palette)
        sc.scene.theme.palette = palette_attr
    end

    setup_limits_and_camera!(sc)

    on(sc.targetlimits) do _
        update_zoomlevel(sc::SmithAxis)
    end

    # Register events
    register_events!(sc, sc.scene)

    #TODO: Do I need a custom Transformation? 
    # apply_transform(trans::mytransformation, point)...?

    # Draw clip, grid lines, spine, ticks
    draw_axis!(sc)

    # Set up the title position
    titlealignnode = lift(sc.blockscene, sc.titlealign; ignore_equal_values=true) do align
        (align, :bottom)
    end

    subtitlepos = lift(subtitle_position, sc.blockscene, sc.scene.viewport, sc.titlegap, sc.titlealign, sc.xticklabelpad,
        sc.xticklabelsize)

    subtitlet = text!(
        sc.blockscene, subtitlepos,
        text = sc.subtitle,
        visible = sc.subtitlevisible,
        fontsize = sc.subtitlesize,
        align = titlealignnode,
        font = sc.subtitlefont,
        color = sc.subtitlecolor,
        lineheight = sc.subtitlelineheight,
        markerspace = :data,
        inspectable = false)

    titlepos = lift(title_position, sc.blockscene, sc.scene.viewport, sc.titlegap, sc.subtitlegap,
        sc.titlealign, sc.xticklabelpad, sc.xticklabelsize, sc, subtitlet; ignore_equal_values=true)

    titleplot = text!(
        sc.blockscene,
        titlepos;
        text = sc.title,
        font = sc.titlefont,
        fontsize = sc.titlesize,
        color = sc.titlecolor,
        align = @lift(($(sc.titlealign), :bottom)),
        visible = sc.titlevisible,
    )
    translate!(titleplot, 0, 0, 9100) # Make sure this draws on top of clip

    # trigger bboxnode so the axis layouts
    notify(sc.layoutobservables.suggestedbbox)

    # trigger limit pipeline once
    tl = sc.targetlimits[]
    notify(sc.limits)
    if tl == sc.targetlimits[]
        notify(sc.targetlimits)
    end

    # Protrusions
    protrusions = map(
            sc.blockscene, sc.title, sc.titlegap, sc.titlesize, sc.subtitle, sc.subtitlegap, sc.subtitlesize
        ) do title, gap, size, subtitle, subgap, subsize
        titlespace = title == "" ? 0f0 : Float32(2gap + size)
        subtitlespace = subtitle == "" ? 0f0 : Float32(2subgap + subsize)
        return Makie.GridLayoutBase.RectSides(0f0, 0f0, 0f0, titlespace+subtitlespace)
    end
    connect!(sc.layoutobservables.protrusions, protrusions)

    return sc
end

function scdefaultlimits(limits)
    if length(limits) == 2
        xo = isnothing(limits[1]) ? -1.0 : limits[1][1]
        yo = isnothing(limits[2]) ? -1.0 : limits[2][1]
        xs = isnothing(limits[1]) ? 1.0 : limits[1][2]
        ys = isnothing(limits[2]) ? 1.0 : limits[2][2]
        return Makie.BBox(xo, xs,yo, ys) 
    elseif length(limits) == 4
        return Makie.BBox(limits...) 
    else
        return Makie.BBox(-1.0, 1.0, -1.0, 1.0) 
    end
end

# Simple reset_limits
function Makie.reset_limits!(sc::SmithAxis; xauto::Bool = false, yauto::Bool = false, zauto::Bool = false)
    limits = scdefaultlimits(sc.limits[])
    sc.targetlimits[] = limits
    nothing
end

function Makie.autolimits!(sc::SmithAxis)
    sc.limits[] = ((-1.0, 1.0), (-1.0, 1.0))
    return
end

function setup_limits_and_camera!(sc::SmithAxis)

    # these are the user defined limits
    on(sc.blockscene, sc.limits) do _
        reset_limits!(sc)
    end
    
    usable_fraction = Observable(Vec2f(1.0, 1.0))

    # Update the view onto the plot (camera matrices)
    onany(sc.blockscene, sc.targetlimits, sc.xreversed, sc.yreversed, usable_fraction; priority=-2) do args...
        update_smithchart_camera!(sc.scene, args...)
        update_smithchart_camera!(sc.overlay, args...)
    end

    onany(sc.blockscene, sc.scene.viewport,
        sc.xticklabelsize, sc.bticklabelsize, 
        sc.xtickvisible, sc.btickvisible,
        sc.xticklabelpad, sc.bticklabelpad) do area, xs, bs, xv, bv, xp, bp
        space_from_center = 0.5 .* widths(area)
        space_for_ticks = 2max(xp, bp) .+ max(23, 23)
        space_for_axis = space_from_center .- space_for_ticks
        # divide by width only because aspect ratios
        usable_fraction[] = space_for_axis ./ space_from_center[1]
    end

    return nothing
end


function update_smithchart_camera!(scene::Scene, lims, xrev::Bool, yrev::Bool, usable_fraction)
    nearclip = -10_000f0
    farclip  =  10_000f0

    # we are computing transformed camera position, so this isn't space dependent
    tlims = lims
    camera = scene.camera

    #update_limits!(scene.float32convert, tlims) # update float32 scaling
    lims32 = tlims
    left, bottom = minimum(lims32)
    right, top   = maximum(lims32)
    leftright = xrev ? (right, left) : (left, right)
    bottomtop = yrev ? (top, bottom) : (bottom, top)
    scale = minimum(usable_fraction) # In my case ws is always (2.0, 2.0)
    projection = Makie.orthographicprojection(
        Float32,
        leftright...,
        bottomtop..., nearclip, farclip)
 
    matrixp = Makie.Mat4f(scale, 0, 0, 0, 
                            0, scale, 0, 0,
                            0,  0, 1, 0,
                            0,  0, 0, 1) 
    Makie.set_proj_view!(camera, projection, matrixp)
    return
end


function title_position(area, titlegap, subtitlegap, align, xticklabelsize, xticklabelpad, sc, subtitlet)
    w, h = widths(area)
    xtitle::Float32 = if align === :center
        area.origin[1] + w / 2
    elseif align === :left
        area.origin[1]
    elseif align === :right
        area.origin[1] + w
    elseif align isa Real
        area.origin[1] + align * w
    else
        error("Title align $align not supported.")
    end

    local subtitlespace::Float32 = if sc.subtitlevisible[] && !Makie.iswhitespace(sc.subtitle[])
        boundingbox(subtitlet).widths[2] + subtitlegap
    else
        0f0
    end

    ytitle::Float32 = top(area) + titlegap + subtitlespace

    return Point2f(xtitle, ytitle)
end


function subtitle_position(a, titlegap, align, xticklabelsize, xticklabelpad)
    align_factor = Makie.halign2num(align, "Horizontal title align $align not supported.")
    xstitle = a.origin[1] + align_factor * a.widths[1]
    ystitle = top(a) + titlegap
    return Point2f(xstitle, ystitle)
end

# EXTEND get_plots and Legend for SmithAxis Type

Makie.get_plots(ax::SmithAxis) = Makie.get_plots(ax.scene)
function Makie.Legend(fig_or_scene, axis::SmithAxis, title = nothing; merge = false, unique = false, kwargs...)
    plots, labels = Makie.get_labeled_plots(axis, merge = merge, unique = unique)
    isempty(plots) && error("There are no plots with labels in the given axis that can be put in the legend. Supply labels to plotting functions like `plot(args...; label = \"My label\")`")
    Legend(fig_or_scene, plots, labels, title; kwargs...)
end