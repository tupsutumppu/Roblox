rconsolecreate();
rconsolesettitle"Scorched Earth | #tupsutumppu";
rconsoleclear();

rconsoleinfo"Initializing...";

local PLAYERS = cloneref(game:GetService"Players");
local local_player = cloneref(PLAYERS.LocalPlayer);

local repo = "https://raw.githubusercontent.com/tupsutumppu/Roblox/main/";

local success, network_module = pcall(loadstring(game:HttpGet(repo .. "ScorchedEarth/modules/network_module.luau")));
if not success then local_player:Kick"Failed to hook network module!" end;

local success, signal_module = pcall(loadstring(game:HttpGet(repo .. "ScorchedEarth/modules/signal_module.luau")));
if not success then local_player:Kick"Failed to hook signals module!" end;

local character_module = loadstring(game:HttpGet(repo .. "ScorchedEarth/modules/character_module.luau"))(signal_module);
local esp_module = loadstring(game:HttpGet(repo .. "ScorchedEarth/modules/esp_module.luau"))();
local combat_module = loadstring(game:HttpGet(repo .. "ScorchedEarth/modules/combat_module.luau"))(signal_module, character_module);

esp_module:init(character_module);

local linoria = loadstring(game:HttpGet(repo .. "ScorchedEarth/ui/linoria.luau"))();
local theme_manager = loadstring(game:HttpGet(repo .. "ScorchedEarth/ui/theme_manager.luau"))();

local window = linoria:CreateWindow{
    Title = game:GetService"MarketplaceService":GetProductInfo(game.PlaceId).Name .. " | #tupsutumppu";
    Center = true;
    AutoShow = true;
    TabPadding = 8;
    MenuFadeTime = 0.2
};

local tabs = {
    combat = window:AddTab"Combat",
    esp_module = window:AddTab"ESP",
    ui = window:AddTab"UI"
};

local silent_aim_gb = tabs.combat:AddLeftGroupbox"Silent Aim";

local enemy_tb = tabs.esp_module:AddLeftTabbox();
local enemy_esp = enemy_tb:AddTab"Enemy ESP";
local enemy_esp_settings = enemy_tb:AddTab"Settings";

local team_tb = tabs.esp_module:AddRightTabbox();
local team_esp = team_tb:AddTab"Team ESP";
local team_esp_settings = team_tb:AddTab"Settings";

