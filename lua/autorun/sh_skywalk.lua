print("Skywalk...")

hook.Add("KeyPress", "MidAirJump", function(ply, key)
    if key == IN_JUMP and ply:OnGround() == false then
        if key == IN_SPEED then
            local angle = ply:EyeAngles()
            local direction = angle:Forward() * 250
            ply:SetVelocity(ply:GetVelocity() + Vector(direction.x, direction.y, 250))
        else
            ply:SetVelocity(Vector(0, 0, 300))
        end
    end
end)