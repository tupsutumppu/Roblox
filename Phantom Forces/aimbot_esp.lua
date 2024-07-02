-- Phantom Forces | made by #tupsutumppu | 23.4.2024
local RUN_SERVICE = cloneref(game:GetService("RunService"));
local TWEEN_SERVICE = cloneref(game:GetService("TweenService"));
local PLAYERS = cloneref(game:GetService("Players"));
local LIGHTING = cloneref(game:GetService("Lighting"));

local localPlayer = PLAYERS.LocalPlayer;
local comm_id, comm_channel = create_comm_channel();
local camera = cloneref(workspace.CurrentCamera);
local ignoreList = {
    cloneref(workspace:WaitForChild("Ignore"));
    cloneref(workspace:WaitForChild("Players"));
    cloneref(workspace:WaitForChild("Terrain"));
    camera;
}
local mouse = localPlayer:GetMouse();
local mouse2Down = false;
local closest = nil;

local enemyBtDefault = {enabled = false; outline = true; color = Color3.fromRGB(255, 0, 0); outlineColor = Color3.fromRGB(); thickness = 1.5; transparency = 1; from = "Bottom"};
local teamBtDefault = {enabled = false; outline = true; color = Color3.fromRGB(120, 255, 0); outlineColor = Color3.fromRGB(); thickness = 1.5; transparency = 1; from = "Bottom"};
local enemyTextDefault = {enabled = false; outline = true; color = Color3.fromRGB(255, 0, 0); outlineColor = Color3.fromRGB(); size = 14; font = 2; transparency = 1};
local teamTextDefault = {enabled = false; outline = true; color = Color3.fromRGB(120, 255, 0); outlineColor = Color3.fromRGB(); size = 14; font = 2; transparency = 1};

local esp = {
    settings = {
        enemy = {
            box = table.clone(enemyBtDefault);
            tracer = table.clone(enemyBtDefault);
            name = table.clone(enemyTextDefault);
            weapon = table.clone(enemyTextDefault);
        };
        team = {
            box = table.clone(teamBtDefault);
            tracer = table.clone(teamBtDefault);
            name = table.clone(teamTextDefault);
            weapon = table.clone(teamTextDefault);
        };
    };
};
esp.cache = {
    __index = esp;
};

local combatSettings = {
    noRecoil = false;
    noSway = false;
    aimbot = {
        aimPart = "Head";
        enabled = false;
        visCheck = true;
        smoothing = 2;
    };
    silentAim = {
        aimPart = "Head";
        enabled = false;
        visCheck = true;
        hitChance = 80;
    };
};

local worldSettings = {
    ambient = {
        enabled = false;
        ambientColor = LIGHTING.Ambient;
    };
};

local aimbotCircle = Drawing.new("Circle");
aimbotCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
aimbotCircle.Color = Color3.fromRGB(255, 255, 255);
aimbotCircle.Transparency = 1;
aimbotCircle.Radius = 100;
aimbotCircle.NumSides = 128;

local silentAimCircle = Drawing.new("Circle");
silentAimCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
silentAimCircle.Color = Color3.fromRGB(255, 255, 255);
silentAimCircle.Transparency = 1;
silentAimCircle.Radius = 100;
silentAimCircle.NumSides = 128;

