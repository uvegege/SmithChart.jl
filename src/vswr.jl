function vswr!(ax::Axis, v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(ax, points; reflection = true, args...)
    ax
end


function vswr(v; args...)
    fig = Figure()
    ax = Axis(fig[1, 1]; aspect=1, limits=(-1.2, 1.2, -1.2, 1.2))
    drawsmithchart!(ax, subgrid = true, cutgrid = true, zoomupdate = false)
    vswr!(ax, v; args...)
    return fig, ax
end

function vswr!(v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(points; reflection = true, args...)
end