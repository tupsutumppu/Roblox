-- // D-DAY Silent aim | Discord: #tupsutumppu | v3rm: https://v3rm.net/members/tupsu.4716/
local PLAYERS = game:GetService "Players";

local camera = workspace.CurrentCamera;
local localPlayer = PLAYERS.LocalPlayer;
local fovRadius = 80;

local worldToViewportPoint = clonefunction(camera.WorldToViewportPoint);
local getPlayers = clonefunction(PLAYERS.GetPlayers);
local findFirstChild = clonefunction(game.FindFirstChild);

--[[
    I don't know what is wrong with Wave's hookmetamethod, but it seems to completely mess up __namecall.
    Every time I use __namecall within the hook or in the 'getClosestHeadPos', it causes an error like: "GetPlayers is not a valid member of Workspace 'Workspace'"
    or "WorldToViewportPoint is not a valid member of Workspace 'Workspace'", even though I clearly called the methods on valid services and instances.
]]

local function getClosestHeadPos()
    local closest;
    local maxDist = math.huge;

    for _, player in getPlayers(PLAYERS) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character then
            local head = findFirstChild(player.Character, "Head");

            if head then
                local pos = head.CFrame.Position;
                local screenPos, onScreen = worldToViewportPoint(camera, pos);

                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - (camera.ViewportSize / 2)).Magnitude;

                    if distance < fovRadius then
                        distance = (camera.CFrame.Position - pos).Magnitude;

                        if distance < maxDist then
                            maxDist = distance;
                            closest = pos;
                        end;
                    end;
                end;
            end;
        end;
    end;

    return closest;
end;

local oldNamecall;
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod();

    if not checkcaller() and method == "FindPartOnRay" and select(-1, ...) == localPlayer.Character then
        local ray = debug.getstack(3, 9);
        local closestHeadPos = getClosestHeadPos();

        if closestHeadPos then
            debug.setstack(3, 9, Ray.new(ray.Origin, closestHeadPos - ray.Origin));
        end;
    end;

    return oldNamecall(...);
end));

local circle = Drawing.new("Circle");
circle.Color = Color3.fromRGB(255, 255, 255);
circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
circle.Radius = fovRadius;
circle.NumSides = 128;
circle.Visible = true;
