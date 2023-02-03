print("Skywalk...")

local skywalk_base_speed = 600
local skywalk_max_speed = 3000
local skywalk_base_jump_height = 300
local allow_skywalk = true
local allow_sound = true 
local allow_particle = false
local soundFile = "skywalk.wav"

-- Get Player Speed
local function getPlayerSpeed(ply, base_speed, limit)
    local player_speed = math.sqrt(ply:GetVelocity().x^2 + ply:GetVelocity().y^2)
    local skywalk_speed_adjust = base_speed + player_speed

    -- Limit Speed
    if skywalk_speed_adjust > limit then
        skywalk_speed_adjust = limit
    end

    return skywalk_speed_adjust
end

-- Mid Air Movement
function setVelocityForNormalAirJump(ply, skywalk_speed, angle)
    local skywalk_speed_adjust = getPlayerSpeed(ply, skywalk_speed, 300)
    local direction

    if ply:KeyDown(IN_FORWARD) && ply:KeyDown(IN_MOVERIGHT) then -- W D
        direction = ((angle:Forward() + angle:Right()) / 2) * skywalk_speed_adjust
    elseif ply:KeyDown(IN_MOVERIGHT) && ply:KeyDown(IN_BACK) then -- D S
        direction = ((-angle:Forward() + angle:Right()) / 2) * skywalk_speed_adjust
    elseif ply:KeyDown(IN_BACK) && ply:KeyDown(IN_MOVELEFT) then -- S A
        direction = ((-angle:Forward() + -angle:Right()) / 2) * skywalk_speed_adjust
    elseif ply:KeyDown(IN_MOVELEFT) && ply:KeyDown(IN_FORWARD) then -- A W
        direction = ((angle:Forward() + -angle:Right()) / 2) * skywalk_speed_adjust
    elseif ply:KeyDown(IN_MOVELEFT) then -- A
        direction = -angle:Right() * skywalk_speed_adjust
    elseif ply:KeyDown(IN_MOVERIGHT) then -- D
        direction = angle:Right() * skywalk_speed_adjust
    elseif ply:KeyDown(IN_BACK) then -- S
        direction = -angle:Forward() * skywalk_speed_adjust
    else return end

    local x = direction.x - ply:GetVelocity().x
    local y = direction.y - ply:GetVelocity().y
    local z = ply:GetVelocity().z - (ply:GetVelocity().z * 2) + skywalk_base_jump_height

    ply:SetVelocity(Vector(x, y, z))
end

-- Sound
local function skywalkSound(ply)
    if allow_sound then
        sound.Play(soundFile, ply:GetPos(), 75, 100, 1)
    end
end

-- Particle
local function skywalkParticle(ply)
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
end

-- Skywalk
hook.Add("KeyPress", "MidAirJump", function(ply, key)
    -- Skywalk
    if allow_skywalk then
        if key == IN_JUMP and ply:OnGround() == false then

            local skywalk_speed = skywalk_base_speed -- Get Base Speed
            local angle = ply:EyeAngles() -- Get Player Angle

            if ply:KeyDown(IN_DUCK) then -- Mid Air Jump
                ply:SetVelocity(Vector(ply:GetVelocity().x - (ply:GetVelocity().x * 2), ply:GetVelocity().y - (ply:GetVelocity().y * 2), ply:GetVelocity().z - (ply:GetVelocity().z * 2) + skywalk_base_jump_height))

            elseif ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then -- Mid Air Movement
                setVelocityForNormalAirJump(ply, skywalk_speed, angle)

            elseif ply:KeyDown(IN_SPEED) or ply:KeyDown(IN_FORWARD) then -- Direction Jump / Forward
                local direction

                if ply:KeyDown(IN_SPEED) then -- Speed Up
                    direction = angle:Forward() * getPlayerSpeed(ply, skywalk_speed, skywalk_max_speed)

                else -- Normal Speed
                    direction = angle:Forward() * skywalk_speed
                end

                local x = direction.x - ply:GetVelocity().x
                local y = direction.y - ply:GetVelocity().y
                local z = direction.z - ply:GetVelocity().z

                if angle.x < -80 then -- Fast Up
                    ply:SetVelocity(Vector(x, y, z + 1000))
                elseif angle.x > 80 then -- Fast Down
                    ply:SetVelocity(Vector(x, y, z - 500))
                else -- Normal
                    ply:SetVelocity(Vector(x, y, z + skywalk_base_jump_height))
                end

            else -- Mid Air Jump
                local fall = ply:GetVelocity()
                if fall.z < 0 then
                    ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + skywalk_base_jump_height)))
                else
                    ply:SetVelocity(Vector(0, 0, skywalk_base_jump_height))
                end
            end
            
            skywalkParticle(ply)
            skywalkSound(ply)
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
        panel:CheckBox("Enable Particle", "sv_allow_skywalk_particle")
        panel:Button("Reset", "sv_skywalk_reset", nil)
    end)
end)