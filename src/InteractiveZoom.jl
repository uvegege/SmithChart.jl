"""
    splitintervals(intervals, n)

Split each interval in n values. `intervals` is a Vectir of intervals.
"""
function splitintervals(intervals, n)
    return map(intervals) do interval
        d = interval.right - interval.left
        inc = d / (n + 1)
        Vec(ntuple(i-> round(interval.left + inc*i, digits = 5), n))
    end
end

"""
    splitintervals(intervals, n)

Create new intervals from the previous splited intervals using left, midpoint and right
"""
function newintervals(splited_intervals, intervals)
    return reduce(vcat, map(splited_intervals, intervals) do splited, interval
        Vec2(interval.left..splited[2], splited[2]..interval.right)
    end)    
end

"""
    splitintervals(intervals, n)

Interpolation using previously defined functions.
"""
function create_subgrid(vals, nsplit; refine = true)
    values = createintervals(vals; lastvalue = maximum(vals)*2)
    vsubgrid = stack(splitintervals(createintervals(vals; lastvalue = maximum(vals)*2), nsplit))[:]
    return vsubgrid
end

"""
     update_zoomlevel(sc::SmithChartBlock)
    
Updates the zoomlevel of the SmithChartBlock. This used when keyword `zoomupdate = true`.
The "dynamic" subgrid update could be better but this "works".
"""
function update_zoomlevel(sc::SmithAxis)
    !sc.zoomupdate[] && return
    minspan = minimum(widths(sc.targetlimits[]))
    act_zoomlevel = sc.zoomlevel[]
    zlevel = 10000 >= minspan >= 1.8 ? 0 :
             1.8 > minspan >= 1.5 ? 1 :
             1.5 > minspan >= 1.2 ? 2 :
             1.2 > minspan >= 1.0 ? 3 :
             1.0 > minspan >= 0.8 ? 4 :
             5
    if zlevel != act_zoomlevel
        sc.zoomlevel[] = zlevel
    end
    return nothing
end


"""
    createintervals(v)

- `create_midpoint = true`: Create intervals from a vector of values. If the difference between a value and the previous one
is bigger than the 2*value, it creates a point in the middle.
- `initvalue = 0.0`
- `lastvalue = 80.0`
"""
function createintervals(v; midpoint = true, initvalue = 0.0, lastvalue = 80.0)
    intervals = Vector{Makie.ClosedInterval{Float64}}()
    sizehint!(intervals, length(v)+3)
    for i in eachindex(v)
        if i == 1
            push!(intervals, initvalue..v[i])
        else
            if i == length(v)
                if 3*v[i-1] < v[i] && midpoint
                    newp = v[i] - 2*v[i-1]
                    push!(intervals, v[i-1]..newp)
                    push!(intervals, newp..v[i])
                else
                    push!(intervals, v[i-1]..v[i])
                end
                push!(intervals, v[i]..lastvalue)
            else
                if 3*v[i-1] < v[i] && midpoint
                    newp = v[i] - 2*v[i-1]
                    push!(intervals, v[i-1]..newp)
                    push!(intervals, newp..(v[i]))
                else
                    push!(intervals, v[i-1]..v[i])
                end
            end
        end
    end
    return intervals
end