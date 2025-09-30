local M={}

local activateKakaoChatList = require("open_kakaotalk")
local BUNDLE_ID = "com.kakao.KakaoTalkMac"

local function isKakaoFrontmost()
  local app = hs.application.frontmostApplication()
  return app and (app:bundleID() == BUNDLE_ID)
end

function M.run(query)
  if type(query) ~= "string" or query == "" then
    hs.alert.show("find_kakaotalk_chat: provide a chat name to search")
    return false
  end

  activateKakaoChatList.run() --search bar already open after this command

  --  -- After 1s, proceed (and retry until KakaoTalk is frontmost)
  -- local attempts, maxAttempts, retryDelay = 0, 15, 0.12
  -- local function step()
  --   attempts = attempts + 1

  --   if not isKakaoFrontmost() then
  --     if attempts < maxAttempts then
  --       hs.timer.doAfter(retryDelay, step)
  --     else
  --       hs.alert.show("KakaoTalk not frontmost; cannot type search")
  --     end
  --     return
  --   end

    -- 2) Open the search bar (Cmd+F)
    hs.eventtap.keyStroke({"cmd"}, "f")
    hs.timer.usleep(90 * 1000) -- small settle

    -- 3) Type the chat name (clear first)
    hs.eventtap.keyStroke({"cmd"}, "a")
    hs.eventtap.keyStroke({}, "delete")
    hs.eventtap.keyStrokes(query)
    hs.timer.usleep(80 * 10000)

    -- -- 4) Press Enter to open the top result
    -- hs.eventtap.keyStroke({}, "down")
    -- hs.eventtap.keyStroke({}, "return")
  -- end

  -- hs.timer.doAfter(1.0, step)  -- 1) wait one second
  -- return true
end

return M

