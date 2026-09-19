local _, ns = ...

local PALETTES = {
    midnight = {
        label = "Midnight Cyan", background = { 0.025, 0.032, 0.050 }, panel = { 0.055, 0.070, 0.105 },
        panelAlt = { 0.080, 0.100, 0.145 }, input = { 0.015, 0.022, 0.036 }, border = { 0.18, 0.30, 0.40 },
        accent = { 0.20, 0.78, 0.82 }, accent2 = { 0.40, 0.86, 0.69 },
    },
    arcane = {
        label = "Arcane Violet", background = { 0.050, 0.035, 0.080 }, panel = { 0.085, 0.060, 0.125 },
        panelAlt = { 0.115, 0.080, 0.165 }, input = { 0.035, 0.025, 0.060 }, border = { 0.30, 0.22, 0.42 },
        accent = { 0.66, 0.40, 0.94 }, accent2 = { 0.91, 0.55, 0.96 },
    },
    emerald = {
        label = "Emerald Grove", background = { 0.025, 0.060, 0.050 }, panel = { 0.045, 0.095, 0.075 },
        panelAlt = { 0.060, 0.125, 0.100 }, input = { 0.018, 0.046, 0.038 }, border = { 0.16, 0.34, 0.27 },
        accent = { 0.18, 0.78, 0.53 }, accent2 = { 0.55, 0.91, 0.48 },
    },
}

local COLORS = {
    background = { 0.025, 0.032, 0.050, 0.97 }, panel = { 0.055, 0.070, 0.105, 1 },
    panelAlt = { 0.080, 0.100, 0.145, 1 }, input = { 0.015, 0.022, 0.036, 1 },
    border = { 0.18, 0.30, 0.40, 1 }, accent = { 0.20, 0.78, 0.82, 1 },
    accent2 = { 0.40, 0.86, 0.69, 1 }, text = { 0.92, 0.95, 0.98, 1 },
    muted = { 0.57, 0.66, 0.75, 1 }, danger = { 0.95, 0.35, 0.38, 1 },
}

local FONTS = {
    { key = "friz", label = "Friz Quadrata", path = STANDARD_TEXT_FONT, flags = "" },
    { key = "arial", label = "Arial Narrow", path = "Fonts\\ARIALN.TTF", flags = "" },
    { key = "morpheus", label = "Morpheus", path = "Fonts\\MORPHEUS.TTF", flags = "" },
    { key = "skurri", label = "Skurri", path = "Fonts\\SKURRI.TTF", flags = "" },
}

-- WoW cannot access Reddit from Lua. This small, reviewable catalog is bundled with the addon.
-- Scores are snapshots from the linked threads, not live values.
local INTERNET_MACROS = {
    {
        name = "Rescue Mouseover", icon = "Interface\\Icons\\Ability_Evoker_Rescue",
        body = "#showtooltip Rescue\n/cast [@mouseover,help,nodead][] Rescue",
        detail = "239 upvotes · Evoker", score = 239,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Rescue the friendly unit under your cursor; otherwise use your normal target.",
    },
    {
        name = "Cursor Cast", icon = "Interface\\Icons\\Spell_Shadow_Shadowfury",
        body = "#showtooltip\n/cast [@cursor] SPELL NAME",
        detail = "119 upvotes · Template", score = 119,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Replace SPELL NAME. Skips the green targeting circle for ground-targeted abilities.",
    },
    {
        name = "Top Trinket", icon = "Interface\\Icons\\INV_Jewelry_Talisman_07",
        body = "#showtooltip\n/use 13",
        detail = "96 upvotes · Utility", score = 96,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Uses the trinket equipped in the upper trinket slot. Use 14 for the lower slot.",
    },
    {
        name = "Volume Toggle", icon = "Interface\\Icons\\INV_Misc_Horn_01",
        body = "/run local v=GetCVar(\"Sound_MasterVolume\"); SetCVar(\"Sound_MasterVolume\",v==\"1\" and .2 or 1)",
        detail = "45 upvotes · Quality of life", score = 45,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Toggles master volume between 100% and 20%.",
    },
    {
        name = "Modifier Stack", icon = "Interface\\Icons\\INV_Misc_Note_01",
        body = "#showtooltip\n/cast [mod:alt] SPELL B; [mod:shift] SPELL C; [mod:ctrl] SPELL D; SPELL A",
        detail = "21 upvotes · Template", score = 21,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Replace the four spell names to place several abilities on one keybind.",
    },
    {
        name = "Healthstone", icon = "Interface\\Icons\\INV_Stone_04",
        body = "#showtooltip Healthstone\n/stopcasting\n/use Healthstone",
        detail = "Community favorite · Survival", score = 5,
        source = "https://reddit.com/r/wow/comments/102x6y8/",
        note = "Stops the current cast before using a Healthstone. Review before use on a healer.",
    },
}

