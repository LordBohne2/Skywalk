print("Skywalk...")

local skywalk_max_speed = 3000
local skywalk_max_jump_height = 3000
local soundFile = "skywalk.wav"
local settingsFileName = "skywalk_settings.json"

local ConVarAllowSkywalk = "sv_allow_skywalk"
local ConVarAllowSkywalkSound = "sv_allow_skywalk_sound"
local ConVarAllowSkywalkParticle = "sv_allow_skywalk_particle"
local ConVarSkywalkBaseSpeed = "sv_skywalk_base_speed"
local ConVarSkywalkBaseJumpHeight = "sv_skywalk_base_jump_height"

local skywalkBaseData = {
    skywalk_base_speed = 600,
    skywalk_base_jump_height = 300,
    allow_skywalk = true,
    allow_sound = true ,
    allow_particle = true
}

local function boolToNum(bool)
    if bool == true then
        return 1
    else
        return 0
    end
end

CreateConVar(ConVarSkywalkBaseSpeed, skywalkBaseData.skywalk_base_speed, FCVAR_REPLICATED, "Set the Base Speed of Skywalk", 100, skywalk_max_speed)
CreateConVar(ConVarSkywalkBaseJumpHeight, skywalkBaseData.skywalk_base_jump_height, FCVAR_REPLICATED, "Set the Base Jump Height of Skywalk", 100, skywalk_max_jump_height)
CreateConVar(ConVarAllowSkywalk, boolToNum(skywalkBaseData.allow_skywalk), FCVAR_REPLICATED, "Enable or Disable Skywalk")
CreateConVar(ConVarAllowSkywalkSound, boolToNum(skywalkBaseData.allow_sound), FCVAR_REPLICATED, "Enable or Disable Skywalk Sound")
CreateConVar(ConVarAllowSkywalkParticle, boolToNum(skywalkBaseData.allow_particle), FCVAR_REPLICATED, "Enable or Disable Skywalk Particles")

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
    local z = ply:GetVelocity().z - (ply:GetVelocity().z * 2) + GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat()

    ply:SetVelocity(Vector(x, y, z))
end

-- Sound
local function skywalkSound(ply)
    if GetConVar(ConVarAllowSkywalkSound):GetBool() then
        sound.Play(soundFile, ply:GetPos(), 75, 100, 1)
    end
end

-- Particle
local function skywalkParticle(ply)
    if GetConVar(ConVarAllowSkywalkParticle):GetBool() && CLIENT then
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
    if GetConVar(ConVarAllowSkywalk):GetBool() then
        if key == IN_JUMP and ply:OnGround() == false then

            local skywalk_speed = GetConVar(ConVarSkywalkBaseSpeed):GetFloat() -- Get Base Speed
            local angle = ply:EyeAngles() -- Get Player Angle

            if ply:KeyDown(IN_DUCK) then -- Mid Air Jump
                ply:SetVelocity(Vector(ply:GetVelocity().x - (ply:GetVelocity().x * 2), ply:GetVelocity().y - (ply:GetVelocity().y * 2), ply:GetVelocity().z - (ply:GetVelocity().z * 2) + GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat()))

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
                    ply:SetVelocity(Vector(x, y, z + GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat()))
                end

            else -- Mid Air Jump
                local fall = ply:GetVelocity()
                if fall.z < 0 then
                    ply:SetVelocity(Vector(0, 0, (fall.z - (fall.z * 2) + GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat())))
                else
                    ply:SetVelocity(Vector(0, 0, GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat()))
                end
            end
            
            skywalkParticle(ply)
            skywalkSound(ply)
        end
    end
end)

-- ConVar
/*
local function setConVar(newData)
    --if (CLIENT) then return end
    GetConVar(ConVarSkywalkBaseSpeed):SetFloat(newData.skywalk_base_speed)
    GetConVar(ConVarSkywalkBaseJumpHeight):SetFloat(newData.skywalk_base_jump_height)
    GetConVar(ConVarAllowSkywalk):SetBool(newData.allow_skywalk)
    GetConVar(ConVarAllowSkywalkSound):SetBool(newData.allow_sound)
    GetConVar(ConVarAllowSkywalkParticle):SetBool(newData.allow_particle)
    print("ConVar Set!")
end
*/
local function SaveSkywalkData()
    local saveData = {
        skywalk_base_speed = GetConVar(ConVarSkywalkBaseSpeed):GetFloat(),
        skywalk_base_jump_height = GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat(),
        allow_skywalk = GetConVar(ConVarAllowSkywalk):GetBool(),
        allow_sound = GetConVar(ConVarAllowSkywalkSound):GetBool(),
        allow_particle = GetConVar(ConVarAllowSkywalkParticle):GetBool()
    }

    file.Write(settingsFileName, util.TableToJSON(saveData))

    print("File Saved on " .. settingsFileName .. "...")
end

local function ReadSkywalkData()
    local readData
    if not file.Exists(settingsFileName, "DATA") then
        readData = skywalkBaseData
        file.Write(settingsFileName, util.TableToJSON(readData))
    else
        readData = util.JSONToTable(file.Read(settingsFileName))
    end

    --setConVar(readData)
end

ReadSkywalkData()

local function ResetSkywalkData()
    local resetData = skywalkBaseData
    file.Write(settingsFileName, util.TableToJSON(resetData))
    --setConVar(resetData)
end

-- Settings Tab
hook.Add("AddToolMenuCategories", "SkywalkCategory", function()
    spawnmenu.AddToolCategory("Options", "Skywalk" ,"#Skywalk")
end)

-- GUI
hook.Add("PopulateToolMenu", "SkywalkMenuSettings", function()
    spawnmenu.AddToolMenuOption("Options", "Skywalk", "Skywalk_Settings", "#Skywalk Settings", "", "", function(panel)
        panel:ClearControls()
        panel:CheckBox("Enable", ConVarAllowSkywalk)
        panel:NumSlider("Base Speed", ConVarSkywalkBaseSpeed, 100, skywalk_max_speed, nil)
        panel:NumSlider("Base Jump Height", ConVarSkywalkBaseJumpHeight, 100, skywalk_max_jump_height, nil)
        panel:CheckBox("Enable Sound", ConVarAllowSkywalkSound)
        panel:CheckBox("Enable Particle", ConVarAllowSkywalkParticle)
        local resetButton = panel:Button("Reset", nil, function() ResetSkywalkData() end)
        resetButton.DoClick = function()
            ResetSkywalkData()
        end
        panel:Help("Controlls: ")
    end)
end)