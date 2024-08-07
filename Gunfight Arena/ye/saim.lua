local SHARED_TABLE_REGISTRY = cloneref(game:GetService"SharedTableRegistry");
local RUN_SERVICE = cloneref(game:GetService"RunService");
local PLAYERS = cloneref(game:GetService"Players");

local localPlayer = PLAYERS.LocalPlayer;
local camera = workspace.CurrentCamera;
local screenCenter = camera.ViewportSize / 2;

local secondThread = localPlayer.PlayerScripts.SecondThread.SecondThread;
local tracerCalc = rawget(getsenv(secondThread), "TracerCalc");

local config = SHARED_TABLE_REGISTRY:GetSharedTable(...);
local closestTarget;

setmetatable(debug.getupvalue(tracerCalc, 1), {
    __newindex = function(self, index, value)
        if rawget(value, "Shooter") == localPlayer and config.silentAim and closestTarget then
            rawset(value, "vel", 99999);
            rawset(value, "start", CFrame.lookAt(rawget(value, "start").Position, closestTarget.CFrame.Position));
        end
        return rawset(self, index, value);
    end
});

RUN_SERVICE.Heartbeat:Connect(function()
    local closest;
    local bestAngle = math.huge;

    for _, player in PLAYERS:GetChildren() do
        local character = player:IsA"Player" and player.Character or workspace:FindFirstChild(player.Name);
        local team = player:GetAttribute"Team";

        if character and team ~= localPlayer:GetAttribute"Team" then
            local hitPart = character:FindFirstChild(config.hitPart);

            if hitPart then
                local pivot = character:GetPivot();
                local screenPos, onScreen = camera:WorldToViewportPoint(pivot.Position);
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude;

                if onScreen and distance <= config.fovRadius then
                    local direction = (pivot.Position - camera.CFrame.Position).Unit;
                    local angle = math.acos(camera.CFrame.LookVector:Dot(direction));

                    if angle < bestAngle then
                        bestAngle = angle;
                        closest = hitPart;
                    end
                end
            end
        end
    end
    closestTarget = closest
end);
