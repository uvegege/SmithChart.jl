"""
    u_to_R(x)

Converts a normalized resistance coordinate (x) on the Smith Chart to its corresponding normalized resistance value 
"""
u_to_R(x) = (1+x)/(1-x) 

"""
    R_to_u(x)

Converts a normalized resistance value (r) to its corresponding normalized resistance coordinate (u) on the Smith Chart.
"""

R_to_u(r) = -(1-r)/(1+r) 
"""
    u_to_X(x)

Converts a coordinate (u) on the outer edge (unit circle) of the Smith Chart to the reactance value (X) of the reactance circle that intersects that coordinate.
"""
u_to_X(u) = sqrt((u+1)/(1-u)) 

"""
    R_to_u(x)

Converts a normalized reactance value (X) to the normalized coordinate (u) on the outer edge (unit circle) of the Smith Chart where the corresponding reactance circle intersects.
"""
X_to_u(X) = (X^2 - 1) / (X^2 + 1) 

"""
    coords_to_z(x)

Converts coordinates (u, v) on the Smith Chart to a complex impedance or admittance value (z)
"""
coords_to_z(u,v) = (1+Complex(u,v))/(1-Complex(u,v))


"""
    smith_transform(z)

Transforms a complex impedance or admittance value `z` to its corresponding point on the Smith Chart.

This function calculates the reflection coefficient (Γ) from a complex value and return a `Point2f` with the coordinates on the Smith Chart.

Γ = (z - 1) / (z + 1)

"""
function smith_transform(z)
    Γ = (z-1)/(z+1)
    return Point2f(real(Γ), imag(Γ))
end

"""
    resistance_arcs(r)

Calculates the center and radius of a constant resistance arc on the Smith Chart.

This function determines the center and radius of a circle representing a constant resistance value `r` on the Smith Chart.

Returns a Tuple{Point2f, Float} containing the center point and the radius.
"""
function resistance_arcs(r)
    center = Point2f(r / (1 + r), 0)
    rad = 1 / (1 + r)
    return (center, rad)
end


"""
    reactance_arcs(r)

Calculates the center and radius of a constant reactance arc on the Smith Chart.

This function determines the center and radius of a circle representing a constant reactance value `r` on the Smith Chart.

Returns a Tuple{Point2f, Float} containing the center point and the radius.
"""
function reactance_arcs(r)
    center = Point2f(1, 1/r)
    rad = 1/abs(r)
    return (center, rad)
end

"""
    start_end_angles(z, center, rad, zoomlevel, resistance = true)

Calculates the start and end angles for drawing arcs on the Smith Chart based on the zoom level.

This function determines the angles that define the visible portion of a constant resistance or reactance arc on the Smith Chart, taking into account the current zoom level. It is designed to be called only when the `zoomlevel` changes.

- `z`: The normalized impedance or admittance value associated with the arc.
- `ticks`: ticks of the grid
- `cuts`: cut values used in `get_zcut` function
- `resistance`: A boolean indicating whether to calculate angles for a resistance arc (`true`) or a reactance arc (`false`). Defaults to `true`.
- `subgrid` A boolean indicating whether it's a grid or subgrid line.

Returns `Tuple{Float64, Float64}`: A tuple containing the start and end angles (in radians) for drawing the arc.

# Notes

- It calculates the intersection points of the arc with a cutoff arc (either resistance or reactance, depending on `resistance`).
- If `cutgrid` is `false` (not explicitly shown in the code, but implied), it always returns `-pi, pi`.

"""
function start_end_angles(z, ticks, cuts; resistance = true, subgrid = false)
    cutfunction = resistance ? reactance_arcs : resistance_arcs
    cfunc = resistance ? resistance_arcs : reactance_arcs

    zcut = get_zcut(z, ticks, cuts; subgrid = subgrid)
    if resistance == true
        realpart = z
        imagpart = zcut
    else
        realpart = zcut
        imagpart = z   
    end
    cut = smith_transform(Complex(realpart, imagpart))
    
    # Angle of the intersection between 2 arcs
    center, rad = cfunc(z)
    angle_cut = atan(cut[2]-center[2], cut[1]-center[1])

    if resistance == true
        return angle_cut, -angle_cut+2*pi
    end

    # Angle of the intersection with exterior circunference
    inter = smith_transform(Complex(0, imagpart))

    angle_init = atan(inter[2] - center[2], inter[1] - center[1])
    if angle_init > 0
        angle_init = angle_init + 2*pi
    end
    
    angle_init, angle_cut = mod(angle_init,2*pi), mod(angle_cut,2*pi)
    return angle_init, angle_cut
end

"""
    textval(z, j = false)

Formats a numerical value as a string for display.
- `z`: The numerical value to format.
- `j`: A boolean flag indicating whether to append "j" to the formatted string. Defaults to `false`.
"""
function textval(z, j = false)
    if isapprox(z - round(z), 0, atol = 1e-6)
        str = j == false ? @sprintf("%.0f", z) : @sprintf("%.0fj", z)
    else
        str = j == false ? @sprintf("%.1f", z) : @sprintf("%.1fj", z)
    end
    return str
end

"""
    circular_shape(s = 1e5)

Return a Polygon with circular shape.
"""
function circular_shape(npoints = 150)
    [Point2f(sincos(θ)) for θ in range(-π, π, npoints)]
end

"""
    rectangular_shape(s = 1e5)

Return a Polygon with rectangular shape.
"""
function rectangular_shape(s = 1e5)
    Point2f[(-s, -s), (-s, s), (s, s), (s, -s), (-s, -s)]
end


