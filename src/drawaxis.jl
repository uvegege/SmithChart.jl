#TODO: MUY IMPORTANTE: PARA QUE CALCULO INTERSECCIONES CUANDO PUEDO SABER LOS VALORES CON COORDS_TO_Z DIRECTAMENTE?
#TODO: AL FINAL LOS ARCOS SON CONSTANTES, NO ES TAN COMPLEJO


function draw_axis!(sc::SmithAxis)

    clipcolor = map(sc.blockscene, sc.clipcolor, sc.backgroundcolor) do cc, bgc
        return cc === automatic ? RGBf(to_color(bgc)) : RGBf(to_color(cc))
    end

    clipcolorint = map(sc.blockscene, sc.clipcolor, sc.backgroundcolorint) do cc, bgc
        return cc === automatic ? RGBf(to_color(bgc)) : RGBf(to_color(cc))
    end

    onany(sc.blockscene, sc.gridcolor, sc.zgridcolor, sc.ygridcolor) do gc, zgc, ygc
        zcolor = isnothing(gc) ? zgc : gc
        ycolor = isnothing(gc) ? ygc : gc
        if !isnothing(zcolor)
            sc.rgridcolor[] = zcolor
            sc.rsubgridcolor[] = zcolor
            sc.xgridcolor[] = zcolor
            sc.xsubgridcolor[] = zcolor
        end
        if !isnothing(ycolor)
            sc.ggridcolor[] = ycolor
            sc.gsubgridcolor[] = ycolor
            sc.bgridcolor[] = ycolor
            sc.bsubgridcolor[] = ycolor
        end
        return
    end

    sc.gridcolor[] = sc.gridcolor[]


    onany(sc.blockscene, sc.rvals, sc.xvals, sc.threshold, sc.zoomlevel) do rticks, xticks, th, _
        thr, thx = th
        sc.xcutvals[] = set_Xcut(rticks, xticks, thx/1000, sc.targetlimits[])
        sc.rcutvals[] = set_Rcut(rticks, xticks, thr/1000, sc.targetlimits[])
    end

    sc.rvals[] = sc.xvals[]
    sc.rvals[] = sc.xvals[]
    
    #TODO: Maybe use a vector with more elements for zvals so you can add more elements
    LSType = typeof(LineString(Point2f[]))

    # 2. Resistance (R) arcs
    rgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.rvals, sc.sample_density, sc.type, sc.rcutvals) do cgrid, zlevel, zvals, density, smtype, cuts
        arc_grid_points!(rgridpoints, cgrid, zlevel, zvals, density, smtype, zvals, cuts; impedance = true, realpart = true)
    end

    # 2.1 Resistance (R) text
    rtick_pos_lbl = Observable{Vector{<:Tuple{Any, Point2f}}}()
    onany(sc.blockscene, sc.blockscene, sc.rvals, sc.type) do zvals, smtype
        interior_arcs_txt!(rtick_pos_lbl, zvals, smtype; impedance = true)
    end

    # 3. Reactance (X) arcs. 
    xgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.xvals, sc.sample_density, sc.type, sc.xcutvals) do cgrid, zlevel, zvals, density, smtype, cuts
        arc_grid_points!(xgridpoints, cgrid, zlevel, zvals, density, smtype, zvals, cuts; impedance = true, realpart = false)
    end

    # 3.1 Reactance (X) text
    xtick_pos_lbl = Observable{Vector{<:Tuple{Any, Point2f}}}()
    xtick_pos_offset = Observable{Vector{Point2f}}()
    onany(sc.blockscene, sc.xvals, sc.xticklabelpad, sc.xticklabelsize, sc.type) do zvals, pad, labelsize, smtype
        exterior_arcs_txt!(xtick_pos_lbl, xtick_pos_offset, zvals, smtype, pad, labelsize; impedance = true)
    end

    # 4. g (G) arcs.
    ggridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.gvals, sc.sample_density, sc.type, sc.rcutvals) do cgrid, zlevel, zvals, density, smtype, cuts
        arc_grid_points!(ggridpoints, cgrid, zlevel, zvals, density, smtype, zvals, cuts; impedance = false, realpart = true)
    end

    # 4.1 g (G) text.
    gtick_pos_lbl = Observable{Vector{<:Tuple{Any, Point2f}}}()
    onany(sc.blockscene, sc.gvals, sc.type) do zvals, smtype
        interior_arcs_txt!(gtick_pos_lbl, zvals, smtype; impedance = false)
    end

    # 5. Susceptance (B) arcs.
    bgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.bvals, sc.sample_density, sc.type, sc.xcutvals) do cgrid, zlevel, zvals, density, smtype, cuts
        arc_grid_points!(bgridpoints, cgrid, zlevel, zvals, density, smtype, zvals, cuts; impedance = false, realpart = false)
    end

    # 5.1 Susceptance (B) text.
    btick_pos_lbl = Observable{Vector{<:Tuple{Any, Point2f}}}()
    btick_pos_offset = Observable{Vector{Point2f}}()
    onany(sc.blockscene, sc.blockscene, sc.bvals, sc.bticklabelpad, sc.bticklabelsize, sc.type) do zvals, pad, labelsize, smtype
        exterior_arcs_txt!(btick_pos_lbl, btick_pos_offset, zvals, smtype, pad, labelsize; impedance = false)
    end

    # Plot using created observables
    sc.zoomlevel[] = sc.zoomlevel[] #TODO: Temporal

    rgridlines = lines!(sc.overlay, rgridpoints, color = sc.rgridcolor,
        linewidth = sc.rgridwidth, linestyle = sc.rgridstyle,
        visible = sc.rgridvisible, inspectable = false)

    xgridlines = lines!(sc.overlay, xgridpoints, color = sc.xgridcolor,
        linewidth = sc.xgridwidth, linestyle = sc.xgridstyle,
        visible = sc.xgridvisible, inspectable = false)

    ggridlines = lines!(sc.overlay, ggridpoints, color = sc.ggridcolor, 
        linewidth = sc.ggridwidth, linestyle = sc.ggridstyle,
        visible = sc.ggridvisible, inspectable = false)

    bgridlines = lines!(sc.overlay, bgridpoints, color = sc.bgridcolor, 
        linewidth = sc.bgridwidth, linestyle = sc.bgridstyle,
        visible = sc.bgridvisible, inspectable = false)

    # PLOT ALL TEXT
    rstrokecolor = map(sc.blockscene, clipcolor, sc.rticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end

    sc.rvals[] = sc.rvals[] 
    sc.xvals[] = sc.xvals[] 
    sc.gvals[] = sc.gvals[] 
    sc.bvals[] = sc.bvals[] 

    rticklabelplot = text!(
        sc.overlay, rtick_pos_lbl; fontsize = sc.rticklabelsize, 
        font = sc.rticklabelfont, color = sc.rticklabelcolor,
        strokewidth = sc.rticklabelstrokewidth, strokecolor = rstrokecolor, align = sc.tickalign,
        rotation = sc.rtickangle, visible = lift((a,c) -> a & !c, sc.rtickvisible, sc.textupdate),
         inspectable = false
    )

    rticklabelsct = scatter!(
        sc.overlay, @lift(getindex.($rtick_pos_lbl, 2)); marker = :rect, markersize = @lift(2 * $(sc.rticklabelsize)), 
        color = sc.backgroundcolorint, 
        visible = lift((a,b,c) -> a & b & !c, sc.rtickvisible, sc.tickbox , sc.textupdate), inspectable = false
    )

    xstrokecolor = map(sc.blockscene, clipcolor, sc.xticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end

    xticklabelplot = text!(
        sc.overlay, xtick_pos_lbl; fontsize = sc.xticklabelsize,
        font = sc.xticklabelfont, color = sc.xticklabelcolor, 
        strokewidth = sc.xticklabelstrokewidth, strokecolor = xstrokecolor,
        offset = xtick_pos_offset, visible = sc.xtickvisible, inspectable = false
    )

    gstrokecolor = map(sc.blockscene, clipcolor, sc.gticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end

    gticklabelplot = text!(
        sc.overlay, gtick_pos_lbl; fontsize = sc.gticklabelsize, 
        font = sc.gticklabelfont, color = sc.gticklabelcolor, 
        strokewidth = sc.gticklabelstrokewidth, strokecolor = gstrokecolor, align = sc.tickalign,
        rotation = sc.gtickangle, visible = lift((a,c) -> a & !c, sc.gtickvisible, sc.textupdate),
        inspectable = false
    )

    gticklabelsct= scatter!(
        sc.overlay, @lift(getindex.($gtick_pos_lbl, 2)); marker = :rect, markersize = @lift(2 * $(sc.gticklabelsize)), 
        color = sc.backgroundcolorint,
        visible = lift((a,b,c) -> a & b & !c, sc.gtickvisible, sc.tickbox , sc.textupdate), inspectable = false
    )

    bstrokecolor = map(sc.blockscene, clipcolor, sc.bticklabelstrokecolor) do bg, sc
        sc === automatic ? bg : to_color(sc)
    end

    bticklabelplot = text!(
        sc.overlay, btick_pos_lbl; fontsize = sc.bticklabelsize,
        font = sc.bticklabelfont, color = sc.bticklabelcolor,
        strokewidth = sc.bticklabelstrokewidth, strokecolor = bstrokecolor,
        offset = btick_pos_offset, visible = sc.btickvisible, inspectable = false
    )

    translate!.((xticklabelplot, bticklabelplot), 0, 0, 9000)
    translate!.((rticklabelplot, gticklabelplot), 0, 0, -1)
    translate!.((rticklabelsct, gticklabelsct), 0, 0, -2)

    # 2. SUBGRID
    rsubgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.rvals, sc.splitminor, sc.splitgrid,
        sc.sample_density, sc.type, sc.rcutvals) do cgrid, zlevel, zvals, sminor, splitv, density, smtype, cuts
            if zlevel < 1
                if sminor > 0
                    vals = create_subgrid(zvals, sminor)
                else
                    vals = [[NaN for _ in 1:sminor*length(zvals)]]
                end
            else
                vals = reduce(vcat, splitintervals(createintervals(zvals), splitv))
            end
            arc_grid_points!(rsubgridpoints, cgrid, zlevel, vals, density, smtype, zvals, cuts; impedance = true, realpart = true, subgrid = true)
        end

    xsubgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.xvals, sc.splitminor, sc.splitgrid,
        sc.sample_density, sc.type, sc.xcutvals) do cgrid, zlevel, zvals, sminor, splitv, density, smtype, cuts
            if zlevel < 1
                if sminor > 0
                    vals = create_subgrid(zvals, sminor)
                else
                    vals = [[NaN for _ in 1:sminor*length(zvals)]]
                end
            else
                vals = reduce(vcat, splitintervals(createintervals(zvals), splitv))
            end
            arc_grid_points!(xsubgridpoints, cgrid, zlevel, vals, density, smtype, zvals, cuts; impedance = true, realpart = false, subgrid = true)
        end

    gsubgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.gvals, sc.splitminor, sc.splitgrid,
        sc.sample_density, sc.type, sc.rcutvals) do cgrid, zlevel, zvals, sminor, splitv, density, smtype, cuts
            if zlevel < 1
                if sminor > 0
                    vals = create_subgrid(zvals, sminor)
                else
                    vals = [[NaN for _ in 1:sminor*length(zvals)]]
                end
            else
                vals = reduce(vcat, splitintervals(createintervals(zvals), splitv))
            end
            arc_grid_points!(gsubgridpoints, cgrid, zlevel, vals, density, smtype, zvals, cuts; impedance = false, realpart = true, subgrid = true)
        end

    bsubgridpoints = Observable{Vector{LSType}}()
    onany(sc.blockscene, sc.cutgrid, sc.zoomlevel, sc.bvals, sc.splitminor, sc.splitgrid,
        sc.sample_density, sc.type, sc.xcutvals) do cgrid, zlevel, zvals, sminor, splitv, density, smtype, cuts
            if zlevel < 1
                if sminor > 0
                    vals = create_subgrid(zvals, sminor)
                else
                    vals = [[NaN for _ in 1:sminor*length(zvals)]]
                end
            else
                vals = reduce(vcat, splitintervals(createintervals(zvals), splitv))
            end
            arc_grid_points!(bsubgridpoints, cgrid, zlevel, vals, density, smtype, zvals, cuts; impedance = false, realpart = false, subgrid = true)
        end

    sc.zoomlevel[] = sc.zoomlevel[]
       
    rsubgridlines = lines!(sc.overlay, rsubgridpoints, color = sc.rsubgridcolor,
        linewidth = sc.rsubgridwidth, linestyle = sc.rsubgridstyle,
        visible = sc.subgrid, inspectable = false)

    xsubgridlines = lines!(sc.overlay, xsubgridpoints, color = sc.xsubgridcolor,
        linewidth = sc.xsubgridwidth, linestyle = sc.xsubgridstyle,
        visible = sc.subgrid, inspectable = false)

    gsubgridlines = lines!(sc.overlay, gsubgridpoints, color = sc.gsubgridcolor,
        linewidth = sc.gsubgridwidth, linestyle = sc.gsubgridstyle,
        visible = sc.subgrid, inspectable = false) 

    bsubgridlines = lines!(sc.overlay, bsubgridpoints, color = sc.bsubgridcolor,
        linewidth = sc.bsubgridwidth, linestyle = sc.bsubgridstyle,
        visible = sc.subgrid, inspectable = false) 
     
        
    # SHIFT GRID AND SUBGRID LINES

    translate!.((rgridlines, xgridlines, ggridlines, bgridlines, rsubgridlines, 
        xsubgridlines, gsubgridlines, bsubgridlines), 0, 0, -50)

    on(sc.blockscene, sc.rgridz) do depth
        translate!(rgridlines, 0, 0, depth)
        translate!(rsubgridlines, 0, 0, depth)
    end
    notify(sc.rgridz)

    on(sc.blockscene, sc.xgridz) do depth
        translate!(xgridlines, 0, 0, depth)
        translate!(xsubgridlines, 0, 0, depth)
    end
    notify(sc.xgridz)

    on(sc.blockscene, sc.ggridz) do depth
        translate!(ggridlines, 0, 0, depth)
        translate!(gsubgridlines, 0, 0, depth)
    end
    notify(sc.ggridz)

    on(sc.blockscene, sc.bgridz) do depth
        translate!(bgridlines, 0, 0, depth)
        translate!(bsubgridlines, 0, 0, depth)
    end
    notify(sc.bgridz)

    # PLOT CLIPPING

    c_shape = circular_shape(361) #TODO: Use sc.sample_density
    r_shape = rectangular_shape()
    outer_shape = Polygon(r_shape, [c_shape])
    inner_clip_plot = poly!(sc.overlay, c_shape, color = clipcolorint, visible = sc.clip, fxaa = false, transformation = Transformation(), shading = NoShading, inspectable = false)
    translate!(inner_clip_plot, 0, 0, -100.0)
    outer_clip_plot = poly!(sc.overlay, outer_shape, color = clipcolor, visible = sc.clip, fxaa = false, transformation = Transformation(), shading = NoShading, inspectable = false)
    translate!(outer_clip_plot, 0, 0, 9000.0)

    on(sc.blockscene, sc.innerclipz) do depth
        translate!(inner_clip_plot, 0, 0, depth)
    end
    notify(sc.innerclipz)

    on(sc.blockscene, sc.outerclipz) do depth
        translate!(outer_clip_plot, 0, 0, depth)
    end
    notify(sc.outerclipz)

    # CHANGE AND ADD TEXT WHEN MOVING ON THE SCENE WHEN textupdate = true
    
    r_label_pos = Observable{Vector{<:Tuple{Any, Point2f}}}(Tuple{Any, Point2f}[])
    x_label_pos = Observable{Vector{<:Tuple{Any, Point2f}}}(Tuple{Any, Point2f}[])
    
    onany(sc.blockscene, sc.targetlimits, sc.zoomlevel, sc.zoomupdate, sc.subgrid, sc.textupdate, sc.ntextvals, sc.type, sc.rvals, sc.xvals, sc.rcutvals, sc.xcutvals) do args...
        calculate_textposition(r_label_pos, x_label_pos, args...)
        notify(r_label_pos)
        notify(x_label_pos)
    end
    sc.targetlimits[] = sc.targetlimits[]

    rlabelplot = text!(
        sc.overlay, r_label_pos; fontsize = sc.rticklabelsize, 
        font = sc.rticklabelfont, color = sc.rticklabelcolor,
        strokewidth = sc.rticklabelstrokewidth, strokecolor = rstrokecolor, align = sc.tickalign,
        rotation = sc.rtickangle, visible = sc.textupdate, inspectable = false
    )

    rlabelsct= scatter!(
        sc.overlay, @lift(getindex.($r_label_pos, 2)); marker = :rect, markersize = @lift(2 * $(sc.rticklabelsize)), 
        color = sc.backgroundcolorint,
        visible = @lift( $(sc.textupdate) & $(sc.tickbox)), inspectable = false
    )

    xlabelplot = text!(
        sc.overlay, x_label_pos; fontsize = sc.rticklabelsize, 
        font = sc.rticklabelfont, color = sc.rticklabelcolor,
        strokewidth = sc.rticklabelstrokewidth, strokecolor = rstrokecolor, align = sc.tickalign,
        rotation = sc.rtickangle, visible = sc.textupdate, inspectable = false
    )

    xlabelsct= scatter!(
        sc.overlay, @lift(getindex.($x_label_pos, 2)); marker = :rect, markersize = @lift(2 * $(sc.rticklabelsize)), 
        color = sc.backgroundcolorint, 
        visible = @lift( $(sc.textupdate) & $(sc.tickbox)), inspectable = false
    )

    translate!.((rlabelplot, xlabelplot), 0, 0, -2)
    translate!.((rlabelsct, xlabelsct), 0, 0, -1)

    # PLOT SPINE

    spineplot = arc!(sc.overlay, Point2f(0.0), 1.0, -pi, pi, resolution = sc.sample_density, 
        color = sc.spinecolor,
        linewidth = sc.spinewidth,
        linestyle = sc.spinestyle,
        visible = sc.spinevisible,
        inspectable = false)
    translate!(spineplot, 0, 0, 9001)
    on(sc.blockscene, sc.spinez) do depth
        translate!(spineplot, 0, 0, depth)
    end

    spineline = lines!(sc.overlay, [Point2f(-1.0, 0.0), Point2f(1.0, 0.0)], 
    color = sc.spinecolor,
    linewidth = sc.spinehorizontalwidth,
    linestyle = sc.spinestyle,
    visible = sc.spinevisible,
    inspectable = false)
    translate!(spineline, 0, 0, -5)
    #on(sc.blockscene, sc.spinez) do depth
    #    translate!(spineline, 0, 0, depth)
    #end
    #notify(sc.spinez)

    return
