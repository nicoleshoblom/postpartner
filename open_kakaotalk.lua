-- restart_kakaotalk_clean.lua
-- Close all KakaoTalk windows (if any) silently (no beep), then reopen KakaoTalk and focus it.

local M = {}

local exitFS = require("exit_fullscreen")

local BUNDLE_ID    = "com.kakao.KakaoTalkMac"
local APP_NAME     = "KakaoTalk"
local TARGET_TITLE = "KakaoTalk" -- main chat list window title (usually "KakaoTalk")

-- ---- Utilities ----

local function getApp()
  return hs.application.get(BUNDLE_ID) or hs.appfinder.appFromName(APP_NAME)
end

local function waitUntil(fn, timeout)
  local deadline = hs.timer.absoluteTime() + (timeout or 5) * 1e9
  while hs.timer.absoluteTime() < deadline do
    if fn() then return true end
    hs.timer.usleep(100000) -- 0.1s
  end
  return fn()
end

local function countOpenWindows(app)
  if not (app and app:isRunning()) then return 0 end
  local n = 0
  for _, w in ipairs(app:allWindows()) do
    if w and w:isStandard() and not w:isMinimized() then n = n + 1 end
  end
  return n
end

-- Close all KakaoTalk windows safely (avoid system beeps).
local function closeAllKakaoWindows()
  local app = getApp()
  if not app then return true end

  -- Make KakaoTalk frontmost so any fallback actions go to the right place.
  app:activate(true)
  waitUntil(function()
    local a = getApp()
    return a and a:isFrontmost()
  end, 2)

  -- First try Accessibility close on each standard window (silent).
  for _, w in ipairs(app:allWindows()) do
    if w and w:isStandard() and not w:isMinimized() then
      w:close() -- AXClose: no beep
      hs.timer.usleep(120000) -- small settle time
    end
  end

  -- If anything remains, only use a menu Close if it's actually enabled.
  if countOpenWindows(app) > 0 then
    local mi = app:findMenuItem({"File", "Close"}) or
               app:findMenuItem({"File", "Close Window"}) or
               app:findMenuItem({"Window", "Close"})
    if mi and mi.enabled then
      app:selectMenuItem(mi)
      hs.timer.usleep(150000)
    end
  end

  -- Wait for windows to be gone.
  return waitUntil(function()
    local a = getApp()
    return a and countOpenWindows(a) == 0
  end, 5)
end

-- Wait for any standard window to appear after relaunch/open.
local function waitForAnyWindow(timeout)
  return waitUntil(function()
    local a = getApp()
    return a and countOpenWindows(a) > 0
  end, timeout or 8)
end

-- Prefer and focus the main "KakaoTalk" window if it exists.
local function focusPreferredWindow()
  local app = getApp()
  if not app then return false end
  local target = nil
  for _, w in ipairs(app:allWindows()) do
    if w and w:isStandard() and not w:isMinimized() then
      if w:title() == TARGET_TITLE then
        target = w
        break
      end
    end
  end
  local win = target or app:mainWindow() or app:focusedWindow()
  if win then
    win:raise(); win:focus()
    return true
  end
  app:activate(true)
  return false
end

-- ---- Public API ----

--- Close all KakaoTalk windows (if any), then open KakaoTalk and focus it.
--- Returns true on success (a fresh window is open and focused), false otherwise.
function M.run()
    local app = getApp()
    local hadOpen = app and (countOpenWindows(app) > 0)

    if hadOpen then
        local closed = closeAllKakaoWindows()
        if not closed then
        hs.alert.show("KakaoTalk: failed to close all windows (continuing)")
        end
    end

    -- Launch or focus KakaoTalk.
    local ok = hs.application.launchOrFocusByBundleID(BUNDLE_ID)
    if not ok then hs.application.launchOrFocus(APP_NAME) end

    -- Wait for a fresh window to appear.
    local appeared = waitForAnyWindow(8)
    if not appeared then
        hs.alert.show("KakaoTalk: no window appeared after opening")
        return false
    end

    -- Focus the preferred window.
    focusPreferredWindow()
    return true
    end

    return M