# Previously the intersection was hardcoded for a specific zoomlevel. It didn't work 
# if the user changed the real or imaginary ticks. 
function set_Xcut_alg1(xticks, yticks, threshold, tlims)
    space = widths(tlims)[2] / 2.0
    ycuts = xticks[end] * ones(length(yticks), )
    prevy = 0.0
    i = 1
    prevx = 0.0
    for y in yticks
        for (xidx, xs) in enumerate(xticks)
            prev = smith_transform(Complex(xs, prevy))
            pact = smith_transform(Complex(xs, y))
            dist = hypot((prev-pact)...)
            if dist < threshold * space
                xs_ = xs
                if prevx == xs # Test next xs
                    if xidx != length(xticks)
                        xs_ = xticks[xidx+1]
                    end
                end
                ycuts[i] = xs_
                i = i + 1
                prevx = xs_
                break
            end
        end
        prevy = y
    end

    ycuts[end] = maximum(ycuts) * (1.5 + 1.5/space)

    if space <= 0.6
        for i in eachindex(ycuts)
            i == length(ycuts) && break
            x = findfirst(>(ycuts[i]), ycuts)
            if !isnothing(x)
                ycuts[i] = ycuts[x]
            end
        end
    end
    return ycuts
end


function set_Rcut_alg1(xticks, yticks, threshold, tlims)
    return set_Xcut_alg2(yticks, xticks, threshold, tlims )
end

# This functions are inspired on the grid generation method used in pySmithPlot
# with some simplifications.
# https://github.com/vMeijin/pySmithPlot
function set_Xcut_alg2(xticks, yticks, threshold, tlims)
    space = widths(tlims)[2] / 2.0
    ycuts = xticks[end] * ones(length(yticks), )
    setyticks = Set(yticks)
    yindex = Dict( yticks .=> eachindex(yticks))
    for xs in xticks
        prevy = 0.0
        for y in yticks
            !in(y, setyticks) && continue
            prev = smith_transform(Complex(xs, prevy))
            pact = smith_transform(Complex(xs, y))
            dist = hypot((prev-pact)...)
            if dist < threshold * space
                ycuts[yindex[y]] = xs
                pop!(setyticks, y)
            else
                prevy = y
            end
        end
    end

    ycuts[end] = maximum(ycuts) * (1.5 + 1.5/space)

    if space <= 0.6
        for i in eachindex(ycuts)
            i == length(ycuts) && break
            x = findfirst(>(ycuts[i]), ycuts)
            if !isnothing(x)
                ycuts[i] = ycuts[x]
            end
        end
    end
    return ycuts
end

function set_Rcut_alg2(xticks, yticks, threshold, tlims)
    space = widths(tlims)[1] / 2.0
    xcuts = yticks[end] * ones(length(xticks), )
    setxticks = Set(xticks)
    prevy = 0.0
    xindex = Dict( xticks .=> eachindex(xticks))
    for y in yticks
        prevx = 0.0
        for x in xticks
            !in(x, setxticks) && continue
            prev = smith_transform(Complex(prevx, y))
            pact = smith_transform(Complex(x, y))
            dist = hypot((prev-pact)...)
            if dist < threshold * space
                xcuts[xindex[x]] = prevy
                pop!(setxticks, x)
            else
                prevx = x
            end
        end
        prevy = y
    end
    
    xcuts[end] = yticks[end] *  (1.5 + 1.5/space)

    if space <= 0.6
        for i in eachindex(xcuts)
            i == length(xcuts) && break
            x = findfirst(>(xcuts[i]), xcuts)
            if !isnothing(x)
                xcuts[i] = xcuts[x]
            end
        end
    end

    return xcuts
end

"""
    get_zcut(z, ticks, cuts ; subgrid = false)

Returns the reactance or resistance value of the arc of the cut depending of the resistance or reactance value `z`
"""
function get_zcut(z, ticks, cuts ; subgrid = false)
    li = length(ticks)
    for idx in eachindex(ticks)
        if idx != li
            interval = idx == 1 ? 0.0..ticks[idx] : ticks[idx-1]..ticks[idx]
            if abs(z) in interval
                if idx == 1
                    return cuts[1]
                else
                    return subgrid == true ? min(cuts[idx-1], cuts[idx]) : cuts[idx]
                end
            end
        end
    end
    return cuts[end]
end
