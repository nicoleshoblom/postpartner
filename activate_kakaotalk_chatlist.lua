-- activate_kakaotalk_chatlist.lua
-- Ensures KakaoTalk is open and focuses the main "KakaoTalk" window if present.

local M = {}

local BUNDLE_ID    = "com.kakao.KakaoTalkMac"
local APP_NAME     = "KakaoTalk"
local TARGET_TITLE = "KakaoTalk"

--- Return {app=hs.application or nil, hasAnyWindows=bool, targetWin=hs.window or nil}
local function inspectKakao()
  local app = hs.application.get(BUNDLE_ID) or hs.appfinder.appFromName(APP_NAME)
  local hasAny = false
  local target = nil

  if app and app:isRunning() then
    for _, w in ipairs(app:allWindows()) do
      if w and w:isStandard() and not w:isMinimized() then
        hasAny = true
        if w:title() == TARGET_TITLE then target = w end
      end
    end
  end
  return app, hasAny, target
end

--- Wait up to `timeout` seconds for any standard KakaoTalk window to appear; return that window (or nil)
local function waitForAnyWindow(timeout)
  local deadline = hs.timer.absoluteTime() + timeout * 1e9
  while hs.timer.absoluteTime() < deadline do
    local app = hs.application.get(BUNDLE_ID) or hs.appfinder.appFromName(APP_NAME)
    if app then
      for _, w in ipairs(app:allWindows()) do
        if w and w:isStandard() and not w:isMinimized() then
          return w
        end
      end
    end
    hs.timer.usleep(100000) -- 0.1s
  end
  return nil
end

--- Ensure KakaoTalk is up, and focus the "KakaoTalk" window if available.
--- Returns true on success (a window focused), false otherwise.
function M.run()
  local app, hasAny, target = inspectKakao()

  -- 1) If no windows (or app not running), launch/focus the app
  if not app or not app:isRunning() or not hasAny then
    -- Try by bundle id first; fall back to name
    local ok = hs.application.launchOrFocusByBundleID(BUNDLE_ID)
    if not ok then hs.application.launchOrFocus(APP_NAME) end

    -- 2) Wait for a window to appear (up to 5s), then try to focus the target
    local win = waitForAnyWindow(5)
    if not win then return false end

    -- After it appears, check again for the exact "KakaoTalk" window
    local _, _, t2 = inspectKakao()
    if t2 then
      t2:raise(); t2:focus()
      return true
    else
      win:raise(); win:focus()
      return true
    end
  end

  -- 3) App has windows already: prefer the window named "KakaoTalk"
  if target then
    target:raise(); target:focus()
    return true
  end

  -- Fallback: focus best available KakaoTalk window
  local fallback = app:mainWindow() or app:focusedWindow()
  if not fallback then
    local wins = app:allWindows()
    fallback = wins and wins[1] or nil
  end
  if fallback then
    fallback:raise(); fallback:focus()
    return true
  end

  -- Last resort: just activate the app
  app:activate(true)
  return false
end

return M