local SHARED_TABLE_REGISTRY = cloneref(game:GetService"SharedTableRegistry");
local USER_INPUT_SERVICE = cloneref(game:GetService"UserInputService");
local CORE_GUI = cloneref(game:GetService"CoreGui");

local IrisLoad = loadstring(game:HttpGet("https://raw.githubusercontent.com/peke7374/Iris/main/Iris.lua"))();
local Iris = IrisLoad.Init(CORE_GUI);

local config = {
    silentAim = Iris.State(false);
    hitPart = Iris.State("Head");
    fovRadius = Iris.State(100);

    infAmmo = Iris.State(false);

    drawFov = Iris.State(false);
    fovColor = Iris.State(Color3.fromRGB(255, 255, 255));
    fovTransparency = Iris.State(1);
    fovNumSides = Iris.State(128);
};

local espConfig = {
    box = Iris.State(true);
    boxColor = Iris.State(Color3.fromRGB(255, 105, 180));
    boxTransparency = Iris.State(1);
    boxThickness = Iris.State(2);
    boxOutline = Iris.State(false);

    tracer = Iris.State(false);
    tracerColor = Iris.State(Color3.fromRGB(255, 105, 180));
    tracerTransparency = Iris.State(1);
    tracerThickness = Iris.State(2);
    tracerOutline = Iris.State(false);

    name = Iris.State(true);
    nameColor = Iris.State(Color3.fromRGB(255, 105, 180));
    nameTransparency = Iris.State(1);
    nameSize = Iris.State(13);
    nameOutline = Iris.State(true);
};

local sharedTableName = crypt.generatebytes(12);
local sharedTable = SharedTable.new({
    silentAim = config.silentAim:get();
    fovRadius = config.fovRadius:get();
    hitPart = config.hitPart:get();
});
SHARED_TABLE_REGISTRY:SetSharedTable(sharedTableName, sharedTable);

local esp = loadstring(game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/Gunfight%20Arena/ye/esp.lua")(espConfig);
run_on_actor(getactors()[1], game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/Gunfight%20Arena/ye/saim.lua", sharedTableName);
loadstring(game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/Gunfight%20Arena/ye/gunmods.lua")(config);

local uiKeybind = Iris.State(Enum.KeyCode.Y);
local sWindow = Iris.State(true);

local circle = Drawing.new"Circle";
circle.Radius = config.fovRadius:get();
circle.Color = config.fovColor:get();
circle.Position = workspace.CurrentCamera.ViewportSize / 2;
circle.NumSides = config.fovNumSides:get();
circle.Transparency = config.fovTransparency:get();
circle.Visible = config.drawFov:get();

Iris:Connect(function()
    Iris.Window({"Gunfight Arena", [Iris.Args.Window.NoResize] = true, [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(450, 500)), isOpened = sWindow});
        Iris.CollapsingHeader({"Combat"});
            Iris.Tree({"Aiming"});
                Iris.SeparatorText({"Silent Aim"});
                Iris.Checkbox({"Enabled"}, {isChecked = config.silentAim});
                Iris.Combo({"Hit Part"}, {index = config.hitPart});
                    Iris.Selectable({"Head", "Head"}, {index = config.hitPart});
                    Iris.Selectable({"HumanoidRootPart", "HumanoidRootPart"}, {index = config.hitPart});
                Iris.End();
                Iris.SliderNum({"Fov", 10, 40, 100}, {number = config.fovRadius});
                Iris.TextColored({"Fov limited to '100' because the game doesn't register hits.\nMight fix this later.", Color3.fromRGB(255, 0, 0)});
                Iris.SeparatorText({"Fov Circle"});
                Iris.Checkbox({"Draw Fov Circle"}, {isChecked = config.drawFov});
                Iris.SliderNum({"Transparency", .1, 0, 1}, {number = config.fovTransparency});
                Iris.SliderNum({"NumSides", 6, 32, 256}, {number = config.fovNumSides});
                Iris.InputColor3({"Fov Color"}, {color = config.fovColor});
            Iris.End();
            Iris.Tree({"Gun Mods"});
                Iris.Checkbox({"Infinite Ammo"}, {isChecked = config.infAmmo});
                Iris.TextColored({"Respawn required", Color3.fromRGB(255, 0, 0)});
            Iris.End();
        Iris.End();
        Iris.CollapsingHeader({"ESP"});
            Iris.Tree({"Box"});
                Iris.Checkbox({"Enabled"}, {isChecked = espConfig.box});
                Iris.Checkbox({"Outline"}, {isChecked = espConfig.boxOutline});
                Iris.SliderNum({"Transparency", .1, .1, 1}, {number = espConfig.boxTransparency});
                Iris.SliderNum({"Thickness", .2, 1, 3}, {number = espConfig.boxThickness});
                Iris.InputColor3({"Color"}, {color = espConfig.boxColor});
            Iris.End();
            Iris.Tree({"Tracer"});
                Iris.Checkbox({"Enabled"}, {isChecked = espConfig.tracer});
                Iris.Checkbox({"Outline"}, {isChecked = espConfig.tracerOutline});
                Iris.SliderNum({"Transparency", .1, .1, 1}, {number = espConfig.tracerTransparency});
                Iris.SliderNum({"Thickness", .2, 1, 3}, {number = espConfig.tracerThickness});
                Iris.InputColor3({"Color"}, {color = espConfig.tracerColor});
            Iris.End();
            Iris.Tree({"Name"});
                Iris.Checkbox({"Enabled"}, {isChecked = espConfig.name});
                Iris.Checkbox({"Outline"}, {isChecked = espConfig.nameOutline});
                Iris.SliderNum({"Transparency", .1, .1, 1}, {number = espConfig.nameTransparency});
                Iris.SliderNum({"Size", 1, 6, 20}, {number = espConfig.nameSize});
                Iris.InputColor3({"Color"}, {color = espConfig.nameColor});
            Iris.End();
        Iris.End();
        Iris.CollapsingHeader({"UI Settings"});
            Iris.SameLine();
                if Iris.SmallButton({"Light Theme"}).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight);
                end
                if Iris.SmallButton({"Dark Theme"}).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark);
                end
            Iris.End();
            Iris.SameLine();
                if Iris.SmallButton({"Classic Size"}).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault);
                end
                if Iris.SmallButton({"Larger Size"}).clicked() then
                    Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear);
                end
            Iris.End();
            Iris.ComboEnum({"UI Keybind"}, {index = uiKeybind}, Enum.KeyCode);
        Iris.End();
    Iris.End();
end);

USER_INPUT_SERVICE.InputBegan:Connect(function(input)
    if input.KeyCode == uiKeybind:get() then
        sWindow:set(not sWindow:get());
    end
end);

local function syncConfig()
    sharedTable.silentAim = config.silentAim:get();
    sharedTable.fovRadius = config.fovRadius:get();
    sharedTable.hitPart = config.hitPart:get();
end

config.silentAim:onChange(syncConfig);
config.fovRadius:onChange(syncConfig);
config.hitPart:onChange(syncConfig);

config.fovRadius:onChange(function(state)
    circle.Radius = state;
end);
config.fovColor:onChange(function(state)
    circle.Color = state;
end);
config.fovTransparency:onChange(function(state)
    circle.Transparency = state;
end);
config.fovNumSides:onChange(function(state)
    circle.NumSides = state;
end);
config.drawFov:onChange(function(state)
    circle.Visible = state;
end);

esp:init();
