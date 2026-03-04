local utils = {}

utils.Direction = {
    LEFT  = "left",
    RIGHT = "right",
    UPPER = "upper",
    LOWER = "lower"
}

utils.windowState = {}  
-- key: win:id(), value: { isMaximized = bool }

return utils