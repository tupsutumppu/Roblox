-- Services
local PLAYERS = cloneref(game:GetService("Players"));
local RUN_SERVICE = cloneref(game:GetService("RunService"));
local REPLICATED_STORAGE = cloneref(game:GetService("ReplicatedStorage"));

local camera = workspace.CurrentCamera;
local localPlayer = PLAYERS.LocalPlayer;
local closestDir = nil;
local specateFrame = localPlayer.PlayerGui.MainGui.Spectate;
local esp = {};
esp.cache = {
    __index = esp;
}

local new_proj = require(REPLICATED_STORAGE:WaitForChild("GunSystem").GunSharedAssets.Projectile).New;
local fire = require(REPLICATED_STORAGE:WaitForChild("GunSystem").GunClientAssets.Modules.Gun).Fire;

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/";
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))();
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))();
local Window = Library:CreateWindow({
    Title = tostring(cloneref(game:GetService("MarketplaceService")):GetProductInfo(game.PlaceId).Name) .. " |" .. " by #tupsutumppu";
    Center = true;
    AutoShow = true;
    TabPadding = 8;
    MenuFadeTime = 0.2
});

local tabs = {
    combat = Window:AddTab("Combat");
    visuals = Window:AddTab("Visuals");
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local UI_silentAim = tabs.combat:AddLeftGroupbox("Silent Aim");
local UI_triggerBot = tabs.combat:AddRightGroupbox("Triggerbot");
local UI_gunMods = tabs.combat:AddRightGroupbox("Gun Mods");
local UI_playerBox = tabs.visuals:AddLeftGroupbox("box");
local UI_playerTracer = tabs.visuals:AddLeftGroupbox("Tracer");
local UI_playerName = tabs.visuals:AddRightGroupbox("Name");
local UI_playerWeapon = tabs.visuals:AddRightGroupbox("Weapon");

local settings = {
    combat = {
        silentAim = false;
        hitPart = "Head";
        useFov = false;
        triggerBot = false;
        infiniteAmmo = false;
        rapidFire = false;
        noSpread = false;
        fovCircle = {
            enabled = false;
            sides = 64;
            color = Color3.fromRGB(255, 255, 255);
            transparency = 1;
            radius = 75;
            thickness = 2;
            filled = false
        }
    },
    esp = {
        box = {enabled = false; outline = false; thickness = 2; transparency = 1; filled = false; color = Color3.fromRGB(45, 255, 0); outlineColor = Color3.fromRGB(0, 0, 0)};
        tracer = {enabled = false; outline = false; thickness = 2; transparency = 1; color = Color3.fromRGB(0, 180, 255); outlineColor = Color3.fromRGB(0, 0, 0)};
        name = {enabled = false; font = 2; size = 13; center = true; outline = true; color = Color3.fromRGB(45, 255, 0); outlineColor = Color3.fromRGB(0, 0, 0)};
        weapon = {enabled = false; font = 2; size = 13; center = true; outline = true; color = Color3.fromRGB(0, 180, 255); outlineColor = Color3.fromRGB(0, 0, 0)}
    }
}

local function is_not_spectating()
    if specateFrame.Visible then
        return false;
    end
    return true;
end

local function get_closest()
    local closest = nil;
    local maxDist = math.huge;

    for _, player in pairs(workspace:GetChildren()) do
        if player:IsA("Model") and player.Name ~= localPlayer.Name and player:FindFirstChild(settings.combat.hitPart) then
            local pos = player[settings.combat.hitPart].CFrame.p;
            local posv2, onScreen = camera:WorldToScreenPoint(pos);

            if onScreen then
                local distance = (Vector2.new(posv2.X, posv2.Y) - (camera.ViewportSize / 2)).Magnitude;
                
                if distance < settings.combat.fovCircle.radius then
                    distance = (camera.CFrame.p - pos).Magnitude;

                    if distance < maxDist then
                        closest = player;
                        maxDist = distance;
                    end
                end
            end
        end
    end

    if closest then
        return closest;
    end
end

RUN_SERVICE.Heartbeat:Connect(function()
    if is_not_spectating() then
        local closest = get_closest();
        local localChar = localPlayer.Character;
        local localHitBox = workspace.Hitboxes:FindFirstChild(localPlayer.Name);
        local hitPart = closest and closest:FindFirstChild(settings.combat.hitPart);
    
        if closest and localChar and localHitBox and hitPart then
            local screenPos = camera:WorldToScreenPoint(hitPart.CFrame.p);
            local rayDir = camera:ScreenPointToRay(screenPos.X, screenPos.Y).Direction;
    
            local origin = camera.CFrame.p;
            local destination = hitPart.CFrame.p;
            local direction = destination - origin;
            local params = RaycastParams.new();
            params.FilterDescendantsInstances = {camera, localChar, workspace.Hitboxes:FindFirstChild(localPlayer.Name)};
            params.FilterType = Enum.RaycastFilterType.Exclude;
            params.IgnoreWater = true;
            result = workspace:Raycast(origin, direction, params);
    
            if result and result.Instance and (result.Instance:IsDescendantOf(workspace.Hitboxes:FindFirstChild(closest.Name)) or result.Instance:IsDescendantOf(closest)) then
                closestDir = rayDir;
    
                if settings.combat.triggerBot and not closest:FindFirstChild("RoundForceField") then
                    mouse1click();
                    task.wait(.05);
                end
            else
                closestDir = nil;
            end
        end
    end
end);

function esp:get_weapon()
    local weapon = self.model:FindFirstChildWhichIsA("Model");

    if weapon then
        return weapon.Name;
    end

    return "No Weapon";
end

function esp:remove_object()
    self.connection:Disconnect();

    for _, drawing in pairs(self.drawings) do
        if typeof(drawing) ~= "table" then
            drawing:Remove();
        end
    end

    table.clear(self);
end

function esp:update_esp()
    local character = self.model;
    local drawings = self.drawings;

    if character and character:FindFirstChild("HumanoidRootPart") and PLAYERS:FindFirstChild(character.Name) then
        -- Yes i am cutting corners here because i hate making esp's.
        local humanoidRootPart = character.HumanoidRootPart;
        local topLeft = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(-3,3,0).p);
        local topRight = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(3,3,0).p);
        local bottomLeft = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(-3,-3,0).p);
        local bottomRight = camera:WorldToViewportPoint(humanoidRootPart.CFrame * CFrame.new(3,-3,0).p);
        local tracerPosX, tracerPosY = (bottomLeft.X + bottomRight.X) / 2, (bottomLeft.Y + bottomRight.Y) / 2;
        local topPosX, topPosY = (topLeft.X + topRight.X) / 2, (topLeft.Y + topRight.Y) / 2;
        local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.CFrame.Position);

        if onScreen then
            -- Boxes
            if settings.esp.box.enabled then
                -- Outline
                drawings.boxOutline.PointA = Vector2.new(topRight.X, topRight.Y);
                drawings.boxOutline.PointB = Vector2.new(topLeft.X, topLeft.Y);
                drawings.boxOutline.PointC = Vector2.new(bottomLeft.X, bottomLeft.Y);
                drawings.boxOutline.PointD = Vector2.new(bottomRight.X, bottomRight.Y);
                drawings.boxOutline.Color = settings.esp.box.outlineColor;
                drawings.boxOutline.Thickness = settings.esp.box.thickness + 1.5;
                drawings.boxOutline.Transparency = settings.esp.box.transparency;
                drawings.boxOutline.Visible = settings.esp.box.outline;
                -- box
                drawings.box.PointA = drawings.boxOutline.PointA;
                drawings.box.PointB = drawings.boxOutline.PointB;
                drawings.box.PointC = drawings.boxOutline.PointC;
                drawings.box.PointD = drawings.boxOutline.PointD;
                drawings.box.Color = settings.esp.box.color;
                drawings.box.Thickness = settings.esp.box.thickness;
                drawings.box.Transparency = settings.esp.box.transparency;
                drawings.box.Filled = settings.esp.box.filled;
                drawings.box.Visible = true;
            else
                drawings.boxOutline.Visible = false;
                drawings.box.Visible = false;
            end
            -- Tracers
            if settings.esp.tracer.enabled then
                drawings.traceOutline.Thickness = settings.esp.tracer.thickness + 1.5;
                drawings.traceOutline.Color = settings.esp.tracer.outlineColor;
                drawings.traceOutline.Transparency = settings.esp.tracer.transparency;
                drawings.traceOutline.Visible = settings.esp.tracer.outline;
                drawings.traceOutline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 1);
                drawings.traceOutline.To = Vector2.new(tracerPosX, tracerPosY);

                drawings.trace.Thickness = settings.esp.tracer.thickness;
                drawings.trace.Color = settings.esp.tracer.color;
                drawings.trace.Transparency = settings.esp.tracer.transparency;
                drawings.trace.Visible = true;
                drawings.trace.From = drawings.traceOutline.From;
                drawings.trace.To = drawings.traceOutline.To;
            else
                drawings.trace.Visible = false;
                drawings.traceOutline.Visible = false;
            end
            -- Names
            if settings.esp.name.enabled then
                drawings.name.Text = character.Name;
                drawings.name.Color = settings.esp.name.color;
                drawings.name.Font = settings.esp.name.font;
                drawings.name.Size = settings.esp.name.size;
                drawings.name.Center = settings.esp.name.center;
                drawings.name.Outline = settings.esp.name.outline;
                drawings.name.OutlineColor = settings.esp.name.outlineColor;
                drawings.name.Position = Vector2.new(topPosX, topPosY - 27);
                drawings.name.Visible = true;
            else
                drawings.name.Visible = false;
                drawings.name.Outline = false;
            end
            -- Distance
            if settings.esp.weapon.enabled then
                drawings.weapon.Text = self:get_weapon();
                drawings.weapon.Color = settings.esp.weapon.color;
                drawings.weapon.Font = settings.esp.weapon.font;
                drawings.weapon.Size = settings.esp.weapon.size;
                drawings.weapon.Center = settings.esp.weapon.center;
                drawings.weapon.Outline = settings.esp.weapon.outline;
                drawings.weapon.OutlineColor = settings.esp.weapon.outlineColor;
                drawings.weapon.Position = Vector2.new(topPosX, topPosY - 15);
                drawings.weapon.Visible = true;
            else
                drawings.weapon.Visible = false;
                drawings.weapon.Outline = false;
            end
        else
            drawings.boxOutline.Visible = false;
            drawings.box.Visible = false;
            drawings.trace.Visible = false;
            drawings.traceOutline.Visible = false;
            drawings.name.Visible = false;
            drawings.weapon.Visible = false;
        end
    end