local frame, mainArea, settingsPage, listPane, editorPane, rows, statusText
local macroName, macroBody, bodyLabel, iconPreview, sourceBox, sourceLabel, noteText
local rowButtons, tabs, styledFrames, styledText, fontObjects = {}, {}, {}, {}, {}
local selectedRecord, selectedIcon, activeSource = nil, nil, "account"
local settingsRefreshing = false
local SelectSource

local function Color(role) return unpack(COLORS[role]) end

local function RegisterBackdrop(object, role)
    object.styleRole = role or "panel"
    styledFrames[object] = true
    object:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    object:SetBackdropColor(Color(object.styleRole))
    object:SetBackdropBorderColor(Color("border"))
end

local function Text(parent, size, role, justify)
    local object = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    object.baseSize = size or 12
    object.colorRole = role or "text"
    object:SetFont(STANDARD_TEXT_FONT, object.baseSize, "")
    object:SetTextColor(Color(object.colorRole))
    object:SetJustifyH(justify or "LEFT")
    styledText[object], fontObjects[object] = true, true
    return object
end

local function Button(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    RegisterBackdrop(button, "panelAlt")
    button.label = Text(button, 12, "text", "CENTER")
    button.label:SetPoint("CENTER")
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(Color("accent")) end)
    button:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(Color(self.selected and "accent" or "border")) end)
    return button
end

local function Edit(parent, multiline)
    local object = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    RegisterBackdrop(object, "input")
    object.baseSize = 13
    object:SetFont(STANDARD_TEXT_FONT, 13, "")
    object:SetTextColor(Color("text"))
    object:SetAutoFocus(false)
    object:SetMultiLine(multiline or false)
    object:SetTextInsets(10, 10, 7, 7)
    object:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    fontObjects[object] = true
    return object
end

local function SelectedFont()
    local key = ns.db and ns.db.font or "friz"
    for _, option in ipairs(FONTS) do if option.key == key then return option end end
    return FONTS[1]
end

local function LoadPalette()
    local palette = PALETTES[ns.db and ns.db.palette or "midnight"] or PALETTES.midnight
    local opacity = math.max(0.60, math.min(1, tonumber(ns.db and ns.db.opacity) or 0.97))
    for role, color in pairs(palette) do
        if role ~= "label" and COLORS[role] then
            COLORS[role][1], COLORS[role][2], COLORS[role][3] = color[1], color[2], color[3]
        end
    end
    COLORS.background[4] = opacity
    COLORS.panel[4], COLORS.panelAlt[4], COLORS.input[4] = math.min(1, opacity + 0.02), math.min(1, opacity + 0.03), math.min(1, opacity + 0.03)
end

local function ApplyAppearance()
    LoadPalette()
    local option = SelectedFont()
    for object in pairs(styledFrames) do
        object:SetBackdropColor(Color(object.styleRole or "panel"))
        object:SetBackdropBorderColor(Color(object.selected and "accent" or "border"))
    end
    for object in pairs(styledText) do object:SetTextColor(Color(object.colorRole or "text")) end
    for object in pairs(fontObjects) do
        if object and object.SetFont then
            local _, currentSize = object:GetFont()
            local size = object == macroBody and (ns.db and ns.db.fontSize or 13) or object.baseSize or currentSize or 12
            local ok, loaded = pcall(object.SetFont, object, option.path, size, option.flags or "")
            if not ok or loaded == false then object:SetFont(STANDARD_TEXT_FONT, size, "") end
        end
    end
    if frame then frame:SetScale(ns.db and ns.db.scale or 1) end
