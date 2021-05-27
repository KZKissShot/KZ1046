--------------------------------------------------------------------------------
-- Cache common functions
--------------------------------------------------------------------------------
local client_camera_angles, client_trace_line, entity_get_local_player, entity_get_players, entity_get_prop, entity_hitbox_position, math_acos, math_cos, math_sin, math_sqrt, ui_get, ui_new_checkbox, ui_new_hotkey, ui_reference, ui_set, ui_set_callback = client.camera_angles, client.trace_line, entity.get_local_player, entity.get_players, entity.get_prop, entity.hitbox_position, math.acos, math.cos, math.sin, math.sqrt, ui.get, ui.new_checkbox, ui.new_hotkey, ui.reference, ui.set, ui.set_callback

--------------------------------------------------------------------------------
-- Constants and variables
--------------------------------------------------------------------------------
local legit_pen_ref = ui_new_checkbox("RAGE", "Other", "Legit auto wall")
local legit_pen_toggle_ref = ui_new_hotkey("RAGE", "Other", "Hotkey", true)

local maximum_fov_ref = ui_reference("RAGE", "Aimbot", "Maximum FOV")
local auto_penetration_ref = ui_reference("RAGE", "Aimbot", "Automatic penetration")

local PI = 3.14159265358979323846
local DEG_TO_RAD = PI / 180.0
local RAD_TO_DEG = 180.0 / PI

--------------------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------------------
local function vec3_normalize(x, y, z)
	local len = math_sqrt(x*x + y*y + z*z)
	if len == 0 then
		return 0, 0, 0
	end
	local r = 1 / len
	return x*r, y*r, z*r
end

local function vec3_dot(ax, ay, az, bx, by, bz)
	return ax*bx + ay*by + az*bz
end

local function angle_to_vec(pitch, yaw)
	local pitch_rad, yaw_rad = DEG_TO_RAD*pitch, DEG_TO_RAD*yaw
	local sp, cp, sy, cy = math_sin(pitch_rad), math_cos(pitch_rad), math_sin(yaw_rad), math_cos(yaw_rad)
	return cp*cy, cp*sy, -sp
end

local function calculate_fov_to_player(ent, lx, ly, lz, fx, fy, fz)
    local px, py, pz = entity_get_prop(ent, "m_vecOrigin")
    local dx, dy, dz = vec3_normalize(px-lx, py-ly, lz-lz)
    local dot_product = vec3_dot(dx, dy, dz, fx, fy, fz)
    local cos_inverse = math_acos(dot_product)
	return RAD_TO_DEG*cos_inverse
end

local function get_closest_player_to_crosshair(lx, ly, lz, pitch, yaw)
    -- Calculate our forward vector once instead of doing it for each player
    local fx, fy, fz = angle_to_vec(pitch, yaw)
    local enemy_players = entity_get_players(true)
    
    local nearest_player = nil
    local nearest_player_fov = math.huge

    for i=1, #enemy_players do
        local enemy_ent = enemy_players[i]

        -- Calculate the FOV to the player so we can determine if they are closer than the stored player
        local fov_to_player = calculate_fov_to_player(enemy_ent, lx, ly, lz, fx, fy, fz)

        if fov_to_player <= nearest_player_fov then
            nearest_player = enemy_ent
            nearest_player_fov = fov_to_player
        end
    end

    return nearest_player, nearest_player_fov
end

local function is_player_visible(local_player, lx, ly, lz, ent)
    for i=0, 18 do
        -- Get the current hitbox position so that we can run a trace to it and see if it is hit
        local ex, ey, ez = entity_hitbox_position(ent, i)
        -- Run the trace from our eye position to the hitbox if the trace hits the enemy then we know the player is visible
        local _, entindex = client_trace_line(local_player, lx, ly, lz, ex, ey, ez)

        if entindex == ent then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Callback functions
--------------------------------------------------------------------------------
local function on_run_command()
    if ui_get(legit_pen_toggle_ref) then
        ui_set(auto_penetration_ref, true)
        goto end_command
    end

    -- Get the aimbots maximum fov so we can determine if a player is within that range
    local maximum_fov = ui_get(maximum_fov_ref)
    local local_player = entity_get_local_player()

    -- Get the local players origin, pitch, and yaw so that we can calculate our FOV to enemies
    local pitch, yaw = client_camera_angles()
    local lx, ly, lz = entity_get_prop(local_player, "m_vecOrigin")
    
    -- Get the nearest player to our crosshair, and the fov to that player so we can determine if they are in the aimbots range
    local nearest_player, nearest_player_fov = get_closest_player_to_crosshair(lx, ly, lz, pitch, yaw)

    -- Get our view offset and add it to our origin so that we can trace from our eye position
    local view_offset = entity_get_prop(local_player, "m_vecViewOffset[2]")
    local lz = lz + view_offset

    if nearest_player ~= nil and nearest_player_fov <= maximum_fov then
        -- Toggle automatic penetration based on if the enemy is visble 
        ui_set(auto_penetration_ref, is_player_visible(local_player, lx, ly, lz, nearest_player))
    else
        -- There are no players within our aimbots fov, so there is no need to auto wall
        ui_set(auto_penetration_ref, false)
    end

    ::end_command::
end

local function on_script_state_change()
    local script_state = ui_get(legit_pen_ref)

    -- If the script is not enabled there is no point in invoking the event callback so we'll dynamically set / unset it based on the script state
    local handle_registration = script_state and client.set_event_callback or client.unset_event_callback
    handle_registration("run_command", on_run_command)
end

--------------------------------------------------------------------------------
-- Initilization code
--------------------------------------------------------------------------------
on_script_state_change()
ui_set_callback(legit_pen_ref, on_script_state_change)