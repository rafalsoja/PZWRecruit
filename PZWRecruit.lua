local DEFAULT_SETTINGS = {
    message = "Guild is recruiting! Looking for active players.",
    interval = 60,
    channel = "PZWTest",
    enableAlliance = false,
    enableHorde = false
}

local DEFAULT_STATS = {
    sentMessages = 0
}

local PREFIX = "|cff00aeef[PZWRecruit]|r "

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

function PZWRecruit_SendAnnouncement()
    if not PZW_Settings or not IsFactionEnabled() then return end

    local channelId = GetCustomChannelId(PZW_Settings.channel)
    if channelId then
        SendChatMessage(PZW_Settings.message, "CHANNEL", nil, channelId)
        PZW_LastSendTime = time()
        PZW_Stats.sentMessages = (PZW_Stats.sentMessages or 0) + 1
        
        print(PREFIX .. "Announcement sent to channel: " .. PZW_Settings.channel)
        
        if PZWRecruitOptionsPanel and PZWRecruitOptionsPanel:IsShown() and PZWRecruitOptionsPanel.refresh then
            PZWRecruitOptionsPanel.refresh()
        end
    else
        print(PREFIX .. "Error: Channel '" .. tostring(PZW_Settings.channel) .. "' not found.")
    end
end

function PZWRecruit_RestartTicker()
    if recruitTicker then
        recruitTicker:Cancel()
        recruitTicker = nil
    end

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
    if PZW_Stats == nil then PZW_Stats = {} end

    for k, v in pairs(DEFAULT_SETTINGS) do
        if PZW_Settings[k] == nil then PZW_Settings[k] = v end
    end
    for k, v in pairs(DEFAULT_STATS) do
        if PZW_Stats[k] == nil then PZW_Stats[k] = v end
    end

    if PZWRecruit_CreateOptionsPanel then
        PZWRecruit_CreateOptionsPanel(DEFAULT_SETTINGS)
    end

    PZWRecruit_RestartTicker()
end)