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



"""
    NFCircle(F, Fmin, Γopt, Rn, Zo)

Computes the points of the constant Noise Figure Circle.

## Arguments

- F: noise factor
- Fmin: minimum noise factor
- Γopt: optimimum source reflection coefficient related to Zopt or Yopt.
- Rn: noise resistance parameter
- Zo: Reference Impedance
- Np: Number of points

## Example

```
using SmithChart

NF_to_F(nf) = 10.0^(nf/10.0)
Γopt = 0.5 * cis(130 * pi / 180)
NFmin = 1.6 # dB
Fmin = NF_to_F(NFmin)
F2dB = NF_to_F(2.0)
nf2 = NFCircle(F2dB, Fmin, Γopt, 20.0, 50.0, 361)

```

"""
function NFCircle(F, Fmin, Γopt, Rn, Zo, Np)
    N = (F - Fmin)/(4*Rn/Zo) * abs2(1 + Γopt)
    center = Γopt / (N + 1)
    rad = sqrt(N*(N+1-abs2(Γopt)))/(N+1)
    x, y = real(center), imag(center)
    return [Point2f(rad * cos(th) + x, rad * sin(th) + y) for th in range(-π, π, Np)]
end

"""
    CGCircle(gi, Sii)

Computes the points of the Constant Gain Circle.

## Arguments

- gi: It's gsource or gload and it's value is G / Gmax
- Sii: Reflection S parameter. S11 for Gs and S22 for Gl. 
- Np: Number of points

## Example

```
using SmithChart

S11 = 0.533 * cis(176.6 / 180 * π)
Gs_max = 1 / (1 - abs2(S11))
gain(dB) = 10.0^(dB/10.0)
g1 = gain(0.0) / Gs_max
c1 = CGCircle(g1, S11, 361)

```

"""
function CGCircle(gi, Sii, Np)
    center = (gi * conj(Sii)) / (1 - abs2(Sii)*(1 - gi))
    rad = (sqrt(1-gi) * (1 - abs2(Sii))) / (1 - abs2(Sii)*(1 - gi))
    x, y = real(center), imag(center)
    return [Point2f(rad * cos(th) + x, rad * sin(th) + y) for th in range(-π, π, Np)]
end

# Stability Circunferences

"""
    StabilityCircle(S11, S12, S21, S22, inout::Symbol, Np; stable = false)

Computes the region of stability (or unstability) and returns a Makie.Polygon.

## Arguments

- Sii: S-parameter
- inout: a symbol selecting source or load regions. Valid values are :load or :source.
- Np: Number of points.
- stable: Selects if the region corresponds to the stable (true) or unstable (false) region.

## Examples

```
using SmithChart

S11, S12, S21, S22 =  [0.438868-0.778865im 1.4+0.2im; 0.1+0.43im  0.692125-0.361834im]
A =  StabilityCircle(S11, S12, S21, S22, :source, 361; stable = false)

```

"""
function StabilityCircle(S11, S12, S21, S22, inout::Symbol, Np; stable = false)
    if inout == :load
        S11, S22 = S22, S11
    end
    Δ =  S11 * S22 - S12 * S21
    center = conj(S22 - Δ*conj(S11)) / (abs2(S22) - abs2(Δ))
    rad = abs(S12 * S21) / (abs2(S22) - abs2(Δ))
    x, y = real(center), imag(center)
    points = [Point2f(rad * cos(th) + x, rad * sin(th) + y) for th in range(-π, π, Np)]
    circshape = circular_shape(Np)
    # Check if:
    if sqrt(sum(abs2, center)) + rad <= 1  # Stability Circle INSIDE Smith Chart
        if abs(S11) < 1
            outpolygon = stable == true ? Makie.Polygon(circshape, [points]) : Makie.Polygon(points)
        else
            outpolygon = stable == true ?  Makie.Polygon(points) : Makie.Polygon(circshape, [points])
        end
    elseif sqrt(sum(abs2, center)) + 1 <= rad # Smith Chart INSIDE Stability Circle (Unconditionally Stable)
        outpolygon = stable == true ? Makie.Polygon(circshape) : Makie.Polygon([Point2f(NaN) for _ in 1:3])
    elseif sqrt(sum(abs2, center)) - rad > 1  # Stability Circle OUTSIDE Smith Chart (Unconditionally Stable)
        outpolygon = stable == true ? Makie.Polygon(circshape) : Makie.Polygon([Point2f(NaN) for _ in 1:3])
    else
        Cr = real(center)
        Ci = imag(center)
        #Γi = (k - (Cr * Γr)) / Ci
        #Γr^2 + (Γi)^2 = 1
        #Γr^2 + ((k - (Cr * Γr))/Ci)^2 = 1
        #Ci^2*Γr^2   + k^2 + Cr^2*Γr^2 - 2*k*Cr*Γr - Ci^2 = 0
        #Ci^2 * Γr^2 + Cr*Γr^2 - 2*k*Cr*Γr - (Ci^2 + k^2) = 0
        #(Ci^2 + Cr^2) * Γr^2    - 2*k*Cr*Γr  + (-Ci^2 + k^2) = 0
        k = (Cr^2 + Ci^2 - rad^2 + 1)/2
        a = (Ci^2 + Cr^2)
        b = -(2*k*Cr)
        c = (-Ci^2 + k^2)
        v = sqrt(b^2-4*a*c)
        Γr = [(-b + v)/(2*a), (-b - v)/(2*a)]
        Γi = @. (k - (Cr * Γr)) / Ci
        P = Point2f.(Γr, Γi)
        v = map(x -> x - Point2f(Cr, Ci), P)
        angles_stability = map(x->atan(x[2], x[1]), v)
        angles_smith = map(x->atan(x[2], x[1]), P)
        # Case 1: |S11| < 1
        ids = sortperm(angles_smith)
        sort!(angles_smith)
        angles_stability = angles_stability[reverse(ids)]
        # Case 2: |S11| > 1
        if ((abs(S11) > 1) & (stable == false)) | ((abs(S11) < 1) & (stable == true))
            reverse!(angles_smith)
            reverse!(angles_stability)
            angles_smith[end] += 2*pi
        end
        stability_points = [Point2f(rad * cos(th) + x, rad * sin(th) + y) 
            for th in range(angles_stability[1], angles_stability[2], Np)]
        smith_points = [Point2f(cos(th), sin(th)) 
            for th in range(angles_smith[1], angles_smith[2], Np)]
        
        outpolygon = Makie.Polygon(vcat(smith_points, stability_points))
    end

    return outpolygon
end



# Forbidden regions

