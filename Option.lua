-- ForeverTchatBell - Panneau du menu Options (Échap > Options > AddOns)
-- Même direction artistique que ForeverEgo : logo + titre doré, encadrés à bord doré.
local ADDON, ns = ...

local LOGO = "Interface\\AddOns\\ForeverTchatBell\\Media\\Logo"
local TITLE_FONT = "Fonts\\MORPHEUS.TTF"
local GOLD_R, GOLD_G, GOLD_B = 1, 0.82, 0
local ROW_H = 24
local LABEL_W = 220

local panel = CreateFrame("Frame")
panel.name = "ForeverTchatBell"
panel:Hide()

local rows = {}
local general = {}

local function HasLibrary() return type(ForeverSoundLibrary_Pick) == "function" end

local function SoundText(s)
    if not s then return "?" end
    local def = ns.DEFAULT_SOUND
    local tag = (s.kit and s.id == def.id) and " |cff888888(cloche HV)|r" or ""
    return (s.name or "?") .. tag
end

local function Tooltip(widget, title, text)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title)
        if text then GameTooltip:AddLine(type(text) == "function" and text() or text, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", GameTooltip_Hide)
end

local function Check(parent, label, onClick)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.label:SetText(label)
    cb:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
    return cb
end

local function Button(parent, text, w, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, 21)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

-- Encadré doré façon ForeverEgo : fond sombre, bord doré, titre + trait doré.
local function Box(parent, anchor, title, gap)
    local box = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetPoint("TOP", anchor, "BOTTOM", 0, -(gap or 22))
    box:SetPoint("LEFT", parent, "LEFT", 30, 0)
    box:SetPoint("RIGHT", parent, "RIGHT", -30, 0)
    if box.SetBackdrop then
        box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        box:SetBackdropColor(0, 0, 0, 0.35)
        box:SetBackdropBorderColor(GOLD_R, GOLD_G, GOLD_B, 0.35)
    end
    local header = box:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetText(title)
    local line = box:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(GOLD_R, GOLD_G, GOLD_B, 0.4)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 14, -34)
    line:SetPoint("TOPRIGHT", -14, -34)
    box.y = -42   -- position de la prochaine ligne
    return box
end

-- Ligne d'un encadré (une bande claire une ligne sur deux).
local function BoxRow(box, i)
    local row = CreateFrame("Frame", nil, box)
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", 6, box.y)
    row:SetPoint("TOPRIGHT", -6, box.y)
    if i % 2 == 0 then
        local stripe = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        stripe:SetAllPoints()
        stripe:SetColorTexture(1, 1, 1, 0.04)
    end
    box.y = box.y - ROW_H
    return row
end

local function CloseBox(box) box:SetHeight(-box.y + 10) end

function ns.RefreshOptions()
    if not panel.built or not ns.db then return end
    local db = ns.db
    general.toggle:SetText(db.enabled and "Sons du tchat : |cff00ff00activés|r" or "Sons du tchat : |cffff4040désactivés|r")
    general.self:SetChecked(db.self)
    general.master:SetChecked(db.master)
    general.delay:SetText(db.delay .. " s")
    local lib = HasLibrary()
    for _, r in ipairs(rows) do
        local c = ns.Chan(r.key)
        local a = (c.on and db.enabled) and 1 or 0.45
        r.check:SetChecked(c.on)
        r.check.label:SetAlpha(a)
        r.sound:SetText(SoundText(c.sound))
        r.sound:SetAlpha(a)
        if lib then r.change:Enable() else r.change:Disable() end
    end
    panel.libWarn:SetShown(not lib)
end

