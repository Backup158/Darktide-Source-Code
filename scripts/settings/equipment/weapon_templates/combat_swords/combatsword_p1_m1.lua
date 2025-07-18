﻿-- chunkname: @scripts/settings/equipment/weapon_templates/combat_swords/combatsword_p1_m1.lua

local ActionSweepSettings = require("scripts/settings/equipment/action_sweep_settings")
local ArmorSettings = require("scripts/settings/damage/armor_settings")
local BaseTemplateSettings = require("scripts/settings/equipment/weapon_templates/base_template_settings")
local BuffSettings = require("scripts/settings/buff/buff_settings")
local DamageProfileTemplates = require("scripts/settings/damage/damage_profile_templates")
local DamageSettings = require("scripts/settings/damage/damage_settings")
local FootstepIntervalsTemplates = require("scripts/settings/equipment/footstep/footstep_intervals_templates")
local HapticTriggerTemplates = require("scripts/settings/equipment/haptic_trigger_templates")
local HitZone = require("scripts/utilities/attack/hit_zone")
local MeleeActionInputSetupMid = require("scripts/settings/equipment/weapon_templates/melee_action_input_setup_mid")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
local SmartTargetingTemplates = require("scripts/settings/equipment/smart_targeting_templates")
local WeaponTraitsBespokeCombatswordP1 = require("scripts/settings/equipment/weapon_traits/weapon_traits_bespoke_combatsword_p1")
local WeaponTraitTemplates = require("scripts/settings/equipment/weapon_templates/weapon_trait_templates/weapon_trait_templates")
local WeaponTweakTemplateSettings = require("scripts/settings/equipment/weapon_templates/weapon_tweak_template_settings")
local WoundsSettings = require("scripts/settings/wounds/wounds_settings")
local damage_types = DamageSettings.damage_types
local armor_types = ArmorSettings.types
local buff_stat_buffs = BuffSettings.stat_buffs
local hit_zone_names = HitZone.hit_zone_names
local default_hit_zone_priority = ActionSweepSettings.default_hit_zone_priority
local buff_stat_buffs = BuffSettings.stat_buffs
local buff_targets = WeaponTweakTemplateSettings.buff_targets
local damage_types = DamageSettings.damage_types
local template_types = WeaponTweakTemplateSettings.template_types
local wield_inputs = PlayerCharacterConstants.wield_inputs
local wounds_shapes = WoundsSettings.shapes
local damage_trait_templates = WeaponTraitTemplates[template_types.damage]
local dodge_trait_templates = WeaponTraitTemplates[template_types.dodge]
local recoil_trait_templates = WeaponTraitTemplates[template_types.recoil]
local spread_trait_templates = WeaponTraitTemplates[template_types.spread]
local sprint_trait_templates = WeaponTraitTemplates[template_types.sprint]
local stamina_trait_templates = WeaponTraitTemplates[template_types.stamina]
local ammo_trait_templates = WeaponTraitTemplates[template_types.ammo]
local sway_trait_templates = WeaponTraitTemplates[template_types.sway]
local toughness_trait_templates = WeaponTraitTemplates[template_types.toughness]
local weapon_handling_trait_templates = WeaponTraitTemplates[template_types.weapon_handling]
local movement_curve_modifier_trait_templates = WeaponTraitTemplates[template_types.movement_curve_modifier]
local weapon_template = {}
local action_inputs = table.clone(MeleeActionInputSetupMid.action_inputs)

action_inputs.parry = {
	buffer_time = 0,
}

local action_input_hierarchy = table.clone(MeleeActionInputSetupMid.action_input_hierarchy)

action_input_hierarchy[#action_input_hierarchy + 1] = {
	input = "parry",
	transition = "base",
}
weapon_template.action_inputs = action_inputs
weapon_template.action_input_hierarchy = action_input_hierarchy
weapon_template.action_inputs.block.buffer_time = 0.1
weapon_template.action_inputs.block_release.buffer_time = 0.35

