local addonName, ns = ...

ns.name = addonName
ns.db = nil

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, loadedName)
    if event == "ADDON_LOADED" and loadedName == addonName then
        if type(RevathsMacroDB) ~= "table" then RevathsMacroDB = {} end
        RevathsMacroDB.font = type(RevathsMacroDB.font) == "string" and RevathsMacroDB.font or "friz"
        RevathsMacroDB.fontSize = math.max(10, math.min(24, tonumber(RevathsMacroDB.fontSize) or 13))
        ns.db = RevathsMacroDB
        if ns.Initialize then ns:Initialize() end
    elseif event ~= "PLAYER_LOGIN" then
        return
    end
    if ns.RedirectBlizzardMacroFrame then ns:RedirectBlizzardMacroFrame() end
end)

SLASH_REVATHSMACRO1 = "/rmacro"
SLASH_REVATHSMACRO2 = "/macroworkshop"
SlashCmdList.REVATHSMACRO = function()
    if ns.Toggle then ns:Toggle() end
end
