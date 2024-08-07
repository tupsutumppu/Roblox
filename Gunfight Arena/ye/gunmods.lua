local PLAYERS = cloneref(game:GetService"Players");

local localPlayer = PLAYERS.LocalPlayer;
local playerScripts = localPlayer.PlayerScripts
local vortex = playerScripts:WaitForChild"Vortex";

local config = ...;

vortex:GetPropertyChangedSignal("Disabled"):Connect(function()
    local senv = getsenv(vortex);

    if senv and task.wait(2) then
        local fire = rawget(senv, "Fire");
        local restock = rawget(senv, "Restock");

        setmetatable(debug.getupvalue(fire, 3), {
            __index = function(self, key)
                if key == "Compressor" and debug.info(2, "n") == "Fire" and config.infAmmo:get() then
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