local default_weapon_box = {
	0.2,
	0.1,
	1.1,
}
local hit_zone_priority = {
	[hit_zone_names.head] = 1,
	[hit_zone_names.torso] = 2,
	[hit_zone_names.upper_left_arm] = 3,
	[hit_zone_names.upper_right_arm] = 3,
	[hit_zone_names.upper_left_leg] = 3,
	[hit_zone_names.upper_right_leg] = 3,
}

table.add_missing(hit_zone_priority, default_hit_zone_priority)

weapon_template.actions = {
	action_unwield = {
		allowed_during_sprint = true,
		kind = "unwield",
		start_input = "wield",
		total_time = 0,
		uninterruptible = true,
		allowed_chain_actions = {},
	},
	action_wield = {
		allowed_during_sprint = true,
		anim_event = "equip",
		kind = "wield",
		sprint_ready_up_time = 0,
		total_time = 0.1,
		uninterruptible = true,
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_left",
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
			},
		},
	},
	action_melee_start_left = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_charge_left",
		anim_event_3p = "attack_swing_charge_left",
		kind = "windup",
		start_input = "start_attack",
		stop_input = "attack_cancel",
		total_time = 3,
		action_movement_curve = {
			{
				modifier = 0.65,
				t = 0.05,
			},
			{
				modifier = 0.7,
				t = 0.1,
			},
			{
				modifier = 0.9,
				t = 0.25,
			},
			{
				modifier = 0.85,
				t = 0.4,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.835,
				t = 0.55,
			},
			{
				modifier = 0.95,
				t = 3,
			},
			start_modifier = 0.75,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			light_attack = {
				action_name = "action_left_light",
				chain_time = 0,
			},
			heavy_attack = {
				action_name = "action_left_heavy",
				chain_time = 0.65,
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
	},
	action_left_light = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "attack_left_diagonal_down",
		anim_event_3p = "attack_swing_left_diagonal",
		damage_window_end = 0.4,
		damage_window_start = 0.31,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		range_mod = 1.25,
		total_time = 2,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1.15,
				t = 0.2,
			},
			{
				modifier = 1.05,
				t = 0.35,
			},
			{
				modifier = 0.7,
				t = 0.5,
			},
			{
				modifier = 0.65,
				t = 0.55,
			},
			{
				modifier = 0.65,
				t = 0.6,
			},
			{
				modifier = 1,
				t = 0.7,
			},
			{
				modifier = 1.05,
				t = 0.75,
			},
			{
				modifier = 1.04,
				t = 0.8,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.3,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_right",
				chain_time = 0.4,
			},
			block = {
				action_name = "action_block",
				chain_time = 0,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.4,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/swing_left_diagonal",
			anchor_point_offset = {
				0,
				0,
				-0.2,
			},
		},
		damage_profile = DamageProfileTemplates.light_combatsword_linesman,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.left_45_slash,
	},
	action_left_heavy = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_attack_left",
		anim_event_3p = "attack_swing_heavy_left",
		damage_window_end = 0.26,
		damage_window_start = 0.08,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		range_mod = 1.25,
		total_time = 1,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1.3,
				t = 0.15,
			},
			{
				modifier = 1.25,
				t = 0.4,
			},
			{
				modifier = 0.5,
				t = 0.6,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.5,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_right",
				chain_time = 0.4,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.4,
				chain_until = 0.1,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.4,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/heavy_swing_left",
			anchor_point_offset = {
				0,
				0,
				-0.15,
			},
		},
		damage_profile = DamageProfileTemplates.heavy_combatsword,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.horizontal_slash,
	},
	action_melee_start_right = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_charge_right",
		anim_event_3p = "attack_swing_charge_right",
		hit_stop_anim = "attack_hit",
		kind = "windup",
		stop_input = "attack_cancel",
		total_time = 3,
		action_movement_curve = {
			{
				modifier = 0.65,
				t = 0.05,
			},
			{
				modifier = 0.7,
				t = 0.1,
			},
			{
				modifier = 0.9,
				t = 0.25,
			},
			{
				modifier = 0.85,
				t = 0.4,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.835,
				t = 0.55,
			},
			{
				modifier = 0.95,
				t = 3,
			},
			start_modifier = 0.75,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			light_attack = {
				action_name = "action_right_light",
				chain_time = 0,
			},
			heavy_attack = {
				action_name = "action_right_heavy",
				chain_time = 0.54,
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
	},
	action_right_light = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "attack_right_diagonal_down",
		anim_event_3p = "attack_swing_right",
		damage_window_end = 0.48,
		damage_window_start = 0.35,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		range_mod = 1.25,
		total_time = 2,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1.15,
				t = 0.2,
			},
			{
				modifier = 1.05,
				t = 0.35,
			},
			{
				modifier = 0.7,
				t = 0.5,
			},
			{
				modifier = 0.65,
				t = 0.55,
			},
			{
				modifier = 0.65,
				t = 0.6,
			},
			{
				modifier = 0.9,
				t = 0.8,
			},
			{
				modifier = 0.975,
				t = 0.85,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.3,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_left_2",
				chain_time = 0.6,
			},
			block = {
				action_name = "action_block",
				chain_time = 0,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.45,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/swing_right_diagonal",
			anchor_point_offset = {
				0,
				0,
				-0.2,
			},
		},
		damage_profile = DamageProfileTemplates.light_combatsword_linesman,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.right_45_slash,
	},
	action_right_heavy = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_attack_right",
		anim_event_3p = "attack_swing_heavy_right",
		damage_window_end = 0.3,
		damage_window_start = 0.1,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		range_mod = 1.3,
		total_time = 1,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1.3,
				t = 0.15,
			},
			{
				modifier = 1.25,
				t = 0.4,
			},
			{
				modifier = 0.5,
				t = 0.6,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.5,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
				chain_time = 0.3,
			},
			start_attack = {
				action_name = "action_melee_start_left_2",
				chain_time = 0.5,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.45,
				chain_until = 0.05,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.5,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/heavy_swing_right",
			anchor_point_offset = {
				0,
				0,
				-0.2,
			},
		},
		damage_profile = DamageProfileTemplates.heavy_combatsword,
		damage_type = damage_types.metal_slashing_medium,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.horizontal_slash,
	},
	action_melee_start_left_2 = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_charge_left",
		anim_event_3p = "attack_swing_charge_left",
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "windup",
		stop_input = "attack_cancel",
		total_time = 3,
		action_movement_curve = {
			{
				modifier = 0.65,
				t = 0.05,
			},
			{
				modifier = 0.7,
				t = 0.1,
			},
			{
				modifier = 0.9,
				t = 0.25,
			},
			{
				modifier = 0.85,
				t = 0.4,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.835,
				t = 0.55,
			},
			{
				modifier = 0.95,
				t = 3,
			},
			start_modifier = 0.75,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			light_attack = {
				action_name = "action_left_light_2",
				chain_time = 0,
			},
			heavy_attack = {
				action_name = "action_left_heavy",
				chain_time = 0.56,
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.5,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
	},
	action_left_light_2 = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "attack_down_left",
		anim_event_3p = "attack_swing_down_left",
		attack_direction_override = "push",
		damage_window_end = 0.46,
		damage_window_start = 0.3,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		power_level = 545,
		range_mod = 1.27,
		total_time = 2,
		weapon_handling_template = "time_scale_1_3",
		action_movement_curve = {
			{
				modifier = 1.25,
				t = 0.2,
			},
			{
				modifier = 1.05,
				t = 0.35,
			},
			{
				modifier = 0.5,
				t = 0.5,
			},
			{
				modifier = 0.45,
				t = 0.55,
			},
			{
				modifier = 0.65,
				t = 0.6,
			},
			{
				modifier = 0.9,
				t = 0.8,
			},
			{
				modifier = 0.975,
				t = 0.85,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.3,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_right_2",
				chain_time = 0.5,
			},
			block = {
				action_name = "action_block",
				chain_time = 0,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.48,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/swing_down_left",
			anchor_point_offset = {
				0.1,
				0,
				0.2,
			},
		},
		damage_profile = DamageProfileTemplates.light_combatsword_smiter,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.vertical_slash,
	},
	action_melee_start_right_2 = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_charge_down_right",
		anim_event_3p = "attack_swing_charge_right",
		hit_stop_anim = "attack_hit",
		kind = "windup",
		stop_input = "attack_cancel",
		total_time = 3,
		action_movement_curve = {
			{
				modifier = 0.65,
				t = 0.05,
			},
			{
				modifier = 0.7,
				t = 0.1,
			},
			{
				modifier = 0.9,
				t = 0.25,
			},
			{
				modifier = 0.85,
				t = 0.4,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.835,
				t = 0.55,
			},
			{
				modifier = 0.95,
				t = 3,
			},
			start_modifier = 0.75,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			light_attack = {
				action_name = "action_right_light",
				chain_time = 0,
			},
			heavy_attack = {
				action_name = "action_right_heavy_2",
				chain_time = 0.4,
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
	},
	action_right_heavy_2 = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "heavy_attack_down_right",
		anim_event_3p = "attack_swing_heavy_down",
		attack_direction_override = "down",
		damage_window_end = 0.3,
		damage_window_start = 0.2,
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "sweep",
		power_level = 540,
		range_mod = 1.25,
		total_time = 1,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1.3,
				t = 0.15,
			},
			{
				modifier = 1.25,
				t = 0.4,
			},
			{
				modifier = 0.5,
				t = 0.6,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.5,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
				chain_time = 0.3,
			},
			start_attack = {
				action_name = "action_melee_start_left",
				chain_time = 0.3,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.45,
				chain_until = 0.05,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.5,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/heavy_swing_down_right",
			anchor_point_offset = {
				-0.1,
				0,
				0.2,
			},
		},
		damage_profile = DamageProfileTemplates.heavy_combatsword_smiter,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
		wounds_shape = wounds_shapes.vertical_slash,
	},
	action_melee_start_push_combo = {
		anim_end_event = "attack_finished",
		anim_event = "heavy_charge_left",
		anim_event_3p = "attack_swing_charge_left",
		hit_armor_anim = "attack_hit_shield",
		hit_stop_anim = "hit_stop",
		kind = "windup",
		stop_input = "attack_cancel",
		total_time = 3,
		action_movement_curve = {
			{
				modifier = 0.65,
				t = 0.05,
			},
			{
				modifier = 0.7,
				t = 0.1,
			},
			{
				modifier = 0.9,
				t = 0.25,
			},
			{
				modifier = 0.85,
				t = 0.4,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.835,
				t = 0.55,
			},
			{
				modifier = 0.95,
				t = 3,
			},
			start_modifier = 0.75,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			light_attack = {
				action_name = "action_left_light_2",
				chain_time = 0,
			},
			heavy_attack = {
				action_name = "action_left_heavy",
				chain_time = 0.56,
			},
			block = {
				action_name = "action_block",
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.5,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
	},
	action_block = {
		anim_end_event = "parry_finished",
		anim_event = "parry_pose",
		kind = "block",
		minimum_hold_time = 0.225,
		start_input = "block",
		stop_input = "block_release",
		total_time = math.huge,
		action_movement_curve = {
			{
				modifier = 0.75,
				t = 0.2,
			},
			{
				modifier = 0.82,
				t = 0.3,
			},
			{
				modifier = 0.8,
				t = 0.325,
			},
			{
				modifier = 0.81,
				t = 0.35,
			},
			{
				modifier = 0.85,
				t = 0.5,
			},
			{
				modifier = 0.85,
				t = 1,
			},
			{
				modifier = 0.8,
				t = 2,
			},
			start_modifier = 1,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			push = {
				action_name = "action_push",
			},
			special_action = {
				action_name = "action_parry_special",
			},
		},
	},
	action_parry_special = {
		anim_end_event = "parry_finished",
		anim_event = "parry_special",
		anim_event_3p = "parry_pose",
		ignore_setting_blocked_on_minions = true,
		kind = "block",
		parry_block = true,
		start_input = "special_action",
		total_time = 1.5,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 0.5,
				t = 0.2,
			},
			{
				modifier = 1,
				t = 0.5,
			},
			start_modifier = 0.4,
		},
		action_keywords = {
			"weapon_special",
		},
		running_action_state_to_action_input = {
			has_blocked = {
				input_name = "parry",
			},
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			parry = {
				action_name = "action_attack_special",
				chain_time = 0.25,
			},
			start_attack = {
				action_name = "action_melee_start_left",
				chain_time = 0.2,
			},
			block = {
				action_name = "action_block",
				chain_time = 1.25,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 1.25,
			},
		},
	},
	action_attack_special = {
		anim_end_event = "attack_finished",
		anim_event = "attack_special",
		attack_direction_override = "push",
		block_duration = 0.5,
		damage_window_end = 0.3,
		damage_window_start = 0.15,
		hit_armor_anim = "attack_hit_shield",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 4,
		range_mod = 1.25,
		total_time = 1,
		weapon_handling_template = "time_scale_1_3",
		action_movement_curve = {
			{
				modifier = 1,
				t = 0.15,
			},
			start_modifier = 1,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
				chain_time = 0.3,
			},
			start_attack = {
				action_name = "action_melee_start_left_2",
				chain_time = 0.4,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.45,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.45,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = {
			0.2,
			0.2,
			1.25,
		},
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/stab_special",
			anchor_point_offset = {
				-0,
				0,
				-0,
			},
		},
		damage_profile = DamageProfileTemplates.combatsword_parry_special,
		damage_type = damage_types.metal_slashing_light,
		wounds_shape = wounds_shapes.right_45_slash,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
	},
	action_right_light_pushfollow = {
		allowed_during_sprint = true,
		anim_end_event = "attack_finished",
		anim_event = "attack_right_diagonal_down",
		anim_event_3p = "attack_swing_right_diagonal",
		damage_window_end = 0.45,
		damage_window_start = 0.35,
		hit_armor_anim = "attack_hit_shield",
		kind = "sweep",
		max_num_saved_entries = 20,
		num_frames_before_process = 0,
		power_level = 535,
		range_mod = 1.28,
		total_time = 2,
		weapon_handling_template = "time_scale_1",
		action_movement_curve = {
			{
				modifier = 1,
				t = 0.2,
			},
			start_modifier = 1,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			start_attack = {
				action_name = "action_melee_start_left_2",
				chain_time = 0.4,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.55,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.45,
			},
		},
		anim_end_event_condition_func = function (unit, data, end_reason)
			return end_reason ~= "new_interrupting_action" and end_reason ~= "action_complete"
		end,
		hit_zone_priority = hit_zone_priority,
		weapon_box = default_weapon_box,
		spline_settings = {
			matrices_data_location = "content/characters/player/human/first_person/animations/combat_sword/swing_right_diagonal",
			anchor_point_offset = {
				0,
				0,
				-0.2,
			},
		},
		damage_profile = DamageProfileTemplates.light_combatsword_linesman,
		damage_type = damage_types.metal_slashing_light,
		time_scale_stat_buffs = {
			buff_stat_buffs.attack_speed,
			buff_stat_buffs.melee_attack_speed,
		},
	},
	action_push = {
		activation_cooldown = 0.2,
		anim_event = "attack_push",
		block_duration = 0.5,
		kind = "push",
		push_radius = 2.5,
		total_time = 1,
		action_movement_curve = {
			{
				modifier = 1.4,
				t = 0.1,
			},
			{
				modifier = 0.5,
				t = 0.25,
			},
			{
				modifier = 0.5,
				t = 0.4,
			},
			{
				modifier = 1,
				t = 1,
			},
			start_modifier = 1.4,
		},
		allowed_chain_actions = {
			combat_ability = {
				action_name = "combat_ability",
			},
			grenade_ability = BaseTemplateSettings.generate_grenade_ability_chain_actions(),
			wield = {
				action_name = "action_unwield",
			},
			push_follow_up = {
				action_name = "action_right_light_pushfollow",
				chain_time = 0.25,
			},
			block = {
				action_name = "action_block",
				chain_time = 0.3,
			},
			start_attack = {
				action_name = "action_melee_start_push_combo",
				chain_time = 0.3,
			},
			special_action = {
				action_name = "action_parry_special",
				chain_time = 0.3,
			},
		},
		inner_push_rad = math.pi * 0.25,
		outer_push_rad = math.pi * 1,
		inner_damage_profile = DamageProfileTemplates.default_push,
		inner_damage_type = damage_types.punch,
		outer_damage_profile = DamageProfileTemplates.light_push,
		outer_damage_type = damage_types.punch,
		haptic_trigger_template = HapticTriggerTemplates.melee.push,
	},
	action_inspect = {
		anim_end_event = "inspect_end",
		anim_event = "inspect_start",
		kind = "inspect",
		lock_view = true,
		skip_3p_anims = false,
		start_input = "inspect_start",
		stop_input = "inspect_stop",
		total_time = math.huge,
		crosshair = {
			crosshair_type = "inspect",
		},
	},
}