end

function esp.new_object(player_model: Model)
    local self = setmetatable({}, esp.cache);
    self.model = player_model;
    self.drawings = {
        boxOutline = Drawing.new("Quad"), {
            Thickness = settings.esp.box.thickness + 1.5,
            Filled = settings.esp.box.filled,
            Transparency = settings.esp.box.transparency,
            Color = settings.esp.box.outlineColor,
            Visible = settings.esp.box.outline,
            ZIndex = 1
        };
        box = Drawing.new("Quad"), {
            Thickness = settings.esp.box.thickness,
            Filled = false,
            Transparency = settings.esp.box.transparency,
            Color = settings.esp.box.color,
            Visible = settings.esp.box.enabled,
            ZIndex = 2
        };
        traceOutline = Drawing.new("Line"), {
            Thickness = settings.esp.tracer.thickness + 1.5,
            Color = settings.esp.tracer.outlineColor,
            Transparency = settings.esp.tracer.transparency,
            Visible = false,
            ZIndex = 1
        };
        trace = Drawing.new("Line"), {
            Thickness = settings.esp.tracer.thickness,
            Color = settings.esp.tracer.color,
            Transparency = settings.esp.tracer.transparency,
            Visible = false,
            ZIndex = 2
        };
        name = Drawing.new("Text"), {
            Text = "nil",
            Color = settings.esp.name.color,
            Font = settings.esp.name.font,
            Size = settings.esp.name.size,
            Center = settings.esp.name.center,
            Outline = settings.esp.name.outline,
            OutlineColor = settings.esp.name.outlineColor
        };
        weapon = Drawing.new("Text"), {
            Text = "nil",
            Color = settings.esp.weapon.color,
            Font = settings.esp.weapon.font,
            Size = settings.esp.weapon.size,
            Center = settings.esp.weapon.center,
            Outline = settings.esp.weapon.outline,
            OutlineColor = settings.esp.weapon.outlineColor
        };
    }
    self.connection = RUN_SERVICE.RenderStepped:Connect(function() self:update_esp() end);
    table.insert(esp.cache, self);
    return self;
