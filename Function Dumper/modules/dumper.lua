local dumper = {};
local repr1_2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/EjRqoN/Roblox/main/Function%20Dumper/modules/repr1_2.lua"))();

local reprSettings = {
	pretty = true;
	robloxFullName = false;
	robloxProperFullName = false;
	robloxClassName = false;
	tabs = true;
	semicolons = false;
	spaces = 4;
	sortKeys = false;
}

function dumper.save_to_file(parts, scr)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name;
    local folder = (isfolder(gameName) and gameName) or makefolder(gameName);
    local fileName = `{folder}/{tostring(scr)}_{math.floor(math.random(1, 999))}.txt`; -- boohoo

    for _, part in parts do
        appendfile(fileName, part .. "\n-----------------------------------------\n");
    end
end

function dumper.function_dump(scr)
    local functions = {};
    local dump = {};

    local function get_args(numparams)
        local argStr = "";

        for arg = 1, numparams do
            argStr ..= (arg ~= numparams and `a{arg}, `) or `a{arg}`;
        end

        return argStr;
    end

    local function table_to_string(tbl)
        local str = "{\n";

        for key, value in tbl do
            str ..= `\t{key} = {value}\n`;
        end

        str ..= "}";
        return str;
    end

    for _, value in getgc() do
        if typeof(value) == "function" and islclosure(value) then
            local info = debug.getinfo(value);

            if string.find(info.short_src, scr:GetFullName()) and rawget(getfenv(value), "script") == scr then
                functions[value] = {
                    info = info;
                    upvalues = debug.getupvalues(value);
                    constants = debug.getconstants(value);
                    protos = debug.getprotos(value, true);
                };
            end
        end
    end

    for _, func in functions do
        local tempDump = "";

        do
            local upvalueStr = "";

            if #func.upvalues > 0 then

                for key, value in func.upvalues do
                    if typeof(value) == "function" then
                        local info = debug.getinfo(value);
                        upvalueStr ..= `upvalue[{key}] = function {(info.name or "__UNNAMED PROTO__")}({(info.is_vararg ~= 1 and get_args(info.numparams)) or "..."})\n`;

                    elseif typeof(value) == "table" then
                        upvalueStr ..= `upvalue[{key}] = {repr1_2(value, reprSettings)}\n`;
    
                    else
                        upvalueStr ..= `upvalue[{key}] = {value}\n`;
                    end
                end
            end

            tempDump ..= upvalueStr;
        end

        tempDump ..= `\nfunction {(func.info.name or "__UNNAMED__")}({(func.info.is_vararg ~= 1 and get_args(func.info.numparams)) or "..."})\n\n`;

        do

            local constantStr = "";

            if #func.constants > 0 then

                for key, value in func.constants do
                    constantStr ..= `\tconstant[{key}] = {value}\n`;
                end
            end

            tempDump ..= constantStr;
        end

        do
            local protoStr = "\t";

            if #func.protos > 0 then

                for key, value in func.protos do
                    local info = debug.getinfo(value);
                    local constants = debug.getconstants(value);
                    protoStr ..= `\n\tproto[{key}] = function {(info.name or "__UNNAMED PROTO__")}({(info.is_vararg ~= 1 and get_args(info.numparams)) or "..."})`;
                    
                    for f, h in constants do
                        protoStr ..= `\tconstant[{f}] = {h}\n`;
                    end

                    protoStr ..= "\n\tend";
                end
            end

            tempDump ..= protoStr;
        end

        tempDump ..= "\nend\n";
        table.insert(dump, tempDump);
    end

    return dump;
end

return dumper;
