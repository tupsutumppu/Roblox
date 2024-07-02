-- Gunfight Arena | Created by #tupsutumppu | 26.3.2024
local PLAYERS = cloneref(game:GetService("Players"));
local REPLICATED_STORAGE = cloneref(game:GetService("ReplicatedStorage"));
local RUN_SERVICE = cloneref(game:GetService("RunService"));

local actors = getactors();
local id, settingsChannel = create_comm_channel();
local camera = cloneref(workspace.CurrentCamera);
local localPlayer = PLAYERS.LocalPlayer;

local cheat_settings = {
    silentAim = {
        enabled = false;
        visibilityCheck = false;
    };

    fovCircle = {
        enabled = true;
        sides = 64;
        color = Color3.fromRGB(255, 255, 255);
        transparency = 1;
        radius = 100;
        thickness = 2;
        filled = false
    };
}

run_on_actor(actors[1], [[
    local PLAYERS = cloneref(game:GetService("Players"));

    local localPlayer = PLAYERS.LocalPlayer;
    local camera = cloneref(workspace.CurrentCamera);
    local pendingBTable;

    local settingsChannel = ...;
    settingsChannel = get_comm_channel(settingsChannel);

    local cheat_settings = {
        silentAim = {
            enabled = false;
            visibilityCheck = false;
        };
        fovCircle = {
            radius = 100;
        }
    };

    settingsChannel.Event:Connect(function(method, tbl, key, value)
        if method == "set" then
            pcall(function()
                local setting = cheat_settings[tbl];
    
                if setting then
                    setting[key] = value;
                end
            end);
        end
    end);

    for k, v in pairs(getgc()) do
        if typeof(v) == "function" and islclosure(v) then
            local info = debug.getinfo(v);

            if info.name == "TracerCalc" then
                pendingBTable = debug.getupvalue(v, 1);
            end
        end
    end

    local function is_visible(character)
        local origin = camera.CFrame.Position;
        local destination = character:GetPivot().Position;
        local direction = destination - origin;
        local params = RaycastParams.new();

        params.FilterDescendantsInstances = {camera, localPlayer.Character};
        params.FilterType = Enum.RaycastFilterType.Exclude;
        params.IgnoreWater = true;
        result = workspace:Raycast(origin, direction, params);

        if result and result.Instance and result.Instance:IsDescendantOf(character) then
            return true;
        end

        return false;
    end

    local function get_closest()
        local closest = nil;
        local maxDist = math.huge;

        for _, player in pairs(PLAYERS:GetPlayers()) do

            if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character then
                local charPos = player.Character:GetPivot().Position;
                local charPosV2, onScreen = camera:WorldToViewportPoint(charPos);

                if onScreen then
                    local distance = (Vector2.new(charPosV2.X, charPosV2.Y) - (camera.ViewportSize / 2)).Magnitude;

                    if distance < cheat_settings.fovCircle.radius and (not cheat_settings.silentAim.visibilityCheck or is_visible(player.Character)) then
                        distance = (camera.CFrame.Position - charPos).Magnitude;

                        if distance < maxDist then
                            maxDist = distance;
                            closest = player.Character;
                        end
                    end
                end
            end
        end

        if closest then
            return closest;
        end

        return nil;
    end

    setrawmetatable(pendingBTable, {
        __newindex = function(tbl, key, value)

            if cheat_settings.silentAim.enabled then
                if not rawget(tbl, key) and compareinstances(rawget(value, "Shooter"), localPlayer) then
                    local oldStart = rawget(value, "start");
                    local closest = get_closest();
                    rawset(value, "vel", 99999)
    
                    if closest and oldStart and closest:FindFirstChild("Head") then
                        local newCFrame = CFrame.lookAt(oldStart.Position, closest.Head.CFrame.Position);
                        rawset(value, "start", newCFrame);
                    end
                end
            end

            return rawset(tbl, key, value);
        end
    });
]])

local circle = Drawing.new("Circle");
circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);

RUN_SERVICE.Heartbeat:Connect(function()
    circle.NumSides = cheat_settings.fovCircle.sides;
    circle.Color = cheat_settings.fovCircle.color;
    circle.Transparency = cheat_settings.fovCircle.transparency;
    circle.Radius = cheat_settings.fovCircle.radius;
    circle.Filled = cheat_settings.fovCircle.filled;
    circle.Visible = cheat_settings.fovCircle.enabled;
    circle.Thickness = cheat_settings.fovCircle.thickness;
end);

-- ESP Library 
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Sirius/request/library/esp/esp.lua'), true))();
espLib.options.teamCheck = true;

-- UI Lib (Linoria)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/';
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))();
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))();

local Window = Library:CreateWindow({
    Title = "Gunfight Arena | made by #tupsutumppu",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
});