end

for _, child in pairs(workspace:GetChildren()) do
    if child:IsA("Model") and PLAYERS:FindFirstChild(child.Name) and child.Name ~= localPlayer.Name then
        esp.new_object(child);
    end
end

-- Function Hooks
local silentHook;
local fireHook;

silentHook = hookfunction(new_proj, function(...)
    local args = {...};

    args[6] = (settings.combat.silentAim and closestDir) or args[6];

    return silentHook(table.unpack(args));
end);

fireHook = hookfunction(fire, function(...)
    local args = {...};

    if settings.combat.infiniteAmmo then
        local ammoVal = args[1].Ammo;
        args[1].Ammo += 1;
    end
    if settings.combat.rapidFire then
        args[1].FireRate /= 2;
    end
    if settings.combat.noSpread then
        args[1].Spread = 0;
    end

    return fireHook(table.unpack(args))
end);

-- Connections
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and PLAYERS:FindFirstChild(child.Name) and child.Name ~= localPlayer.Name then
        esp.new_object(child);
    end
end);

workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") then
        for _, value in pairs(esp.cache) do
            if typeof(value) == "table" and value.model == child then
                value:remove_object();
                break;
            end
        end
    end
end);

-- FOV Circle bullshit
local Circle = Drawing.new("Circle");
RUN_SERVICE.RenderStepped:Connect(function()
    Circle.NumSides = settings.combat.fovCircle.sides;
    Circle.Color = settings.combat.fovCircle.color;
    Circle.Transparency = settings.combat.fovCircle.transparency;
    Circle.Radius = settings.combat.fovCircle.radius;
    Circle.Filled = settings.combat.fovCircle.filled;
    Circle.Visible = settings.combat.fovCircle.enabled;
    Circle.Thickness = settings.combat.fovCircle.thickness;
    Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
end)

