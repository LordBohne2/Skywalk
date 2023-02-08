include("autorun/sh_skywalk.lua")

-- Add the command to the server-side list of console commands
concommand.Add("skywalk_set_convar", function(ply, cmd, args)
    if ply:IsValid() then
        -- Ensure that only players with the appropriate permission can use the command
        if not ply:IsAdmin() then
            return
        end
    
        -- Get the new values for each ConVar
        local newSpeed = tonumber(args[1])
        local newJumpHeight = tonumber(args[2])
        local newAllowSkywalk = args[3]
        local newAllowSound = args[4]
        local newAllowParticle = args[5]

        -- Set the values for each ConVar
        GetConVar(ConVarSkywalkBaseSpeed):SetFloat(newSpeed)
        GetConVar(ConVarSkywalkBaseJumpHeight):SetFloat(newJumpHeight)
        GetConVar(ConVarAllowSkywalk):SetBool(newAllowSkywalk)
        GetConVar(ConVarAllowSkywalkSound):SetBool(newAllowSound)
        GetConVar(ConVarAllowSkywalkParticle):SetBool(newAllowParticle)
    end
end)