function esp:update()
    if self.data and self.data.character and self.data.character.Head then
        local torso = self.data.character.Torso;
        local screenPosition, onScreen = camera:WorldToViewportPoint(torso.CFrame.Position);

        if torso and screenPosition and onScreen then
            local settings = (self.player.Team == localPlayer.Team and esp.settings.team) or esp.settings.enemy;
            local scaleFactor = 1 / (screenPosition.Z * math.tan(math.rad(camera.FieldOfView / 2)) * 2) * 1000;
            local boxWidth, boxHeight = math.round(4 * scaleFactor), math.round(5 * scaleFactor);
            local boxPos = Vector2.new(math.round(screenPosition.X - boxWidth / 2), math.round(screenPosition.Y - boxHeight / 2));
            local topTextY = (screenPosition.Y - (boxHeight + self.drawings.name.TextBounds.Y + 19) / 2);
            local bottomTextY = (screenPosition.Y + (boxHeight + self.drawings.weapon.TextBounds.Y - 5) / 2);

            self.drawings.boxOutline.Visible = settings.box.enabled and settings.box.outline;
            self.drawings.boxOutline.Size = Vector2.new(boxWidth, boxHeight);
            self.drawings.boxOutline.Position = boxPos;
            self.drawings.boxOutline.Color = settings.box.outlineColor;
            self.drawings.boxOutline.Thickness = settings.box.thickness + 1.5;
            self.drawings.boxOutline.Transparency = settings.box.transparency;

            self.drawings.box.Visible = settings.box.enabled;
            self.drawings.box.Size = Vector2.new(boxWidth, boxHeight);
            self.drawings.box.Position = boxPos;
            self.drawings.box.Color = settings.box.color;
            self.drawings.box.Thickness = settings.box.thickness;
            self.drawings.box.Transparency = settings.box.transparency;

            self.drawings.tracerOutline.Visible = settings.tracer.enabled and settings.tracer.outline;
            self.drawings.tracerOutline.From = (settings.tracer.from == "Bottom" and Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)) or Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
            self.drawings.tracerOutline.To = Vector2.new(screenPosition.X, screenPosition.Y);
            self.drawings.tracerOutline.Color = settings.tracer.outlineColor;
            self.drawings.tracerOutline.Thickness = settings.tracer.thickness + 1.5;
            self.drawings.tracerOutline.Transparency = settings.tracer.transparency;

            self.drawings.tracer.Visible = settings.tracer.enabled;
            self.drawings.tracer.From = self.drawings.tracerOutline.From;
            self.drawings.tracer.To = Vector2.new(screenPosition.X, screenPosition.Y);
            self.drawings.tracer.Color = settings.tracer.color;
            self.drawings.tracer.Thickness = settings.tracer.thickness;
            self.drawings.tracer.Transparency = settings.tracer.transparency;

            self.drawings.weapon.Visible = settings.weapon.enabled;
            self.drawings.weapon.Text = (self.data.weapon) or "no weapon";
            self.drawings.weapon.Size = settings.weapon.size;
            self.drawings.weapon.Color = settings.weapon.color;
            self.drawings.weapon.Transparency = settings.weapon.transparency;
            self.drawings.weapon.Outline = settings.weapon.outline;
            self.drawings.weapon.OutlineColor = settings.weapon.outlineColor;
            self.drawings.weapon.Font = settings.weapon.font;
            self.drawings.weapon.Position = Vector2.new(screenPosition.X, bottomTextY);
            self.drawings.weapon.Center = true;

            self.drawings.name.Visible = settings.name.enabled;
            self.drawings.name.Text = self.player.Name;
            self.drawings.name.Size = settings.name.size;
            self.drawings.name.Color = settings.name.color;
            self.drawings.name.Transparency = settings.name.transparency;
            self.drawings.name.Outline = settings.name.outline;
            self.drawings.name.OutlineColor = settings.name.outlineColor;
            self.drawings.name.Font = settings.name.font;
            self.drawings.name.Position = Vector2.new(screenPosition.X, topTextY);
            self.drawings.name.Center = true;
        else
            self.drawings.boxOutline.Visible = false;
            self.drawings.box.Visible = false;
            self.drawings.tracerOutline.Visible = false;
            self.drawings.tracer.Visible = false;
            self.drawings.weapon.Visible = false;
            self.drawings.name.Visible = false;
        end

    else
        self.drawings.boxOutline.Visible = false;
        self.drawings.box.Visible = false;
        self.drawings.tracerOutline.Visible = false;
        self.drawings.tracer.Visible = false;
        self.drawings.weapon.Visible = false;
        self.drawings.name.Visible = false;
    end