end


function interior_arcs_txt!(tick_pos_lbl, zvals, smtype; impedance = true)
    scomp = impedance == true ? :Y : :Z
    if smtype == scomp
        tick_pos_lbl[] = [("", Point2f(NaN)) for _ in 1:length(zvals)]
    else
        labels = textval.(zvals, false)
        sgn = impedance ? 1.0 : -1.0
        tick_pos_lbl[] = tuple.(labels, Point2f.(sgn * R_to_u.(zvals), 0.0))
    end
    return nothing
end

function exterior_arcs_txt!(tick_pos_lbl, tick_pos_offset, zvals, smtype, pad, labelsize; impedance = true)
    scomp = impedance == true ? :Y : :Z
    if smtype == scomp
        tick_pos_lbl[] = [("", Point2f(NaN)) for _ in 1:(2*length(zvals)+1)]
        tick_pos_offset[] = [Point2f(0.0) for _ in 1:(2*length(zvals)+1)]
    else
        sgn = impedance ? 1.0 : -1.0
        labels = [textval.(zvals, true); textval.(-zvals, true)]
        #ps = smith_transform.(Complex.(0.0,  [zvals, -zvals]))
        xs = X_to_u.(zvals)
        ys = @. sqrt(1-xs^2) 
        ys *= impedance == true ? 1 : -1 
        ys = [ys; -ys] 
        xs = repeat(xs, 2)
        push!(xs, -1.0)
        push!(ys, 0.0)
        push!(labels, "0")
        ps = Point2f.(sgn * xs, ys)
        direction = atan.(ys, xs)
        sico = sincos.(direction)
        xextra = map(length.(labels), ps) do l, x
            return x[1] < 0 ? l+2  : 0
        end
        yextra = map(length.(labels), ys) do l, y
            return y < 0 ? labelsize : 0
        end
        tick_pos_offset[] = map((x, e, ye) -> Point2f(sgn*pad*(1+e)*x[2], pad*x[1]-ye), sico, xextra, yextra)
        tick_pos_lbl[] = tuple.(labels, ps)
    end
    return nothing
