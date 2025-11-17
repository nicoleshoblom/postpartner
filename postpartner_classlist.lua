local M = {}

local function go_to_ClassYearGroup_filter()
    local elementname = nil
    while elementname ~= "To one or more Class, Year, Group" do
        hs.eventtap.keyStroke({}, "tab")
        local ax = hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement")
        elementname = ax:attributeValue("AXPlaceholderValue")
    end
end

function M.run()
    -- open a chrome window in my Nicole profile and go to classlist url for making announcements
    hs.execute('open -na "Google Chrome" --args --new-window --profile-directory="Default" "https://app.classlist.com/school/#/announcements/create"')

    -- go to the "To one or more Class, Year, Group" field
    hs.timer.usleep(100000)
    go_to_ClassYearGroup_filter()
end

return M