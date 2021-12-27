--[[
	
	module by cyn_8
	
	github / documentation: https://github.com/cyn-8/soundphys
	
]]



--[[ settings ]]

local settings = {
	options = {
		-- main
		refresh_rate = 30,
		
		-- autodetection
		ignore_player_sounds = false,
		
		-- obstruction
		reverse_raycast = false,
		ignore_players = true,
		ignore_materials = true,
		min_size = 1,
		max_transparency = 0,
	},
	
	enabled = {
		true, -- autodetection
		true, -- obstruction
		true, -- water
		true, -- reverb
		true -- distance falloff
	},
		
	values = {
		lerp = {0.25, 0.1}, -- eq, reverb
		
		default = {
			eq = {0, 0, 0}, -- high, mid, low
			reverb = {0, 0, 0, 0, -80} -- decay, density, diffusion, dry gain, wet gain
		},
		
		obstruction = {12, 6, 3}, -- high, mid, low
		material = {
			--[[
				["material name"] = {0, 0, 0}, -- high, mid, low
				...
			]]
		},
		
		water = {21, 9, 0}, -- high, mid, low
		
		falloff_scale = {80, 20, 5} -- high, mid, low
	}
}



--[[ internal stuff ]]

local sound_tables = {}

local water_areas = {}

local reverb_areas = {}

local autodetection_ignore = {}
local obstruction_ignore = {}

local connection_descendantadded
local connection_descendantremoving
local connection_playeradded
local connection_set_external
local connection_pyseph_wait

local running = false

local function setup_sound_table(instance, base_eq)
	if instance:isA("Sound") then
		if instance.Parent:IsA("BasePart") or instance.Parent:IsA("Attachment") then
			local function create_table()
				local sound_table = sound_tables[instance]
				if not sound_table then
					sound_table = {}
					
					local default_values = settings.values.default
					local default_eq = default_values.eq
					local default_reverb = default_values.reverb
					
					local enabled = settings.enabled
					if enabled[2] or enabled[3] or enabled[5] then
						local eq = instance:FindFirstChildWhichIsA("EqualizerSoundEffect")
						if not eq then
							eq = Instance.new("EqualizerSoundEffect")
							eq.HighGain = base_eq and base_eq[1] or default_eq[1]
							eq.MidGain = base_eq and base_eq[2] or default_eq[2]
							eq.LowGain = base_eq and base_eq[3] or default_eq[3]
							eq.Name = "soundphys_eq"
							eq.Parent = instance
						end
						
						sound_table[1] = eq.HighGain
						sound_table[2] = eq.MidGain
						sound_table[3] = eq.LowGain
						sound_table[4] = 0
						sound_table[5] = 0
						sound_table[6] = 0
					end
					
					if settings.enabled[4] then
						local reverb = instance:FindFirstChildWhichIsA("ReverbSoundEffect")
						if not reverb then
							reverb = Instance.new("ReverbSoundEffect")
							reverb.DecayTime = default_reverb[1]
							reverb.Density = default_reverb[2]
							reverb.Diffusion = default_reverb[3]
							reverb.DryLevel = default_reverb[4]
							reverb.WetLevel = default_reverb[5]
							reverb.Name = "soundphys_reverb"
							reverb.Parent = instance
						end
						
						sound_table[7] = reverb.DecayTime
						sound_table[8] = reverb.Density
						sound_table[9] = reverb.Diffusion
						sound_table[10] = reverb.DryLevel
						sound_table[11] = reverb.WetLevel
					end
					
					sound_tables[instance] = sound_table
				end
			end
			
			if settings.options.ignore_player_sounds then
				local possible_character = instance:FindFirstAncestorWhichIsA("Model")
				if possible_character then
					if not possible_character:FindFirstChild("HumanoidRootPart") then
						create_table()
					end
				else
					create_table()
				end
			else
				create_table()
			end
		end
	end
end
local function remove_sound_table(sound)
	local sound_table = sound_tables[sound]
	if sound_table then
		local eq = sound:FindFirstChildWhichIsA("EqualizerSoundEffect")
		if eq then
			if eq.Name == "soundphys_eq" then
				eq:Destroy()
			else
				eq.HighGain = sound_table[1]
				eq.MidGain = sound_table[2]
				eq.LowGain = sound_table[3]
			end
		end
		
		if settings.enabled[4] then
			local reverb = sound:FindFirstChildWhichIsA("ReverbSoundEffect")
			if reverb then
				if reverb.Name == "soundphys_reverb" then
					reverb:Destroy()
				end
			end
		end
		
		sound_tables[sound] = nil
	end
