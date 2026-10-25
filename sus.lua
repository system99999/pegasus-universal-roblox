--[[
    Pegasus — v2.2.1
    Made by Urban. Tested by YuleTide.

    A client-side framework I put together over a few weeks. Wrote every chunk
    by hand, kept the design tight, tuned the aim until it stopped feeling
    robotic. YuleTide ran it on his machine, broke it a dozen times, and told
    me what felt off. This build is what came out the other side.

    Chunk order: combat -> gui -> tabs -> runtime
]]

local G = getgenv and getgenv() or _G
G._pegasus = G._pegasus or {}
local P = G._pegasus
P.errors = P.errors or {}

local function bootstrap()
    local function diag(msg)
        if rconsoleprint then rconsoleprint(msg .. "\n") end
        if print then print(msg) end
        if warn then warn(msg) end
    end

    do
        local ok, lp = pcall(function() return game:GetService("Players").LocalPlayer end)
        if not ok or not lp or not lp.Parent then
            diag("[Pegasus] bootstrap aborted: DataModel invalid")
            return false
        end
    end

    P.PEGASUS_VERSION    = "2.2.1"
    P.PEGASUS_SUBVERSION = "release"
    P.PEGASUS_NAME       = "Pegasus"
    P.PEGASUS_ICON_ASSET = "rbxassetid://77142792778121"
    P.PEGASUS_BANNER     = "rbxassetid://9802509067"
    P.PEGASUS_AUTHOR     = "Urban"
    P.PEGASUS_TESTER     = "YuleTide"

    P.Players             = game:GetService("Players")
    P.UserInputService    = game:GetService("UserInputService")
    P.RunService          = game:GetService("RunService")
    P.Workspace           = game:GetService("Workspace")
    P.VirtualInputManager = game:GetService("VirtualInputManager")
    P.TextService         = game:GetService("TextService")
    P.TweenService        = game:GetService("TweenService")
    P.HttpService         = game:GetService("HttpService")
    P.LocalPlayer         = P.Players.LocalPlayer

    do
        local pgOk, pg = pcall(function()
            return P.LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
        if not pgOk or not pg then
            diag("[Pegasus] bootstrap aborted: PlayerGui unavailable")
            return false
        end
        P.PlayerGui = pg
    end

    P.IS_TOUCH    = P.UserInputService.TouchEnabled and not P.UserInputService.KeyboardEnabled
    P.IS_COMPUTER = P.UserInputService.KeyboardEnabled and P.UserInputService.MouseEnabled

    P.hasTeamsService = false
    do
        local ok, svc = pcall(function() return game:GetService("Teams") end)
        if ok and svc then P.hasTeamsService = true end
    end

    if not Drawing then
        diag("[Pegasus] bootstrap aborted: Drawing library unavailable")
        return false
    end
    if type(Drawing.new) ~= "function" then
        diag("[Pegasus] bootstrap aborted: Drawing.new not a function")
        return false
    end

    P.console = function(msg)
        if rconsoleprint then rconsoleprint(msg .. "\n") end
        if print then print("[Pegasus] " .. msg) end
    end

    P.logError = function(msg)
        P.errors[#P.errors+1] = msg
        if rconsoleprint then rconsoleprint("[Pegasus][ERR] " .. msg .. "\n") end
        if warn then warn("[Pegasus][ERR] " .. msg) end
        if print then print("[Pegasus][ERR] " .. msg) end
    end

    P.console("[Pegasus] preflight v" .. P.PEGASUS_VERSION .. " " .. P.PEGASUS_SUBVERSION)

    P.saveKey    = "pegasus_settings_" .. P.LocalPlayer.UserId
    P.savedTable = (getgenv and getgenv()[P.saveKey]) or {}

    P.PAL = {
        bg = Color3.fromRGB(33, 33, 33), bg2 = Color3.fromRGB(38, 38, 38),
        panel = Color3.fromRGB(28, 28, 28), panelDeep = Color3.fromRGB(20, 20, 20),
        surface = Color3.fromRGB(42, 42, 42), surfaceHover = Color3.fromRGB(54, 54, 54),
        hairline = Color3.fromRGB(46, 46, 46), divider = Color3.fromRGB(60, 60, 60),
        text = Color3.fromRGB(232, 240, 248), textDim = Color3.fromRGB(150, 166, 180),
        textFaint = Color3.fromRGB(90, 100, 112),
        accent = Color3.fromRGB(80, 200, 235), accentHover = Color3.fromRGB(115, 220, 250),
        accentDim = Color3.fromRGB(50, 145, 180),
        track = Color3.fromRGB(40, 40, 40), knobOff = Color3.fromRGB(150, 166, 180),
        outline = Color3.fromRGB(64, 64, 64),
        success = Color3.fromRGB(80, 220, 150), danger = Color3.fromRGB(235, 95, 95),
        warn = Color3.fromRGB(235, 185, 75),
    }

    P.KEYBIND_MAP = {
        None = nil,
        LeftShift = Enum.KeyCode.LeftShift, RightShift = Enum.KeyCode.RightShift,
        CapsLock = Enum.KeyCode.CapsLock,
        LeftControl = Enum.KeyCode.LeftControl, RightControl = Enum.KeyCode.RightControl,
        LeftAlt = Enum.KeyCode.LeftAlt, RightAlt = Enum.KeyCode.RightAlt,
        Tab = Enum.KeyCode.Tab, Insert = Enum.KeyCode.Insert,
        Home = Enum.KeyCode.Home, End = Enum.KeyCode.End,
        F1 = Enum.KeyCode.F1, F2 = Enum.KeyCode.F2, F3 = Enum.KeyCode.F3,
        F4 = Enum.KeyCode.F4, F5 = Enum.KeyCode.F5, F6 = Enum.KeyCode.F6,
        Q = Enum.KeyCode.Q, E = Enum.KeyCode.E, R = Enum.KeyCode.R, F = Enum.KeyCode.F,
        G = Enum.KeyCode.G, H = Enum.KeyCode.H, P = Enum.KeyCode.P, V = Enum.KeyCode.V,
        B = Enum.KeyCode.B, N = Enum.KeyCode.N, M = Enum.KeyCode.M,
        Z = Enum.KeyCode.Z, X = Enum.KeyCode.X, C = Enum.KeyCode.C, T = Enum.KeyCode.T,
        Y = Enum.KeyCode.Y, U = Enum.KeyCode.U, I = Enum.KeyCode.I, O = Enum.KeyCode.O,
        J = Enum.KeyCode.J, K = Enum.KeyCode.K, L = Enum.KeyCode.L,
        One = Enum.KeyCode.One, Two = Enum.KeyCode.Two, Three = Enum.KeyCode.Three,
        Four = Enum.KeyCode.Four, Five = Enum.KeyCode.Five, Six = Enum.KeyCode.Six,
        Seven = Enum.KeyCode.Seven, Eight = Enum.KeyCode.Eight, Nine = Enum.KeyCode.Nine,
        Zero = Enum.KeyCode.Zero,
        BackSlash = Enum.KeyCode.BackSlash,
        RightBracket = Enum.KeyCode.RightBracket,
        Semicolon = Enum.KeyCode.Semicolon,
        Apostrophe = Enum.KeyCode.Quote,
        Comma = Enum.KeyCode.Comma,
        Period = Enum.KeyCode.Period,
        Slash = Enum.KeyCode.Slash,
    }

    P.KEYCODE_TO_NAME = {}
    for name, kc in pairs(P.KEYBIND_MAP) do
        if kc then P.KEYCODE_TO_NAME[kc] = name end
    end

    P.C = {
        notificationsEnabled = P.savedTable.notificationsEnabled ~= nil and P.savedTable.notificationsEnabled or true,

        aimToggled     = P.savedTable.aimToggled     ~= nil and P.savedTable.aimToggled     or true,
        aimMode        = P.savedTable.aimMode        or "Camera",
        aimActivation  = P.savedTable.aimActivation  or "Toggle",
        aimHeldKey     = false,
        teamCheck      = P.savedTable.teamCheck      ~= nil and P.savedTable.teamCheck      or true,
        aimPart        = P.savedTable.aimPart        or "Head",
        predictorMult  = P.savedTable.predictorMult  or 0.25,
        smoothness     = P.savedTable.smoothness     or 0.62,
        fov            = P.savedTable.fov            or 150,
        updateInterval = P.savedTable.updateInterval or 1,
        wallCheckAim   = P.savedTable.wallCheckAim   ~= nil and P.savedTable.wallCheckAim   or true,
        silentAim      = P.savedTable.silentAim      ~= nil and P.savedTable.silentAim      or false,
        silentChance   = P.savedTable.silentChance   or 100,
        onePressAim    = P.savedTable.onePressAim    ~= nil and P.savedTable.onePressAim    or false,
        offAfterKill   = P.savedTable.offAfterKill   ~= nil and P.savedTable.offAfterKill   or false,
        aimTimeLimit   = P.savedTable.aimTimeLimit   or 0,
        aimOffsetX     = P.savedTable.aimOffsetX     or 0,
        aimOffsetY     = P.savedTable.aimOffsetY     or 0,
        aimOffsetZ     = P.savedTable.aimOffsetZ     or 0,
        aimRandomPart  = P.savedTable.aimRandomPart  ~= nil and P.savedTable.aimRandomPart  or false,
        aimPartList    = P.savedTable.aimPartList    or { "Head", "HumanoidRootPart", "UpperTorso" },
        aimErrorX      = P.savedTable.aimErrorX      or 0,
        aimErrorY      = P.savedTable.aimErrorY      or 0,
        aimRespectFovRing = P.savedTable.aimRespectFovRing ~= nil and P.savedTable.aimRespectFovRing or true,
        aimAutoScope   = P.savedTable.aimAutoScope   ~= nil and P.savedTable.aimAutoScope   or false,
        aimVelocityPred = P.savedTable.aimVelocityPred or 0,
        aimVisibilityCheck = P.savedTable.aimVisibilityCheck ~= nil and P.savedTable.aimVisibilityCheck or true,
        aimTargetAll   = P.savedTable.aimTargetAll   ~= nil and P.savedTable.aimTargetAll   or false,
        aimOnlyVisible = P.savedTable.aimOnlyVisible ~= nil and P.savedTable.aimOnlyVisible or true,
        aimRadiusSort  = P.savedTable.aimRadiusSort  or "Angle",
        aimLockedPart  = P.savedTable.aimLockedPart  ~= nil and P.savedTable.aimLockedPart  or true,
        smartAimbot    = P.savedTable.smartAimbot    ~= nil and P.savedTable.smartAimbot    or true,

        spinBot = false, spinKey = "None", spinVelocity = 50,
        spinPart = "HumanoidRootPart", onePressSpin = false,

        triggerEnabled    = P.savedTable.triggerEnabled ~= nil and P.savedTable.triggerEnabled or false,
        triggerMode       = P.savedTable.triggerMode      or "Toggle",
        triggerHeldKey    = false,
        triggerTeamMode   = P.savedTable.triggerTeamMode  or "FFA",
        triggerDelay      = P.savedTable.triggerDelay     or 0.03,
        triggerCooldown   = P.savedTable.triggerCooldown  or 0.08,
        triggerFov        = P.savedTable.triggerFov       or 80,
        triggerWallCheck  = P.savedTable.triggerWallCheck ~= nil and P.savedTable.triggerWallCheck or true,
        triggerHeadOnly   = P.savedTable.triggerHeadOnly  ~= nil and P.savedTable.triggerHeadOnly  or false,
        triggerAliveCheck = P.savedTable.triggerAliveCheck ~= nil and P.savedTable.triggerAliveCheck or true,
        triggerKey        = P.savedTable.keyTrigger        or "None",
        onePressTrig      = false, smartTrigger = false, triggerChance = 100,
        autoFireLocked    = P.savedTable.autoFireLocked    ~= nil and P.savedTable.autoFireLocked    or false,

        aliveCheck = true, godCheck = false, friendCheck = false, followCheck = false,
        verifiedCheck = false, waterCheck = true, transparencyCheck = false,
        ignoredTransparency = 0.5, whitelistedGroupCheck = false, whitelistedGroup = 0,
        blacklistedGroupCheck = false, blacklistedGroup = 0, magnitudeCheck = false,
        triggerMagnitude = 500, ignoredPlayersCheck = false, ignoredPlayers = {},
        targetPlayersCheck = false, targetPlayers = {},

        trigRingVisible  = P.savedTable.trigRingVisible ~= nil and P.savedTable.trigRingVisible or true,
        trigRingColor    = P.savedTable.trigRingColor    or Color3.fromRGB(80, 200, 235),
        trigRingTrans    = P.savedTable.trigRingTrans    or 0.65,
        trigRingThick    = P.savedTable.trigRingThick    or 2,

        espEnabled     = P.savedTable.espEnabled     ~= nil and P.savedTable.espEnabled     or false,
        streamerMode   = false,
        espMaxPlayers  = P.savedTable.espMaxPlayers  or 5,
        espBox         = P.savedTable.espBox         ~= nil and P.savedTable.espBox         or true,
        espFill        = P.savedTable.espFill        ~= nil and P.savedTable.espFill        or false,
        espName        = P.savedTable.espName        ~= nil and P.savedTable.espName        or true,
        espHealth      = P.savedTable.espHealth      ~= nil and P.savedTable.espHealth      or true,
        espDistance    = P.savedTable.espDistance    ~= nil and P.savedTable.espDistance    or true,
        espTracer      = P.savedTable.espTracer      ~= nil and P.savedTable.espTracer      or false,
        espWallCheck   = P.savedTable.espWallCheck   ~= nil and P.savedTable.espWallCheck   or false,
        espTeamColor   = P.savedTable.espTeamColor   ~= nil and P.savedTable.espTeamColor   or true,
        espBoxColor    = P.savedTable.espBoxColor     or Color3.fromRGB(255, 30, 30),
        espTeamBoxColor= P.savedTable.espTeamBoxColor or Color3.fromRGB(80, 255, 80),
        espFillAlpha   = P.savedTable.espFillAlpha   or 0.15,
        espTextSize    = P.savedTable.espTextSize    or 14,
        espBoxThick    = P.savedTable.espBoxThick    or 1,
        espMaxDist     = P.savedTable.espMaxDist     or 1500,
        espMaxObjects  = 500,

        espOutline          = P.savedTable.espOutline ~= nil and P.savedTable.espOutline or true,
        espOutlineColor     = P.savedTable.espOutlineColor or Color3.fromRGB(255, 255, 255),
        espBoxShadow        = P.savedTable.espBoxShadow ~= nil and P.savedTable.espBoxShadow or true,
        espSkeleton         = P.savedTable.espSkeleton ~= nil and P.savedTable.espSkeleton or false,
        espSkeletonThickness = P.savedTable.espSkeletonThickness or 1,
        espSkeletonColor    = P.savedTable.espSkeletonColor or "Box",

        rainbowVisuals = false, rainbowDelay = 5,
        menuOpen = true,
        statusDraw = P.savedTable.statusDraw ~= nil and P.savedTable.statusDraw or true,
        overlayEnabled = P.savedTable.overlayEnabled ~= nil and P.savedTable.overlayEnabled or true,
        hitMarkerEnabled = P.savedTable.hitMarkerEnabled ~= nil and P.savedTable.hitMarkerEnabled or false,
        accent = P.savedTable.accent or Color3.fromRGB(80, 200, 235),
        fovRingColor = P.savedTable.fovRingColor or Color3.fromRGB(80, 200, 235),
        panelX = P.savedTable.panelX or 80, panelY = P.savedTable.panelY or 60,
        _lastMenuToggle = 0, _fullscreen = false,

        flyEnabled = P.savedTable.flyEnabled ~= nil and P.savedTable.flyEnabled or false,
        flySpeed = P.savedTable.flySpeed or 80,
        speedEnabled = P.savedTable.speedEnabled ~= nil and P.savedTable.speedEnabled or false,
        speedValue = P.savedTable.speedValue or 80,
        jumpEnabled = P.savedTable.jumpEnabled ~= nil and P.savedTable.jumpEnabled or false,
        jumpValue = 25,
        clickTPEnabled = P.savedTable.clickTPEnabled ~= nil and P.savedTable.clickTPEnabled or false,

        radarEnabled = P.savedTable.radarEnabled ~= nil and P.savedTable.radarEnabled or false,
        radarRadius = P.savedTable.radarRadius or 300,
        radarSize = P.savedTable.radarSize or 180,
        radarDotColor = P.savedTable.radarDotColor or Color3.fromRGB(80, 200, 235),
        radarEnemyColor = P.savedTable.radarEnemyColor or Color3.fromRGB(255, 80, 80),
        radarShowHeight = P.savedTable.radarShowHeight ~= nil and P.savedTable.radarShowHeight or true,
        radarSweep = P.savedTable.radarSweep ~= nil and P.savedTable.radarSweep or false,

        crosshairEnabled = P.savedTable.crosshairEnabled ~= nil and P.savedTable.crosshairEnabled or false,
        crosshairSize = P.savedTable.crosshairSize or 8,
        crosshairColor = P.savedTable.crosshairColor or Color3.fromRGB(80, 200, 235),

        targetPanelEnabled = P.savedTable.targetPanelEnabled ~= nil and P.savedTable.targetPanelEnabled or true,

        renderMode = P.savedTable.renderMode or "RenderStepped",

        keyAim = P.savedTable.keyAim or "None",
        keyEsp = P.savedTable.keyEsp or "None",
        keyTrigger = P.savedTable.keyTrigger or "None",
        keyMenu = P.savedTable.keyMenu or "Zero",
        keyStreamer = P.savedTable.keyStreamer or "None",
        keyUnload = P.savedTable.keyUnload or "None",
        keyFov = "None",

        bounds = {
            predictorMult={0.00,0.60}, smoothness={0.00,0.95}, fov={30,400},
            updateInterval={1,10}, aimTimeLimit={0,60},
            aimOffsetX={-20,20}, aimOffsetY={-20,20}, aimOffsetZ={-20,20},
            aimErrorX={0,10}, aimErrorY={0,10}, aimVelocityPred={0,1},
            silentChance={1,100},
            espTextSize={8,24}, espBoxThick={1,4}, espMaxDist={100,5000},
            espMaxPlayers={1,20}, espFillAlpha={0.0,0.5}, espSkeletonThickness={1,4},
            triggerDelay={0.01,0.30}, triggerCooldown={0.00,1.00}, triggerFov={10,400},
            trigRingTrans={0.0,1.0}, trigRingThick={1,5},
            flySpeed={10,500}, speedValue={16,500},
            spinVelocity={1,50}, triggerChance={1,100}, rainbowDelay={1,10},
            triggerMagnitude={10,1000}, ignoredTransparency={0.1,1}, jumpValue={1,500},
            radarRadius={50,2000}, radarSize={120,400},
            crosshairSize={2,24},
        },
    }

    do
        local defaults = {
            keyAim="None", keyEsp="None", keyTrigger="None",
            keyStreamer="None", keyUnload="None", spinKey="None", keyFov="None",
        }
        for k, def in pairs(defaults) do
            local v = P.C[k]
            if type(v) ~= "string" or P.KEYBIND_MAP[v] == nil then P.C[k] = def end
        end
        if type(P.C.keyMenu) ~= "string" or P.KEYBIND_MAP[P.C.keyMenu] == nil then
            P.C.keyMenu = "Zero"
        end
    end

    P.CONFIG_FILE = "pegasus_config_" .. P.LocalPlayer.UserId .. ".json"
    P.CONFIG_FOLDER = "pegasus_configs"

    P.Connections = {}; P.Reg = {}; P.drawingCount = 0
    P.espObjects = {}; P.espInstances = {}
    P.themedSectionHeaders = {}; P.themedRows = {}; P.themedLabels = {}
    P.themedSubLabels = {}; P.themedToggles = {}; P.themedSliders = {}
    P.themedDropdowns = {}; P.themedButtons = {}; P.refreshFns = {}
    P.sectionBarList = {}; P.subTabs = {}; P.subTabButtons = {}
    P.Tabs = {}; P.tabButtons = {}; P.tabIndicators = {}
    P.ActiveTab = "Aim"; P.Target = nil; P.currentTarget = nil
    P.triggerIsAlive = true; P.triggerNextFire = 0; P.spinConn = nil
    P.openDropdown = nil; P.toast = nil; P.toastToken = 0
    P._closeToast = nil
    P.savedFullscreenState = nil; P.keybindCapture = nil
    P.colorPickerOpen = false; P.colorPickerReadouts = {}; P.colorPickerSliderFills = {}
    P._rainbowHue = 0; P._loadingShown = false
    P._aimRescanWait = 0
    P.notifications = {}; P.notificationY = 0
    P.radar = nil
    P.menuToggleConn = nil
    P.menuReady = false
    P.shuttingDown = false
    P._silentInstalled = false
    P._triggerFiring = false
    P.favoriteRows = P.savedTable.favoriteRows or {}
    P.searchQuery = ""
    P.overlayPanel = nil
    P.aimState = {
        target=nil, targetPart=nil, targetChar=nil,
        aimPos=Vector3.zero, rawPos=Vector3.zero,
        lastSeen=0, occludedFor=0, diedConn=nil, charConn=nil,
        _lastVel=nil,
    }
    P.aimRandomPartAccum = 0
    P.adminState = {
        flyBodyVelocity=nil, flyBodyGyro=nil, flyActive=false,
        flyRenderConn=nil, speedLoopConn=nil, jumpLoopConn=nil, clickTPConn=nil,
    }

    P.cachedViewport = Vector2.new(0, 0)
    P.refreshViewport = function()
        local ok, cam = pcall(function() return P.Workspace.CurrentCamera end)
        if ok and cam then P.cachedViewport = cam.ViewportSize end
    end
    pcall(P.refreshViewport)
    P.screenCenter = function() return Vector2.new(P.cachedViewport.X/2, P.cachedViewport.Y/2) end

    P.sameTeam = function(a, b)
        if not P.C.teamCheck then return false end
        if not P.hasTeamsService then return false end
        local ta, tb = a.Team, b.Team
        if ta == nil or tb == nil then return false end
        return ta == tb
    end

    P.teamColorFor = function(p)
        local localT, t = P.LocalPlayer.TeamColor, p.TeamColor
        if P.hasTeamsService then
            if P.LocalPlayer.Team == nil or p.Team == nil then
                if localT == nil or t == nil then return nil end
                return (t == localT) and P.C.espTeamBoxColor or P.C.espBoxColor
            end
            return (p.Team == P.LocalPlayer.Team) and P.C.espTeamBoxColor or P.C.espBoxColor
        end
        if localT == nil or t == nil then return nil end
        return (t == localT) and P.C.espTeamBoxColor or P.C.espBoxColor
    end

    P.mk = function(kind)
        if P.drawingCount >= P.C.espMaxObjects then return nil end
        local ok, o = pcall(Drawing.new, kind)
        if not ok or not o then return nil end
        P.Reg[#P.Reg+1] = o
        P.drawingCount = P.drawingCount + 1
        return o
    end

    P.rm = function(o)
        if not o then return end
        pcall(function() o.Visible = false end)
        pcall(function() o:Remove() end)
    end

    P.setProp = function(obj, prop, value)
        if not obj then return false end
        return pcall(function() obj[prop] = value end)
    end

    P.aimRayParams = RaycastParams.new()
    P.aimRayParams.FilterType = Enum.RaycastFilterType.Exclude
    P.aimRayParams.IgnoreWater = true

    P.triggerParams = RaycastParams.new()
    P.triggerParams.FilterType = Enum.RaycastFilterType.Exclude
    P.triggerParams.IgnoreWater = true

    P.saveSettings = function()
        if not getgenv then return end
        local t = {}
        for k, v in pairs(P.C) do
            if type(v) == "number" or type(v) == "boolean" or type(v) == "string"
            or (type(v) == "table" and v.R and v.G and v.B) then
                t[k] = v
            end
        end
        t.favoriteRows = P.favoriteRows
        getgenv()[P.saveKey] = t
    end

    P.saveConfigToFile = function()
        if not writefile then return false end
        local function ser(v)
            if type(v) == "number" or type(v) == "boolean" then return tostring(v)
            elseif type(v) == "string" then return string.format("%q", v)
            elseif type(v) == "table" and v.R and v.G and v.B then
                return string.format("{R=%f,G=%f,B=%f}", v.R, v.G, v.B)
            end
            return "nil"
        end
        local parts = {}
        for k, v in pairs(P.C) do
            if type(v) == "number" or type(v) == "boolean" or type(v) == "string"
               or (type(v) == "table" and v.R and v.G and v.B) then
                parts[#parts+1] = string.format("[%q]=%s", k, ser(v))
            end
        end
        return pcall(writefile, P.CONFIG_FILE, "return {" .. table.concat(parts, ",") .. "}")
    end

    P.saveNamedConfig = function(name)
        if not writefile then return false end
        if not isfolder or not makefolder then return false end
        if not isfolder(P.CONFIG_FOLDER) then pcall(makefolder, P.CONFIG_FOLDER) end
        local path = P.CONFIG_FOLDER .. "/" .. name .. ".json"
        local function ser(v)
            if type(v) == "number" or type(v) == "boolean" then return tostring(v)
            elseif type(v) == "string" then return string.format("%q", v)
            elseif type(v) == "table" and v.R and v.G and v.B then
                return string.format("{R=%f,G=%f,B=%f}", v.R, v.G, v.B)
            end
            return "nil"
        end
        local parts = {}
        for k, v in pairs(P.C) do
            if type(v) == "number" or type(v) == "boolean" or type(v) == "string"
               or (type(v) == "table" and v.R and v.G and v.B) then
                parts[#parts+1] = string.format("[%q]=%s", k, ser(v))
            end
        end
        return pcall(writefile, path, "return {" .. table.concat(parts, ",") .. "}")
    end

    P.loadNamedConfig = function(name)
        if not readfile or not isfolder then return false end
        local path = P.CONFIG_FOLDER .. "/" .. name .. ".json"
        if not isfile or not isfile(path) then return false end
        local raw = readfile(path)
        if not raw then return false end
        local fn = loadstring or load
        local chunk = fn(raw)
        if not chunk then return false end
        local ok2, tbl = pcall(chunk)
        if not ok2 or type(tbl) ~= "table" then return false end
        P.applyConfig(tbl)
        return true
    end

    P.listNamedConfigs = function()
        if not listfiles or not isfolder then return {} end
        if not isfolder(P.CONFIG_FOLDER) then return {} end
        local out = {}
        local ok, files = pcall(listfiles, P.CONFIG_FOLDER)
        if not ok or not files then return out end
        for _, f in ipairs(files) do
            local name = f:match("([^/\\]+)%.json$")
            if name then out[#out+1] = name end
        end
        return out
    end

    P.applyConfig = function(tbl)
        for k, v in pairs(tbl) do
            if k == "favoriteRows" and type(v) == "table" then
                P.favoriteRows = v
            elseif type(v) == "table" and v.R and v.G and v.B then P.C[k] = Color3.new(v.R, v.G, v.B)
            elseif P.C[k] ~= nil and type(P.C[k]) == type(v) then P.C[k] = v
            elseif P.C[k] == nil and (type(v) == "number" or type(v) == "boolean" or type(v) == "string") then P.C[k] = v end
        end
        P.saveSettings()
    end

    P.loadConfigFromFile = function()
        if not readfile or not isfile then return false end
        local ok = pcall(isfile, P.CONFIG_FILE)
        if not ok or not isfile(P.CONFIG_FILE) then return false end
        local raw = readfile(P.CONFIG_FILE)
        if not raw then return false end
        local fn = loadstring or load
        local chunk = fn(raw)
        if not chunk then return false end
        local ok2, tbl = pcall(chunk)
        if not ok2 or type(tbl) ~= "table" then return false end
        P.applyConfig(tbl)
        return true
    end

    P.fireRipple = function(button)
        if not button then return end
        local r = Instance.new("Frame")
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.BackgroundColor3 = P.PAL.accent
        r.BackgroundTransparency = 0.6
        r.BorderSizePixel = 0
        r.Size = UDim2.fromOffset(0, 0)
        r.Position = UDim2.new(0.5, 0, 0.5, 0)
        r.ZIndex = (button.ZIndex or 8) + 50
        r.Parent = button
        local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.4
        P.TweenService:Create(r, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(targetSize, targetSize),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.45, function() if r and r.Parent then r:Destroy() end end)
    end

    P.closeOpenDropdown = function()
        if P.openDropdown then P.openDropdown:Destroy(); P.openDropdown = nil end
    end

    P.keyCodeFromName = function(name) return P.KEYBIND_MAP[name] end

    P.toggleFavorite = function(rowId)
        local list = P.favoriteRows
        for i, v in ipairs(list) do
            if v == rowId then table.remove(list, i); return false end
        end
        list[#list+1] = rowId
        return true
    end

    P.isFavorite = function(rowId)
        for _, v in ipairs(P.favoriteRows) do
            if v == rowId then return true end
        end
        return false
    end

    P.INT_KEYS = {
        updateInterval=true, espTextSize=true, espBoxThick=true, espMaxDist=true,
        espMaxPlayers=true, triggerFov=true, trigRingThick=true, flySpeed=true,
        speedValue=true, silentChance=true, spinVelocity=true, triggerChance=true,
        rainbowDelay=true, triggerMagnitude=true, jumpValue=true,
        espSkeletonThickness=true, aimTimeLimit=true, aimOffsetX=true,
        aimOffsetY=true, aimOffsetZ=true, aimErrorX=true, aimErrorY=true,
        radarRadius=true, radarSize=true, crosshairSize=true,
    }

    P.console("[Pegasus] state initialized")
    return true
end

local function runChunk(name, src)
    local fn, err = (loadstring or load)(src, name)
    if not fn then
        local msg = "chunk load failed (" .. name .. "): " .. tostring(err)
        if rconsoleprint then rconsoleprint("[Pegasus] " .. msg .. "\n") end
        if warn then warn("[Pegasus] " .. msg) end
        if print then print("[Pegasus] " .. msg) end
        G._pegasus.errors[#G._pegasus.errors+1] = msg
        return false
    end
    local ok, runtimeErr = pcall(fn)
    if not ok then
        local msg = "chunk runtime failed (" .. name .. "): " .. tostring(runtimeErr)
        if rconsoleprint then rconsoleprint("[Pegasus] " .. msg .. "\n") end
        if warn then warn("[Pegasus] " .. msg) end
        if print then print("[Pegasus] " .. msg) end
        G._pegasus.errors[#G._pegasus.errors+1] = msg
        return false
    end
    return true
end

local function main()
    if bootstrap() == false then
        if rconsoleprint then rconsoleprint("[Pegasus] main aborted: bootstrap failed\n") end
        if print then print("[Pegasus] main aborted: bootstrap failed") end
        return
    end

    -- combat chunk ----------------------------------------------------------
    runChunk("pegasus.combat", [=[
local G = getgenv()
local P = G._pegasus
local Players, UserInputService, RunService, Workspace = P.Players, P.UserInputService, P.RunService, P.Workspace
local LocalPlayer = P.LocalPlayer
local C = P.C
local mk, setProp = P.mk, P.setProp
local console = P.console

local function getCam()
    local ok, cam = pcall(function() return Workspace.CurrentCamera end)
    if not ok or not cam then return nil end
    return cam
end

P.isVisible = function(cam, part, targetChar)
    P.aimRayParams.FilterDescendantsInstances = { LocalPlayer.Character, cam, targetChar }
    P.aimRayParams.IgnoreWater = C.waterCheck
    local origin = cam.CFrame.Position
    local hit = Workspace:Raycast(origin, part.Position - origin, P.aimRayParams)
    return hit == nil
end

P.readHP = function(character, hum)
    local max = (hum and hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
    local function tryCreator(container)
        if not container then return nil end
        local creator = container:FindFirstChild("creator"); if not creator then return nil end
        local dmg = creator:FindFirstChild("Damage")
        if dmg and dmg:IsA("NumberValue") then return math.clamp(max - dmg.Value, 0, max), max, true end
        return nil
    end
    if hum then local v = tryCreator(hum); if v then return v end end
    if character then local v = tryCreator(character); if v then return v end end
    if hum then return hum.Health, max, false end
    return 100, 100, false
end

P.rainbow = function()
    if not C.rainbowVisuals then return nil end
    return Color3.fromHSV(P._rainbowHue or 0, 1, 1)
end

P.isMovingTarget = function(ch)
    if not ch then return false end
    local root = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not root then return false end
    local v = root.AssemblyLinearVelocity or root.Velocity or Vector3.zero
    local moveDir = hum and hum.MoveDirection or Vector3.zero
    return v.Magnitude > 1.5 or moveDir.Magnitude > 0.1
end

P.buildPartsCache = function(ch)
    if not ch then return nil end
    return {
        Head = ch:FindFirstChild("Head"),
        UpperTorso = ch:FindFirstChild("UpperTorso"),
        LowerTorso = ch:FindFirstChild("LowerTorso"),
        LeftUpperArm = ch:FindFirstChild("LeftUpperArm"),
        LeftLowerArm = ch:FindFirstChild("LeftLowerArm"),
        LeftHand = ch:FindFirstChild("LeftHand"),
        RightUpperArm = ch:FindFirstChild("RightUpperArm"),
        RightLowerArm = ch:FindFirstChild("RightLowerArm"),
        RightHand = ch:FindFirstChild("RightHand"),
        LeftUpperLeg = ch:FindFirstChild("LeftUpperLeg"),
        LeftLowerLeg = ch:FindFirstChild("LeftLowerLeg"),
        LeftFoot = ch:FindFirstChild("LeftFoot"),
        RightUpperLeg = ch:FindFirstChild("RightUpperLeg"),
        RightLowerLeg = ch:FindFirstChild("RightLowerLeg"),
    }
end

P.buildDrawingESP = function(p)
    local o = {
        box = mk("Square"), boxShadow = mk("Square"), fill = mk("Square"),
        tracer = mk("Line"), bones = {}, parts = nil, _hp = nil, _hpLastRead = 0,
        character = nil,
    }
    if o.box then
        setProp(o.box, "Filled", false)
        setProp(o.box, "Thickness", C.espBoxThick)
    end
    if o.boxShadow then
        setProp(o.boxShadow, "Filled", false)
        setProp(o.boxShadow, "Thickness", C.espBoxThick + 2)
        setProp(o.boxShadow, "Color", P.PAL.bg)
        setProp(o.boxShadow, "Transparency", 0.4)
    end
    if o.fill then setProp(o.fill, "Filled", true) end
    if o.tracer then setProp(o.tracer, "Thickness", 1) end
    for i = 1, 11 do
        local ln = mk("Line")
        if ln then
            setProp(ln, "Thickness", C.espSkeletonThickness or 1)
            setProp(ln, "Transparency", 0.35)
        end
        o.bones[i] = ln
    end
    P.espObjects[p] = o
    return o
end

P.hideDrawingESP = function(o)
    if not o then return end
    if o.box then setProp(o.box, "Visible", false) end
    if o.boxShadow then setProp(o.boxShadow, "Visible", false) end
    if o.fill then setProp(o.fill, "Visible", false) end
    if o.tracer then setProp(o.tracer, "Visible", false) end
    for _, ln in pairs(o.bones) do setProp(ln, "Visible", false) end
end

P.buildEngineESP = function(p)
    P.espInstances[p] = {
        highlight=nil, billboard=nil, nameLabel=nil, healthLabel=nil, distLabel=nil,
        character=nil,
        _lastName=nil, _lastHealth=nil, _lastDistance=nil, _diedConn=nil,
    }
    return P.espInstances[p]
end

P.attachEngineESP = function(p, character)
    if not character or not character.Parent then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    local entry = P.espInstances[p] or P.buildEngineESP(p)

    if not entry.highlight or not entry.highlight.Parent then
        local hl = Instance.new("Highlight")
        hl.Name = "_pegasusHighlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = C.espOutlineColor
        hl.Enabled = false
        hl.Parent = character
        entry.highlight = hl
    elseif entry.highlight.Parent ~= character then
        entry.highlight.Parent = character
    end

    if not entry.billboard or not entry.billboard.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Name = "_pegasusBillboard"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 220, 0, 62)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false
        bb.Enabled = false
        bb.Parent = character

        local lbl = Instance.new("TextLabel")
        lbl.Name = "_name"; lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = p.DisplayName or p.Name
        lbl.TextSize = 15; lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Color3.fromRGB(240, 245, 250)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        lbl.Visible = C.espName; lbl.Parent = bb

        local hlth = Instance.new("TextLabel")
        hlth.Name = "_health"; hlth.Size = UDim2.new(1, 0, 0, 16)
        hlth.Position = UDim2.new(0, 0, 0, 20)
        hlth.BackgroundTransparency = 1
        hlth.Text = "100"; hlth.TextSize = 13
        hlth.Font = Enum.Font.Gotham
        hlth.TextColor3 = Color3.fromRGB(120, 255, 120)
        hlth.TextStrokeTransparency = 0
        hlth.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        hlth.Visible = C.espHealth; hlth.Parent = bb

        local dst = Instance.new("TextLabel")
        dst.Name = "_distance"; dst.Size = UDim2.new(1, 0, 0, 14)
        dst.Position = UDim2.new(0, 0, 0, 36)
        dst.BackgroundTransparency = 1
        dst.Text = "0m"; dst.TextSize = 12
        dst.Font = Enum.Font.Gotham
        dst.TextColor3 = Color3.fromRGB(220, 230, 240)
        dst.TextStrokeTransparency = 0
        dst.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        dst.Visible = C.espDistance; dst.Parent = bb

        entry.billboard = bb
        entry.nameLabel = lbl
        entry.healthLabel = hlth
        entry.distLabel = dst
    elseif entry.billboard.Adornee ~= head then
        entry.billboard.Adornee = head
    end

    if entry._diedConn then
        pcall(function() entry._diedConn:Disconnect() end)
        entry._diedConn = nil
    end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        entry._diedConn = hum.Died:Connect(function()
            local o = P.espObjects[p]
            if o then P.hideDrawingESP(o) end
            local e = P.espInstances[p]
            if e then
                if e.highlight then e.highlight.Enabled = false end
                if e.billboard then e.billboard.Enabled = false end
            end
        end)
    end
end

P.detachEngineESP = function(p)
    local entry = P.espInstances[p]
    if not entry then return end
    if entry._diedConn then pcall(function() entry._diedConn:Disconnect() end); entry._diedConn = nil end
    if entry.highlight then pcall(function() entry.highlight:Destroy() end); entry.highlight = nil end
    if entry.billboard then pcall(function() entry.billboard:Destroy() end); entry.billboard = nil end
    entry.nameLabel = nil; entry.healthLabel = nil; entry.distLabel = nil
    entry.character = nil
end

P.setEngineESPEnabled = function(on)
    for _, entry in pairs(P.espInstances) do
        if entry.highlight then entry.highlight.Enabled = on and C.espOutline end
        if entry.billboard then entry.billboard.Enabled = on end
    end
end

P.hideDrawingAll = function()
    for _, o in pairs(P.espObjects) do P.hideDrawingESP(o) end
    for _, entry in pairs(P.espInstances) do
        if entry.highlight then entry.highlight.Enabled = false end
        if entry.billboard then entry.billboard.Enabled = false end
    end
end

local BONE_PAIRS = {
    { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "UpperTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "UpperTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" },
}

P.updateESP = function()
    if not C.espEnabled or C.streamerMode then P.hideDrawingAll(); return end
    local cam = getCam(); if not cam then return end
    local camPos = cam.CFrame.Position
    local rainbow = C.rainbowVisuals and P.rainbow() or nil

    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not P.sameTeam(p, LocalPlayer) then
            local ch = p.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local root = ch:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - camPos).Magnitude
                    if dist <= C.espMaxDist then
                        candidates[#candidates+1] = { p=p, ch=ch, hum=hum, root=root, dist=dist }
                    end
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local cap = math.min(#candidates, C.espMaxPlayers)
    local drawnSet = {}
    for i = 1, cap do
        local cand = candidates[i]
        local p = cand.p; drawnSet[p] = true
        local ch, hum, root, dist = cand.ch, cand.hum, cand.root, cand.dist
        local entry = P.espInstances[p] or P.buildEngineESP(p)
        local o = P.espObjects[p] or P.buildDrawingESP(p)

        if entry.character ~= ch or not entry.billboard or not entry.billboard.Parent then
            entry.character = ch
            pcall(P.attachEngineESP, p, ch)
        end

        if o.character ~= ch then
            o.character = ch
            o.parts = P.buildPartsCache(ch)
            o._hp = nil; o._hpLastRead = 0
            entry._lastName = nil; entry._lastHealth = nil; entry._lastDistance = nil
        end

        local now = tick()
        if o._hp == nil or (now - o._hpLastRead) >= 0.25 then
            local v, _, k = P.readHP(ch, hum)
            o._hp = { v=v, k=k }; o._hpLastRead = now
        end
        local hval = o._hp.v
        local hmax = hum.MaxHealth or 100
        local known = o._hp.k

        local topP, topOn = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3.0, 0))
        local botP, botOn = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.0, 0))
        if topOn and botOn then
            local boxH = math.abs(topP.Y - botP.Y)
            local boxW = boxH * 0.74
            local pos = Vector2.new(topP.X - boxW * 0.5, topP.Y)
            local boxSize = Vector2.new(boxW, boxH)
            local pct = hval / math.max(hmax, 1)
            local hcol = Color3.fromRGB(255 * (1 - pct), 255 * pct, 60)
            local tc = P.teamColorFor(p)
            local boxColor = (not C.espTeamColor or tc == nil) and C.espBoxColor or tc
            if rainbow then boxColor = rainbow end

            local occluded = false
            if C.espWallCheck then
                local head = ch:FindFirstChild("Head") or root
                occluded = not P.isVisible(cam, head, ch)
            end

            if o.box then
                if C.espBox and not occluded then
                    setProp(o.box, "Visible", true); setProp(o.box, "Color", boxColor)
                    setProp(o.box, "Thickness", C.espBoxThick)
                    setProp(o.box, "Position", pos); setProp(o.box, "Size", boxSize)
                else setProp(o.box, "Visible", false) end
            end
            if o.boxShadow then
                if C.espBoxShadow and C.espBox and not occluded then
                    setProp(o.boxShadow, "Visible", true)
                    setProp(o.boxShadow, "Position", Vector2.new(pos.X + 1, pos.Y + 1))
                    setProp(o.boxShadow, "Size", boxSize)
                else setProp(o.boxShadow, "Visible", false) end
            end
            if o.fill then
                if C.espFill and not occluded then
                    setProp(o.fill, "Visible", true); setProp(o.fill, "Color", boxColor)
                    setProp(o.fill, "Transparency", 1 - C.espFillAlpha)
                    setProp(o.fill, "Position", pos); setProp(o.fill, "Size", boxSize)
                else setProp(o.fill, "Visible", false) end
            end
            if o.tracer then
                if C.espTracer and not occluded then
                    setProp(o.tracer, "Visible", true); setProp(o.tracer, "Color", boxColor)
                    setProp(o.tracer, "From", Vector2.new(P.cachedViewport.X * 0.5, P.cachedViewport.Y - 30))
                    setProp(o.tracer, "To", Vector2.new(pos.X + boxW * 0.5, pos.Y + boxH * 0.5))
                else setProp(o.tracer, "Visible", false) end
            end

            local skeletonRange = C.espMaxDist * 0.60
            local skeletonColor = boxColor
            if C.espSkeletonColor == "Rainbow" then skeletonColor = rainbow or boxColor end
            if C.espSkeleton and o.parts and dist <= skeletonRange then
                for i, pair in ipairs(BONE_PAIRS) do
                    local a = o.parts[pair[1]]; local b = o.parts[pair[2]]
                    local ln = o.bones[i]
                    if a and a.Parent and b and b.Parent and ln then
                        local pa, oka = cam:WorldToViewportPoint(a.Position)
                        local pb, okb = cam:WorldToViewportPoint(b.Position)
                        if oka and okb then
                            setProp(ln, "Visible", true); setProp(ln, "Color", skeletonColor)
                            setProp(ln, "From", Vector2.new(pa.X, pa.Y))
                            setProp(ln, "To", Vector2.new(pb.X, pb.Y))
                        else setProp(ln, "Visible", false) end
                    elseif ln then setProp(ln, "Visible", false) end
                end
            else
                for _, ln in pairs(o.bones) do setProp(ln, "Visible", false) end
            end

            if entry.highlight then
                entry.highlight.Enabled = C.espOutline and not occluded
                entry.highlight.OutlineColor = rainbow or C.espOutlineColor
            end
            if entry.billboard then
                entry.billboard.Enabled = true
                if entry.nameLabel then
                    local nm = p.DisplayName or p.Name
                    if entry._lastName ~= nm then entry._lastName = nm; entry.nameLabel.Text = nm end
                    entry.nameLabel.Visible = C.espName and not occluded
                    entry.nameLabel.TextColor3 = rainbow or Color3.fromRGB(240, 245, 250)
                end
                if entry.healthLabel then
                    local htxt = known and string.format("%d", math.floor(hval + 0.5)) or "?"
                    if entry._lastHealth ~= htxt then entry._lastHealth = htxt; entry.healthLabel.Text = htxt end
                    entry.healthLabel.Visible = C.espHealth
                    if known then
                        entry.healthLabel.TextColor3 = rainbow or hcol
                    else
                        entry.healthLabel.TextColor3 = rainbow or Color3.fromRGB(200, 200, 200)
                    end
                end
                if entry.distLabel then
                    local dtxt = string.format("%dm", math.floor(dist + 0.5))
                    if entry._lastDistance ~= dtxt then entry._lastDistance = dtxt; entry.distLabel.Text = dtxt end
                    entry.distLabel.Visible = C.espDistance and not occluded
                    entry.distLabel.TextColor3 = rainbow or Color3.fromRGB(220, 230, 240)
                end
            end
        else
            P.hideDrawingESP(o)
            if entry.highlight then entry.highlight.Enabled = false end
            if entry.billboard then entry.billboard.Enabled = false end
        end
    end

    for p, o in pairs(P.espObjects) do
        if not drawnSet[p] then
            P.hideDrawingESP(o)
            local entry = P.espInstances[p]
            if entry then
                if entry.highlight then entry.highlight.Enabled = false end
                if entry.billboard then entry.billboard.Enabled = false end
            end
        end
    end
end

P.validateTarget = function(p, ch)
    if not p or p == LocalPlayer then return false end
    if not ch or not ch.Parent then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local okState, stateVal = pcall(function() return hum:GetState() end)
    if okState and stateVal == Enum.HumanoidStateType.Dead then return false end
    local root = ch:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local y = root.Position.Y
    if y < -50 or y > 5000 then return false end
    local targetPart = ch:FindFirstChild(C.aimPart)
    if not targetPart or not targetPart:IsA("BasePart") then return false end
    local nativeChar = LocalPlayer.Character
    if not nativeChar then return false end
    local nativePart = nativeChar:FindFirstChild(C.aimPart)
    if not nativePart or not nativePart:IsA("BasePart") then return false end
    return true, hum, root, targetPart, nativePart
end

P.passesPolicy = function(p, ch, hum, targetPart, nativePart)
    if C.teamCheck and P.hasTeamsService and p.TeamColor == LocalPlayer.TeamColor and not C.aimTargetAll then return false end
    if C.friendCheck then
        local ok, isFriend = pcall(function() return p:IsFriendsWith(LocalPlayer.UserId) end)
        if ok and isFriend then return false end
    end
    if C.followCheck and p.FollowUserId == LocalPlayer.UserId then return false end
    if C.verifiedCheck and p.HasVerifiedBadge then return false end
    if C.ignoredPlayersCheck and table.find(C.ignoredPlayers, p.Name) then return false end
    if C.targetPlayersCheck and not table.find(C.targetPlayers, p.Name) then return false end
    if C.whitelistedGroupCheck and C.whitelistedGroup > 0 then
        local ok, inG = pcall(function() return p:IsInGroup(C.whitelistedGroup) end)
        if ok and inG then return false end
    end
    if C.blacklistedGroupCheck and C.blacklistedGroup > 0 then
        local ok, inG = pcall(function() return p:IsInGroup(C.blacklistedGroup) end)
        if ok and not inG then return false end
    end
    if C.magnitudeCheck and (targetPart.Position - nativePart.Position).Magnitude > C.triggerMagnitude then return false end
    if C.transparencyCheck then
        local head = ch:FindFirstChild("Head")
        if head and head:IsA("BasePart") and head.Transparency >= C.ignoredTransparency then return false end
    end
    return true
end

P.aimWallCheck = function(ch, nativeChar, targetPart, nativePart)
    if not C.wallCheckAim and not C.aimVisibilityCheck then return true end
    local origin = nativePart.Position
    local dir = targetPart.Position - origin
    if dir.Magnitude < 0.001 then return true end
    local unit = dir.Unit
    local params = P.aimRayParams
    params.FilterDescendantsInstances = { LocalPlayer.Character, nativeChar }
    params.IgnoreWater = C.waterCheck
    local origin2 = origin + unit * 2.0
    local hit = Workspace:Raycast(origin2, unit * (dir.Magnitude - 2.0), params)
    if not hit then return true end
    local inst = hit.Instance
    if not inst then return true end
    if inst:IsDescendantOf(ch) then return true end
    if inst:IsDescendantOf(nativeChar) then return true end
    local head = ch:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        local originHead = origin + unit * 2.0
        local headDir = head.Position - originHead
        if headDir.Magnitude > 0.001 then
            local hHit = Workspace:Raycast(originHead, headDir, params)
            if hHit and hHit.Instance and hHit.Instance:IsDescendantOf(ch) then return true end
        end
    end
    return false
end

P.scanTargets = function(cam)
    local camPos = cam.CFrame.Position
    local camLook = cam.CFrame.LookVector
    local fovRad = math.rad(C.fov * 0.5)
    local nativeChar = LocalPlayer.Character
    if not nativeChar then return nil end
    local nativePart = nativeChar:FindFirstChild(C.aimPart)
    if not nativePart or not nativePart:IsA("BasePart") then return nil end
    local requireMoving = C.smartAimbot == true
    local best = nil; local bestScore = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local ch = p.Character
            if ch then
                local ok, hum, root, targetPart = P.validateTarget(p, ch)
                if ok then
                    local skip = false
                    if requireMoving and not P.isMovingTarget(ch) then skip = true end
                    if not skip and P.passesPolicy(p, ch, hum, targetPart, nativePart) then
                        local worldPos = targetPart.Position
                        local dist3d = (worldPos - camPos).Magnitude
                        if dist3d <= C.espMaxDist then
                            local dir = worldPos - camPos
                            if dir.Magnitude >= 0.001 then
                                local ang = math.acos(math.clamp(camLook:Dot(dir.Unit), -1, 1))
                                if ang <= fovRad then
                                    if P.aimWallCheck(ch, nativeChar, targetPart, nativePart) then
                                        local score
                                        if C.aimRadiusSort == "Angle" then
                                            score = ang * 2.0 + (dist3d / C.espMaxDist) * 0.15
                                        else
                                            score = dist3d + ang * 20
                                        end
                                        if score < bestScore then
                                            bestScore = score
                                            best = { player=p, character=ch, humanoid=hum, root=root,
                                                     targetPart=targetPart, worldPos=worldPos,
                                                     distance=dist3d, angle=ang }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

P.clearAimTarget = function()
    local s = P.aimState
    if s.diedConn then pcall(function() s.diedConn:Disconnect() end); s.diedConn = nil end
    if s.charConn then pcall(function() s.charConn:Disconnect() end); s.charConn = nil end
    s.target = nil; s.targetPart = nil; s.targetChar = nil
    s.lastSeen = 0; s.occludedFor = 0
    s._lastVel = nil
end

P.setAimTarget = function(cand)
    local s = P.aimState
    P.clearAimTarget()
    s.target = cand.player
    s.targetPart = cand.targetPart
    s.targetChar = cand.character
    local cam = getCam()
    if cam then
        local camPos = cam.CFrame.Position
        local camLook = cam.CFrame.LookVector
        local toTarget = cand.worldPos - camPos
        local distToTarget = toTarget.Magnitude
        if distToTarget > 0.001 then
            local angleOff = math.acos(math.clamp(camLook:Dot(toTarget.Unit), -1, 1))
            if angleOff > math.rad(25) then
                s.aimPos = camPos + camLook * distToTarget
            else
                s.aimPos = cand.worldPos
            end
        else
            s.aimPos = cand.worldPos
        end
    else
        s.aimPos = cand.worldPos
    end
    s.rawPos = cand.worldPos
    s.lastSeen = tick()
    s.occludedFor = 0
    P.Target = cand.character
    if cand.humanoid then
        s.diedConn = cand.humanoid.Died:Connect(function()
            if P.aimState.target == cand.player then
                P.clearAimTarget()
                if C.offAfterKill then C.aimToggled = false end
            end
        end)
    end
    if cand.player then
        s.charConn = cand.player.CharacterRemoving:Connect(function()
            if P.aimState.target == cand.player then P.clearAimTarget() end
        end)
    end
end

P.computeAimPos = function(cand)
    local part = cand.targetPart
    if not part then return cand.worldPos end
    local base = part.Position
    local rawV = part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
    local s = P.aimState
    if not s._lastVel then s._lastVel = rawV end
    s._lastVel = s._lastVel:Lerp(rawV, 0.5)
    local v = s._lastVel
    local mult = C.predictorMult + (C.aimVelocityPred or 0)
    if mult < 0 then mult = 0 end
    if mult > 0.01 and v.Magnitude > 0.5 then
        base = base + v * mult
    end
    if C.aimOffsetX and C.aimOffsetX ~= 0 then base = base + Vector3.new(C.aimOffsetX / 10, 0, 0) end
    if C.aimOffsetY and C.aimOffsetY ~= 0 then base = base + Vector3.new(0, C.aimOffsetY / 10, 0) end
    if C.aimOffsetZ and C.aimOffsetZ ~= 0 then base = base + Vector3.new(0, 0, C.aimOffsetZ / 10) end
    return base
end

P.isAimActive = function()
    if not C.aimToggled then return false end
    if C.aimActivation == "Hold" then return C.aimHeldKey == true end
    return true
end

P.isTriggerActive = function()
    if not C.triggerEnabled then return false end
    if C.triggerMode == "Hold" then return C.triggerHeldKey == true end
    return true
end

P.aimStartedAt = nil

P.updateAimbot = function(dt)
    if C.streamerMode then return end
    if not dt or dt <= 0 then dt = 1/60 end
    if dt > 1/30 then dt = 1/30 end
    if not P.isAimActive() then
        if P.aimState.target then P.clearAimTarget() end
        P.aimStartedAt = nil; return
    end
    if P.aimStartedAt == nil then P.aimStartedAt = tick() end
    if C.aimTimeLimit and C.aimTimeLimit > 0 and tick() - P.aimStartedAt > C.aimTimeLimit then
        if P.aimState.target then P.clearAimTarget() end
        return
    end
    local cam = getCam(); if not cam then return end
    local s = P.aimState; local now = tick()

    if C.aimRandomPart then
        P.aimRandomPartAccum = (P.aimRandomPartAccum or 0) + dt
        if P.aimRandomPartAccum >= 1 then
            P.aimRandomPartAccum = 0
            local list = C.aimPartList or { "Head", "HumanoidRootPart", "UpperTorso" }
            if #list > 0 then C.aimPart = list[math.random(1, #list)] end
        end
    end

    local keep = false
    if s.target and C.aimLockedPart then
        local ok, hum, root, targetPart = P.validateTarget(s.target, s.targetChar)
        if ok then
            local nativeChar = LocalPlayer.Character
            local nativePart = nativeChar and nativeChar:FindFirstChild(C.aimPart)
            if nativePart then
                local passes = P.passesPolicy(s.target, s.targetChar, hum, targetPart, nativePart)
                if passes then
                    local camPos = cam.CFrame.Position
                    local camLook = cam.CFrame.LookVector
                    local dist3d = (targetPart.Position - camPos).Magnitude
                    local fovRad = math.rad(C.fov * 0.5)
                    local dir = targetPart.Position - camPos
                    local ang = dir.Magnitude > 0.001
                        and math.acos(math.clamp(camLook:Dot(dir.Unit), -1, 1))
                        or math.huge
                    local wallOk = P.aimWallCheck(s.targetChar, nativeChar, targetPart, nativePart)

                    if C.smartAimbot then
                        local broke = false
                        if dist3d > C.espMaxDist then
                            broke = true
                        elseif ang > fovRad * 1.6 then
                            broke = true
                        elseif not P.isMovingTarget(s.targetChar) then
                            broke = true
                        elseif not wallOk then
                            s.occludedFor = (s.occludedFor or 0) + dt
                            if s.occludedFor >= 0.40 then broke = true end
                        else
                            s.occludedFor = 0
                        end
                        if not broke then
                            keep = true
                            s.targetPart = targetPart
                            s.rawPos = P.computeAimPos({ targetPart = targetPart, worldPos = targetPart.Position })
                            s.lastSeen = now
                        end
                    else
                        if wallOk then
                            keep = true
                            s.targetPart = targetPart
                            s.rawPos = P.computeAimPos({ targetPart = targetPart, worldPos = targetPart.Position })
                            s.lastSeen = now
                        end
                    end
                end
            end
        end
    end

    if not keep then
        if s.target then P.clearAimTarget() end
        P._aimRescanWait = (P._aimRescanWait or 0) + 1
        if P._aimRescanWait >= 1 then
            P._aimRescanWait = 0
            local cand = P.scanTargets(cam)
            if cand then
                P.setAimTarget(cand)
                s.rawPos = P.computeAimPos(cand)
                s.occludedFor = 0
            else
                return
            end
        else
            return
        end
    else
        P._aimRescanWait = 0
    end

    local aimPos = s.rawPos
    if not aimPos then return end

    local acquiring = (s.lastSeen == 0) or (now - s.lastSeen > 0.4)
    local tauBase = acquiring and (C.smoothness * 0.16) or (C.smoothness * 0.30)
    local tau = 0.02 + tauBase
    local alpha = 1 - math.exp(-dt / tau)
    if C.smoothness <= 0.01 then s.aimPos = aimPos
    else s.aimPos = s.aimPos:Lerp(aimPos, alpha) end

    local jitterX = 0; local jitterY = 0
    if C.aimErrorX and C.aimErrorX > 0 then jitterX = (math.random()*2-1)*C.aimErrorX*0.1 end
    if C.aimErrorY and C.aimErrorY > 0 then jitterY = (math.random()*2-1)*C.aimErrorY*0.1 end
    local finalAim = s.aimPos + Vector3.new(jitterX, jitterY, 0)

    if C.aimMode == "Camera" or P.IS_TOUCH then
        local curPos = cam.CFrame.Position
        local lookDir = finalAim - curPos
        if lookDir.Magnitude > 0.01 then
            local tgtLook = lookDir.Unit
            local curLook = cam.CFrame.LookVector
            local dot = math.clamp(curLook:Dot(tgtLook), -1, 1)
            local ang = math.acos(dot)
            local maxStep = math.rad(24)
            if ang > maxStep then
                local axis = curLook:Cross(tgtLook)
                if axis.Magnitude > 0.001 then
                    local axisN = axis.Unit
                    local q = CFrame.fromAxisAngle(axisN, maxStep)
                    cam.CFrame = CFrame.new(curPos) * q * cam.CFrame.Rotation
                else
                    cam.CFrame = CFrame.new(curPos, curPos + tgtLook)
                end
            else
                cam.CFrame = CFrame.new(curPos, finalAim)
            end
        end
    elseif C.aimMode == "Mouse" then
        if not mousemoverel and not mousemoveabs then
            if not P._mouseModeWarned then
                P._mouseModeWarned = true
                P.logError("Mouse aim mode unavailable")
            end
            return
        end
        local sp, on = cam:WorldToViewportPoint(finalAim)
        if on and sp.Z > 0 then
            local center = P.screenCenter()
            local dx = (sp.X - center.X) * alpha
            local dy = (sp.Y - center.Y) * alpha
            if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
                if mousemoverel then pcall(mousemoverel, dx, dy)
                elseif mousemoveabs then
                    local m = UserInputService:GetMouseLocation()
                    pcall(mousemoveabs, m.X + dx, m.Y + dy)
                end
            end
        end
    end
end

P.triggerIsEnemy = function(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    local mode = C.triggerTeamMode
    if mode == "FFA" then return true
    elseif mode == "Everyone" then return targetPlayer ~= LocalPlayer
    elseif mode == "Team-Based" then
        if not P.hasTeamsService then return true end
        local lt, tt = LocalPlayer.Team, targetPlayer.Team
        if lt == nil or tt == nil then return true end
        return tt ~= lt
    end
    return false
end

P.triggerFire = function()
    if P._triggerFiring then return end
    P._triggerFiring = true
    local center = P.screenCenter()
    local cx = math.floor(center.X)
    local cy = math.floor(center.Y)
    if P.VirtualInputManager then
        pcall(function() P.VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0) end)
        task.wait(C.triggerDelay)
        pcall(function() P.VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0) end)
    elseif mouse1press and mouse1release then
        pcall(mouse1press); task.wait(C.triggerDelay); pcall(mouse1release)
    elseif mouse1click then pcall(mouse1click) end
    P._triggerFiring = false
    if C.hitMarkerEnabled and P.hitMarker then P.hitMarker.t = 0.15 end
end

P.triggerStep = function()
    if not P.isTriggerActive() then return end
    if C.streamerMode then return end
    if C.smartTrigger and not P.isAimActive() then return end
    if C.triggerAliveCheck and not P.triggerIsAlive then return end
    if C.triggerCooldown > 0 and tick() < P.triggerNextFire then return end
    if math.random(1, 100) > C.triggerChance then return end
    local cam = getCam(); if not cam then return end

    if C.autoFireLocked then
        local s = P.aimState
        if s.target and s.targetChar then
            local targetHum = s.targetChar:FindFirstChildOfClass("Humanoid")
            local targetRoot = s.targetChar:FindFirstChild("HumanoidRootPart")
            if targetHum and targetRoot and targetHum.Health > 0 then
                if C.triggerWallCheck then
                    if not P.isVisible(cam, s.targetPart or targetRoot, s.targetChar) then return end
                end
                P.triggerNextFire = tick() + C.triggerDelay + C.triggerCooldown
                P.triggerFire()
            end
        end
        return
    end

    local center = P.screenCenter()

    local hit
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Target then hit = mouse.Target
    else
        local ray = cam:ViewportPointToRay(center.X, center.Y)
        P.triggerParams.FilterDescendantsInstances = { LocalPlayer.Character, cam }
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, P.triggerParams)
        hit = result and result.Instance or nil
    end
    if not hit then return end
    local targetParent = hit.Parent; if not targetParent then return end
    local targetHum = targetParent:FindFirstChildOfClass("Humanoid"); if not targetHum then return end
    if targetParent.Name == LocalPlayer.Name then return end
    if targetParent == LocalPlayer.Character then return end

    local targetPlayer = Players:GetPlayerFromCharacter(targetParent)
    if not targetPlayer then targetPlayer = Players:FindFirstChild(targetParent.Name) end
    if not targetPlayer then return end
    if not P.triggerIsEnemy(targetPlayer) then return end

    local thp = P.readHP(targetParent, targetHum); if thp <= 0 then return end

    if C.triggerHeadOnly then
        local n = hit.Name
        if not (n == "Head" or n == "UpperTorso" or n == "Torso") then return end
    end
    if C.triggerWallCheck then
        if not P.isVisible(cam, hit, targetParent) then return end
    end

    P.triggerNextFire = tick() + C.triggerDelay + C.triggerCooldown
    P.triggerFire()
end

P.spinTick = function()
    if not C.spinBot then return end
    local ch = LocalPlayer.Character
    local part = ch and ch:FindFirstChild(C.spinPart)
    if part and part:IsA("BasePart") then
        part.CFrame = part.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(C.spinVelocity), 0)
    end
end

P.setSpin = function(on)
    if on and not P.spinConn then
        P.spinConn = RunService.Heartbeat:Connect(function() pcall(P.spinTick) end)
    elseif not on and P.spinConn then
        P.spinConn:Disconnect(); P.spinConn = nil
    end
end

P.clearFly = function()
    local A = P.adminState
    if A.flyBodyVelocity then pcall(function() A.flyBodyVelocity:Destroy() end); A.flyBodyVelocity = nil end
    if A.flyBodyGyro then pcall(function() A.flyBodyGyro:Destroy() end); A.flyBodyGyro = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
    A.flyActive = false
end

P.startFly = function()
    local char = LocalPlayer.Character; if not char then return end
    local head = char:FindFirstChild("Head"); local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    if P.adminState.flyActive then return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity")
    bv.Name = "_pegasusFlight"; bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.P = 1250; bv.Parent = head
    local bg = Instance.new("BodyGyro")
    bg.Name = "_pegasusGyro"; bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000; bg.CFrame = head.CFrame; bg.Parent = head
    P.adminState.flyBodyVelocity = bv; P.adminState.flyBodyGyro = bg; P.adminState.flyActive = true
end

P.flyTick = function()
    local A = P.adminState
    if not A.flyActive then return end
    local cam = getCam(); local char = LocalPlayer.Character
    if not cam or not char then return end
    local bv = A.flyBodyVelocity; local bg = A.flyBodyGyro
    if not bv or not bg then return end
    local move = Vector3.zero
    if P.UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if P.UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if P.UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if P.UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if P.UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if P.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0.01 then bv.Velocity = move.Unit * C.flySpeed else bv.Velocity = Vector3.zero end
    bg.CFrame = CFrame.new(Vector3.zero, cam.CFrame.LookVector)
end

P.setFly = function(enabled)
    if enabled then
        P.startFly()
        if not P.adminState.flyRenderConn then
            P.adminState.flyRenderConn = RunService.RenderStepped:Connect(function() pcall(P.flyTick) end)
        end
    else
        P.clearFly()
        if P.adminState.flyRenderConn then P.adminState.flyRenderConn:Disconnect(); P.adminState.flyRenderConn = nil end
    end
end

P.speedTick = function()
    if not C.speedEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= C.speedValue then pcall(function() hum.WalkSpeed = C.speedValue end) end
end
P.setSpeed = function(enabled)
    if enabled then
        if not P.adminState.speedLoopConn then
            P.adminState.speedLoopConn = RunService.Heartbeat:Connect(function() pcall(P.speedTick) end)
        end
        P.speedTick()
    else
        if P.adminState.speedLoopConn then P.adminState.speedLoopConn:Disconnect(); P.adminState.speedLoopConn = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = 16 end) end
    end
end

P.jumpTick = function()
    if not C.jumpEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not hum.UseJumpPower then pcall(function() hum.UseJumpPower = true end) end
    if hum.JumpPower ~= C.jumpValue then pcall(function() hum.JumpPower = C.jumpValue end) end
end
P.setJump = function(enabled)
    if enabled then
        P.jumpTick()
        if not P.adminState.jumpLoopConn then
            P.adminState.jumpLoopConn = RunService.Heartbeat:Connect(function() pcall(P.jumpTick) end)
        end
    else
        if P.adminState.jumpLoopConn then P.adminState.jumpLoopConn:Disconnect(); P.adminState.jumpLoopConn = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.UseJumpPower = true end)
            pcall(function() hum.JumpPower = 50 end)
        end
    end
end

P.watchJumpState = function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if C.jumpEnabled and hum.JumpPower ~= C.jumpValue then
            pcall(function() hum.JumpPower = C.jumpValue end)
        end
    end)
    hum:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
        if C.jumpEnabled and not hum.UseJumpPower then
            pcall(function() hum.UseJumpPower = true end)
        end
    end)
end

P.clickTPHandler = function(input)
    if not C.clickTPEnabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
       and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local cam = getCam(); if not cam then return end
    local ray = cam:ViewportPointToRay(input.Position.X, input.Position.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, cam }
    params.IgnoreWater = true
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
    if not result then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    pcall(function() root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end)
end
P.setClickTP = function(enabled)
    if enabled then
        if not P.adminState.clickTPConn then
            P.adminState.clickTPConn = P.UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                pcall(P.clickTPHandler, i)
            end)
        end
    else
        if P.adminState.clickTPConn then P.adminState.clickTPConn:Disconnect(); P.adminState.clickTPConn = nil end
    end
end

P.teleportToPlayer = function(name)
    local target = Players:FindFirstChild(name)
    if not target then return false end
    local ch = target.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    local me = LocalPlayer.Character
    local myRoot = me and me:FindFirstChild("HumanoidRootPart")
    if not root or not myRoot then return false end
    pcall(function() myRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0) end)
    return true
end

P.installSilentAim = function()
    if P._silentInstalled then return end
    local ok, mt = pcall(function() return getrawmetatable(game) end)
    if not ok or not mt then return end
    local oldIdx = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if C.silentAim and C.aimToggled and not C.streamerMode then
            if self == LocalPlayer:GetMouse() and key == "Hit" then
                local s = P.aimState
                if s.targetPart and s.targetPart.Parent then
                    return s.targetPart.CFrame
                end
            end
        end
        return oldIdx(self, key)
    end)
    setreadonly(mt, true)
    P._silentInstalled = true
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if C.flyEnabled then P.setFly(false); P.setFly(true) end
    if C.speedEnabled then P.setSpeed(false); P.setSpeed(true) end
    if C.jumpEnabled then P.setJump(false); P.setJump(true) end
    pcall(P.watchJumpState)
