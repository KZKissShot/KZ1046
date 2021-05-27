ui.new_label("LUA", "B", "o��������������������o Menu border o��������������������o")

local enable = ui.new_checkbox("LUA", "B", "Enable")
local size = ui.new_slider("LUA", "B", "Border size",  1, 10, 1, true, nil)
local rfrequ = ui.new_slider("LUA", "B", "Rainbow  frequenz",  1, 100, 1, true, nil, .1)

ui.new_label("LUA", "B", "o��������������������������������������������������������������������o")

local function hsv_to_rgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r * 255, g * 255, b * 255, a * 255
end

local function func_rgb_rainbowize(frequency, rgb_split_ratio)
    local r, g, b, a = hsv_to_rgb(globals.realtime() * frequency, 1, 1, 1)

    r = r * rgb_split_ratio
    g = g * rgb_split_ratio
    b = b * rgb_split_ratio

    return r, g, b
end

local function on_paint(ctx)
	
	if ui.get(enable) then

	if ui.is_menu_open() then
	
		local mx, my = ui.menu_position()
		local mw, mh = ui.menu_size()
		
		
	
local r, g, b = func_rgb_rainbowize((ui.get(rfrequ)/10), 1)

		renderer.gradient(mx - ui.get(size), my - ui.get(size), mw + (ui.get(size)*2), ui.get(size), r, g, b, 255, r, b, g, 255, true)
		renderer.gradient(mx + mw, my, ui.get(size), mh + ui.get(size), r, b, g, 255, g, b, r, 255, false)
		renderer.gradient(mx, my + mh, mw + ui.get(size), ui.get(size), g, r, b, 255, g, b, r, 255, true)
		renderer.gradient(mx - ui.get(size), my, ui.get(size), mh + ui.get(size), r, g, b, 255, g, r, b, 255, false)
	
	end
	end
end

client.set_event_callback("paint_ui", on_paint)