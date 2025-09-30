-- activate_kakaotalk_chatlist.lua
-- Focus the KakaoTalk app and bring the window titled exactly "KakaoTalk" to front.

local M = {}

local BUNDLE_ID    = "com.kakao.KakaoTalkMac"
local APP_NAME     = "KakaoTalk"
local TARGET_TITLE = "KakaoTalk"

-- Find the KakaoTalk window with the exact title "KakaoTalk"
local function findTargetWindow(app)
  if not app then return nil end
  for _, w in ipairs(app:allWindows()) do
    -- ignore minimized / non-standard utility panels
    if w and w:title() == TARGET_TITLE and w:isStandard() and not w:isMinimized() then
      return w
    end
  end
  return nil
end

local function focusTargetWindow()
  local app = hs.application.get(BUNDLE_ID) or hs.appfinder.appFromName(APP_NAME)
  if not (app and app:isRunning()) then return false end

  local win = findTargetWindow(app)
  if win then
    app:unhide()
    app:activate(true)
    win:raise()
    win:focus()
    return true
  end

  -- Fallback: just activate the app if the titled window isn't found yet
  app:unhide()
  app:activate(true)
  return false
end

function M.run()
  -- Launch or focus KakaoTalk first
  if hs.application.launchOrFocusByBundleID then
    hs.application.launchOrFocusByBundleID(BUNDLE_ID)
  else
    hs.application.launchOrFocus(APP_NAME)
  end

  -- Retry a few times because windows can appear/retitle shortly after activation
  local attempts, maxAttempts, delay = 0, 8, 0.15
  local function try()
    attempts = attempts + 1
    if focusTargetWindow() then return end
    if attempts < maxAttempts then
      hs.timer.doAfter(delay, try)
    else
      hs.alert.show("KakaoTalk window \"KakaoTalk\" not found")
    end
  end
  hs.timer.doAfter(delay, try)
end

return M