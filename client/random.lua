local config = require 'config.client'
local randomEmotes = config.randomEmotes
local randomIndex = math.random(1, #randomEmotes)
local selectedEmote = randomEmotes[randomIndex]
local inProcessOfMovingCam = false
local freeze = false
local startingCam = nil
local playerHeadBone = nil

local function startDisablingControls()
    CreateThread(function()
        inProcessOfMovingCam = true
        while inProcessOfMovingCam do
            Wait(0)
            if freeze then FreezeEntityPosition(cache.ped, true) end
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 36, true)
            DisableControlAction(0, 72, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 64, true)
            DisableControlAction(0, 63, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 245, true) -- Chat
            DisableControlAction(0, 309, true) -- Chat
            DisableControlAction(0, 246, true) -- Chat
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(27, 75, true) -- disable exit vehicle
            DisableControlAction(0, 32, true) -- move (w)
            DisableControlAction(0, 34, true) -- move (a)
            DisableControlAction(0, 33, true) -- move (s)
            DisableControlAction(0, 35, true) -- move (d)
            DisablePlayerFiring(PlayerId(), true)
        end

        Wait(1000)
        inProcessOfMovingCam = false
        FreezeEntityPosition(cache.ped, false)
    end)
end

local function initialLoadingIn(coords)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z - 1.0, false, false, false, false)
    SetEntityHeading(cache.ped, coords.w or 0.0)
    FreezeEntityPosition(cache.ped, true)
    startDisablingControls()
    exports.scully_emotemenu:cancelEmote()
    SetEntityVisible(cache.ped, false)
    Wait(500)
    startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(startingCam, coords.x + 1, coords.y + 1, coords.z + config.howHighInTheSky * 100) -- Make this get ground coords and do maths
    PointCamAtEntity(startingCam, cache.ped, 0, 0, 0, 1)
    SetCamFov(startingCam, config.camFov + 10.0)
    RenderScriptCams(true, true, 1, true, true)
    Wait(500)
    DoScreenFadeIn(2000)
end

local function destroyAllCameras(durationToRender)
    SetNuiFocus(false, false)
    RenderScriptCams(false, true, durationToRender, true, true)
    Wait(5)
    DestroyAllCams()
end

function startRandomSpawn(coords)
    DisplayRadar(false)
    TriggerEvent('nt_hud:client:toggleHud', false)
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    initialLoadingIn(coords)
    destroyAllCameras(config.howLongItTakesToZoomInToPlayer)
    SetEntityVisible(cache.ped, true)
    Wait(100)
    exports.scully_emotemenu:playEmoteByCommand(selectedEmote)
    Wait(config.howLongItTakesToZoomInToPlayer + 50)
    playerHeadBone = GetPedBoneIndex(cache.ped, "SKEL_HEAD")
    startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    ShakeCam(startingCam, "FAMILY5_DRUG_TRIP_SHAKE", 0.35)
    freeze = true
    if selectedEmote == "prone" then
        SetCamCoord(startingCam, GetEntityCoords(cache.ped).x + 3.5, GetEntityCoords(cache.ped).y - 2, GetEntityCoords(cache.ped).z - 0.9) -- Make this get ground coords and do maths
        PointCamAtPedBone(startingCam, cache.ped, playerHeadBone, 1, 1, -0.5, true)
        SetCamFov(startingCam, config.camFovProne)
        RenderScriptCams(true, true, 3500, true, true)
    else
        SetCamCoord(startingCam, coords.x + 4, coords.y - 3.8, coords.z + 1.3) -- Make this get ground coords and do maths
        PointCamAtPedBone(startingCam, cache.ped, playerHeadBone, 1, 1, 0, true)
        SetCamFov(startingCam, config.camFov)
        RenderScriptCams(true, true, config.waitTimeToRenderCamera, true, true)
    end

    Wait(config.waitTimeToRenderCamera) -- Wait before ending final camera (Usually while doing anim)
    destroyAllCameras(2000)
    Wait(100)
    freeze = false
    inProcessOfMovingCam = false
    StopCamShaking(startingCam, true)
    exports.scully_emotemenu:setLimitation(false) -- false to disable it
    exports.scully_emotemenu:cancelEmote()
    FreezeEntityPosition(cache.ped, false)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerEvent('nt_hud:client:toggleHud', true)
end