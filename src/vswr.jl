"""
    vswr(v; args...)

Plots reflection data on a Smith chart, configured to visualize **Voltage Standing Wave Ratio (VSWR)** characteristics.

This function is a convenience wrapper around [`smithplot`](@ref), with the keyword `reflection = true` set by default. It is intended for use when plotting reflection coefficients or S-parameter data, where impedance normalization is not needed.

#### Arguments

- `v`: VSWR value
- `args...`: Additional keyword arguments forwarded to [`smithplot`](@ref), allowing customization of plot appearance and behavior.

#### Example

```julia
vswr(2.0; color = :red, linewidth = 2)
```

This plots a VSWR = 2 circle centered at the origin with radius 1/3.

See also: [`smithplot`](@ref), [`smithscatter`](@ref)
"""
function vswr!(ax, v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(ax, points; reflection = true, args...)
    ax
end

"""
    vswr(v; args...)

Plots reflection data on a Smith chart, configured to visualize **Voltage Standing Wave Ratio (VSWR)** characteristics.

This function is a convenience wrapper around [`smithplot`](@ref), with the keyword `reflection = true` set by default. It is intended for use when plotting reflection coefficients or S-parameter data, where impedance normalization is not needed.

## Arguments

- `v`: VSWR value
- `args...`: Additional keyword arguments forwarded to [`smithplot`](@ref), allowing customization of plot appearance and behavior.

## Example

```julia
vswr(2.0; color = :red, linewidth = 2)
```

This plots a VSWR = 2 circle centered at the origin with radius 1/3.

See also: [`smithplot`](@ref), [`smithscatter`](@ref)
"""
function vswr(v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    return smithplot(points; reflection = true, args...)
end

"""
    vswr(v; args...)

Plots reflection data on a Smith chart, configured to visualize **Voltage Standing Wave Ratio (VSWR)** characteristics.

This function is a convenience wrapper around [`smithplot`](@ref), with the keyword `reflection = true` set by default. It is intended for use when plotting reflection coefficients or S-parameter data, where impedance normalization is not needed.

#### Arguments

- `v`: VSWR value
- `args...`: Additional keyword arguments forwarded to [`smithplot`](@ref), allowing customization of plot appearance and behavior.

#### Example

```julia
vswr(2.0; color = :red, linewidth = 2)
```

This plots a VSWR = 2 circle centered at the origin with radius 1/3.

See also: [`smithplot`](@ref), [`smithscatter`](@ref)
"""
function vswr!(v; args...)
    Γ = (v - 1) / (v + 1)
    points = [Γ * cis(t) for t in range(-pi, pi, 251)]
    smithplot!(points; reflection = true, args...)
end