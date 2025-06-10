using Documenter, SmithChart

DocMeta.setdocmeta!(SmithChart, :DocTestSetup, :(using SmithChart); recursive=true)

makedocs(modules = [SmithChart], clean = true,  format = Documenter.HTML(; size_threshold=100_000_000), sitename = "SmithChart.jl", 
    pages = Any[
    "index.md",
    "SmithAxisBlock.md",
    "api_reference.md",
    "Examples" => Any[
        "Examples/ChartTypes.md",
        "Examples/TickPositions.md",
        "Examples/MakieIntegration.md",
        "Examples/Reflection.md", 
        "Examples/InteractiveDataMarkers.md",
        "Examples/ConstantCircles.md", 
        "Examples/VisualDetails.md",
        "Examples/DynamicUpdate.md"]
        ], doctest = true, checkdocs=:none)
     
deploydocs(
    repo = "github.com/uvegege/SmithChart.jl.git",
    push_preview = true,
)

