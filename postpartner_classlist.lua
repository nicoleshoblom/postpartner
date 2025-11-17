local M = {}

function M.run()
    -- hs.application.launchOrFocus("Google Chrome")

    -- hs.timer.usleep(1000000)
    hs.execute('open -na "Google Chrome" --args --new-window --profile-directory="Default" "https://app.classlist.com/school/#/announcements/create"')
end

return M