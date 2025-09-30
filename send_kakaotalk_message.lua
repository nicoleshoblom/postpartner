-- write_kakaotalk_message.lua
-- Writes a message into the active KakaoTalk chat message field.
-- Assumes the chat window is already frontmost and the text cursor is in the input field.

local M = {}

-- Safe paste helper (handles emoji/special chars better than raw keystrokes)
local function pasteText(str)
  local prev = hs.pasteboard.getContents()
  hs.pasteboard.setContents(str or "")
  hs.timer.usleep(150000) -- small delay to ensure pasteboard is ready
  hs.eventtap.keyStroke({ "cmd" }, "v") -- paste
  -- restore clipboard (best-effort, async so we don't block)
  hs.timer.doAfter(0.2, function()
    if prev ~= nil then hs.pasteboard.setContents(prev) end
  end)
end

local activate_chat = require("activate_kakaotalk_chat")

--- Write a message to the currently active KakaoTalk chat.
-- @param message string: the text to write (not sent).
-- @param opts table|nil: { requireFrontmost = true } to enforce KakaoTalk is frontmost.
function M.send(chatName, message, opts)
  activate_chat.run(chatName)

  opts = opts or {}
  if type(message) ~= "string" or #message == 0 then
    hs.alert.show("No message provided.")
    return false
  end

  local front = hs.application.frontmostApplication()
  local isKakaoFront = (front and (front:name() == "KakaoTalk"))
  if opts.requireFrontmost ~= false and not isKakaoFront then
    hs.alert.show("Bring the KakaoTalk chat to the front first.")
    return false
  end

  pasteText(message)

  hs.eventtap.keyStroke({}, "return", 0)

  local win = hs.window.frontmostWindow()
  if win then win:close() end
  return true
end

return M