table.add_missing(weapon_template.actions, BaseTemplateSettings.actions)

weapon_template.anim_state_machine_3p = "content/characters/player/human/third_person/animations/power_sword"
weapon_template.anim_state_machine_1p = "content/characters/player/human/first_person/animations/combat_sword"
weapon_template.weapon_box = {
	0.1,
	0.7,
	0.02,
}
weapon_template.hud_configuration = {
	uses_ammunition = false,
	uses_overheat = false,
}
weapon_template.sprint_ready_up_time = 0.3
weapon_template.max_first_person_anim_movement_speed = 5.8
weapon_template.damage_window_start_sweep_trail_offset = -0.45
weapon_template.damage_window_end_sweep_trail_offset = 0.45
weapon_template.ammo_template = "no_ammo"
weapon_template.fx_sources = {
	_block = "fx_block",
	_sweep = "fx_sweep",
}
weapon_template.crosshair = {
	crosshair_type = "dot",
}
weapon_template.hit_marker_type = "center"
weapon_template.keywords = {
	"melee",
	"combat_sword",
	"p1",
}
weapon_template.dodge_template = "default"
weapon_template.sprint_template = "default"
weapon_template.stamina_template = "linesman_plus"
weapon_template.toughness_template = "default"
weapon_template.movement_curve_modifier_template = "chainsword_p1_m1"
weapon_template.footstep_intervals = FootstepIntervalsTemplates.default
weapon_template.smart_targeting_template = SmartTargetingTemplates.default_melee
weapon_template.haptic_trigger_template = HapticTriggerTemplates.melee.medium
weapon_template.overclocks = {
	cleave_damage_up_dps_down = {
		combatsword_p1_m1_cleave_damage_stat = 0.1,
		combatsword_p1_m1_dps_stat = -0.1,
	},
	finesse_up_cleave_damage_down = {
		combatsword_p1_m1_cleave_damage_stat = -0.2,
		combatsword_p1_m1_finesse_stat = 0.2,
	},
	cleave_targets_up_cleave_damage_down = {
		combatsword_p1_m1_cleave_damage_stat = -0.1,
		combatsword_p1_m1_cleave_targets_stat = 0.1,
	},
	mobility_up_cleave_targets_down = {
		combatsword_p1_m1_cleave_targets_stat = -0.1,
		combatsword_p1_m1_mobility_stat = 0.1,
	},
	dps_up_mobility_down = {
		combatsword_p1_m1_dps_stat = 0.1,
		combatsword_p1_m1_mobility_stat = -0.1,
	},
}