end



function arc_grid_points!(gridpoints, cgrid, zlevel, zvals, density, smtype, ticks, cuts; impedance = true, realpart = true, subgrid = false)
    
    cmpsymbol = impedance == true ? :Z : :Y
    lenfactor = realpart == true ? 1 : 2
    
    if !((smtype == cmpsymbol) | (smtype == :ZY))
        gridpoints[] = LineString.([[Point2f(NaN), Point2f(NaN)] for _ in 1:lenfactor*length(zvals)])
        return 
    end    

    if impedance == true
        reversed = 1.0
    else
        reversed = -1.0
    end

    if realpart == true
        ie_flag = true
        centerandrads = resistance_arcs.(zvals)
    else
        zvals = [zvals; -zvals]
        ticks = [ticks; ticks]
        cuts = [cuts; cuts]
        ie_flag = false
        centerandrads = reactance_arcs.(zvals)
    end

    if cgrid == false
        angles = [LinRange(-pi, pi, density) for _ in 1:length(zvals)]
    else
        ie = map(x -> start_end_angles(x, ticks, cuts; resistance = ie_flag, subgrid = subgrid), zvals)
        angles = [LinRange(i, e, density) for (i, e) in ie]
    end

    gridpoints[] = LineString.([Point2f.(reversed*(c[1] .+ r * cos.(th)), c[2] .+ r * sin.(th)) for ((c, r), th) in zip(centerandrads, angles)])

    return 
end