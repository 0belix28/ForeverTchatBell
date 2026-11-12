-- ForeverTchatBell : un son au choix pour chaque canal du tchat.
local ADDON, ns = ...

-- Son par défaut : ouverture de l'hôtel des ventes (la cloche).
local BELL = { id = (SOUNDKIT and SOUNDKIT.AUCTION_WINDOW_OPEN) or 5274, kit = true, name = "auction_window_open" }
ns.DEFAULT_SOUND = BELL

-- Canaux du tchat : clé, nom affiché, événements, activé par défaut.
ns.CHANNELS = {
    { key = "guild",     label = "Guilde",               on = true,  events = { "CHAT_MSG_GUILD" } },
    { key = "officer",   label = "Officiers",            on = false, events = { "CHAT_MSG_OFFICER" } },
    { key = "whisper",   label = "Chuchotements",        on = false, events = { "CHAT_MSG_WHISPER" } },
    { key = "bnet",      label = "Chuchotements Battle.net", on = false, events = { "CHAT_MSG_BN_WHISPER" } },
    { key = "party",     label = "Groupe",               on = false, events = { "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER" } },
    { key = "raid",      label = "Raid",                 on = false, events = { "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" } },
    { key = "raidwarn",  label = "Avertissement de raid", on = false, events = { "CHAT_MSG_RAID_WARNING" } },
    { key = "instance",  label = "Instance",             on = false, events = { "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER" } },
    { key = "say",       label = "Dire",                 on = false, events = { "CHAT_MSG_SAY" } },
    { key = "yell",      label = "Crier",                on = false, events = { "CHAT_MSG_YELL" } },
    { key = "channel",   label = "Canaux (Commerce, Général...)", on = false, events = { "CHAT_MSG_CHANNEL" } },
    { key = "community", label = "Communautés",          on = false, events = { "CHAT_MSG_COMMUNITIES_CHANNEL" } },
}

local EVENT_TO_KEY = {}
for _, c in ipairs(ns.CHANNELS) do
    for _, e in ipairs(c.events) do EVENT_TO_KEY[e] = c.key end
end

local DEFAULTS = {
    enabled = true,    -- addon actif
    self = false,      -- jouer aussi pour ses propres messages
    master = true,     -- canal audio "Master" : s'entend même si les effets sonores sont coupés
    delay = 2,         -- secondes minimum entre deux sons d'un même canal (anti-spam)
}

local PREFIX = "|cff33ccffForeverTchatBell|r : "
function ns.Print(msg) DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg) end

function ns.Version()
    local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return (get and get(ADDON, "Version")) or "?"
end

-- Réglages d'un canal : { on = bool, sound = { id, kit, name } }
function ns.Chan(key)
    local db = ns.db
    local c = db.channels[key]
    if not c then
        c = {}
        db.channels[key] = c
    end
    if c.on == nil then
        for _, def in ipairs(ns.CHANNELS) do if def.key == key then c.on = def.on end end
    end
    if type(c.sound) ~= "table" or not tonumber(c.sound.id) then c.sound = CopyTable(BELL) end
    return c
end

function ns.PlaySound(s)
    if not s or not s.id then return end
    local ch = ns.db.master and "Master" or "SFX"
    if s.kit then
        PlaySound(s.id, ch)
    else
        PlaySoundFile(s.id, ch)
    end
end

local lastPlay = {}

-- Vrai si le message vient du joueur lui-même. Les valeurs "secrètes" du client
-- (comparaison impossible) sont protégées par pcall : en cas de doute, on joue.
local function IsMine(guid)
    local ok, mine = pcall(function() return guid ~= nil and guid == UnitGUID("player") end)
    return ok and mine
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
for e in pairs(EVENT_TO_KEY) do pcall(f.RegisterEvent, f, e) end
f:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= ADDON then return end
        ForeverTchatBellDB = ForeverTchatBellDB or {}
        local db = ForeverTchatBellDB
        for k, v in pairs(DEFAULTS) do
            if db[k] == nil then db[k] = v end
        end
        db.channels = type(db.channels) == "table" and db.channels or {}
        ns.db = db
        for _, c in ipairs(ns.CHANNELS) do ns.Chan(c.key) end
        f:UnregisterEvent("ADDON_LOADED")
        return
    end

    local db = ns.db
    if not db or not db.enabled then return end
    local key = EVENT_TO_KEY[event]
    local c = key and db.channels[key]
    if not c or not c.on then return end
    if not db.self and IsMine((select(12, ...))) then return end
    local now = GetTime()
    if lastPlay[key] and now - lastPlay[key] < db.delay then return end
    lastPlay[key] = now
    ns.PlaySound(c.sound)
end)

local function OnOff(v) return v and "|cff00ff00activé|r" or "|cffff0000désactivé|r" end
ns.OnOff = OnOff

SLASH_FOREVERTCHATBELL1 = "/ftb"
SLASH_FOREVERTCHATBELL2 = "/tchatbell"
SlashCmdList.FOREVERTCHATBELL = function(input)
    if not ns.db then return end
    local cmd = strtrim(input or ""):lower():match("^(%S*)")
    if cmd == "" or cmd == "options" or cmd == "config" then
        ForeverTchatBell_OpenOptions()
    elseif cmd == "toggle" then
        ns.db.enabled = not ns.db.enabled
        ns.Print("sons du tchat " .. OnOff(ns.db.enabled))
        if ns.RefreshOptions then ns.RefreshOptions() end
    elseif cmd == "test" then
        ns.PlaySound(ns.Chan("guild").sound)
    else
        ns.Print("v" .. ns.Version() .. " — état : " .. OnOff(ns.db.enabled))
        ns.Print("/ftb — ouvrir le panneau de configuration")
        ns.Print("/ftb toggle — activer / désactiver tous les sons")
        ns.Print("/ftb test — jouer le son de la guilde")
    end
end