local tabs = {
    Combat = Window:AddTab("Combat");
    Esp = Window:AddTab("ESP");
    ['UI Settings'] = Window:AddTab('UI Settings');
};

local UI_silentAim = tabs.Combat:AddLeftGroupbox("Silent Aim");

local UI_espBox = tabs.Esp:AddLeftGroupbox("Box");
local UI_espHBar = tabs.Esp:AddLeftGroupbox("Health");
local UI_espTracer = tabs.Esp:AddLeftGroupbox("Tracer");
local UI_espName = tabs.Esp:AddRightGroupbox("Name");
local UI_espDistance = tabs.Esp:AddRightGroupbox("Distance");
local UI_espArrows = tabs.Esp:AddRightGroupbox("OFF Screen Arrows");
local UI_espChams = tabs.Esp:AddRightGroupbox("Chams");

-- Toggles, buttons and shiiit
UI_silentAim:AddToggle("SilentAim", {Text = "Enabled", Default = false, Tooltip = "Enable/Disable Silent Aim",
    Callback = function(Value)
        cheat_settings.silentAim.enabled = Value;
        settingsChannel:Fire("set", "silentAim", "enabled", Value);
    end
});
UI_silentAim:AddToggle("VisCheck", {Text = "Visibility Check", Default = false, Tooltip = "Checks if target is visible",
    Callback = function(Value)
        cheat_settings.silentAim.visibilityCheck = Value;
        settingsChannel:Fire("set", "silentAim", "visibilityCheck", Value);
    end
});
UI_silentAim:AddToggle("fovCircle", {Text = "Show FOV Circle", Default = true, Tooltip = "Show/Hide FOV Circle",
    Callback = function(Value)
        cheat_settings.fovCircle.enabled = Value;
    end
});
UI_silentAim:AddSlider("CircleRadius", {Text = "Radius", Default = cheat_settings.fovCircle.radius, Min = 10, Max = 1000, Rounding = 1, Compact = false,
    Callback = function(Value)
        cheat_settings.fovCircle.radius = Value;
        settingsChannel:Fire("set", "silentAim", "radius", Value);
    end
});
UI_silentAim:AddSlider("CircleTransparency", {Text = "Transparency", Default = cheat_settings.fovCircle.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        cheat_settings.fovCircle.transparency = Value;
    end
});
UI_silentAim:AddSlider("CircleThickness", {Text = "Thickness", Default = cheat_settings.fovCircle.thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(Value)
        cheat_settings.fovCircle.thickness = Value;
    end
});
UI_silentAim:AddLabel("Color"):AddColorPicker("CircleColor", {Default = cheat_settings.fovCircle.color, Title = "Circle Color", Transparency = 0,
    Callback = function(Value)
        cheat_settings.fovCircle.color = Value;
    end
});

UI_espBox:AddToggle("box", {Text = "Enabled", Default = true, Tooltip = "Enable/Disable Box esp",
    Callback = function(Value)
        espLib.options.boxes = Value;
    end
});
UI_espBox:AddToggle("boxFill", {Text = "Box Fill", Default = false, Tooltip = "Enable/Disable Box fill",
    Callback = function(Value)
        espLib.options.boxFill = Value;
    end
});
UI_espBox:AddLabel("Color"):AddColorPicker("BoxColor", {Default = espLib.options.boxesColor, Title = "Box Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.boxesColor = Value;
    end
});
UI_espBox:AddLabel("Fill Color"):AddColorPicker("boxFillColor", {Default = espLib.options.boxFillColor, Title = "Fill Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.boxFillColor = Value;
    end
});
UI_espBox:AddSlider("boxTransparency", {Text = "Box Transparency", Default = espLib.options.boxesTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.boxesTransparency = Value;
    end
});
UI_espBox:AddSlider("boxFillTransparency", {Text = "Fill Transparency", Default = espLib.options.boxFillTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.boxFillTransparency = Value;
    end
});

