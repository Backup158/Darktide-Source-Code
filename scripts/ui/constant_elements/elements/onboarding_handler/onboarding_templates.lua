﻿-- chunkname: @scripts/ui/constant_elements/elements/onboarding_handler/onboarding_templates.lua

local UI_POPUP_INFO_DURATION = 10
local InputUtils = require("scripts/managers/input/input_utils")
local ItemUtils = require("scripts/utilities/items")
local MissionObjectiveGoal = require("scripts/extension_systems/mission_objective/utilities/mission_objective_goal")

local function _get_interaction_units_by_type(interaction_type)
	local units = {}
	local interactee_system = Managers.state.extension:system("interactee_system")
	local component_system = Managers.state.extension:system("component_system")
	local unit_to_interactee_ext = interactee_system:unit_to_extension_map()

	for interactee_unit, extension in pairs(unit_to_interactee_ext) do
		if interaction_type == extension:interaction_type() then
			local target_components = component_system:get_components(interactee_unit, "OnboardingObjectiveTarget")

			for i = 1, #target_components do
				local component = target_components[i]

				if component:is_primary_marker() then
					units[#units + 1] = interactee_unit

					break
				end
			end
		end
	end

	return units
end

local function _is_in_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "hub"

	return is_in_hub
end

local function _has_hud()
	local has_hud = Managers.ui:has_hud()

	return has_hud
end

local function is_view_or_popup_active()
	local ui_manager = Managers.ui

	return ui_manager:has_active_view() or ui_manager:handling_popups()
end

local function _is_in_prologue_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "prologue_hub"

	return is_in_hub
end

local function _get_player_character_level()
	local local_player_id = 1
	local player = Managers.player:local_player(local_player_id)
	local player_profile = player:profile()

	return player_profile.current_level
end

local function _get_player()
	local local_player_id = 1
	local player = Managers.player:local_player_safe(local_player_id)

	return player
end

local function _create_objective(objective_name, localization_key, marker_units, is_side_mission, localized_header)
	local icon = is_side_mission and "content/ui/materials/icons/objectives/bonus" or "content/ui/materials/icons/objectives/main"
	local objective_data = {
		locally_added = true,
		marker_type = "hub_objective",
		name = objective_name,
		header = localization_key,
		objective_category = is_side_mission and "side_mission" or "default",
		icon = icon,
		localized_header = localized_header,
	}
	local objective = MissionObjectiveGoal:new()

	objective:start_objective(objective_data)

	if marker_units then
		for i = 1, #marker_units do
			local unit = marker_units[i]

			objective:add_marker(unit)
		end
	end

	return objective
end

local function _get_view_input_text(input_action)
	local service_type = "View"
	local alias_key = Managers.ui:get_input_alias_key(input_action, service_type)
	local input_text = InputUtils.input_text_for_current_input_device(service_type, alias_key)

	return input_text
end

local function _get_ingame_input_text(input_action)
	local service_type = "Ingame"
	local alias_key = Managers.ui:get_input_alias_key(input_action, service_type)
	local input_text = InputUtils.input_text_for_current_input_device(service_type, alias_key)

	return input_text
end

local function _is_on_story_chapter(story_name, chapter_name)
	local current_chapter = Managers.narrative:current_chapter(story_name)

	if current_chapter then
		local current_chapter_name = current_chapter.name

		return current_chapter_name == chapter_name
	end

	return false
end

local function _is_story_complete(story_name)
	return Managers.narrative:is_story_complete(story_name)
end

local function _complete_current_story_chapter(story_name)
	Managers.narrative:complete_current_chapter(story_name)
end

local function _is_havoc_cadence_active()
	return Managers.data_service.havoc:get_havoc_cadence_status()
end

local function _journey_mission_completed(mission)
	local mission_data = Managers.data_service.mission_board:get_filtered_missions_data()
	local story_missions = mission_data.story
	local mission_completed = story_missions and story_missions[mission] and story_missions[mission].completed

	return mission_completed
end

local function _last_completed_chapter_is(story_name, chapter_name)
	local completed_chapter = Managers.narrative:last_completed_chapter(story_name)

	if completed_chapter then
		local completed_chapter_name = completed_chapter.name

		return completed_chapter_name == chapter_name
	end
end

local function _archetype_name_is(archetype_name)
	local player = _get_player()
	local player_archetype_name = player:archetype_name()

	return archetype_name == player_archetype_name
end

local function _has_new_difficulty()
	local player = _get_player()
	local profile = player:profile()
	local character_id = profile.character_id
	local new_difficulty_unlocked = Managers.data_service.mission_board:get_new_difficulty_unlocked(character_id)

	if new_difficulty_unlocked then
		Managers.data_service.mission_board:reset_cached_highest_difficulty(character_id)
	end

	return new_difficulty_unlocked
end

local templates = {
	{
		name = "Training Ground Objective - Morrow",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_prologue_hub() and _is_on_story_chapter("onboarding", "speak_to_morrow")
		end,
		on_activation = function (self)
			return
		end,
		on_event_triggered = function (self, interaction_unit)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_om_hub_01_goto_command_central_header"
			local marker_units = {
				interaction_unit,
			}
			local objective = _create_objective(objective_name, localization_key, marker_units)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		sync_on_events = {
			"event_onboarding_step_speak_to_morrow",
		},
	},
	{
		name = "Training Ground Objective - visit training ground",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_prologue_hub() and _is_on_story_chapter("onboarding", "go_to_training")
		end,
		on_activation = function (self)
			return
		end,
		on_event_triggered = function (self, interaction_unit)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_onboarding_hub_training_grounds"
			local marker_units = {
				interaction_unit,
			}
			local objective = _create_objective(objective_name, localization_key, marker_units)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		sync_on_events = {
			"event_onboarding_step_go_to_training",
		},
	},
	{
		name = "Training Ground Popup - Reward Popup",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_prologue_hub() and _is_on_story_chapter("onboarding", "training_reward")
		end,
		on_activation = function (self)
			local player = Managers.player:local_player(1)
			local profile = player:profile()
			local loadout = profile.loadout
			local new_items = {
				primary_item = loadout.slot_primary,
				secondary_item = loadout.slot_secondary,
			}

			for _, item in pairs(new_items) do
				ItemUtils.mark_item_id_as_new(item)
			end

			Managers.narrative:complete_current_chapter("onboarding", "training_reward")
		end,
		on_deactivation = function (self)
			return
		end,
		sync_on_events = {},
	},
	{
		name = "Training Ground Popup - Inventory",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_prologue_hub() and _is_on_story_chapter("onboarding", "inventory_popup")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_inventory"
			local no_cache = true
			local param = {
				input_key = "{#color(226, 199, 126)}" .. _get_view_input_text("hotkey_inventory") .. "{#reset()}",
			}
			local localized_text = Localize(localization_key, no_cache, param)
			local duration = UI_POPUP_INFO_DURATION

			local function close_callback_function()
				Managers.narrative:complete_current_chapter("onboarding", "inventory_popup")

				local level = Managers.state.mission:mission_level()

				if level then
					Level.trigger_event(level, "event_onboarding_step_inventory_popup_displayed")
				end
			end

			local close_callback = callback(close_callback_function)

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration, close_callback)
		end,
		close_condition = function (self)
			local input_service = Managers.input:get_input_service("View")

			return input_service:get("hotkey_inventory")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Training Ground Objective - Visit Chapel",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_prologue_hub() and _is_on_story_chapter("onboarding", "visit_chapel")
		end,
		on_activation = function (self)
			return
		end,
		on_event_triggered = function (self, interaction_unit)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_om_hub_01_goto_cathedral_header"
			local marker_units = {
				interaction_unit,
			}
			local objective = _create_objective(objective_name, localization_key, marker_units)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		sync_on_events = {
			"event_onboarding_step_visit_chapel",
		},
	},
	{
		name = "Training Ground Objective - Chapel Video",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and Managers.state.mission and Managers.narrative:can_complete_event("onboarding_step_chapel_video_viewed")
		end,
		on_activation = function (self)
			local ui_manager = Managers.ui
			local view_name = "video_view"

			if ui_manager:view_active(view_name) then
				local force_close = true

				ui_manager:close_view(view_name, force_close)
			end

			local function close_callback_function()
				Managers.narrative:complete_event("onboarding_step_chapel_video_viewed")

				local level = Managers.state.mission and Managers.state.mission:mission_level()

				if level then
					Level.trigger_event(level, "event_onboarding_step_chapel_video_viewed")
				end

				local function instant_easing_function()
					return 1
				end

				local time = 0.1
				local local_player = Managers.player:local_player(1)
				local fade_out_at = Managers.time:time("main") + time

				Managers.event:trigger("event_cutscene_fade_in", local_player, time, instant_easing_function)
				Managers.event:trigger("event_cutscene_fade_out_at", local_player, time, instant_easing_function, fade_out_at)
			end

			local template_name = "cs06"
			local close_callback = callback(close_callback_function)
			local context = {
				allow_skip_input = true,
				template = template_name,
				close_callback = close_callback,
			}

			ui_manager:open_view(view_name, nil, true, true, nil, context)
		end,
		on_deactivation = function (self)
			local ui_manager = Managers.ui
			local view_name = "video_view"

			if ui_manager:view_active(view_name) and not ui_manager:is_view_closing(view_name) then
				local force_close = true

				ui_manager:close_view(view_name, force_close)
			end
		end,
		sync_on_events = {},
	},
	{
		name = "Mission Terminal Objective - Access MT",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _has_hud() and _is_in_hub() and Managers.narrative:can_complete_event("onboarding_step_mission_board_introduction")
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_hub_mission_board_header"
			local interaction_type = "mission_board"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		sync_on_events = {},
	},
	{
		name = "Mission Terminal Popup - Access MT",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and Managers.narrative:can_complete_event("onboarding_step_mission_board_introduction")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_mission_board_01"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION
			local level = Managers.state.mission:mission_level()

			if level and not is_view_or_popup_active() then
				Level.trigger_event(level, "event_onboarding_step_mission_board_introduction")
			end

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 2 Unlocks Objective - Contracts Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _has_hud() and _is_in_hub() and Managers.narrative:can_complete_event("level_unlock_contract_store_visited")
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_hub_contracts"
			local interaction_type = "contracts"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		close_condition = function (self)
			return Managers.ui:view_active("contracts_background_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Level 2 Unlocks Popup - Contracts Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _is_on_story_chapter("level_unlock_popups", "level_unlock_contract_store_popup")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_contracts"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			_complete_current_story_chapter("level_unlock_popups")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 3 Unlocks Objective - Weapons Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _has_hud() and _is_in_hub() and Managers.narrative:can_complete_event("level_unlock_credits_store_visited")
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_hub_weapon_shop"
			local interaction_type = "vendor"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		close_condition = function (self)
			return Managers.ui:view_active("credits_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Level 3 Unlocks Popup - Weapons Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _is_on_story_chapter("level_unlock_popups", "level_unlock_credits_store_popup")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_weapon_shop"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			local function close_callback_function()
				_complete_current_story_chapter("level_unlock_popups")
			end

			local close_callback = callback(close_callback_function)

			_complete_current_story_chapter("level_unlock_popups")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 3 Unlocks Objective - Cosmetics Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _has_hud() and _is_in_hub() and Managers.narrative:can_complete_event("level_unlock_cosmetic_store_visited") and not _archetype_name_is("adamant")
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_hub_cosmetics_shop"
			local interaction_type = "cosmetics_vendor"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		close_condition = function (self)
			return Managers.ui:view_active("cosmetics_vendor_background_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Level 3 Unlocks Popup - Cosmetics Shop",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and Managers.narrative:can_complete_event("level_unlock_cosmetic_store_popup") and not _journey_mission_completed("km_heresy")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_cosmetics_shop"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.narrative:complete_event("level_unlock_cosmetic_store_popup")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 4 Unlocks Objective - Forge / Crafting",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _has_hud() and _is_in_hub() and Managers.narrative:can_complete_event("level_unlock_crafting_station_visited")
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_objective_hub_crafting"
			local interaction_type = "crafting"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		close_condition = function (self)
			return Managers.ui:view_active("crafting_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Level 4 Unlocks Popup - Forge / Crafting",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _is_on_story_chapter("level_unlock_popups", "level_unlock_crafting_station_popup")
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_crafting"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			local function close_callback_function()
				_complete_current_story_chapter("level_unlock_popups")
			end

			local close_callback = callback(close_callback_function)

			_complete_current_story_chapter("level_unlock_popups")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 5 Unlocks Popup - Mission Board Tier Up",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and (_is_on_story_chapter("level_unlock_popups", "level_unlock_mission_board_popup_difficulty_increased_1") or _is_on_story_chapter("level_unlock_popups", "level_unlock_mission_board_popup_difficulty_increased_2") or _is_on_story_chapter("level_unlock_popups", "level_unlock_mission_board_popup_difficulty_increased_3"))
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_mission_board_02"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			local function close_callback_function()
				_complete_current_story_chapter("level_unlock_popups")
			end

			local close_callback = callback(close_callback_function)

			_complete_current_story_chapter("level_unlock_popups")
		end,
		on_deactivation = function (self)
			local player = _get_player()
		end,
		sync_on_events = {},
	},
	{
		name = "Level 5/10/15/20/25/30 Unlocks Popup - Talent Tier Up",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and (_is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_1") or _is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_2") or _is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_3") or _is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_4") or _is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_5") or _is_on_story_chapter("level_unlock_popups", "level_unlock_talent_tier_6"))
		end,
		on_activation = function (self)
			_complete_current_story_chapter("level_unlock_popups")
		end,
	},
	{
		name = "Level 7 Introduce Objective - Penances / Track",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			if not _is_in_hub() then
				return false
			end

			if _get_player_character_level() < 7 then
				return false
			end

			return Managers.achievements:is_reward_to_claim()
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local objective_name = self.name
			local localization_key = "loc_notification_desc_penance_item_can_be_claimed"
			local interaction_type = "penances"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, localization_key, marker_units, true)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()
		end,
		sync_on_events = {},
	},
	{
		name = "Level 8 / 15 / 23 Unlocks Popup - New Device Slot",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and (_is_on_story_chapter("level_unlock_popups", "level_unlock_gadget_slot_1") or _is_on_story_chapter("level_unlock_popups", "level_unlock_gadget_slot_2") or _is_on_story_chapter("level_unlock_popups", "level_unlock_gadget_slot_3"))
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_device_slot_01"
			local no_cache = true
			local param = {
				input_key = "{#color(226, 199, 126)}" .. _get_view_input_text("hotkey_inventory") .. "{#reset()}",
			}
			local localized_text = Localize(localization_key, no_cache, param)
			local duration = UI_POPUP_INFO_DURATION

			_complete_current_story_chapter("level_unlock_popups")
			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
		close_condition = function (self)
			local input_service = Managers.input:get_input_service("View")

			return input_service:get("hotkey_inventory")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "Level 30 Introduce Objective - Havoc Start Quest",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _has_hud() and _is_on_story_chapter("unlock_havoc", "unlock_havoc_1") and _is_havoc_cadence_active()
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			if Managers.data_service.havoc:get_havoc_unlock_status() == "unlocked" then
				Managers.narrative:skip_story("unlock_havoc")

				return
			end

			local objective_name = self.name
			local localized_header = string.format("{#color(169,191,153)}%s{#reset()}\n%s", Localize("loc_quest_havoc_interact_description"), Localize("loc_quest_havoc_interact_objective"))
			local interaction_type = "gamemode_havoc"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, nil, marker_units, nil, localized_header)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self, close_condition_met)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()

			if close_condition_met then
				Managers.narrative:complete_current_chapter("unlock_havoc", "unlock_havoc_1")
			end
		end,
		close_condition = function (self)
			return Managers.ui:is_view_closing("havoc_background_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Level 30 Introduce Objective - Havoc Complete Maelstrom",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _has_hud() and _is_on_story_chapter("unlock_havoc", "unlock_havoc_2") and _is_havoc_cadence_active()
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local narrative_manager = Managers.narrative

			if Managers.data_service.havoc:get_havoc_unlock_status() == "unlocked" then
				narrative_manager:skip_story("unlock_havoc")

				return
			end

			local objective_name = self.name
			local localized_header = string.format("{#color(169,191,153)}%s{#reset()}\n%s", Localize("loc_quest_havoc_maelstrom_description"), Localize("loc_quest_havoc_maelstrom_objective"))
			local interaction_type = "gamemode_havoc"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, nil, marker_units, nil, localized_header)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
			Managers.data_service.havoc:set_havoc_unlock_status("awaiting_maelstrom_completion")
		end,
		on_deactivation = function (self, close_condition_met)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()

			if close_condition_met then
				Managers.narrative:complete_current_chapter("unlock_havoc", "unlock_havoc_2")
			end
		end,
		close_condition = function (self)
			return Managers.data_service.havoc:get_ever_received_havoc_order()
		end,
		sync_on_events = {},
	},
	{
		name = "Level 30 Introduce Objective - Havoc Complete Quest",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _has_hud() and _is_on_story_chapter("unlock_havoc", "unlock_havoc_3") and _is_havoc_cadence_active()
		end,
		on_activation = function (self)
			if self.objective then
				Log.warning("onboarding_templates", "[on_event_triggered] trying to start objective '%s' when it's already active", self.name)

				return
			end

			local narrative_manager = Managers.narrative

			if Managers.data_service.havoc:get_havoc_unlock_status() == "unlocked" then
				narrative_manager:skip_story("unlock_havoc")

				return
			end

			local objective_name = self.name
			local localized_header = string.format("{#color(169,191,153)}%s{#reset()}\n%s", Localize("loc_quest_havoc_final_description"), Localize("loc_quest_havoc_final_objective"))
			local interaction_type = "gamemode_havoc"
			local marker_units = _get_interaction_units_by_type(interaction_type)
			local objective = _create_objective(objective_name, nil, marker_units, nil, localized_header)

			self.objective = objective

			Managers.event:trigger("event_add_mission_objective", objective)
		end,
		on_deactivation = function (self, close_condition_met)
			if not self.objective then
				return
			end

			local objective = self.objective
			local objective_name = objective:name()

			Managers.event:trigger("event_remove_mission_objective", objective_name)

			self.objective = nil

			objective:destroy()

			if close_condition_met then
				Managers.narrative:complete_current_chapter("unlock_havoc", "unlock_havoc_3")
				Managers.data_service.havoc:set_havoc_unlock_status("unlocked")
			end
		end,
		close_condition = function (self)
			return Managers.ui:is_view_closing("havoc_background_view")
		end,
		sync_on_events = {},
	},
	{
		name = "Unspent Talent points available",
		once_per_state = true,
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			if _is_in_hub() then
				local player = _get_player()
				local profile = player and player:profile()

				if profile then
					local talent_points = profile.talent_points or 0
					local points_spent = 0

					for widget_name, points_spent_on_node in pairs(profile.selected_nodes) do
						points_spent = points_spent + points_spent_on_node
					end

					if points_spent < talent_points then
						return true
					end
				end

				return false
			end

			return false
		end,
		on_activation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_talent_points_reminder"
			local no_cache = true
			local param = {
				input_key = "{#color(226, 199, 126)}" .. _get_view_input_text("hotkey_inventory") .. "{#reset()}",
			}
			local localized_text = Localize(localization_key, no_cache, param)
			local duration = UI_POPUP_INFO_DURATION

			local function close_callback_function()
				return
			end

			local close_callback = callback(close_callback_function)

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration, close_callback)
		end,
		close_condition = function (self)
			local input_service = Managers.input:get_input_service("View")

			return input_service:get("hotkey_inventory")
		end,
		on_deactivation = function (self)
			local player = _get_player()

			Managers.event:trigger("event_player_hide_onboarding_message", player)
		end,
		sync_on_events = {},
	},
	{
		name = "season_1_twins_prologue",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _is_on_story_chapter("s1_twins", "s1_twins_prologue")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("s1_twins", "s1_twins_prologue")

			local level = Managers.state.mission:mission_level()

			if level then
				Level.trigger_event(level, "s1_event_twins_prologue")
			end
		end,
	},
	{
		name = "season_1_twins_epilogue_1",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _is_on_story_chapter("s1_twins", "s1_twins_epilogue_1")
		end,
		on_activation = function (self)
			local level = Managers.state.mission:mission_level()

			if level then
				Level.trigger_event(level, "s1_event_twins_epilogue_1")
			end
		end,
	},
	{
		name = "season_1_twins_epilogue_3",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _is_on_story_chapter("s1_twins", "s1_twins_epilogue_3")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("s1_twins", "s1_twins_epilogue_3")

			local level = Managers.state.mission:mission_level()

			if level then
				Level.trigger_event(level, "s1_event_twins_epilogue_3")
			end
		end,
	},
	{
		name = "Player Journey - Mission Board Tier Up",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _has_hud() and _has_new_difficulty()
		end,
		on_activation = function (self)
			local player = _get_player()
			local current_difficulty_name = Managers.data_service.mission_board:get_difficulty_progression_data().current.name
			local localization_key = "loc_onboarding_popup_difficulty_unlocked_" .. current_difficulty_name
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
	},
	{
		name = "main_story_km_station",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("km_station") and not Managers.narrative:last_completed_chapter("main_story") or _journey_mission_completed("km_heresy") and _last_completed_chapter_is("main_story", "km_station")
		end,
		on_activation = function (self)
			if _journey_mission_completed("km_heresy") then
				Managers.narrative:complete_chapter_by_name("main_story", "km_heresy")
				Managers.narrative:complete_event("level_unlock_credits_store_visited")
				Managers.narrative:complete_event("level_unlock_crafting_station_visited")
				Managers.narrative:complete_event("level_unlock_contract_store_visited")
				Managers.narrative:complete_event("level_unlock_cosmetic_store_visited")
				Managers.narrative:complete_event("level_unlock_cosmetic_store_popup")
				Managers.narrative:complete_event("level_unlock_premium_store_visited")
				Managers.narrative:complete_event("level_unlock_barber_visited")
			else
				if not _archetype_name_is("adamant") then
					local cinematic_scene_system = Managers.state.extension:system("cinematic_scene_system")

					cinematic_scene_system:play_cutscene("path_of_trust_01")
				end

				Managers.narrative:complete_current_chapter("main_story")
			end
		end,
		close_condition = function (self)
			if not _journey_mission_completed("km_heresy") then
				return Managers.ui:is_view_closing("cutscene_view") or _archetype_name_is("adamant")
			else
				return true
			end
		end,
		on_deactivation = function (self)
			if not _journey_mission_completed("km_heresy") then
				local player = _get_player()
				local localization_key = "loc_onboarding_popup_weapon_shop"
				local localized_text = Localize(localization_key)
				local duration = UI_POPUP_INFO_DURATION

				Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
			end
		end,
	},
	{
		name = "main_story_dm_stockpile",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("dm_stockpile") and _is_on_story_chapter("main_story", "dm_stockpile")
		end,
		on_activation = function (self)
			if not _archetype_name_is("adamant") then
				local player = _get_player()
				local localization_key = "loc_onboarding_popup_cosmetics_shop"
				local localized_text = Localize(localization_key)
				local duration = UI_POPUP_INFO_DURATION

				Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
			end

			Managers.narrative:complete_current_chapter("main_story")
		end,
	},
	{
		name = "main_story_hm_cartel",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("hm_cartel") and _is_on_story_chapter("main_story", "hm_cartel")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("main_story")
		end,
	},
	{
		name = "main_story_km_enforcer",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("km_enforcer") and _is_on_story_chapter("main_story", "km_enforcer")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("main_story")

			local player = _get_player()
			local localization_key = "loc_onboarding_popup_crafting"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
	},
	{
		name = "main_story_cm_habs",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("cm_habs") and _is_on_story_chapter("main_story", "cm_habs")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("main_story")

			if not _archetype_name_is("adamant") then
				local cinematic_scene_system = Managers.state.extension:system("cinematic_scene_system")

				cinematic_scene_system:play_cutscene("path_of_trust_05")
			end
		end,
		close_condition = function (self)
			return Managers.ui:is_view_closing("cutscene_view") or _archetype_name_is("adamant")
		end,
		on_deactivation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_live_events_unlocked"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION
		end,
	},
	{
		name = "main_story_dm_propaganda",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("dm_propaganda") and (_last_completed_chapter_is("main_story", "cm_habs") or _last_completed_chapter_is("main_story", "fm_cargo_0_1") or _last_completed_chapter_is("main_story", "core_research_0_2"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "cm_habs") then
				jump_to_chapter = "dm_propaganda_1_0"
			elseif _last_completed_chapter_is("main_story", "fm_cargo_0_1") then
				jump_to_chapter = "dm_propaganda_1_1"
			elseif _last_completed_chapter_is("main_story", "core_research_0_2") then
				jump_to_chapter = "dm_propaganda_1_2"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)

			local player = Managers.player:local_player(1)

			Managers.achievements:unlock_achievement(player, "unlock_contracts", true)

			local localization_key = "loc_onboarding_popup_contracts"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
	},
	{
		name = "main_story_fm_cargo",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _journey_mission_completed("fm_cargo") and (_last_completed_chapter_is("main_story", "cm_habs") or _last_completed_chapter_is("main_story", "dm_propaganda_1_0") or _last_completed_chapter_is("main_story", "hm_strain_2_0"))
		end,
		on_activation = function (self)
			local ui_manager = Managers.ui
			local view_name = "video_view"
			local template_name = "core_research_intro"
			local context = {
				allow_skip_input = true,
				template = template_name,
			}

			ui_manager:open_view(view_name, nil, true, true, nil, context)
		end,
		close_condition = function (self)
			return Managers.ui:is_view_closing("video_view")
		end,
		on_deactivation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "cm_habs") then
				jump_to_chapter = "fm_cargo_0_1"
			elseif _last_completed_chapter_is("main_story", "dm_propaganda_1_0") then
				jump_to_chapter = "fm_cargo_1_1"
			elseif _last_completed_chapter_is("main_story", "hm_strain_2_0") then
				jump_to_chapter = "fm_cargo_2_1"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)

			local level = Managers.state.mission:mission_level()

			if level then
				Level.trigger_event(level, "horde_intro_vo")
			end

			local player = _get_player()
			local localization_key = "loc_onboarding_popup_horde_mode_unlocked"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
	},
	{
		name = "main_story_hm_strain",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and _journey_mission_completed("hm_strain") and (_last_completed_chapter_is("main_story", "dm_propaganda_1_0") or _last_completed_chapter_is("main_story", "fm_cargo_1_1") or _last_completed_chapter_is("main_story", "dm_propaganda_1_1") or _last_completed_chapter_is("main_story", "core_research_1_2") or _last_completed_chapter_is("main_story", "dm_propaganda_1_2"))
		end,
		on_activation = function (self)
			if not _archetype_name_is("adamant") then
				local cinematic_scene_system = Managers.state.extension:system("cinematic_scene_system")

				cinematic_scene_system:play_cutscene("path_of_trust_08")
			end
		end,
		close_condition = function (self)
			local cinematic_manager = Managers.state.cinematic

			return cinematic_manager and cinematic_manager:last_story_time_left() and cinematic_manager:last_story_time_left() < 0.5 or not is_view_or_popup_active()
		end,
		on_deactivation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "dm_propaganda_1_0") then
				jump_to_chapter = "hm_strain_2_0"
			elseif _last_completed_chapter_is("main_story", "fm_cargo_1_1") or _last_completed_chapter_is("main_story", "dm_propaganda_1_1") then
				jump_to_chapter = "hm_strain_2_1"
			elseif _last_completed_chapter_is("main_story", "core_research_1_2") or _last_completed_chapter_is("main_story", "dm_propaganda_1_2") then
				jump_to_chapter = "hm_strain_2_2"

				local ui_manager = Managers.ui
				local view_name = "video_view"
				local template_name = "s1_intro"
				local context = {
					allow_skip_input = true,
					template = template_name,
				}

				ui_manager:open_view(view_name, nil, true, true, nil, context)
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_core_research",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("core_research") and (_last_completed_chapter_is("main_story", "fm_cargo_0_1") or _last_completed_chapter_is("main_story", "fm_cargo_1_1") or _last_completed_chapter_is("main_story", "dm_propaganda_1_1") or _last_completed_chapter_is("main_story", "hm_strain_2_1") or _last_completed_chapter_is("main_story", "fm_cargo_2_1"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "fm_cargo_0_1") then
				jump_to_chapter = "core_research_0_2"
			elseif _last_completed_chapter_is("main_story", "fm_cargo_1_1") or _last_completed_chapter_is("main_story", "dm_propaganda_1_1") then
				jump_to_chapter = "core_research_1_2"
			elseif _last_completed_chapter_is("main_story", "hm_strain_2_1") or _last_completed_chapter_is("main_story", "fm_cargo_2_1") then
				jump_to_chapter = "core_research_2_2"

				local ui_manager = Managers.ui
				local view_name = "video_view"
				local template_name = "s1_intro"
				local context = {
					allow_skip_input = true,
					template = template_name,
				}

				ui_manager:open_view(view_name, nil, true, true, nil, context)
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_fm_armoury",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("fm_armoury") and (_last_completed_chapter_is("main_story", "core_research_2_2") or _last_completed_chapter_is("main_story", "hm_strain_2_2"))
		end,
		on_activation = function (self)
			Managers.narrative:complete_chapter_by_name("main_story", "fm_armoury")
		end,
	},
	{
		name = "main_story_cm_raid",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("cm_raid") and _is_on_story_chapter("main_story", "cm_raid")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("main_story")
		end,
	},
	{
		name = "main_story_km_enforcer_twins",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("km_enforcer_twins") and _is_on_story_chapter("main_story", "km_enforcer_twins")
		end,
		on_activation = function (self)
			Managers.narrative:complete_current_chapter("main_story")

			local ui_manager = Managers.ui
			local view_name = "video_view"
			local template_name = "cin_nox_alpha"
			local context = {
				allow_skip_input = true,
				template = template_name,
			}

			ui_manager:open_view(view_name, nil, true, true, nil, context)
		end,
	},
	{
		name = "main_story_fm_resurgence",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("fm_resurgence") and (_last_completed_chapter_is("main_story", "km_enforcer_twins") or _last_completed_chapter_is("main_story", "dm_rise_0_1"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "km_enforcer_twins") then
				jump_to_chapter = "fm_resurgence_1_0"
			elseif _last_completed_chapter_is("main_story", "dm_rise_0_1") then
				jump_to_chapter = "fm_resurgence_1_1"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_dm_rise",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("dm_rise") and (_last_completed_chapter_is("main_story", "km_enforcer_twins") or _last_completed_chapter_is("main_story", "fm_resurgence_1_0") or _last_completed_chapter_is("main_story", "cm_archives_2_0") or _last_completed_chapter_is("main_story", "hm_complex_3_0"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "km_enforcer_twins") then
				jump_to_chapter = "dm_rise_0_1"
			elseif _last_completed_chapter_is("main_story", "fm_resurgence_1_0") then
				jump_to_chapter = "dm_rise_1_1"
			elseif _last_completed_chapter_is("main_story", "cm_archives_2_0") then
				jump_to_chapter = "dm_rise_2_1"
			elseif _last_completed_chapter_is("main_story", "hm_complex_3_0") then
				jump_to_chapter = "dm_rise_3_1"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_cm_archives",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("cm_archives") and (_last_completed_chapter_is("main_story", "fm_resurgence_1_0") or _last_completed_chapter_is("main_story", "dm_rise_1_1") or _last_completed_chapter_is("main_story", "fm_resurgence_1_1"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "fm_resurgence_1_0") then
				jump_to_chapter = "cm_archives_2_0"
			elseif _last_completed_chapter_is("main_story", "dm_rise_1_1") or _last_completed_chapter_is("main_story", "fm_resurgence_1_1") then
				jump_to_chapter = "cm_archives_2_1"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_hm_complex",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("hm_complex") and (_last_completed_chapter_is("main_story", "cm_archives_2_0") or _last_completed_chapter_is("main_story", "dm_rise_2_1") or _last_completed_chapter_is("main_story", "cm_archives_2_1"))
		end,
		on_activation = function (self)
			local jump_to_chapter

			if _last_completed_chapter_is("main_story", "cm_archives_2_0") then
				jump_to_chapter = "hm_complex_3_0"
			elseif _last_completed_chapter_is("main_story", "dm_rise_2_1") or _last_completed_chapter_is("main_story", "cm_archives_2_1") then
				jump_to_chapter = "hm_complex_3_1"
			end

			Managers.narrative:complete_chapter_by_name("main_story", jump_to_chapter)
		end,
	},
	{
		name = "main_story_km_heresy",
		valid_states = {
			"GameplayStateRun",
		},
		validation_func = function (self)
			return _is_in_hub() and not is_view_or_popup_active() and _journey_mission_completed("km_heresy") and (_last_completed_chapter_is("main_story", "hm_complex_3_1") or _last_completed_chapter_is("main_story", "dm_rise_3_1"))
		end,
		on_activation = function (self)
			Managers.narrative:complete_chapter_by_name("main_story", "km_heresy")

			if not _archetype_name_is("adamant") then
				local cinematic_scene_system = Managers.state.extension:system("cinematic_scene_system")

				cinematic_scene_system:play_cutscene("path_of_trust_09")
			end
		end,
		close_condition = function (self)
			return Managers.ui:is_view_closing("cutscene_view") or _archetype_name_is("adamant")
		end,
		on_deactivation = function (self)
			local player = _get_player()
			local localization_key = "loc_onboarding_popup_maelstrom_unlocked"
			local localized_text = Localize(localization_key)
			local duration = UI_POPUP_INFO_DURATION

			Managers.event:trigger("event_player_display_onboarding_message", player, localized_text, duration)
		end,
	},
}

return templates
