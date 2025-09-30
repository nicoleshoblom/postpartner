local M = {}

local writeKakaoMessage = require("write_kakaotalk_message")

function M.run(query, msg, opts)
    writeKakaoMessage.run(query, msg, opts)
    hs.timer.usleep(80 * 10000)
    hs.eventtap.keyStroke({}, "return")
end

return M