-- Rest of the UI shit
UI_silentAim:AddToggle("silentAim", {
    Text = "Enabled",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.silentAim = Value;
    end
})
UI_silentAim:AddDivider()
UI_silentAim:AddToggle("silentAimFOV", {
    Text = "Show FOV Circle",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.fovCircle.enabled = Value;
    end
})
UI_silentAim:AddSlider("FOV Radius", {
    Text = "Radius",
    Default = 75,
    Min = 20,
    Max = 800,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.combat.fovCircle.radius = Value;
    end
})
UI_silentAim:AddSlider("FOV Transparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.combat.fovCircle.transparency = Value;
    end
})
UI_silentAim:AddSlider("FOV Thickness", {
    Text = "Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.combat.fovCircle.thickness = Value;
    end
})
UI_silentAim:AddLabel("Color"):AddColorPicker("FOVCircleColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "FOV Color",
    Callback = function(Value)
        settings.combat.fovCircle.color = Value;
    end
})
UI_triggerBot:AddToggle("triggerBot", {
    Text = "Enabled",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.triggerBot = Value;
    end
})
UI_gunMods:AddToggle("Infinite Ammo", {
    Text = "Infinite Ammo",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.infiniteAmmo = Value;
    end
})
UI_gunMods:AddToggle("Rapid Fire", {
    Text = "Faster Firerate",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.rapidFire = Value;
    end
})
UI_gunMods:AddToggle("No Spread", {
    Text = "No Spread",
    Default = false,
    Tooltip = "",

    Callback = function(Value)
        settings.combat.noSpread = Value;
    end
})
UI_playerBox:AddToggle("BoxESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Box ESP",
    Callback = function(Value)
        settings.esp.box.enabled = Value;
    end
})
UI_playerBox:AddToggle("BoxESPOutline", {
    Text = "Outline",
    Default = false,
    Tooltip = "Enable/Disable Box Outline",
    Callback = function(Value)
        settings.esp.box.outline = Value;
    end
})
UI_playerBox:AddSlider("BoxThickness", {
    Text = "Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.box.thickness = Value;
    end
})
UI_playerBox:AddSlider("BoxTransparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.box.transparency = Value;
    end
})
UI_playerBox:AddLabel("Box Color"):AddColorPicker("BOXCOLOR", {
    Default = settings.esp.box.color,
    Title = "box color",

    Callback = function(Value)
        settings.esp.box.color = Value;
    end
})

