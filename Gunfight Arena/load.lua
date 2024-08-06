local fovRadius = 120;
local fovColor = Color3.fromRGB(255, 255, 255);

run_on_actor(getactors()[1], game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/Gunfight%20Arena/silent_aim_wave.lua", fovRadius);
loadstring(game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/Gunfight%20Arena/infinite_ammo_no_reload.lua")();

local circle = Drawing.new"Circle";
circle.Radius = fovRadius;
circle.Position = workspace.CurrentCamera.ViewportSize / 2;
circle.Transparency = 1;
circle.NumSides = 256;
circle.Color = fovColor;
circle.Visible = true;
