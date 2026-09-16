local addonName = ...
local database
local currentCharacterKey
local isBankOpen = false

local function getCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName() or "Unknown Realm"
    return realm .. " - " .. name
end

local function getItemID(itemLink)
    if not itemLink then
        return nil
    end

    return C_Item.GetItemInfoInstant(itemLink)
end

local function addContainerItems(containerID, counts)
    local slotCount = C_Container.GetContainerNumSlots(containerID) or 0

    for slot = 1, slotCount do
        local itemInfo = C_Container.GetContainerItemInfo(containerID, slot)
        if itemInfo and itemInfo.hyperlink then
            local itemID = getItemID(itemInfo.hyperlink)
            if itemID then
                counts[itemID] = (counts[itemID] or 0) + (itemInfo.stackCount or 1)
            end
        end
    end
end

local function scanCharacter()
    local bags = {}

    addContainerItems(BACKPACK_CONTAINER, bags)
    for bagID = 1, NUM_BAG_SLOTS do
        addContainerItems(bagID, bags)
    end

    local character = database.characters[currentCharacterKey] or {}
    character.bags = bags
    if isBankOpen then
        local bank = {}
        addContainerItems(BANK_CONTAINER, bank)
        for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
            addContainerItems(bagID, bank)
        end
        addContainerItems(REAGENTBANK_CONTAINER, bank)
        character.bank = bank
    end

    database.characters[currentCharacterKey] = character
end

local function getTotal(itemID)
    local total = 0
    local currentCount = 0

    for characterKey, counts in pairs(database.characters) do
        local characterBags = counts.bags or {}
        local characterBank = counts.bank or {}
        local count = (characterBags[itemID] or 0) + (characterBank[itemID] or 0)
        total = total + count
        if characterKey == currentCharacterKey then
            currentCount = count
        end
    end

    return total, currentCount
end

local function addTooltipCount(tooltip)
    local _, itemLink = tooltip:GetItem()
    local itemID = getItemID(itemLink)
    if not itemID or not database or not database.characters then
        return
    end

    local total, currentCount = getTotal(itemID)
    if total == 0 then
        return
    end

    tooltip:AddDoubleLine(
        "Revath's Tooltip Helper",
        string.format("%d total", total),
        0.45, 0.8, 1,
        1, 1, 1
    )
    tooltip:AddLine(string.format("This character: %d", currentCount), 0.75, 0.75, 0.75)
    tooltip:Show()
end

local function rescan()
    if database and currentCharacterKey then
        scanCharacter()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("BANKFRAME_CLOSED")
eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        database = RevathsTooltipHelperDB or { characters = {} }
        database.characters = database.characters or {}
        RevathsTooltipHelperDB = database
        currentCharacterKey = getCharacterKey()
        rescan()
    elseif event == "BANKFRAME_OPENED" then
        isBankOpen = true
        rescan()
    elseif event == "BANKFRAME_CLOSED" then
        isBankOpen = false
    else
        rescan()
    end
end)

GameTooltip:HookScript("OnTooltipSetItem", addTooltipCount)
ItemRefTooltip:HookScript("OnTooltipSetItem", addTooltipCount)

SLASH_REVATHSTOOLTIPHELPER1 = "/rth"
SlashCmdList.REVATHSTOOLTIPHELPER = function(message)
    local command = string.lower(message or "")
    if command == "rescan" or command == "" then
        rescan()
        print("Revath's Tooltip Helper: character inventory rescanned.")
    else
        print("Revath's Tooltip Helper commands: /rth rescan")
    end
end