local function Build()
    if panel.built then return end
    panel.built = true

    -- Le contenu dépasse la hauteur du menu Options : on le met dans une zone défilante.
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(600, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnSizeChanged", function(self, w) content:SetWidth(w) end)

    -- Bloc du haut : logo + nom de l'addon
    local head = CreateFrame("Frame", nil, content)
    head:SetSize(1, 72)
    head:SetPoint("TOP", 0, -36)

    local logo = head:CreateTexture(nil, "ARTWORK")
    logo:SetSize(64, 64)
    logo:SetTexture(LOGO)

    local title = head:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    if not title:SetFont(TITLE_FONT, 46, "") then
        title:SetFontObject("GameFontNormalHuge")
    end
    title:SetText("ForeverTchatBell")
    title:SetTextColor(GOLD_R, GOLD_G, GOLD_B)
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)

    local gap = 16
    head:SetWidth(64 + gap + title:GetStringWidth())
    logo:SetPoint("LEFT", head, "LEFT", 0, 0)
    title:SetPoint("LEFT", logo, "RIGHT", gap, -2)

    local version = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    version:SetPoint("TOP", head, "BOTTOM", 0, -14)
    version:SetText("Version : " .. ns.Version())

    local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    hint:SetPoint("TOP", version, "BOTTOM", 0, -10)
    hint:SetText("Un son à chaque message reçu, au choix pour chaque canal du tchat")

    -- Gros bouton : tout activer / désactiver
    local toggle = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    toggle:SetSize(280, 34)
    toggle:SetPoint("TOP", hint, "BOTTOM", 0, -20)
    toggle:SetNormalFontObject("GameFontNormalLarge")
    toggle:SetHighlightFontObject("GameFontHighlightLarge")
    toggle:SetScript("OnClick", function()
        ns.db.enabled = not ns.db.enabled
        ns.RefreshOptions()
    end)
    general.toggle = toggle

    -- Encadré « Réglages »
    local opts = Box(content, toggle, "Réglages", 28)

    local r1 = BoxRow(opts, 1)
    general.self = Check(r1, "Jouer aussi pour mes propres messages", function(v) ns.db.self = v end)
    general.self:SetPoint("LEFT", 6, 0)

    local r2 = BoxRow(opts, 2)
    general.master = Check(r2, "Canal audio Master", function(v) ns.db.master = v end)
    general.master:SetPoint("LEFT", 6, 0)
    local masterNote = r2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    masterNote:SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    masterNote:SetPoint("RIGHT", -8, 0)
    masterNote:SetJustifyH("LEFT")
    masterNote:SetWordWrap(false)
    masterNote:SetText("Audible même si les effets sonores sont coupés")

    local r3 = BoxRow(opts, 3)
    local dl = r3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dl:SetPoint("LEFT", 36, 0)
    dl:SetText("Délai anti-spam")
    local minus = Button(r3, "-", 24, function()
        ns.db.delay = math.max(0, ns.db.delay - 1); ns.RefreshOptions()
    end)
    minus:SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    general.delay = r3:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    general.delay:SetPoint("LEFT", minus, "RIGHT", 6, 0)
    general.delay:SetWidth(36)
    local plus = Button(r3, "+", 24, function()
        ns.db.delay = math.min(60, ns.db.delay + 1); ns.RefreshOptions()
    end)
    plus:SetPoint("LEFT", general.delay, "RIGHT", 6, 0)
    local dnote = r3:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dnote:SetPoint("LEFT", plus, "RIGHT", 10, 0)
    dnote:SetPoint("RIGHT", -8, 0)
    dnote:SetJustifyH("LEFT")
    dnote:SetWordWrap(false)
    dnote:SetText("entre deux sons d'un même canal")
    local dtip = "Temps minimum entre deux sons d'un même canal, quand beaucoup de messages arrivent d'un coup. 0 = un son à chaque message."
    Tooltip(minus, "Délai anti-spam", dtip)
    Tooltip(plus, "Délai anti-spam", dtip)
    CloseBox(opts)

    -- Encadré « Sons par canal »
    local chans = Box(content, opts, "Sons par canal")
    for i, def in ipairs(ns.CHANNELS) do
        local r = { key = def.key }
        local row = BoxRow(chans, i)

        r.check = Check(row, def.label, function(v) ns.Chan(def.key).on = v; ns.RefreshOptions() end)
        r.check:SetPoint("LEFT", 6, 0)

        r.def = Button(row, "Défaut", 60, function()
            ns.Chan(def.key).sound = CopyTable(ns.DEFAULT_SOUND)
            ns.RefreshOptions()
        end)
        r.def:SetPoint("RIGHT", -6, 0)
        Tooltip(r.def, "Son par défaut", "Remet la cloche de l'hôtel des ventes.")

        r.change = Button(row, "Changer...", 84, function()
            if not HasLibrary() then return end
            ForeverSoundLibrary_Pick(function(s)
                ns.Chan(def.key).sound = { id = s.id, kit = s.kit, name = s.name }
                ns.RefreshOptions()
                ns.Print(def.label .. " : son changé pour " .. s.name)
            end, "ForeverTchatBell - " .. def.label)
        end)
        r.change:SetPoint("RIGHT", r.def, "LEFT", -4, 0)
        r.change:SetMotionScriptsWhileDisabled(true)
        Tooltip(r.change, "Changer le son", function()
            if HasLibrary() then
                return "Ouvre ForeverSoundLibrary : cliquez un son pour l'écouter, puis validez avec le bouton en haut de la fenêtre."
            end
            return "|cffff6060ForeverSoundLibrary n'est pas chargé.|r Activez-le dans la liste des AddOns puis relancez le jeu."
        end)

        r.play = Button(row, "Écouter", 66, function() ns.PlaySound(ns.Chan(def.key).sound) end)
        r.play:SetPoint("RIGHT", r.change, "LEFT", -4, 0)

        r.sound = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        r.sound:SetPoint("LEFT", 14 + LABEL_W + 4, 0)
        r.sound:SetPoint("RIGHT", r.play, "LEFT", -8, 0)
        r.sound:SetJustifyH("LEFT")
        r.sound:SetWordWrap(false)

        rows[i] = r
    end
    panel.libWarn = chans:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
    panel.libWarn:SetPoint("TOPLEFT", 14, chans.y - 6)
    panel.libWarn:SetPoint("RIGHT", -14, 0)
    panel.libWarn:SetJustifyH("LEFT")
    panel.libWarn:SetText("ForeverSoundLibrary n'est pas chargé : « Changer... » est indisponible. Activez-le dans la liste des AddOns.")
    chans.y = chans.y - 20
    CloseBox(chans)

    -- Encadré « Commandes »
    local cmds = Box(content, chans, "Commandes")
    local COMMANDS = {
        { "/ftb", "Ouvrir ce panneau d'options" },
        { "/ftb toggle", "Activer / désactiver tous les sons" },
        { "/ftb test", "Jouer le son de la guilde" },
        { "/ftb help", "Afficher l'aide dans le tchat" },
    }
    for i, c in ipairs(COMMANDS) do
        local row = BoxRow(cmds, i)
        local cmd = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cmd:SetPoint("LEFT", 8, 0)
        cmd:SetWidth(LABEL_W)
        cmd:SetJustifyH("LEFT")
        cmd:SetText(c[1])
        local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        desc:SetPoint("LEFT", 14 + LABEL_W + 4, 0)
        desc:SetPoint("RIGHT", -8, 0)
        desc:SetJustifyH("LEFT")
        desc:SetWordWrap(false)
        desc:SetText(c[2])
    end
    CloseBox(cmds)

    -- Hauteur totale du contenu défilant
    C_Timer.After(0, function()
        local top, bottom = content:GetTop(), cmds:GetBottom()
        if top and bottom then content:SetHeight(top - bottom + 30) end
    end)
    content:SetHeight(1100)
end

panel:SetScript("OnShow", function()
    Build()
    ns.RefreshOptions()
end)

-- Enregistrement dans le menu Options
local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

function ForeverTchatBell_OpenOptions()
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category.GetID and category:GetID() or category.ID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
