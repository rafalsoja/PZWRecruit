local DEFAULT_SETTINGS = {
    message = "Guild is recruiting! Looking for active players.",
    interval = 60, -- In minutes
    channel = "PZWTest",
    enableAlliance = false,
    enableHorde = false
}

local framePZW = CreateFrame("Frame")
local recruitTicker = nil

local function GetCustomChannelId(targetName)
    if not targetName then return nil end
    targetName = string.lower(targetName)
    local i = 1
    while true do
        local channelName, header, _, channelNumber = GetChannelDisplayInfo(i)
        if not channelName then break end
        if not header and string.lower(channelName) == targetName then
            return channelNumber
        end
        i = i + 1
    end
    return nil
end

-- Helper function to check if broadcasting is enabled for current faction
local function IsFactionEnabled()
    if not PZW_Settings then return false end
    local playerFaction = UnitFactionGroup("player")
    
    if playerFaction == "Alliance" and PZW_Settings.enableAlliance then
        return true
    elseif playerFaction == "Horde" and PZW_Settings.enableHorde then
        return true
    end
    
    return false
end

-- Global function to broadcast the message
function PZWRecruit_SendAnnouncement()
    if not PZW_Settings then return end

    if not IsFactionEnabled() then
        return
    end

    local channelId = GetCustomChannelId(PZW_Settings.channel)
    if channelId then
        SendChatMessage(PZW_Settings.message, "CHANNEL", nil, channelId)
        PZW_LastSendTime = time()
        print("[PZWRecruit] Announcement sent to channel: " .. PZW_Settings.channel)
        
        if PZWRecruitOptionsPanel and PZWRecruitOptionsPanel:IsShown() and PZWRecruitOptionsPanel.refresh then
            PZWRecruitOptionsPanel.refresh()
        end
    else
        print("[PZWRecruit] Error: Channel '" .. tostring(PZW_Settings.channel) .. "' not found.")
    end
end

-- Function to restart/update the ticker when settings change or on login
function PZWRecruit_RestartTicker()
    if recruitTicker then
        recruitTicker:Cancel()
        recruitTicker = nil
    end

    -- Run ticker check every 30 seconds
    recruitTicker = C_Timer.NewTicker(30, function()
        if PZW_LastSendTime == nil or PZW_Settings == nil then return end
        if not IsFactionEnabled() then return end

        local intervalInSeconds = (PZW_Settings.interval or 60) * 60
        local currentTime = time()

        if (currentTime - PZW_LastSendTime) >= intervalInSeconds then
            PZWRecruit_SendAnnouncement()
        end
    end)
end

framePZW:RegisterEvent("PLAYER_LOGIN")
framePZW:SetScript("OnEvent", function(self, event)
    if PZW_LastSendTime == nil then PZW_LastSendTime = 0 end
    if PZW_Settings == nil then PZW_Settings = {} end

    for k, v in pairs(DEFAULT_SETTINGS) do
        if PZW_Settings[k] == nil then
            PZW_Settings[k] = v
        end
    end

    if PZWRecruit_CreateOptionsPanel then
        PZWRecruit_CreateOptionsPanel(DEFAULT_SETTINGS)
    end

    PZWRecruit_RestartTicker()
end)