local WeaponBarUIDescriptionTemplates = require("scripts/settings/equipment/weapon_bar_ui_description_templates")

weapon_template.base_stats = {
	combatsword_p1_m1_dps_stat = {
		display_name = "loc_stats_display_damage_stat",
		is_stat_trait = true,
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_dps_stat,
				display_data = {
					prefix = "loc_weapon_action_title_light",
					display_stats = {
						targets = {
							{
								power_distribution = {
									attack = {
										display_name = "loc_weapon_stats_display_base_damage",
									},
								},
							},
						},
					},
				},
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_dps_stat,
				display_data = {
					prefix = "loc_weapon_action_title_heavy",
					display_stats = {
						targets = {
							{
								power_distribution = {
									attack = {
										display_name = "loc_weapon_stats_display_base_damage",
									},
								},
							},
						},
					},
				},
			},
			action_right_light = {
				damage_trait_templates.combatsword_dps_stat,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_dps_stat,
			},
			action_left_light_2 = {
				damage_trait_templates.combatsword_dps_stat,
			},
			action_attack_special = {
				damage_trait_templates.combatsword_dps_stat,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_dps_stat,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_dps_stat,
			},
		},
	},
	combatsword_p1_m1_cleave_damage_stat = {
		display_name = "loc_stats_display_cleave_damage_stat",
		is_stat_trait = true,
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_cleave_damage_stat,
				display_data = {
					display_stats = {
						armor_damage_modifier = {
							attack = {
								[armor_types.armored] = {
									display_name = "loc_weapon_stats_display_cleave_armored",
								},
								[armor_types.unarmored] = {
									display_name = "loc_weapon_stats_display_cleave_unarmored",
								},
								[armor_types.disgustingly_resilient] = {
									display_name = "loc_weapon_stats_display_cleave_disgustingly_resilient",
								},
							},
						},
					},
				},
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_right_light = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_left_light_2 = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_attack_special = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_cleave_damage_stat,
			},
		},
	},
	combatsword_p1_m1_finesse_stat = {
		display_name = "loc_stats_display_finesse_stat",
		is_stat_trait = true,
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_finesse_stat,
				display_data = {
					prefix = "loc_weapon_action_title_light",
					display_stats = {
						targets = {
							{
								boost_curve_multiplier_finesse = {},
							},
						},
					},
				},
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_finesse_stat,
				display_data = {
					prefix = "loc_weapon_action_title_heavy",
					display_stats = {
						targets = {
							{
								boost_curve_multiplier_finesse = {},
							},
						},
					},
				},
			},
			action_right_light = {
				damage_trait_templates.combatsword_finesse_stat,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_finesse_stat,
			},
			action_left_light_2 = {
				damage_trait_templates.combatsword_finesse_stat,
			},
			action_attack_special = {
				damage_trait_templates.combatsword_finesse_stat,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_finesse_stat,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_finesse_stat,
			},
		},
		weapon_handling = {
			action_left_light = {
				weapon_handling_trait_templates.default_finesse_stat,
				display_data = {
					prefix = "loc_weapon_action_title_light",
					display_stats = {
						__all_basic_stats = true,
					},
				},
			},
			action_left_heavy = {
				weapon_handling_trait_templates.default_finesse_stat,
				display_data = {
					prefix = "loc_weapon_action_title_heavy",
					display_stats = {
						__all_basic_stats = true,
					},
				},
			},
			action_right_light = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
			action_right_heavy = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
			action_left_light_2 = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
			action_attack_special = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
			action_right_light_pushfollow = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
			action_right_heavy_2 = {
				weapon_handling_trait_templates.default_finesse_stat,
			},
		},
	},
	combatsword_p1_m1_cleave_targets_stat = {
		display_name = "loc_stats_display_cleave_targets_stat",
		is_stat_trait = true,
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_cleave_targets_stat,
				display_data = {
					prefix = "loc_weapon_action_title_light",
					display_stats = {
						__all_basic_stats = true,
					},
				},
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_cleave_targets_stat,
				display_data = {
					prefix = "loc_weapon_action_title_heavy",
					display_stats = {
						__all_basic_stats = true,
					},
				},
			},
			action_right_light = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
			action_left_light_2 = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
			action_attack_special = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_cleave_targets_stat,
			},
		},
	},
	combatsword_p1_m1_mobility_stat = {
		display_name = "loc_stats_display_mobility_stat",
		is_stat_trait = true,
		dodge = {
			base = {
				dodge_trait_templates.default_dodge_stat,
				display_data = WeaponBarUIDescriptionTemplates.all_basic_stats,
			},
		},
		sprint = {
			base = {
				sprint_trait_templates.default_sprint_stat,
				display_data = WeaponBarUIDescriptionTemplates.all_basic_stats,
			},
		},
		movement_curve_modifier = {
			base = {
				movement_curve_modifier_trait_templates.default_movement_curve_modifier_stat,
				display_data = WeaponBarUIDescriptionTemplates.all_basic_stats,
			},
		},
	},
}
weapon_template.traits = {}

