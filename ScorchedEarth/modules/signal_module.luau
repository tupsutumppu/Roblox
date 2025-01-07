local new;
local invoke;
local subscribe;
local fire;

for k, v in getgc(true) do
    if type(v) == "table" and type(rawget(v, "forgetAndFire")) == "function" then
		    new       = rawget(v, "new");
        invoke    = rawget(v, "invoke");
        subscribe = rawget(v, "subscribe");
        fire      = rawget(v, "fire");
		    break;
	  end
end

local signal_cache = debug.getupvalue(invoke, 2);

local signal_module = {};
signal_module.invoke_hooks = {};

-- // Hook invoke
local invoke_hooks = signal_module.invoke_hooks;
hookfunction(invoke, function(signal_name, ...)
    local signal = signal_cache[signal_name];

    if signal then
        local result = nil;

        for _, v in signal do
            local return_val = v(...);

            if not result then
                result = return_val;
            end

            local hook = invoke_hooks[signal_name];

            if result and hook then
                hook(result);
            end
        end

        return result;
    end
end);

function signal_module:safe_new(signal_name)
    if not signal_cache[signal_name] then
        signal_cache[signal_name] = {};
    end
    return signal_cache[signal_name];
end

function signal_module:safe_subscribe(signal_name, callback, index)
    local signal = signal_cache[signal_name] or self:new(signal_name);

    if index then
        table.insert(signal, index, callback);
    else
        table.insert(signal, callback);
    end
end

function signal_module:hook_invoke(signal_name, hook)
    self.invoke_hooks[signal_name] = hook;
end

return signal_module;
