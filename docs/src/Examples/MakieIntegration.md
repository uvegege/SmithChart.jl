# Integration with Makie

This example showcases the seamless integration of the Smith chart with Makie.jl's interactive functionalities. It demonstrates a typical scenario used to teach impedance matching, where we aim to transform a source impedance of 50+100j $\Omega$ to a load impedance of 50 $\Omega$. To achieve this, we utilize a transmission line and a parallel stub, and control their lengths via sliders. By dynamically adjusting these lengths, users can observe how the source impedance seen by the load evolves on the Smith chart, visually illustrating the impedance matching process.


```@example  
using GLMakie
using SmithChart

fig = Figure()
ax = SmithAxis(fig[1, 1], title = "Stub Matching")

Zl = 50.0
Ri = 50.0
Xi = 100.0
zi = Ri + Xi*im
zi = zi / Zl

function simline(z, l)
    bl = 2 * pi * l # Electrical length
    return (z + im * tan(bl)) / (1 + im * z * tan(bl))
end

function simstub(z, l)
    bl = 2 * pi * l
    y_stub = im * tan(-bl)
    return 1 / ((1 / z) + y_stub) 
end

N = 101
sg = SliderGrid(
    fig[2, 1],
    (label = "Line", range = range(0.0, 0.5, 151), format = "{:.3f}λ", startvalue = 0.0),
    (label = "Stub", range = range(0.0, 0.5, 151), format = "{:.3f}λ", startvalue = 0.0))

sliderobservables = [s.value for s in sg.sliders]
z = lift(sliderobservables...) do slvalues...
    line_index, stub_index = [slvalues...]
    line_p = range(0.0, line_index, N)
    stub_p = range(0.0, stub_index, N)
    z_line = simline.(zi, line_p)
    z_stub = simstub.(z_line[end], stub_p)
    return [zi; z_line; z_stub]
end

zend = lift(x->x[end], z)
smithscatter!(zi)
smithplot!(z)
smithscatter!(zend)
fig
```

I've tested and it works with WGLMakie and Bonito, but don't know how to integrate it with Documenter.jl. The result would be something like the following gif.

![Sliders](../assets/sliders.gif)