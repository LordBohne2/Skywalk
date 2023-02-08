include("autorun/sh_skywalk.lua")

local function setConVar(newData)
    -- Send the new values to the server
    print("Client:", newData.allow_skywalk)
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

ReadSkywalkData()

local function ResetSkywalkData()
    file.Write(settingsFileName, util.TableToJSON(skywalkBaseData))
    setConVar(skywalkBaseData)
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