local bespoke_combatsword_p1_traits = table.ukeys(WeaponTraitsBespokeCombatswordP1)

table.append(weapon_template.traits, bespoke_combatsword_p1_traits)

weapon_template.perks = {
	combatsword_p1_m1_dps_perk = {
		display_name = "loc_trait_display_combatsword_p1_m1_dps_perk",
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_dps_perk,
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_dps_perk,
			},
			action_right_light = {
				damage_trait_templates.combatsword_dps_perk,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_dps_perk,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_dps_perk,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_dps_perk,
			},
		},
	},
	combatsword_p1_m1_cleave_damage_perk = {
		display_name = "loc_trait_display_combatsword_p1_m1_cleave_damage_perk",
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
			action_right_light = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_cleave_damage_perk,
			},
		},
	},
	combatsword_p1_m1_finesse_perk = {
		display_name = "loc_trait_display_combatsword_p1_m1_finesse_perk",
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_finesse_perk,
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_finesse_perk,
			},
			action_right_light = {
				damage_trait_templates.combatsword_finesse_perk,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_finesse_perk,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_finesse_perk,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_finesse_perk,
			},
		},
		weapon_handling = {
			action_left_light = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
			action_left_heavy = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
			action_right_light = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
			action_right_heavy = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
			action_right_light_pushfollow = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
			action_right_heavy_2 = {
				weapon_handling_trait_templates.default_finesse_perk,
			},
		},
	},
	combatsword_p1_m1_cleave_targets_perk = {
		display_name = "loc_trait_display_combatsword_p1_m1_cleave_targets_perk",
		damage = {
			action_left_light = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
			action_left_heavy = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
			action_right_light = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
			action_right_heavy = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
			action_right_light_pushfollow = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
			action_right_heavy_2 = {
				damage_trait_templates.combatsword_cleave_targets_perk,
			},
		},
	},
	combatsword_p1_m1_mobility_perk = {
		display_name = "loc_trait_display_combatsword_p1_m1_mobility_perk",
		dodge = {
			base = {
				dodge_trait_templates.default_dodge_perk,
			},
		},
		sprint = {
			base = {
				sprint_trait_templates.default_sprint_perk,
			},
		},
		movement_curve_modifier = {
			base = {
				movement_curve_modifier_trait_templates.default_movement_curve_modifier_perk,
			},
		},
	},
}
weapon_template.displayed_keywords = {
	{
		display_name = "loc_weapon_keyword_fast_attack",
	},
	{
		display_name = "loc_weapon_keyword_crowd_control",
	},
}
weapon_template.displayed_attacks = {
	primary = {
		display_name = "loc_gestalt_linesman",
		type = "linesman",
		attack_chain = {
			"linesman",
			"linesman",
			"smiter",
		},
	},
	secondary = {
		display_name = "loc_gestalt_linesman",
		type = "linesman",
		attack_chain = {
			"linesman",
			"linesman",
		},
	},
	special = {
		desc = "loc_weapon_special_parry_desc",
		display_name = "loc_weapon_special_parry",
		type = "defence",
	},
}
weapon_template.weapon_card_data = {
	main = {
		{
			header = "light",
			icon = "linesman",
			value_func = "primary_attack",
		},
		{
			header = "heavy",
			icon = "linesman",
			value_func = "secondary_attack",
		},
	},
	weapon_special = {
		header = "parry",
		icon = "defence",
	},
}
weapon_template.special_action_name = "action_attack_special"

return weapon_template
