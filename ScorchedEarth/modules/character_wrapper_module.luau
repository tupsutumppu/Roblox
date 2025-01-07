local local_player = cloneref(game.Players.LocalPlayer);

local character_wrapper = {};
character_wrapper.__index = character_wrapper;
character_wrapper.cache = {};

function character_wrapper.new(char)
    local self = setmetatable({}, character_wrapper);

    self.char = char;
    self.on_destroy_conns = {};

    return self;
end

function character_wrapper:destroy()
    for i, conn in self.on_destroy_conns do
        conn();
    end

    table.clear(self.on_destroy_conns);
    table.clear(self);
end

function character_wrapper:on_destroy(func)
    table.insert(self.on_destroy_conns, func);
end

function character_wrapper:is_friendly()
    return self.char.team == local_player.team.Name;
end

function character_wrapper:get_primary_cf()
    return self.char.bodyModel.PrimaryPart.CFrame;
end

function character_wrapper:get_body_part(name)
    return self.char.bodyModel[name];
end

function character_wrapper:get_name()
    return self.char.name;
end

function character_wrapper:get_velocity()
    return self.char.localVel;
end

return character_wrapper;
