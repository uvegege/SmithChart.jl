# Split each interval in n values
function splitintervals(intervals, n)
    return map(intervals) do interval
        d = interval.right - interval.left
        inc = d / (n + 1)
        Vec(ntuple(i-> round(interval.left + inc*i, digits = 5), n))
    end
end

#Create new intervals from the previous splited intervals using left, midpoint and right
function newintervals(splited_intervals, intervals)
    return reduce(vcat, map(splited_intervals, intervals) do splited, interval
        Vec2(interval.left..splited[2], splited[2]..interval.right)
    end)    
end

function get_zcut(z, zoomlevel)
    if zoomlevel == 1 || zoomlevel == 0
        zcut = abs(z) in 0.0..0.999 ? 0.6 :
               abs(z) in 1.0..2.0 ? 2.0 :
               abs(z) in 2.0..5.0 ? 5.0 :
               abs(z) in 5.0..20. ? 20. :
               abs(z) in 20.0..Inf ? 50.0 : 0.0

        zcut = abs(z) in (0.2, 0.4, 0.6) ? 1.0 :
            abs(z) in (1.0, 2.0)      ? 5.0 :
            abs(z) == 5.0             ? 50.0 : zcut

    elseif zoomlevel == 2
        zcut = abs(z) in 0.0..2.0 ? 2.0 :
            abs(z) in 2.0..5.0 ? 5.0 : 50.0

        zcut = abs(z) in(0.2, 0.4, 0.6, 1.0, 2.0) ? 5.0 :
            abs(z) in(5.0, 10.0) ? 20.0 : zcut

    elseif zoomlevel == 3
        zcut = abs(z) in 0.0..2.0 ? 3.5 :
               abs(z) in 2.0..5.0 ? 20.0 : 50
        zcut = abs(z) in(0.2, 0.4, 0.6) ? 5.0 : zcut
        zcut = abs(z) == 1.0 ? 12.5 : zcut
        zcut = abs(z) == 2.0 ? 20.0 : zcut
    end
    return zcut
end
