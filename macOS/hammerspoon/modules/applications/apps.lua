local application = {}

--- Launch or focus application by app path (e.g. /Applications/iTerm.app).
--- Resolves bundle ID automatically, restores minimized windows,
--- and reopens new window via AppleScript if none exist.
-- @param appPath string - full path to the .app
function application.launchOrFocus(appPath)
    if type(appPath) ~= "string" then return end

    appPath = appPath:gsub("/+$", "") -- strip trailing slashes

    local task = hs.task.new("/usr/bin/mdls", function(exitCode, stdOut, stdErr)
        if exitCode ~= 0 or not stdOut then
            hs.alert.show("Failed to read bundle ID for: " .. appPath)
            return
        end

        local bundleID = stdOut:match('kMDItemCFBundleIdentifier%s+=%s+"(.-)"')
        if not bundleID then
            hs.alert.show("Bundle ID not found for: " .. appPath)
            return
        end

        local app = hs.application.get(bundleID)

        if app and app:isRunning() then
            app:activate()

            local windows = app:allWindows()
            local hadMinimized = false

            for _, win in ipairs(windows) do
                if win:isMinimized() then
                    win:unminimize()
                    hadMinimized = true
                end
            end

            local needsNewWindow = (#windows == 0) or (not hadMinimized and app:mainWindow() == nil)

            if needsNewWindow then
                -- First attempt: Cmd+N
                hs.timer.doAfter(0.3, function()
                    hs.eventtap.keyStroke({"cmd"}, "n")

                    -- After Cmd+N, check again after delay
                    hs.timer.doAfter(0.5, function()
                        local newApp = hs.application.get(bundleID)
                        if newApp and (#newApp:allWindows() == 0 or not newApp:mainWindow()) then
                            -- Cmd+N didn't work, try AppleScript
                            local as = string.format([[
                                tell application id "%s"
                                    activate
                                    if (count of windows) = 0 then
                                        try
                                            reopen
                                        on error
                                            try
                                                make new window
                                            end try
                                        end try
                                    end if
                                end tell
                            ]], bundleID)
                            hs.osascript.applescript(as)
                        end
                    end)
                end)
            end
        else
            local ok = hs.application.launchOrFocusByBundleID(bundleID)
            if not ok then
                hs.task.new("/usr/bin/open", nil, { "-a", appPath }):start()
            end
        end
    end, { "-name", "kMDItemCFBundleIdentifier", appPath })

    task:start()
end

return application