end

function esp.new(player, data)
    local self = setmetatable({}, esp.cache);
    self.player = player;
    self.data = data;
    self.drawings = {
        boxOutline = Drawing.new("Square");
        box = Drawing.new("Square");
        tracerOutline = Drawing.new("Line");
        tracer = Drawing.new("Line");
        weapon = Drawing.new("Text");
        name = Drawing.new("Text");
    };
    self.connection = RUN_SERVICE.RenderStepped:Connect(function()
        self:update();
    end);

    esp.cache[player] = self;
    return self;
end

function esp:remove()
    self.connection:Disconnect();

    for _, drawing in next, self.drawings do
        if typeof(drawing) ~= "table" then
            drawing:Remove();
        end
    end

    esp.cache[self.player] = nil;
    table.clear(self);
end

function esp.getEnemyCharacters()
    local enemies = {};

    for k, v in next, esp.cache do
        if typeof(k) == "Instance" and v.data and v.data.character and k.Team ~= localPlayer.Team then
            table.insert(enemies, v.data.character);
        end
    end

    return enemies;
end

PLAYERS.PlayerRemoving:Connect(function(player)
    local self = esp.cache[player];

    if self then
        self:remove();
    end
end);

comm_channel.Event:Connect(function(caller, player, data)
    if caller == "actor" then
        local self = esp.cache[player];

        if self then
            self.data = data;
    
        else
            esp.new(player);
        end
    end
end);

run_on_actor(getactors()[1], [[
    local comm_channel = ...;
    comm_channel = get_comm_channel(comm_channel);

    local RUN_SERVICE = cloneref(game:GetService("RunService"));
    local req = getrenv().shared.require
    local operateOnAllEntries = req("ReplicationInterface").operateOnAllEntries;
    local applyImpulse = req("RecoilSprings").applyImpulse;

    local combatSettings;
    local closest;
    
    -- // I am not sure if tables sent trough comm channels are passed by reference or just clones.
    RUN_SERVICE.Heartbeat:Connect(function()
        operateOnAllEntries(function(player, data)
            comm_channel:Fire("actor", player, {
                weapon = (data._thirdPersonObject and data._thirdPersonObject._weaponname) or false;
                character = (data._thirdPersonObject and data._thirdPersonObject._characterHash) or false;
            });
        end);
    end);

    comm_channel.Event:Connect(function(caller, _, data)
        if caller == "main" then
            combatSettings = data.combatSettings;
            closest = data.closest;
        end
    end)

    local old_applyImpulse;
    local old_index;

    old_applyImpulse = hookfunction(applyImpulse, function(...)
        if combatSettings.noRecoil then
            return
        end
        return old_applyImpulse(...);
    end);

    old_index = hookmetamethod(game, "__index", newcclosure(function(...)
        local self, index = ...;

        if typeof(self) == "Instance" and index == "CFrame" and debug.info(3, "n") == "fireRound" then
            if combatSettings.silentAim.enabled and closest and math.random(1, 100) <= combatSettings.silentAim.hitChance then
                local oldCFrame = old_index(self, index);

                return CFrame.lookAt(oldCFrame.Position, closest.CFrame.Position);
            end
        end

        return old_index(...);
    end));
]], comm_id);

local function isVisible(head)
    return #camera:GetPartsObscuringTarget({head.CFrame.Position}, ignoreList) == 0;
end

