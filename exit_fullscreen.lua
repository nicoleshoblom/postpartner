-- exit_fullscreen.lua
-- Exits full screen for the current active window, if it's in full screen.

local M = {}

-- Small helper: wait until `fn()` is true (or timeout in seconds)
local function waitUntil(fn, timeout)
  local deadline = hs.timer.absoluteTime() + (timeout or 2) * 1e9
  while hs.timer.absoluteTime() < deadline do
    if fn() then return true end
    hs.timer.usleep(80000) -- 80ms
  end
  return fn()
end

-- Try several safe ways to exit fullscreen for the given window
local function exitFullscreenForWindow(win)
  if not win then return false end
  local app = win:application()

  -- 1) Native API path (best): setFullScreen(false)
  if win:isFullScreen() then
    win:setFullScreen(false)
    if waitUntil(function() return not win:isFullScreen() end, 2) then
      return true
    end
  else
    -- Already not fullscreen
    return false
  end

  -- 2) App menu fallback (if provided/enabled)
  if app then
    local candidates = {
      {"View",   "Exit Full Screen"},
      {"Window", "Exit Full Screen"},
    }
    for _, path in ipairs(candidates) do
      local mi = app:findMenuItem(path)
      if mi and mi.enabled then
        app:selectMenuItem(path)
        if waitUntil(function() return not win:isFullScreen() end, 2) then
          return true
        end
      end
    end
  end

  -- 3) Keyboard shortcut fallback (system default: Ctrl+Cmd+F)
  if app then
    hs.eventtap.keyStroke({"ctrl","cmd"}, "f", 0, app)
    if waitUntil(function() return not win:isFullScreen() end, 2) then
      return true
    end
  end

  return not win:isFullScreen()
end

--- Public: Exit fullscreen on the current active window if needed.
--- Returns:
---   true  -> fullscreen was exited (or it wasn’t fullscreen to begin with)
---   false -> failed to exit fullscreen
function M.run()
  local win = hs.window.frontmostWindow()
  if not win then return false end

  -- If not in full screen, nothing to do
  local fs = win:isFullScreen()
  if fs == false then return true end

  return exitFullscreenForWindow(win)
end

return M