local cam = nil
local charPed = nil
local loadScreenCheckState = false
local QBCore = exports['qb-core']:GetCoreObject()
local cached_player_skins = {}

local randommodels = { -- models possible to load when choosing empty slot
    'mp_m_freemode_01',
    'mp_f_freemode_01',
}

-- Main Thread

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qb-multicharacter:client:chooseChar')
			return
		end
	end
end)

-- Functions

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end


function delpeds() 
    for i = 1, 3 do
        local delped = Config.pedModels[i]
        local hashped = GetHashKey(delped)
        
        local allPeds = GetGamePool('CPed')
        for _, ped in ipairs(allPeds) do
            if GetEntityModel(ped) == hashped then
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end
        end
    end
    DeleteEntity(characterPed)
end

local function initializePedModel(model, data)
    CreateThread(function()
        if not model then
            model = joaat(randommodels[math.random(#randommodels)])
        end
        loadModel(model)
        charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
        SetPedComponentVariation(charPed, 0, 0, 0, 2)
        FreezeEntityPosition(charPed, false)
        SetEntityInvincible(charPed, true)
        PlaceObjectOnGroundProperly(charPed)
        SetBlockingOfNonTemporaryEvents(charPed, true)
        if data then
            TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)
        end

    end)
end

local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.0 ,0.0, Config.CamCoords.w, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local function openCharMenu(bool)
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:GetNumberOfCharacters", function(result)
        local translations = {}
        for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
            if k:sub(0, ('ui.'):len()) then
                translations[k:sub(('ui.'):len() + 1)] = Lang:t(k)
            end
        end
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "ui",
            customNationality = Config.customNationality,
            toggle = bool,
            nChar = result,
            enableDeleteButton = Config.EnableDeleteButton,
            translations = translations
        })
        skyCam(bool)
        if not loadScreenCheckState then
            -- ShutdownLoadingScreenNui()
            loadScreenCheckState = true
        end
    end)
end

-- Events

RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    local interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Wait(1000)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(1500)
    -- ShutdownLoadingScreen()
    -- ShutdownLoadingScreenNui()
    openCharMenu(true)
end)

RegisterNetEvent('qb-multicharacter:client:spawnLastLocation', function(coords, cData)
    QBCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result then
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
            local ped = PlayerPedId()
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
            SetEntityHeading(ped, coords.w)
            FreezeEntityPosition(ped, false)
            SetEntityVisible(ped, true)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local insideMeta = PlayerData.metadata["inside"]
            DoScreenFadeOut(500)
            SetNuiFocus(false, false)

            if insideMeta.house then
                TriggerEvent('qb-houses:client:LastLocationHouse', insideMeta.house)
            elseif insideMeta.apartment.apartmentType and insideMeta.apartment.apartmentId then
                TriggerEvent('qb-apartments:client:LastLocationHouse', insideMeta.apartment.apartmentType, insideMeta.apartment.apartmentId)
            else
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
                SetEntityHeading(ped, coords.w)
                FreezeEntityPosition(ped, false)
                SetEntityVisible(ped, true)
            end

            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            Wait(2000)
            DoScreenFadeIn(250)
        end
    end, cData.citizenid)
end)


RegisterNetEvent('save_all_clothes') -- The actual saving.
AddEventHandler('save_all_clothes',function(characterPed)
    local ped = characterPed
    mask_old,mask_tex,mask_pal = GetPedDrawableVariation(ped,1),GetPedTextureVariation(ped,1),GetPedPaletteVariation(ped,1)
    vest_old,vest_tex,vest_pal = GetPedDrawableVariation(ped,9),GetPedTextureVariation(ped,9),GetPedPaletteVariation(ped,9)
    glass_prop,glass_tex = GetPedPropIndex(ped,1),GetPedPropTextureIndex(ped,1)
    hat_prop,hat_tex = GetPedPropIndex(ped,0),GetPedPropTextureIndex(ped,0)
    jacket_old,jacket_tex,jacket_pal = GetPedDrawableVariation(ped, 11),GetPedTextureVariation(ped,11),GetPedPaletteVariation(ped,11)
    shirt_old,shirt_tex,shirt_pal = GetPedDrawableVariation(ped,8),GetPedTextureVariation(ped,8),GetPedPaletteVariation(ped,8)
    arms_old,arms_tex,arms_pal = GetPedDrawableVariation(ped,3),GetPedTextureVariation(ped,3),GetPedPaletteVariation(ped,3)
    pants_old,pants_tex,pants_pal = GetPedDrawableVariation(ped,4),GetPedTextureVariation(ped,4),GetPedPaletteVariation(ped,4)
    feet_old,feet_tex,feet_pal = GetPedDrawableVariation(ped,6),GetPedTextureVariation(ped,6),GetPedPaletteVariation(ped,6)
    hair_old,hair_tex,hair_pal = GetPedDrawableVariation(ped,2),GetPedTextureVariation(ped,2),GetPedPaletteVariation(ped,2)
end)