local function getClosestEnemy(enemies, visCheck, fovRadius, aimPart)
    local maxDist = math.huge;
    local closest = nil;

    for _, v in next, enemies do
        if v.Head and v[aimPart] then
            local head = v.Head;
            local headPos = head.CFrame.Position;
            local headPosV2, onScreen = camera:WorldToViewportPoint(headPos);

            if onScreen then
                local distance = (Vector2.new(headPosV2.X, headPosV2.Y) - (camera.ViewportSize / 2)).Magnitude;

                if (not fovRadius or (distance < fovRadius)) and (not visCheck or isVisible(head)) then
                    distance = (camera.CFrame.Position - headPos).Magnitude;

                    if distance < maxDist then
                        maxDist = distance;
                        closest = v[aimPart];
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

local function lookAt(pos)
    local mousePos = Vector2.new(mouse.X, mouse.Y);
    mousemoverel((pos.X - mousePos.X) / combatSettings.aimbot.smoothing, (pos.Y - mousePos.Y) / combatSettings.aimbot.smoothing);
end

RUN_SERVICE.Heartbeat:Connect(function()
    local enemies = esp.getEnemyCharacters();

    closest = getClosestEnemy(
        enemies,
        combatSettings.aimbot.visCheck,
        aimbotCircle.Radius,
        combatSettings.aimbot.aimPart
    );

    if combatSettings.aimbot.enabled and mouse2Down then
        if closest then
            lookAt(camera:WorldToScreenPoint(closest.CFrame.Position));
        end
    end

    comm_channel:Fire("main", nil, {
        combatSettings = combatSettings;
        closest = getClosestEnemy(
            enemies,
            combatSettings.silentAim.visCheck,
            silentAimCircle.Radius,
            combatSettings.silentAim.aimPart
        );
    });
end);

LIGHTING:GetPropertyChangedSignal("Ambient"):Connect(function()
    if worldSettings.ambient.enabled then
        LIGHTING.Ambient = worldSettings.ambient.ambientColor;
    end
end)

mouse.Button2Down:Connect(function()
    mouse2Down = true;
end);

mouse.Button2Up:Connect(function()
    mouse2Down = false;
end);

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/";
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))();
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))();

local Window = Library:CreateWindow({
    Title = tostring(cloneref(game:GetService("MarketplaceService")):GetProductInfo(game.PlaceId).Name) .. " |" .. " #tupsutumppu";
    Center = true;
    AutoShow = true;
    TabPadding = 8;
    MenuFadeTime = 0.2
});

local Tabs = {
    Combat = Window:AddTab("Combat");
    Visuals = Window:AddTab("Visuals");
    ["UI & Config"] = Window:AddTab("UI & Config")
};

local silentAimGB = Tabs.Combat:AddLeftGroupbox("Silent Aim");
local aimbotGB = Tabs.Combat:AddRightGroupbox("Aimbot");
local gunModsGB = Tabs.Combat:AddRightGroupbox("Gun Mods");

local enemyTB = Tabs.Visuals:AddLeftTabbox();
local enemyESP = enemyTB:AddTab("Enemy ESP");
local enemyESPSettings = enemyTB:AddTab("Settings");
local teamTB = Tabs.Visuals:AddRightTabbox();
local teamESP = teamTB:AddTab("Team ESP");
local teamESPSettings = teamTB:AddTab("Settings");

local worldGB = Tabs.Visuals:AddLeftGroupbox("World");