UI_espHBar:AddToggle("healthBar", {Text = "Health Bar", Default = true, Tooltip = "Enable/Disable Health bar",
    Callback = function(Value)
        espLib.options.healthBars = Value;
    end
});
UI_espHBar:AddSlider("hBarSize", {Text = "Bar Size", Default = espLib.options.healthBarsSize, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.healthBarsSize = Value;
    end
});
UI_espHBar:AddSlider("hBarTransparency", {Text = "Bar Transparency", Default = espLib.options.healthBarsTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.healthBarsTransparency = Value;
    end
});
UI_espHBar:AddLabel("Bar Color"):AddColorPicker("HBarColor", {Default = espLib.options.healthBarsColor, Title = "Bar Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.healthBarsColor = Value;
    end
});
UI_espHBar:AddDivider()
UI_espHBar:AddToggle("healthText", {Text = "Health Text", Default = true, Tooltip = "Enable/Disable Health Text",
    Callback = function(Value)
        espLib.options.healthText = Value;
    end
});
UI_espHBar:AddSlider("healthTextTransparecy", {Text = "Text Transparency", Default = espLib.options.healthTextTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.healthTextTransparency = Value;
    end
});
UI_espHBar:AddLabel("Text Color"):AddColorPicker("HealthTextColor", {Default = espLib.options.healthTextColor, Title = "Text Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.healthTextColor = Value;
    end
});
UI_espTracer:AddToggle("tracer", {Text = "Enabled", Default = false, Tooltip = "Enable/Disable tracer esp",
    Callback = function(Value)
        espLib.options.tracers = Value;
    end
});
UI_espTracer:AddLabel("Color"):AddColorPicker("TracerColor", {Default = espLib.options.tracerColor, Title = "Tracer Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.tracerColor = Value;
    end
});
UI_espTracer:AddSlider("tracerTransparency", {Text = "Tracer Transparency", Default = espLib.options.tracerTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.tracerTransparency = Value;
    end
});

UI_espName:AddToggle("name", {Text = "Enabled", Default = true, Tooltip = "Enable/Disable name esp",
    Callback = function(Value)
        espLib.options.names = Value;
    end
});
UI_espName:AddLabel("Color"):AddColorPicker("nameColor", {Default = espLib.options.tracerColor, Title = "Name & Distance Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.nameColor = Value;
    end
});

UI_espDistance:AddToggle("distance", {Text = "Enabled", Default = true, Tooltip = "Enable/Disable distance esp",
    Callback = function(Value)
        espLib.options.distance = Value;
    end
});
UI_espDistance:AddLabel("Color"):AddColorPicker("distanceColor", {Default = espLib.options.distanceColor, Title = "Name & Distance Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.nameColor = Value;
    end
});

UI_espChams:AddToggle("chams", {Text = "Enabled", Default = true, Tooltip = "Enable/Disable chams",
    Callback = function(Value)
        espLib.options.chams = Value;
    end
});
UI_espChams:AddLabel("Fill Color"):AddColorPicker("chamsFillColor", {Default = espLib.options.chamsFillColor, Title = "Fill Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.chamsFillColor = Value;
    end
});
UI_espChams:AddLabel("Outline Color"):AddColorPicker("chamsOutlineColor", {Default = espLib.options.chamsOutlineColor, Title = "Outline Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.chamsOutlineColor = Value;
    end
});
UI_espChams:AddSlider("chamsFillTransparency", {Text = "Fill Transparency", Default = espLib.options.chamsFillTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.chamsFillTransparency = Value;
    end
});
UI_espChams:AddSlider("tracerTransparency", {Text = "Outline Transparency", Default = espLib.options.chamsOutlineTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.chamsOutlineTransparency = Value;
    end
});

UI_espArrows:AddToggle("arrows", {Text = "Enabled", Default = true, Tooltip = "Enable/Disable OFF screen arrows",
    Callback = function(Value)
        espLib.options.outOfViewArrows = Value;
        espLib.options.outOfViewArrowsOutline = Value;
    end
});
UI_espArrows:AddToggle("arrowsFilled", {Text = "Filled", Default = true, Tooltip = "Enable/Disable arrow fill",
    Callback = function(Value)
        espLib.options.outOfViewArrows = Value;
    end
});
UI_espArrows:AddSlider("arrowsSize", {Text = "Size", Default = espLib.options.outOfViewArrowsSize, Min = 5, Max = 50, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.outOfViewArrowsSize = Value;
    end
});
UI_espArrows:AddSlider("arrowsRadius", {Text = "Radius", Default = espLib.options.outOfViewArrowsRadius, Min = 50, Max = 500, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.outOfViewArrowsRadius = Value;
    end
});
UI_espArrows:AddLabel("Arrow Color"):AddColorPicker("arrowsColor", {Default = espLib.options.outOfViewArrowsColor, Title = "Arrow Color", Transparency = 0,
    Callback = function(Value)
        espLib.options.outOfViewArrowsColor = Value;
    end
});
UI_espArrows:AddSlider("arrowsTransparency", {Text = "Transparency", Default = espLib.options.outOfViewArrowsTransparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(Value)
        espLib.options.outOfViewArrowsTransparency = Value;
    end
});

local MenuGroup = tabs["UI Settings"]:AddRightGroupbox('Menu');
MenuGroup:AddButton('Unload', function() Library:Unload() end);
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' });
Library.ToggleKeybind = Options.MenuKeybind;
ThemeManager:SetLibrary(Library);
ThemeManager:SetFolder('MyScriptHub');
ThemeManager:ApplyToTab(tabs['UI Settings']);
espLib:Load()
