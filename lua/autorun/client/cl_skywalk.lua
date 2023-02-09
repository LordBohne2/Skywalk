include("autorun/sh_skywalk.lua")

local function setConVar(newData)
    -- Send the new values to the server   
    RunConsoleCommand("skywalk_set_convar", newData.skywalk_base_speed, newData.skywalk_base_jump_height, tostring(newData.allow_skywalk), tostring(newData.allow_sound), tostring(newData.allow_particle))
end

local function ReadSkywalkData()
    local readData
    if not file.Exists(settingsFileName, "DATA") then
        readData = skywalkBaseData
        file.Write(settingsFileName, util.TableToJSON(readData))
    else
        readData = util.JSONToTable(file.Read(settingsFileName))
    end

    setConVar(readData)
end

local function SaveSkywalkData()
    local saveData = {
        skywalk_base_speed = GetConVar(ConVarSkywalkBaseSpeed):GetFloat(),
        skywalk_base_jump_height = GetConVar(ConVarSkywalkBaseJumpHeight):GetFloat(),
        allow_skywalk = GetConVar(ConVarAllowSkywalk):GetBool(),
        allow_sound = GetConVar(ConVarAllowSkywalkSound):GetBool(),
        allow_particle = GetConVar(ConVarAllowSkywalkParticle):GetBool()
    }

    file.Write(settingsFileName, util.TableToJSON(saveData))
end

local function ResetSkywalkData()
    setConVar(skywalkBaseData)
end

-- GUI
hook.Add("AddToolMenuCategories", "SkywalkCategory", function()
    spawnmenu.AddToolCategory("Options", "Skywalk" ,"#Skywalk")
end)

hook.Add("PopulateToolMenu", "SkywalkMenuSettings", function()
    spawnmenu.AddToolMenuOption("Options", "Skywalk", "Skywalk_Settings", "#Skywalk Settings", "", "", function(panel)
        panel:ClearControls()
        panel:CheckBox("Enable", ConVarAllowSkywalk)
        panel:NumSlider("Base Speed", ConVarSkywalkBaseSpeed, 100, skywalk_max_speed, nil)
        panel:NumSlider("Base Jump Height", ConVarSkywalkBaseJumpHeight, 100, skywalk_max_jump_height, nil)
        panel:CheckBox("Enable Sound", ConVarAllowSkywalkSound)
        panel:CheckBox("Enable Particle", ConVarAllowSkywalkParticle)
        local saveButton = panel:Button("Save Settings", nil, function() SaveSkywalkData() end)
        saveButton.DoClick = function()
            SaveSkywalkData()
        end
        local loadButton = panel:Button("Load Settings", nil, function() ReadSkywalkData() end)
        loadButton.DoClick = function()
            ReadSkywalkData()
        end
        local resetButton = panel:Button("Reset Settings", nil, function() ResetSkywalkData() end)
        resetButton.DoClick = function()
            ResetSkywalkData()
        end
        panel:Help("Controlls: ")
        panel:Help("Forward: Jump in the Direction where you are watching")
        panel:Help("Left & Right: Jump to Left or Right")
        panel:Help("Back: Jump Backwards")
        panel:Help("Shift: Jump Fast")
        panel:Help("CTRL: Cancel Movement")
    end)
end)