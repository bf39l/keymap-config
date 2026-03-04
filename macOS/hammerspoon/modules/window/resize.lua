local resize = {}
local utils = require("modules.window.utils")

function resize.toHalf(direction)
    local win = hs.window.frontmostWindow()
    if win then
        local screen = win:screen()
        local frame = screen:frame()
        local newFrame = hs.geometry.copy(frame)

        if direction == utils.Direction.LEFT then
            newFrame.w = frame.w / 2
        elseif direction == utils.Direction.RIGHT then
            newFrame.x = frame.x + frame.w / 2
            newFrame.w = frame.w / 2
        elseif direction == utils.Direction.UPPER then
            newFrame.h = frame.h / 2
        elseif direction == utils.Direction.LOWER then
            newFrame.y = frame.y + frame.h / 2
            newFrame.h = frame.h / 2
        end

        win:setFrame(newFrame)
    end
end

function resize.toggleMax(win)
    if not win then return end

    local screen = win:screen()
    local frame = screen:frame()
    local id = win:id()

    local state = utils.windowState[id] or { isMaximized = true }

    if state.isMaximized then
        -- Shrink to almost max
        local newW = frame.w * (5 / 6)
        local newH = frame.h * (5 / 6)
        local newX = frame.x + (frame.w - newW) / 2
        local newY = frame.y + (frame.h - newH) / 2

        win:setFrame({
            x = newX,
            y = newY,
            w = newW,
            h = newH
        })

        state.isMaximized = false
    else
        -- Maximize
        win:setFrame(frame)
        state.isMaximized = true
    end

    -- Save state
    utils.windowState[id] = state
end


function resize.by(grow, minWidth, minHeight, edgeGap)
    local win = hs.window.frontmostWindow()
    if not win or grow == 0 then return end

    local wf = win:frame()
    local sf = win:screen():frame()

    minWidth = minWidth or 400
    minHeight = minHeight or 400
    edgeGap = edgeGap or 10

    if grow > 0 then
        -- EXPAND logic
        local leftRoom   = math.min(grow, wf.x - sf.x)
        local rightRoom  = math.min(grow, (sf.x + sf.w) - (wf.x + wf.w))
        local topRoom    = math.min(grow, wf.y - sf.y)
        local bottomRoom = math.min(grow, (sf.y + sf.h) - (wf.y + wf.h))

        if leftRoom < grow then
            local extra = grow - leftRoom
            rightRoom = math.min(grow + extra, (sf.x + sf.w) - (wf.x + wf.w))
        end
        if rightRoom < grow then
            local extra = grow - rightRoom
            leftRoom = math.min(grow + extra, wf.x - sf.x)
        end
        if topRoom < grow then
            local extra = grow - topRoom
            bottomRoom = math.min(grow + extra, (sf.y + sf.h) - (wf.y + wf.h))
        end
        if bottomRoom < grow then
            local extra = grow - bottomRoom
            topRoom = math.min(grow + extra, wf.y - sf.y)
        end

        win:setFrame({
            x = wf.x - leftRoom,
            y = wf.y - topRoom,
            w = wf.w + leftRoom + rightRoom,
            h = wf.h + topRoom + bottomRoom
        })

    else
        -- SHRINK logic
        local shrink = -grow
        local newFrame = hs.geometry.copy(wf)

        local canShrinkWidth = (wf.w - shrink * 2 >= minWidth)
        local canShrinkHeight = (wf.h - shrink * 2 >= minHeight)

        local leftEdgeNear   = math.abs(wf.x - sf.x) <= edgeGap
        local rightEdgeNear  = math.abs((wf.x + wf.w) - (sf.x + sf.w)) <= edgeGap
        local topEdgeNear    = math.abs(wf.y - sf.y) <= edgeGap
        local bottomEdgeNear = math.abs((wf.y + wf.h) - (sf.y + sf.h)) <= edgeGap

        local allEdgesNear = leftEdgeNear and rightEdgeNear and topEdgeNear and bottomEdgeNear
        
        if allEdgesNear then
            -- All edges pinned, normal centered shrink
            newFrame.x = wf.x + shrink
            newFrame.y = wf.y + shrink
            newFrame.w = wf.w - shrink * 2
            newFrame.h = wf.h - shrink * 2
        else
            -- Shrink with edge locking
            -- Width shrink logic
            if canShrinkWidth then
                if not leftEdgeNear and not rightEdgeNear then
                    newFrame.x = wf.x + shrink
                    newFrame.w = wf.w - shrink * 2
                elseif leftEdgeNear and not rightEdgeNear then
                    newFrame.w = wf.w - shrink
                elseif not leftEdgeNear and rightEdgeNear then
                    newFrame.x = wf.x + shrink
                    newFrame.w = wf.w - shrink
                end
                -- if both edges are pinned, skip width shrink
            end

            -- Height shrink logic
            if canShrinkHeight then
                if not topEdgeNear and not bottomEdgeNear then
                    newFrame.y = wf.y + shrink
                    newFrame.h = wf.h - shrink * 2
                elseif topEdgeNear and not bottomEdgeNear then
                    newFrame.h = wf.h - shrink
                elseif not topEdgeNear and bottomEdgeNear then
                    newFrame.y = wf.y + shrink
                    newFrame.h = wf.h - shrink
                end
                -- if both edges are pinned, skip height shrink
            end
        end

        win:setFrame(newFrame)
    end
end


return resize