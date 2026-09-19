local _, ns = ...

local COLORS = {
    background = { 0.025, 0.032, 0.050, 0.98 },
    panel = { 0.055, 0.070, 0.105, 1 },
    panelAlt = { 0.080, 0.100, 0.145, 1 },
    input = { 0.015, 0.022, 0.036, 1 },
    border = { 0.18, 0.30, 0.40, 1 },
    accent = { 0.20, 0.78, 0.82, 1 },
    text = { 0.92, 0.95, 0.98, 1 },
    muted = { 0.57, 0.66, 0.75, 1 },
    danger = { 0.95, 0.35, 0.38, 1 },
}

local FONTS = {
    { key = "friz", label = "Friz Quadrata", path = STANDARD_TEXT_FONT, flags = "" },
    { key = "arial", label = "Arial Narrow", path = "Fonts\\ARIALN.TTF", flags = "" },
    { key = "morpheus", label = "Morpheus", path = "Fonts\\MORPHEUS.TTF", flags = "" },
    { key = "skurri", label = "Skurri", path = "Fonts\\SKURRI.TTF", flags = "" },
}

local fontObjects = {}
local frame
local macroName
local macroBody
local bodyLabel
local statusText
local fontButton
local fontMenu
local sizeSlider
local sizeValue
local selectedIndex
local selectedIcon
local rowButtons = {}
local rows

local function Color(color)
    return unpack(COLORS[color])
end

local function Backdrop(object, color)
    object:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    object:SetBackdropColor(Color(color or "panel"))
    object:SetBackdropBorderColor(Color("border"))
end

local function Text(parent, size, color, justify)
    local object = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    object:SetFont(STANDARD_TEXT_FONT, size, "")
    object:SetTextColor(Color(color or "text"))
    object:SetJustifyH(justify or "LEFT")
    fontObjects[object] = true
    return object
end

local function Button(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    Backdrop(button, "panelAlt")
    button.label = Text(button, 12, "text", "CENTER")
    button.label:SetPoint("CENTER")
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(Color("accent"))
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(Color("border"))
    end)
    return button
end

local function Edit(parent, multiline)
    local object = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    Backdrop(object, "input")
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
    for _, option in ipairs(FONTS) do
        if option.key == key then return option end
    end
    return FONTS[1]
end

local function ApplyFont()
    local option = SelectedFont()
    for object in pairs(fontObjects) do
        if object and object.GetFont and object.SetFont then
            local _, size, flags = object:GetFont()
            local ok, loaded = pcall(object.SetFont, object, option.path, size or 12, option.flags or flags or "")
            if not ok or loaded == false then object:SetFont(STANDARD_TEXT_FONT, size or 12, option.flags or "") end
        end
    end
    fontButton.label:SetText(option.label)
end

local function ApplyBodyFont()
    if not macroBody then return end
    local option = SelectedFont()
    local size = ns.db and ns.db.fontSize or 13
    local ok, loaded = pcall(macroBody.SetFont, macroBody, option.path, size, option.flags or "")
    if not ok or loaded == false then macroBody:SetFont(STANDARD_TEXT_FONT, size, option.flags or "") end
    sizeValue:SetText(string.format("%d", size))
end

local function SetStatus(message, isError)
    statusText:SetText(message or "")
    statusText:SetTextColor(Color(isError and "danger" or "muted"))
end

local function ClearEditor()
    selectedIndex = nil
    selectedIcon = nil
    macroName:SetText("")
    macroBody:SetText("")
    SetStatus("Ready for a new macro.")
end

local function ImportMacro(index)
    local name, icon, body = GetMacroInfo(index)
    if not name then return end
    selectedIndex = index
    selectedIcon = icon
    macroName:SetText(name)
    macroBody:SetText(body or "")
    SetStatus(string.format("Imported %s. Save when you are ready.", name))
    macroBody:SetFocus()
end