end)

Players.PlayerAdded:Connect(function(p)
    P.buildEngineESP(p)
end)
Players.PlayerRemoving:Connect(function(p) P.detachEngineESP(p); P.espInstances[p] = nil end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        P.buildEngineESP(p)
    end
end

console("[Pegasus] combat core loaded")
    ]=])

    -- gui chunk -------------------------------------------------------------
    runChunk("pegasus.gui", [=[
local G = getgenv()
local P = G._pegasus
local Players, UserInputService, RunService, Workspace, TextService, TweenService = P.Players, P.UserInputService, P.RunService, P.Workspace, P.TextService, P.TweenService
local LocalPlayer, PlayerGui = P.LocalPlayer, P.PlayerGui
local PAL, C = P.PAL, P.C

local parent = PlayerGui
if gethui then local okh, h = pcall(gethui); if okh and h then parent = h end end

local gui = Instance.new("ScreenGui")
gui.Name = "PegasusMenu"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = false
gui.DisplayOrder = 999; gui.Parent = parent
gui.Enabled = false
if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
if protectgui then pcall(protectgui, gui) end
P.gui = gui

local toastGui = Instance.new("ScreenGui")
toastGui.Name = "PegasusToast"; toastGui.ResetOnSpawn = false
toastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; toastGui.IgnoreGuiInset = false
toastGui.DisplayOrder = 1000; toastGui.Parent = parent
toastGui.Enabled = false
if syn and syn.protect_gui then pcall(syn.protect_gui, toastGui) end
if protectgui then pcall(protectgui, toastGui) end
P.toastGui = toastGui

local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "PegasusNotify"; notifyGui.ResetOnSpawn = false
notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; notifyGui.IgnoreGuiInset = true
notifyGui.DisplayOrder = 1500; notifyGui.Parent = parent
notifyGui.Enabled = false
if syn and syn.protect_gui then pcall(syn.protect_gui, notifyGui) end
if protectgui then pcall(protectgui, notifyGui) end
P.notifyGui = notifyGui

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "PegasusOverlay"; overlayGui.ResetOnSpawn = false
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; overlayGui.IgnoreGuiInset = true
overlayGui.DisplayOrder = 1600; overlayGui.Parent = parent
overlayGui.Enabled = true
if syn and syn.protect_gui then pcall(syn.protect_gui, overlayGui) end
if protectgui then pcall(protectgui, overlayGui) end
P.overlayGui = overlayGui

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "PegasusLoading"; loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; loadingGui.IgnoreGuiInset = false
loadingGui.DisplayOrder = 2000; loadingGui.Parent = parent
if syn and syn.protect_gui then pcall(syn.protect_gui, loadingGui) end
if protectgui then pcall(protectgui, loadingGui) end
P.loadingGui = loadingGui

do
    local panel = Instance.new("Frame")
    panel.Name = "_loadingPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Size = UDim2.fromOffset(320, 120)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
    panel.BorderSizePixel = 0
    panel.ZIndex = 2
    panel.Parent = loadingGui
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = PAL.hairline
    panelStroke.Thickness = 1
    panelStroke.Parent = panel

    local iconHolder = Instance.new("Frame")
    iconHolder.Name = "_loadingIcon"
    iconHolder.BackgroundTransparency = 1
    iconHolder.Size = UDim2.fromOffset(64, 64)
    iconHolder.Position = UDim2.fromOffset(20, 28)
    iconHolder.ZIndex = 3
    iconHolder.Parent = panel
    local icon = Instance.new("ImageLabel")
    icon.Name = "_icon"
    icon.BackgroundTransparency = 1
    icon.Image = P.PEGASUS_ICON_ASSET
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.ZIndex = 4
    icon.Parent = iconHolder

    local title = Instance.new("TextLabel")
    title.Name = "_loadingTitle"
    title.Text = P.PEGASUS_NAME
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = PAL.text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -104, 0, 24)
    title.Position = UDim2.fromOffset(96, 32)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = panel

    local sub = Instance.new("TextLabel")
    sub.Name = "_loadingSub"
    sub.Text = "Loading v" .. tostring(P.PEGASUS_VERSION) .. " " .. tostring(P.PEGASUS_SUBVERSION)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextColor3 = PAL.textDim
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -104, 0, 16)
    sub.Position = UDim2.fromOffset(96, 58)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 3
    sub.Parent = panel

    local barBg = Instance.new("Frame")
    barBg.Name = "_loadingBarBg"
    barBg.Size = UDim2.new(1, -40, 0, 4)
    barBg.Position = UDim2.new(0, 20, 1, -20)
    barBg.BackgroundColor3 = PAL.track
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 3
    barBg.Parent = panel

    local barFill = Instance.new("Frame")
    barFill.Name = "_loadingBarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = PAL.accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 4
    barFill.Parent = barBg

    local credit = Instance.new("TextLabel")
    credit.Name = "_loadingCredit"
    credit.Text = ""
    credit.Font = Enum.Font.GothamMedium
    credit.TextSize = 10
    credit.TextColor3 = PAL.accent
    credit.BackgroundTransparency = 1
    credit.Size = UDim2.new(1, -40, 0, 14)
    credit.Position = UDim2.new(0, 20, 1, -36)
    credit.TextXAlignment = Enum.TextXAlignment.Center
    credit.TextTransparency = 1
    credit.ZIndex = 4
    credit.Parent = panel

    local steps = 18
    task.spawn(function()
        for i = 1, steps do
            if not barFill or not barFill.Parent then return end
            TweenService:Create(barFill, TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(i / steps, 0, 1, 0),
            }):Play()
            task.wait(0.42)
        end
        if credit and credit.Parent then
            credit.Text = "Showcasing, Pegasus by 302urban"
            TweenService:Create(credit, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 0,
            }):Play()
        end
        if sub and sub.Parent then
            TweenService:Create(sub, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
        end
        if title and title.Parent then
            TweenService:Create(title, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
        end
        if icon and icon.Parent then
            TweenService:Create(icon, TweenInfo.new(0.35), { ImageTransparency = 1 }):Play()
        end
        task.wait(1.4)
    end)
end

P.notificationList = {}
P.notificationY = 0
P.notify = function(title, body, kind)
    if C.notificationsEnabled == false then return end
    kind = kind or "info"
    local stripeColor = PAL.accent
    if kind == "success" then stripeColor = PAL.success or Color3.fromRGB(80, 220, 150) end
    if kind == "danger" then stripeColor = PAL.danger or Color3.fromRGB(235, 95, 95) end
    if kind == "warn" then stripeColor = PAL.warn or Color3.fromRGB(235, 185, 75) end

    local nW, nH = 260, 52
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(1, 0)
    f.Size = UDim2.fromOffset(nW, nH)
    f.Position = UDim2.new(1, nW + 20, 0, 52 + P.notificationY)
    f.BackgroundColor3 = PAL.panel
    f.BorderSizePixel = 0
    f.ZIndex = 20
    f.Parent = notifyGui
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline
    st.Thickness = 1
    st.Parent = f

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.fromOffset(3, nH)
    stripe.Position = UDim2.fromOffset(0, 0)
    stripe.BackgroundColor3 = stripeColor
    stripe.BorderSizePixel = 0
    stripe.ZIndex = 21
    stripe.Parent = f

    local tl = Instance.new("TextLabel")
    tl.Text = title
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 11
    tl.TextColor3 = PAL.text
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -16, 0, 16)
    tl.Position = UDim2.fromOffset(12, 8)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 21
    tl.Parent = f

    local bl = Instance.new("TextLabel")
    bl.Text = body or ""
    bl.Font = Enum.Font.Gotham
    bl.TextSize = 9
    bl.TextColor3 = PAL.textDim
    bl.BackgroundTransparency = 1
    bl.Size = UDim2.new(1, -16, 0, 22)
    bl.Position = UDim2.fromOffset(12, 26)
    bl.TextXAlignment = Enum.TextXAlignment.Left
    bl.TextYAlignment = Enum.TextYAlignment.Top
    bl.TextWrapped = true
    bl.ZIndex = 21
    bl.Parent = f

    local targetY = 52 + P.notificationY
    P.notificationY = P.notificationY + nH + 8
    table.insert(P.notificationList, f)

    TweenService:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -nW - 20, 0, targetY),
    }):Play()

    task.delay(2.5, function()
        if not f or not f.Parent then return end
        TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
        }):Play()
        for _, c in ipairs(f:GetDescendants()) do
            if c:IsA("Frame") then
                TweenService:Create(c, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            elseif c:IsA("TextLabel") then
                TweenService:Create(c, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            elseif c:IsA("UIStroke") then
                TweenService:Create(c, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            end
        end
        task.wait(0.35)
        if f and f.Parent then f:Destroy() end
        for i, n in ipairs(P.notificationList) do
            if n == f then table.remove(P.notificationList, i); break end
        end
        P.notificationY = math.max(0, P.notificationY - nH - 8)
        local yy = 52
        for _, n in ipairs(P.notificationList) do
            if n and n.Parent then
                TweenService:Create(n, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -nW - 20, 0, yy),
                }):Play()
                yy = yy + nH + 8
            end
        end
    end)