-- NUI Callbacks

RegisterNUICallback('closeUI', function(_, cb)
    local cData = data.cData
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    if Config.SkipSelection then
        SetNuiFocus(false, false)
        skyCam(false)
    else
        openCharMenu(false)
    end
    cb("ok")
end)

RegisterNUICallback('disconnectButton', function(_, cb)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('qb-multicharacter:server:disconnect')
    cb("ok")
end)

local isCinematic = true
local isCinematic2 = true

RegisterNUICallback('selectCharacter', function(data, cb)
    local cData = data.cData
    local playerId = PlayerPedId()
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    SetEntityInvincible(playerId, false)
    SetEntityVisible(playerId, true, 0)
    StopCutscene(false)
    StopCutsceneImmediately()
    isCinematic = false
    isCinematic2 = false
    cb("ok")
end)

RegisterNUICallback('cDataPed', function(nData, cb)
    local cData = nData.cData
    isCinematic = false
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    delpeds()
    if cData ~= nil then
        if not cached_player_skins[cData.citizenid] then
            local temp_model = promise.new()
            local temp_data = promise.new()

            QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
                temp_model:resolve(model)
                temp_data:resolve(data)
            end, cData.citizenid)

            local resolved_model = Citizen.Await(temp_model)
            local resolved_data = Citizen.Await(temp_data)

            cached_player_skins[cData.citizenid] = {model = resolved_model, data = resolved_data}
        end

        local model = cached_player_skins[cData.citizenid].model
        local data = cached_player_skins[cData.citizenid].data

        model = model ~= nil and tonumber(model) or false

        if model ~= nil then
            initializePedModel(model, json.decode(data))
        else
            initializePedModel()
        end
        cb("ok")
    else
        initializePedModel()
        cb("ok")
    end
end)


-- RegisterNUICallback('cutscene', function(nData, cb)
--     DoScreenFadeOut(10)
--     Wait(1000)
--     StopCutscene(false)
--     StopCutsceneImmediately()
--     Wait(1000)
--     local cData = nData.cData



--     if cData ~= nil then
--         if not cached_player_skins[cData.citizenid] then
--             local temp_model = promise.new()
--             local temp_data = promise.new()

--             QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
--                 temp_model:resolve(model)
--                 temp_data:resolve(data)
--             end, cData.citizenid)

--             local resolved_model = Citizen.Await(temp_model)
--             local resolved_data = Citizen.Await(temp_data)

--             cached_player_skins[cData.citizenid] = {model = resolved_model, data = resolved_data}
--         end
--         local model = cached_player_skins[cData.citizenid].model
--         local data = cached_player_skins[cData.citizenid].data
--         model = model ~= nil and tonumber(model) or false
        

--         if model ~= nil and isCinematic2 == false then
--             TriggerEvent('qb-multicharacter:client:cutscene', model, json.decode(data))
--         elseif isCinematic2 then
--             TriggerEvent('qb-multicharacter:client:selectcutscene', model, json.decode(data))
--         else
--             TriggerEvent('qb-multicharacter:client:cutscene')
--         end
--     else 
--         TriggerEvent('qb-multicharacter:client:cutscene')
--     end
-- end)

