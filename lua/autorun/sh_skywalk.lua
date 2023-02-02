print("Skywalk...")

local skywalk_base_speed = 600
local skywalk_max_speed = 3000
local allow_skywalk = true
local allow_sound = true 
local allow_particle = true
local soundFile = "skywalk.wav"

function setVelocityForNormalAirJump(ply, ply_Velocity, skywalk_speed, angle)
    local player_speed = math.sqrt(ply_Velocity.x^2 + ply_Velocity.y^2)
    local direction
    local speed = skywalk_speed + player_speed

    -- Limit Speed
    if speed > skywalk_speed then
        speed = skywalk_speed
    end

    if ply:KeyDown(IN_BACK) then
        direction = angle:Forward() * speed
        direction = -direction
    elseif ply:KeyDown(IN_MOVELEFT) then
        direction = angle:Right() * speed
        direction = -direction
    elseif ply:KeyDown(IN_MOVERIGHT) then
        direction = angle:Right() * speed
    else return end

    local x = direction.x - ply_Velocity.x
    local y = direction.y - ply_Velocity.y
    local z = ply_Velocity.z - (ply_Velocity.z * 2) + 300

    ply:SetVelocity(Vector(x, y, z))
end

-- Skywalk
hook.Add("KeyPress", "MidAirJump", function(ply, key)
    -- Skywalk
    if allow_skywalk then
        if key == IN_JUMP and ply:OnGround() == false then

            local skywalk_speed = skywalk_base_speed -- Get Base Speed
            local angle = ply:EyeAngles() -- Get Player Angle
            local ply_Velocity = ply:GetVelocity() -- Get Player Velocity

            --[[ Get Extra Speed
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
            ]]

            -- Direction Jump / Forward
            if ply:KeyDown(IN_SPEED) or ply:KeyDown(IN_FORWARD) then
                local direction
                if ply:KeyDown(IN_SPEED) then -- Speed Up
                    local player_speed = math.sqrt(ply_Velocity.x^2 + ply_Velocity.y^2) -- Get Player Speed
                    local skywalk_speed_adjust = skywalk_speed + player_speed

                    -- Limit Speed
                    if skywalk_speed_adjust > skywalk_max_speed then
                        skywalk_speed_adjust = skywalk_max_speed
                    end

                    direction = angle:Forward() * skywalk_speed_adjust
                else -- Normal Speed
                    direction = angle:Forward() * skywalk_speed
                end

                local x = direction.x - ply_Velocity.x
                local y = direction.y - ply_Velocity.y
                local z = direction.z - ply_Velocity.z + 300

                ply:SetVelocity(Vector(x, y, z))
                print("Direction Jump")
                
            elseif ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then -- Mid Air Movement
                setVelocityForNormalAirJump(ply, ply_Velocity, skywalk_speed, angle)

            else -- Mid Air Jump
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
                for i = 1, 25 do
                    local particle = emitter:Add("particle/smokesprites_0001", ply:GetPos())
                    if particle then
                        particle:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 50)))
                        particle:SetDieTime(1)
                        particle:SetStartAlpha(math.Rand(150, 200))
                        particle:SetEndAlpha(0)
                        particle:SetStartSize(math.Rand(7, 10))
                        particle:SetEndSize(math.Rand(3, 5))
                        particle:SetRoll(math.Rand(0, 360))
                        particle:SetRollDelta(math.Rand(-0.2, 0.2))
                        particle:SetColor(255, 255, 255)
                    end
                end
                emitter:Finish()
            end

            -- Sound
            if allow_sound then
                sound.Play(soundFile, ply:GetPos(), 75, 100, 1)
            end
        end
    end
end)

-- Settings Tab
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