local RUN_SERVICE = cloneref(game:GetService"RunService");
local camera = cloneref(workspace.CurrentCamera);

local esp_module = {};
esp_module.cache = {};
esp_module.config = {
    team = {
        box = false,
        box_outline = true,
        box_color = Color3.fromRGB(255, 255, 255),
        box_outline_color = Color3.fromRGB(),
        box_thickness = 2,
        box_transparency = 1,

        tracer = false,
        tracer_outline = true,
        tracer_color = Color3.fromRGB(255, 255, 255);
        tracer_outline_color = Color3.fromRGB();
        tracer_thickness = 2,
        tracer_transparency = 1,

        name = false,
        name_outline = true,
        name_color = Color3.fromRGB(255, 255, 255),
        name_outline_color = Color3.fromRGB(),
        name_size = 14,
        name_transparency = 1
    },
    enemy = {
        box = false,
        box_outline = true,
        box_color = Color3.fromRGB(255, 255, 255);
        box_outline_color = Color3.fromRGB(),
        box_thickness = 2,
        box_transparency = 1,

        tracer = false,
        tracer_outline = true,
        tracer_color = Color3.fromRGB(255, 255, 255);
        tracer_outline_color = Color3.fromRGB();
        tracer_thickness = 2,
        tracer_transparency = 1,

        name = false,
        name_outline = true,
        name_color = Color3.fromRGB(255, 255, 255),
        name_outline_color = Color3.fromRGB(),
        name_size = 14,
        name_transparency = 1
    }
};

local esp_obj = {};
esp_obj.__index = esp_obj;

function esp_module:add_esp(character_wrapper)
    local char = character_wrapper.char;
    self.cache[char.name] = esp_obj.new(character_wrapper);
end

function esp_module:remove_esp(character_wrapper)
    local char = character_wrapper.char;
    self.cache[char.name]:destroy();
    self.cache[char.name] = nil;
end

function esp_module:init(character_handler)
    character_handler:on_char_add(function(character_wrapper)
        self:add_esp(character_wrapper);
    end);
    character_handler:on_char_removed(function(character_wrapper)
        self:remove_esp(character_wrapper);
    end);
end

function esp_obj.new(character_wrapper)
    local self = setmetatable({}, esp_obj);

    self.wrapper = character_wrapper;
    self.drawings = {
        box = Drawing.new"Quad",
        box_outline = Drawing.new"Quad",
        tracer = Drawing.new"Line",
        tracer_outline = Drawing.new"Line",
        name = Drawing.new"Text"
    };
    self.connection = RUN_SERVICE.RenderStepped:Connect(function()
        self:render();
    end);

    return self;
end

function esp_obj:destroy()
    self.connection:Disconnect();

    for k, v in self.drawings do
        v:Remove();
    end

    table.clear(self);
end

function esp_obj:render()
    local wrapper = self.wrapper;
    local drawings = self.drawings;

    local primary_cf = wrapper:get_primary_cf();
    local screen_pos, on_screen = camera:WorldToViewportPoint(primary_cf.Position);

    if on_screen then
        local top_left = camera:WorldToViewportPoint(primary_cf * CFrame.new(-3, 3, 0).Position);
        local top_right = camera:WorldToViewportPoint(primary_cf * CFrame.new(3, 3, 0).Position);
        local bottom_left = camera:WorldToViewportPoint(primary_cf * CFrame.new(-3, -3, 0).Position);
        local bottom_right = camera:WorldToViewportPoint(primary_cf * CFrame.new(3, -3, 0).Position);

        local config = if wrapper:is_friendly() then esp_module.config.team else esp_module.config.enemy;

        if config.box then
            local point_a = Vector2.new(top_right.X, top_right.Y);
            local point_b = Vector2.new(top_left.X, top_left.Y);
            local point_c = Vector2.new(bottom_left.X, bottom_left.Y);
            local point_d = Vector2.new(bottom_right.X, bottom_right.Y);

            local outline = drawings.box_outline;
            local box = drawings.box;

            outline.PointA = point_a;
            outline.PointB = point_b;
            outline.PointC = point_c;
            outline.PointD = point_d;

            outline.Color = config.box_outline_color;
            outline.Thickness = config.box_thickness + 1.5;
            outline.Transparency = config.box_transparency;
            outline.Visible = config.box_outline;

            box.PointA = point_a;
            box.PointB = point_b;
            box.PointC = point_c;
            box.PointD = point_d;

            box.Color = config.box_color;
            box.Thickness = config.box_thickness;
            box.Transparency = config.box_transparency;
            box.Visible = true;
            box.ZIndex = 2;
        else
            drawings.box_outline.Visible = false;
            drawings.box.Visible = false;
        end

        if config.tracer then
            local from = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) 
            local to = Vector2.new(screen_pos.X, screen_pos.Y);

            local outline = drawings.tracer_outline;
            local tracer = drawings.tracer;

            outline.From = from;
            outline.To = to;
            outline.Color = config.tracer_outline_color;
            outline.Thickness = config.tracer_thickness + 1.5;
            outline.Transparency = config.tracer_transparency;
            outline.Visible = config.tracer_outline;

            tracer.From = from;
            tracer.To = to;
            tracer.Color = config.tracer_color;
            tracer.Thickness = config.tracer_thickness;
            tracer.Transparency = config.tracer_transparency;
            tracer.Visible = true;
            tracer.ZIndex = 2;
        else
            drawings.tracer_outline.Visible = false;
            drawings.tracer.Visible = false;
        end

        if config.name then
            local name = drawings.name;

            name.Position = Vector2.new((top_left.X + top_right.X) / 2, ((top_left.Y + top_right.Y) / 2) - (name.TextBounds.Y + 2));
            name.Text = wrapper:get_name();
            name.Color = config.name_color;
            name.Outline = config.name_outline;
            name.OutlineColor = config.name_outline_color;
            name.Center = true;
            name.Transparency = config.name_transparency;
            name.Size = config.name_size;
            name.Font = 2;
            name.Visible = true;
        else
            drawings.name.Visible = false;
        end
    else
        drawings.box_outline.Visible = false;
        drawings.box.Visible = false;
        drawings.tracer_outline.Visible = false;
        drawings.tracer.Visible = false;
        drawings.name.Visible = false;
    end
end

return esp_module;