RegisterNUICallback('scenecutscene', function(nData, cb)
    StopCutscene(false)
    StopCutsceneImmediately()
    DoScreenFadeOut(10)
    Wait(400)
    local cData = nData.cData

    if cData ~= nil then
        if not cached_player_skins[cData.citizenid] then
            local temp_model = promise.new()
            local temp_data = promise.new()

            QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
                temp_model:resolve(model)
                temp_data:resolve(data)
            end, cData.citizenid)

            local resolved_model = Citizen.Await(temp_model)
            local resolved_data = Citizen.Await(temp_data)

            cached_player_skins[cData.citizenid] = {model = resolved_model, data = resolved_data}
        end
        local model = cached_player_skins[cData.citizenid].model
        local data = cached_player_skins[cData.citizenid].data
        model = model ~= nil and tonumber(model) or false
        

        if model ~= nil then
            TriggerEvent('qb-multicharacter:client:selectcutscene', model, json.decode(data))
        else
            TriggerEvent('qb-multicharacter:client:selectcutscene')
        end
    else 
        TriggerEvent('qb-multicharacter:client:selectcutscene')
    end
end)


-- RegisterNetEvent("qb-multicharacter:client:cutscene")
-- AddEventHandler("qb-multicharacter:client:cutscene", function(model, data)
--     DoScreenFadeOut(1800)


--     local usedCutscenes = {}

--     local function getRandomCutscene()
--         if #usedCutscenes == #Config.Cutscenes then
--             -- Todas las cutscenes han sido usadas, reinicia
--             usedCutscenes = {}
--         end
        
--         local availableCutscenes = {}
--         for i, cutscene in ipairs(Config.Cutscenes) do
--             if not usedCutscenes[i] then
--                 table.insert(availableCutscenes, {index = i, cutscene = cutscene})
--             end
--         end
        
--         local randomIndex = math.random(1, #availableCutscenes)
--         local selected = availableCutscenes[randomIndex]
        
--         usedCutscenes[selected.index] = true
--         return selected.cutscene
--     end
    
--     -- Uso:
--     local playerId = PlayerPedId()
    
--     local selectedCutscene = getRandomCutscene()
    
--     while not HasCutsceneLoaded() do
--         Wait(0)
--         RequestCutscene(selectedCutscene.cutscene, 8)
--     end

--     if not model then
--         hash = GetHashKey(Config.pedDefault)
--         RequestModel(hash)
--         while not HasModelLoaded(hash) do
--             Wait(1)
--         end
--         characterPed = CreatePed(2, hash, -803.49, 178.92, 76.74 - 0.98, Config.PedCoords.w, false, true)
--         SetEntityCoords(playerId, selectedCutscene.coords.x, selectedCutscene.coords.y, selectedCutscene.coords.z - 0.98, false, false, false, true)
--         SetEntityInvincible(playerId, true)
--         SetEntityVisible(playerId, false, 0)
--     else
--         loadModel(model)
--         characterPed = CreatePed(2, model, -803.49, 178.92, 76.74 - 0.98, Config.PedCoords.w, false, true)
--         TriggerEvent('qb-clothing:client:loadPlayerClothing', data, characterPed)
--         -- SetEntityCoords(playerId, -803.49, 178.92, 76.74 - 0.98, false, false, false, true)
--         SetEntityCoords(playerId, selectedCutscene.coords.x, selectedCutscene.coords.y, selectedCutscene.coords.z - 0.98, false, false, false, true)
--         SetEntityInvincible(playerId, true)
--         SetEntityVisible(playerId, false, 0)

--         -- Citizen.CreateThread(function()

--         --     RequestModel(model)
--         --     while not HasModelLoaded(model) do
--         --         RequestModel(model)
--         --         Citizen.Wait(0)
--         --     end
--         --     SetPlayerModel(PlayerId(), model)
--         --     TriggerEvent('qb-clothing:client:loadPlayerClothing', data)
--         --     SetModelAsNoLongerNeeded(model)

--         --     Wait(1600)
--         --     SetPedComponentVariation(playerId, 0, 0, 0, 2)

--         --     Wait(2000)

--         -- Wait(0)
--         -- end)
--         Wait(100)
--     end
--     SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
--     RegisterEntityForCutscene(characterPed, 'MP_1', 0, model, 64)


--     for i = 1, 3 do
--         local hash = GetHashKey(Config.pedModels[i])
--         local ped = createped(hash)
--         local cuenta = "MP_" .. (i + 1)
--         RegisterEntityForCutscene(ped, cuenta, 0, GetEntityModel(ped), 64)
--     end

--     TriggerEvent("save_all_clothes", characterPed)

--     Wait(100)
--     StartCutscene(4)
--     DoScreenFadeIn(400)
--     Wait(0)
--     StopCutsceneAudio()

--     if not model then

--     else
--         SetCutscenePedComponentVariationFromPed(characterPed, characterPed, 1885233650)
--         SetPedComponentVariation(characterPed, 11, jacket_old, jacket_tex, jacket_pal)
--         SetPedComponentVariation(characterPed, 8, shirt_old, shirt_tex, shirt_pal)
--         SetPedComponentVariation(characterPed, 3, arms_old, arms_tex, arms_pal)
--         SetPedComponentVariation(characterPed, 4, pants_old,pants_tex,pants_pal)
--         SetPedComponentVariation(characterPed, 6, feet_old,feet_tex,feet_pal)
--         SetPedComponentVariation(characterPed, 1, mask_old,mask_tex,mask_pal)
--         SetPedComponentVariation(characterPed, 9, vest_old,vest_tex,vest_pal)
--         SetPedComponentVariation(characterPed, 2, hair_old,hair_tex,hair_pal)
--         SetPedPropIndex(characterPed, 0, hat_prop, hat_tex, 0)
--         SetPedPropIndex(characterPed, 1, glass_prop, glass_tex, 0)
--     end

--     while not (DoesCutsceneEntityExist('MP_1', 0)) do
--         Wait(0)
--     end

--     local timescene = GetCutsceneTotalDuration()

--     Wait(timescene - 2000)

--     if isCinematic then
--         DoScreenFadeOut(1000)
--         Wait(2400)
--         delpeds()
        
--         TriggerEvent('qb-multicharacter:client:cutscene', model, data)
--     else

--     end

-- end)


RegisterNetEvent("qb-multicharacter:client:selectcutscene")
AddEventHandler("qb-multicharacter:client:selectcutscene", function(model, data)
    DoScreenFadeOut(1100)
    local usedCutscenes = {}

    local function getRandomCutscene()
        if #usedCutscenes == #Config.Cutscenes then
            -- Todas las cutscenes han sido usadas, reinicia
            usedCutscenes = {}
        end
        
        local availableCutscenes = {}
        for i, cutscene in ipairs(Config.Cutscenes) do
            if not usedCutscenes[i] then
                table.insert(availableCutscenes, {index = i, cutscene = cutscene})
            end
        end
        
        local randomIndex = math.random(1, #availableCutscenes)
        local selected = availableCutscenes[randomIndex]
        
        usedCutscenes[selected.index] = true
        return selected.cutscene
    end
    
    -- Uso:
    local playerId = PlayerPedId()
    
    local selectedCutscene = getRandomCutscene()
    
    while not HasCutsceneLoaded() do
        Wait(0)
        RequestCutscene(selectedCutscene.cutscene, 8)
    end

    if not model then
        hash = GetHashKey(Config.pedDefault)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(1)
        end
        characterPed = CreatePed(2, hash, -803.49, 178.92, 76.74 - 0.98, Config.PedCoords.w, false, true)
        SetEntityCoords(playerId, selectedCutscene.coords.x, selectedCutscene.coords.y, selectedCutscene.coords.z - 0.98, false, false, false, true)
        SetEntityInvincible(playerId, true)
        SetEntityVisible(playerId, false, 0)
    else
        loadModel(model)
        characterPed = CreatePed(2, model, -803.49, 178.92, 76.74 - 0.98, Config.PedCoords.w, false, true)
        TriggerEvent('qb-clothing:client:loadPlayerClothing', data, characterPed)
        SetEntityCoords(playerId, selectedCutscene.coords.x, selectedCutscene.coords.y, selectedCutscene.coords.z - 0.98, false, false, false, true)
        SetEntityInvincible(playerId, true)
        SetEntityVisible(playerId, false, 0)

        Wait(100)
    end
    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(characterPed, 'MP_1', 0, model, 64)

    local pedHeading = Config.PedCoords.w

    local hashPedModel = GetHashKey(Config.pedModels[1])
    loadModel(hashPedModel)
    local pedOffLine2 = CreatePed(2, hashPedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, pedHeading, false, true)
    SetCutsceneEntityStreamingFlags("MP_2", 0, 1)
    RegisterEntityForCutscene(pedOffLine2, "MP_2", 0, hashPedModel, 64)

    local pedOffLine3 = CreatePed(2, hashPedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, pedHeading, false, true)
    SetCutsceneEntityStreamingFlags("MP_3", 0, 1)
    RegisterEntityForCutscene(pedOffLine3, "MP_3", 0, hashPedModel, 64)
    
    local pedOffLine4 = CreatePed(2, hashPedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, pedHeading, false, true)
    SetCutsceneEntityStreamingFlags("MP_4", 0, 1)
    RegisterEntityForCutscene(pedOffLine4, "MP_4", 0, hashPedModel, 64)

    local clothesConfig2 = Config.Clothes["ped2"]
    local clothesConfig3 = Config.Clothes["ped3"]
    local clothesConfig4 = Config.Clothes["ped4"]


    TriggerEvent("save_all_clothes", characterPed)

    StartCutscene(4)
    DoScreenFadeIn(400)
    Wait(0)
    StopCutsceneAudio()

    if not model then
        SetCutscenePedComponentVariationFromPed(pedOffLine2, pedOffLine2, 1885233650)
        SetPedComponentVariation(pedOffLine2, 3, clothesConfig2.arms.old, clothesConfig2.arms.tex, clothesConfig2.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine2, 4, clothesConfig2.pants.old, clothesConfig2.pants.tex, clothesConfig2.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine2, 6, clothesConfig2.feet.old, clothesConfig2.feet.tex, clothesConfig2.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine2, 8, clothesConfig2.shirt.old, clothesConfig2.shirt.tex, clothesConfig2.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine2, 9, clothesConfig2.vest.old, clothesConfig2.vest.tex, clothesConfig2.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine2, 11, clothesConfig2.jacket.old, clothesConfig2.jacket.tex, clothesConfig2.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine2, 1, clothesConfig2.mask.old, clothesConfig2.mask.tex, clothesConfig2.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine2, 0, clothesConfig2.face.old, clothesConfig2.face.tex, clothesConfig2.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine2, 2, clothesConfig2.hair.old, clothesConfig2.hair.tex, clothesConfig2.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine2, 0, clothesConfig2.hat.prop, clothesConfig2.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine2, 1, clothesConfig2.glass.prop, clothesConfig2.glass.tex, 0)  

        SetCutscenePedComponentVariationFromPed(pedOffLine3, pedOffLine3, 1885233650)
        SetPedComponentVariation(pedOffLine3, 3, clothesConfig3.arms.old, clothesConfig3.arms.tex, clothesConfig3.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine3, 4, clothesConfig3.pants.old, clothesConfig3.pants.tex, clothesConfig3.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine3, 6, clothesConfig3.feet.old, clothesConfig3.feet.tex, clothesConfig3.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine3, 8, clothesConfig3.shirt.old, clothesConfig3.shirt.tex, clothesConfig3.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine3, 9, clothesConfig3.vest.old, clothesConfig3.vest.tex, clothesConfig3.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine3, 11, clothesConfig3.jacket.old, clothesConfig3.jacket.tex, clothesConfig3.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine3, 1, clothesConfig3.mask.old, clothesConfig3.mask.tex, clothesConfig3.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine3, 0, clothesConfig3.face.old, clothesConfig3.face.tex, clothesConfig3.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine3, 2, clothesConfig3.hair.old, clothesConfig3.hair.tex, clothesConfig3.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine3, 0, clothesConfig3.hat.prop, clothesConfig3.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine3, 1, clothesConfig3.glass.prop, clothesConfig3.glass.tex, 0)  

        SetCutscenePedComponentVariationFromPed(pedOffLine4, pedOffLine4, 1885233650)
        SetPedComponentVariation(pedOffLine4, 3, clothesConfig4.arms.old, clothesConfig4.arms.tex, clothesConfig4.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine4, 4, clothesConfig4.pants.old, clothesConfig4.pants.tex, clothesConfig4.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine4, 6, clothesConfig4.feet.old, clothesConfig4.feet.tex, clothesConfig4.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine4, 8, clothesConfig4.shirt.old, clothesConfig4.shirt.tex, clothesConfig4.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine4, 9, clothesConfig4.vest.old, clothesConfig4.vest.tex, clothesConfig4.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine4, 11, clothesConfig4.jacket.old, clothesConfig4.jacket.tex, clothesConfig4.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine4, 1, clothesConfig4.mask.old, clothesConfig4.mask.tex, clothesConfig4.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine4, 0, clothesConfig4.face.old, clothesConfig4.face.tex, clothesConfig4.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine4, 2, clothesConfig4.hair.old, clothesConfig4.hair.tex, clothesConfig4.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine4, 0, clothesConfig4.hat.prop, clothesConfig4.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine4, 1, clothesConfig4.glass.prop, clothesConfig4.glass.tex, 0)   
    else

        SetCutscenePedComponentVariationFromPed(pedOffLine2, pedOffLine2, 1885233650)
        SetPedComponentVariation(pedOffLine2, 3, clothesConfig2.arms.old, clothesConfig2.arms.tex, clothesConfig2.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine2, 4, clothesConfig2.pants.old, clothesConfig2.pants.tex, clothesConfig2.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine2, 6, clothesConfig2.feet.old, clothesConfig2.feet.tex, clothesConfig2.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine2, 8, clothesConfig2.shirt.old, clothesConfig2.shirt.tex, clothesConfig2.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine2, 9, clothesConfig2.vest.old, clothesConfig2.vest.tex, clothesConfig2.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine2, 11, clothesConfig2.jacket.old, clothesConfig2.jacket.tex, clothesConfig2.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine2, 1, clothesConfig2.mask.old, clothesConfig2.mask.tex, clothesConfig2.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine2, 0, clothesConfig2.face.old, clothesConfig2.face.tex, clothesConfig2.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine2, 2, clothesConfig2.hair.old, clothesConfig2.hair.tex, clothesConfig2.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine2, 0, clothesConfig2.hat.prop, clothesConfig2.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine2, 1, clothesConfig2.glass.prop, clothesConfig2.glass.tex, 0)  

        SetCutscenePedComponentVariationFromPed(pedOffLine3, pedOffLine3, 1885233650)
        SetPedComponentVariation(pedOffLine3, 3, clothesConfig3.arms.old, clothesConfig3.arms.tex, clothesConfig3.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine3, 4, clothesConfig3.pants.old, clothesConfig3.pants.tex, clothesConfig3.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine3, 6, clothesConfig3.feet.old, clothesConfig3.feet.tex, clothesConfig3.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine3, 8, clothesConfig3.shirt.old, clothesConfig3.shirt.tex, clothesConfig3.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine3, 9, clothesConfig3.vest.old, clothesConfig3.vest.tex, clothesConfig3.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine3, 11, clothesConfig3.jacket.old, clothesConfig3.jacket.tex, clothesConfig3.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine3, 1, clothesConfig3.mask.old, clothesConfig3.mask.tex, clothesConfig3.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine3, 0, clothesConfig3.face.old, clothesConfig3.face.tex, clothesConfig3.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine3, 2, clothesConfig3.hair.old, clothesConfig3.hair.tex, clothesConfig3.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine3, 0, clothesConfig3.hat.prop, clothesConfig3.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine3, 1, clothesConfig3.glass.prop, clothesConfig3.glass.tex, 0)  

        SetCutscenePedComponentVariationFromPed(pedOffLine4, pedOffLine4, 1885233650)
        SetPedComponentVariation(pedOffLine4, 3, clothesConfig4.arms.old, clothesConfig4.arms.tex, clothesConfig4.arms.pal)       -- Brazos
        SetPedComponentVariation(pedOffLine4, 4, clothesConfig4.pants.old, clothesConfig4.pants.tex, clothesConfig4.pants.pal)   -- Pantalones
        SetPedComponentVariation(pedOffLine4, 6, clothesConfig4.feet.old, clothesConfig4.feet.tex, clothesConfig4.feet.pal)       -- Zapatos
        SetPedComponentVariation(pedOffLine4, 8, clothesConfig4.shirt.old, clothesConfig4.shirt.tex, clothesConfig4.shirt.pal)   -- Camisa
        SetPedComponentVariation(pedOffLine4, 9, clothesConfig4.vest.old, clothesConfig4.vest.tex, clothesConfig4.vest.pal)       -- Chaleco
        SetPedComponentVariation(pedOffLine4, 11, clothesConfig4.jacket.old, clothesConfig4.jacket.tex, clothesConfig4.jacket.pal) -- Chaqueta
        SetPedComponentVariation(pedOffLine4, 1, clothesConfig4.mask.old, clothesConfig4.mask.tex, clothesConfig4.mask.pal)       -- Máscara
        SetPedComponentVariation(pedOffLine4, 0, clothesConfig4.face.old, clothesConfig4.face.tex, clothesConfig4.face.pal)       -- Cara
        SetPedComponentVariation(pedOffLine4, 2, clothesConfig4.hair.old, clothesConfig4.hair.tex, clothesConfig4.hair.pal)       -- Cabello
        SetPedPropIndex(pedOffLine4, 0, clothesConfig4.hat.prop, clothesConfig4.hat.tex, 0)                              -- Sombrero
        SetPedPropIndex(pedOffLine4, 1, clothesConfig4.glass.prop, clothesConfig4.glass.tex, 0)   

        SetCutscenePedComponentVariationFromPed(characterPed, characterPed, 1885233650)
        SetPedComponentVariation(characterPed, 11, jacket_old, jacket_tex, jacket_pal)
        SetPedComponentVariation(characterPed, 8, shirt_old, shirt_tex, shirt_pal)
        SetPedComponentVariation(characterPed, 3, arms_old, arms_tex, arms_pal)
        SetPedComponentVariation(characterPed, 4, pants_old,pants_tex,pants_pal)
        SetPedComponentVariation(characterPed, 6, feet_old,feet_tex,feet_pal)
        SetPedComponentVariation(characterPed, 1, mask_old,mask_tex,mask_pal)
        SetPedComponentVariation(characterPed, 9, vest_old,vest_tex,vest_pal)
        SetPedComponentVariation(characterPed, 2, hair_old,hair_tex,hair_pal)
        SetPedPropIndex(characterPed, 0, hat_prop, hat_tex, 0)
        SetPedPropIndex(characterPed, 1, glass_prop, glass_tex, 0)
    end

    while not (DoesCutsceneEntityExist('MP_1', 0)) do
        Wait(0)
    end

    local timescene = GetCutsceneTotalDuration()

    Wait(timescene - 2000)
    SendNUIMessage({
        action = "disableButtonsTemp"
    })
    if isCinematic2 then
        DoScreenFadeOut(1000)
        Wait(2100)
        local issceneactive = IsCutsceneActive()
        if not issceneactive and isCinematic2 then
        print("no hay una escena en progreso")
        DoScreenFadeOut(1000)
        delpeds()
        TriggerEvent('qb-multicharacter:client:selectcutscene', model, data)
        else
        print("hay una escena en progreso o esta jugando el jugador")
        DoScreenFadeIn(1000)
        end
    else
        print("fuera2")
        DoScreenFadeIn(1000)
    end

end)



RegisterNUICallback('setupCharacters', function(_, cb)
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:setupCharacters", function(result)
	cached_player_skins = {}
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
        cb("ok")
    end)
end)

RegisterNUICallback('removeBlur', function(_, cb)
    SetTimecycleModifier('default')
    cb("ok")
end)

RegisterNUICallback('createNewCharacter', function(data, cb)
    local cData = data
    DoScreenFadeOut(150)
    StopCutscene(false)
    StopCutsceneImmediately()
    isCinematic = false
    isCinematic2 = false
    if cData.gender == Lang:t("ui.male") then
        cData.gender = 0
    elseif cData.gender == Lang:t("ui.female") then
        cData.gender = 1
    end
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    Wait(500)
    cb("ok")
end)

RegisterNUICallback('exit', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:exit')
    cb("ok")
end)

RegisterNUICallback('removeCharacter', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
    DeletePed(charPed)
    TriggerEvent('qb-multicharacter:client:chooseChar')
    cb("ok")
end)