local function RefreshRows()
    for _, row in ipairs(rowButtons) do row:Hide() end
    local globalCount, characterCount = GetNumMacros()
    local total = (globalCount or 0) + (characterCount or 0)
    rows:SetHeight(math.max(1, total * 32))
    for index = 1, total do
        local name = GetMacroInfo(index)
        if name then
            local row = rowButtons[index]
            if not row then
                row = Button(rows, "", 210, 28)
                row:SetPoint("TOPLEFT", 0, -((index - 1) * 32))
                row.label:SetJustifyH("LEFT")
                row.label:ClearAllPoints()
                row.label:SetPoint("LEFT", 9, 0)
                rowButtons[index] = row
            end
            row.label:SetText(name)
            row:SetScript("OnClick", function() ImportMacro(index) end)
            row:Show()
        end
    end
    if total == 0 then SetStatus("No existing macros. Create one below.") end
end

local function SaveMacro()
    local name = string.gsub(macroName:GetText() or "", "^%s*(.-)%s*$", "%1")
    local body = macroBody:GetText() or ""
    if name == "" then SetStatus("Enter a macro name first.", true); return end
    if body == "" then SetStatus("Enter a macro body first.", true); return end
    local ok, result
    if selectedIndex then
        ok, result = pcall(EditMacro, selectedIndex, name, selectedIcon, body)
    else
        ok, result = pcall(CreateMacro, name, "INV_Misc_Note", body, false)
    end
    if ok and result ~= false then
        SetStatus("Macro saved. Blizzard may restrict this during combat.")
        RefreshRows()
    else
        SetStatus("The game refused this change. Try again outside combat.", true)
    end
end

