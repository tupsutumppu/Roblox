-- // Made by tupsutumppu ( made in early 2023?? )
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("PTFS Plane Speed Modifier")
local serv = win:Server("super op script", "")
local maxSpeedChannel = serv:Channel("Max Speed")
local accelerationChannel = serv:Channel("Acceleration")

local settings = {
    maxSpeed = nil,
    acceleration = nil
}

local function mod(target, value)
    for _, v in pairs(getgc()) do
        if type(v) == "function" and tostring(getfenv(v).script) == "Control" then
            local upvalues = debug.getupvalues(v)
            for i, upvalue in pairs(upvalues) do
                if upvalue == target then
                    debug.setupvalue(v, i, value)
                    local str = "Original value: " .. tostring(target) .. " | New Value: " .. tostring(value)
                    DiscordLib:Notification("Success!" ,str, "Close")
                end
            end
            break
        end
    end
end

maxSpeedChannel:Textbox("MaxSpeed", "Type here!", true, function(text)
    settings.maxSpeed = tonumber(text) or settings.maxSpeed
end)

maxSpeedChannel:Button("Apply New MaxSpeed", function()
    if settings.maxSpeed ~= nil then
        local seatPart = game.Players.LocalPlayer.Character.Humanoid.SeatPart
        if seatPart then
            local fullName = seatPart:GetFullName()
            local secondName = fullName:split(".")[3]
            local maxSpeedValue = game.Workspace.Aircraft[tostring(secondName)]:GetAttribute("MaxSpeed")
            mod(maxSpeedValue, settings.maxSpeed)
        else
            DiscordLib:Notification("Notification", "Must be in a plane!", "Close")
        end
    else
        DiscordLib:Notification("Notification", "MaxSpeed cannot be 'nil'. Did you forget to press 'Enter' after providing a value?", "Close")
    end
end)

accelerationChannel:Textbox("Acceleration", "Type here!", true, function(text)
    settings.acceleration = tonumber(text) or settings.acceleration
end)

accelerationChannel:Button("Apply New Acceleration", function()
    if settings.acceleration ~= nil then
        local seatPart = game.Players.LocalPlayer.Character.Humanoid.SeatPart
        if seatPart then
            local fullName = seatPart:GetFullName()
            local secondName = fullName:split(".")[3]
            local accelerationValue = game.Workspace.Aircraft[tostring(secondName)]:GetAttribute("Acceleration")
            mod(accelerationValue, settings.acceleration)
        else
            DiscordLib:Notification("Notification", "Must be in a plane!", "Close")
        end
    else
        DiscordLib:Notification("Notification", "Acceleration cannot be 'nil'. Did you forget to press 'Enter' after providing a value?", "Close")
    end
end)
