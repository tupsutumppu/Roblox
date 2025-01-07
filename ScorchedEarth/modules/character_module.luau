local CHAR_SPAWNED_SUB_CODE = "969";
local CHAR_DESPAWNED_SUB_CODE = "938";

local local_player = cloneref(game:GetService"Players".LocalPlayer);

local character_wrapper = assert(loadstring(game:HttpGet"https://raw.githubusercontent.com/tupsutumppu/Roblox/main/ScorchedEarth/modules/character_module.luau")(), "Failed to load character_wrapper!");
local signal_module = ...;

local character_module = {};
character_module.cache = {};
character_module.on_add_conns = {};
character_module.on_removed_conns = {};

function character_module:add_character(char)
	local wrapper = character_wrapper.new(char);
	self.cache[char.name] = wrapper;
	
	for _, conn in self.on_add_conns do
		conn(wrapper);
	end
end

function character_module:remove_character(char)
	local name = char.name;
	local wrapper = self.cache[name];

	for _, conn in self.on_removed_conns do
		conn(wrapper);
	end

	wrapper:destroy();
	self.cache[name] = nil;
end

function character_module:on_char_add(func)
	table.insert(self.on_add_conns, func);
end

function character_module:on_char_removed(func)
	table.insert(self.on_removed_conns, func);
end

function character_module:get_characters()
	return self.cache;
end

signal_module:safe_subscribe(CHAR_SPAWNED_SUB_CODE, function(char, ...)
    if char.name ~= local_player.Name then
        character_module:add_character(char);
    end
end);

signal_module:safe_subscribe(CHAR_DESPAWNED_SUB_CODE, function(char, ...)
    if char.name ~= local_player.Name then
        character_module:remove_character(char);
    end
end);


return character_module;
