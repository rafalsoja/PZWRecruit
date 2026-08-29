function PZWRecruit_CreateOptionsPanel(defaultSettings)
    local panel = CreateFrame("Frame", "PZWRecruitOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "PZW Recruitment"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PZW Recruitment - Options")

    -- 1. Message text (Multi-line)
    local msgLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    msgLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    msgLabel:SetText("Announcement message:")

    local msgScroll = CreateFrame("ScrollFrame", "PZWRecruitMsgScroll", panel, "UIPanelScrollFrameTemplate")
    msgScroll:SetPoint("TOPLEFT", msgLabel, "BOTTOMLEFT", 0, -8)
    msgScroll:SetSize(350, 100)

    local msgBox = CreateFrame("EditBox", nil, msgScroll)
    msgBox:SetSize(350, 100)
    msgBox:SetMultiLine(true)
    msgBox:SetAutoFocus(false)
    msgBox:SetFontObject("ChatFontNormal")
    msgBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    msgScroll:SetScrollChild(msgBox)

    -- Background for multi-line EditBox
    local msgBg = CreateFrame("Frame", nil, msgScroll, "BackdropTemplate")
    msgBg:SetPoint("TOPLEFT", msgScroll, -5, 5)
    msgBg:SetPoint("BOTTOMRIGHT", msgScroll, 25, -5)
    msgBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    msgBg:SetFrameLevel(msgScroll:GetFrameLevel() - 1)

    -- 2. Channel name
    local chanLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    chanLabel:SetPoint("TOPLEFT", msgScroll, "BOTTOMLEFT", 0, -20)
    chanLabel:SetText("Channel name (e.g. PZWTest or Global):")

    local chanBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    chanBox:SetPoint("TOPLEFT", chanLabel, "BOTTOMLEFT", 5, -5)
    chanBox:SetSize(150, 20)
    chanBox:SetAutoFocus(false)

    -- 3. Interval
    local intLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    intLabel:SetPoint("TOPLEFT", chanBox, "BOTTOMLEFT", -5, -16)
    intLabel:SetText("Send interval (in minutes):")

    local intBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    intBox:SetPoint("TOPLEFT", intLabel, "BOTTOMLEFT", 5, -5)
    intBox:SetSize(60, 20)
    intBox:SetAutoFocus(false)
    intBox:SetNumeric(true)

    -- Last send status
    local statusLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    statusLabel:SetPoint("TOPLEFT", intBox, "BOTTOMLEFT", -5, -20)

    -- Load stored settings into input boxes and update status label
    local function LoadValues()
        msgBox:SetText(PZW_Settings.message or defaultSettings.message)
        msgBox:SetCursorPosition(0)
        
        chanBox:SetText(PZW_Settings.channel or defaultSettings.channel)
        chanBox:SetCursorPosition(0)
        
        intBox:SetText(tostring(PZW_Settings.interval or defaultSettings.interval))
        intBox:SetCursorPosition(0)

        if PZW_LastSendTime and PZW_LastSendTime > 0 then
            local formattedTime = date("%Y-%m-%d %H:%M:%S", PZW_LastSendTime)
            local diffMinutes = math.floor((time() - PZW_LastSendTime) / 60)
            statusLabel:SetText("Last sent: " .. formattedTime .. " (" .. diffMinutes .. " min ago)")
        else
            statusLabel:SetText("Last sent: No data (not sent yet)")
        end
    end

    -- Save input values to settings
    local function SaveValues()
        PZW_Settings.message = msgBox:GetText()
        PZW_Settings.channel = chanBox:GetText()
        
        local val = tonumber(intBox:GetText())
        if val and val > 0 then
            PZW_Settings.interval = val
        end
        print("[PZWRecruit] Settings saved successfully.")
        LoadValues()
    end

    -- 1. Save Button
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetPoint("TOPLEFT", statusLabel, "BOTTOMLEFT", 0, -15)
    saveBtn:SetSize(100, 25)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", SaveValues)

    -- 2. Send Now Button (Saves settings + fires announcement + resets timer)
    local sendBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    sendBtn:SetPoint("LEFT", saveBtn, "RIGHT", 10, 0)
    sendBtn:SetSize(100, 25)
    sendBtn:SetText("Send Now")
    sendBtn:SetScript("OnClick", function()
        SaveValues()
        if PZWRecruit_SendAnnouncement then
            PZWRecruit_SendAnnouncement()
        end
    end)

    LoadValues()

    -- WoW options panel integration
    panel.refresh = LoadValues
    panel.okay = SaveValues
    panel.default = function()
        PZW_Settings = CopyTable(defaultSettings)
        LoadValues()
    end

    InterfaceOptions_AddCategory(panel)
end

-- Slash command registration
SLASH_PZWRECRUIT1 = "/pzw"
SlashCmdList["PZWRECRUIT"] = function()
    if not InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Show()
    end
    InterfaceOptionsFrame_OpenToCategory(PZWRecruitOptionsPanel)
    InterfaceOptionsFrame_OpenToCategory(PZWRecruitOptionsPanel)
end