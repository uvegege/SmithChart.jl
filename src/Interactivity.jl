#Are rightdragstart, rightdragstop, etc better options?
# Can I make it with "on(...) do event ...
function interactivity_smithchart(ax)
    deregister_interaction!(ax, :rectanglezoom)
    register_interaction!(ax, :custominteraction) do event::MouseEvent, axis
        if event.type === MouseEventTypes.rightdrag
            act_x, act_y = event.px
            prev_x, prev_y = event.prev_px
            sign_x = sign(prev_x - act_x)
            sign_y = sign(prev_y - act_y)
            lims = ax.targetlimits[]
            ox, oy = lims.origin
            wx, wy = lims.widths
            xlims = (ox, ox+wx)
            ylims = (oy, oy+wy)
            #limit x-axis
            if xlims[2] > 1.1 && sign_x == 1
                ax.xpanlock[] = true
            elseif xlims[1] < -1.1 && sign_x == -1
                ax.xpanlock[] = true
            else
                ax.xpanlock[] = false
            end
            # Limit y-axis
            if ylims[2] > 1.1 && sign_y == 1
                ax.ypanlock[] = true
            elseif ylims[1] < -1.1 && sign_y == -1
                ax.ypanlock[] = true
            else
                ax.ypanlock[] = false
            end
        end
    end
    
    on(events(ax).scroll, priority = 100) do event
        _, sval = event
        sign_scroll = sign(sval)
        lims = ax.targetlimits[]
        ox, oy = lims.origin
        wx, wy = lims.widths
        xlims = (ox, ox+wx)
        ylims = (oy, oy+wy)
        if (xlims[2] > 1.2 || xlims[1] < -1.2 || ylims[2] > 1.2 || ylims[1] < -1.2) && sign_scroll == -1
            reset_limits!(ax) 
            return Consume(true)
        else 
            return Consume(false)
        end 
    end

    smith_plot = findfirst(p -> p isa Plot{smithchart}, ax.scene.plots)
    if !isnothing(smith_plot)
        on(ax.targetlimits, priority = 1) do _
            sm_plot = ax.scene.plots[smith_plot]
            lims = ax.targetlimits[]
            p_limits = sm_plot.prev_limits[]
            if lims != p_limits
                sm_plot.limits[], sm_plot.prev_limits[] = lims, sm_plot.limits[]
            end
        end
    end
end
