local BULLET_FIRE_SUB_CODE = "1181";

local camera = cloneref(workspace.CurrentCamera);
local signal_module, character_module = ...;

local combat_module = {};
combat_module.config = {
    silent_aim = false,
    target_part = "head"
};

local circle = Drawing.new"Circle";
circle.Position = camera.ViewportSize / 2;
circle.Visible = true;
circle.NumSides = 128;
circle.Color = Color3.fromRGB(255, 255, 255);
circle.Radius = 150;

combat_module.fov_circle = circle;

function combat_module:get_closest_char()
    local characters = character_module:get_characters();
    local best_angle = math.huge;
    local closest_char;

    for _, char in characters do
        local primary_cf = char:get_primary_cf();
        local screen_pos, on_screen = camera:WorldToViewportPoint(primary_cf.Position);

        if on_screen and not char:is_friendly() then
            local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - (camera.ViewportSize / 2)).Magnitude;

            if distance <= self.fov_circle.Radius then
                local direction = (primary_cf.Position - camera.CFrame.Position).Unit;
                local angle = math.acos(camera.CFrame.LookVector:Dot(direction));

                if angle < best_angle then
                    best_angle = angle;
                    closest_char = char;
                end
            end
        end
    end

    return closest_char;
end

local config = combat_module.config;
signal_module:hook_invoke(BULLET_FIRE_SUB_CODE, function(ret_val)
    local static_data = debug.getstack(3, 1).itemData.staticData;

    if config.silent_aim then
        local closest_char = combat_module:get_closest_char();

        if closest_char then
            local target_part = closest_char:get_body_part(config.target_part);
            local speed = static_data.velocity;

            ret_val.gravity = setmetatable({}, {
                __mul = function(self, value)
                    local bullet_data = debug.getstack(2, 6);

                    local bullet_pos = bullet_data.startP;
                    local target_pos = target_part.CFrame.Position;

                    bullet_data.startV = (target_pos - bullet_pos).Unit * speed;

                    return Vector3.zero;
                end
            });
        end
    end
end);

return combat_module;
