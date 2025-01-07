local DETECTION_SIGNALS = {
    ["124"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '124' [INSTANCE_DETECTED]";
    end,
    ["202"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '202' [INSTANCE_DETECTED]";
    end,
    ["203"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '203' [INSTANCE_DETECTED_OR_COREGUI_WEAKT]";
    end,
    ["204"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '204' [SCRIPT_CONTEXT_ERROR]";
    end,
    ["205"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '205' [SIGNALS/NETWORK_MODULE_TAMPER]";
    end,
    ["206"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '206' [_G_VAR_DETECTED]";
    end,
    ["envSpoof"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '206' [GETFENV_TRAP_TRIGGERED]";
    end,
    ["72"] = function(vargs)
        rconsolewarn"BLOCKED DETECTION '72' [GETFENV_TRAP_TRIGGERED]";
    end
};

local fire;

for k, v in getgc(true) do
    if type(v) == "table" and type(rawget(v, "fireUnreliable")) == "function" then
        fire = rawget(v, "fire");
        break;
    end
end

local encode = debug.getupvalue(fire, 2);
local remote = debug.getupvalue(fire, 3);

hookfunction(fire, function(a_1, ...)
    if DETECTION_SIGNALS[a_1] then
        DETECTION_SIGNALS[a_1]{...};
        return;
    end

    remote:FireServer(encode(a_1), ...);
end);

return true;