do
    aimbotGB:AddToggle("aimbot", {Text = "Enabled"; Default = false; Tooltip = "enable / disable aimbot";
        Callback = function(Value)
            combatSettings.aimbot.enabled = Value;
        end
    });
    aimbotGB:AddToggle("aimbotVisCheck", {Text = "Visibility Check"; Default = true; Tooltip = "checks if target is visible";
        Callback = function(Value)
            combatSettings.aimbot.visCheck = Value;
        end
    });
    aimbotGB:AddDropdown("aimbotPart", {Values = {"Head", "Torso"}, Default = "Head", Multi = false, Text = "Aim Part", Tooltip = nil,
        Callback = function(Value)
            combatSettings.aimbot.aimPart = Value;
        end
    });
    aimbotGB:AddSlider("aimbotSmoothing", {Text = "Aimbot Smoothing", Default = combatSettings.aimbot.smoothing, Min = 2, Max = 20, Rounding = 1, Compact = false,
        Callback = function(Value)
            combatSettings.aimbot.smoothing = Value;
        end
    });
    aimbotGB:AddDivider();
    aimbotGB:AddToggle("aimbotCircle", {Text = "FOV Cirle"; Default = false; Tooltip = "enable / disable fov aimbotCircle";
        Callback = function(Value)
            aimbotCircle.Visible = Value;
        end
    }):AddColorPicker("aimbotCircleColor", {Default = Color3.fromRGB(255, 255, 255), Title = "", Transparency = 0,
        Callback = function(Value)
            aimbotCircle.Color = Value;
        end
    });
    aimbotGB:AddSlider("aimbotCircleRadius", {Text = "Radius", Default = aimbotCircle.Radius, Min = 25, Max = 1000, Rounding = 0, Compact = false,
        Callback = function(Value)
            aimbotCircle.Radius = Value;
        end
    });
    aimbotGB:AddSlider("aimbotCircleThickness", {Text = "Thickness", Default = 1.2, Min = 1, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            aimbotCircle.Thickness = Value;
        end
    });
    aimbotGB:AddSlider("aimbotCircleNumSides", {Text = "NumSides", Default = 128, Min = 6, Max = 256, Rounding = 0, Compact = false,
        Callback = function(Value)
            aimbotCircle.NumSides = Value;
        end
    });
    aimbotGB:AddSlider("aimbotCircleTransparency", {Text = "Transparency", Default = 1, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            aimbotCircle.Transparency = Value;
        end
    });
end

do
    silentAimGB:AddToggle("silentAim", {Text = "Enabled"; Default = false; Tooltip = "enable / disable silent aim";
        Callback = function(Value)
            combatSettings.silentAim.enabled = Value;
        end
    });
    silentAimGB:AddToggle("silentAimVisCheck", {Text = "Visibility Check"; Default = true; Tooltip = "checks if target is visible";
        Callback = function(Value)
            combatSettings.silentAim.visCheck = Value;
        end
    });
    silentAimGB:AddDropdown("silentAimPart", {Values = {"Head", "Torso"}, Default = "Head", Multi = false, Text = "Aim Part", Tooltip = nil,
        Callback = function(Value)
            combatSettings.silentAim.aimPart = Value;
        end
    });
    silentAimGB:AddSlider("silentAimHitChance", {Text = "Hit Chance", Default = combatSettings.silentAim.hitChance, Min = 1, Max = 100, Rounding = 0, Compact = false,
        Callback = function(Value)
            combatSettings.silentAim.hitChance = Value;
        end
    });
    silentAimGB:AddDivider();
    silentAimGB:AddToggle("silentAimCircle", {Text = "FOV Cirle"; Default = false; Tooltip = "enable / disable fov aimbotCircle";
        Callback = function(Value)
            silentAimCircle.Visible = Value;
        end
    }):AddColorPicker("silentAimCircleColor", {Default = Color3.fromRGB(255, 255, 255), Title = "", Transparency = 0,
        Callback = function(Value)
            silentAimCircle.Color = Value;
        end
    });
    silentAimGB:AddSlider("silentAimCircleRadius", {Text = "Radius", Default = silentAimCircle.Radius, Min = 25, Max = 1000, Rounding = 0, Compact = false,
        Callback = function(Value)
            silentAimCircle.Radius = Value;
        end
    });
    silentAimGB:AddSlider("silentAimCircleThickness", {Text = "Thickness", Default = 1.2, Min = 1, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            silentAimCircle.Thickness = Value;
        end
    });
    silentAimGB:AddSlider("silentAimCircleNumSides", {Text = "NumSides", Default = 128, Min = 6, Max = 256, Rounding = 0, Compact = false,
        Callback = function(Value)
            silentAimCircle.NumSides = Value;
        end
    });
    silentAimGB:AddSlider("silentAimCircleTransparency", {Text = "Transparency", Default = 1, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            silentAimCircle.Transparency = Value;
        end
    });
