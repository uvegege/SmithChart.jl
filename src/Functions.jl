u_to_R(x) = (1+x)/(1-x) 
R_to_u(r) = -(1-r)/(1+r) 
u_to_X(u) = sqrt((u+1)/(1-u)) 
X_to_u(X) = (X^2 - 1) / (X^2 + 1) 
coords_to_z(u,v) = (1+Complex(u,v))/(1-Complex(u,v))

function smith_transform(z)
    Γ = (z-1)/(z+1)
    x_map = real(Γ)
    y_map = imag(Γ)
    return Point2f(x_map, y_map)
end


function resistance_arcs(r)
    center = Point2f(r / (1 + r), 0)
    rad = 1 / (1 + r)
    return center, rad
end

function reactance_arcs(r)
    center = Point2f(1, 1/r)
    rad = 1/abs(r)
    return center, rad
end


function circles_intersection(center1, center2, r1, r2)
    d = sqrt((center2[1] - center1[1])^2 + (center2[2] - center1[2])^2)
    if d > r1 + r2 || d < abs(r1 - r2) && !isapprox(d, r1-r2)
        return Point2f[]
    end
    θ = atan(center2[2] - center1[2], center2[1] - center1[1])
    a = (r1^2 - r2^2 + d^2) / (2 * d)
    h = sqrt(abs(r1^2 - a^2))

    x1 = center1[1] + a * cos(θ) + h * cos(θ + π/2)
    y1 = center1[2] + a * sin(θ) + h * sin(θ + π/2)

    x2 = center1[1] + a * cos(θ) - h * cos(θ + π/2)
    y2 = center1[2] + a * sin(θ) - h * sin(θ + π/2)

    return [Point2f(x1, y1), Point2f(x2, y2)]
end

function start_end_angles(z, center, rad, zoomlevel, resistance = true, dashed = false)
    cutfunction = resistance ? reactance_arcs : resistance_arcs
    zcut = get_zcut(z, zoomlevel)

    # Angle of the intersection between 2 arcs
    center_cut, rad_cut = cutfunction(zcut)
    cut1, cut2 = circles_intersection(center_cut, center, rad_cut, rad)
    cut = sqrt(sum(abs2,cut1)) < sqrt(sum(abs2,cut2)) ? cut1 : cut2
    angle_cut = atan(cut[2]-center[2], cut[1]-center[1])
    if angle_cut < 0
        angle_cut = angle_cut + 2*pi
    end
    if resistance == true
        return angle_cut, -angle_cut+2*pi
    end
    # Angle of the intersection with exterior circunference
    inter1, inter2 = circles_intersection(Point2f(0.0), center, 1.0, rad)
    inter = center[2] > 0 ? inter1 : inter2
    angle_init = atan(inter[2] - center[2], inter[1] - center[1])
    if angle_init > 0
        angle_init = angle_init + 2*pi
    end
    angle_init, angle_cut = mod(angle_init,2*pi), mod(angle_cut,2*pi)
    return angle_init, angle_cut
end


#
function textval(z, j = false)
    if isapprox(z - round(z), 0, atol = 1e-6)
        str = j == false ? @sprintf("%.0f", z) : @sprintf("%.0fj", z)
    else
        str = j == false ? @sprintf("%.1f", z) : @sprintf("%.1fj", z)
    end
    return str
end



function circular_shape(npoints = 150)
    circular_shape = [Point2f(sincos(θ)) for θ in range(-π, π, npoints)]
end

function rectangular_shape(s = 1e5)
    Point2f[(-s, -s), (-s, s), (s, s), (s, -s), (-s, -s)]
end