silent_aim_gb:AddToggle("silent_aim", {Text = "Enabled"; Default = combat_module.config.silent_aim; Tooltip = nil;
    Callback = function(value)
        combat_module.config.silent_aim = value;
    end
});
silent_aim_gb:AddDropdown("silent_aim_target_part", {Values = {"head", "torso"}, Default = combat_module.config.target_part, Multi = false, Text = "Aim Part", Tooltip = nil,
    Callback = function(value)
        combat_module.config.target_part = value;
    end
});
silent_aim_gb:AddSlider("fov_radius", {Text = "Fov Radius", Default = combat_module.fov_circle.Radius, Min = 50, Max = 400, Rounding = 0, Compact = false,
    Callback = function(value)
        combat_module.fov_circle.Radius = value;
    end
});
silent_aim_gb:AddDivider();
silent_aim_gb:AddToggle("fov_visible", {Text = "Fov Visible"; Default = combat_module.fov_circle.Visible; Tooltip = nil;
    Callback = function(value)
        combat_module.fov_circle.Visible = value;
    end
}):AddColorPicker("fov_color", {Default = combat_module.fov_circle.Color, Title = "", Transparency = 0,
    Callback = function(value)
        combat_module.fov_circle.Color = value;
    end
});
silent_aim_gb:AddSlider("fov_num_sides", {Text = "Fov NumSides", Default = combat_module.fov_circle.NumSides, Min = 32, Max = 256, Rounding = 0, Compact = false,
    Callback = function(value)
        combat_module.fov_circle.NumSides = value;
    end
});
silent_aim_gb:AddSlider("fov_transparency", {Text = "Fov Transparency", Default = combat_module.fov_circle.Transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        combat_module.fov_circle.Transparency = value;
    end
});
enemy_esp:AddToggle("enemy_box", {Text = "Box", Default = esp_module.config.enemy.box, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.box = value;
    end
}):AddColorPicker("enemy_box_color", {Default = esp_module.config.enemy.box_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.box_color = value;
    end
});
enemy_esp:AddToggle("enemy_box_outline", {Text = "Box Outline", Default = esp_module.config.enemy.box_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.box_outline = value;
    end
}):AddColorPicker("enemy_box_outline_color", {Default = esp_module.config.enemy.box_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.box_outline_color = value;
    end
});
enemy_esp:AddToggle("enemy_tracer", {Text = "Tracer", Default = esp_module.config.enemy.tracer, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.tracer = value;
    end
}):AddColorPicker("enemy_tracer_color", {Default = esp_module.config.enemy.tracer_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.tracer_color = value;
    end
});
enemy_esp:AddToggle("enemy_tracer_outline", {Text = "Tracer Outline", Default = esp_module.config.enemy.tracer_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.tracer_outline = value;
    end
}):AddColorPicker("enemy_tracer_outline_color", {Default = esp_module.config.enemy.tracer_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.tracer_outline_color = value;
    end
});
enemy_esp:AddToggle("enemy_name", {Text = "Name", Default = esp_module.config.enemy.name, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.name = value;
    end
}):AddColorPicker("enemy_name_color", {Default = esp_module.config.enemy.name_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.name_color = value;
    end
});
enemy_esp:AddToggle("enemy_name_outline", {Text = "Name Outline", Default = esp_module.config.enemy.name_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.enemy.name_outline = value;
    end
}):AddColorPicker("enemy_name_outline_color", {Default = esp_module.config.enemy.name_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.enemy.name_outline_color = value;
    end
});
enemy_esp_settings:AddSlider("enemy_box_thickness", {Text = "Box Thickness", Default = esp_module.config.enemy.box_thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.box_thickness = value;
    end
});
enemy_esp_settings:AddSlider("enemy_box_transparency", {Text = "Box Transparency", Default = esp_module.config.enemy.box_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.box_transparency = value;
    end
});
enemy_esp_settings:AddSlider("enemy_tracer_thickness", {Text = "Tracer Thickness", Default = esp_module.config.enemy.tracer_thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.tracer_thickness = value;
    end
});
enemy_esp_settings:AddSlider("enemy_tracer_transparency", {Text = "Tracer Transparency", Default = esp_module.config.enemy.tracer_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.tracer_transparency = value;
    end
});
enemy_esp_settings:AddSlider("enemy_name_size", {Text = "Name Text Size", Default = esp_module.config.enemy.name_size, Min = 6, Max = 20, Rounding = 0, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.name_size = value;
    end
});
enemy_esp_settings:AddSlider("enemy_name_transparency", {Text = "Name Text Transparency", Default = esp_module.config.enemy.name_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.enemy.name_transparency = value;
    end
});
team_esp:AddToggle("team_box", {Text = "Box", Default = esp_module.config.team.box, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.box = value;
    end
}):AddColorPicker("team_box_color", {Default = esp_module.config.team.box_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.box_color = value;
    end
});
team_esp:AddToggle("team_box_outline", {Text = "Box Outline", Default = esp_module.config.team.box_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.box_outline = value;
    end
}):AddColorPicker("team_box_outline_color", {Default = esp_module.config.team.box_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.box_outline_color = value;
    end
});
team_esp:AddToggle("team_tracer", {Text = "Tracer", Default = esp_module.config.team.tracer, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.tracer = value;
    end
}):AddColorPicker("team_tracer_color", {Default = esp_module.config.team.tracer_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.tracer_color = value;
    end
});
team_esp:AddToggle("team_tracer_outline", {Text = "Tracer Outline", Default = esp_module.config.team.tracer_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.tracer_outline = value;
    end
}):AddColorPicker("team_tracer_outline_color", {Default = esp_module.config.team.tracer_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.tracer_outline_color = value;
    end
});
team_esp:AddToggle("team_name", {Text = "Name", Default = esp_module.config.team.name, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.name = value;
    end
}):AddColorPicker("team_name_color", {Default = esp_module.config.team.name_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.name_color = value;
    end
});
team_esp:AddToggle("team_name_outline", {Text = "Name Outline", Default = esp_module.config.team.name_outline, Tooltip = nil,
    Callback = function(value)
        esp_module.config.team.name_outline = value;
    end
}):AddColorPicker("team_name_outline_color", {Default = esp_module.config.team.name_outline_color, Title = "", Transparency = 0,
    Callback = function(value)
        esp_module.config.team.name_outline_color = value;
    end
});

team_esp_settings:AddSlider("team_box_thickness", {Text = "Box Thickness", Default = esp_module.config.team.box_thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.team.box_thickness = value;
    end
});
team_esp_settings:AddSlider("team_box_transparency", {Text = "Box Transparency", Default = esp_module.config.team.box_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.team.box_transparency = value;
    end
});
team_esp_settings:AddSlider("team_tracer_thickness", {Text = "Tracer Thickness", Default = esp_module.config.team.tracer_thickness, Min = 0, Max = 3, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.team.tracer_thickness = value;
    end
});
team_esp_settings:AddSlider("team_tracer_transparency", {Text = "Tracer Transparency", Default = esp_module.config.team.tracer_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.team.tracer_transparency = value;
    end
});
team_esp_settings:AddSlider("team_name_size", {Text = "Name Text Size", Default = esp_module.config.team.name_size, Min = 6, Max = 20, Rounding = 0, Compact = false,
    Callback = function(value)
        esp_module.config.team.name_size = value;
    end
});
team_esp_settings:AddSlider("team_name_transparency", {Text = "Name Text Transparency", Default = esp_module.config.team.name_transparency, Min = 0, Max = 1, Rounding = 1, Compact = false,
    Callback = function(value)
        esp_module.config.team.name_transparency = value;
    end
});

local menu_group = tabs.ui:AddRightGroupbox"Menu";
menu_group:AddLabel"Menu bind":AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "Menu keybind"});
linoria.ToggleKeybind = Options.MenuKeybind;

theme_manager:SetLibrary(linoria);
theme_manager:ApplyToTab(tabs.ui);
theme_manager:ApplyTheme"Mint";

rconsoleinfo("Initialized!");
