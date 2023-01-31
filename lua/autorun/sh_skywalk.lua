print("Skywalk...")

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    if key == IN_JUMP and ply:OnGround() == false then
        if true then -- Direction Jump
            local angle = ply:EyeAngles()
            local direction = angle:Forward() * 250

            print("Angle X, Y: " .. angle.x .. ", " .. angle.y)
            local plyvector = ply:GetVelocity()
            print("plyvector X, Y, Z: " .. plyvector.x .. ", " .. plyvector.y .. ", " .. plyvector.z)

            ply:SetVelocity(Vector(direction.x - plyvector.x,  direction.y - plyvector.y, direction.z - plyvector.z))
            
            print("Direction Jump")

        else -- Air Jump
            local fall = ply:GetVelocity()
            print("Air Jump")
            if fall.z < 0 then
                ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + 300)))
            else
                ply:SetVelocity(Vector(0, 0, 300))
            end
        end
    end
end)