end

local PANEL_W, PANEL_H = P.IS_TOUCH and 500 or 640, P.IS_TOUCH and 640 or 740
P.PANEL_W, P.PANEL_H = PANEL_W, PANEL_H
local TOPBAR_H = 40
local TABBAR_H = 32
local SUBTAB_H = 26
local FOOTER_H = 20
P.TOPBAR_H, P.TABBAR_H, P.SUBTAB_H, P.FOOTER_H = TOPBAR_H, TABBAR_H, SUBTAB_H, FOOTER_H

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
frame.Position = UDim2.fromOffset(C.panelX, C.panelY)
frame.BackgroundColor3 = PAL.bg
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = not P.IS_TOUCH
frame.ClipsDescendants = true
frame.ZIndex = 3
frame.Parent = gui
local frameGradient = Instance.new("UIGradient")
frameGradient.Rotation = 90
frameGradient.Color = ColorSequence.new(PAL.bg, PAL.bg2)
frameGradient.Parent = frame
local frameOutline = Instance.new("UIStroke")
frameOutline.Color = PAL.hairline
frameOutline.Thickness = 1
frameOutline.Transparency = 0
frameOutline.Parent = frame
P.frame = frame

if P.IS_TOUCH then
    frame.Draggable = false
    local dragging, dragStart, startPos = false, nil, nil
    local dragBar = Instance.new("Frame")
    dragBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
    dragBar.BackgroundTransparency = 1
    dragBar.ZIndex = 20
    dragBar.Parent = frame
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

