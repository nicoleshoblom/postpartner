local M = {}

local openKakaoChat = require("open_kakaotalk_top_chat")

function M.run(query, msg, opts)
    openKakaoChat.run(query) -- kakaotalk chatlist already active, and wanted chat is at the top
    opts = opts or {}
  local method = (opts.method or "paste"):lower()
  local restoreClipboard = (opts.restoreClipboard ~= false)
  local delayMs = tonumber(opts.delayMs) or 120

  if type(msg) ~= "string" or msg == "" then
    hs.alert.show("paste_msg: msg must be a non-empty string")
    return false
  end

  -- Normalize line endings (\r\n / \r -> \n) to avoid surprises
  msg = msg:gsub("\r\n", "\n"):gsub("\r", "\n")

  if method == "type" then
    -- Types the text (slower for long strings; honors \n)
    hs.eventtap.keyStrokes(msg)
    return true
  end

  -- Default: paste via clipboard (fast + exact)
  local prior = hs.pasteboard.getContents()
  hs.pasteboard.setContents(msg)

  -- Make sure target has focus (caller ensures active window is correct)
  hs.timer.usleep(60 * 1000)       -- tiny settle
  hs.eventtap.keyStroke({"cmd"}, "v", 0)

  if restoreClipboard then
    -- Restore clipboard after a short beat so the paste completes
    hs.timer.doAfter(delayMs / 1000, function()
      if prior == nil then
        -- clear if previously empty
        hs.pasteboard.clearContents()
      else
        hs.pasteboard.setContents(prior)
      end
    end)
  end

  return true
end

return M