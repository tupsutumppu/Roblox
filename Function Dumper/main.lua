local hui = gethui and gethui() or cloneref and cloneref(game:GetService("CoreGui"));
local Iris = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0581/Iris-Exploit-Bundle/main/bundle.lua"))().Init(hui);
local dumper = loadstring(game:HttpGet("https://raw.githubusercontent.com/EjRqoN/Roblox/main/Function%20Dumper/modules/dumper.lua"))();

local scripts = getscripts();
local scriptCache = table.clone(scripts);
local dumpCache = {scr = nil; dumpStr = {}};
local openWindow = nil;

local function render_dumper_window()
    Iris.Window({tostring(openWindow), [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(1000, 800))}) do
        Iris.SameLine() do
            Iris.Text({"dumped by #tupsutumppu"});
            Iris.Separator();

            if Iris.Button({"save to file"}).clicked then
                task.defer(dumper.save_to_file, dumpCache.dumpStr, dumpCache.scr);
            end
        end
        Iris.End();
        Iris.Separator();

        for _, str in pairs(dumpCache.dumpStr) do
            Iris.Text({str});
            Iris.Separator();
        end
    end
    Iris.End();
end

Iris:Connect(function()
    Iris.Window({"Function Dumper", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(450, 500))}) do
        Iris.Text({"Search for scripts"})

        Iris.SameLine() do
            local search = Iris.InputText({""}).text.value;

            if Iris.Button({"Search!"}).clicked then
                scriptCache = {};

                for _, value in pairs(scripts) do
                    local scriptName = tostring(value);

                    if string.find(string.lower(scriptName), string.lower(search)) then
                        table.insert(scriptCache, value);
                    end
                end
            end
        end
        Iris.End();
        Iris.Separator();

        for _, scr in pairs(scriptCache) do

            Iris.Tree({tostring(scr)}) do
                Iris.SameLine() do
                    if Iris.Button({"open"}).clicked then
                        openWindow = scr;

                        if dumpCache.scr ~= scr then
                            dumpCache.scr = scr;
                            dumpCache.dumpStr = dumper.function_dump(scr);
                        end
                    end
                    if Iris.Button({"close"}).clicked then
                        openWindow = nil;
                    end
                end
                Iris.End();
            end
            Iris.End();
        end
    end
    Iris.End();

    if openWindow then
        render_dumper_window();
    end
end);
