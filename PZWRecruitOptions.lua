local PREFIX = "|cff00aeef[PZWRecruit]|r "

function PZWRecruit_CreateOptionsPanel(defaultSettings)
    local panel = CreateFrame("Frame", "PZWRecruitOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "PZW Recruitment"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PZW Recruitment - Options")

    -- 1. Message text
    local msgLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    msgLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    msgLabel:SetText("Announcement message:")

    local msgScroll = CreateFrame("ScrollFrame", "PZWRecruitMsgScroll", panel, "UIPanelScrollFrameTemplate")
    msgScroll:SetPoint("TOPLEFT", msgLabel, "BOTTOMLEFT", 0, -8)
    msgScroll:SetSize(350, 80)

    local msgBox = CreateFrame("EditBox", nil, msgScroll)
    msgBox:SetSize(350, 80)
    msgBox:SetMultiLine(true)
    msgBox:SetAutoFocus(false)
    msgBox:SetFontObject("ChatFontNormal")
    msgBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    msgScroll:SetScrollChild(msgBox)

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
    chanLabel:SetPoint("TOPLEFT", msgScroll, "BOTTOMLEFT", 0, -16)
    chanLabel:SetText("Channel name (e.g. PZWTest or Global):")

    local chanBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    chanBox:SetPoint("TOPLEFT", chanLabel, "BOTTOMLEFT", 5, -5)
    chanBox:SetSize(150, 20)
    chanBox:SetAutoFocus(false)

    -- 3. Interval
    local intLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    intLabel:SetPoint("TOPLEFT", chanBox, "BOTTOMLEFT", -5, -12)
    intLabel:SetText("Send interval (in minutes):")

    local intBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    intBox:SetPoint("TOPLEFT", intLabel, "BOTTOMLEFT", 5, -5)
    intBox:SetSize(60, 20)
    intBox:SetAutoFocus(false)
    intBox:SetNumeric(true)

    -- 4. Faction Checkboxes
    local allyCheck = CreateFrame("CheckButton", "PZW_AllyCheck", panel, "UICheckButtonTemplate")
    allyCheck:SetPoint("TOPLEFT", intBox, "BOTTOMLEFT", -5, -12)
    local allyText = _G[allyCheck:GetName() .. "Text"]
    allyText:SetText("Enable for Alliance characters")
    allyText:SetTextColor(0, 0.68, 1)

    local hordeCheck = CreateFrame("CheckButton", "PZW_HordeCheck", panel, "UICheckButtonTemplate")
    hordeCheck:SetPoint("TOPLEFT", allyCheck, "BOTTOMLEFT", 0, -4)
    local hordeText = _G[hordeCheck:GetName() .. "Text"]
    hordeText:SetText("Enable for Horde characters")
    hordeText:SetTextColor(1, 0.2, 0.2)

    -- Status & Stats Labels
    local statusLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    statusLabel:SetPoint("TOPLEFT", hordeCheck, "BOTTOMLEFT", 0, -12)

    local statsSentLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    statsSentLabel:SetPoint("TOPLEFT", statusLabel, "BOTTOMLEFT", 0, -10)

    local function LoadValues()
        msgBox:SetText(PZW_Settings.message or defaultSettings.message)
        msgBox:SetCursorPosition(0)
        
        chanBox:SetText(PZW_Settings.channel or defaultSettings.channel)
        chanBox:SetCursorPosition(0)
        
        intBox:SetText(tostring(PZW_Settings.interval or defaultSettings.interval))
        intBox:SetCursorPosition(0)

        allyCheck:SetChecked(PZW_Settings.enableAlliance ~= false)
        hordeCheck:SetChecked(PZW_Settings.enableHorde ~= false)

        if PZW_LastSendTime and PZW_LastSendTime > 0 then
            local formattedTime = date("%Y-%m-%d %H:%M:%S", PZW_LastSendTime)
            local diffMinutes = math.floor((time() - PZW_LastSendTime) / 60)
            statusLabel:SetText("Last sent: " .. formattedTime .. " (" .. diffMinutes .. " min ago)")
        else
            statusLabel:SetText("Last sent: No data (not sent yet)")
        end

        statsSentLabel:SetText("Total messages sent: " .. (PZW_Stats and PZW_Stats.sentMessages or 0))
    end

    local function SaveValues()
        PZW_Settings.message = msgBox:GetText()
        PZW_Settings.channel = chanBox:GetText()
        PZW_Settings.enableAlliance = allyCheck:GetChecked()
        PZW_Settings.enableHorde = hordeCheck:GetChecked()
        
        local val = tonumber(intBox:GetText())
        if val and val > 0 then
            PZW_Settings.interval = val
        end
        print(PREFIX .. "Settings saved successfully.")
        LoadValues()
    end

    -- Save Button
    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetPoint("TOPLEFT", statsSentLabel, "BOTTOMLEFT", 0, -16)
    saveBtn:SetSize(100, 25)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", SaveValues)

    -- Send Now Button
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

    -- Reset Counter Button
    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetPoint("LEFT", sendBtn, "RIGHT", 10, 0)
    resetBtn:SetSize(100, 25)
    resetBtn:SetText("Reset Counter")
    resetBtn:SetScript("OnClick", function()
        PZW_Stats.sentMessages = 0
        LoadValues()
        print(PREFIX .. "Sent counter reset.")
    end)

    LoadValues()

    panel.refresh = LoadValues
    panel.okay = SaveValues
    panel.default = function()
        PZW_Settings = CopyTable(defaultSettings)
        LoadValues()
    end

    InterfaceOptions_AddCategory(panel)
end

SLASH_PZWRECRUIT1 = "/pzw"
SlashCmdList["PZWRECRUIT"] = function()
    if not InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Show()
    end
    InterfaceOptionsFrame_OpenToCategory(PZWRecruitOptionsPanel)
    InterfaceOptionsFrame_OpenToCategory(PZWRecruitOptionsPanel)
end