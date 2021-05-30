local min_hitchance = ui.reference("RAGE", "Aimbot", "Minimum hit chance")

client.set_event_callback("paint", function()
    local hitchance = ui.get(min_hitchance)
    renderer.indicator(255, 255, 255, 255, "Hit chance: "..(hitchance.."%"))
end)

local mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage")

client.set_event_callback("paint", function()
    local dmg = ui.get(mindmg)
    renderer.indicator(255, 255, 255, 255, "Min DMG=> "..((dmg > 100) and ("HP+"..(dmg-100)) or dmg))
end)



------------------------------------------------------------------------------------LBY显示-------------------------------------------------------------------------------------------------------
local aa_enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled")
local yaw = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
local main_enabled = ui.new_checkbox("VISUALS", "Other ESP", "long indicator")
local x_slider = ui.new_slider("VISUALS", "Other ESP", "long indicator X offset", 0, 150, 87)
local y_slider = ui.new_slider("VISUALS", "Other ESP", "long indicator Y offset", 0, 150, 20)

local angle = 0
client.set_event_callback("setup_command", function(c)
	if c.chokedcommands == 0 then
		if c.in_use == 1 then
			angle = 0
		else
			angle = math.min(57, math.abs(entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11)*120-60))
		end
	end
end)

client.set_event_callback("paint", function()
	if ui.get(main_enabled) and ui.get(aa_enabled) and ui.get(yaw) ~= "Off" and entity.is_alive(entity.get_local_player()) then
		local color = { 255-(angle*2.29824561404), angle*3.42105263158, angle*0.22807017543 }
		local y = renderer.indicator(color[1], color[2], color[3], 255, "LONG")+ui.get(y_slider)
		local x = ui.get(x_slider)
		renderer.circle_outline(x, y, 0, 0, 0, 155, 10, 0, 1, 6)
		renderer.circle_outline(x, y, color[1], color[2], color[3], 255, 56, 100, angle*0.01754385964, 4)
	end
end)
------------------------------------------------------------------------------------LBY显示-------------------------------------------------------------------------------------------------------