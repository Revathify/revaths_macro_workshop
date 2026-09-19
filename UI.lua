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
    crimson = {
        label = "Crimson Ember", background = { 0.070, 0.030, 0.035 }, panel = { 0.115, 0.048, 0.055 },
        panelAlt = { 0.150, 0.064, 0.070 }, input = { 0.052, 0.022, 0.026 }, border = { 0.38, 0.18, 0.20 },
        accent = { 0.91, 0.28, 0.34 }, accent2 = { 1.00, 0.62, 0.34 },
    },
    royal = {
        label = "Royal Blue", background = { 0.025, 0.040, 0.080 }, panel = { 0.042, 0.070, 0.125 },
        panelAlt = { 0.060, 0.095, 0.165 }, input = { 0.018, 0.032, 0.062 }, border = { 0.16, 0.28, 0.46 },
        accent = { 0.25, 0.57, 0.96 }, accent2 = { 0.55, 0.78, 1.00 },
    },
    graphite = {
        label = "Graphite Gray", background = { 0.050, 0.052, 0.058 }, panel = { 0.080, 0.083, 0.092 },
        panelAlt = { 0.110, 0.114, 0.125 }, input = { 0.035, 0.037, 0.043 }, border = { 0.28, 0.29, 0.32 },
        accent = { 0.62, 0.65, 0.70 }, accent2 = { 0.84, 0.86, 0.89 },
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
    { key = "frizOutline", label = "Friz Outlined", path = STANDARD_TEXT_FONT, flags = "OUTLINE" },
    { key = "arial", label = "Arial Narrow", path = "Fonts\\ARIALN.TTF", flags = "" },
    { key = "arialOutline", label = "Arial Outlined", path = "Fonts\\ARIALN.TTF", flags = "OUTLINE" },
    { key = "morpheus", label = "Morpheus", path = "Fonts\\MORPHEUS.TTF", flags = "" },
    { key = "morpheusOutline", label = "Morpheus Outlined", path = "Fonts\\MORPHEUS.TTF", flags = "OUTLINE" },
    { key = "skurri", label = "Skurri", path = "Fonts\\SKURRI.TTF", flags = "" },
    { key = "skurriOutline", label = "Skurri Outlined", path = "Fonts\\SKURRI.TTF", flags = "OUTLINE" },
}

local function DiscoverSharedMediaFonts()
    if not LibStub then return end
    local media = LibStub("LibSharedMedia-3.0", true)
    if not media or not media.HashTable then return end
    local knownPaths = {}
    for _, font in ipairs(FONTS) do knownPaths[string.lower(font.path)] = true end
    local registered = media:HashTable("font")
    if type(registered) ~= "table" then return end
    for name, path in pairs(registered) do
        if type(name) == "string" and type(path) == "string" and path ~= "" and not knownPaths[string.lower(path)] then
            local key = "shared:" .. name
            local exists = false
            for _, font in ipairs(FONTS) do if font.key == key then exists = true end end
            if not exists then
                FONTS[#FONTS + 1] = { key = key, label = name, path = path, flags = "", shared = true }
                knownPaths[string.lower(path)] = true
            end
        end
    end
end

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
    {
        name = "Shadow Word: Death Focus", class = "PRIEST", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        body = "#showtooltip Shadow Word: Death\n/cast [@focus,harm,nodead] Shadow Word: Death",
        detail = "Shadow Priest · Focus interrupt", score = 90,
        source = "Community template", note = "Casts Shadow Word: Death on your focus target.",
    },
    {
        name = "Vampiric Touch Mouseover", class = "PRIEST", icon = "Interface\\Icons\\Spell_Holy_Stoicism",
        body = "#showtooltip Vampiric Touch\n/cast [@mouseover,harm,nodead][] Vampiric Touch",
        detail = "Shadow Priest · DoT", score = 80,
        source = "Community template", note = "Applies Vampiric Touch to a hostile mouseover or your target.",
    },
    {
        name = "Devouring Plague", class = "PRIEST", icon = "Interface\\Icons\\Spell_Shadow_DevouringPlague",
        body = "#showtooltip Devouring Plague\n/cast [harm,nodead] Devouring Plague",
        detail = "Shadow Priest · Core", score = 70,
        source = "Community template", note = "A compact Devouring Plague button for Shadow Priests.",
    },
}

