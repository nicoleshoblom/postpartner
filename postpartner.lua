local M = {}

local post_to_kakaotalk = require("postpartner_kakaotalk")
local post_to_classlist = require("postpartner_classlist")

function M.run(chatname, messagepath)
    post_to_kakaotalk.run(chatname, messagepath)
    
    hs.timer.usleep(200000)

    post_to_classlist.run(messagepath)

end
return M