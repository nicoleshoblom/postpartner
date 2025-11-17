local M = {}

local post_to_kakaotalk = require("postpartner_kakaotalk")
local post_to_classlist = require("postpartner_classlist")

function M.run(chatname, messagepath)
    post_to_kakaotalk.run(chatname, messagepath)
    
    -- hs.timer.usleep(2000000)

    --post_to_classlist.run(chatname, messagepath)

    -- hs.timer.doAfter(2.0, function()
    --     local elementname = nil
    --     while elementname ~= "To one or more Class, Year, Group" do
    --         hs.eventtap.keyStroke({}, "tab")
    --         local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
    --         elementname = ax:attributeValue("AXPlaceholderValue")
    --     end
    --     hs.eventtap.keyStrokes("Sandpipers 2S")
    --     hs.timer.doAfter(2.0, function()
    --         hs.eventtap.keyStroke({}, "tab")
    --         hs.eventtap.keyStroke({}, "tab")
    --         local file = io.open(messagepath, "r")
    --         if file then
    --             local firstLine = file:read("*l")  -- read first line
    --             file:close()
    --             --set subject
    --             if firstLine then
    --                 hs.pasteboard.setContents(firstLine)
    --                 hs.eventtap.keyStroke({"cmd"}, "v")
    --                 hs.alert.show("Copied first line: " .. firstLine)
    --             else
    --                 hs.alert.show("File is empty")
    --             end
    --         else
    --             hs.alert.show("File not found")
    --         end

    --         --go to announcement body
    --         hs.eventtap.keyStroke({}, "tab")

    --         --paste in announcement
    --         local file = io.open(messagepath, "r")
    --         if file then
    --             file:read("*l")
    --             file:read("*l")
    --             local rest = file:read("*a")
    --             file:close()
    --             --set subject
    --             if rest then
    --                 hs.pasteboard.setContents(rest)
    --                 hs.eventtap.keyStroke({"cmd"}, "v")
    --                 hs.alert.show("Pasted announcement body")
    --             else
    --                 hs.alert.show("File is empty")
    --             end
    --         else
    --             hs.alert.show("File not found")
    --         end

    --         --send
    --         while elementname ~= "Send" do
    --             hs.eventtap.keyStroke({}, "tab")
    --             local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
    --             elementname = ax:attributeValue("AXTitle")
    --             hs.alert.show(elementname)
    --         end
    --         --hs.eventtap.keyStroke({}, "return")
    --         --hs.alert.show("Ready to send announcement now")

    --     end)
    -- end)

end
return M