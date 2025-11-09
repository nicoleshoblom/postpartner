-- Opens https://app.classlist.com/school/#/announcements/create in Google Chrome profile "Nicole"

local M = {}

local URL = "https://app.classlist.com/school/#/announcements/create"
local CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
local LOCAL_STATE = os.getenv("HOME") .. "/Library/Application Support/Google/Chrome/Local State"

-- Return the internal profile directory (e.g., "Default", "Profile 1") for a given visible name (e.g., "Nicole")
local function findProfileDirectoryByName(visibleName)
  -- Read Local State JSON (contains profile.info_cache mapping)
  local fh = io.open(LOCAL_STATE, "r")
  if not fh then return nil end
  local content = fh:read("*a"); fh:close()
  local ok, data = pcall(hs.json.decode, content)
  if not ok or type(data) ~= "table" then return nil end

  local infoCache = (((data or {}).profile) or {}).info_cache
  if type(infoCache) ~= "table" then return nil end

  for dirName, meta in pairs(infoCache) do
    if type(meta) == "table" and meta.name == visibleName then
      return dirName -- e.g. "Profile 2"
    end
  end
  return nil
end

-- Open URL in a specific profile (by visible name), falling back to "Default" if not found
local function openInChromeProfile(visibleName, url)
  local dir = findProfileDirectoryByName(visibleName) or "Default"

  -- Launch Chrome with explicit profile + URL.
  -- Use the binary (not `open -a`) so the --args are respected.
  local cmd = string.format([[%q --profile-directory=%q "%s"]], CHROME_BIN, dir, url)
  hs.task.new("/bin/sh", nil, {"-c", cmd}):start()
end

function M.run()
  openInChromeProfile("Nicole", URL)
end

return M