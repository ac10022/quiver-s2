meta = {
    name = 'Quiver',
    version = '1.1',
    description = 'Adds a quiver into the game, which allows you to hold arrows in an inventory which can then be fetched later.\nThis mod uses the SPRINT/WALK key as its main keybind for each character.',
    author = 'ac10022',
}

local quiver

local iquiver = create_image("quiver.png")
local iarrow = create_image("arrow.png")
local imetal = create_image("metal_arrow.png")
local ilight = create_image("light_arrow.png")

register_option_bool("disable_prompts", "Disable text prompts", "Disables instructions which appear at the bottom of the screen.", false)
register_option_int("ui_text_size", "UI text size", "Change if you are using a resolution other than 1920x1080 and the UI looks broken", 15, 0, 100)

local function pressed(iv)

	local ar = state.player_inputs.player_settings[iv].auto_run_enabled

	--[[

		If you know what you are doing, you can remap keybinds below here...

		Note: "ar" detects whether auto-run is enabled for a player,
		this is needed because otherwise with auto-run enabled, the game
		constantly thinks the run keybind (INPUTS.RUN) is being pressed.
		You could remove the whole variable completely if you plan to change
		the keybind to INPUTS.DOOR or INPUTS.JOURNAL or something

	]]

    if test_mask(state.player_inputs.player_slots[iv].buttons, INPUTS.RUN) and (not ar) then
        return true
	elseif (not test_mask(state.player_inputs.player_slots[iv].buttons, INPUTS.RUN)) and ar then
		return true
	end
    return false

end

local function aholding()

	for _, p in ipairs(players) 
	do

		if get_entity_type(p.holding_uid) == 371 or get_entity_type(p.holding_uid) == 373 or get_entity_type(p.holding_uid) == 374 then
			return true
		end

	end
	return false

end

local function loadable()

	for i, p in ipairs(players) do

		local holding = get_entity_type(p.holding_uid)
		local holdinge = get_entity(p.holding_uid)
		
		if ((holding == 590 and holdinge.animation_frame == 167) or (holding == 579 and holdinge.animation_frame == 66)) and (quiver[i*3-2] ~= 0 or quiver[i*3-1] ~= 0 or quiver[i*3] ~= 0) then
			return true
		end

	end
	return false

end

local function bn(v)
	return v and 1 or 0
end

local function quiver_full()
	for i = 1, 12 do
		if quiver[i] ~= 0 then return true end
	end
	return false
end

set_callback(function()

	quiver = {0,0,0,0,0,0,0,0,0,0,0,0}

end, ON.START)

set_callback(function()

	quiver = {0,0,0,0,0,0,0,0,0,0,0,0}

end, ON.ARENA_INTRO)

set_post_entity_spawn(function(pl)
	pl:set_post_kill(
		function(_, _, _)
			for i, p in ipairs(players) do
				if tostring(p.uid) == tostring(pl.uid) and quiver[i*3] > 0 then
					local x, y, layer = get_position(pl.uid)
					spawn_entity(374, x, y, layer, math.random(), math.random())
					quiver[i*3-2], quiver[i*3-1], quiver[i*3] = 0, 0, 0
				end
			end
		end
	)
end, SPAWN_TYPE.ANY, MASK.PLAYER)

set_callback(function()

	for i, p in ipairs(players) do

		local holding = get_entity_type(p.holding_uid)
		local holdinge = get_entity(p.holding_uid)

		local aheld = (holding == 371 or holding == 373 or holding == 374) and true or false

		local prompt = (((holding == 590 and holdinge.animation_frame == 167) or (holding == 579 and holdinge.animation_frame == 66)) and (quiver[i*3-2] ~= 0 or quiver[i*3-1] ~= 0 or quiver[i*3] ~= 0)) and true or false

		if aheld and pressed(i) then
			
			if holding == 371 then quiver[i*3-2] = quiver[i*3-2] + 1
			elseif holding == 373 then quiver[i*3-1] = quiver[i*3-1] + 1
			else quiver[i*3] = quiver[i*3] + 1 end
			
			get_entity(p.holding_uid):destroy()

		elseif prompt and pressed(i) then
		
			if quiver[i*3-2] ~= 0 then
				holdinge:apply_metadata(1)
				quiver[i*3-2] = quiver[i*3-2] - 1
			elseif quiver[i*3-1] ~= 0 then
				holdinge:apply_metadata(2)
				quiver[i*3-1] = quiver[i*3-1] - 1
			else
				holdinge:apply_metadata(4)
				quiver[i*3] = quiver[i*3] - 1
			end

		end
		
	end

end, ON.GAMEFRAME)

set_callback(function(draw_ctx)

	if not options.disable_prompts then

		if aholding() and players[1].uid and game_manager.pause_ui.visibility == 0 then
			local x = draw_text_size(18.0, "Press the sprint/walk key to load arrow into quiver")
			draw_ctx:draw_text(0 - x/2, -0.9, 18.0, "Press the sprint/walk key to load arrow into quiver", rgba(255, 255, 255, 255))
		end
	
		if loadable() and players[1].uid and game_manager.pause_ui.visibility == 0 then
			local x = draw_text_size(18.0, "Press the sprint/walk key to load an arrow from your quiver into your weapon")
			draw_ctx:draw_text(0 - x/2, -0.9, 18.0, "Press the sprint/walk key to load an arrow from your quiver into your weapon", rgba(255, 255, 255, 255))
		end

	end
	
	-- Drawing is so fun and not time consuming at all :3
	local aw, ah, ax, ay, bw, bh = 0.045, 0.1, -0.95, -0.85, 0.03, 0.018

	if (state.screen == 12 or state.screen == 26) and game_manager.pause_ui.visibility == 0 and quiver_full() then

		draw_ctx:draw_rect_filled(ax-0.02, ay+0.02, ax+aw+0.03+(0.03*(#players+1)), ay-ah-0.02, 10.0, rgba(0, 0, 0, 200))

		draw_ctx:draw_image(iquiver, ax, ay, ax+aw, ay-ah, 0, 0, 1, 1, rgba(255, 255, 255, 255))

		draw_ctx:draw_image(iarrow, ax+0.055, ay-0.01, ax+0.055+bw, ay-0.01-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))
		draw_ctx:draw_image(imetal, ax+0.055, ay-0.04, ax+0.055+bw, ay-0.04-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))
		draw_ctx:draw_image(ilight, ax+0.055, ay-0.07, ax+0.055+bw, ay-0.07-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))

		for o = 1, #players do
			draw_ctx:draw_text(ax+0.095+((o-1) * 0.03), ay-0.008, math.abs(options.ui_text_size), tostring(quiver[3*o-2]).."\n"..tostring(quiver[3*o-1]).."\n"..tostring(quiver[3*o]), rgba(255-(bn(o == 2))*255, 255-(bn(o == 3))*255, 255-(bn(o == 4))*255, 255))
		end

	end

end, ON.GUIFRAME)