local frame, mainArea, settingsPage, listPane, editorPane, rows, statusText
local macroName, macroBody, bodyLabel, iconPreview, sourceBox, sourceLabel, noteText, editorFontValue
local rowButtons, tabs, styledFrames, styledText, fontObjects = {}, {}, {}, {}, {}
local selectedRecord, selectedIcon, activeSource = nil, nil, "account"
local settingsRefreshing = false
local pendingScale, scaleDragging, scaleCommitToken
local iconPopup, iconButtons, iconChoices, iconPage = nil, {}, {}, 1
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
    if editorFontValue and ns.db then editorFontValue:SetText(string.format("%d px", tonumber(ns.db.fontSize) or 13)) end
    if frame and not scaleDragging then frame:SetScale(ns.db and ns.db.scale or 1) end
end

local function ChangeEditorFontSize(delta)
    if not ns.db then return end
    ns.db.fontSize = math.max(10, math.min(24, (tonumber(ns.db.fontSize) or 13) + delta))
    ApplyAppearance()
end

local function PreserveWindowCenterAtScale(value)
    if not frame then return end
    local centerX, centerY = frame:GetCenter()
    frame:SetScale(value)
    if centerX and centerY and UIParent.GetCenter then
        local parentX, parentY = UIParent:GetCenter()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", centerX - parentX, centerY - parentY)
        if ns.db and ns.db.window then
            ns.db.window.point, ns.db.window.relativePoint = "CENTER", "CENTER"
            ns.db.window.x, ns.db.window.y = centerX - parentX, centerY - parentY
        end
    end
end

local function CommitWindowScale()
    if not pendingScale or not ns.db or not frame then return end
    ns.db.scale = pendingScale
    PreserveWindowCenterAtScale(pendingScale)
    pendingScale = nil
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

