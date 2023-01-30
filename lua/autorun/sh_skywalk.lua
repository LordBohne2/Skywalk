print("Skywalk...")

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    if key == IN_JUMP and ply:OnGround() == false then
        if true then -- Direction Jump
            local angle = ply:EyeAngles()
            local direction = angle:Forward() * 250
            print(angle)
            if angle.x < -10 then -- Go Up
                ply:SetVelocity(ply:GetVelocity() + Vector(direction.x, direction.y, direction.z + 300))
                print("Down")
            else -- Go Down
                ply:SetVelocity(ply:GetVelocity() + Vector(direction.x, direction.y, direction.z))
                print("Up")
            end
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