end

local soundphys = {
	autodetection = function(action, sounds)
		if settings.enabled[1] then
			local actions = {
				["ignore_add"] = function()
					for _, sound in pairs(sounds) do
						if sound:isA("Sound") then
							autodetection_ignore[sound] = true
						end
					end
				end,
				
				["ignore_remove"] = function()
					for _, sound in pairs(sounds) do
						autodetection_ignore[sound] = nil
					end
				end
			}
			
			if actions[action] then
				actions[action]()
			end
		end
	end,
	
	obstruction = function(action, baseparts)
		if settings.enabled[2] then
			local actions = {
				["ignore_add"] = function()
					for _, basepart in pairs(baseparts) do
						if not obstruction_ignore[basepart] then
							obstruction_ignore[basepart] = true
						end
					end
				end,
				
				["ignore_remove"] = function()
					for _, basepart in pairs(baseparts) do
						obstruction_ignore[basepart] = nil
					end
				end
			}
			
			if actions[action] then
				actions[action]()
			end
		end
	end,
	
	sound_tables = function(action, sounds, data)
		if not settings.enabled[1] then
			local actions = {
				["add"] = function()
					for _, sound in pairs(sounds) do
						setup_sound_table(sound, data)
					end
				end,
				
				["remove"] = function()
					for _, sound in pairs(sounds) do
						if sound:IsA("Sound") then
							remove_sound_table(sound)
						end
					end
				end
			}
			
			if actions[action] then
				actions[action]()
			end
		end
		
	end,
	
	water_areas = function(action, baseparts, data)
		if settings.enabled[3] then
			local actions = {
				["add"] = function()
					for _, basepart in pairs(baseparts) do
						if not water_areas[basepart] then
							water_areas[basepart] = data
						end
					end
				end,
				
				["remove"] = function()
					for _, basepart in pairs(baseparts) do
						water_areas[basepart] = nil
					end
				end,
				
				["ignore_add"] = function()
					for _, basepart in pairs(baseparts) do
						if water_areas[basepart] then
							for _, sound in pairs(data) do
								water_areas[basepart][sound] = true 
							end
						end
					end
				end,
				
				["ignore_remove"] = function()
					for _, basepart in pairs(baseparts) do
						if water_areas[basepart] then
							for _, sound in pairs(data) do
								water_areas[basepart][sound] = nil 
							end
						end
					end
				end
			}
			
			if actions[action] then
				actions[action]()
			end
		end
	end,
	
	reverb_areas = function(action, baseparts, data)
		if settings.enabled[4] then
			local actions = {
				["add"] = function()
					for _, basepart in pairs(baseparts) do
						if not reverb_areas[basepart] then
							reverb_areas[basepart] = {data[1], {}}
							for _, sound in pairs(data[2]) do
								reverb_areas[basepart][2][sound] = true
							end
						end
					end
				end,
				
				["remove"] = function()
					for _, basepart in pairs(baseparts) do
						reverb_areas[basepart] = nil
					end
				end,
				
				["ignore_add"] = function()
					for _, basepart in pairs(baseparts) do
						if reverb_areas[basepart] then
							for _, sound in pairs(data) do
								reverb_areas[basepart][2][sound] = true 
							end
						end
					end
				end,
				
				["ignore_remove"] = function()
					for _, basepart in pairs(baseparts) do
						if reverb_areas[basepart] then
							for _, sound in pairs(data) do
								reverb_areas[basepart][2][sound] = nil 
							end
						end
					end
				end
			}
			
			if actions[action] then
				actions[action]()
			end
		end
	end,
	
	run = function()
		if not running then
			running = true
			
			local options = settings.options
			local enabled = settings.enabled
			local obstruction_enabled = enabled[2]
			local water_enabled = enabled[3]
			local reverb_enabled = enabled[4]
			local falloff_enabled = enabled[5]
			local values = settings.values
			
			if enabled[1] then
				sound_tables = {}
				
				for _, instance in pairs(workspace:GetDescendants()) do
					if not autodetection_ignore[instance] then
						setup_sound_table(instance)
					end
				end
				connection_descendantadded = workspace.DescendantAdded:Connect(function(instance)
					if not autodetection_ignore[instance] then
						setup_sound_table(instance)
					end
				end)
			end
			
			connection_descendantremoving = workspace.DescendantRemoving:Connect(function(instance)
				if instance:IsA("Sound") then
					autodetection_ignore[instance] = nil
					remove_sound_table(instance)
					if water_enabled then
						for _, area in pairs(water_areas) do
							area[instance] = nil
						end
					end
					if reverb_enabled then
						for _, area in pairs(reverb_areas) do
							area[2][instance] = nil
						end
					end
				elseif instance.Parent:IsA("BasePart") then
					obstruction_ignore[instance] = nil
					water_areas[instance] = nil
					reverb_areas[instance] = nil
				end
			end)
			
			if obstruction_enabled then
				if settings.options.ignore_players then
					local players = game:GetService("Players")
					
					local function ignore_player(player)
						if player.Character then
							obstruction_ignore[player.Character] = true
						end
						
						local connection_characteradded
						connection_characteradded = player.CharacterAdded:Connect(function(removing_character)
							obstruction_ignore[removing_character] = true
						end)
						local connection_characterremoving
						connection_characterremoving = player.CharacterRemoving:Connect(function(removing_character)
							obstruction_ignore[removing_character] = nil
						end)
						
						local connection_playerremoving
						connection_playerremoving = players.PlayerRemoving:Connect(function(removing_player)
							if removing_player == player then
								if player.Character then
									obstruction_ignore[player.Character] = nil
								end
								
								connection_characteradded:Disconnect()
								connection_characterremoving:Disconnect()
								connection_playerremoving:Disconnect()
							end
						end)
					end
					
					for _, player in pairs(players:GetChildren()) do
						ignore_player(player)
					end
					
					connection_playeradded = players.PlayerAdded:Connect(function(player)
						ignore_player(player)
					end)
				end
			end
			
			local camera = workspace.CurrentCamera
			local camera_is_underwater
			local function within_area(area, position)
				local temp_cframe = area.CFrame:PointToObjectSpace(position)
				local area_size = area.Size
				return (math.abs(temp_cframe.X) <= (area_size.X / 2)) and (math.abs(temp_cframe.Y) <= (area_size.Y / 2)) and (math.abs(temp_cframe.Z) <= (area_size.Z / 2))
			end
			local function set_internal()
				local camera_cframe = camera.CFrame
				local camera_position = camera_cframe.Position
				
				for sound, sound_table in pairs(sound_tables) do
					if sound.IsPlaying then
						local origin = sound.Parent
						local origin_position = origin.Position
						if not ((origin_position - camera_position).Magnitude > sound.RollOffMaxDistance) then
							local eq = sound:FindFirstChildWhichIsA("EqualizerSoundEffect")
							if eq then
								if obstruction_enabled then
									local difference
									if options.reverse_raycast then
										difference = (camera_position - origin_position)
									else
										difference = (origin_position - camera_position)
									end
									local direction_vector = (difference.Unit * difference.Magnitude)
									
									local ray_ignore = {}
									for instance, _ in pairs(obstruction_ignore) do
										table.insert(ray_ignore, instance)
									end
									if not obstruction_ignore[origin] then
										table.insert(ray_ignore, origin)
									end
									
									local ray_parameters = RaycastParams.new()
									ray_parameters.FilterDescendantsInstances = ray_ignore
									ray_parameters.FilterType = Enum.RaycastFilterType.Blacklist
									ray_parameters.IgnoreWater = true
									
									local function nohit()
										sound_table[4] = 0
										sound_table[5] = 0
										sound_table[6] = 0
									end
									local raycast = workspace:Raycast(camera_position, direction_vector, ray_parameters)
									if raycast then
										local result = raycast.Instance
										local result_size = result.Size
										local min_size = options.min_size
										if (((result_size.X >= min_size) and (result_size.Y >= min_size) and (result_size.Z >= min_size)) and (result.Transparency <= options.max_transparency)) then
											local obstruction_values = values.obstruction
											sound_table[4] = sound_table[1] + obstruction_values[1]
											sound_table[5] = sound_table[2] + obstruction_values[2]
											sound_table[6] = sound_table[3] + obstruction_values[3]
											
											if not options.ignore_materials then
												local material_values = values.material[raycast.Material.Name]
												sound_table[4] += material_values[1]
												sound_table[5] += material_values[2]
												sound_table[6] += material_values[3]
											end
										else
											nohit()
										end
									else
										nohit()
									end
								end
								
								if water_enabled then
									local underwater_values = values.water
									local function add_underwater()
										sound_table[4] += underwater_values[1]
										sound_table[5] += underwater_values[2]
										sound_table[6] += underwater_values[3]
									end
									
									for area, _ in pairs(water_areas) do
										if within_area(area, sound.Parent.Position) then
											if not camera_is_underwater then
												add_underwater()
											end
											break
										end
									end
									if camera_is_underwater then
										add_underwater()
									end
								end
							end
							
							if reverb_enabled then
								local reverb = sound:FindFirstChildWhichIsA("ReverbSoundEffect")
								if reverb then
									local in_area = false
									for basepart, reverb_area in pairs(reverb_areas) do
										if not reverb_area[2][sound] then
											if within_area(basepart, sound.Parent.Position) then
												local reverb_values = reverb_area[1]
												sound_tables[sound][7] = reverb_values[1]
												sound_tables[sound][8] = reverb_values[2]
												sound_tables[sound][9] = reverb_values[3]
												sound_tables[sound][10] = reverb_values[4]
												sound_tables[sound][11] = reverb_values[5]
												
												in_area = true
												break
											end
										end
									end
									if not in_area then
										local default_reverb = settings.values.default.reverb
										sound_tables[sound][7] = default_reverb[1]
										sound_tables[sound][8] = default_reverb[2]
										sound_tables[sound][9] = default_reverb[3]
										sound_tables[sound][10] = default_reverb[4]
										sound_tables[sound][11] = default_reverb[5]
									end
								end
							end
						end
					end
				end
				
				if water_enabled then
					for basepart, _ in pairs(water_areas) do
						if within_area(basepart, camera_position) then
							camera_is_underwater = true
							break
						end
						camera_is_underwater = false
					end
				end
			end
			
			local function lerp(start, goal, alpha)
				return (start + ((goal - start) * alpha))
			end
			local function set_external()
				for sound, sound_table in pairs(sound_tables) do
					if sound.IsPlaying then
						if not ((sound.Parent.Position - camera.CFrame.Position).Magnitude > sound.RollOffMaxDistance) then
							local eq = sound:FindFirstChildWhichIsA("EqualizerSoundEffect")
							if eq then
								local distance_factor = (sound.Parent.Position - camera.CFrame.Position).Magnitude / sound.RollOffMaxDistance
								local falloff_scale = values.falloff_scale
								local alpha = values.lerp[1]
								eq.HighGain = lerp(eq.HighGain, sound_table[1] - (sound_table[4] + (falloff_enabled and (distance_factor * falloff_scale[1]) or 0)), alpha)
								eq.MidGain = lerp(eq.MidGain, sound_table[2] - (sound_table[5] + (falloff_enabled and (distance_factor * falloff_scale[2]) or 0)), alpha)
								eq.LowGain = lerp(eq.LowGain, sound_table[3] - (sound_table[6] + (falloff_enabled and (distance_factor * falloff_scale[3]) or 0)), alpha)
							end
							
							if reverb_enabled then
								local reverb = sound:FindFirstChildWhichIsA("ReverbSoundEffect")
								if reverb then
									local alpha = values.lerp[2]
									reverb.DecayTime = lerp(reverb.DecayTime, sound_table[7], alpha)
									reverb.Density = lerp(reverb.Density, sound_table[8], alpha)
									reverb.Diffusion = lerp(reverb.Diffusion, sound_table[9], alpha)
									reverb.DryLevel = lerp(reverb.DryLevel, sound_table[10], alpha)
									reverb.WetLevel = lerp(reverb.WetLevel, sound_table[11], alpha)
								end
							end
						end
					end
				end
			end
			
			local runservice = game:GetService("RunService")
			
			connection_set_external = runservice.Heartbeat:Connect(function()
				set_external()
			end)
			
			-- custom wait by pysephdev
			local yields = {}
			connection_pyseph_wait = runservice.Stepped:Connect(function()
				for idx, data in next, yields do
					local spent = os.clock() - data[1]
					if spent >= data[2] then
						yields[idx] = nil
						coroutine.resume(data[3], spent, os.clock())
					end
				end
			end)
			local function pyseph_wait(duration)
				duration = (type(duration) ~= "number" or duration < 0) and 0 or duration
				table.insert(yields, {os.clock(), duration, coroutine.running()})
				return coroutine.yield()
			end
			
			local interval = 1 / options.refresh_rate
			while running do
				set_internal()
				pyseph_wait(interval)
			end
		end
	end,
	
	stop = function()
		if running then
			running = false
			
			local enabled = settings.enabled
			if enabled[1] then
				connection_descendantadded:Disconnect()
			end
			connection_descendantremoving:Disconnect()
			if enabled[2] then
				if settings.options.ignore_players then
					connection_playeradded:Disconnect()
				end
			end
			connection_set_external:Disconnect()
			connection_pyseph_wait:Disconnect()
		end
	end
}

return soundphys
