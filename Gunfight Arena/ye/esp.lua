local RUN_SERVICE = cloneref(game:GetService"RunService");
local PLAYERS = cloneref(game:GetService"Players");

local espConfig = ...;
local localPlayer = PLAYERS.LocalPlayer;
local camera = workspace.CurrentCamera;

local espObject = {};
espObject.__index = espObject;

local esp = {
    _cache = {};
};

function esp:createObject(player, character)
    local object = espObject.new(player, character);
    self._cache[player.Name] = object;
end

function esp:removeObject(player)
    local object = assert(self._cache[player.Name], "Attempt to remove object which does not exist!");
    object:destroy();
    self._cache[player.Name] = nil;
end
function espObject:isFriendly(): boolean
    return self.player:GetAttribute"Team" == localPlayer:GetAttribute"Team";
end

function espObject:_render()
    local drawings = self._drawings;

    if self.character then
        local character = self.character;
        local pivot = character:GetPivot();
        local screenPos, onScreen = camera:WorldToViewportPoint(pivot.Position);

        if onScreen and not self:isFriendly() then
            local tL = camera:WorldToViewportPoint((pivot * CFrame.new(-3, 3, 0)).Position);
            local tR = camera:WorldToViewportPoint((pivot * CFrame.new(3, 3, 0)).Position);
            local bL = camera:WorldToViewportPoint((pivot * CFrame.new(-3, -3, 0)).Position);
            local bR = camera:WorldToViewportPoint((pivot * CFrame.new(3, -3, 0)).Position);

            if espConfig.box:get() then
                local box = drawings.box;
                local boxOutline = drawings.boxOutline;

                boxOutline.PointA = Vector2.new(tR.X, tR.Y);
                boxOutline.PointB = Vector2.new(tL.X, tL.Y);
                boxOutline.PointC = Vector2.new(bL.X, bL.Y);
                boxOutline.PointD = Vector2.new(bR.X, bR.Y);
                boxOutline.Thickness = espConfig.boxThickness:get() + 2;
                boxOutline.Transparency = espConfig.boxTransparency:get();
                boxOutline.Visible = espConfig.boxOutline:get();

                box.PointA = boxOutline.PointA;
                box.PointB = boxOutline.PointB;
                box.PointC = boxOutline.PointC;
                box.PointD = boxOutline.PointD;
                box.Color = espConfig.boxColor:get();
                box.ZIndex = 2;
                box.Thickness = boxOutline.Thickness - 2;
                box.Transparency = espConfig.boxTransparency:get();
                box.Visible = true;
            else
                drawings.boxOutline.Visible = false;
                drawings.box.Visible = false;
            end

            if espConfig.tracer:get() then
                local tracer = drawings.tracer;
                local tracerOutline = drawings.tracerOutline;

                tracerOutline.Thickness = espConfig.tracerThickness:get() + 2;
                tracerOutline.Transparency = espConfig.tracerTransparency:get();
                tracerOutline.Visible = espConfig.tracerOutline:get();
                tracerOutline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
                tracerOutline.To = Vector2.new(screenPos.X, screenPos.Y);

                tracer.Thickness = tracerOutline.Thickness - 2;
                tracer.ZIndex = 2;
                tracer.Color = espConfig.tracerColor:get();
                tracer.Transparency = espConfig.tracerTransparency:get();
                tracer.Visible = true;
                tracer.From = tracerOutline.From;
                tracer.To = tracerOutline.To;
            else
                drawings.tracerOutline.Visible = false;
                drawings.tracer.Visible = false;
            end

            if espConfig.name:get() then
                local name = drawings.name;
                name.Text = self.name;
                name.Color = espConfig.nameColor:get();
                name.Outline = espConfig.nameOutline:get();
                name.Center = true;
                name.Size = espConfig.nameSize:get();
                name.Position = Vector2.new((tL.X + tR.X) / 2, ((tL.Y + tR.Y) / 2) - (name.TextBounds.Y + 5));
                name.Transparency = espConfig.nameTransparency:get();
                name.Visible = true;
            else
                drawings.name.Visible = false;
            end
        else
            drawings.boxOutline.Visible = false;
            drawings.box.Visible = false;
            drawings.tracerOutline.Visible = false;
            drawings.tracer.Visible = false;
            drawings.name.Visible = false;
        end
    else
        drawings.boxOutline.Visible = false;
        drawings.box.Visible = false;
        drawings.tracerOutline.Visible = false;
        drawings.tracer.Visible = false;
        drawings.name.Visible = false;
    end
end

function espObject.new(player: Player | Folder, character: Model): espObject
    assert(player and character, "lol");
    local self = setmetatable({}, espObject);
    self.player = player;
    self.character = character;
    self.name = player.Name;
    self._drawings = {
        boxOutline = Drawing.new("Quad");
        box = Drawing.new("Quad");
        tracerOutline = Drawing.new("Line");
        tracer = Drawing.new("Line");
        name = Drawing.new("Text");
    };
    self._connection = RUN_SERVICE.RenderStepped:Connect(function()
        self:_render();
    end);
    return self;
end

function espObject:destroy()
    self._connection:Disconnect();
    for _, drawing in self._drawings do
        drawing:Remove();
    end
    table.clear(self);
end

function espObject:updateCharacter(character)
    self.character = character;
end

function esp:init()
    for _, player in PLAYERS:GetChildren() do
        if player ~= localPlayer then
            local character = workspace:FindFirstChild(player.Name);

            if player and character then
                self:createObject(player, character);
            end
        end
    end
    workspace.ChildAdded:Connect(function(child)
        local player = PLAYERS:FindFirstChild(child.Name);

        if player and player ~= localPlayer and self._cache[player.Name] then
            self._cache[player.Name]:updateCharacter(child);
        elseif player then
            self:createObject(player, child)
        end
    end);
    PLAYERS.ChildRemoved:Connect(function(player)
        self:removeObject(player);
    end);
end

return esp;