local function BuildUI()
    frame = CreateFrame("Frame", "RevathsMacroFrame", UIParent, "BackdropTemplate")
    frame:SetSize(900, 590)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    Backdrop(frame, "background")

    local title = Text(frame, 23, "text")
    title:SetPoint("TOPLEFT", 24, -20)
    title:SetText("REVATH'S |cff33c5d0MACRO WORKSHOP|r")
    local subtitle = Text(frame, 11, "muted")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -5)
    subtitle:SetText("IMPORT, EDIT, AND MANAGE YOUR MACROS")

    local close = Button(frame, "X", 30, 30)
    close:SetPoint("TOPRIGHT", -16, -16)
    close:SetScript("OnClick", function() frame:Hide() end)

    local list = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    list:SetPoint("TOPLEFT", 22, -84)
    list:SetPoint("BOTTOMLEFT", 22, 24)
    list:SetWidth(246)
    Backdrop(list)
    local listTitle = Text(list, 14, "text")
    listTitle:SetPoint("TOPLEFT", 16, -16)
    listTitle:SetText("YOUR MACROS")
    local listHint = Text(list, 11, "muted")
    listHint:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 0, -5)
    listHint:SetText("Click a macro to import it.")

    local scroll = CreateFrame("ScrollFrame", nil, list, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -58)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)
    rows = CreateFrame("Frame", nil, scroll)
    rows:SetSize(210, 1)
    scroll:SetScrollChild(rows)

    local editor = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    editor:SetPoint("TOPLEFT", list, "TOPRIGHT", 14, 0)
    editor:SetPoint("BOTTOMRIGHT", -22, 24)
    Backdrop(editor)

    local editorTitle = Text(editor, 18, "text")
    editorTitle:SetPoint("TOPLEFT", 20, -18)
    editorTitle:SetText("Macro Editor")
    local editorHint = Text(editor, 11, "muted")
    editorHint:SetPoint("TOPLEFT", editorTitle, "BOTTOMLEFT", 0, -6)
    editorHint:SetText("Import an existing macro or start a new one.")

    local nameLabel = Text(editor, 11, "muted")
    nameLabel:SetPoint("TOPLEFT", 20, -70)
    nameLabel:SetText("MACRO NAME")
    macroName = Edit(editor)
    macroName:SetSize(300, 35)
    macroName:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6)

    bodyLabel = Text(editor, 11, "muted")
    bodyLabel:SetPoint("TOPLEFT", 20, -128)
    bodyLabel:SetText("MACRO BODY")
    macroBody = Edit(editor, true)
    macroBody:SetPoint("TOPLEFT", bodyLabel, "BOTTOMLEFT", 0, -6)
    macroBody:SetPoint("BOTTOMRIGHT", -20, 105)
    macroBody:SetMaxLetters(255)
    macroBody:SetScript("OnTextChanged", function(self)
        bodyLabel:SetText(string.format("MACRO BODY  %d / 255", string.len(self:GetText() or "")))
    end)

    local fontLabel = Text(editor, 11, "muted")
    fontLabel:SetPoint("BOTTOMLEFT", 20, 73)
    fontLabel:SetText("FONT")
    fontButton = Button(editor, "Friz Quadrata", 190, 28)
    fontButton:SetPoint("LEFT", fontLabel, "RIGHT", 12, 0)

    fontMenu = CreateFrame("Frame", nil, editor, "BackdropTemplate")
    fontMenu:SetSize(202, #FONTS * 30 + 10)
    fontMenu:SetPoint("BOTTOMLEFT", fontButton, "TOPLEFT", 0, 4)
    fontMenu:SetFrameLevel(editor:GetFrameLevel() + 10)
    Backdrop(fontMenu)
    for index, option in ipairs(FONTS) do
        local optionButton = Button(fontMenu, option.label, 190, 26)
        optionButton:SetPoint("TOPLEFT", 6, -6 - ((index - 1) * 30))
        optionButton:SetScript("OnClick", function()
            ns.db.font = option.key
            ApplyFont()
            ApplyBodyFont()
            fontMenu:Hide()
        end)
    end
    fontMenu:Hide()
    fontButton:SetScript("OnClick", function() fontMenu:SetShown(not fontMenu:IsShown()) end)

    local sizeLabel = Text(editor, 11, "muted")
    sizeLabel:SetPoint("BOTTOMLEFT", 300, 73)
    sizeLabel:SetText("SIZE")
    sizeValue = Text(editor, 11, "accent")
    sizeValue:SetPoint("LEFT", sizeLabel, "RIGHT", 8, 0)
    sizeSlider = CreateFrame("Slider", nil, editor)
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -9)
    sizeSlider:SetSize(210, 18)
    sizeSlider:SetOrientation("HORIZONTAL")
    sizeSlider:SetMinMaxValues(10, 24)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local track = sizeSlider:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(Color("border"))
    track:SetPoint("LEFT", 2, 0)
    track:SetPoint("RIGHT", -2, 0)
    track:SetHeight(4)
    sizeSlider:SetScript("OnValueChanged", function(_, value)
        ns.db.fontSize = math.floor(value + 0.5)
        ApplyBodyFont()
    end)

    local newButton = Button(editor, "New macro", 105, 30)
    newButton:SetPoint("BOTTOMLEFT", 20, 18)
    newButton:SetScript("OnClick", ClearEditor)
    local saveButton = Button(editor, "Create / Update", 140, 30)
    saveButton:SetPoint("BOTTOMRIGHT", -20, 18)
    saveButton:SetScript("OnClick", SaveMacro)

    statusText = Text(editor, 11, "muted")
    statusText:SetPoint("BOTTOMLEFT", 300, 28)
    statusText:SetPoint("BOTTOMRIGHT", -180, 28)

    table.insert(UISpecialFrames, frame:GetName())
    ApplyFont()
    sizeSlider:SetValue(ns.db.fontSize)
    RefreshRows()
end

function ns:Initialize()
    BuildUI()
end

function ns:Toggle()
    if not frame then return end
    if frame:IsShown() then
        frame:Hide()
    else
        ApplyFont()
        ApplyBodyFont()
        RefreshRows()
        frame:Show()
    end
end
