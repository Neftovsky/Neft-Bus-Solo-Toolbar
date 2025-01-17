--[[ 
    Neft Bus Solo Toolbar
    This script creates a toolbar for controlling solo states on tracks in Reaper.
    It allows toggling the solo state for the following track groups:
    
    Rythm (Rythm Bus) - for the track named "Rythm Bus".
    VOC (Vocal Bus) - for the track named "Vocal Bus".
    FX (Send Bus) - for the track named "Send Bus".
    Instr (Instr Bus) - for the track named "Instr Bus".

    The toolbar can also be dragged around the screen by clicking and holding the space 
    between the buttons (not on the buttons themselves). The position is updated when the 
    mouse is dragged, and the toolbar follows the mouse's movement.
    
 ]]


local imgui = reaper.ImGui_CreateContext("Rythm Bus Toolbar")
local window_open = true

local toolbar_pos_x = 100
local toolbar_pos_y = 100
local dragging = false
local offset_x, offset_y = 0, 0

local window_flags = reaper.ImGui_WindowFlags_NoTitleBar()
                     | reaper.ImGui_WindowFlags_NoResize()
                     | reaper.ImGui_WindowFlags_NoScrollbar()
                     | reaper.ImGui_WindowFlags_NoCollapse()
                     | reaper.ImGui_WindowFlags_AlwaysAutoResize()
                     | reaper.ImGui_WindowFlags_NoBackground()

local default_button_color = 0x666666FF

local function HSV(h, s, v, a)
    local r, g, b = reaper.ImGui_ColorConvertHSVtoRGB(h, s, v)
    return reaper.ImGui_ColorConvertDouble4ToU32(r, g, b, a or 1.0)
end

local function ToggleSoloByTrackName(track_name)
    local track_count = reaper.CountTracks(0)
    local track_found = false
    for i = 0, track_count - 1 do
        local track = reaper.GetTrack(0, i)
        local _, current_track_name = reaper.GetTrackName(track)
        if current_track_name == track_name then
            track_found = true
            local solo_state = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
            if solo_state > 0 then
                reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 0)
            else
                reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 2)
            end
            break
        end
    end
    
    if not track_found then
        reaper.ShowMessageBox("Track '" .. track_name .. "' not found!", "Error", 0)
    end
end

local function CheckSoloState(track_name)
    local track_count = reaper.CountTracks(0)
    for i = 0, track_count - 1 do
        local track = reaper.GetTrack(0, i)
        local _, current_track_name = reaper.GetTrackName(track)
        if current_track_name == track_name then
            local solo_state = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
            return solo_state > 0
        end
    end
    return false
end

local function Main()
    if window_open then
        reaper.ImGui_SetNextWindowPos(imgui, toolbar_pos_x, toolbar_pos_y, reaper.ImGui_Cond_FirstUseEver())
        reaper.ImGui_SetNextWindowSize(imgui, 400, 50, reaper.ImGui_Cond_FirstUseEver())

        local visible, open = reaper.ImGui_Begin(imgui, "Rythm Bus Toolbar", true, window_flags)

        if visible then
            if reaper.ImGui_IsItemHovered(imgui) and reaper.ImGui_IsMouseDown(imgui, 0) then
                if not dragging then
                    dragging = true
                    local mouse_x, mouse_y = reaper.ImGui_GetMousePos(imgui)
                    offset_x = mouse_x - toolbar_pos_x
                    offset_y = mouse_y - toolbar_pos_y
                end
            elseif not reaper.ImGui_IsMouseDown(imgui, 0) then
                dragging = false
            end

            if dragging then
                local mouse_x, mouse_y = reaper.ImGui_GetMousePos(imgui)
                toolbar_pos_x = mouse_x - offset_x
                toolbar_pos_y = mouse_y - offset_y
            end

            local rythm_soloed = CheckSoloState("Rythm Bus")
            if rythm_soloed then
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), HSV(0.1, 0.8, 0.8, 1.0))
            else
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), default_button_color)
            end
            if reaper.ImGui_Button(imgui, "RYTHM") then
                ToggleSoloByTrackName("Rythm Bus")
            end
            reaper.ImGui_PopStyleColor(imgui)

            reaper.ImGui_SameLine(imgui)

            local voc_soloed = CheckSoloState("Vocal Bus")
            if voc_soloed then
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), HSV(0.1, 0.8, 0.8, 1.0))
            else
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), default_button_color)
            end
            if reaper.ImGui_Button(imgui, "VOC") then
                ToggleSoloByTrackName("Vocal Bus")
            end
            reaper.ImGui_PopStyleColor(imgui)

            reaper.ImGui_SameLine(imgui)

            local instr_soloed = CheckSoloState("Instr Bus")
            if instr_soloed then
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), HSV(0.1, 0.8, 0.8, 1.0))
            else
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), default_button_color)
            end
            if reaper.ImGui_Button(imgui, "INSTR") then
                ToggleSoloByTrackName("Instr Bus")
            end
            reaper.ImGui_PopStyleColor(imgui)

            reaper.ImGui_SameLine(imgui)

            local fx_soloed = CheckSoloState("Send Bus")
            if fx_soloed then
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), HSV(0.1, 0.8, 0.8, 1.0))
            else
                reaper.ImGui_PushStyleColor(imgui, reaper.ImGui_Col_Button(), default_button_color)
            end
            if reaper.ImGui_Button(imgui, "FX") then
                ToggleSoloByTrackName("Send Bus")
            end
            reaper.ImGui_PopStyleColor(imgui)

            reaper.ImGui_End(imgui)
        end

        if not open then window_open = false end
    else
        reaper.ImGui_DestroyContext(imgui)
        return
    end

    reaper.defer(Main)
end

Main()