frame:GetPropertyChangedSignal("Position"):Connect(function()
    if not C._fullscreen then C.panelX = frame.Position.X.Offset; C.panelY = frame.Position.Y.Offset end
end)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
topBar.BackgroundColor3 = PAL.bg
topBar.BorderSizePixel = 0
topBar.ZIndex = 6
topBar.Parent = frame

P.PegasusIcon = function(p, position, size, opts)
    opts = opts or {}
    local lbl = Instance.new("ImageLabel")
    lbl.Name = opts.name or "PegasusIcon"
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Image = opts.image or P.PEGASUS_ICON_ASSET
    lbl.ImageColor3 = opts.color or Color3.fromRGB(255, 255, 255)
    lbl.ImageTransparency = opts.transparency or 0
    lbl.ScaleType = Enum.ScaleType.Fit
    lbl.AnchorPoint = opts.anchor or Vector2.new(0, 0.5)
    lbl.Size = UDim2.fromOffset(size, size)
    lbl.Position = position
    lbl.ZIndex = opts.zindex or 7
    lbl.Rotation = opts.rotation or 0
    if opts.visible ~= nil then lbl.Visible = opts.visible end
    lbl.Parent = p
    return lbl
end

P.addGlow = function(inst, color)
    local g = Instance.new("UIStroke")
    g.Name = "_pegasusGlow"
    g.Color = color or PAL.accent
    g.Thickness = 1
    g.Transparency = 0.78
    g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    g.Parent = inst
    return g
end

