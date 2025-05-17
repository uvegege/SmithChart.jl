module SmithChart

using Makie
using Makie: parent_scene, shift_project, update_tooltip_alignment!, position2string
#if VERSION >= v"1.11" # Setting [compat] to Makie = "0.20.10" I don't need this
#    using Makie: make_block_docstring
#end
using Makie.GeometryBasics: Polygon
using Makie: DragPan, ScrollZoom, LimitReset
using Makie.GeometryBasics: LineString
using Makie: inherit, automatic
using Printf

include("./smithaxis.jl")
include("./blockinteractivity.jl")
include("./drawaxis.jl")
include("./smithaxisblock.jl")

include("./functions.jl")
include("./cutgrid.jl")

include("./recipes.jl")
include("./interactivetext.jl")
include("./interactivezoom.jl")
include("./vswr.jl")

export SmithAxis
export SmithLine, smithplot, smithplot!
export SmithScatter, smithscatter, smithscatter!
export vswr, vswr!
export datamarkers
export NFCircle, CGCircle, StabilityCircle

end

