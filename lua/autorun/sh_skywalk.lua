print("Skywalk...")

local speed = 300

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    if key == IN_JUMP and ply:OnGround() == false then
        if true then -- Direction Jump
            local angle = ply:EyeAngles()
            local direction = angle:Forward() * speed
            local plyvector = ply:GetVelocity()

            print("Angle X, Y: " .. angle.x .. ", " .. angle.y)
            print("plyvector X, Y, Z: " .. plyvector.x .. ", " .. plyvector.y .. ", " .. plyvector.z)

            local x = direction.x - plyvector.x
            local y = direction.y - plyvector.y
            local z = direction.z - plyvector.z

            if angle.x > -20 then -- Neutral Jump
                z = z + 300
            end
            if angle.x < -80 then -- Fast Up
                z = z + 600
            end
            if angle.x > 80 then -- Fast Down
                z = plyvector.z - 300
            end

            ply:SetVelocity(Vector(x, y, z))
            print("Direction Jump")

        else -- Air Jump
            local fall = ply:GetVelocity()
            print("Air Jump")
            if fall.z < 0 then
                ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + speed)))
            else
                ply:SetVelocity(Vector(0, 0, speed))
            end
        end
    end
end)