function vswr!(ax, v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(ax, points; reflection = true, args...)
    ax
end

function vswr(v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    return smithplot(points; reflection = true, args...)
end

function vswr!(v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(points; reflection = true, args...)
end