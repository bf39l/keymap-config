local movement = {}
local utils = require("modules.window.utils")

function movement.By(direction, move)
    local win = hs.window.frontmostWindow()
    if not win or move == 0 then return end

    local wf = win:frame()
    local sf = win:screen():frame()

    local newFrame = hs.geometry.copy(wf)

    if direction == utils.Direction.LEFT then
        newFrame.x = wf.x - move

    elseif direction == utils.Direction.RIGHT then
        newFrame.x = wf.x + move

    elseif direction == utils.Direction.UPPER then
        newFrame.y = wf.y - move

    elseif direction == utils.Direction.LOWER then
        newFrame.y = wf.y + move
    end

    -- Keep window inside screen bounds
    if newFrame.x < sf.x then
        newFrame.x = sf.x
    end

    if newFrame.y < sf.y then
        newFrame.y = sf.y
    end

    if newFrame.x + newFrame.w > sf.x + sf.w then
        newFrame.x = sf.x + sf.w - newFrame.w
    end

    if newFrame.y + newFrame.h > sf.y + sf.h then
        newFrame.y = sf.y + sf.h - newFrame.h
    end

    win:setFrame(newFrame)
end

return movement