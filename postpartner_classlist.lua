local M = {}

local function go_to_ClassYearGroup_filter()
    local elementname = nil
    while elementname ~= "To one or more Class, Year, Group" do
        hs.eventtap.keyStroke({}, "tab")
        local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
        elementname = ax:attributeValue("AXPlaceholderValue")
    end
end

function M.run(messagepath)
    -- open a chrome window in my Nicole profile and go to classlist url for making announcements
    --to do: remove this once you add code to wait to do all the tabs until chrome window is active
    hs.application.launchOrFocus("Google Chrome")
    
    hs.timer.usleep(400000)
    hs.execute('open -na "Google Chrome" --args --new-window --profile-directory="Default" "https://app.classlist.com/school/#/announcements/create"')

    hs.timer.usleep(2000000)
    go_to_ClassYearGroup_filter()

    --type in filter you want
    hs.eventtap.keyStrokes("Sandpipers 2S")

    --go to subject field
    hs.timer.usleep(1500000)
    hs.eventtap.keyStroke({}, "tab")
    hs.eventtap.keyStroke({}, "tab")

    --load subject
    local file = io.open(messagepath, "r")
    if file then
        local firstLine = file:read("*l")  -- read first line
        file:close()
        --set subject
        if firstLine then
            hs.pasteboard.setContents(firstLine)
            hs.eventtap.keyStroke({"cmd"}, "v")
        else
            hs.alert.show("File is empty")
        end
    else
        hs.alert.show("File not found")
    end

    --go to announcement body
    hs.timer.usleep(200000)
    hs.eventtap.keyStroke({}, "tab")

    --load announcement message
    local file = io.open(messagepath, "r")
    if file then
        file:read("*l")
        file:read("*l")
        local rest = file:read("*a")
        file:close()
        --set subject
        if rest then
            hs.pasteboard.setContents(rest)
            hs.eventtap.keyStroke({"cmd"}, "v")
        else
            hs.alert.show("File is empty")
        end
    else
        hs.alert.show("File not found")
    end

    --send announcement
    hs.timer.usleep(700000)
    while elementname ~= "Send" do
        hs.eventtap.keyStroke({}, "tab")
        local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
        elementname = ax:attributeValue("AXTitle")
    end
    -- hs.eventtap.keyStroke({}, "return")
    --hs.alert.show("Ready to send announcement now")
end

return M