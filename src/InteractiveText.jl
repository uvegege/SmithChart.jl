#TODO: This should be simpler
"""
    move_textlabels(r_label_pos, x_label_pos, limits, zoomlevel, zupdate, subgrid, updatext, nvals, smtype, rvals, xvals, rcuts, xcuts)

Calculates and updates the positions of text labels on the Smith Chart based on the current view limits and zoom level.

This function calculates the new positions for resistance and reactance text labels on the Smith Chart when the `updatext` flag is `true`. It uses the current view limits (`limits`), zoom level (`zoomlevel`), and the number of desired values (`nvals`) to determine the appropriate positions.
"""
function calculate_textposition(r_label_pos, x_label_pos, limits, zoomlevel, zupdate, subgrid, updatext, nvals, smtype, rvals, xvals, rcuts, xcuts)

    if !updatext | !zupdate 
        x_label_pos[] = [("", Point2f(NaN)) for _ in 1:nvals]
        r_label_pos[] = [("", Point2f(NaN)) for _ in 1:2*nvals]
        return
    end

    empty!(x_label_pos[])
    empty!(r_label_pos[])

    ox, oy = limits.origin
    wx, wy = limits.widths
    xc, yc = ox+wx/2, oy+wy/2 # Center points
    center = Point2f(xc, yc)
    zl = coords_to_z(center...)
    rc = real(zl)
    ic = imag(zl)
    
    if zoomlevel == 1 && subgrid == true
        intervals1 = createintervals(rvals)
        intervals2 = createintervals(xvals)
        rvalues = map(x->x.right, intervals1)
        ivalues = map(x->x.right, intervals2)
    elseif zoomlevel > 2 && subgrid == true
        split_intervals = 3 # TODO: pass to the function
        intervals = createintervals(rvals)
        splited_intervals = splitintervals(intervals, split_intervals)
        new_intervals = newintervals(splited_intervals, intervals)
        rvalues = map(x->x.right, new_intervals)

        intervals2 = createintervals(xvals)
        splited_intervals2 = splitintervals(intervals2, split_intervals)
        new_intervals2 = newintervals(splited_intervals2, intervals2)
        ivalues = map(x->x.right, new_intervals2)
    else
        rvalues = copy(rvals)
        ivalues = copy(xvals)
    end

    # Find the closest REACTANCE/RESISTANCE curve to the center of the image
    sgn = smtype == :Z ? 1.0 : -1.0
    crc = argmin(v->abs(v - rc), rvalues)
    cic = argmin(v->abs(v - ic), vcat(ivalues, -ivalues))
    cic = abs(ic) < 0.2 ? 0.0 : cic
    
    if sgn == -1.0
        crc = 1/crc
    end

    #Resistance
    prev = Point2f(Inf)
    if cic == 0.0
        minR = max(0.0, real(coords_to_z(max(-1.0, ox), 0.0)))
        maxR = min(Inf, real(coords_to_z(min(0.999999, ox+wx), 0.0)))
        if sgn == -1.0
            minR, maxR = 1/maxR, 1/minR
        end
    else
        minR, maxR =  0.0, Inf
    end
    valr = filter(v -> (minR <= v <= maxR) &  (abs(v) <= get_zcut(v, rvals, rcuts)) , rvalues)
    lenv = length(valr)
    indices = lenv >= nvals ? round.(Int, range(1, lenv, nvals)) : eachindex(valr)

    for i in indices
        v = valr[i]
        if cic == 0.0
            push!(r_label_pos[], (textval(v), Point2f(sgn * R_to_u(v), 0.0)))
        else
            pr = smith_transform(Complex(v, cic))
            if sqrt(sum(abs2, pr - prev)) > 0.07
                push!(r_label_pos[], (textval(v), Point2f(sgn * pr[1], pr[2])))
                prev = pr
            else
                push!(r_label_pos[], ("", Point2f(Inf)))
            end
        end
    end

    # FILL with INF
    for _ in 1:(nvals - length(r_label_pos[]))
        push!(r_label_pos[], ("", Point2f(Inf)))
    end

    #Reactance
    prev = Point2f(Inf)
    filter!(x-> abs(x) <= get_zcut(crc, xvals, xcuts), ivalues)
    lenv = length(ivalues)
    indices = lenv >= nvals ? round.(Int, range(1, lenv, nvals)) : eachindex(ivalues)
    
    for i in indices
        v = ivalues[i]
        val = cic < 0 ? -v : v
        px = smith_transform(Complex(crc, val))
        px = Point2f(sgn*px[1], px[2])

        if sqrt(sum(abs2, px - prev)) > 0.07 && all(x->sqrt(sum(abs2, px - x)) > 0.05, getindex.(r_label_pos[], 2)) && abs(px[2]) > 0.045
            push!(x_label_pos[], (textval(sgn * val, true), px))
            prev = px
        else
            push!(x_label_pos[], ("", Point2f(Inf)))
        end
    end
    # FILL with INF
    for _ in 1:(nvals - length(x_label_pos[]))
        push!(x_label_pos[], ("", Point2f(Inf)))
    end

    for i in eachindex(x_label_pos[])
        pos = x_label_pos[][i][2]
        txt = x_label_pos[][i][1]
        txt = startswith("-", txt) ? txt[2:end] : "-"*txt
        pos = Point2f(pos[1], -pos[2])
        push!(x_label_pos[], (txt, pos))
    end

    return nothing
end