end

do
    gunModsGB:AddToggle("noRecoil", {Text = "No Recoil"; Default = false; Tooltip = "enable / disable weapon recoil";
        Callback = function(Value)
            combatSettings.noRecoil = Value;
        end
    });
end

do
    enemyESP:AddToggle("enemyBoxEnabled", {Text = "Box"; Default = false; Tooltip = "enable / disable boxes";
        Callback = function(Value)
            esp.settings.enemy.box.enabled = Value;
        end
    }):AddColorPicker("enemyBoxColor", {Default = esp.settings.enemy.box.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.box.color = Value;
        end
    }):AddColorPicker("enemyBoxOutlineColor", {Default = esp.settings.enemy.box.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.box.outlineColor = Value;
        end
    });
    enemyESP:AddToggle("enemyTracerEnabled", {Text = "Tracer"; Default = false; Tooltip = "enable / disable tracers";
        Callback = function(Value)
            esp.settings.enemy.tracer.enabled = Value;
        end
    }):AddColorPicker("enemyTracerColor", {Default = esp.settings.enemy.tracer.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.tracer.color = Value;
        end
    }):AddColorPicker("enemyTracerColor", {Default = esp.settings.enemy.tracer.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.tracer.outlineColor = Value;
        end
    });
    enemyESP:AddToggle("enemyNameEnabled", {Text = "Name"; Default = false; Tooltip = "enable / disable names";
        Callback = function(Value)
            esp.settings.enemy.name.enabled = Value;
        end
    }):AddColorPicker("enemyNameColor", {Default = esp.settings.enemy.name.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.name.color = Value;
        end
    }):AddColorPicker("enemyNameOutlineColor", {Default = esp.settings.enemy.name.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.name.outlineColor = Value;
        end
    });
    enemyESP:AddToggle("enemyWeaponEnabled", {Text = "Weapon"; Default = false; Tooltip = "enable / disable weapons";
        Callback = function(Value)
            esp.settings.enemy.weapon.enabled = Value;
        end
    }):AddColorPicker("enemyWeaponColor", {Default = esp.settings.enemy.weapon.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.weapon.color = Value;
        end
    }):AddColorPicker("enemyWeaponOutlineColor", {Default = esp.settings.enemy.weapon.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.enemy.weapon.outlineColor = Value;
        end
    });
    enemyESPSettings:AddToggle("enemyBoxOutline", {Text = "Box Outline"; Default = true; Tooltip = "enable / disable box outline";
        Callback = function(Value)
            esp.settings.enemy.box.outline = Value;
        end
    });
    enemyESPSettings:AddSlider("enemyBoxThickness", {Text = "Box Thickness", Default = esp.settings.enemy.box.thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.enemy.box.thickness = Value;
        end
    });
    enemyESPSettings:AddSlider("enemyBoxTransparency", {Text = "Box Transparency", Default = esp.settings.enemy.box.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.enemy.box.transparency = Value;
        end
    });
    enemyESPSettings:AddDivider();
    enemyESPSettings:AddToggle("enemyTracerOutline", {Text = "Tracer Outline"; Default = true; Tooltip = "enable / disable tracer outline";
        Callback = function(Value)
            esp.settings.enemy.tracer.outline = Value;
        end
    });
    enemyESPSettings:AddSlider("enemyTracerThickness", {Text = "Tracer Thickness", Default = esp.settings.enemy.tracer.thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.enemy.tracer.thickness = Value
        end
    });
    enemyESPSettings:AddSlider("enemyTracerTransparency", {Text = "Tracer Transparency", Default = esp.settings.enemy.tracer.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.enemy.tracer.transparency = Value;
        end
    });
    enemyESPSettings:AddDropdown("enemyTracerFrom", {Values = {"Bottom", "Middle"}, Default = "Bottom", Multi = false, Text = "Tracer From", Tooltip = nil,
        Callback = function(Value)
            esp.settings.enemy.tracer.from = Vector2.new(camera.ViewportSize.X / 2, ((esp.settings.enemy.tracer.from == "Bottom" and camera.ViewportSize.Y) or camera.ViewportSize.Y / 2));
        end
    });
    enemyESPSettings:AddDivider();
    enemyESPSettings:AddToggle("enemyTextOutline", {Text = "Text Outline"; Default = true; Tooltip = "enable / disable text outline";
        Callback = function(Value)
            esp.settings.enemy.name.outline = Value;
            esp.settings.enemy.weapon.outline = Value;
        end
    });
    enemyESPSettings:AddSlider("enemyTextTransparency", {Text = "Text Transparency", Default = esp.settings.enemy.name.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.enemy.name.transparency = Value;
            esp.settings.enemy.weapon.transparency = Value;
        end
    });
    enemyESPSettings:AddDropdown("enemyTextFont", {Values = {"UI", "System", "Plex", "Monospace"}, Default = "System", Multi = false, Text = "Text Font", Tooltip = nil,
        Callback = function(Value)
            esp.settings.enemy.name.font = Drawing.Fonts[Value];
            esp.settings.enemy.weapon.font = Drawing.Fonts[Value];
        end
    });