end

local function SetStatus(message, isError)
    if not statusText then return end
    statusText.colorRole = isError and "danger" or "muted"
    statusText:SetTextColor(Color(statusText.colorRole))
    statusText:SetText(message or "")
end

local function SetEditor(record)
    selectedRecord = record
    selectedIcon = record and record.icon or "Interface\\Icons\\INV_Misc_Note_01"
    macroName:SetText(record and record.name or "")
    macroBody:SetText(record and record.body or "")
    iconPreview:SetTexture(selectedIcon)
    sourceBox:SetText(record and record.source or "")
    sourceLabel:SetShown(record ~= nil and record.kind == "internet")
    sourceBox:SetShown(record ~= nil and record.kind == "internet")
    noteText:SetText(record and record.note or "")
    noteText:SetShown(record ~= nil and record.kind == "internet")
    if record then
        SetStatus(record.kind == "internet" and "Community template loaded. Review placeholders before saving." or "Macro loaded and ready to edit.")
    else
        SetStatus("Ready for a new macro. Choose where to save it.")
    end
end

local function ClearEditor() SetEditor(nil); macroName:SetFocus() end

local function AccountRecords()
    local result = {}
    local globalCount = select(1, GetNumMacros()) or 0
    for index = 1, globalCount do
        local name, icon, body = GetMacroInfo(index)
        if name then result[#result + 1] = { kind = "account", index = index, name = name, icon = icon, body = body or "", detail = "Account macro" } end
    end
    return result
end

local function CharacterRecords()
    local result = {}
    local characterCount = select(2, GetNumMacros()) or 0
    local offset = MAX_ACCOUNT_MACROS or 120
    for slot = 1, characterCount do
        local index = offset + slot
        local name, icon, body = GetMacroInfo(index)
        if name then result[#result + 1] = { kind = "character", index = index, name = name, icon = icon, body = body or "", detail = "Character macro" } end
    end
    return result
end

local function RecordsForSource()
    if activeSource == "account" then return AccountRecords() end
    if activeSource == "character" then return CharacterRecords() end
    local result = {}
    for _, item in ipairs(INTERNET_MACROS) do
        local copy = {}
        for key, value in pairs(item) do copy[key] = value end
        copy.kind = "internet"
        result[#result + 1] = copy
    end
    table.sort(result, function(a, b) return a.score > b.score end)
    return result
end

local function RefreshRows()
    for _, row in ipairs(rowButtons) do row:Hide() end
    local records = RecordsForSource()
    local rowHeight = ns.db and ns.db.compactRows and 39 or 49
    rows:SetHeight(math.max(1, #records * rowHeight))
    for slot, record in ipairs(records) do
        local row = rowButtons[slot]
        if not row then
            row = Button(rows, "", 228, 44)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(32, 32); row.icon:SetPoint("LEFT", 6, 0); row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            row.label:ClearAllPoints(); row.label:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -2); row.label:SetPoint("RIGHT", -6, 0); row.label:SetJustifyH("LEFT")
            row.detail = Text(row, 10, "muted")
            row.detail:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 2); row.detail:SetPoint("RIGHT", -6, 0)
            rowButtons[slot] = row
        end
        row:SetSize(228, rowHeight - 5); row:ClearAllPoints(); row:SetPoint("TOPLEFT", 0, -((slot - 1) * rowHeight))
        row.label:SetText(record.name); row.detail:SetText(record.detail or ""); row.detail:SetShown(not (ns.db and ns.db.compactRows))
        row.icon:SetTexture(record.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        row:SetScript("OnClick", function() SetEditor(record) end); row:Show()
    end
    local countLabel = activeSource == "internet" and string.format("%d curated templates", #records) or string.format("%d macros", #records)
    listPane.count:SetText(countLabel)
    if #records == 0 then SetStatus("No macros in this tab yet. Create one in the editor.") end
end

local function SaveMacro(isCharacter)
    local name = string.gsub(macroName:GetText() or "", "^%s*(.-)%s*$", "%1")
    local body = macroBody:GetText() or ""
    if name == "" then SetStatus("Enter a macro name first.", true); return end
    if body == "" then SetStatus("Enter a macro body first.", true); return end
    if string.find(body, "SPELL NAME", 1, true) or string.find(body, "SPELL A", 1, true) then SetStatus("Replace the template spell names before saving.", true); return end
    local icon = selectedIcon
    if type(icon) == "string" and GetFileIDFromPath then
        local path = string.match(string.lower(icon), "%.blp$") and icon or (icon .. ".blp")
        local fileID = GetFileIDFromPath(path)
        if fileID and fileID > 0 then icon = fileID end
    end
    if type(icon) ~= "number" then icon = 134400 end
    local sameScope = selectedRecord and selectedRecord.index and selectedRecord.kind == (isCharacter and "character" or "account")
    local ok, result
    if sameScope then ok, result = pcall(EditMacro, selectedRecord.index, name, icon, body)
    else ok, result = pcall(CreateMacro, name, icon, body, isCharacter) end
    if ok and result ~= false and result ~= nil then
        SetStatus(sameScope and "Macro updated." or (isCharacter and "Character macro created." or "Account macro created."))
        activeSource = isCharacter and "character" or "account"
        SelectSource(isCharacter and "character" or "account")
    else
        SetStatus("The game refused this change. Check macro limits and try outside combat.", true)
    end
end

SelectSource = function(source)
    activeSource = source; settingsPage:Hide(); mainArea:Show()
    for key, tab in pairs(tabs) do
        tab.selected = key == source
        tab:SetBackdropColor(Color(tab.selected and "accent" or "panelAlt"))
        tab:SetBackdropBorderColor(Color(tab.selected and "accent" or "border"))
    end
    RefreshRows()
end

local function Slider(parent, label, y, minimum, maximum, step)
    local title = Text(parent, 11, "muted"); title:SetPoint("TOPLEFT", 28, y); title:SetText(label)
    local valueText = Text(parent, 11, "accent2", "RIGHT"); valueText:SetPoint("TOPRIGHT", -28, y); valueText:SetWidth(70)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetPoint("TOPLEFT", 28, y - 25); slider:SetPoint("TOPRIGHT", -28, y - 25); slider:SetHeight(18)
    slider:SetOrientation("HORIZONTAL"); slider:SetMinMaxValues(minimum, maximum); slider:SetValueStep(step); slider:SetObeyStepOnDrag(true)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local track = slider:CreateTexture(nil, "BACKGROUND"); track:SetColorTexture(Color("border")); track:SetPoint("LEFT", 2, 0); track:SetPoint("RIGHT", -2, 0); track:SetHeight(4)
    return slider, valueText
end

local function BuildSettings()
    settingsPage = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    settingsPage:SetPoint("TOPLEFT", 22, -108); settingsPage:SetPoint("BOTTOMRIGHT", -22, 24); RegisterBackdrop(settingsPage, "panel")
    local title = Text(settingsPage, 19, "text"); title:SetPoint("TOPLEFT", 24, -22); title:SetText("Appearance settings")
    local hint = Text(settingsPage, 11, "muted"); hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7); hint:SetText("Changes are saved account-wide and applied immediately.")
    local paletteTitle = Text(settingsPage, 11, "muted"); paletteTitle:SetPoint("TOPLEFT", 28, -84); paletteTitle:SetText("COLOR PALETTE")
    local paletteButtons = {}
    for index, key in ipairs({ "midnight", "arcane", "emerald" }) do
        local button = Button(settingsPage, PALETTES[key].label, 170, 34)
        button:SetPoint("TOPLEFT", 28 + ((index - 1) * 184), -105)
        button:SetScript("OnClick", function()
            ns.db.palette = key
            for name, item in pairs(paletteButtons) do item.selected = name == key end
            ApplyAppearance()
        end)
        paletteButtons[key] = button
    end
    local fontTitle = Text(settingsPage, 11, "muted"); fontTitle:SetPoint("TOPLEFT", 28, -166); fontTitle:SetText("ADDON FONT")
    local fontButton = Button(settingsPage, "", 260, 34); fontButton:SetPoint("TOPLEFT", 28, -187)
    fontButton:SetScript("OnClick", function()
        local current = 1
        for index, option in ipairs(FONTS) do if option.key == ns.db.font then current = index end end
        local selected = FONTS[(current % #FONTS) + 1]
        ns.db.font = selected.key; fontButton.label:SetText(selected.label .. "  ›"); ApplyAppearance()
    end)
    local compact = CreateFrame("CheckButton", nil, settingsPage, "UICheckButtonTemplate")
    compact:SetPoint("TOPLEFT", 330, -184); compact:SetSize(28, 28)
    local compactLabel = Text(settingsPage, 12, "text"); compactLabel:SetPoint("LEFT", compact, "RIGHT", 7, 0); compactLabel:SetText("Compact macro rows")
    compact:SetScript("OnClick", function(self) ns.db.compactRows = self:GetChecked() == true; RefreshRows() end)

    local opacity, opacityValue = Slider(settingsPage, "WINDOW OPACITY", -250, 0.60, 1, 0.05)
    local scale, scaleValue = Slider(settingsPage, "WINDOW SCALE", -315, 0.70, 1.15, 0.05)
    local editorSize, editorSizeValue = Slider(settingsPage, "EDITOR FONT SIZE", -380, 10, 24, 1)
    opacity:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 20 + 0.5) / 20; opacityValue:SetText(string.format("%d%%", value * 100))
        if not settingsRefreshing then ns.db.opacity = value; ApplyAppearance() end
    end)
    scale:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 20 + 0.5) / 20; scaleValue:SetText(string.format("%d%%", value * 100))
        if not settingsRefreshing then ns.db.scale = value; frame:SetScale(value) end
    end)
    editorSize:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value + 0.5); editorSizeValue:SetText(tostring(value) .. " px")
        if not settingsRefreshing then ns.db.fontSize = value; ApplyAppearance() end
    end)
    local reset = Button(settingsPage, "Reset appearance", 150, 30); reset:SetPoint("BOTTOMLEFT", 28, 24)
    reset:SetScript("OnClick", function()
        ns.db.palette, ns.db.font, ns.db.opacity, ns.db.scale, ns.db.fontSize, ns.db.compactRows = "midnight", "friz", 0.97, 1, 13, false
        settingsPage:Refresh(); ApplyAppearance(); RefreshRows(); SetStatus("Appearance reset to defaults.")
    end)
    local version = Text(settingsPage, 11, "muted", "RIGHT"); version:SetPoint("BOTTOMRIGHT", -28, 31); version:SetText("Revath's Macro Workshop  ·  " .. tostring(ns.version))
    function settingsPage:Refresh()
        settingsRefreshing = true
        fontButton.label:SetText(SelectedFont().label .. "  ›"); compact:SetChecked(ns.db.compactRows)
        opacity:SetValue(ns.db.opacity); scale:SetValue(ns.db.scale); editorSize:SetValue(ns.db.fontSize)
        for key, button in pairs(paletteButtons) do button.selected = ns.db.palette == key end
        settingsRefreshing = false; ApplyAppearance()
    end
    settingsPage:Hide()
