
function move_textlabels(limits, zoomlevel, rtext, itext, vrtext, vitext, updatext ,nvals)
    !updatext && return
    empty!(rtext)
    empty!(itext)
    empty!(vrtext)
    empty!(vitext)
    ox, oy = limits.origin
    wx, wy = limits.widths
    xc, yc = ox+wx/2, oy+wy/2 # Center points
    center = Point2f(xc, yc)
    zl = coords_to_z(center...)
    rc = real(zl)
    ic = imag(zl)
    if zoomlevel == 0
        intervals = [0..0.2, 0.2..0.4, 0.4..0.6, 0.6..1.0, 1.0..2.0, 2.0..5.0, 5.0..20.0]
        values = map(x->x.right, intervals)
    elseif zoomlevel == 1
        intervals = [0..0.2, 0.2..0.4, 0.4..0.6, 0.6..1.0, 1.0..2.0, 2.0..5.0, 5.0..10.0, 10.0..20.0, 20.0..80]
        values = map(x->x.right, intervals)
    else #elseif zoomlevel > 2
        split_intervals = 3
        intervals = [0..0.2, 0.2..0.4, 0.4..0.6, 0.6..1.0, 1.0..2.0, 2.0..5.0, 5.0..10.0, 10.0..20.0, 20.0..80]
        splited_intervals = splitintervals(intervals, split_intervals)
        new_intervals = newintervals(splited_intervals, intervals)
        values = map(x->x.right, new_intervals)
    end

    # Find the closest REACTANCE/RESISTANCE curve to the center of the image

    crc = argmin(v->abs(v - rc), values)
    cic = argmin(v->abs(v - ic), vcat(values, -values))
    cic = abs(ic) < 0.2 ? 0.0 : cic

    #Resistance
    ref_center, ref_rad = reactance_arcs(cic)
    prev = Point2f(Inf)
    if cic == 0.0
        minR = max(0.0, real(coords_to_z(max(-1.0, ox), 0.0)))
        maxR = min(Inf, real(coords_to_z(min(0.999999, ox+wx), 0.0)))
    else
        minR, maxR =  0.0, Inf
    end
    valr = filter(v -> (minR <= v <= maxR) &  (abs(v) <= get_zcut(v, zoomlevel)) , values)
    lenv = length(valr)
    indices = lenv >= nvals ? round.(Int, range(1, lenv, nvals)) : eachindex(valr)

    for i in indices
        v = valr[i]
        if cic == 0.0
            push!(rtext, Point2f(R_to_u(v), 0.0))
            push!(vrtext, v)
        else
            center, rad = resistance_arcs(v)
            pr1, pr2 = circles_intersection(ref_center, center, ref_rad, rad)
            pr = cic < 0 ? pr1 : pr2
            if sqrt(sum(abs2, pr - prev)) > 0.07
                push!(rtext, pr)
                push!(vrtext, v)
                prev = pr
            else
                push!(rtext, Point2f(Inf))
                push!(vrtext, Inf)
            end
        end
    end
    for v in 1:(nvals - length(rtext))
        push!(rtext, Point2f(Inf))
        push!(vrtext, Inf)
    end

    #Reactance
    ref_center, ref_rad = resistance_arcs(crc)
    prev = Point2f(Inf)
    filter!(x-> abs(x) <= get_zcut(crc, zoomlevel), values)
    lenv = length(values)
    indices = lenv >= nvals ? round.(Int, range(1, lenv, nvals)) : eachindex(values)
    
    for i in indices
        v = values[i]
        val = cic < 0 ? -v : v
        center, rad = reactance_arcs(val)
        px1, px2 = circles_intersection(ref_center, center, ref_rad, rad)
        px = val < 0 ? px2 : px1
        # Don't push too close positions, positions on rtext and positions to close to x = 0 line.
        if sqrt(sum(abs2, px - prev)) > 0.07 && all(x->sqrt(sum(abs2, px - x)) > 0.05, rtext) && abs(px[2]) > 0.045
            push!(itext, px)
            push!(vitext, val)
            prev = px
        else
            push!(itext, Point2f(Inf))
            push!(vitext, Inf)
        end
    end
    for v in 1:(nvals - length(itext))
        push!(itext, Point2f(Inf))
        push!(vitext, Inf)
    end

    return nothing
end

