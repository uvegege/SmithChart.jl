using SmithChart
using Test

@testset "SmithChart.jl" begin
    f = Figure(size = (1200, 800))
    sc = SmithAxis(f[1,1], type = :Z, subtitle = "type :Z (default)")
    sc = SmithAxis(f[1,2], type = :Y, subtitle = "type :Y")
    sc = SmithAxis(f[1,3], type = :ZY, subtitle = "type :ZY", gtickvisible = false, btickvisible = false)
    sc = SmithAxis(f[2,1], type = :Z, subtitle = "rgridcolor = :red, xgridcolor = :green", rgridcolor = :red, xgridcolor = :green)
    sc = SmithAxis(f[2,2], type = :Y, subtitle = "ygridcolor = :blue", ygridcolor = :blue)
    sc = SmithAxis(f[2,3], type = :ZY, subtitle = "zgridcolor = :orange, ygridcolor = :green", zgridcolor = :orange, ygridcolor = :green, gtickvisible = false, btickvisible = false)
    f
end
