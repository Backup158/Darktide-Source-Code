﻿-- chunkname: @scripts/ui/views/mission_board_view_pj/mission_board_view_settings.lua

local MissionBoardViewSettings = {
	fetch_retry_cooldown = 5,
	resource_renderer_enabled = false,
	resource_renderer_material = "content/ui/materials/mission_board/render_target_scanlines",
	resource_renderer_name = "mission_board_view_scanlines_ui_renderer",
}

MissionBoardViewSettings.on_screen_effect_settings = {
	cloud_name = "hard_noise2",
	enabled = true,
	on_screen_effect = "content/fx/particles/screenspace/screen_mission_board_hologram_effect",
	default_materials = {
		hologram = "content/environment/artsets/imperial/hub/mission_board_table_hologram/hologram_02",
		hologram_bottom = "content/environment/artsets/imperial/hub/mission_board_table_hologram/hologram_bottom",
		hologram_grid = "content/environment/artsets/imperial/hub/mission_board_table_hologram/hologram_grid",
	},
	effect_materials = {
		hologram = "content/parent_materials/black_shadow_caster",
		hologram_bottom = "content/parent_materials/black_shadow_caster",
		hologram_grid = "content/parent_materials/black_shadow_caster",
	},
}
MissionBoardViewSettings.mission_category_icons = {
	undefined = {
		mission_board_icon = "content/ui/materials/icons/mission_types_pj/mission_type_undefined",
		name = "loc_mission_type_undefined_name",
	},
	story = {
		mission_board_icon = "content/ui/materials/icons/mission_types_pj/mission_type_story",
		name = "loc_player_journey_campaign",
	},
	maelstrom = {
		mission_board_icon = "content/ui/materials/icons/mission_types_pj/mission_type_maelstrom_01",
		name = "loc_mission_board_maelstrom_header",
	},
	event = {
		mission_board_icon = "content/ui/materials/icons/mission_types_pj/mission_type_event",
		name = "loc_event_category_label",
	},
}
MissionBoardViewSettings.mission_widgets_size_multipliers = {
	common = 1,
	event = 1,
	maelstrom = 1,
	story = 1.25,
}
MissionBoardViewSettings.sidebar_tabs = {
	"main_objective",
	"side_objective",
}
MissionBoardViewSettings.hologram_unit_name = "mission_table_hologram_02"
MissionBoardViewSettings.world_spawner_settings = {
	level_name = "content/levels/ui/mission_board_player_journey/mission_board_player_journey",
	viewport_layer = 1,
	viewport_name = "mission_board_viewport",
	viewport_shading_environment = "content/shading_environments/ui/mission_board",
	viewport_type = "default",
	world_layer = 1,
	world_name = "mission_board",
	world_timer_name = "ui",
}
MissionBoardViewSettings.ui_viewport_settings = {
	renderer_name = "mission_board_default_gui_renderer",
	viewport_layer = 1,
	viewport_name = "mission_board_default_gui_viewport",
	viewport_shading_environment = "content/shading_environments/ui_default_bloom",
	viewport_type = "overlay",
	world_layer = 10,
	world_name = "mission_board_default_gui",
	world_timer_name = "ui",
}
MissionBoardViewSettings.black_listed_categories = {
	"hordes",
}
MissionBoardViewSettings.fluff_frames = {
	"content/ui/materials/fluff/hologram/frames/fluff_frame_01",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_02",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_03",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_04",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_05",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_06",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_07",
	"content/ui/materials/fluff/hologram/frames/fluff_frame_08",
}
MissionBoardViewSettings.currency_icons = {
	credits = "content/ui/materials/mission_board/currencies/credits_small_digital",
	diamantine = "content/ui/materials/mission_board/currencies/diamantine_small_digital",
	plasteel = "content/ui/materials/mission_board/currencies/plasteel_small_digital",
	xp = "content/ui/materials/mission_board/currencies/experience_small_digital",
}
MissionBoardViewSettings.currency_order = {
	"credits",
	"xp",
	"plasteel",
	"diamantine",
}
MissionBoardViewSettings.camera_settings = {
	acceleration_factor = 0.1,
	speed_factor = 2.5,
}
MissionBoardViewSettings.mission_difficulty_complete_icons = {
	"content/ui/materials/icons/mission_difficulty_complete/difficulty_completed_1",
	"content/ui/materials/icons/mission_difficulty_complete/difficulty_completed_2",
	"content/ui/materials/icons/mission_difficulty_complete/difficulty_completed_3",
	"content/ui/materials/icons/mission_difficulty_complete/difficulty_completed_4",
	"content/ui/materials/icons/mission_difficulty_complete/difficulty_completed_5",
}
MissionBoardViewSettings.dimensions = {
	details_width = 483,
	difficulty_stepper_width = 336,
	page_selector_height = 60,
	rewards_height = 36,
	side_buffer = 40,
	sidebar_buffer = 20,
	sidebar_small_buffer = 12,
	top_buffer = 60,
	widget_buffer = 40,
	difficulty_indicator_size = {
		22,
		22,
	},
	difficulty_indicator_active_size = {
		58,
		58,
	},
	difficulty_icon_active_size = {
		48,
		48,
	},
	play_button = {
		375,
		110,
	},
	small_mission_size = {
		72,
		82.8,
	},
	small_mission_background_size = {
		187.5,
		225,
	},
	small_mission_selected_frame_size = {
		150,
		180,
	},
	large_mission_size = {
		249.60000000000002,
		140.4,
	},
	threat_level_progress_bar_size = {
		276,
		8,
	},
	threat_tooltip_size = {
		400,
		90,
	},
}
MissionBoardViewSettings.page_selector_settings = {
	button_spacing = 0,
	grow_vertically = false,
	horizontal_alignment = "center",
	vertical_alignment = "top",
	button_size = {
		140,
		MissionBoardViewSettings.dimensions.page_selector_height,
	},
	input_label_offset = {
		25,
		15,
	},
}
MissionBoardViewSettings.gamepad_cursor_settings = {
	arrow_rotate_rate = 0.001,
	average_speeed_smoothing = 0.5,
	cursor_acceleration = 8000,
	cursor_friction_coefficient = 0.002,
	cursor_minimum_speed = 0.1,
	size_resize_rate = 0.001,
	snap_delay = 0.1,
	snap_input_length_threshold = 0.05,
	snap_movement_rate = 0.005,
	snap_selection_speed_threshold = 10,
	stickiness_radius = 25,
	stickiness_speed_threshold = 500,
	time_until_invisible = 0.6,
	widget_drag_coefficient = 0.45,
	default_size_x = MissionBoardViewSettings.dimensions.small_mission_size[1],
	default_size_y = MissionBoardViewSettings.dimensions.small_mission_size[2],
}
MissionBoardViewSettings.mission_tile_banner_category_texts = {
	default = "n/a",
	event = "loc_event_category_label",
	maelstrom = "loc_mission_board_maelstrom_header",
	story = "loc_group_finder_category_story",
}

return settings("MissionBoardViewSettings", MissionBoardViewSettings)
