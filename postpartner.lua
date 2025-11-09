local M = {}

function M.run(chatname, messagepath, chromeprofile)
    --open kakaotalk
    hs.application.launchOrFocus("KakaoTalk")

    --open kakaotalk window titled "Kakaotalk"
    hs.timer.doAfter(0.4, function()
    local app = hs.application.find("KakaoTalk")
    if not app then return end
    -- Find a window titled exactly "KakaoTalk"
    for _, w in ipairs(app:allWindows()) do
      if w:title() == "KakaoTalk" then
        w:unminimize()
        w:raise()
        w:focus()
        return
      end
    end
    hs.alert('Window "KakaoTalk" not found')
  end)

    --hit command 2 to ensure chatlist is open
    hs.eventtap.keyStroke({"cmd"}, "2")

    --hit command f to open search bar
    hs.eventtap.keyStroke({"cmd"}, "f")

    --type name of chat we went to send message to
    hs.eventtap.keyStrokes(chatname)

    --open chatname chat window
    hs.timer.doAfter(0.7, function()
        hs.eventtap.keyStroke({}, "down")
        hs.eventtap.keyStroke({}, "return")
    end)

    --clear any text in chat window
    hs.timer.doAfter(0.7, function()
        hs.eventtap.keyStroke({"cmd"}, "a")
        hs.eventtap.keyStroke({}, "delete")
    end)

    --load message to send from txt file
    hs.timer.doAfter(0.7, function()
        local file = io.open(messagepath, "r")
        if not file then return end
        local text = file:read("*all")
        file:close()
        hs.pasteboard.setContents(text)
        hs.eventtap.keyStroke({"cmd"}, "v")
    end)

    --hit enter to send message in kakatalk chat window
    -- hs.timer.doAfter(0.7, function()
    --     hs.eventtap.keyStroke({}, "return")
    -- end)

    --Now for classlist - open google chrome window/profile where you are signed into classlist
end

return M