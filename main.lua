meta = {
    name = 'Quiver',
    version = '1.0',
    description = 'Adds a quiver into the game, which allows you to hold arrows in an inventory which can then be fetched later.\nDefault keybinds for this mod are \'Q\' on keyboards and Left Trigger on controllers.',
    author = 'ac10022',
}

local cio = get_io()
local aheld
local prompt

local iquiver = create_image("quiver.png")
local iarrow = create_image("arrow.png")
local imetal = create_image("metal_arrow.png")
local ilight = create_image("light_arrow.png")

register_option_bool("disable_prompts", "Disable prompts", "Disables instructions which appear at the bottom of the screen.", false)
register_option_bool("disable_ui", "Disable quiver UI", "Disables the UI which shows when the quiver isn't empty.", false)

set_callback(function()

	quiver = {
		["371"] = 0,
		["373"] = 0,
		["374"] = 0
	}

end, ON.START)

set_callback(function()
	
	local holding = get_entity_type(players[1].holding_uid)
	local holdinge = get_entity(players[1].holding_uid)

	aheld = (holding == 371 or holding == 373 or holding == 374) and true or false

	prompt = (((holding == 590 and holdinge.animation_frame == 167) or (holding == 579 and holdinge.animation_frame == 66)) and (quiver["371"] ~= 0 or quiver["373"] ~= 0 or quiver["374"] ~= 0)) and true or false

	--[[
		You can change the keybinds below!
		Keyboard: Replace 'Q' with the keyboard key of your choice
		Controller: It's more annoying, lt (left trigger) and rt (right trigger) recommended, otherwise figure out how to use specific inputs using the API documentation
	]]
	
	if aheld and (cio.keydown('Q') or cio.gamepad.lt > 0.5) then -- <= replace keybind here
		
		if holding == 371 then quiver["371"] = quiver["371"] + 1
		elseif holding == 373 then quiver["373"] = quiver["373"] + 1
		else quiver["374"] = quiver["374"] + 1 end
		
		get_entity(players[1].holding_uid):destroy()

	elseif prompt and (cio.keydown('Q') or cio.gamepad.lt > 0.5) then -- <= replace keybind here too
	
		if quiver["371"] ~= 0 then
			holdinge:apply_metadata(1)
			quiver["371"] = quiver["371"] - 1
		elseif quiver["373"] ~= 0 then
			holdinge:apply_metadata(2)
			quiver["373"] = quiver["373"] - 1
		else
			holdinge:apply_metadata(4)
			quiver["374"] = quiver["374"] - 1
		end

	end

end, ON.FRAME)

set_callback(function(draw_ctx)

	if aheld == true and players[1].uid and game_manager.pause_ui.visibility == 0 and (not options.disable_prompts) then
		local x = draw_text_size(18.0, "Press 'Q' / Left Trigger to load arrow into quiver")
		draw_ctx:draw_text(0 - x/2, -0.9, 18.0, "Press 'Q' / Left Trigger to load arrow into quiver", rgba(255, 255, 255, 255))
	end

	if prompt == true and players[1].uid and game_manager.pause_ui.visibility == 0 and (not options.disable_prompts) then
		local x = draw_text_size(18.0, "Press 'Q' / Left Trigger to load an arrow from your quiver into your weapon")
		draw_ctx:draw_text(0 - x/2, -0.9, 18.0, "Press 'Q' / Left Trigger to load an arrow from your quiver into your weapon", rgba(255, 255, 255, 255))
	end

	-- Drawing is so fun and not time consuming at all :3
	local aw = 0.045
    local ah = 0.1
    local ax = -0.95
    local ay = -0.85

	local bw = 0.03
	local bh = 0.018

	local usize = math.floor(cio.displaysize.x * 0.0075 + 1.5)

	if state.screen == 12 and game_manager.pause_ui.visibility == 0 and (quiver["371"] ~= 0 or quiver["373"] ~= 0 or quiver["374"] ~= 0) and (not options.disable_ui) then

		draw_ctx:draw_rect_filled(ax-0.02, ay+0.02, ax+aw+0.1, ay-ah-0.02, 10.0, rgba(0, 0, 0, 200))

		draw_ctx:draw_image(iquiver, ax, ay, ax+aw, ay-ah, 0, 0, 1, 1, rgba(255, 255, 255, 255))

		draw_ctx:draw_image(iarrow, ax+0.055, ay-0.01, ax+0.055+bw, ay-0.01-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))
		draw_ctx:draw_image(imetal, ax+0.055, ay-0.04, ax+0.055+bw, ay-0.04-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))
		draw_ctx:draw_image(ilight, ax+0.055, ay-0.07, ax+0.055+bw, ay-0.07-bh, 0, 0, 1, 1, rgba(255, 255, 255, 255))

		draw_ctx:draw_text(ax+0.095, ay-0.008, usize, tostring(quiver["371"]).."\n"..tostring(quiver["373"]).."\n"..tostring(quiver["374"]), rgba(255, 255, 255, 255))

	end

end, ON.GUIFRAME)