P.overlayPanel = nil
P.buildOverlayPanel = function()
    if P.overlayPanel then return P.overlayPanel end
    local p = Instance.new("Frame")
    p.Name = "_overlayPanel"
    p.Size = UDim2.fromOffset(200, 78)
    p.Position = UDim2.fromOffset(12, 12)
    p.BackgroundColor3 = PAL.panelDeep
    p.BackgroundTransparency = 0.15
    p.BorderSizePixel = 0
    p.ZIndex = 15
    p.Parent = P.overlayGui
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline
    st.Thickness = 1
    st.Parent = p
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, 4)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = p

    local title = Instance.new("TextLabel")
    title.Name = "_ovUser"
    title.Text = "user"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = PAL.text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 16)
    title.Position = UDim2.fromOffset(0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 16
    title.Parent = p

    local fps = Instance.new("TextLabel")
    fps.Name = "_ovFps"
    fps.Text = "0 FPS"
    fps.Font = Enum.Font.Gotham
    fps.TextSize = 10
    fps.TextColor3 = PAL.textDim
    fps.BackgroundTransparency = 1
    fps.Size = UDim2.new(1, 0, 0, 14)
    fps.Position = UDim2.fromOffset(0, 18)
    fps.TextXAlignment = Enum.TextXAlignment.Left
    fps.ZIndex = 16
    fps.Parent = p

    local stat = Instance.new("TextLabel")
    stat.Name = "_ovStatus"
    stat.Text = ""
    stat.Font = Enum.Font.Gotham
    stat.TextSize = 10
    stat.TextColor3 = PAL.textDim
    stat.BackgroundTransparency = 1
    stat.Size = UDim2.new(1, 0, 0, 14)
    stat.Position = UDim2.fromOffset(0, 34)
    stat.TextXAlignment = Enum.TextXAlignment.Left
    stat.TextWrapped = true
    stat.ZIndex = 16
    stat.Parent = p

    local conn = Instance.new("TextLabel")
    conn.Name = "_ovConn"
    conn.Text = ""
    conn.Font = Enum.Font.Gotham
    conn.TextSize = 10
    conn.TextColor3 = PAL.accent
    conn.BackgroundTransparency = 1
    conn.Size = UDim2.new(1, 0, 0, 14)
    conn.Position = UDim2.fromOffset(0, 52)
    conn.TextXAlignment = Enum.TextXAlignment.Left
    conn.ZIndex = 16
    conn.Parent = p

    P.overlayPanel = {
        frame = p,
        user = title,
        fps = fps,
        status = stat,
        conn = conn,
    }
    return P.overlayPanel
end

P.mkWinBtn = function(kind, xOff, fn)
    local b = Instance.new("TextButton")
    b.Text = ""
    b.AutoButtonColor = false
    b.BackgroundColor3 = PAL.panel
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Size = UDim2.fromOffset(24, 24)
    b.Position = UDim2.new(1, xOff, 0, math.floor((TOPBAR_H - 24) / 2))
    b.ZIndex = 9
    b.Parent = topBar
    local hover = Instance.new("Frame")
    hover.Size = UDim2.new(1, 0, 1, 0)
    hover.BackgroundColor3 = PAL.surfaceHover
    hover.BackgroundTransparency = 1
    hover.BorderSizePixel = 0
    hover.ZIndex = 8
    hover.Parent = b

    local iconLayer = Instance.new("Frame")
    iconLayer.Size = UDim2.new(1, 0, 1, 0)
    iconLayer.BackgroundTransparency = 1
    iconLayer.ZIndex = 9
    iconLayer.Parent = b

    local parts = {}
    if kind == "min" then
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(10, 1)
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
        bar.BackgroundColor3 = PAL.textDim
        bar.BorderSizePixel = 0
        bar.ZIndex = 10
        bar.Parent = iconLayer
        parts[#parts+1] = bar
    elseif kind == "max" then
        local sq = Instance.new("Frame")
        sq.Size = UDim2.fromOffset(10, 10)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        sq.Position = UDim2.new(0.5, 0, 0.5, 0)
        sq.BackgroundTransparency = 1
        sq.BorderSizePixel = 0
        sq.ZIndex = 10
        sq.Parent = iconLayer
        local ss = Instance.new("UIStroke")
        ss.Color = PAL.textDim; ss.Thickness = 1; ss.Parent = sq
        parts[#parts+1] = ss
    elseif kind == "close" then
        local armLen = 10
        local b1 = Instance.new("Frame")
        b1.Size = UDim2.fromOffset(armLen, 1)
        b1.AnchorPoint = Vector2.new(0.5, 0.5)
        b1.Position = UDim2.new(0.5, 0, 0.5, 0)
        b1.Rotation = 45
        b1.BackgroundColor3 = PAL.textDim
        b1.BorderSizePixel = 0
        b1.ZIndex = 10
        b1.Parent = iconLayer
        local b2 = Instance.new("Frame")
        b2.Size = UDim2.fromOffset(armLen, 1)
        b2.AnchorPoint = Vector2.new(0.5, 0.5)
        b2.Position = UDim2.new(0.5, 0, 0.5, 0)
        b2.Rotation = -45
        b2.BackgroundColor3 = PAL.textDim
        b2.BorderSizePixel = 0
        b2.ZIndex = 10
        b2.Parent = iconLayer
        parts[#parts+1] = b1
        parts[#parts+1] = b2
    end

    b.MouseEnter:Connect(function()
        hover.BackgroundTransparency = 0.5
        for _, p in ipairs(parts) do
            if p:IsA("Frame") then p.BackgroundColor3 = PAL.text
            elseif p:IsA("UIStroke") then p.Color = PAL.text end
        end
    end)
    b.MouseLeave:Connect(function()
        hover.BackgroundTransparency = 1
        for _, p in ipairs(parts) do
            if p:IsA("Frame") then p.BackgroundColor3 = PAL.textDim
            elseif p:IsA("UIStroke") then p.Color = PAL.textDim end
        end
    end)
    b.MouseButton1Click:Connect(fn)
    return b
end

P.mkWinBtn("close", -32, function() P.closeMenu() end)
P.mkWinBtn("max",   -60, function() P.toggleFullscreen() end)
P.mkWinBtn("min",   -88, function() P.minimizeMenu() end)

local brandIcon = P.PegasusIcon(topBar, UDim2.fromOffset(14, math.floor(TOPBAR_H/2)), 22, { zindex = 7 })

local brand = Instance.new("TextLabel")
brand.Text = P.PEGASUS_NAME
brand.Font = Enum.Font.GothamBold
brand.TextSize = 13
brand.TextColor3 = PAL.text
brand.BackgroundTransparency = 1
brand.Size = UDim2.fromOffset(90, TOPBAR_H)
brand.Position = UDim2.fromOffset(44, 0)
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.ZIndex = 7
brand.Parent = topBar

local versionTag = Instance.new("TextLabel")
versionTag.Text = "v" .. P.PEGASUS_VERSION .. " " .. P.PEGASUS_SUBVERSION
versionTag.Font = Enum.Font.Gotham
versionTag.TextSize = 10
versionTag.TextColor3 = PAL.textDim
versionTag.BackgroundTransparency = 1
versionTag.Size = UDim2.fromOffset(140, TOPBAR_H)
versionTag.Position = UDim2.fromOffset(126, 0)
versionTag.TextXAlignment = Enum.TextXAlignment.Left
versionTag.ZIndex = 7
versionTag.Parent = topBar

local topHair = Instance.new("Frame")
topHair.Size = UDim2.new(1, 0, 0, 1)
topHair.Position = UDim2.new(0, 0, 0, TOPBAR_H)
topHair.BackgroundColor3 = PAL.hairline
topHair.BorderSizePixel = 0
topHair.ZIndex = 6
topHair.Parent = frame

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, 0, 0, TABBAR_H)
tabBar.Position = UDim2.fromOffset(0, TOPBAR_H + 1)
tabBar.BackgroundColor3 = PAL.bg
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 6
tabBar.Parent = frame
tabBar.ScrollBarThickness = 0
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.CanvasSize = UDim2.new(0, 0, 0, TABBAR_H)
tabBar.ClipsDescendants = true
P.tabBar = tabBar

local tabHair = Instance.new("Frame")
tabHair.Size = UDim2.new(1, 0, 0, 1)
tabHair.Position = UDim2.new(0, 0, 1, -1)
tabHair.BackgroundColor3 = PAL.hairline
tabHair.BorderSizePixel = 0
tabHair.ZIndex = 6
tabHair.Parent = tabBar

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, 0, 1, -(TOPBAR_H + TABBAR_H + 2 + FOOTER_H))
contentHolder.Position = UDim2.fromOffset(0, TOPBAR_H + TABBAR_H + 2)
contentHolder.BackgroundColor3 = PAL.bg
contentHolder.BorderSizePixel = 0
contentHolder.ClipsDescendants = true
contentHolder.ZIndex = 5
contentHolder.Parent = frame

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, 0)
contentArea.Position = UDim2.fromOffset(0, 0)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.ZIndex = 6
contentArea.Parent = contentHolder
P.contentArea = contentArea

local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
footer.BackgroundColor3 = PAL.bg
footer.BorderSizePixel = 0
footer.ZIndex = 6
footer.Parent = frame

local footerHair = Instance.new("Frame")
footerHair.Size = UDim2.new(1, 0, 0, 1)
footerHair.Position = UDim2.new(0, 0, 0, 0)
footerHair.BackgroundColor3 = PAL.hairline
footerHair.BorderSizePixel = 0
footerHair.ZIndex = 6
footerHair.Parent = footer

local buildLabel = Instance.new("TextLabel")
buildLabel.Text = P.PEGASUS_NAME .. " v" .. P.PEGASUS_VERSION .. " " .. P.PEGASUS_SUBVERSION
buildLabel.Font = Enum.Font.Gotham
buildLabel.TextSize = 9
buildLabel.TextColor3 = PAL.textDim
buildLabel.BackgroundTransparency = 1
buildLabel.Size = UDim2.new(1, -20, 1, 0)
buildLabel.Position = UDim2.fromOffset(0, 0)
buildLabel.TextXAlignment = Enum.TextXAlignment.Right
buildLabel.ZIndex = 7
buildLabel.Parent = footer

P.sideItems = { "Home", "Visual", "Aim", "Misc", "Admin", "Teleport", "Configs", "Settings" }
P.TAB_FONT = Enum.Font.GothamMedium
P.TAB_FONT_ACTIVE = Enum.Font.GothamBold
P.TAB_TEXT = 11
P.TAB_GAP = 4
P.TAB_PAD_X = 6
P.SUBTAB_FONT = Enum.Font.GothamMedium
P.SUBTAB_FONT_ACTIVE = Enum.Font.GothamBold
P.SUBTAB_TEXT = 10
P.SUBTAB_GAP = 3
P.SUBTAB_PAD_X = 8

P.measureTabWidth = function(text, font)
    local ok, size = pcall(function()
        return TextService:GetTextSize(text, P.TAB_TEXT, font, Vector2.new(1000, 20))
    end)
    if ok and size then return math.ceil(size.X) + P.TAB_PAD_X * 2 end
    return (#text * 6) + P.TAB_PAD_X * 2
end

P.measureSubTabWidth = function(text, font)
    local ok, size = pcall(function()
        return TextService:GetTextSize(text, P.SUBTAB_TEXT, font, Vector2.new(1000, 20))
    end)
    if ok and size then return math.ceil(size.X) + P.SUBTAB_PAD_X * 2 end
    return (#text * 6) + P.SUBTAB_PAD_X * 2
end

P.layoutTabs = function()
    local x = 12
    for _, nm in ipairs(P.sideItems) do
        local tb = P.tabButtons[nm]
        if tb then
            tb.button.Position = UDim2.fromOffset(x, 0)
            x = x + tb.width + P.TAB_GAP
        end
    end
    P.tabBar.CanvasSize = UDim2.new(0, x + 8, 0, P.TABBAR_H)
end

P.refreshTabs = function()
    for n, t in pairs(P.Tabs) do
        if t.holder then t.holder.Visible = (n == P.ActiveTab) end
    end
    for n, tb in pairs(P.tabButtons) do
        local isA = (n == P.ActiveTab)
        tb.label.TextColor3 = isA and PAL.text or PAL.textDim
        tb.label.Font = isA and P.TAB_FONT_ACTIVE or P.TAB_FONT
        local newW = P.measureTabWidth(n, tb.label.Font)
        tb.width = newW
        tb.button.Size = UDim2.fromOffset(newW, P.TABBAR_H)
        if P.tabIndicators[n] then
            P.tabIndicators[n].Visible = isA
            if isA then
                P.tabIndicators[n].BackgroundColor3 = (P.rainbow and P.rainbow()) or PAL.accent
            end
        end
        local tbGlow = tb.button:FindFirstChild("_pegasusGlow")
        if tbGlow then tbGlow.Transparency = isA and 0.6 or 1 end
    end
    P.layoutTabs()
    for parentName, group in pairs(P.subTabButtons) do
        for _, entry in ipairs(group) do
            local isActive = (P.subTabs[parentName] and P.subTabs[parentName].active == entry.name)
            entry.label.TextColor3 = isActive and PAL.text or PAL.textDim
            entry.label.Font = isActive and P.SUBTAB_FONT_ACTIVE or P.SUBTAB_FONT
            if entry.indicator then
                entry.indicator.Visible = isActive
                if isActive then
                    entry.indicator.BackgroundColor3 = (P.rainbow and P.rainbow()) or PAL.accent
                    if entry.glow then entry.glow.Color = (P.rainbow and P.rainbow()) or PAL.accent end
                end
            end
            local sbGlow = entry.button:FindFirstChild("_pegasusGlow")
            if sbGlow then sbGlow.Transparency = isActive and 0.6 or 1 end
            if entry.bg then
                entry.bg.BackgroundTransparency = isActive and 0 or 1
            end
        end
    end
    if C.rainbowVisuals and P.rainbow then
        for _, bar in ipairs(P.sectionBarList) do bar.BackgroundColor3 = P.rainbow() end
    end
    for _, fn in ipairs(P.refreshFns) do pcall(fn) end
end

for i, name in ipairs(P.sideItems) do
    local w = P.measureTabWidth(name, name == P.ActiveTab and P.TAB_FONT_ACTIVE or P.TAB_FONT)
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(w, TABBAR_H)
    btn.Position = UDim2.fromOffset(0, 0)
    btn.ZIndex = 8
    btn.Parent = tabBar
    local lbl = Instance.new("TextLabel")
    lbl.Text = name
    lbl.Font = (name == P.ActiveTab) and P.TAB_FONT_ACTIVE or P.TAB_FONT
    lbl.TextSize = P.TAB_TEXT
    lbl.TextColor3 = (name == P.ActiveTab) and PAL.text or PAL.textDim
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Position = UDim2.fromOffset(0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 9
    lbl.Parent = btn
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 0, 0, 3)
    ind.Position = UDim2.new(0, 0, 1, -3)
    ind.BackgroundColor3 = PAL.accent
    ind.BorderSizePixel = 0
    ind.Visible = (name == P.ActiveTab)
    ind.ZIndex = 9
    ind.Parent = btn
    local tabGlow = P.addGlow(btn, PAL.accent)
    tabGlow.Transparency = (name == P.ActiveTab) and 0.6 or 1

    P.tabButtons[name] = { label = lbl, button = btn, width = w }
    P.tabIndicators[name] = ind
    btn.MouseEnter:Connect(function()
        if P.ActiveTab ~= name then lbl.TextColor3 = PAL.text end
    end)
    btn.MouseLeave:Connect(function()
        if P.ActiveTab ~= name then lbl.TextColor3 = PAL.textDim end
    end)
    btn.MouseButton1Click:Connect(function()
        P.ActiveTab = name
        P.refreshTabs()
        P.fireRipple(btn)
    end)
end

tabBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local cx = tabBar.CanvasPosition.X
        local maxX = math.max(0, tabBar.AbsoluteCanvasSize.X - tabBar.AbsoluteSize.X)
        tabBar.CanvasPosition = Vector2.new(math.clamp(cx - input.Position.Z * 40, 0, maxX), 0)
    end
end)

P.registerSubTab = function(parentName, subName, canvasH)
    if not P.Tabs[parentName] or not P.Tabs[parentName].holder then
        P.makeTabHolder(parentName, 1200)
    end
    local parentHolder = P.Tabs[parentName] and P.Tabs[parentName].holder
    if not parentHolder then
        P.logError("registerSubTab: could not create holder for tab " .. tostring(parentName))
        return nil
    end
    P.subTabs[parentName] = P.subTabs[parentName] or { active = nil, holders = {}, built = false }
    local st = P.subTabs[parentName]

    local holder = Instance.new("ScrollingFrame")
    holder.Name = "Sub_" .. parentName .. "_" .. subName
    holder.Size = UDim2.new(1, 0, 1, -(SUBTAB_H + 12))
    holder.Position = UDim2.fromOffset(0, SUBTAB_H + 12)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ScrollBarThickness = 4
    holder.ScrollBarImageColor3 = PAL.divider
    holder.ScrollBarImageTransparency = 0.3
    holder.CanvasSize = UDim2.new(0, 0, 0, canvasH or 600)
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.ClipsDescendants = true
    holder.Visible = false
    holder.ZIndex = 8
    holder.Parent = parentHolder
    st.holders[subName] = holder

    if not st.built then
        st.built = true
        local row = Instance.new("ScrollingFrame")
        row.Size = UDim2.new(1, -20, 0, SUBTAB_H)
        row.Position = UDim2.fromOffset(10, 4)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.ScrollBarThickness = 0
        row.ScrollingDirection = Enum.ScrollingDirection.X
        row.CanvasSize = UDim2.new(0, 0, 0, SUBTAB_H)
        row.ClipsDescendants = true
        row.ZIndex = 9
        row.Parent = parentHolder
        st.row = row
        P.subTabButtons[parentName] = P.subTabButtons[parentName] or {}
    end

    local entries = P.subTabButtons[parentName]
    local w = P.measureSubTabWidth(subName, P.SUBTAB_FONT)
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(w, SUBTAB_H)
    btn.Position = UDim2.fromOffset(0, 0)
    btn.ZIndex = 10
    btn.Parent = st.row
    local subBg = Instance.new("Frame")
    subBg.Name = "_subBg"
    subBg.Size = UDim2.new(1, 0, 1, 0)
    subBg.BackgroundColor3 = PAL.panelDeep
    subBg.BackgroundTransparency = 1
    subBg.BorderSizePixel = 0
    subBg.ZIndex = 10
    subBg.Parent = btn
    Instance.new("UICorner", subBg).CornerRadius = UDim.new(0, 3)
    local lbl = Instance.new("TextLabel")
    lbl.Text = subName
    lbl.Font = P.SUBTAB_FONT
    lbl.TextSize = P.SUBTAB_TEXT
    lbl.TextColor3 = PAL.textDim
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 11
    lbl.Parent = btn
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 0, 0, 3)
    ind.Position = UDim2.new(0, 0, 1, -3)
    ind.BackgroundColor3 = PAL.accent
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.ZIndex = 11
    ind.Parent = btn
    local glow = Instance.new("UIStroke")
    glow.Color = PAL.accent
    glow.Thickness = 3
    glow.Transparency = 0.85
    glow.Parent = ind
    local subGlow = P.addGlow(btn, PAL.accent)
    subGlow.Transparency = 1

    local entry = { name = subName, button = btn, label = lbl, indicator = ind, width = w, glow = glow, bg = subBg }
    entries[#entries+1] = entry

    local x = 0
    for _, e in ipairs(entries) do
        e.button.Position = UDim2.fromOffset(x, 0)
        x = x + e.width + P.SUBTAB_GAP
    end
    st.row.CanvasSize = UDim2.new(0, x + 8, 0, SUBTAB_H)

    btn.MouseEnter:Connect(function()
        if st.active ~= subName then lbl.TextColor3 = PAL.text end
    end)
    btn.MouseLeave:Connect(function()
        if st.active ~= subName then lbl.TextColor3 = PAL.textDim end
    end)
    btn.MouseButton1Click:Connect(function()
        st.active = subName
        for n, h in pairs(st.holders) do h.Visible = (n == subName) end
        for _, e in ipairs(entries) do
            if e.bg then
                e.bg.BackgroundTransparency = (e.name == subName) and 0 or 1
            end
        end
        P.refreshTabs()
        P.fireRipple(btn)
    end)

    if not st.active then
        st.active = subName
        for n, h in pairs(st.holders) do h.Visible = (n == subName) end
        for _, e in ipairs(entries) do
            if e.bg then
                e.bg.BackgroundTransparency = (e.name == subName) and 0 or 1
            end
        end
    end

    return holder
end

P.makeSectionHeader = function(parentFrame, y, text)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, -40, 0, 28)
    wrap.Position = UDim2.fromOffset(20, y)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 7
    wrap.Parent = parentFrame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(2, 14)
    bar.Position = UDim2.new(0, 0, 0.5, -7)
    bar.BackgroundColor3 = PAL.accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 8
    bar.Parent = wrap
    local t = Instance.new("TextLabel")
    t.Text = string.upper(text)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 11
    t.TextColor3 = PAL.textDim
    t.BackgroundTransparency = 1
    t.Size = UDim2.new(1, -8, 1, 0)
    t.Position = UDim2.fromOffset(10, 0)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.ZIndex = 8
    t.Parent = wrap
    P.themedSectionHeaders[#P.themedSectionHeaders+1] = t
    P.sectionBarList[#P.sectionBarList+1] = bar
    return wrap
end

P.makeRow = function(parentFrame, y)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, -32, 0, 40)
    r.Position = UDim2.fromOffset(16, y)
    r.BackgroundColor3 = PAL.bg
    r.BorderSizePixel = 0
    r.ZIndex = 7
    r.Parent = parentFrame
    local hover = Instance.new("Frame")
    hover.Name = "_hover"
    hover.Size = UDim2.new(1, 0, 1, 0)
    hover.BackgroundColor3 = PAL.surfaceHover
    hover.BackgroundTransparency = 1
    hover.BorderSizePixel = 0
    hover.ZIndex = 7
    hover.Parent = r
    local hoverStroke = Instance.new("UIStroke")
    hoverStroke.Color = PAL.hairline
    hoverStroke.Thickness = 1
    hoverStroke.Transparency = 1
    hoverStroke.Parent = hover
    local hair = Instance.new("Frame")
    hair.Size = UDim2.new(1, 0, 0, 1)
    hair.Position = UDim2.new(0, 0, 1, -1)
    hair.BackgroundColor3 = PAL.hairline
    hair.BorderSizePixel = 0
    hair.ZIndex = 8
    hair.Parent = r
    P.themedRows[#P.themedRows+1] = { frame = r, hair = hair, hover = hover }
    r.MouseEnter:Connect(function()
        TweenService:Create(hover, TweenInfo.new(0.12), { BackgroundTransparency = 0.55, BackgroundColor3 = PAL.surfaceHover }):Play()
        hoverStroke.Transparency = 0.6
    end)
    r.MouseLeave:Connect(function()
        TweenService:Create(hover, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
        hoverStroke.Transparency = 1
    end)
    return r
end

P.makeStackedRow = function(parentFrame, y)
    local r = P.makeRow(parentFrame, y)
    r.Size = UDim2.new(1, -32, 0, 52)
    return r
end

P.makeTitleLabel = function(r, text)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextColor3 = PAL.text
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -150, 0, 16)
    l.Position = UDim2.fromOffset(26, 6)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 8
    l.Parent = r
    P.themedLabels[#P.themedLabels+1] = l
    return l
end

P.makeTitleLabelCompact = function(r, text)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextColor3 = PAL.text
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -150, 0, 16)
    l.Position = UDim2.fromOffset(2, 6)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 8
    l.Parent = r
    P.themedLabels[#P.themedLabels+1] = l
    return l
end

P.makeSubLabel = function(r, text)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextColor3 = PAL.textDim
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -150, 0, 14)
    l.Position = UDim2.fromOffset(26, 24)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 8
    l.Parent = r
    P.themedSubLabels[#P.themedSubLabels+1] = l
    return l
end

P.makeCaution = function(r, tipText)
    local icon = Instance.new("TextButton")
    icon.Text = "?"
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 10
    icon.TextColor3 = PAL.warn or Color3.fromRGB(235, 185, 75)
    icon.BackgroundColor3 = PAL.surface
    icon.BackgroundTransparency = 0
    icon.BorderSizePixel = 0
    icon.AutoButtonColor = false
    icon.Size = UDim2.fromOffset(16, 16)
    icon.Position = UDim2.new(0, 4, 0.5, -8)
    icon.ZIndex = 9
    icon.Parent = r
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    local st = Instance.new("UIStroke")
    st.Color = PAL.warn or Color3.fromRGB(235, 185, 75)
    st.Thickness = 1
    st.Transparency = 0.4
    st.Parent = icon

    local tip = Instance.new("TextLabel")
    tip.Text = tipText or ""
    tip.Font = Enum.Font.Gotham
    tip.TextSize = 10
    tip.TextColor3 = PAL.text
    tip.BackgroundColor3 = PAL.panelDeep
    tip.BorderSizePixel = 0
    tip.Size = UDim2.fromOffset(220, 30)
    tip.Position = UDim2.new(0, 4, 0, -36)
    tip.TextWrapped = true
    tip.Visible = false
    tip.ZIndex = 60
    tip.Parent = r
    local tipStroke = Instance.new("UIStroke")
    tipStroke.Color = PAL.hairline
    tipStroke.Thickness = 1
    tipStroke.Parent = tip

    icon.MouseEnter:Connect(function() tip.Visible = true end)
    icon.MouseLeave:Connect(function() tip.Visible = false end)
    return icon
end

P.makeLabel = function(r, text)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextColor3 = PAL.text
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -160, 1, 0)
    l.Position = UDim2.fromOffset(2, 0)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 8
    l.Parent = r
    P.themedLabels[#P.themedLabels+1] = l
    return l
end

P.makeValueLabel = function(r, text, color)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextColor3 = color or PAL.text
    l.BackgroundTransparency = 1
    l.Size = UDim2.fromOffset(120, 22)
    l.Position = UDim2.new(1, -124, 0.5, -11)
    l.TextXAlignment = Enum.TextXAlignment.Right
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 8
    l.Parent = r
    P.themedLabels[#P.themedLabels+1] = l
    return l
end

P.makeToggle = function(r, get, set)
    local tW, tH, kSz = 40, 20, 16
    local track = Instance.new("TextButton")
    track.Text = ""
    track.BackgroundColor3 = get() and PAL.accent or PAL.track
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.Size = UDim2.fromOffset(tW, tH)
    track.Position = UDim2.new(1, -tW - 2, 0.5, -tH/2)
    track.ZIndex = 9
    track.Parent = r
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(kSz, kSz)
    knob.Position = UDim2.fromOffset(get() and (tW - kSz - 2) or 2, 2)
    knob.BackgroundColor3 = get() and Color3.fromRGB(255, 255, 255) or PAL.knobOff
    knob.BorderSizePixel = 0
    knob.ZIndex = 10
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local toggleGlow = P.addGlow(track, PAL.accent)
    local function refresh()
        local on = get()
        track.BackgroundColor3 = on and PAL.accent or PAL.track
        knob.Position = UDim2.fromOffset(on and (tW - kSz - 2) or 2, 2)
        knob.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or PAL.knobOff
        toggleGlow.Transparency = on and 0.55 or 0.82
        toggleGlow.Color = on and PAL.accent or PAL.outline
    end
    refresh()
    track.MouseEnter:Connect(function()
        track.BackgroundColor3 = get() and PAL.accentHover or PAL.surfaceHover
        toggleGlow.Transparency = get() and 0.42 or 0.68
    end)
    track.MouseLeave:Connect(function()
        track.BackgroundColor3 = get() and PAL.accent or PAL.track
        toggleGlow.Transparency = get() and 0.55 or 0.82
    end)
    track.MouseButton1Click:Connect(function()
        set(not get()); refresh(); P.saveSettings()
        P.fireRipple(track)
    end)
    P.refreshFns[#P.refreshFns+1] = refresh
    P.themedToggles[#P.themedToggles+1] = { track = track, refresh = refresh, get = get }
end

P.makeSlider = function(r, key)
    local b = P.C.bounds[key]
    if not b then P.logError("missing bounds for slider key: " .. tostring(key)); return end
    local lo, hi = b[1], b[2]
    local tW = 140
    local tH = 4
    local knobSz = 12
    local track = Instance.new("Frame")
    track.BackgroundColor3 = PAL.track
    track.BorderSizePixel = 0
    track.Size = UDim2.fromOffset(tW, tH)
    track.Position = UDim2.new(1, -tW - 74, 0.5, -tH/2)
    track.ZIndex = 8
    track.Parent = r
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = PAL.accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(math.clamp((P.C[key] - lo) / (hi - lo), 0, 1), 0, 1, 0)
    fill.ZIndex = 9
    fill.Parent = track
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(knobSz, knobSz)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 244)
    knob.BorderSizePixel = 0
    knob.ZIndex = 10
    knob.Parent = track
    local readout = Instance.new("TextLabel")
    readout.Text = tostring(P.C[key])
    readout.Font = Enum.Font.Gotham
    readout.TextSize = 11
    readout.TextColor3 = PAL.text
    readout.BackgroundTransparency = 1
    readout.Size = UDim2.fromOffset(64, 22)
    readout.Position = UDim2.new(1, -68, 0.5, -11)
    readout.TextXAlignment = Enum.TextXAlignment.Right
    readout.TextYAlignment = Enum.TextYAlignment.Center
    readout.ZIndex = 8
    readout.Parent = r
    local function knobX(fr) return 6 + fr * (tW - 12) end
    local fr0 = math.clamp((P.C[key] - lo) / (hi - lo), 0, 1)
    knob.Position = UDim2.fromOffset(knobX(fr0), tH/2)
    local drg = false
    local function setX(x)
        local fr = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = lo + fr * (hi - lo)
        if P.INT_KEYS[key] then v = math.floor(v + 0.5) end
        P.C[key] = v
        fill.Size = UDim2.new(fr, 0, 1, 0)
        knob.Position = UDim2.fromOffset(knobX(fr), tH/2)
        if P.INT_KEYS[key] then readout.Text = string.format("%d", math.floor(v + 0.5))
        else readout.Text = string.format("%.2f", v) end
    end
    local hit = Instance.new("TextButton")
    hit.Text = ""
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.ZIndex = 11
    hit.Parent = r
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local x = i.Position.X
            if x >= track.AbsolutePosition.X - 10 then
                drg = true; setX(x)
            end
        end
    end)
    P.Connections[#P.Connections+1] = UserInputService.InputChanged:Connect(function(i)
        if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setX(i.Position.X)
        end
    end)
    P.Connections[#P.Connections+1] = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if drg then drg = false; P.saveSettings() end
        end
    end)
    P.themedSliders[#P.themedSliders+1] = { track = track, fill = fill, readout = readout, knob = knob }
end

P.makeDropdown = function(r, key, options, onChange)
    local bW, bH = 120, 24
    local btn = Instance.new("TextButton")
    btn.Text = tostring(P.C[key])
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextColor3 = PAL.text
    btn.BackgroundColor3 = PAL.panel
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(bW, bH)
    btn.Position = UDim2.new(1, -bW - 2, 0.5, -bH/2)
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.ZIndex = 9
    btn.Parent = r
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline; st.Thickness = 1; st.Transparency = 0; st.Parent = btn
    local ddGlow = P.addGlow(btn, PAL.accent)
    ddGlow.Transparency = 0.82

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surfaceHover }):Play()
        ddGlow.Transparency = 0.6
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.panel }):Play()
        ddGlow.Transparency = 0.82
    end)

    btn.MouseButton1Click:Connect(function()
        P.closeOpenDropdown()
        P.fireRipple(btn)
        local optionCount = #options
        local rowH = 24
        local padY = 6
        local desiredH = padY * 2 + optionCount * rowH
        local maxPopupH = 240
        local btnRelY = btn.AbsolutePosition.Y - P.frame.AbsolutePosition.Y
        local btnRelX = btn.AbsolutePosition.X - P.frame.AbsolutePosition.X
        local spaceBelow = P.frame.AbsoluteSize.Y - (btnRelY + btn.AbsoluteSize.Y) - 8
        local spaceAbove = btnRelY - 8
        local popupH = math.min(desiredH, maxPopupH)
        local flipUp = false
        if spaceBelow < popupH and spaceAbove > spaceBelow then
            flipUp = true
            popupH = math.min(desiredH, maxPopupH, math.max(spaceAbove, 60))
        else
            popupH = math.min(desiredH, maxPopupH, math.max(spaceBelow, 60))
        end
        local popup = Instance.new("ScrollingFrame")
        popup.Name = "DropdownPopup"
        popup.Size = UDim2.fromOffset(bW + 20, popupH)
        if flipUp then
            popup.Position = UDim2.fromOffset(btnRelX - 10, btnRelY - popupH - 2)
        else
            popup.Position = UDim2.fromOffset(btnRelX - 10, btnRelY + btn.AbsoluteSize.Y + 2)
        end
        popup.BackgroundColor3 = PAL.panelDeep
        popup.BorderSizePixel = 0
        popup.ZIndex = 300
        popup.Active = true
        popup.ClipsDescendants = true
        popup.ScrollBarThickness = 0
        popup.ScrollingDirection = Enum.ScrollingDirection.Y
        popup.ElasticBehavior = Enum.ElasticBehavior.Never
        popup.CanvasSize = UDim2.new(0, 0, 0, padY * 2 + optionCount * rowH)
        popup.Parent = P.frame
        local pst = Instance.new("UIStroke")
        pst.Color = PAL.outline; pst.Thickness = 1; pst.Transparency = 0.2; pst.Parent = popup
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, padY); pad.PaddingBottom = UDim.new(0, padY)
        pad.PaddingLeft = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 4)
        pad.Parent = popup
        popup.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseWheel then
                local cy = popup.CanvasPosition.Y
                local maxY = math.max(0, popup.AbsoluteCanvasSize.Y - popup.AbsoluteSize.Y)
                popup.CanvasPosition = Vector2.new(0, math.clamp(cy - i.Position.Z * 24, 0, maxY))
            end
        end)
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Text = tostring(opt)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 11
            optBtn.TextColor3 = (opt == P.C[key]) and PAL.text or PAL.textDim
            optBtn.BackgroundColor3 = PAL.surfaceHover
            optBtn.BackgroundTransparency = 1
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Size = UDim2.new(1, 0, 0, rowH - 2)
            optBtn.Position = UDim2.fromOffset(0, (i - 1) * rowH)
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 301
            optBtn.Parent = popup
            local op = Instance.new("UIPadding")
            op.PaddingLeft = UDim.new(0, 12); op.PaddingRight = UDim.new(0, 4)
            op.Parent = optBtn
            if opt == P.C[key] then
                local bar = Instance.new("Frame")
                bar.Size = UDim2.fromOffset(2, 12)
                bar.Position = UDim2.new(0, 2, 0.5, -6)
                bar.BackgroundColor3 = PAL.accent
                bar.BorderSizePixel = 0
                bar.ZIndex = 302
                bar.Parent = optBtn
            end
            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.2 }):Play()
                optBtn.TextColor3 = PAL.text
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
                if opt ~= P.C[key] then optBtn.TextColor3 = PAL.textDim end
            end)
            optBtn.MouseButton1Click:Connect(function()
                P.C[key] = opt
                btn.Text = tostring(opt)
                if onChange then pcall(onChange, opt) end
                task.defer(function() P.closeOpenDropdown() end)
                P.saveSettings()
                P.fireRipple(optBtn)
            end)
        end
        P.openDropdown = popup
    end)
end

P.Connections[#P.Connections+1] = UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if P.openDropdown then
            local pos = input.Position
            local ap = P.openDropdown.AbsolutePosition
            local as = P.openDropdown.AbsoluteSize
            local overPopup = pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
            if not overPopup then P.closeOpenDropdown() end
        end
    end
end)

P.makeKeybind = function(r, key)
    local bW, bH = 120, 24
    local btn = Instance.new("TextButton")
    local function displayName(v) return (v == "None" or v == nil) and "—" or tostring(v) end
    btn.Text = displayName(P.C[key])
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextColor3 = PAL.text
    btn.BackgroundColor3 = PAL.panel
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(bW, bH)
    btn.Position = UDim2.new(1, -bW - 2, 0.5, -bH/2)
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.ZIndex = 9
    btn.Parent = r
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline; st.Thickness = 1; st.Transparency = 0; st.Parent = btn
    local kbGlow = P.addGlow(btn, PAL.accent)
    kbGlow.Transparency = 0.82
    local function refresh() btn.Text = displayName(P.C[key]) end
    refresh()
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surfaceHover }):Play()
        kbGlow.Transparency = 0.6
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.panel }):Play()
        kbGlow.Transparency = 0.82
    end)
    btn.MouseButton1Click:Connect(function()
        if P.keybindCapture == key then
            P.keybindCapture = nil
            refresh()
            st.Color = PAL.hairline
        else
            P.keybindCapture = key
            btn.Text = "press key…"
            st.Color = PAL.accent
        end
        P.fireRipple(btn)
    end)
    btn.MouseButton2Click:Connect(function()
        P.C[key] = "None"
        if P.keybindCapture == key then P.keybindCapture = nil end
        refresh()
        st.Color = PAL.hairline
        P.saveSettings()
    end)
    P.refreshFns[#P.refreshFns+1] = refresh
    P.themedDropdowns[#P.themedDropdowns+1] = { btn = btn, stroke = st, key = key }
end

P.makeButton = function(r, text, fn)
    local bW, bH = 120, 24
    local b = Instance.new("TextButton")
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextColor3 = PAL.text
    b.BackgroundColor3 = PAL.surface
    b.BackgroundTransparency = 0
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Size = UDim2.fromOffset(bW, bH)
    b.Position = UDim2.new(1, -bW - 2, 0.5, -bH/2)
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.ZIndex = 9
    b.Parent = r
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline; st.Thickness = 1; st.Transparency = 0; st.Parent = b
    local btnGlow = P.addGlow(b, PAL.accent)
    btnGlow.Transparency = 0.82
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surfaceHover }):Play()
        btnGlow.Transparency = 0.6
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surface }):Play()
        btnGlow.Transparency = 0.82
    end)
    b.MouseButton1Click:Connect(function()
        P.fireRipple(b)
        fn()
    end)
    P.themedButtons[#P.themedButtons+1] = b
    return b
end

P.makeColorButton = function(r, get, set, title)
    local bW, bH = 120, 24
    local btn = Instance.new("TextButton")
    btn.Text = "Pick"
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = PAL.text
    btn.BackgroundColor3 = PAL.surface
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromOffset(bW, bH)
    btn.Position = UDim2.new(1, -bW - 2, 0.5, -bH/2)
    btn.ZIndex = 9
    btn.Parent = r
    local st = Instance.new("UIStroke")
    st.Color = PAL.hairline; st.Thickness = 1; st.Transparency = 0; st.Parent = btn
    local cbGlow = P.addGlow(btn, PAL.accent)
    cbGlow.Transparency = 0.82
    local sw = Instance.new("Frame")
    sw.Size = UDim2.fromOffset(12, 12)
    sw.Position = UDim2.new(1, -18, 0.5, -6)
    sw.BackgroundColor3 = get()
    sw.BorderSizePixel = 0
    sw.ZIndex = 10
    sw.Parent = btn
    local swStroke = Instance.new("UIStroke")
    swStroke.Color = PAL.hairline; swStroke.Thickness = 1; swStroke.Parent = sw
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surfaceHover }):Play()
        cbGlow.Transparency = 0.6
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = PAL.surface }):Play()
        cbGlow.Transparency = 0.82
    end)
    btn.MouseButton1Click:Connect(function()
        P.fireRipple(btn)
        if P.openColorPicker then
            P.openColorPicker(title or "Color", get(), function(color)
                set(color); sw.BackgroundColor3 = color; P.saveSettings()
            end)
        end
    end)
    P.themedButtons[#P.themedButtons+1] = btn
end

P.makeTabHolder = function(name, canvasH)
    local holder = Instance.new("ScrollingFrame")
    holder.Name = "Tab_" .. name
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.Position = UDim2.fromOffset(0, 0)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ScrollBarThickness = 4
    holder.ScrollBarImageColor3 = PAL.divider
    holder.ScrollBarImageTransparency = 0.3
    holder.CanvasSize = UDim2.new(0, 0, 0, canvasH or 600)
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.ClipsDescendants = true
    holder.Visible = false
    holder.ZIndex = 7
    holder.Parent = P.contentArea
    P.Tabs[name] = P.Tabs[name] or {}
    P.Tabs[name].holder = holder
    return holder
end

P.COLOR_SWATCHES = {
    { name = "White",    color = Color3.fromRGB(255, 255, 255) },
    { name = "Red",      color = Color3.fromRGB(255, 60, 60)   },
    { name = "Orange",   color = Color3.fromRGB(255, 145, 60)  },
    { name = "Yellow",   color = Color3.fromRGB(255, 235, 60)  },
    { name = "Green",    color = Color3.fromRGB(90, 235, 90)   },
    { name = "SeaGreen", color = Color3.fromRGB(60, 200, 145)  },
    { name = "Cyan",     color = Color3.fromRGB(60, 220, 235)  },
    { name = "Lavender", color = Color3.fromRGB(180, 160, 245) },
    { name = "Blue",     color = Color3.fromRGB(70, 130, 245)  },
    { name = "Violet",   color = Color3.fromRGB(160, 70, 235)  },
    { name = "Magenta",  color = Color3.fromRGB(235, 70, 200)  },
    { name = "Pink",     color = Color3.fromRGB(255, 130, 180) },
}

local HUE_GRADIENT = ColorSequence.new({
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0)),
})

