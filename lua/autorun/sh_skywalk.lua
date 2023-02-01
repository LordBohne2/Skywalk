print("Skywalk...")

local skywalk_base_speed = 600
local skywalk_max_speed = 1000
local skywalk_sprint = 300
local allow_skywalk = true
local allow_sound = true 
local allow_particle = false
local skywalk_sound_path = "addons/skywalk/sound/skywalk.wav"
local ParticleEmitter = ParticleEmitter

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    -- Skywalk
    if allow_skywalk then
        if key == IN_JUMP and ply:OnGround() == false then

            local skywalk_speed = skywalk_base_speed
            local angle = ply:EyeAngles()
            local ply_Velocity = ply:GetVelocity() -- Get Player Velocity
            print("Angle X Y: " .. angle.x .. angle.y)
            print("Player Velocity X Y Z: " .. ply_Velocity.x .. ply_Velocity.y .. ply_Velocity.z)

            -- Get Extra Speed
            if ply:KeyDown(IN_SPEED) then
                skywalk_speed = skywalk_speed + skywalk_sprint

                if angle.x < -80 then -- Fast Up
                    ply:SetVelocity(Vector(0, 0, 1000))
                    return
                end
                if angle.x > 80 then -- Fast Down
                    ply:SetVelocity(Vector(0, 0, -500))
                    return
                end
            end

            -- Direction Jump / Forward
            if ply:KeyDown(IN_FORWARD) then
                local player_speed = math.sqrt(ply_Velocity.x^2 + ply_Velocity.y^2)
                print("Player Speed: " .. player_speed)

                local speed = skywalk_base_speed + player_speed

                -- Limit Speed
                if speed > skywalk_max_speed then
                    speed = skywalk_max_speed
                end

                local direction = angle:Forward() * speed

                local x = direction.x - ply_Velocity.x
                local y = direction.y - ply_Velocity.y
                local z = direction.z - ply_Velocity.z + 300

                ply:SetVelocity(Vector(x, y, z))
                print("Direction Jump")
                
            else -- Air Jump
                local fall = ply:GetVelocity()
                if fall.z < 0 then
                    ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + 300)))
                else
                    ply:SetVelocity(Vector(0, 0, 300))
                end
                print("Air Jump")
            end
            
            -- Particle
            if allow_particle then
                local emitter = ParticleEmitter(ply:GetPos())
                for i = 1, 100 do
                    local particle = emitter:Add("particle/smokesprites_0001", ply:GetPos())
                    particle:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(20, 100)))
                    particle:SetDieTime(math.Rand(1, 2))
                    particle:SetStartAlpha(math.Rand(150, 200))
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.Rand(3, 5))
                    particle:SetEndSize(math.Rand(10, 15))
                    particle:SetRoll(math.Rand(0, 360))
                    particle:SetRollDelta(math.Rand(-0.2, 0.2))
                    particle:SetColor(255, 255, 255)
                end
            end

            -- Sound
            if allow_sound then
                sound.Play(skywalk_sound_path, ply:GetPos(), 75, 100, 1)
            end
        end
    end
end)

hook.Add("AddToolMenuCategories", "CustomCategory", function()
    spawnmenu.AddToolCategory("Utilities", "Skywalk" ,"#Skywalk")
end)

hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "Skywalk", "Skywalk_Menu", "#Skywalk_Menu", "", "", function(panel)
        panel:ClearControls()
        panel:CheckBox("Enable Skywalk", "sv_allow_skywalk")
        panel:NumSlider("Skywalk Speed", "sv_skywalk_base_speed", 100, skywalk_max_speed, nil)
        panel:CheckBox("Enable Sound", "sv_allow_skywalk_sound")
    end)
end)