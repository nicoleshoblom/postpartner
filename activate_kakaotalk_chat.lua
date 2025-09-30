-- /Users/nicole/pospartner/activate_kakaotalk_open_chat.lua
-- Open a KakaoTalk chat by name by targeting the search field, with a keystroke fallback.
-- Requires: Hammerspoon Accessibility permission.
-- Usage:
--   local openChat = require("activate_kakaotalk_open_chat")
--   openChat.run("Jeremy Shoblom", { clearSearch = true, debug = true })

local M = {}

local BUNDLE_ID    = "com.kakao.KakaoTalkMac"
local APP_NAME     = "KakaoTalk"
local CHATLIST_WIN = "KakaoTalk"

-- ----- utils -----
local function sleep(sec) hs.timer.usleep(math.floor(sec * 1e6)) end
local function attr(el, key)
  local ok, v = pcall(function() return el:attributeValue(key) end)
  return ok and v or nil
end
local function setAttr(el, key, val)
  return pcall(function() el:setAttributeValue(key, val) end)
end
local function perform(el, action)
  return pcall(function() el:performAction(action) end)
end

local function bringAppFront()
  if hs.application.launchOrFocusByBundleID then
    hs.application.launchOrFocusByBundleID(BUNDLE_ID)
  else
    hs.application.launchOrFocus(APP_NAME)
  end
  sleep(0.2)
  return hs.application.get(BUNDLE_ID) or hs.appfinder.appFromName(APP_NAME)
end

local function getChatlistWindow(app)
  if not app then return nil end
  for _, w in ipairs(app:allWindows()) do
    if w:title() == CHATLIST_WIN and w:isStandard() and not w:isMinimized() then
      return w
    end
  end
  return app:mainWindow()
end

-- DFS search in AX tree
local function findDescendant(root, predicate, maxDepth)
  maxDepth = maxDepth or 9
  local function dfs(el, d)
    if not el or d > maxDepth then return nil end
    if predicate(el) then return el end
    local kids = attr(el, "AXChildren") or {}
    for _, k in ipairs(kids) do
      local hit = dfs(k, d + 1)
      if hit then return hit end
    end
    return nil
  end
  return dfs(root, 0)
end

-- Try to use AX to set the search field and open the first result
local function tryAXSearch(axWin, chatName, debug)
  -- Many Electron/React apps expose the search as AXSearchField (or a text field)
  local searchEl = findDescendant(axWin, function(el)
    local role = attr(el, "AXRole")
    return role == "AXSearchField" or role == "AXTextField"
  end, 6)

  if not searchEl then
    if debug then print("[KakaoTalk] AX search field not found") end
    return false
  end

  -- Focus the search field and set its value
  setAttr(searchEl, "AXFocused", true)
  sleep(0.05)
  local ok = setAttr(searchEl, "AXValue", chatName)
  if not ok then
    if debug then print("[KakaoTalk] Failed to set AXValue on search") end
    return false
  end

  -- Give UI time to populate results, then select first result:
  -- Down → Enter (works in most builds)
  sleep(0.12)
  hs.eventtap.keyStroke({}, "down", 0)
  sleep(0.04)
  hs.eventtap.keyStroke({}, "return", 0)

  return true
end

-- Fallback: keystroke-only method (Cmd-F → paste → Down → Enter)
local function tryKeystrokeSearch(chatName, debug)
  local prevPB = hs.pasteboard.getContents()
  hs.pasteboard.setContents(chatName)

  hs.eventtap.keyStroke({"cmd"}, "f", 0)  -- focus search bar
  sleep(0.06)
  hs.eventtap.keyStroke({"cmd"}, "v", 0)  -- paste name
  sleep(0.12)
  hs.eventtap.keyStroke({}, "down", 0)    -- highlight first result
  sleep(0.04)
  hs.eventtap.keyStroke({}, "return", 0)  -- open it

  -- restore clipboard
  hs.pasteboard.setContents(prevPB)

  return true
end

-- Public API
-- opts.clearSearch: bool (default true) -> send Escape to clear search filter
-- opts.debug: bool (default false)
function M.run(chatName, opts)
  assert(type(chatName) == "string" and chatName ~= "", "Provide a non-empty chat name")
  opts = opts or {}
  local clearSearch = (opts.clearSearch ~= false)
  local debug = opts.debug == true

  local app = bringAppFront()
  if not app then hs.alert.show("KakaoTalk not running"); return false end

  local win = getChatlistWindow(app)
  if not win then hs.alert.show("Chat list window not found"); return false end
  win:focus()
  sleep(0.05)

  local axWin = hs.axuielement.windowElement(win)
  if not axWin then hs.alert.show("AX error: no window element"); return false end

  -- 1) AX path
  local okAX = tryAXSearch(axWin, chatName, debug)
  if not okAX then
    -- 2) Keystroke fallback
    if debug then print("[KakaoTalk] Falling back to keystroke search") end
    tryKeystrokeSearch(chatName, debug)
  end

--   -- Optional: clear search field so your list returns to normal
--   if clearSearch then
--     sleep(0.15)
--     hs.eventtap.keyStroke({}, "escape", 0) -- many builds clear search with Esc
--   end

  return true
end

return M