P.openColorPicker = function(title, initial, onApply)
    if P._colorPickerFrame then pcall(function() P._colorPickerFrame:Destroy() end); P._colorPickerFrame = nil end
    P.colorPickerReadouts = {}; P.colorPickerSliderFills = {}; P.colorPickerOpen = true
    initial = initial or Color3.fromRGB(255,255,255)
    local stt = {
        R = math.clamp(math.floor(initial.R * 255 + 0.5), 0, 255),
        G = math.clamp(math.floor(initial.G * 255 + 0.5), 0, 255),
        B = math.clamp(math.floor(initial.B * 255 + 0.5), 0, 255),
    }
    local h0, s0, v0 = Color3.toHSV(initial)
    local cpW, cpH = 300, 470
    local vp = P.cachedViewport
    local cp = Instance.new("Frame")
    cp.Size = UDim2.fromOffset(cpW, cpH)
    cp.Position = UDim2.fromOffset(math.max(0,(vp.X-cpW)/2), math.max(0,(vp.Y-cpH)/2))
    cp.BackgroundColor3 = PAL.panel
    cp.BorderSizePixel = 0
    cp.Active = true
    cp.ZIndex = 400
    cp.Parent = P.gui
    local cps = Instance.new("UIStroke"); cps.Color = PAL.hairline; cps.Thickness = 1; cps.Parent = cp

    local dragging, dragStart, startPos = false, nil, nil
    cp.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = cp.Position
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            cp.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local tl = Instance.new("TextLabel")
    tl.Text = title; tl.Font = Enum.Font.GothamMedium; tl.TextSize = 12
    tl.TextColor3 = PAL.text; tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -40, 0, 24); tl.Position = UDim2.fromOffset(12, 6)
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextYAlignment = Enum.TextYAlignment.Center
    tl.ZIndex = 401; tl.Parent = cp

    local cb = Instance.new("TextButton")
    cb.Text = "X"; cb.Font = Enum.Font.GothamMedium; cb.TextSize = 11
    cb.TextColor3 = PAL.textDim; cb.BackgroundColor3 = PAL.surface
    cb.BorderSizePixel = 0; cb.AutoButtonColor = false
    cb.Size = UDim2.fromOffset(20, 20); cb.Position = UDim2.new(1, -26, 0, 6)
    cb.ZIndex = 401; cb.Parent = cp

    local hueTrack = Instance.new("Frame")
    hueTrack.BackgroundColor3 = Color3.fromRGB(255,255,255); hueTrack.BorderSizePixel = 0
    hueTrack.Size = UDim2.fromOffset(240, 18); hueTrack.Position = UDim2.fromOffset(30, 36)
    hueTrack.ZIndex = 401; hueTrack.Parent = cp
    local hueGrad = Instance.new("UIGradient"); hueGrad.Color = HUE_GRADIENT; hueGrad.Parent = hueTrack

    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.fromOffset(6, 22); hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    hueKnob.Position = UDim2.new(h0, 0, 0.5, 0)
    hueKnob.BackgroundColor3 = Color3.fromRGB(240,240,244); hueKnob.BorderSizePixel = 0
    hueKnob.ZIndex = 403; hueKnob.Parent = hueTrack

    local svBase = Instance.new("Frame")
    svBase.BackgroundColor3 = Color3.fromHSV(h0, 1, 1); svBase.BorderSizePixel = 0
    svBase.Size = UDim2.fromOffset(200, 200); svBase.Position = UDim2.fromOffset(50, 68)
    svBase.ZIndex = 401; svBase.Parent = cp

    local svWhite = Instance.new("Frame")
    svWhite.BackgroundColor3 = Color3.fromRGB(255,255,255); svWhite.BorderSizePixel = 0
    svWhite.Size = UDim2.new(1, 0, 1, 0); svWhite.ZIndex = 402; svWhite.Parent = svBase
    local whiteGrad = Instance.new("UIGradient")
    whiteGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    whiteGrad.Parent = svWhite

    local svBlack = Instance.new("Frame")
    svBlack.BackgroundColor3 = Color3.fromRGB(0,0,0); svBlack.BorderSizePixel = 0
    svBlack.Size = UDim2.new(1, 0, 1, 0); svBlack.ZIndex = 403; svBlack.Parent = svBase
    local blackGrad = Instance.new("UIGradient")
    blackGrad.Rotation = 90
    blackGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
    blackGrad.Parent = svBlack

    local svKnob = Instance.new("Frame")
    svKnob.Size = UDim2.fromOffset(10, 10); svKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    svKnob.Position = UDim2.new(s0, 0, 1 - v0, 0)
    svKnob.BackgroundTransparency = 1; svKnob.BorderSizePixel = 0
    svKnob.ZIndex = 405; svKnob.Parent = svBase
    local svKnobStroke = Instance.new("UIStroke")
    svKnobStroke.Color = Color3.fromRGB(255,255,255); svKnobStroke.Thickness = 2
    svKnobStroke.Parent = svKnob

    local pv = Instance.new("Frame")
    pv.BackgroundColor3 = Color3.fromRGB(stt.R, stt.G, stt.B); pv.BorderSizePixel = 0
    pv.Size = UDim2.fromOffset(60, 32); pv.Position = UDim2.fromOffset(30, 280)
    pv.ZIndex = 401; pv.Parent = cp

    local hexLabel = Instance.new("TextLabel")
    hexLabel.Text = string.format("#%02X%02X%02X", stt.R, stt.G, stt.B)
    hexLabel.Font = Enum.Font.Code; hexLabel.TextSize = 12
    hexLabel.TextColor3 = PAL.text; hexLabel.BackgroundTransparency = 1
    hexLabel.Size = UDim2.fromOffset(140, 32); hexLabel.Position = UDim2.fromOffset(100, 280)
    hexLabel.TextXAlignment = Enum.TextXAlignment.Left
    hexLabel.TextYAlignment = Enum.TextYAlignment.Center
    hexLabel.ZIndex = 401; hexLabel.Parent = cp

    local function refreshAll()
        local col = Color3.fromRGB(stt.R, stt.G, stt.B)
        pv.BackgroundColor3 = col
        hexLabel.Text = string.format("#%02X%02X%02X", stt.R, stt.G, stt.B)
        local hh, ss, vv = Color3.toHSV(col)
        hueKnob.Position = UDim2.new(hh, 0, 0.5, 0)
        svBase.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
        svKnob.Position = UDim2.new(ss, 0, 1 - vv, 0)
        for key, entry in pairs(P.colorPickerSliderFills) do
            entry.fill.Size = UDim2.new(stt[key] / 255, 0, 1, 0)
        end
        for key, ro in pairs(P.colorPickerReadouts) do ro.Text = tostring(stt[key]) end
    end

    local function setFromHSV(hh, ss, vv)
        local col = Color3.fromHSV(hh, ss, vv)
        stt.R = math.floor(col.R * 255 + 0.5)
        stt.G = math.floor(col.G * 255 + 0.5)
        stt.B = math.floor(col.B * 255 + 0.5)
        refreshAll()
    end

    local hueDrag = false
    local function hueSetX(px)
        local fr = math.clamp((px - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
        local _, ss, vv = Color3.toHSV(Color3.fromRGB(stt.R, stt.G, stt.B))
        setFromHSV(fr, ss, vv)
    end
    hueTrack.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hueDrag = true; hueSetX(i.Position.X)
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputChanged:Connect(function(i)
        if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            hueSetX(i.Position.X)
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hueDrag = false
        end
    end)

    local svDrag = false
    local function svSet(px, py)
        local hh, _, _ = Color3.toHSV(Color3.fromRGB(stt.R, stt.G, stt.B))
        local ss = math.clamp((px - svBase.AbsolutePosition.X) / svBase.AbsoluteSize.X, 0, 1)
        local vv = math.clamp(1 - ((py - svBase.AbsolutePosition.Y) / svBase.AbsoluteSize.Y), 0, 1)
        setFromHSV(hh, ss, vv)
    end
    svBase.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            svDrag = true; svSet(i.Position.X, i.Position.Y)
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputChanged:Connect(function(i)
        if svDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            svSet(i.Position.X, i.Position.Y)
        end
    end)
    P.Connections[#P.Connections+1] = P.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            svDrag = false
        end
    end)

    local function makeChannelSlider(y, label, key)
        local lb = Instance.new("TextLabel")
        lb.Text = label; lb.Font = Enum.Font.GothamMedium; lb.TextSize = 11
        lb.TextColor3 = PAL.text; lb.BackgroundTransparency = 1
        lb.Size = UDim2.fromOffset(16, 18); lb.Position = UDim2.fromOffset(30, y)
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb.ZIndex = 401; lb.Parent = cp

        local track = Instance.new("Frame")
        track.BackgroundColor3 = PAL.track; track.BorderSizePixel = 0
        track.Size = UDim2.fromOffset(160, 3); track.Position = UDim2.fromOffset(52, y + 8)
        track.ZIndex = 401; track.Parent = cp

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = PAL.accent; fill.BorderSizePixel = 0
        fill.Size = UDim2.new(stt[key] / 255, 0, 1, 0)
        fill.ZIndex = 402; fill.Parent = track

        local ro = Instance.new("TextLabel")
        ro.Text = tostring(stt[key]); ro.Font = Enum.Font.Gotham; ro.TextSize = 11
        ro.TextColor3 = PAL.text; ro.BackgroundTransparency = 1
        ro.Size = UDim2.fromOffset(40, 18); ro.Position = UDim2.new(1, -46, 0, y)
        ro.TextXAlignment = Enum.TextXAlignment.Right
        ro.TextYAlignment = Enum.TextYAlignment.Center
        ro.ZIndex = 401; ro.Parent = cp

        P.colorPickerSliderFills[key] = { fill = fill, track = track }
        P.colorPickerReadouts[key] = ro

        local drg = false
        local function setX(px)
            local fr = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            stt[key] = math.floor(fr * 255 + 0.5)
            fill.Size = UDim2.new(fr, 0, 1, 0)
            ro.Text = tostring(stt[key])
            local col = Color3.fromRGB(stt.R, stt.G, stt.B)
            pv.BackgroundColor3 = col
            hexLabel.Text = string.format("#%02X%02X%02X", stt.R, stt.G, stt.B)
            local hh, ss, vv = Color3.toHSV(col)
            hueKnob.Position = UDim2.new(hh, 0, 0.5, 0)
            svBase.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
            svKnob.Position = UDim2.new(ss, 0, 1 - vv, 0)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drg = true; setX(i.Position.X)
            end
        end)
        P.Connections[#P.Connections+1] = P.UserInputService.InputChanged:Connect(function(i)
            if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                setX(i.Position.X)
            end
        end)
        P.Connections[#P.Connections+1] = P.UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drg = false
            end
        end)
    end

    makeChannelSlider(322, "R", "R")
    makeChannelSlider(348, "G", "G")
    makeChannelSlider(374, "B", "B")

    local swGridX = 30; local swGridY = 400
    local swCellW = 38; local swCellH = 14
    local swGapX = 2; local swGapY = 2
    for i, swatch in ipairs(P.COLOR_SWATCHES) do
        local col = (i - 1) % 6
        local row = math.floor((i - 1) / 6)
        local sb = Instance.new("TextButton")
        sb.Text = ""; sb.BackgroundColor3 = swatch.color; sb.BorderSizePixel = 0
        sb.AutoButtonColor = false
        sb.Size = UDim2.fromOffset(swCellW, swCellH)
        sb.Position = UDim2.fromOffset(swGridX + col * (swCellW + swGapX), swGridY + row * (swCellH + swGapY))
        sb.ZIndex = 401; sb.Parent = cp
        sb.MouseButton1Click:Connect(function()
            stt.R = math.floor(swatch.color.R * 255 + 0.5)
            stt.G = math.floor(swatch.color.G * 255 + 0.5)
            stt.B = math.floor(swatch.color.B * 255 + 0.5)
            refreshAll()
        end)
    end

    local ab = Instance.new("TextButton")
    ab.Text = "Apply"; ab.Font = Enum.Font.GothamMedium; ab.TextSize = 11
    ab.TextColor3 = Color3.fromRGB(255,255,255); ab.BackgroundColor3 = PAL.accent
    ab.BorderSizePixel = 0; ab.AutoButtonColor = false
    ab.Size = UDim2.fromOffset(120, 24); ab.Position = UDim2.fromOffset(20, 436)
    ab.ZIndex = 401; ab.Parent = cp

    local cn = Instance.new("TextButton")
    cn.Text = "Cancel"; cn.Font = Enum.Font.Gotham; cn.TextSize = 11
    cn.TextColor3 = PAL.text; cn.BackgroundColor3 = PAL.surface
    cn.BorderSizePixel = 0; cn.AutoButtonColor = false
    cn.Size = UDim2.fromOffset(120, 24); cn.Position = UDim2.fromOffset(160, 436)
    cn.ZIndex = 401; cn.Parent = cp

    local function closePicker()
        cp:Destroy()
        P._colorPickerFrame = nil
        P.colorPickerOpen = false
        P.colorPickerReadouts = {}
        P.colorPickerSliderFills = {}
    end

    ab.MouseButton1Click:Connect(function()
        if onApply then pcall(onApply, Color3.fromRGB(stt.R, stt.G, stt.B)) end
        closePicker()
    end)
    cn.MouseButton1Click:Connect(closePicker)
    cb.MouseButton1Click:Connect(closePicker)
    P._colorPickerFrame = cp
end

P.dismissToast = function()
    if P.toast then P.toast:Destroy(); P.toast = nil end
end

P.showToast = function()
    P.dismissToast()
    local f = Instance.new("Frame")
    local tW, tH = 300, 46
    f.Size = UDim2.fromOffset(tW, tH)
    f.Position = UDim2.new(1, -tW - 20, 1, -tH - 20)
    f.BackgroundColor3 = PAL.panel; f.BorderSizePixel = 0
    f.ZIndex = 30; f.Parent = P.toastGui
    local s = Instance.new("UIStroke"); s.Color = PAL.hairline; s.Thickness = 1; s.Parent = f
    local ab = Instance.new("Frame")
    ab.Size = UDim2.fromOffset(2, 30); ab.Position = UDim2.fromOffset(8, 8)
    ab.BackgroundColor3 = PAL.accent; ab.BorderSizePixel = 0; ab.ZIndex = 31; ab.Parent = f
    local tl = Instance.new("TextLabel")
    tl.Text = P.PEGASUS_NAME .. " minimized — press " .. tostring(C.keyMenu or "0") .. " to reopen"
    tl.Font = Enum.Font.GothamMedium; tl.TextSize = 11
    tl.TextColor3 = PAL.text; tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -24, 1, 0); tl.Position = UDim2.fromOffset(18, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextYAlignment = Enum.TextYAlignment.Center
    tl.ZIndex = 31; tl.Parent = f
    P.toast = f
    task.delay(2.0, function()
        if P.toast == f then P.dismissToast() end
    end)
end

P.showCloseToast = function()
    if P._closeToast then pcall(function() P._closeToast:Destroy() end); P._closeToast = nil end
    if not P.toastGui then return end
    local f = Instance.new("Frame")
    local tW, tH = 300, 52
    f.Size = UDim2.fromOffset(tW, tH)
    f.Position = UDim2.new(1, -tW - 20, 1, -tH - 20)
    f.BackgroundColor3 = PAL.panel
    f.BorderSizePixel = 0
    f.ZIndex = 35
    f.Parent = P.toastGui
    local s = Instance.new("UIStroke"); s.Color = PAL.hairline; s.Thickness = 1; s.Parent = f
    local ab = Instance.new("Frame")
    ab.Size = UDim2.fromOffset(2, 36); ab.Position = UDim2.fromOffset(8, 8)
    ab.BackgroundColor3 = PAL.accent; ab.BorderSizePixel = 0; ab.ZIndex = 36; ab.Parent = f

    local tl = Instance.new("TextLabel")
    tl.Text = P.PEGASUS_NAME .. " closed"
    tl.Font = Enum.Font.GothamBold; tl.TextSize = 11
    tl.TextColor3 = PAL.text; tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1, -24, 0, 16); tl.Position = UDim2.fromOffset(18, 8)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 36; tl.Parent = f

    local bl = Instance.new("TextLabel")
    bl.Text = "Press " .. tostring(C.keyMenu or "0") .. " to reopen"
    bl.Font = Enum.Font.Gotham; bl.TextSize = 10
    bl.TextColor3 = PAL.textDim; bl.BackgroundTransparency = 1
    bl.Size = UDim2.new(1, -24, 0, 14); bl.Position = UDim2.fromOffset(18, 28)
    bl.TextXAlignment = Enum.TextXAlignment.Left
    bl.ZIndex = 36; bl.Parent = f

    P._closeToast = f
    task.delay(5.0, function()
        if P._closeToast == f then
            if f and f.Parent then f:Destroy() end
            P._closeToast = nil
        end
    end)
end

P.toggleFullscreen = function()
    if P.C._fullscreen then
        if P.savedFullscreenState then
            P.frame.Size = P.savedFullscreenState.size
            P.frame.Position = P.savedFullscreenState.position
            P.savedFullscreenState = nil
        else
            P.frame.Size = UDim2.fromOffset(P.PANEL_W, P.PANEL_H)
            P.frame.Position = UDim2.fromOffset(P.C.panelX, P.C.panelY)
        end
        P.C._fullscreen = false
    else
        P.savedFullscreenState = { size = P.frame.Size, position = P.frame.Position }
        P.frame.Size = UDim2.new(1, 0, 1, 0)
        P.frame.Position = UDim2.fromOffset(0, 0)
        P.C._fullscreen = true
    end
end

P.minimizeMenu = function()
    P.C.menuOpen = false
    if P.gui then P.gui.Enabled = false end
    P.showToast()
end

P.closeMenu = function()
    if P.shuttingDown then return end
    P.shuttingDown = true
    P.dismissToast()
    if P._colorPickerFrame then pcall(function() P._colorPickerFrame:Destroy() end); P._colorPickerFrame = nil end
    P.colorPickerOpen = false
    P.colorPickerReadouts = {}; P.colorPickerSliderFills = {}
    if P.menuToggleConn then pcall(function() P.menuToggleConn:Disconnect() end); P.menuToggleConn = nil end
    for _, c in ipairs(P.Connections) do pcall(function() c:Disconnect() end) end
    P.Connections = {}
    if P.spinConn then pcall(function() P.spinConn:Disconnect() end); P.spinConn = nil end
    if P.adminState.flyRenderConn then pcall(function() P.adminState.flyRenderConn:Disconnect() end); P.adminState.flyRenderConn = nil end
    if P.adminState.speedLoopConn then pcall(function() P.adminState.speedLoopConn:Disconnect() end); P.adminState.speedLoopConn = nil end
    if P.adminState.jumpLoopConn then pcall(function() P.adminState.jumpLoopConn:Disconnect() end); P.adminState.jumpLoopConn = nil end
    if P.adminState.clickTPConn then pcall(function() P.adminState.clickTPConn:Disconnect() end); P.adminState.clickTPConn = nil end
    if P._noclipConn then pcall(function() P._noclipConn:Disconnect() end); P._noclipConn = nil end
    for p, _ in pairs(P.espInstances) do pcall(function() P.detachEngineESP(p) end) end
    for _, o in pairs(P.espObjects) do P.hideDrawingESP(o) end
    for _, o in ipairs(P.Reg) do P.rm(o) end
    P.Reg = {}; P.drawingCount = 0
    if P.radar then
        if P.radar.circle then P.rm(P.radar.circle) end
        if P.radar.crossX then P.rm(P.radar.crossX) end
        if P.radar.crossY then P.rm(P.radar.crossY) end
        if P.radar.sweep then P.rm(P.radar.sweep) end
        for _, entry in pairs(P.radar.dots or {}) do
            if entry.dot then P.rm(entry.dot) end
            if entry.name then P.rm(entry.name) end
        end
        P.radar = nil
    end
    if P.trigRing then P.rm(P.trigRing); P.trigRing = nil end
    if P.statusDraw then P.rm(P.statusDraw); P.statusDraw = nil end
    if P.fovRing then P.rm(P.fovRing); P.fovRing = nil end
    if P.crosshair then
        for _, l in pairs(P.crosshair) do P.rm(l) end
        P.crosshair = nil
    end
    if P.hitMarker then
        if P.hitMarker.a then P.rm(P.hitMarker.a) end
        if P.hitMarker.b then P.rm(P.hitMarker.b) end
        P.hitMarker = nil
    end
    if P.targetPanel then
        if P.targetPanel.name then P.rm(P.targetPanel.name) end
        if P.targetPanel.dist then P.rm(P.targetPanel.dist) end
        if P.targetPanel.hp then P.rm(P.targetPanel.hp) end
        P.targetPanel = nil
    end
    if P.overlayPanel and P.overlayPanel.frame then
        pcall(function() P.overlayPanel.frame:Destroy() end)
        P.overlayPanel = nil
    end
    if P.showCloseToast then pcall(P.showCloseToast) end
    if P.gui then P.gui:Destroy(); P.gui = nil end
    if P.notifyGui then P.notifyGui:Destroy(); P.notifyGui = nil end
    if P.overlayGui then P.overlayGui:Destroy(); P.overlayGui = nil end
    if P.loadingGui then P.loadingGui:Destroy(); P.loadingGui = nil end
    if rconsoleprint then rconsoleprint("[Pegasus] closed\n") end
    task.delay(5.5, function()
        if P.toastGui then pcall(function() P.toastGui:Destroy() end); P.toastGui = nil end
        P.shuttingDown = false
    end)
end

