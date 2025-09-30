local M = {}

local findKakaoChat = require("find_kakaotalk_chat")

function M.run(query)
    findKakaoChat.run(query) -- kakaotalk chatlist already active, and wanted chat is at the top

    hs.eventtap.keyStroke({}, "down")
    hs.eventtap.keyStroke({}, "return")
    hs.timer.usleep(80 * 10000)
end

return M