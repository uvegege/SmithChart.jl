"""
A Smith Chart Axis which can be plotted into.

**Constructors**

```julia
SmithAxis(fig_or_scene; kwargs...)
```
"""
Makie.@Block SmithAxis <: Makie.AbstractAxis begin

scene::Scene
overlay::Scene
targetlimits::Observable{Rect2f}
mouseeventhandle::Makie.MouseEventHandle
scrollevents::Observable{ScrollEvent}
keysevents::Observable{KeysEvent}
interactions::Dict{Symbol, Tuple{Bool, Any}}
temp_plots::Observable{Vector{Any}}
#temp_plots::Observable{Vector{Tuple{Makie.Plot, String, Makie.Plot, Int64, Bool, Vector{<:Real}}}}

@attributes begin
    """
    Global state for the x dimension conversion.
    """
    dim1_conversion = nothing
    """
    Global state for the y dimension conversion.
    """
    dim2_conversion = nothing

    # Smith Chart type

    "Smith Chart type. Valid values are :Z, :Y and :ZY"
    type::Symbol = :Z 
    "Controls the cut of the lines."
    cutgrid::Bool = true
    "Select cutgrid algorithm (1 or 2)"
    cutgridalg::Int = 2
    "Controls if there is a subgrid drawn in the image."
    subgrid::Bool = false
    "Controls the interactive `subgrid` update while zooming."
    zoomupdate::Bool = false
    "Controls if there is interactive text annotations while moving and zooming in the image."
    textupdate::Bool = false
    "Controls the maximum number of text labels"
    ntextvals::Int = 7
    "Controls the actual zoom level"
    zoomlevel::Int = 0

    # Scene 
    
    "The height setting of the scene."
    height = nothing
    "The width setting of the scene."
    width = nothing
    "Controls if the parent layout can adjust to this element's width"
    tellwidth::Bool = true
    "Controls if the parent layout can adjust to this element's height"
    tellheight::Bool = true
    "The horizontal alignment of the scene in its suggested bounding box."
    halign = :center
    "The vertical alignment of the scene in its suggested bounding box."
    valign = :center
    "The alignment of the scene in its suggested bounding box."
    alignmode = Inside()

    "Controls if the x axis goes rightwards (false) or leftwards (true) in default camera orientation."
    xreversed::Bool = false
    "Controls if the y axis goes leftwards (false) or rightwards (true) in default camera orientation."
    yreversed::Bool = false

    # Background / clip settings
    "The density at which curved lines are sampled. (grid lines, spine lines, clip)"
    sample_density::Int = 361
    "The background color of the axis."
    backgroundcolor = inherit(scene, :backgroundcolor, :white)
    "The background color of the axis."
    backgroundcolorint = inherit(scene, :backgroundcolor, :white)
    "Controls whether to activate the nonlinear clip feature. Note that this should not be used when the background is ultimately transparent."
    clip::Bool = true
    "Sets the color of the clip polygon. Mainly for debug purposes."
    clipcolor = automatic
    "Sets the z value of inner clip."
    innerclipz::Float32 = -100.0
    "Sets the z value of outer clip."
    outerclipz::Float32 = 100.0

    # Limits & transformation settings
    "Can be used to manually specify which axis limits are desired."
    limits = ((-1., 1.), (-1., 1.))
    "Controls the forced aspect ratio of the Smith Chart"
    aspect::Float32 = 1.0
    "Radial limit of the Smith Chart."
    vlimit::Float32 = 1.0
    "The relative margins added to the autolimits in x direction."
    xautolimitmargin::Tuple{Float64, Float64} = (0.05f0, 0.05f0)
    "The relative margins added to the autolimits in y direction."
    yautolimitmargin::Tuple{Float64, Float64} = (0.05f0, 0.05f0)

    # Title
    "The title of the plot"
    title = ""
    "The gap between the title and the top of the axis"
    titlegap::Float32 = 4f0
    "The alignment of the title.  Can be any of `:center`, `:left`, or `:right`."
    titlealign = :center
    "The fontsize of the title."
    titlesize::Float32 = 16f0
    "The font of the title."
    titlefont = :bold
    "The color of the title."
    titlecolor = :black
    "Controls if the title is visible."
    titlevisible::Bool = true
    """
    The content of the axis subtitle.
    The value can be any non-vector-valued object that the `text` primitive supports.
    """
    subtitle = ""
    "The font family of the subtitle."
    subtitlefont = :regular
    "The subtitle's font size."
    subtitlesize::Float64 = 16f0
    "The gap between subtitle and title."
    subtitlegap::Float64 = 0
    "Controls if the subtitle is visible."
    subtitlevisible::Bool = true
    "The color of the subtitle"
    subtitlecolor::RGBAf = :black
    "The axis subtitle line height multiplier."
    subtitlelineheight::Float64 = 1


    # Spine 
    "Sets the z value of the exterior circunference. To Place the grid above plots set a value > 1"
    spinez::Float32 = 9000
    "Color of the exterior circunference"
    spinecolor =  :black
    "Linewidth of the exterior circunference"
    spinewidth::Float32 = 2.2
    "Linewidth of the horizontal line"
    spinehorizontalwidth::Float32 = 1.7
    "Linestyle of the exterior circunference"
    spinestyle = nothing
    "Controls if the exterior circunference is visible."
    spinevisible::Bool = true

    # GRID SECTION
    "Controls the color of ALL the grid"
    gridcolor = nothing
    "Controls the color of Z smith chart grid"
    zgridcolor = nothing
    "Controls the color of Y smith chart grid"
    ygridcolor = nothing
    """
    Controls the number of times the grid is splitted. Each position on the tuple indicates
    the number of lines that splits a interval for a specific zoomlevel. 
    When zoomlevel > length(splitgrid) the used value is the last one. 
    """
    splitgrid = (1, 1, 3)

    # RESISTANCE grid
    "Sets the z value of the RESISTANCE arcs grid. To Place the grid above plots set a value > 1"
    rgridz::Float32 = -50
    "Color of the RESISTANCE grid"
    rgridcolor = :black
    "Linewidth of the RESISTANCE grid"
    rgridwidth::Float32 = 0.7
    "Linestyle of the RESISTANCE grid"
    rgridstyle = nothing
    "Controls if the RESISTANCE grid is visible."
    rgridvisible::Bool = true
    "RESISTANCE grid positions"
    rvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]
    #"RESISTANCE subgrid positions"
    #rsubgrid::Vector{Float64} = [0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.25, 1.5, 3.5]
    "REACTANCE subgrid style"
    rsubgridstyle = :dash
    "Linewidth of the RESISTANCE subgrid"
    rsubgridwidth::Float32 = 0.7
    "Color of the RESISTANCE subgrid"
    rsubgridcolor = :black
    
    # REACTANCE grid
    "Sets the z value of the REACTANCE arcs grid. To Place the grid above plots set a value > 1"
    xgridz::Float32 = -50
    "Color of the REACTANCE grid"
    xgridcolor = :black
    "Linewidth of the REACTANCE grid"
    xgridwidth::Float32 = 0.7
    "Linestyle of the REACTANCE grid"
    xgridstyle = nothing
    "Controls if the REACTANCE grid is visible."
    xgridvisible::Bool = true
    "REACTANCE grid positions"
    xvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]
    #"REACTANCE subgrid positions"
    #xsubgrid::Vector{Float64} = [0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.25, 1.5, 3.5]
    "REACTANCE subgrid style"
    xsubgridstyle = :dash
    "Linewidth of the REACTANCE subgrid"
    xsubgridwidth::Float32 = 0.7
    "Color of the REACTANCE subgrid"
    xsubgridcolor = :black

    # CONDUCTANCE grid
    "Sets the z value of the CONDUCTANCE arcs grid. To Place the grid above plots set a value > 1"
    ggridz::Float32 = -50
    "Color of the CONDUCTANCE grid"
    ggridcolor = :black
    "Linewidth of the CONDUCTANCE grid"
    ggridwidth::Float32 = 0.7
    "Linestyle of the CONDUCTANCE grid"
    ggridstyle = nothing
    "Controls if the CONDUCTANCE grid is visible."
    ggridvisible::Bool = true
    "CONDUCTANCE grid positions"
    gvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]
    #"CONDUCTANCE subgrid positions"
    #gsubgrid::Vector{Float64} = [0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.25, 1.5, 3.5]
    "CONDUCTANCE subgrid style"
    gsubgridstyle = :dash
    "Linewidth of the CONDUCTANCE subgrid"
    gsubgridwidth::Float32 = 0.7
    "Color of the CONDUCTANCE subgrid"
    gsubgridcolor = :black

    # SUSCEPTANCE  grid
    "Sets the SUSCEPTANCE value of the arcs grid. To Place the grid above plots set a value > 1"
    bgridz::Float32 = -50
    "Color of the SUSCEPTANCE grid"
    bgridcolor = :black
    "Linewidth of the SUSCEPTANCE grid"
    bgridwidth::Float32 = 0.7
    "Linestyle of the SUSCEPTANCE grid"
    bgridstyle = nothing
    "Controls if the SUSCEPTANCE grid is visible."
    bgridvisible::Bool = true
    "SUSCEPTANCE grid positions"
    bvals::Vector{Float64} = [0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 20.0]
    #"SUSCEPTANCE subgrid positions"
    #bsubgrid::Vector{Float64} = [0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.25, 1.5, 3.5]
    "SUSCEPTANCE subgrid style"
    bsubgridstyle = :dash
    "Linewidth of the SUSCEPTANCE subgrid"
    bsubgridwidth::Float32 = 0.7
    "Color of the SUSCEPTANCE subgrid"
    bsubgridcolor = :black

    # TICKS SECTIONS
    "Align of the R ticks"
    tickalign = (:center, :center)
    "Controls if we draw a box behind the text"
    tickbox::Bool = true
    
    # CUT GRID CONTROL 
    "Values controling the cut of the grid R"
    rcutvals::Vector{Float64} = Float64[]
    "Values controling the cut of the grid X"
    xcutvals::Vector{Float64} = Float64[]
    "Values controling the cut of the grid R"
    rsubcutvals::Vector{Float64} = Float64[]
    "Values controling the cut of the grid X"
    xsubcutvals::Vector{Float64} = Float64[]
    "Threshold controling the cut of the grid"
    threshold = (100, 100)

    # REACTANCE Ticks 
    "Controls if the exterior circunference ticks are visible"
    xtickvisible::Bool = true
    "The formatter for the exterior ticks."
    xtickformat = Makie.automatic
    "The fontsize of the exterior tick labels."
    xticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), inherit(scene, :fontsize, 16))
    "The font of the exterior tick labels."
    xticklabelfont = inherit(scene, (:Axis, :yticklabelfont), inherit(scene, :font, Makie.defaultfont()))
    "The color of the exterior tick labels."
    xticklabelcolor = inherit(scene, (:Axis, :yticklabelcolor), inherit(scene, :textcolor, :black))
    "Padding of the exterior ticks label."
    xticklabelpad::Float32 = 4.5f0
    "The width of the outline of exterior ticks. Setting this to 0 will remove the outline."
    xticklabelstrokewidth::Float32 = 0.0
    "The color of the outline of exterior ticks. By default this uses the background color."
    xticklabelstrokecolor = automatic

    # RESISTANCE Ticks
    "The formatter for the r ticks"
    rtickformat = Makie.automatic
    "The fontsize of the RESISTANCE tick labels."
    rticklabelsize::Float32 = inherit(scene, (:Axis, :yticklabelsize), inherit(scene, :fontsize, 16))
    "The font of the r tick labels."
    rticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
    "The color of the r tick labels."
    rticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
    "The width of the outline of r ticks. Setting this to 0 will remove the outline."
    rticklabelstrokewidth::Float32 = 0.0
    "The color of the outline of r ticks. By default this uses the background color."
    rticklabelstrokecolor = automatic
    "Padding of the r ticks label."
    rticklabelpad::Float32 = 4f0
    "Controls if the r ticks are visible."
    rtickvisible::Bool = inherit(scene, (:Axis, :xticklabelsvisible), true)
    "The angle in radians along which the r ticks are printed."
    rtickangle::Float32 = 0.0

    # SUSCEPTANCE Ticks 
    "Controls if the exterior circunference ticks are visible"
    btickvisible::Bool = true
    "The formatter for the exterior ticks."
    btickformat = Makie.automatic
    "The fontsize of the exterior tick labels."
    bticklabelsize::Float32 = inherit(scene, (:Axis, :xticklabelsize), inherit(scene, :fontsize, 16))
    "The font of the exterior tick labels."
    bticklabelfont = inherit(scene, (:Axis, :yticklabelfont), inherit(scene, :font, Makie.defaultfont()))
    "The color of the exterior tick labels."
    bticklabelcolor = inherit(scene, (:Axis, :yticklabelcolor), inherit(scene, :textcolor, :black))
    "Padding of the exterior ticks label."
    bticklabelpad::Float32 = 4f0
    "The width of the outline of exterior ticks. Setting this to 0 will remove the outline."
    bticklabelstrokewidth::Float32 = 0.0
    "The color of the outline of exterior ticks. By default this uses the background color."
    bticklabelstrokecolor = automatic

    # CONDUCTANCE Ticks
    "The formatter for the CONDUCTANCE ticks"
    gtickformat = Makie.automatic
    "The fontsize of the CONDUCTANCE btick labels."
    gticklabelsize::Float32 = inherit(scene, (:Axis, :yticklabelsize), inherit(scene, :fontsize, 16))
    "The font of the CONDUCTANCE tick labels."
    gticklabelfont = inherit(scene, (:Axis, :xticklabelfont), inherit(scene, :font, Makie.defaultfont()))
    "The color of the CONDUCTANCE tick labels."
    gticklabelcolor = inherit(scene, (:Axis, :xticklabelcolor), inherit(scene, :textcolor, :black))
    "The width of the outline of CONDUCTANCE ticks. Setting this to 0 will remove the outline."
    gticklabelstrokewidth::Float32 = 0.0
    "The color of the outline of CONDUCTANCE ticks. By default this uses the background color."
    gticklabelstrokecolor = automatic
    "Padding of the CONDUCTANCE ticks label."
    gticklabelpad::Float32 = 4f0
    "Controls if the CONDUCTANCE ticks are visible."
    gtickvisible::Bool = true
    "The angle in radians along which the CONDUCTANCE ticks are printed."
    gtickangle::Float32 = 0.0

    #Interactivity
    "Locks interactive panning in the x direction."
    xpanlock::Bool = false
    "Locks interactive panning in the y direction."
    ypanlock::Bool = false
    "Locks interactive zoom in the x direction."
    xzoomlock::Bool = false
    "Locks interactive zoom in the y direction."
    yzoomlock::Bool = false
    "The key for limiting panning to the x direction."
    xpankey::Makie.Keyboard.Button = Makie.Keyboard.x
    "The key for limiting panning to the y direction."
    ypankey::Makie.Keyboard.Button = Makie.Keyboard.y
    "The key for limiting zooming to the x direction."
    xzoomkey::Makie.Keyboard.Button = Makie.Keyboard.x
    "The key for limiting zooming to the y direction."
    yzoomkey::Makie.Keyboard.Button = Makie.Keyboard.y
    "The button for panning."
    panbutton::Makie.Mouse.Button = Makie.Mouse.right
    "Button that needs to be pressed to allow scroll zooming."
    zoombutton::Union{Bool, Makie.Keyboard.Button} = true

end

end