P.console("[Pegasus] GUI scaffold loaded")
    ]=])

    -- tabs chunk ------------------------------------------------------------
    runChunk("pegasus.tabs", [=[
local G = getgenv()
local P = G._pegasus
local Players = P.Players
local LocalPlayer = P.LocalPlayer
local PAL, C = P.PAL, P.C

local function safeTab(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        P.logError("tab build " .. name .. ": " .. tostring(err))
    end
end

local function makePage(tabName, subName)
    if subName then
        if not P.subTabs[tabName] or not P.subTabs[tabName].holders[subName] then
            P.logError("makePage: missing sub-tab " .. tostring(tabName) .. "/" .. tostring(subName))
            return nil
        end
        return P.subTabs[tabName].holders[subName]
    end
    P.Tabs[tabName] = P.Tabs[tabName] or {}
    if not P.Tabs[tabName].holder then
        P.makeTabHolder(tabName, 1200)
    end
    return P.Tabs[tabName].holder
end

P.makePage = makePage

local function addRow(page, labelText, opt)
    if not page then P.logError("addRow: nil page for " .. tostring(labelText)); return end
    local y = page:GetAttribute("_rowY") or 8
    local r
    if opt and opt.kind == "toggle" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeToggle(r, function() return P.C[opt.key] end, function(v) P.C[opt.key] = v end)
    elseif opt and opt.kind == "slider" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeSlider(r, opt.key)
    elseif opt and opt.kind == "dropdown" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeDropdown(r, opt.key, opt.values, opt.onChange)
    elseif opt and opt.kind == "keybind" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeKeybind(r, opt.key)
    elseif opt and opt.kind == "button" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeButton(r, opt.text or "Run", opt.fn)
    elseif opt and opt.kind == "color" then
        r = P.makeRow(page, y)
        P.makeTitleLabelCompact(r, labelText)
        P.makeColorButton(r, function() return P.C[opt.key] end, function(v) P.C[opt.key] = v end, labelText)
    elseif opt and opt.kind == "label" then
        r = P.makeRow(page, y)
        P.makeLabel(r, labelText)
        P.makeValueLabel(r, tostring(opt.value or ""))
    else
        r = P.makeRow(page, y)
        P.makeLabel(r, labelText)
    end
    page:SetAttribute("_rowY", y + 44)
    local cs = page.CanvasSize
    page.CanvasSize = UDim2.new(0, 0, 0, math.max(cs.Y.Offset, y + 52))
end

P.row = addRow

P.section = function(page, text)
    local y = page:GetAttribute("_rowY") or 8
    P.makeSectionHeader(page, y, text)
    page:SetAttribute("_rowY", y + 34)
end

safeTab("Home", function()
    local page = makePage("Home")

    P.section(page, "Server Info")
    P.row(page, "Active Injection", { kind = "label", value = "v" .. tostring(P.PEGASUS_VERSION) .. " " .. tostring(P.PEGASUS_SUBVERSION) })
    P.row(page, "Place ID", { kind = "label", value = tostring(game.PlaceId) })
    P.row(page, "Job ID", { kind = "label", value = tostring(game.JobId) })

    P.section(page, "Handy Stuff")
    P.row(page, "Toggle Menu", { kind = "label", value = tostring(C.keyMenu) })
    P.row(page, "Unload", { kind = "label", value = tostring(C.keyUnload) })

    P.section(page, "Your Keys")
    do
        local y = page:GetAttribute("_rowY") or 8
        local r = P.makeRow(page, y)
        P.makeLabel(r, string.format("Menu %s · Aim %s · Trigger %s · ESP %s · Unload %s",
            tostring(C.keyMenu), tostring(C.keyAim), tostring(C.keyTrigger),
            tostring(C.keyEsp), tostring(C.keyUnload)))
        page:SetAttribute("_rowY", y + 44)
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(page.CanvasSize.Y.Offset, y + 52))
    end

    P.section(page, "Made By")

    do
        local y = page:GetAttribute("_rowY") or 8
        local banner = P.makeStackedRow(page, y)
        banner.Size = UDim2.new(1, -32, 0, 168)
        local img = Instance.new("ImageLabel")
        img.Name = "_brandBanner"
        img.BackgroundTransparency = 1
        img.Image = P.PEGASUS_BANNER
        img.ScaleType = Enum.ScaleType.Fit
        img.Size = UDim2.new(1, -16, 1, -8)
        img.Position = UDim2.fromOffset(8, 4)
        img.ZIndex = 8
        img.Parent = banner
        page:SetAttribute("_rowY", y + 180)
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(page.CanvasSize.Y.Offset, y + 188))
    end

    do
        local y = page:GetAttribute("_rowY") or 8
        local heroRow = P.makeStackedRow(page, y)
        P.PegasusIcon(heroRow, UDim2.fromOffset(16, 6), 40, {
            glow = true,
            anchor = Vector2.new(0, 0),
        })
        local t1 = Instance.new("TextLabel")
        t1.Parent = heroRow; t1.BackgroundTransparency = 1
        t1.Position = UDim2.fromOffset(66, 6); t1.Size = UDim2.new(1, -80, 0, 16)
        t1.Font = Enum.Font.GothamBold; t1.TextSize = 13; t1.TextColor3 = PAL.text
        t1.TextXAlignment = Enum.TextXAlignment.Left; t1.Text = "PEGASUS"
        t1.ZIndex = 8
        local t2 = Instance.new("TextLabel")
        t2.Parent = heroRow; t2.BackgroundTransparency = 1
        t2.Position = UDim2.fromOffset(66, 22); t2.Size = UDim2.new(1, -80, 0, 14)
        t2.Font = Enum.Font.Gotham; t2.TextSize = 10; t2.TextColor3 = PAL.textDim
        t2.TextXAlignment = Enum.TextXAlignment.Left; t2.Text = "Universal client-side framework"
        t2.ZIndex = 8
        local t3 = Instance.new("TextLabel")
        t3.Parent = heroRow; t3.BackgroundTransparency = 1
        t3.Position = UDim2.fromOffset(66, 34); t3.Size = UDim2.new(1, -80, 0, 12)
        t3.Font = Enum.Font.Gotham; t3.TextSize = 10; t3.TextColor3 = PAL.accent
        t3.TextXAlignment = Enum.TextXAlignment.Left
        t3.Text = "v" .. tostring(P.PEGASUS_VERSION) .. " " .. tostring(P.PEGASUS_SUBVERSION)
        t3.ZIndex = 8
        page:SetAttribute("_rowY", y + 56)
    end

    do
        local y = page:GetAttribute("_rowY") or 8
        local aboutRow = P.makeStackedRow(page, y)
        aboutRow.Size = UDim2.new(1, -32, 0, 76)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "_aboutText"
        lbl.Text = "Built entirely by Urban over the course of a few weeks. Every line written by hand, tested on live servers, iterated until it felt right. Big thanks to my good friend YuleTide for helping me test and for putting up with all the late-night debugging calls."
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = PAL.textDim
        lbl.BackgroundTransparency = 1
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Size = UDim2.new(1, -16, 1, -8)
        lbl.Position = UDim2.fromOffset(8, 4)
        lbl.ZIndex = 8
        lbl.Parent = aboutRow
        page:SetAttribute("_rowY", y + 88)
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(page.CanvasSize.Y.Offset, y + 96))
    end

    do
        local y = page:GetAttribute("_rowY") or 8
        local credit = P.makeRow(page, y)
        P.makeLabel(credit, "Developed by Urban")
        P.makeValueLabel(credit, "with YuleTide", PAL.accent)
        page:SetAttribute("_rowY", y + 44)
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(page.CanvasSize.Y.Offset, y + 52))
    end
end)

safeTab("Visual", function()
    P.registerSubTab("Visual", "ESP", 700)
    P.registerSubTab("Visual", "Radar", 600)
    P.registerSubTab("Visual", "Overlay", 400)

    local esp = makePage("Visual", "ESP")
    P.row(esp, "Enable ESP", { kind = "toggle", key = "espEnabled" })
    P.row(esp, "Max Players", { kind = "slider", key = "espMaxPlayers" })
    P.row(esp, "Box", { kind = "toggle", key = "espBox" })
    P.row(esp, "Fill", { kind = "toggle", key = "espFill" })
    P.row(esp, "Box Thickness", { kind = "slider", key = "espBoxThick" })
    P.row(esp, "Max Distance", { kind = "slider", key = "espMaxDist" })
    P.row(esp, "Fill Alpha", { kind = "slider", key = "espFillAlpha" })
    P.row(esp, "Text Size", { kind = "slider", key = "espTextSize" })
    do
        local y = esp:GetAttribute("_rowY") or 8
        local r = P.makeStackedRow(esp, y)
        P.makeTitleLabel(r, "Health ESP")
        P.makeCaution(r, 'Only works in games with the "Teams" Service')
        P.makeToggle(r, function() return P.C.espHealth end, function(v) P.C.espHealth = v end)
        esp:SetAttribute("_rowY", y + 56)
        esp.CanvasSize = UDim2.new(0, 0, 0, math.max(esp.CanvasSize.Y.Offset, y + 64))
    end
    P.row(esp, "Skeleton", { kind = "toggle", key = "espSkeleton" })
    P.row(esp, "Skeleton Thickness", { kind = "slider", key = "espSkeletonThickness" })
    P.row(esp, "Skeleton Color", { kind = "dropdown", key = "espSkeletonColor", values = { "Box", "Rainbow" } })
    P.row(esp, "Outline", { kind = "toggle", key = "espOutline" })
    P.row(esp, "Outline Color", { kind = "color", key = "espOutlineColor" })
    P.row(esp, "Box Shadow", { kind = "toggle", key = "espBoxShadow" })
    P.row(esp, "Team Color", { kind = "toggle", key = "espTeamColor" })
    P.row(esp, "Enemy Box", { kind = "color", key = "espBoxColor" })
    P.row(esp, "Team Box", { kind = "color", key = "espTeamBoxColor" })
    P.row(esp, "Rainbow Visuals", { kind = "toggle", key = "rainbowVisuals" })
    P.row(esp, "Rainbow Delay", { kind = "slider", key = "rainbowDelay" })

    local radar = makePage("Visual", "Radar")
    P.row(radar, "Enable Radar", { kind = "toggle", key = "radarEnabled" })
    P.row(radar, "Radar Radius", { kind = "slider", key = "radarRadius" })
    P.row(radar, "Radar Size", { kind = "slider", key = "radarSize" })
    P.row(radar, "Radar Dot Color", { kind = "color", key = "radarDotColor" })
    P.row(radar, "Radar Enemy Color", { kind = "color", key = "radarEnemyColor" })
    P.row(radar, "Show Height", { kind = "toggle", key = "radarShowHeight" })
    P.row(radar, "Background Transparent", { kind = "toggle", key = "radarBgTransparent" })

    local ov = makePage("Visual", "Overlay")
    P.row(ov, "Overlay Panel", { kind = "toggle", key = "overlayEnabled" })
    P.row(ov, "Crosshair", { kind = "toggle", key = "crosshairEnabled" })
    P.row(ov, "Crosshair Size", { kind = "slider", key = "crosshairSize" })
    P.row(ov, "Crosshair Color", { kind = "color", key = "crosshairColor" })
    P.row(ov, "Target Panel", { kind = "toggle", key = "targetPanelEnabled" })
    P.row(ov, "Hit Marker", { kind = "toggle", key = "hitMarkerEnabled" })
    P.row(ov, "Status Text", { kind = "toggle", key = "statusDraw" })
end)

safeTab("Aim", function()
    P.registerSubTab("Aim", "Aimbot", 1400)
    P.registerSubTab("Aim", "Checks", 900)
    P.registerSubTab("Aim", "Silent / Spin", 500)
    P.registerSubTab("Aim", "TriggerBot", 900)
    P.registerSubTab("Aim", "Visuals", 400)

    local ab = makePage("Aim", "Aimbot")
    P.row(ab, "Enable Aimbot", { kind = "toggle", key = "aimToggled" })
    P.row(ab, "Aim Mode", { kind = "dropdown", key = "aimMode", values = { "Camera", "Mouse", "Silent" } })
    P.row(ab, "Aim Part", { kind = "dropdown", key = "aimPart", values = { "Head", "UpperTorso", "HumanoidRootPart" } })
    P.row(ab, "Smart Aimbot", { kind = "toggle", key = "smartAimbot" })
    P.row(ab, "Random Aim Part", { kind = "toggle", key = "aimRandomPart" })
    P.row(ab, "Aim Locked Part", { kind = "toggle", key = "aimLockedPart" })
    P.row(ab, "Aim Radius Sort", { kind = "dropdown", key = "aimRadiusSort", values = { "Angle", "Distance" } })
    P.row(ab, "Smoothness", { kind = "slider", key = "smoothness" })
    P.row(ab, "Predictor Multiplier", { kind = "slider", key = "predictorMult" })
    P.row(ab, "FOV", { kind = "slider", key = "fov" })
    P.row(ab, "Update Interval", { kind = "slider", key = "updateInterval" })
    P.row(ab, "Aim Time Limit", { kind = "slider", key = "aimTimeLimit" })
    P.row(ab, "Aim Velocity Prediction", { kind = "slider", key = "aimVelocityPred" })
    P.row(ab, "Activation", { kind = "dropdown", key = "aimActivation", values = { "Toggle", "Hold" } })
    P.row(ab, "Aim Key", { kind = "keybind", key = "keyAim" })
    P.row(ab, "One Press", { kind = "toggle", key = "onePressAim" })
    P.row(ab, "Off After Kill", { kind = "toggle", key = "offAfterKill" })
    P.row(ab, "Auto Scope", { kind = "toggle", key = "aimAutoScope" })
    P.row(ab, "Respect FOV Ring", { kind = "toggle", key = "aimRespectFovRing" })
    P.row(ab, "Aim Offset X", { kind = "slider", key = "aimOffsetX" })
    P.row(ab, "Aim Offset Y", { kind = "slider", key = "aimOffsetY" })
    P.row(ab, "Aim Offset Z", { kind = "slider", key = "aimOffsetZ" })
    P.row(ab, "Aim Error X", { kind = "slider", key = "aimErrorX" })
    P.row(ab, "Aim Error Y", { kind = "slider", key = "aimErrorY" })

    local c = makePage("Aim", "Checks")
    P.row(c, "Team Check", { kind = "toggle", key = "teamCheck" })
    P.row(c, "Friend Check", { kind = "toggle", key = "friendCheck" })
    P.row(c, "Alive Check", { kind = "toggle", key = "aliveCheck" })
    P.row(c, "Wall Check", { kind = "toggle", key = "wallCheckAim" })
    P.row(c, "Water Check", { kind = "toggle", key = "waterCheck" })
    P.row(c, "Visibility Check", { kind = "toggle", key = "aimVisibilityCheck" })
    P.row(c, "Only Visible", { kind = "toggle", key = "aimOnlyVisible" })
    P.row(c, "Target All", { kind = "toggle", key = "aimTargetAll" })
    P.row(c, "God Check", { kind = "toggle", key = "godCheck" })
    P.row(c, "Follow Check", { kind = "toggle", key = "followCheck" })
    P.row(c, "Verified Badge", { kind = "toggle", key = "verifiedCheck" })
    P.row(c, "Transparency Check", { kind = "toggle", key = "transparencyCheck" })
    P.row(c, "Magnitude Check", { kind = "toggle", key = "magnitudeCheck" })
    P.row(c, "Ignored Transparency", { kind = "slider", key = "ignoredTransparency" })

    local ss = makePage("Aim", "Silent / Spin")
    P.row(ss, "Silent Aim", { kind = "toggle", key = "silentAim" })
    P.row(ss, "Silent Chance", { kind = "slider", key = "silentChance" })
    P.row(ss, "Spin Bot", { kind = "toggle", key = "spinBot" })
    P.row(ss, "One Press Mode", { kind = "toggle", key = "onePressSpin" })
    P.row(ss, "Spin Key", { kind = "keybind", key = "spinKey" })
    P.row(ss, "Spin Velocity", { kind = "slider", key = "spinVelocity" })
    P.row(ss, "Spin Part", { kind = "dropdown", key = "spinPart", values = { "Head", "UpperTorso", "HumanoidRootPart", "Torso" } })

    local tb = makePage("Aim", "TriggerBot")
    P.row(tb, "Enable Triggerbot", { kind = "toggle", key = "triggerEnabled" })
    P.row(tb, "Trigger Activation", { kind = "dropdown", key = "triggerMode", values = { "Toggle", "Hold" } })
    P.row(tb, "Trigger Key", { kind = "keybind", key = "keyTrigger" })
    P.row(tb, "Trigger Team Mode", { kind = "dropdown", key = "triggerTeamMode", values = { "FFA", "Team-Based", "Everyone" } })
    P.row(tb, "Trigger Delay", { kind = "slider", key = "triggerDelay" })
    P.row(tb, "Trigger Cooldown", { kind = "slider", key = "triggerCooldown" })
    P.row(tb, "Trigger Chance", { kind = "slider", key = "triggerChance" })
    P.row(tb, "Trigger FOV", { kind = "slider", key = "triggerFov" })
    P.row(tb, "Trigger Wall Check", { kind = "toggle", key = "triggerWallCheck" })
    P.row(tb, "Head Only", { kind = "toggle", key = "triggerHeadOnly" })
    P.row(tb, "Trigger Alive Check", { kind = "toggle", key = "triggerAliveCheck" })
    P.row(tb, "Auto Fire Locked", { kind = "toggle", key = "autoFireLocked" })
    P.row(tb, "FOV Ring Visible", { kind = "toggle", key = "trigRingVisible" })
    P.row(tb, "FOV Ring Transparency", { kind = "slider", key = "trigRingTrans" })
    P.row(tb, "FOV Ring Thickness", { kind = "slider", key = "trigRingThick" })
    P.row(tb, "Trigger Ring Color", { kind = "color", key = "trigRingColor" })

    local vis = makePage("Aim", "Visuals")
    P.row(vis, "Aim Random Part", { kind = "toggle", key = "aimRandomPart" })
    P.row(vis, "Aim Part List", { kind = "label", value = table.concat(C.aimPartList or {}, ", ") })
    P.row(vis, "Aim FOV Ring Color", { kind = "color", key = "fovRingColor" })
end)

safeTab("Misc", function()
    local page = makePage("Misc")
    P.row(page, "Status Indicator", { kind = "toggle", key = "statusDraw" })
    P.row(page, "Overlay Panel", { kind = "toggle", key = "overlayEnabled" })
    P.row(page, "Notifications Enabled", { kind = "toggle", key = "notificationsEnabled" })
    P.row(page, "Reset Panel", { kind = "button", text = "Reset", fn = function()
        C.panelX = 80; C.panelY = 60
        if P.frame then P.frame.Position = UDim2.fromOffset(80, 60) end
    end })
end)

