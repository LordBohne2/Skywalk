print("Skywalk...")

local skywalk_speed = 600
local skywalk_max_speed = 1000
local allow_skywalk = true;

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    if allow_skywalk then
        if key == IN_JUMP and ply:OnGround() == false then
            if true then -- Direction Jump
                local angle = ply:EyeAngles()
                local ply_Velocity = ply:GetVelocity() -- Get Player Velocity 

                print("Angle X Y: " .. angle.x .. angle.y)
                print("Player Velocity X Y Z: " .. ply_Velocity.x .. ply_Velocity.y .. ply_Velocity.z)

                local player_speed = math.sqrt(ply_Velocity.x^2 + ply_Velocity.y^2)

                print("Player Speed: " .. player_speed)

                local speed = skywalk_speed + player_speed

                -- Limit Speed
                if speed > skywalk_max_speed then
                    speed = skywalk_max_speed
                end

                print("Speed: " .. speed)

                local direction = angle:Forward() * speed

                local x = direction.x - ply_Velocity.x
                local y = direction.y - ply_Velocity.y
                local z = direction.z - ply_Velocity.z

                if angle.x > -20 then -- Neutral Jump
                    z = z + 300
                end
                if angle.x < -80 then -- Fast Up
                    z = z + 600
                end
                if angle.x > 80 then -- Fast Down
                    z = ply_Velocity.z - 300
                end

                ply:SetVelocity(Vector(x, y, z))
                print("Direction Jump")

            else -- Air Jump
                local fall = ply:GetVelocity()
                print("Air Jump")
                if fall.z < 0 then
                    ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + skywalk_speed)))
                else
                    ply:SetVelocity(Vector(0, 0, skywalk_speed))
                end
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
        panel:NumSlider("Skywalk Speed", "sv_skywalk_speed", 100, skywalk_max_speed, nil)
        panel:CheckBox("Enable Sound", "sv_allow_skywalk_sound")
    end)
end)