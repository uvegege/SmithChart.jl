# Stability, Gain and Noise Circles

SmithChart.jl allows visualization of constant gain circles, constant noise circles, and stability regions, essential for amplifier design and stability analysis. These features can be useful for tasks such as designing low-noise amplifiers (LNAs), power amplifiers, and ensuring the stability of circuits over a range of frequencies and impedances.

## Constant Gain Circles

The example used to demonstrate `CGCircle` is based on the design found in [this article on designing a unilateral RF amplifier for a specified gain](https://www.allaboutcircuits.com/technical-articles/designing-a-unilateral-rf-amplifier-for-a-specified-gain/), where a detailed explanation can be found.

```@example 
using CairoMakie
CairoMakie.activate!() #hide
using SmithChart

f = Figure()
sc = SmithAxis(f[1,1], cutgrid = true, title = "Constant Gs Circles")

NF_to_F(nf) = 10.0^(nf/10.0)
Γopt = 0.5 * cis(130 * pi / 180)
NFmin = 1.6 # dB
Fmin = NF_to_F(NFmin)
F2dB = NF_to_F(2.0)
F2_5dB = NF_to_F(2.5)
F3dB = NF_to_F(3.0)
nf2 = NFCircle(F2dB, Fmin, Γopt, 20.0, 50.0, 361)
nf2_5 = NFCircle(F2_5dB, Fmin, Γopt, 20.0, 50.0, 361)
nf3 = NFCircle(F3dB, Fmin, Γopt, 20.0, 50.0, 361)

smithscatter!(sc, [Γopt], reflection = true, color = :blue)
text!(sc, "Γopt", position = Point2f(real(Γopt)-0.07, imag(Γopt)),  offset  = (3, 3), color = :blue, font = :bold)
text!(sc, "$NFmin dB", position = Point2f(real(Γopt), imag(Γopt)),  offset  = (-11, -16), color = :blue, font = :bold)

lines!(sc, nf2, color = :green, linewidth = 1.9)
text!(sc, "2.0 dB", position = nf2[45],  offset  = (2, -6), color = :green, font = :bold)

lines!(sc, nf2_5, color = :purple, linewidth = 1.9)
text!(sc, "2.5 dB", position = nf2_5[120],  offset  = (-35, -2), color = :purple, font = :bold)

lines!(sc, nf3, color = :orange, linewidth = 1.9)
text!(sc, "3.0 dB", position = nf3[260],  offset  = (2, 2), color = :orange, font = :bold)
f
```

## Constant Noise Circles

The example for `NFCircle` is taken from [this article on designing unilateral low-noise amplifiers](https://www.allaboutcircuits.com/technical-articles/learn-about-designing-unilateral-low-noise-amplifiers/), which provides a thorough explanation.
``` @example 
using CairoMakie
using SmithChart

f = Figure()
sc = SmithAxis(f[1,1], cutgrid = true, title = "Constant NF Circles")

S11 = 0.533 * cis(176.6 / 180 * π)
S22 = 0.604 * cis(-58.0 / 180 * π)
Go = abs2(S11)
Gs_max = 1 / (1 - abs2(S11))
gain(dB) = 10.0^(dB/10.0)

g1 = gain(0.0) / Gs_max
g2 = gain(0.5) / Gs_max
g3 = gain(1.0) / Gs_max
g4 = gain(1.4) / Gs_max

c1 = CGCircle(g1, S11, 361)
c2 = CGCircle(g2, S11, 361)
c3 = CGCircle(g3, S11, 361)
c4 = CGCircle(g4, S11, 361)

smithscatter!(sc, [conj(S11)], reflection = true, color = :blue)
text!(sc, "S11*", position = Point2f(real(S11), -imag(S11)),  
    offset  = (11, 11), color = :blue, font = :bold, fontsize = 11)

poly!(sc, c1, color = (:green, 0.1), strokecolor = :green, strokewidth = 1.9)
text!(sc, "0.0 dB", position = c1[125],  offset  = (17, -4), color = :green, font = :bold)

lines!(sc, c2, color = :red, linewidth = 1.9)
text!(sc, "0.5 dB", position = c2[110],  offset  = (-39, -1), color = :red, font = :bold)

lines!(sc, c3, color = :magenta, linewidth = 1.9)
text!(sc, "1.0 dB", position = c3[260],  offset  = (2, 0), color = :magenta, font = :bold)

lines!(sc, c4, color = :purple, linewidth = 1.9)
text!(sc, "1.4 dB", position = c3[45],  offset  = (2, -5), color = :purple, font = :bold)
f
```

## Stability Circles

The example illustrating `StabilityCircle` is based on [this article about unconditional stability and potential instability in RF amplifier design](https://www.allaboutcircuits.com/technical-articles/learn-about-unconditional-stability-and-potential-instability-in-rf-amplifier-design/), which explains the theory in detail.

``` @example 
using CairoMakie
using SmithChart

f = Figure(size = (1000, 500))
Label(f[0, 1:2] , "Stable Regions", fontsize = 24, font = :bold)
S11, S12, S21, S22 =  [0.438868-0.778865im 1.4+0.2im; 0.1+0.43im  0.692125-0.361834im]
A =  StabilityCircle(S11, S12, S21, S22, :source, 361; stable = false)
B =  StabilityCircle(S11, S12, S21, S22, :source, 361; stable = true)

ax = SmithAxis(f[1,1], subtitle = "StabilityCircle(... ; stable = false)")
region = poly!(ax, A, strokecolor = :black, strokewidth = 1.2, color = Pattern('x', linecolor = :red, width = 1.3, background_color = (:red, 0.1)))
translate!(region, (0, 0, -2)) 
text!(ax, "Unstable Input", position = Point2f(-0.65, -0.5), font = :bold, color = :red, fontsize = 15)
B =  StabilityCircle(S11, S12, S21, S22, :source, 361; stable = true);
ax = SmithAxis(f[1,2], subtitle = "StabilityCircle(... ; stable = true)")
region = poly!(ax, B, strokecolor = :black, strokewidth = 1.2, color = Pattern('\\', linecolor = :blue, width = 1.3, background_color = (:blue, 0.1)))
translate!(region, (0, 0, -2)) 
text!(ax, "Stable Input", position = Point2f(-0.1, 0.15), font = :bold, color = :blue, fontsize = 15)
f
```

``` @example 
using CairoMakie
using SmithChart

f = Figure()
S11, S12, S21, S22 = [ 0.0967927-0.604297im  0.0255292+0.0394621im ; -8.4396+11.0786im    0.552226-0.425271im]
A =  StabilityCircle(S11, S12, S21, S22, :source, 361; stable = true);
B =  StabilityCircle(S11, S12, S21, S22, :load, 361; stable = true);
ax = SmithAxis(f[1,1], title = "Input and Output stability regions")
color1 = Pattern('/', linecolor = :blue, width = 1.3, background_color  = :transparent)
color2 = Pattern('\\', linecolor = :green, width = 1.3, background_color  = :transparent)
region = poly!(ax, A, strokecolor = :black, strokewidth = 1.2, color = color1)
translate!(region, (0, 0, -2)) 
region = poly!(ax, B, strokecolor = :black, strokewidth = 1.2, color = color2)
translate!(region, (0, 0, -2)) 
text!(ax, "Stable Input", position = Point2f(-0.85, 0.2), font = :bold, color = :blue, rotation = 25*pi/180, fontsize = 12)
text!(ax, "Stable Output", position = Point2f(0.3, 0.5), font = :bold, color = :green, rotation = -18*pi/180, fontsize = 12)
f
```