safeTab("Admin", function()
    P.registerSubTab("Admin", "Movement", 700)
    P.registerSubTab("Admin", "Admin Commands", 700)
    P.registerSubTab("Admin", "Teleport", 700)

    local mv = makePage("Admin", "Movement")
    P.row(mv, "Flight", { kind = "toggle", key = "flyEnabled" })
    P.row(mv, "Fly Speed", { kind = "slider", key = "flySpeed" })
    P.row(mv, "Speed Enhancement", { kind = "toggle", key = "speedEnabled" })
    P.row(mv, "Speed Value", { kind = "slider", key = "speedValue" })
    P.row(mv, "Higher Jump", { kind = "toggle", key = "jumpEnabled" })
    P.row(mv, "Jump Power", { kind = "slider", key = "jumpValue" })
    P.row(mv, "Click to Teleport", { kind = "toggle", key = "clickTPEnabled" })

    local ad = makePage("Admin", "Admin Commands")
    P.row(ad, "God", { kind = "button", text = "Run", fn = function()
        local ch = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
    end })
    P.row(ad, "Infinite Jump", { kind = "button", text = "Run", fn = function()
        P.Connections[#P.Connections+1] = UserInputService.JumpRequest:Connect(function()
            local ch = LocalPlayer.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end })
    P.row(ad, "NoClip", { kind = "button", text = "Run", fn = function()
        P._noclipOn = not P._noclipOn
        if P._noclipOn then
            P._noclipConn = RunService.Stepped:Connect(function()
                local ch = LocalPlayer.Character
                if ch then for _, p in ipairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end end
            end)
        else
            if P._noclipConn then P._noclipConn:Disconnect(); P._noclipConn = nil end
        end
    end })
    P.row(ad, "Full Bright", { kind = "button", text = "Run", fn = function()
        local l = game:GetService("Lighting")
        l.Ambient = Color3.fromRGB(255,255,255)
        l.OutdoorAmbient = Color3.fromRGB(255,255,255)
        l.Brightness = 2
    end })
    P.row(ad, "Anti-AFK", { kind = "button", text = "Run", fn = function()
        local vu = game:GetService("VirtualUser")
        P.Connections[#P.Connections+1] = LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end })
    P.row(ad, "Freeze", { kind = "button", text = "Run", fn = function()
        local ch = LocalPlayer.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = not root.Anchored end
    end })
    P.row(ad, "Server Hop", { kind = "button", text = "Run", fn = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local data = game:GetService("HttpService"):JSONDecode(req)
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end)
    end })
    P.row(ad, "Rejoin", { kind = "button", text = "Run", fn = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end })
    P.row(ad, "Reset Character", { kind = "button", text = "Run", fn = function()
        local ch = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end })
    P.row(ad, "Reset WalkSpeed", { kind = "button", text = "Run", fn = function()
        local ch = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end })
    P.row(ad, "Reset Gravity", { kind = "button", text = "Run", fn = function()
        if Workspace then Workspace.Gravity = 196.2 end
    end })

    local tp = makePage("Admin", "Teleport")
    do
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then playerNames[#playerNames+1] = p.Name end
        end
        if #playerNames == 0 then playerNames = { "(no players)" } end
        P.row(tp, "Teleport To Player", { kind = "dropdown", key = "tpTarget", values = playerNames, onChange = function(name)
            P.teleportToPlayer(name)
        end })
    end
    P.row(tp, "Server Hop", { kind = "button", text = "Run", fn = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local data = game:GetService("HttpService"):JSONDecode(req)
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end)
    end })
end)

safeTab("Teleport", function()
    local page = makePage("Teleport")
    P.row(page, "Server Hop", { kind = "button", text = "Run", fn = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local data = game:GetService("HttpService"):JSONDecode(req)
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end)
    end })
    P.row(page, "Rejoin", { kind = "button", text = "Run", fn = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end })
end)

safeTab("Configs", function()
    local page = makePage("Configs")
    P.row(page, "Save Config", { kind = "button", text = "Save", fn = function()
        P.saveSettings()
        if P.saveConfigToFile then P.saveConfigToFile() end
    end })
    P.row(page, "Load Config", { kind = "button", text = "Load", fn = function()
        if P.loadConfigFromFile then P.loadConfigFromFile() end
        if P.refreshTabs then P.refreshTabs() end
    end })
    P.row(page, "Delete Config", { kind = "button", text = "Delete", fn = function()
        if delfile and isfile and isfile(P.CONFIG_FILE) then pcall(delfile, P.CONFIG_FILE) end
    end })
    P.row(page, "Export Config", { kind = "button", text = "Export", fn = function()
        if P.saveConfigToFile then P.saveConfigToFile() end
    end })
    P.row(page, "Import Config", { kind = "button", text = "Import", fn = function()
        if P.loadConfigFromFile then P.loadConfigFromFile() end
        if P.refreshTabs then P.refreshTabs() end
    end })
    P.row(page, "Auto-save on exit", { kind = "toggle", key = "autoSave" })
    P.row(page, "Save Named", { kind = "button", text = "Save", fn = function()
        if P.saveNamedConfig then P.saveNamedConfig("slot1") end
    end })
    P.row(page, "Load Named", { kind = "button", text = "Load", fn = function()
        if P.loadNamedConfig then P.loadNamedConfig("slot1") end
        if P.refreshTabs then P.refreshTabs() end
    end })
end)

safeTab("Settings", function()
    local page = makePage("Settings")
    P.section(page, "Interface")
    P.row(page, "Notifications", { kind = "toggle", key = "notificationsEnabled" })
    P.row(page, "Streamer Key", { kind = "keybind", key = "keyStreamer" })
    P.row(page, "Unload Key", { kind = "keybind", key = "keyUnload" })
    P.row(page, "Menu Key", { kind = "keybind", key = "keyMenu" })
    P.section(page, "Frame Handling")
    P.row(page, "Rendering Mode", { kind = "dropdown", key = "renderMode", values = { "RenderStepped", "Heartbeat", "Stepped" } })
    P.section(page, "Saving")
    P.row(page, "Auto Save", { kind = "toggle", key = "autoSave" })
    P.section(page, "Credits")
    P.row(page, "Version", { kind = "label", value = "v" .. tostring(P.PEGASUS_VERSION) .. " " .. tostring(P.PEGASUS_SUBVERSION) })
    P.row(page, "Developer", { kind = "label", value = "Urban" })
    P.row(page, "Tester", { kind = "label", value = "YuleTide" })
end)

if not C.autoSave then C.autoSave = false end
if not C.tpTarget then C.tpTarget = "(no players)" end

P.console("[Pegasus] tabs built: 8")
    ]=])

    -- runtime chunk ---------------------------------------------------------
    runChunk("pegasus.runtime", [=[
local G = getgenv()
local P = G._pegasus
local Players, UserInputService, RunService = P.Players, P.UserInputService, P.RunService
local LocalPlayer = P.LocalPlayer
local PAL, C = P.PAL, P.C
local mk, setProp = P.mk, P.setProp

local function safeMk(kind)
    local ok, o = pcall(P.mk, kind)
    if not ok or not o then return nil end
    return o
end

local function getCam()
    local ok, cam = pcall(function() return Workspace.CurrentCamera end)
    if not ok or not cam then return nil end
    return cam
end

local function gameValid()
    return pcall(function() return game.PlaceId end)
end

P.trigRing = safeMk("Circle")
if P.trigRing then
    setProp(P.trigRing, "Filled", false)
    setProp(P.trigRing, "Color", C.trigRingColor)
    setProp(P.trigRing, "Transparency", C.trigRingTrans)
    setProp(P.trigRing, "Thickness", C.trigRingThick)
    setProp(P.trigRing, "Visible", false)
    setProp(P.trigRing, "NumSides", 64)
end

P.statusDraw = safeMk("Text")
if P.statusDraw then
    setProp(P.statusDraw, "Size", 12)
    setProp(P.statusDraw, "Color", PAL.text)
    setProp(P.statusDraw, "Outline", true)
    setProp(P.statusDraw, "OutlineColor", PAL.bg)
    setProp(P.statusDraw, "Center", false)
    setProp(P.statusDraw, "Position", Vector2.new(12, 12))
    setProp(P.statusDraw, "Visible", false)
end

P.fovRing = safeMk("Circle")
if P.fovRing then
    setProp(P.fovRing, "Filled", false)
    setProp(P.fovRing, "Color", C.fovRingColor)
    setProp(P.fovRing, "Transparency", 0.5)
    setProp(P.fovRing, "Thickness", 1)
    setProp(P.fovRing, "Visible", false)
    setProp(P.fovRing, "NumSides", 64)
end

P.crosshair = {
    up = safeMk("Line"), down = safeMk("Line"),
    left = safeMk("Line"), right = safeMk("Line"),
}
for _, l in pairs(P.crosshair) do
    if l then
        setProp(l, "Thickness", 1)
        setProp(l, "Visible", false)
    end
end

P.hitMarker = {
    a = safeMk("Line"), b = safeMk("Line"),
    t = 0,
}
if P.hitMarker.a then setProp(P.hitMarker.a, "Thickness", 2) end
if P.hitMarker.b then setProp(P.hitMarker.b, "Thickness", 2) end

P.targetPanel = {
    name = safeMk("Text"),
    dist = safeMk("Text"),
    hp = safeMk("Text"),
}
if P.targetPanel.name then
    setProp(P.targetPanel.name, "Size", 13)
    setProp(P.targetPanel.name, "Color", PAL.accent)
    setProp(P.targetPanel.name, "Outline", true)
    setProp(P.targetPanel.name, "OutlineColor", PAL.bg)
    setProp(P.targetPanel.name, "Center", false)
    setProp(P.targetPanel.name, "Visible", false)
end
if P.targetPanel.dist then
    setProp(P.targetPanel.dist, "Size", 11)
    setProp(P.targetPanel.dist, "Color", PAL.textDim)
    setProp(P.targetPanel.dist, "Outline", true)
    setProp(P.targetPanel.dist, "OutlineColor", PAL.bg)
    setProp(P.targetPanel.dist, "Center", false)
    setProp(P.targetPanel.dist, "Visible", false)
end
if P.targetPanel.hp then
    setProp(P.targetPanel.hp, "Size", 11)
    setProp(P.targetPanel.hp, "Color", PAL.textDim)
    setProp(P.targetPanel.hp, "Outline", true)
    setProp(P.targetPanel.hp, "OutlineColor", PAL.bg)
    setProp(P.targetPanel.hp, "Center", false)
    setProp(P.targetPanel.hp, "Visible", false)
end

P.menuReady = false

pcall(P.buildOverlayPanel)

P.buildRadar = function()
    if P.radar then return P.radar end
    local r = {
        circle = safeMk("Circle"),
        crossX = safeMk("Line"),
        crossY = safeMk("Line"),
        sweep = safeMk("Line"),
        sweepAngle = 0,
        dots = {},
    }
    if r.circle then
        setProp(r.circle, "Filled", false)
        setProp(r.circle, "Color", PAL.outline)
        setProp(r.circle, "Transparency", 0.35)
        setProp(r.circle, "Thickness", 1)
        setProp(r.circle, "NumSides", 48)
        setProp(r.circle, "Visible", false)
    end
    if r.crossX then
        setProp(r.crossX, "Color", PAL.outline)
        setProp(r.crossX, "Transparency", 0.5)
        setProp(r.crossX, "Thickness", 1)
        setProp(r.crossX, "Visible", false)
    end
    if r.crossY then
        setProp(r.crossY, "Color", PAL.outline)
        setProp(r.crossY, "Transparency", 0.5)
        setProp(r.crossY, "Thickness", 1)
        setProp(r.crossY, "Visible", false)
    end
    if r.sweep then
        setProp(r.sweep, "Color", PAL.accent)
        setProp(r.sweep, "Transparency", 0.7)
        setProp(r.sweep, "Thickness", 1)
        setProp(r.sweep, "Visible", false)
    end
    P.radar = r
    return r
end

P.hideRadar = function()
    local r = P.radar
    if not r then return end
    if r.circle then setProp(r.circle, "Visible", false) end
    if r.crossX then setProp(r.crossX, "Visible", false) end
    if r.crossY then setProp(r.crossY, "Visible", false) end
    if r.sweep then setProp(r.sweep, "Visible", false) end
    for _, entry in pairs(r.dots) do
        if entry.dot then setProp(entry.dot, "Visible", false) end
        if entry.name then setProp(entry.name, "Visible", false) end
    end
end

P.updateRadar = function(dt)
    if not P.menuReady or not C.radarEnabled or C.streamerMode then
        P.hideRadar()
        return
    end
    local r = P.buildRadar()
    local cam = getCam()
    if not cam or not LocalPlayer.Character then P.hideRadar(); return end
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then P.hideRadar(); return end

    local radarSize = C.radarSize or 180
    local radius = radarSize * 0.5
    local center = Vector2.new(40 + radius, 40 + radius)
    local camLook = cam.CFrame.LookVector
    local yaw = math.atan2(camLook.X, camLook.Z)

    if r.circle then
        setProp(r.circle, "Position", center)
        setProp(r.circle, "Radius", radius)
        setProp(r.circle, "Visible", true)
    end
    if r.crossX then
        setProp(r.crossX, "From", Vector2.new(center.X - radius, center.Y))
        setProp(r.crossX, "To", Vector2.new(center.X + radius, center.Y))
        setProp(r.crossX, "Visible", true)
    end
    if r.crossY then
        setProp(r.crossY, "From", Vector2.new(center.X, center.Y - radius))
        setProp(r.crossY, "To", Vector2.new(center.X, center.Y + radius))
        setProp(r.crossY, "Visible", true)
    end
    if r.sweep and C.radarSweep then
        r.sweepAngle = ((r.sweepAngle or 0) + dt * 2.5) % (math.pi * 2)
        local ex = center.X + math.cos(r.sweepAngle) * radius
        local ey = center.Y + math.sin(r.sweepAngle) * radius
        setProp(r.sweep, "From", center)
        setProp(r.sweep, "To", Vector2.new(ex, ey))
        setProp(r.sweep, "Visible", true)
    elseif r.sweep then
        setProp(r.sweep, "Visible", false)
    end

    local maxRange = C.radarRadius or 300
    local plotted = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not P.sameTeam(p, LocalPlayer) then
            local ch = p.Character
            if ch then
                local root = ch:FindFirstChild("HumanoidRootPart")
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local delta = root.Position - localRoot.Position
                    local planarDist = Vector2.new(delta.X, delta.Z).Magnitude
                    if planarDist <= maxRange then
                        local cosY = math.cos(-yaw)
                        local sinY = math.sin(-yaw)
                        local rx = delta.X * cosY - delta.Z * sinY
                        local rz = delta.X * sinY + delta.Z * cosY
                        local scale = radius / maxRange
                        local px = center.X + rx * scale
                        local py = center.Y + rz * scale
                        plotted[p] = { pos = Vector2.new(px, py), dy = delta.Y }
                    end
                end
            end
        end
    end

    for p, entry in pairs(r.dots) do
        if not plotted[p] then
            if entry.dot then setProp(entry.dot, "Visible", false) end
            if entry.name then setProp(entry.name, "Visible", false) end
        end
    end

    local dotColor = C.radarDotColor or PAL.accent
    local enemyColor = C.radarEnemyColor or Color3.fromRGB(255, 80, 80)
    for p, info in pairs(plotted) do
        local entry = r.dots[p]
        if not entry then
            local dot = safeMk("Circle")
            if dot then
                setProp(dot, "Filled", true)
                setProp(dot, "NumSides", 16)
                setProp(dot, "Radius", 3)
            end
            local nameText = safeMk("Text")
            if nameText then
                setProp(nameText, "Size", 10)
                setProp(nameText, "Center", true)
                setProp(nameText, "Outline", true)
                setProp(nameText, "OutlineColor", PAL.bg)
                setProp(nameText, "Color", PAL.text)
            end
            entry = { dot = dot, name = nameText }
            r.dots[p] = entry
        end
        local isEnemy = P.triggerIsEnemy and P.triggerIsEnemy(p) or true
        local col = isEnemy and enemyColor or dotColor
        if entry.dot then
            setProp(entry.dot, "Position", info.pos)
            setProp(entry.dot, "Color", col)
            local dy = info.dy or 0
            local dotRad = 3
            if C.radarShowHeight then
                dotRad = math.clamp(3 + dy * 0.08, 1.5, 7)
            end
            setProp(entry.dot, "Radius", dotRad)
            setProp(entry.dot, "Visible", true)
        end
        if entry.name then
            setProp(entry.name, "Position", Vector2.new(info.pos.X, info.pos.Y + 6))
            setProp(entry.name, "Text", p.DisplayName or p.Name)
            setProp(entry.name, "Color", col)
            setProp(entry.name, "Visible", true)
        end
    end
end

local renderAccum = 0
local statusAccum = 0
local fpsAccum, fpsN = 0, 0

local function buildStatusText()
    local parts = {}
    if C.aimToggled then parts[#parts+1] = "aim" end
    if C.silentAim then parts[#parts+1] = "silent" end
    if C.triggerEnabled then parts[#parts+1] = "trig" end
    if C.spinBot then parts[#parts+1] = "spin" end
    if C.espEnabled and not C.streamerMode then parts[#parts+1] = "esp" end
    if C.radarEnabled and not C.streamerMode then parts[#parts+1] = "radar" end
    if C.flyEnabled then parts[#parts+1] = "fly" end
    if C.speedEnabled then parts[#parts+1] = "speed" end
    if C.jumpEnabled then parts[#parts+1] = "jump" end
    if C.streamerMode then return "streamer" end
    if #parts == 0 then return nil end
    return table.concat(parts, " | ")
end

local function renderTick(dt)
    if P.shuttingDown then return end
    if not gameValid() then
        if P.Connections then
            for _, c in ipairs(P.Connections) do pcall(function() c:Disconnect() end) end
            P.Connections = {}
        end
        return
    end
    P.refreshViewport()
    renderAccum = renderAccum + dt
    local interval = math.max(C.updateInterval or 1, 1) / 60
    if renderAccum >= interval then
        renderAccum = 0
        if P.updateESP then pcall(P.updateESP) end
        if P.updateAimbot then pcall(P.updateAimbot, dt) end
        if P.updateRadar then pcall(P.updateRadar, dt) end
    end
    if C.rainbowVisuals then
        P._rainbowHue = (P._rainbowHue + dt / math.max(C.rainbowDelay or 5, 0.01)) % 1
    end
    if C.triggerEnabled and P.triggerStep then
        pcall(P.triggerStep)
    end
    if P.trigRing then
        local center = P.screenCenter()
        local radius = C.triggerFov * 0.5
        setProp(P.trigRing, "Position", center)
        setProp(P.trigRing, "Radius", radius)
        setProp(P.trigRing, "Color", P.rainbow and P.rainbow() or C.trigRingColor)
        setProp(P.trigRing, "Transparency", C.trigRingTrans)
        setProp(P.trigRing, "Thickness", C.trigRingThick)
        setProp(P.trigRing, "Visible", P.menuReady and C.trigRingVisible and C.triggerEnabled and not C.streamerMode)
    end
    if P.fovRing then
        local center = P.screenCenter()
        local radius = C.fov * 0.5
        setProp(P.fovRing, "Position", center)
        setProp(P.fovRing, "Radius", radius)
        setProp(P.fovRing, "Color", P.rainbow and P.rainbow() or C.fovRingColor)
        setProp(P.fovRing, "Visible", P.menuReady and C.aimToggled and C.aimMode ~= "Silent" and not C.streamerMode)
    end
    statusAccum = statusAccum + dt
    if statusAccum >= 0.25 then
        statusAccum = 0
        local txt = buildStatusText()
        local pingStr = ""
        do
            local ok, v = pcall(function()
                return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok and v then pingStr = string.format("%dms", math.floor(v + 0.5)) end
        end
        if P.statusDraw then
            if P.menuReady and txt and C.statusDraw and not C.streamerMode then
                setProp(P.statusDraw, "Text", "[Pegasus] " .. txt .. (pingStr ~= "" and (" · " .. pingStr) or ""))
                setProp(P.statusDraw, "Visible", true)
            else
                setProp(P.statusDraw, "Visible", false)
            end
        end
        fpsAccum = fpsAccum + (1 / math.max(dt, 1/240))
        fpsN = fpsN + 1
        local fpsAvg = math.floor((fpsAccum / math.max(fpsN, 1)) + 0.5)
        fpsAccum, fpsN = 0, 0
        if P.overlayPanel and P.overlayPanel.frame then
            if C.overlayEnabled and not C.streamerMode then
                P.overlayPanel.frame.Visible = true
                P.overlayPanel.user.Text = LocalPlayer.DisplayName or LocalPlayer.Name
                P.overlayPanel.fps.Text = string.format("%d FPS", fpsAvg)
                P.overlayPanel.status.Text = txt or "idle"
                P.overlayPanel.conn.Text = pingStr ~= "" and ("Ping " .. pingStr) or ""
            else
                P.overlayPanel.frame.Visible = false
            end
        end
    end
    if P.crosshair and P.crosshair.up and P.menuReady and C.crosshairEnabled then
        local c = P.screenCenter()
        local n = C.crosshairSize or 8
        local col = C.crosshairColor or PAL.accent
        setProp(P.crosshair.up, "From", Vector2.new(c.X, c.Y - 4))
        setProp(P.crosshair.up, "To", Vector2.new(c.X, c.Y - 4 - n))
        setProp(P.crosshair.up, "Color", col)
        setProp(P.crosshair.up, "Visible", true)
        setProp(P.crosshair.down, "From", Vector2.new(c.X, c.Y + 4))
        setProp(P.crosshair.down, "To", Vector2.new(c.X, c.Y + 4 + n))
        setProp(P.crosshair.down, "Color", col)
        setProp(P.crosshair.down, "Visible", true)
        setProp(P.crosshair.left, "From", Vector2.new(c.X - 4, c.Y))
        setProp(P.crosshair.left, "To", Vector2.new(c.X - 4 - n, c.Y))
        setProp(P.crosshair.left, "Color", col)
        setProp(P.crosshair.left, "Visible", true)
        setProp(P.crosshair.right, "From", Vector2.new(c.X + 4, c.Y))
        setProp(P.crosshair.right, "To", Vector2.new(c.X + 4 + n, c.Y))
        setProp(P.crosshair.right, "Color", col)
        setProp(P.crosshair.right, "Visible", true)
    elseif P.crosshair and P.crosshair.up then
        for _, l in pairs(P.crosshair) do setProp(l, "Visible", false) end
    end
    if P.hitMarker and P.hitMarker.a then
        if C.hitMarkerEnabled and P.hitMarker.t > 0 then
            P.hitMarker.t = P.hitMarker.t - dt
            local c = P.screenCenter()
            local s = 6
            setProp(P.hitMarker.a, "From", Vector2.new(c.X - s, c.Y - s))
            setProp(P.hitMarker.a, "To", Vector2.new(c.X + s, c.Y + s))
            setProp(P.hitMarker.a, "Color", PAL.danger)
            setProp(P.hitMarker.a, "Visible", true)
            setProp(P.hitMarker.b, "From", Vector2.new(c.X - s, c.Y + s))
            setProp(P.hitMarker.b, "To", Vector2.new(c.X + s, c.Y - s))
            setProp(P.hitMarker.b, "Color", PAL.danger)
            setProp(P.hitMarker.b, "Visible", true)
        else
            setProp(P.hitMarker.a, "Visible", false)
            setProp(P.hitMarker.b, "Visible", false)
        end
    end
    if P.targetPanel and P.targetPanel.name and P.menuReady and not C.streamerMode and C.targetPanelEnabled then
        local s = P.aimState
        local show = s and s.target and s.targetChar and C.aimToggled
        if show then
            local root = s.targetChar:FindFirstChild("HumanoidRootPart")
            local hum = s.targetChar:FindFirstChildOfClass("Humanoid")
            local cam = getCam()
            if root and hum and cam then
                local dist = (root.Position - cam.CFrame.Position).Magnitude
                local px = P.cachedViewport.X * 0.5 + 140
                local py = P.cachedViewport.Y * 0.5 - 40
                setProp(P.targetPanel.name, "Position", Vector2.new(px, py))
                setProp(P.targetPanel.name, "Text", s.target.DisplayName or s.target.Name)
                setProp(P.targetPanel.name, "Visible", true)
                setProp(P.targetPanel.dist, "Position", Vector2.new(px, py + 16))
                setProp(P.targetPanel.dist, "Text", string.format("%dm", math.floor(dist + 0.5)))
                setProp(P.targetPanel.dist, "Visible", true)
                setProp(P.targetPanel.hp, "Position", Vector2.new(px, py + 30))
                setProp(P.targetPanel.hp, "Text", string.format("HP %d", math.floor(hum.Health + 0.5)))
                setProp(P.targetPanel.hp, "Visible", true)
            else
                setProp(P.targetPanel.name, "Visible", false)
                setProp(P.targetPanel.dist, "Visible", false)
                setProp(P.targetPanel.hp, "Visible", false)
            end
        else
            setProp(P.targetPanel.name, "Visible", false)
            setProp(P.targetPanel.dist, "Visible", false)
            setProp(P.targetPanel.hp, "Visible", false)
        end
    end
end

if RunService and RunService.RenderStepped then
    P.Connections[#P.Connections+1] = RunService.RenderStepped:Connect(function(dt)
        pcall(renderTick, dt)
    end)
end

if RunService and RunService.Heartbeat then
    P.Connections[#P.Connections+1] = RunService.Heartbeat:Connect(function()
        if C.spinBot and P.spinTick then pcall(P.spinTick) end
    end)
end

P.Connections[#P.Connections+1] = UserInputService.InputBegan:Connect(function(input, gp)
    if P.keybindCapture and input.UserInputType == Enum.UserInputType.Keyboard then
        local name = P.KEYCODE_TO_NAME[input.KeyCode]
        if name then
            P.C[P.keybindCapture] = name
            for _, entry in ipairs(P.themedDropdowns) do
                if entry.key == P.keybindCapture and entry.btn then
                    entry.btn.Text = name
                end
            end
            P.keybindCapture = nil
            if P.saveSettings then P.saveSettings() end
        end
        return
    end
    if gp then return end
    if P.colorPickerOpen then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local kc = input.KeyCode
        local function isKey(name)
            local code = P.KEYBIND_MAP[name]
            return code ~= nil and code == kc
        end
        if isKey(C.keyUnload) then
            if P.closeMenu then pcall(P.closeMenu) end
            return
        end
        if isKey(C.keyStreamer) then
            C.streamerMode = not C.streamerMode
            if C.streamerMode and P.hideDrawingAll then pcall(P.hideDrawingAll) end
            if P.refreshTabs then pcall(P.refreshTabs) end
            return
        end
        if isKey(C.keyEsp) then
            C.espEnabled = not C.espEnabled
            if not C.espEnabled and P.hideDrawingAll then pcall(P.hideDrawingAll) end
            if P.refreshTabs then pcall(P.refreshTabs) end
            if P.saveSettings then P.saveSettings() end
            return
        end
        if isKey(C.keyAim) then
            if C.aimActivation == "Hold" then
                C.aimHeldKey = true
            else
                C.aimToggled = not C.aimToggled
                if P.refreshTabs then pcall(P.refreshTabs) end
                if P.saveSettings then P.saveSettings() end
            end
            return
        end
        if isKey(C.keyTrigger) then
            if C.triggerMode == "Hold" then
                C.triggerHeldKey = true
            else
                C.triggerEnabled = not C.triggerEnabled
                if P.refreshTabs then pcall(P.refreshTabs) end
                if P.saveSettings then P.saveSettings() end
            end
            return
        end
        if C.spinKey and isKey(C.spinKey) then
            C.spinBot = not C.spinBot
            if P.setSpin then pcall(P.setSpin, C.spinBot) end
            if P.refreshTabs then pcall(P.refreshTabs) end
            return
        end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then return end
end)

P.menuToggleConn = UserInputService.InputBegan:Connect(function(input, gp)
    if P.shuttingDown then return end
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if P.keybindCapture then return end
    if P.colorPickerOpen then return end
    local code = P.KEYBIND_MAP[C.keyMenu]
    if code == nil then return end
    if input.KeyCode ~= code then return end
    local now = tick()
    if now - (C._lastMenuToggle or 0) <= 0.3 then return end
    C._lastMenuToggle = now
    if not P.gui then return end
    P.gui.Enabled = not P.gui.Enabled
    if P.gui.Enabled and P.dismissToast then P.dismissToast() end
end)

P.Connections[#P.Connections+1] = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode
    if P.KEYBIND_MAP[C.keyAim] == kc and C.aimActivation == "Hold" then
        C.aimHeldKey = false
    end
    if P.KEYBIND_MAP[C.keyTrigger] == kc and C.triggerMode == "Hold" then
        C.triggerHeldKey = false
    end
end)

task.spawn(function()
    task.wait(0.5)
    if C.flyEnabled and P.setFly then pcall(P.setFly, true) end
    if C.speedEnabled and P.setSpeed then pcall(P.setSpeed, true) end
    if C.jumpEnabled and P.setJump then pcall(P.setJump, true) end
    if C.clickTPEnabled and P.setClickTP then pcall(P.setClickTP, true) end
    if C.spinBot and P.setSpin then pcall(P.setSpin, true) end
end)

pcall(function() P.installSilentAim() end)

if P.refreshTabs then pcall(P.refreshTabs) end
P.console("[Pegasus] loaded v" .. P.PEGASUS_VERSION .. " " .. P.PEGASUS_SUBVERSION)
P.console("[Pegasus] tabs=" .. tostring(#P.sideItems) .. " drawings=" .. tostring(P.drawingCount))

if P.toastGui then P.toastGui.Enabled = true end
if P.notifyGui then P.notifyGui.Enabled = true end

local function revealMenu()
    P.menuReady = true
    if P.gui then P.gui.Enabled = true end
    if P.notify then
        pcall(P.notify, "Pegasus loaded", "v" .. tostring(P.PEGASUS_VERSION), "success")
    end
end

if P.loadingGui then
    task.spawn(function()
        task.wait(8.6)
        if P.loadingGui and P.loadingGui.Parent then
            pcall(function()
                for _, d in ipairs(P.loadingGui:GetDescendants()) do
                    if d:IsA("Frame") then
                        P.TweenService:Create(d, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
                    elseif d:IsA("TextLabel") then
                        P.TweenService:Create(d, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
                    elseif d:IsA("ImageLabel") then
                        P.TweenService:Create(d, TweenInfo.new(0.35), { ImageTransparency = 1 }):Play()
                    elseif d:IsA("UIStroke") then
                        P.TweenService:Create(d, TweenInfo.new(0.35), { Transparency = 1 }):Play()
                    end
                end
            end)
            task.wait(0.45)
            pcall(function() P.loadingGui:Destroy() end)
            P.loadingGui = nil
        end
        revealMenu()
    end)
else
    revealMenu()
end
    ]=])

end

local ok, err = xpcall(main, function(e) return e .. "\n" .. debug.traceback() end)
if not ok then
    if rconsoleprint then rconsoleprint("[Pegasus] FATAL: " .. tostring(err) .. "\n") end
    if warn then warn("[Pegasus] FATAL: " .. tostring(err)) end
    if print then print("[Pegasus] FATAL: " .. tostring(err)) end
    pcall(function()
        local s = tostring(err)
        local line = s:match(":%d+:")
        if rconsoleprint and line then rconsoleprint("[Pegasus] failing line " .. line .. "\n") end
    end)
end