end

local function BuildUI()
    frame = CreateFrame("Frame", "RevathsMacroFrame", UIParent, "BackdropTemplate")
    local savedWidth = math.max(820, math.min(1180, tonumber(ns.db.window.width) or 980))
    local savedHeight = math.max(640, math.min(760, tonumber(ns.db.window.height) or 640))
    frame:SetSize(savedWidth, savedHeight)
    if ns.db.window.x and ns.db.window.y then
        frame:SetPoint(ns.db.window.point or "CENTER", UIParent, ns.db.window.relativePoint or "CENTER", ns.db.window.x, ns.db.window.y)
    else
        frame:SetPoint("CENTER")
    end
    frame:SetFrameStrata("HIGH"); frame:SetClampedToScreen(true); frame:SetMovable(true); frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(820, 640, 1180, 760) end
    frame:EnableMouse(true); frame:RegisterForDrag("LeftButton"); frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint(1)
        ns.db.window.point, ns.db.window.relativePoint, ns.db.window.x, ns.db.window.y = point, relativePoint, x, y
    end)
    RegisterBackdrop(frame, "background")
    local title = Text(frame, 22, "text"); title:SetPoint("TOPLEFT", 24, -18); title:SetText("REVATH'S |cff33c5d0MACRO WORKSHOP|r")
    local subtitle = Text(frame, 10, "muted"); subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -4); subtitle:SetText("ACCOUNT, CHARACTER, AND COMMUNITY MACROS")
    local close = Button(frame, "×", 32, 30); close:SetPoint("TOPRIGHT", -15, -15); close:SetScript("OnClick", function() frame:Hide() end)
    local settings = Button(frame, "Settings", 76, 30); settings:SetPoint("RIGHT", close, "LEFT", -7, 0)
    settings:SetScript("OnClick", function()
        if settingsPage:IsShown() then SelectSource(activeSource) else mainArea:Hide(); settingsPage:Show(); settingsPage:Refresh() end
    end)

    tabs = {}
    local tabSpecs = {
        { key = "account", label = "Account Macros", width = 145 }, { key = "character", label = "Character Macros", width = 155 },
        { key = "internet", label = "From the Internet", width = 155 },
    }
    local previous
    for _, spec in ipairs(tabSpecs) do
        local tab = Button(frame, spec.label, spec.width, 31)
        if previous then tab:SetPoint("LEFT", previous, "RIGHT", 7, 0) else tab:SetPoint("TOPLEFT", 22, -70) end
        tab:SetScript("OnClick", function() SelectSource(spec.key) end); tabs[spec.key], previous = tab, tab
    end

    mainArea = CreateFrame("Frame", nil, frame); mainArea:SetPoint("TOPLEFT", 22, -108); mainArea:SetPoint("BOTTOMRIGHT", -22, 24)
    listPane = CreateFrame("Frame", nil, mainArea, "BackdropTemplate"); listPane:SetPoint("TOPLEFT"); listPane:SetPoint("BOTTOMLEFT"); listPane:SetWidth(270); RegisterBackdrop(listPane, "panel")
    local listTitle = Text(listPane, 14, "text"); listTitle:SetPoint("TOPLEFT", 16, -16); listTitle:SetText("MACROS")
    listPane.count = Text(listPane, 10, "muted", "RIGHT"); listPane.count:SetPoint("TOPRIGHT", -16, -19); listPane.count:SetWidth(120)
    local scroll = CreateFrame("ScrollFrame", nil, listPane, "UIPanelScrollFrameTemplate"); scroll:SetPoint("TOPLEFT", 12, -48); scroll:SetPoint("BOTTOMRIGHT", -28, 12)
    rows = CreateFrame("Frame", nil, scroll); rows:SetSize(228, 1); scroll:SetScrollChild(rows)

    editorPane = CreateFrame("Frame", nil, mainArea, "BackdropTemplate"); editorPane:SetPoint("TOPLEFT", listPane, "TOPRIGHT", 14, 0); editorPane:SetPoint("BOTTOMRIGHT"); RegisterBackdrop(editorPane, "panel")
    local editorTitle = Text(editorPane, 18, "text"); editorTitle:SetPoint("TOPLEFT", 20, -18); editorTitle:SetText("Macro Editor")
    local editorHint = Text(editorPane, 11, "muted"); editorHint:SetPoint("TOPLEFT", editorTitle, "BOTTOMLEFT", 0, -6); editorHint:SetText("Edit a macro or adapt a community template.")
    iconPreview = editorPane:CreateTexture(nil, "ARTWORK"); iconPreview:SetSize(42, 42); iconPreview:SetPoint("TOPRIGHT", -20, -18); iconPreview:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local nameLabel = Text(editorPane, 11, "muted"); nameLabel:SetPoint("TOPLEFT", 20, -70); nameLabel:SetText("MACRO NAME")
    macroName = Edit(editorPane); macroName:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6); macroName:SetPoint("RIGHT", -20, 0); macroName:SetHeight(35); macroName:SetMaxLetters(16)
    bodyLabel = Text(editorPane, 11, "muted"); bodyLabel:SetPoint("TOPLEFT", 20, -128); bodyLabel:SetText("MACRO BODY")
    macroBody = Edit(editorPane, true); macroBody:SetPoint("TOPLEFT", bodyLabel, "BOTTOMLEFT", 0, -6); macroBody:SetPoint("BOTTOMRIGHT", -20, 139); macroBody:SetMaxLetters(255)
    macroBody:SetScript("OnTextChanged", function(self) bodyLabel:SetText(string.format("MACRO BODY  %d / 255", string.len(self:GetText() or ""))) end)
    sourceLabel = Text(editorPane, 10, "muted"); sourceLabel:SetPoint("BOTTOMLEFT", 20, 104); sourceLabel:SetText("SOURCE")
    sourceBox = Edit(editorPane); sourceBox:SetPoint("LEFT", sourceLabel, "RIGHT", 10, 0); sourceBox:SetPoint("RIGHT", -20, 0); sourceBox:SetHeight(27)
    sourceBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    sourceBox:SetScript("OnTextChanged", function(self, userInput) if userInput and selectedRecord then self:SetText(selectedRecord.source or ""); self:HighlightText() end end)
    noteText = Text(editorPane, 10, "muted"); noteText:SetPoint("BOTTOMLEFT", 20, 78); noteText:SetPoint("RIGHT", -20, 0); noteText:SetWordWrap(true)
    local newButton = Button(editorPane, "New", 76, 31); newButton:SetPoint("BOTTOMLEFT", 20, 18); newButton:SetScript("OnClick", ClearEditor)
    local accountSave = Button(editorPane, "Save to Account", 135, 31); accountSave:SetPoint("BOTTOMRIGHT", -162, 18); accountSave:SetScript("OnClick", function() SaveMacro(false) end)
    local characterSave = Button(editorPane, "Save to Character", 142, 31); characterSave:SetPoint("BOTTOMRIGHT", -12, 18); characterSave:SetScript("OnClick", function() SaveMacro(true) end)
    statusText = Text(editorPane, 10, "muted"); statusText:SetPoint("BOTTOMLEFT", newButton, "BOTTOMRIGHT", 12, 10); statusText:SetPoint("RIGHT", accountSave, "LEFT", -10, 0); statusText:SetWordWrap(false)

    local resize = Button(frame, "◢", 24, 24); resize:SetPoint("BOTTOMRIGHT", -3, 3)
    resize:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); ns.db.window.width, ns.db.window.height = frame:GetWidth(), frame:GetHeight() end)
    BuildSettings(); table.insert(UISpecialFrames, frame:GetName()); ApplyAppearance(); SetEditor(nil); SelectSource("account"); frame:Hide()
end

function ns:Initialize() BuildUI() end

function ns:RedirectBlizzardMacroFrame()
    if self.macroRedirectInstalled then return end

    local function Redirect()
        if self.redirectingMacroFrame then return end
        self.redirectingMacroFrame = true
        if MacroFrame then MacroFrame:Hide() end
        if frame and not frame:IsShown() then
            ApplyAppearance()
            SelectSource(activeSource)
            frame:Show()
        end
        self.redirectingMacroFrame = nil
    end

    local installed = false
    if MacroFrame then
        MacroFrame:HookScript("OnShow", Redirect)
        installed = true
    end
    for _, functionName in ipairs({ "MacroFrame_Show", "ShowMacroFrame" }) do
        if type(_G[functionName]) == "function" then
            hooksecurefunc(functionName, Redirect)
            installed = true
        end
    end
    self.macroRedirectInstalled = installed
end

function ns:Toggle()
    if not frame then return end
    if frame:IsShown() then frame:Hide() else ApplyAppearance(); SelectSource(activeSource); frame:Show() end
end
