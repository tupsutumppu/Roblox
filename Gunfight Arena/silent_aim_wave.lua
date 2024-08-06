local RUN_SERVICE = cloneref(game:GetService"RunService");
local PLAYERS = cloneref(game:GetService"Players");

local localPlayer = PLAYERS.LocalPlayer;
local camera = workspace.CurrentCamera;
local screenCenter = camera.ViewportSize / 2;

local secondThread = localPlayer.PlayerScripts.SecondThread.SecondThread;
local tracerCalc = rawget(getsenv(secondThread), "TracerCalc");

local fovRadius = tonumber(...);
local closestHead;

setmetatable(debug.getupvalue(tracerCalc, 1), {
    __newindex = function(self, index, value)
        if rawget(value, "Shooter") == localPlayer and closestHead then
            rawset(value, "vel", 99999);
            rawset(value, "start", CFrame.lookAt(rawget(value, "start").Position, closestHead.CFrame.Position));
        end
        return rawset(self, index, value);
    end;
});

-- // Not the best loop but idgaf
RUN_SERVICE.Heartbeat:Connect(function()
    local closest;
    local bestAngle = math.huge;

    for _, player in PLAYERS:GetChildren() do
        local isPlayer = player:IsA"Player";
        local character = isPlayer and player.Character or workspace:FindFirstChild(player.Name);
        local team = isPlayer and player.Team or player:GetAttribute"Team";

        if character and team ~= localPlayer.Team then
            local head = character:FindFirstChild"Head";

            if head then
                local pivot = character:GetPivot();
                local screenPos, onScreen = camera:WorldToViewportPoint(pivot.Position);
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude;

                if onScreen and distance <= fovRadius then
                    local direction = (pivot.Position - camera.CFrame.Position).Unit;
                    local angle = math.acos(camera.CFrame.LookVector:Dot(direction));

                    if angle < bestAngle then
                        bestAngle = angle;
                        closest = head;
                    end
                end
            end
        end
    end
    closestHead = closest
end);