end

do
    teamESP:AddToggle("teamBoxEnabled", {Text = "Box"; Default = false; Tooltip = "enable / disable boxes";
        Callback = function(Value)
            esp.settings.team.box.enabled = Value;
        end
    }):AddColorPicker("teamBoxColor", {Default = esp.settings.team.box.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.box.color = Value;
        end
    }):AddColorPicker("teamBoxOutlineColor", {Default = esp.settings.team.box.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.box.outlineColor = Value;
        end
    });
    teamESP:AddToggle("teamTracerEnabled", {Text = "Tracer"; Default = false; Tooltip = "enable / disable tracers";
        Callback = function(Value)
            esp.settings.team.tracer.enabled = Value;
        end
    }):AddColorPicker("teamTracerColor", {Default = esp.settings.team.tracer.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.tracer.color = Value;
        end
    }):AddColorPicker("teamTracerColor", {Default = esp.settings.team.tracer.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.tracer.outlineColor = Value;
        end
    });
    teamESP:AddToggle("teamNameEnabled", {Text = "Name"; Default = false; Tooltip = "enable / disable names";
        Callback = function(Value)
            esp.settings.team.name.enabled = Value;
        end
    }):AddColorPicker("teamNameColor", {Default = esp.settings.team.name.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.name.color = Value;
        end
    }):AddColorPicker("teamNameOutlineColor", {Default = esp.settings.team.name.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.name.outlineColor = Value;
        end
    });
    teamESP:AddToggle("teamWeaponEnabled", {Text = "Weapon"; Default = false; Tooltip = "enable / disable weapons";
        Callback = function(Value)
            esp.settings.team.weapon.enabled = Value;
        end
    }):AddColorPicker("teamWeaponColor", {Default = esp.settings.team.weapon.color, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.weapon.color = Value;
        end
    }):AddColorPicker("teamWeaponOutlineColor", {Default = esp.settings.team.weapon.outlineColor, Title = "", Transparency = 0,
        Callback = function(Value)
            esp.settings.team.weapon.outlineColor = Value;
        end
    });
    teamESPSettings:AddToggle("teamBoxOutline", {Text = "Box Outline"; Default = true; Tooltip = "enable / disable box outline";
        Callback = function(Value)
            esp.settings.team.box.outline = Value;
        end
    });
    teamESPSettings:AddSlider("teamBoxThickness", {Text = "Box Thickness", Default = esp.settings.team.box.thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.team.box.thickness = Value;
        end
    });
    teamESPSettings:AddSlider("teamBoxTransparency", {Text = "Box Transparency", Default = esp.settings.team.box.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.team.box.transparency = Value;
        end
    });
    teamESPSettings:AddDivider();
    teamESPSettings:AddToggle("teamTracerOutline", {Text = "Tracer Outline"; Default = true; Tooltip = "enable / disable tracer outline";
        Callback = function(Value)
            esp.settings.team.tracer.outline = Value;
        end
    });
    teamESPSettings:AddSlider("teamTracerThickness", {Text = "Tracer Thickness", Default = esp.settings.team.tracer.thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.team.tracer.thickness = Value;
        end
    });
    teamESPSettings:AddSlider("teamTracerTransparency", {Text = "Tracer Transparency", Default = esp.settings.team.tracer.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.team.tracer.transparency = Value;
        end
    });
    teamESPSettings:AddDropdown("teamTracerFrom", {Values = {"Bottom", "Middle"}, Default = "Bottom", Multi = false, Text = "Tracer From", Tooltip = nil,
        Callback = function(Value)
            esp.settings.team.tracer.from = Vector2.new(camera.ViewportSize.X / 2, ((esp.settings.team.tracer.from == "Bottom" and camera.ViewportSize.Y) or camera.ViewportSize.Y / 2));
        end
    });
    teamESPSettings:AddDivider();
    teamESPSettings:AddToggle("teamTextOutline", {Text = "Text Outline"; Default = true; Tooltip = "enable / disable text outline";
        Callback = function(Value)
            esp.settings.team.name.outline = Value;
            esp.settings.team.weapon.outline = Value;
        end
    });
    teamESPSettings:AddSlider("teamTextTransparency", {Text = "Text Transparency", Default = esp.settings.team.name.transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
        Callback = function(Value)
            esp.settings.team.name.transparency = Value;
            esp.settings.team.weapon.transparency = Value;
        end
    });
    teamESPSettings:AddDropdown("teamTextFont", {Values = {"UI", "System", "Plex", "Monospace"}, Default = "System", Multi = false, Text = "Text Font", Tooltip = nil,
        Callback = function(Value)
            esp.settings.team.name.font = Drawing.Fonts[Value];
            esp.settings.team.weapon.font = Drawing.Fonts[Value];
        end
    });
