local PLAYERS = cloneref(game:GetService"Players");

local localPlayer = PLAYERS.LocalPlayer;
local playerScripts = localPlayer.PlayerScripts
local vortex = playerScripts:WaitForChild"Vortex";
local camera = workspace.CurrentCamera;

vortex:GetPropertyChangedSignal("Disabled"):Connect(function()
    local senv = getsenv(vortex);

    if senv and task.wait(1) then
        local fire = rawget(senv, "Fire");
        local restock = rawget(senv, "Restock");

        setmetatable(debug.getupvalue(fire, 3), {
            __index = function(self, key)
                if key == "Compressor" and debug.info(2, "n") == "Fire" then
                    if debug.getupvalue(2, 17) == 0 then
                        restock();
                        debug.setupvalue(2, 50, 999);
                    end
                end
                return rawget(self, key);
            end
        });
    end
end);