UI_playerTracer:AddToggle("TracerESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Tracer ESP",
    Callback = function(Value)
        settings.esp.tracer.enabled = Value;
    end
})
UI_playerTracer:AddToggle("TracerESPOutline", {
    Text = "Outline",
    Default = false,
    Tooltip = "Enable/Disable Box Outline",
    Callback = function(Value)
        settings.esp.tracer.outline = Value;
    end
})
UI_playerTracer:AddSlider("TracerThickness", {
    Text = "Thickness",
    Default = 2,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.tracer.thickness = Value;
    end
})
UI_playerTracer:AddSlider("TracerTransparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.tracer.transparency = Value;
    end
})
UI_playerTracer:AddLabel("Trace Color"):AddColorPicker("TRACECOLOR", {
    Default = settings.esp.tracer.color,
    Title = "tracer color",

    Callback = function(Value)
        settings.esp.tracer.color = Value;
    end
})
UI_playerName:AddToggle("NameESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Name ESP",
    Callback = function(Value)
        settings.esp.name.enabled = Value;
    end
})
UI_playerName:AddToggle("NameOutline", {
    Text = "Outline",
    Default = true,
    Tooltip = "Enable/Disable Name Outline",
    Callback = function(Value)
        settings.esp.name.outline = Value;
    end
})
UI_playerName:AddSlider("NameSize", {
    Text = "Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.name.size = Value;
    end
})
UI_playerName:AddLabel("Text Color"):AddColorPicker("NAMECOLOR", {
    Default = settings.esp.name.color,
    Title = "name color",

    Callback = function(Value)
        settings.esp.name.color = Value;
    end
})
UI_playerWeapon:AddToggle("WeaponESP", {
    Text = "Enabled",
    Default = false,
    Tooltip = "Enable/Disable Weapon (TEXT) ESP",
    Callback = function(Value)
        settings.esp.weapon.enabled = Value;
    end
})
UI_playerWeapon:AddToggle("WeaponOutline", {
    Text = "Outline",
    Default = true,
    Tooltip = "Enable/Disable Weapon (TEXT) Outline",
    Callback = function(Value)
        settings.esp.weapon.outline = Value;
    end
})
UI_playerWeapon:AddSlider("WeaponSize", {
    Text = "Size",
    Default = 13,
    Min = 4,
    Max = 15,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        settings.esp.weapon.size = Value;
    end
})
UI_playerWeapon:AddLabel("Text Color"):AddColorPicker("WEAPONCOLOR", {
    Default = settings.esp.weapon.color,
    Title = "weapon color",

    Callback = function(Value)
        settings.esp.weapon.color = Value;
    end
})

local MenuGroup = tabs["UI Settings"]:AddRightGroupbox('Menu');
MenuGroup:AddButton('Unload', function() Library:Unload() end);
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' });
Library.ToggleKeybind = Options.MenuKeybind;
ThemeManager:SetLibrary(Library);
ThemeManager:SetFolder('MyScriptHub');
ThemeManager:ApplyToTab(tabs['UI Settings']);