end

do
    worldGB:AddToggle("shadowsToggle", {Text = "Global Shadows"; Default = LIGHTING.GlobalShadows; Tooltip = nil;
        Callback = function(Value)
            LIGHTING.GlobalShadows = Value;
        end
    });
    worldGB:AddToggle("ambientToggle", {Text = "Set Ambient"; Default = false; Tooltip = nil;
        Callback = function(Value)
            worldSettings.ambient.enabled = Value;
        end
    }):AddColorPicker("ambientColor", {Default = LIGHTING.Ambient, Title = "", Transparency = 0,
        Callback = function(Value)
            worldSettings.ambient.ambientColor = Value;

            if worldSettings.ambient.enabled then
                LIGHTING.Ambient = Value;
            end
        end
    });
    worldGB:AddLabel("respawn to reset ambient")
end


local MenuGroup = Tabs["UI & Config"]:AddRightGroupbox("Menu");
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "Menu keybind"});
Library.ToggleKeybind = Options.MenuKeybind;

ThemeManager:SetLibrary(Library);
ThemeManager:ApplyToTab(Tabs["UI & Config"]);
ThemeManager:ApplyTheme("Mint");

SaveManager:SetLibrary(Library);
SaveManager:IgnoreThemeSettings();
SaveManager:SetIgnoreIndexes({"MenuKeybind"});
SaveManager:SetFolder("Phantom Forces");
SaveManager:BuildConfigSection(Tabs["UI & Config"]);
SaveManager:LoadAutoloadConfig();