local function BuildIconPicker()
    if iconPopup then return end
    iconPopup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    iconPopup:SetSize(420, 350)
    iconPopup:SetFrameStrata("DIALOG")
    iconPopup:SetClampedToScreen(true)
    RegisterBackdrop(iconPopup, "panel")
    local title = Text(iconPopup, 14, "text")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText("Choose macro icon")
    local hint = Text(iconPopup, 10, "muted")
    hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    hint:SetText("Blizzard icons and icons supplied by your installed addons")
    for index = 1, 80 do
        local button = CreateFrame("Button", nil, iconPopup, "BackdropTemplate")
        button:SetSize(36, 36)
        RegisterBackdrop(button, "panelAlt")
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetPoint("TOPLEFT", 4, -4)
        button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
        button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        local column = (index - 1) % 10
        local row = math.floor((index - 1) / 10)
        button:SetPoint("TOPLEFT", 14 + column * 39, -61 - row * 39)
        iconButtons[index] = button
    end
    local previous = Button(iconPopup, "‹", 28, 25)
    previous:SetPoint("BOTTOMLEFT", 14, 12)
    local next = Button(iconPopup, "›", 28, 25)
    next:SetPoint("BOTTOMRIGHT", -14, 12)
    local pageLabel = Text(iconPopup, 10, "muted", "CENTER")
    pageLabel:SetPoint("BOTTOM", 0, 20)
    pageLabel:SetWidth(140)
    iconPopup.previous, iconPopup.next, iconPopup.pageLabel = previous, next, pageLabel
    previous:SetScript("OnClick", function()
        iconPage = math.max(1, iconPage - 1)
        RefreshIconPicker()
    end)
    next:SetScript("OnClick", function()
        iconPage = math.min(math.max(1, math.ceil(#iconChoices / 80)), iconPage + 1)
        RefreshIconPicker()
    end)
    local close = Button(iconPopup, "Close", 70, 26)
    close:SetPoint("TOPRIGHT", -12, -10)
    close:SetScript("OnClick", function() iconPopup:Hide() end)
    iconPopup:EnableMouseWheel(true)
    iconPopup:SetScript("OnMouseWheel", function(_, delta)
        local pages = math.max(1, math.ceil(#iconChoices / 80))
        iconPage = math.max(1, math.min(pages, iconPage + (delta > 0 and -1 or 1)))
        RefreshIconPicker()
    end)
end

local function RefreshIconPicker()
    BuildIconPicker()
    local choices = {}
    local function append(source)
        if type(source) ~= "table" then return end
        for _, value in pairs(source) do
            if type(value) == "table" then value = value.fileID or value.icon or value.texture end
            if value then choices[#choices + 1] = value end
        end
    end
    append(GetMacroIcons and GetMacroIcons())
    append(GetMacroItemIcons and GetMacroItemIcons())
    if #choices == 0 then
        choices = {
            "Interface\\Icons\\INV_Misc_QuestionMark", "Interface\\Icons\\INV_Misc_Note_01",
            "Interface\\Icons\\Spell_Shadow_Shadowfury", "Interface\\Icons\\Ability_Evoker_Rescue",
        }
    end
    iconChoices = choices
    local pages = math.max(1, math.ceil(#iconChoices / 80))
    iconPage = math.max(1, math.min(pages, iconPage))
    local offset = (iconPage - 1) * 80
    for index, button in ipairs(iconButtons) do
        local icon = iconChoices[offset + index]
        button:SetShown(icon ~= nil)
        if icon then
            button.icon:SetTexture(icon)
            button:SetScript("OnClick", function()
                selectedIcon = icon
                iconPreview:SetTexture(icon)
                iconPopup:Hide()
                SetStatus("Icon selected. Save the macro to apply it.")
            end)
        end
    end
    iconPopup.previous:SetEnabled(iconPage > 1)
    iconPopup.next:SetEnabled(iconPage < pages)
    iconPopup.pageLabel:SetText(string.format("Page %d / %d · %d icons", iconPage, pages, #iconChoices))
end

local function ShowIconPicker()
    RefreshIconPicker()
    iconPopup:ClearAllPoints()
    iconPopup:SetPoint("TOPRIGHT", editorPane, "TOPRIGHT", -12, -64)
    iconPopup:Show()
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
    local playerClass = UnitClass and select(2, UnitClass("player")) or nil
    for _, item in ipairs(INTERNET_MACROS) do
        local copy = {}
        for key, value in pairs(item) do copy[key] = value end
        copy.kind = "internet"
        copy.classRank = copy.class == playerClass and 2 or (copy.class == nil and 1 or 0)
        result[#result + 1] = copy
    end
    table.sort(result, function(a, b)
        if a.classRank ~= b.classRank then return a.classRank > b.classRank end
        return a.score > b.score
    end)
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
        row:SetScript("OnClick", function() SetEditor(record) end)
        row:RegisterForDrag("LeftButton")
        row:SetScript("OnDragStart", function()
            if record.index then
                PickupMacro(record.index)
            else
                SetStatus("Save this community macro first, then drag it to an action bar.", true)
            end
        end)
        row:Show()
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
    local hint = Text(settingsPage, 11, "muted"); hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7); hint:SetText("Choose a font and adjust transparency. Resize the window from its lower-right corner.")
    DiscoverSharedMediaFonts()
    local fontTitle = Text(settingsPage, 11, "muted"); fontTitle:SetPoint("TOPLEFT", 28, -92); fontTitle:SetText("ADDON FONT")
    local fontButton = Button(settingsPage, "", 300, 34); fontButton:SetPoint("TOPLEFT", 28, -113)
    local fontMenu = CreateFrame("Frame", nil, settingsPage, "BackdropTemplate")
    fontMenu:SetSize(360, 250); fontMenu:SetFrameLevel(settingsPage:GetFrameLevel() + 20); fontMenu:SetClampedToScreen(true); RegisterBackdrop(fontMenu, "panel"); fontMenu:Hide()
    local fontMenuTitle = Text(fontMenu, 11, "muted"); fontMenuTitle:SetPoint("TOPLEFT", 12, -10); fontMenuTitle:SetText("SELECT FONT")
    local fontMenuButtons = {}
    for index = 1, 10 do
        local button = Button(fontMenu, "", 160, 29)
        local column = (index - 1) % 2; local row = math.floor((index - 1) / 2)
        button:SetPoint("TOPLEFT", 12 + column * 172, -30 - row * 34)
        fontMenuButtons[index] = button
    end
    local fontPrev = Button(fontMenu, "‹", 28, 24); fontPrev:SetPoint("BOTTOMLEFT", 12, 10)
    local fontPage = Text(fontMenu, 10, "muted", "CENTER"); fontPage:SetPoint("BOTTOM", 0, 15); fontPage:SetWidth(80)
    local fontNext = Button(fontMenu, "›", 28, 24); fontNext:SetPoint("BOTTOMRIGHT", -12, 10)
    local fontMenuPage = 1
    local function RefreshFontMenu()
        DiscoverSharedMediaFonts()
        local pages = math.max(1, math.ceil(#FONTS / 10)); fontMenuPage = math.max(1, math.min(fontMenuPage, pages)); fontPage:SetText(string.format("%d / %d", fontMenuPage, pages))
        local start = (fontMenuPage - 1) * 10
        for index, button in ipairs(fontMenuButtons) do
            local option = FONTS[start + index]
            button:SetShown(option ~= nil)
            if option then
                button.label:SetText(option.label .. (option.key == ns.db.font and "  ✓" or ""))
                button.label:SetFont(option.path, 11, option.flags or "")
                button:SetScript("OnClick", function()
                    ns.db.font = option.key; fontMenu:Hide(); settingsPage:Refresh(); ApplyAppearance()
                end)
            end
        end
        fontPrev:SetEnabled(fontMenuPage > 1); fontNext:SetEnabled(fontMenuPage < pages)
    end
    fontPrev:SetScript("OnClick", function() fontMenuPage = fontMenuPage - 1; RefreshFontMenu() end)
    fontNext:SetScript("OnClick", function() fontMenuPage = fontMenuPage + 1; RefreshFontMenu() end)
    fontButton:SetScript("OnClick", function()
        RefreshFontMenu(); fontMenu:ClearAllPoints(); fontMenu:SetPoint("TOPLEFT", fontButton, "BOTTOMLEFT", 0, -6); fontMenu:Show()
    end)

    local opacity, opacityValue = Slider(settingsPage, "WINDOW OPACITY", -190, 0.55, 1, 0.05)
    opacity:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 20 + 0.5) / 20; opacityValue:SetText(string.format("%d%%", value * 100))
        if not settingsRefreshing then ns.db.opacity = value; ApplyAppearance() end
    end)
    local version = Text(settingsPage, 11, "muted", "RIGHT"); version:SetPoint("BOTTOMRIGHT", -28, 31); version:SetText("Revath's Macro Workshop  ·  " .. tostring(ns.version))
    function settingsPage:Refresh()
        settingsRefreshing = true
        fontButton.label:SetText(SelectedFont().label .. "  ▾"); opacity:SetValue(ns.db.opacity); RefreshFontMenu()
        settingsRefreshing = false; ApplyAppearance()
    end
    settingsPage:Hide()
end

local function BuildUI()
    frame = CreateFrame("Frame", "RevathsMacroFrame", UIParent, "BackdropTemplate")
    local savedWidth = math.max(820, tonumber(ns.db.window.width) or 980)
    local savedHeight = math.max(640, tonumber(ns.db.window.height) or 640)
    frame:SetSize(savedWidth, savedHeight)
    if ns.db.window.x and ns.db.window.y then
        frame:SetPoint(ns.db.window.point or "CENTER", UIParent, ns.db.window.relativePoint or "CENTER", ns.db.window.x, ns.db.window.y)
    else
        frame:SetPoint("CENTER")
    end
    frame:SetFrameStrata("HIGH"); frame:SetClampedToScreen(true); frame:SetMovable(true); frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(820, 640, 2400, 1800) end
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
    local iconButton = Button(editorPane, "Change icon", 96, 25)
    iconButton:SetPoint("TOPRIGHT", -20, -66)
    iconButton:SetScript("OnClick", ShowIconPicker)
    local nameLabel = Text(editorPane, 11, "muted"); nameLabel:SetPoint("TOPLEFT", 20, -70); nameLabel:SetText("MACRO NAME")
    macroName = Edit(editorPane); macroName:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6); macroName:SetPoint("RIGHT", iconButton, "LEFT", -12, 0); macroName:SetHeight(35); macroName:SetMaxLetters(16)
    bodyLabel = Text(editorPane, 11, "muted"); bodyLabel:SetPoint("TOPLEFT", 20, -128); bodyLabel:SetText("MACRO BODY")
    local fontMinus = Button(editorPane, "−", 27, 23); fontMinus:SetPoint("TOPRIGHT", -57, -111)
    editorFontValue = Text(editorPane, 10, "accent2", "RIGHT"); editorFontValue:SetPoint("RIGHT", fontMinus, "LEFT", -7, 0); editorFontValue:SetWidth(40)
    local fontPlus = Button(editorPane, "+", 27, 23); fontPlus:SetPoint("TOPRIGHT", -20, -111)
    fontMinus:SetScript("OnClick", function() ChangeEditorFontSize(-1) end); fontPlus:SetScript("OnClick", function() ChangeEditorFontSize(1) end)
    macroBody = Edit(editorPane, true); macroBody:SetPoint("TOPLEFT", bodyLabel, "BOTTOMLEFT", 0, -6); macroBody:SetPoint("BOTTOMRIGHT", -20, 139); macroBody:SetMaxLetters(255)
    local suggestionPopup = CreateFrame("Frame", nil, editorPane, "BackdropTemplate"); suggestionPopup:SetSize(240, 190); suggestionPopup:SetFrameLevel(editorPane:GetFrameLevel() + 10); RegisterBackdrop(suggestionPopup, "panel"); suggestionPopup:Hide()
    local suggestionTitle = Text(suggestionPopup, 10, "muted"); suggestionTitle:SetPoint("TOPLEFT", 10, -8); suggestionTitle:SetText("MACRO COMMANDS")
    local macroCommands = { "/cast ", "/use ", "/target ", "/focus ", "/assist ", "/mouseover ", "/stopcasting", "/cancelaura ", "/startattack", "/dismount", "/run ", "/click " }
    local suggestionButtons = {}
    for index = 1, 8 do
        local button = Button(suggestionPopup, "", 218, 18); button:SetPoint("TOPLEFT", 10, -24 - (index - 1) * 20); suggestionButtons[index] = button
    end
    local function UpdateSuggestions()
        local text = macroBody:GetText() or ""; local line = text:match("([^\n]*)$") or ""; local partial = line:match("^%s*(/[%w]*)")
        if not partial or #partial < 1 then suggestionPopup:Hide(); return end
        local matches = {}; for _, command in ipairs(macroCommands) do if command:sub(1, #partial):lower() == partial:lower() then matches[#matches + 1] = command end end
        if #matches == 0 then suggestionPopup:Hide(); return end
        suggestionPopup:ClearAllPoints(); suggestionPopup:SetPoint("TOPLEFT", macroBody, "TOPLEFT", 12, -6); suggestionPopup:Show()
        for index, button in ipairs(suggestionButtons) do
            local command = matches[index]; button:SetShown(command ~= nil)
            if command then
                button.label:SetText(command); button:SetScript("OnClick", function()
                    local prefix = text:sub(1, #text - #line); macroBody:SetText(prefix .. command); macroBody:SetCursorPosition(#prefix + #command); suggestionPopup:Hide()
                end)
            end
        end
    end
    macroBody:SetScript("OnTextChanged", function(self, userInput)
        bodyLabel:SetText(string.format("MACRO BODY  %d / 255", string.len(self:GetText() or "")))
        if userInput then UpdateSuggestions() end
    end)
    macroName:SetScript("OnEscapePressed", function() macroName:ClearFocus() end)
    macroBody:SetScript("OnEscapePressed", function() macroBody:ClearFocus() end)
    sourceLabel = Text(editorPane, 10, "muted"); sourceLabel:SetPoint("BOTTOMLEFT", 20, 104); sourceLabel:SetText("SOURCE")
    sourceBox = Edit(editorPane); sourceBox:SetPoint("LEFT", sourceLabel, "RIGHT", 10, 0); sourceBox:SetPoint("RIGHT", -20, 0); sourceBox:SetHeight(27)
    sourceBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    sourceBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    sourceBox:SetScript("OnTextChanged", function(self, userInput) if userInput and selectedRecord then self:SetText(selectedRecord.source or ""); self:HighlightText() end end)
    noteText = Text(editorPane, 10, "muted"); noteText:SetPoint("BOTTOMLEFT", 20, 78); noteText:SetPoint("RIGHT", -20, 0); noteText:SetWordWrap(true)
    local newButton = Button(editorPane, "New", 76, 31); newButton:SetPoint("BOTTOMLEFT", 20, 18); newButton:SetScript("OnClick", ClearEditor)
    local accountSave = Button(editorPane, "Save to Account", 135, 31); accountSave:SetPoint("BOTTOMRIGHT", -162, 18); accountSave:SetScript("OnClick", function() SaveMacro(false) end)
    local characterSave = Button(editorPane, "Save to Character", 142, 31); characterSave:SetPoint("BOTTOMRIGHT", -12, 18); characterSave:SetScript("OnClick", function() SaveMacro(true) end)
    statusText = Text(editorPane, 10, "muted"); statusText:SetPoint("BOTTOMLEFT", newButton, "BOTTOMRIGHT", 12, 10); statusText:SetPoint("RIGHT", accountSave, "LEFT", -10, 0); statusText:SetWordWrap(false)

    local resize = CreateFrame("Button", nil, frame)
    resize:SetSize(20, 20); resize:SetPoint("BOTTOMRIGHT", -2, 2); resize:SetFrameLevel(frame:GetFrameLevel() + 3)
    resize.label = resize:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resize.label:SetPoint("CENTER", 1, -1); resize.label:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE"); resize.label:SetTextColor(Color("accent")); resize.label:SetText("◢")
    resize:SetScript("OnEnter", function(self) self.label:SetTextColor(Color("accent2")); GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText("Resize window"); GameTooltip:Show() end)
    resize:SetScript("OnLeave", function(self) self.label:SetTextColor(Color("accent")); GameTooltip:Hide() end)
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
