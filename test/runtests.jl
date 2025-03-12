using SmithChart
using Test

@testset "SmithChart.jl" begin
    fig = Figure()
    ax = Axis(fig[1, 1]; aspect=1, limits=(-1.2, 1.2, -1.2, 1.2), title = "Variable Length Lossy Transmission Line")
    drawsmithchart!(ax, subgrid = true, cutgrid = true, zoomupdate = false)
    # Lossy transmission line
    Zo = 50
    Zl = 100 + 50im
    f = 3.0e9
    λ = 3.0e8/f
    σ = 6.5
    β = 2*pi/λ
    s = σ + β*im
    l = range(0,λ,101)
    z = [(Zl+(Zo*tanh(s*li)))/(Zo+(Zl*tanh(s*li))) for li in l]
    smithplot!(ax, z, reflection = false, color = 1:101)
    smithscatter!(ax, [z[1]], reflection = false, markersize = 12.0)
    smithscatter!(ax, [z[end]], reflection = false, markersize = 12.0, marker = :cross)
    Colorbar(fig[1,2], limits = (l[1]/λ, l[end]/λ), ticks = ([0.0, 0.5, 1.0], ["0.0λ", "0.5λ", "1.0λ"]))
    DataInspector(fig)
    fig
end
