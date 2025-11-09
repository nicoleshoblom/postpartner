local M = {}

local post_to_kakaotalk = require("postpartner_kakaotalk")

function M.run(chatname, messagepath)
    post_to_kakaotalk.run(chatname, messagepath)

    hs.timer.doAfter(0.7, function()
        hs.application.launchOrFocus("Google Chrome")
    end)

    hs.timer.doAfter(0.7, function()
        hs.execute('open -na "Google Chrome" --args --new-window --profile-directory="Default" "https://app.classlist.com/school/#/announcements/create"')
    end)

    hs.timer.doAfter(3.0, function()
        hs.alert.show("try to tab")
        hs.eventtap.keyStroke({}, "tab")
        local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
        hs.alert.show(ax:attributeValue("AXPlaceholderValue"))
    end)
end
return M