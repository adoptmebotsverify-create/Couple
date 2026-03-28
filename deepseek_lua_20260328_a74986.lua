-- Colten Hub UI Loader

local gui = Instance.new("ScreenGui")
gui.Name = "ColtenHub"
pcall(function()
	gui.Parent = game.CoreGui
end)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,40)
main.Position = UDim2.new(0.4,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Library | Colten Hub"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- menu
local menu = Instance.new("Frame", main)
menu.Size = UDim2.new(1,0,0,120)
menu.Position = UDim2.new(0,0,1,5)
menu.BackgroundColor3 = Color3.fromRGB(40,40,40)
menu.Visible = false

-- BUTTON 1
local btn1 = Instance.new("TextButton", menu)
btn1.Size = UDim2.new(1,-10,0,35)
btn1.Position = UDim2.new(0,5,0,5)
btn1.Text = "admin gave you script"
btn1.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn1.TextColor3 = Color3.new(1,1,1)
btn1.Font = Enum.Font.SourceSansBold
btn1.TextSize = 16

-- SECTION LABEL
local label2 = Instance.new("TextLabel", menu)
label2.Size = UDim2.new(1,-10,0,20)
label2.Position = UDim2.new(0,5,0,45)
label2.Text = "Pet spawner and fake trade"
label2.BackgroundTransparency = 1
label2.TextColor3 = Color3.new(1,1,1)
label2.Font = Enum.Font.SourceSansBold
label2.TextSize = 14
label2.TextXAlignment = Enum.TextXAlignment.Left

-- BUTTON 2
local btn2 = Instance.new("TextButton", menu)
btn2.Size = UDim2.new(1,-10,0,35)
btn2.Position = UDim2.new(0,5,0,70)
btn2.Text = "Run"
btn2.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn2.TextColor3 = Color3.new(1,1,1)
btn2.Font = Enum.Font.SourceSansBold
btn2.TextSize = 16

-- toggle menu
title.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)

-- SCRIPT 1
btn1.MouseButton1Click:Connect(function()
	task.spawn(function()

-- Roblox LocalScript: Pet Dialog Spawner (FIXED FOR ALL EXECUTORS)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Thread identity helper for different executors
local function set_thread_identity(level)
    if type(syn) == "table" and syn.set_thread_identity then
        return syn.set_thread_identity(level)
    elseif type(getthreadidentity) == "function" and type(setthreadidentity) == "function" then
        local current = getthreadidentity()
        setthreadidentity(level)
        return current
    elseif type(getthreadcontext) == "function" and type(setthreadcontext) == "function" then
        local current = getthreadcontext()
        setthreadcontext(level)
        return current
    end
    return 2 -- Default to 2 if no identity functions
end

-- Pet names list (capitalized properly)
local petNames = {
    "Bat Dragon", "Shadow Dragon", "Evil Unicorn", "Crow", "Giraffe", 
    "Parrot", "Diamond Butterfly", "Owl", "Frost Dragon", "Giant Panda", 
    "Balloon Unicorn", "Monkey King", "Arctic Reindeer", "Hedgehog", "Flamingo",
    "Turtle", "Kangaroo"
}

-- === GLOBAL SPAWNER SYSTEM ===
local spawnerSystemLoaded = false
local spawnerPets = {}
local equippedPet = nil
local mountedPet = nil
local currentMountTrack = nil

-- Make these functions global so they can be called from dialog
_G.createPet = nil
_G.equipPet = nil
_G.unequipPet = nil

-- === SPAWNER SYSTEM ===
local function loadSpawnerSystem()
    if spawnerSystemLoaded then return end
    
    local success, err = pcall(function()
        local oldIdentity = set_thread_identity(2)
        local Fsys = require(game.ReplicatedStorage:WaitForChild('Fsys'))
        local load = Fsys.load
        
        local clientData = load('ClientData')
        local items = load('KindDB')
        local router = load('RouterClient')
        local downloader = load('DownloadClient')
        local animationManager = load('AnimationManager')
        local petRigs = load('new:PetRigs')
        local UIManager = load('UIManager')
        
        set_thread_identity(oldIdentity)

        local petModels = {}

        local function updateData(key, action)
            local oldId = set_thread_identity(2)
            local data = clientData.get(key)
            local clonedData = table.clone(data)
            clientData.predict(key, action(clonedData))
            set_thread_identity(oldId)
        end

        local function getUniqueId()
            return HttpService:GenerateGUID(false)
        end

        local function getPetModel(kind)
            if petModels[kind] then
                return petModels[kind]:Clone()
            end

            local promise = downloader.promise_download_copy('Pets', kind)
            if promise then
                local streamed = promise:expect()
                petModels[kind] = streamed
                return streamed:Clone()
            end
            return nil
        end

        -- === PET CREATION ===
        _G.createPet = function(id, properties)
            local uniqueId = getUniqueId()
            local item = items[id]
            if not item then
                return nil
            end

            local oldId = set_thread_identity(2)
            local new_pet = {
                unique = uniqueId,
                category = 'pets',
                id = id,
                kind = item.kind,
                newness_order = math.random(1, 900000),
                properties = properties or {},
            }
            local inventory = clientData.get('inventory')
            inventory.pets[uniqueId] = new_pet
            set_thread_identity(oldId)
            
            spawnerPets[uniqueId] = {
                data = new_pet,
                model = nil,
            }
            
            return new_pet
        end

        local function neonify(model, entry)
            local petModel = model:FindFirstChild('PetModel')
            if not petModel then
                return
            end

            local oldId = set_thread_identity(2)
            local petRig = petRigs.get(petModel)
            set_thread_identity(oldId)
            
            if petRig and petRig.get_geo_part then
                for neonPart, configuration in pairs(entry.neon_parts) do
                    local trueNeonPart = petRig.get_geo_part(petModel, neonPart)
                    if trueNeonPart then
                        trueNeonPart.Material = configuration.Material
                        trueNeonPart.Color = configuration.Color
                    end
                end
            end
        end

        local function addPetWrapper(wrapper)
            updateData('pet_char_wrappers', function(petWrappers)
                wrapper.unique = #petWrappers + 1
                wrapper.index = #petWrappers + 1
                petWrappers[#petWrappers + 1] = wrapper
                return petWrappers
            end)
        end

        local function addPetState(state)
            updateData('pet_state_managers', function(petStates)
                petStates[#petStates + 1] = state
                return petStates
            end)
        end

        local function findIndex(array, finder)
            for index, value in pairs(array) do
                local isIt = finder(value, index)
                if isIt then
                    return index
                end
            end
            return nil
        end

        local function removePetWrapper(uniqueId)
            updateData('pet_char_wrappers', function(petWrappers)
                local index = findIndex(petWrappers, function(wrapper)
                    return wrapper.pet_unique == uniqueId
                end)

                if not index then
                    return petWrappers
                end

                table.remove(petWrappers, index)

                for wrapperIndex, wrapper in pairs(petWrappers) do
                    wrapper.unique = wrapperIndex
                    wrapper.index = wrapperIndex
                end

                return petWrappers
            end)
        end

        local function removePetState(uniqueId)
            local pet = spawnerPets[uniqueId]
            if not pet or not pet.model then
                return
            end

            updateData('pet_state_managers', function(petStates)
                local index = findIndex(petStates, function(state)
                    return state.char == pet.model
                end)

                if not index then
                    return petStates
                end

                table.remove(petStates, index)
                return petStates
            end)
        end

        -- === EQUIP/UNEQUIP SYSTEM ===
        _G.unequipPet = function(item)
            local pet = spawnerPets[item.unique]
            if not pet then 
                return 
            end

            removePetWrapper(item.unique)
            removePetState(item.unique)

            if pet.model then
                pet.model:Destroy()
                pet.model = nil
            end

            equippedPet = nil
        end

        _G.equipPet = function(item)
            if equippedPet then
                _G.unequipPet(equippedPet)
            end

            local petModel = getPetModel(item.kind)
            if not petModel then
                return
            end
            
            petModel.Parent = workspace
            spawnerPets[item.unique].model = petModel

            if item.properties.neon or item.properties.mega_neon then
                neonify(petModel, items[item.kind])
            end

            equippedPet = item
            
            local wrapper = {
                char = petModel,
                mega_neon = item.properties.mega_neon,
                neon = item.properties.neon,
                player = LocalPlayer,
                entity_controller = LocalPlayer,
                controller = LocalPlayer,
                rp_name = item.properties.rp_name or '',
                pet_trick_level = item.properties.pet_trick_level,
                pet_unique = item.unique,
                pet_id = item.id,
                location = {
                    full_destination_id = 'housing',
                    destination_id = 'housing',
                    house_owner = LocalPlayer,
                },
                pet_progression = {
                    age = math.random(1, 900000),
                    percentage = math.random(0.01, 0.99),
                },
                are_colors_sealed = false,
                is_pet = true,
            }
            
            addPetWrapper(wrapper)

            addPetState({
                char = petModel,
                player = LocalPlayer,
                store_key = 'pet_state_managers',
                is_sitting = false,
                chars_connected_to_me = {},
                states = {},
            })
        end

        -- Helper function to get pet by name
        local InventoryDB = load('InventoryDB')
        _G.GetPetByName = function(name)
            local oldId = set_thread_identity(2)
            for i, v in pairs(InventoryDB.pets) do
                if v.name:lower() == name:lower() then
                    set_thread_identity(oldId)
                    return v.id
                end
            end
            set_thread_identity(oldId)
            return false
        end

        -- ROUTER.GET OVERRIDE
        local oldGet = router.get

        local function createRemoteFunctionMock(callback)
            return {
                InvokeServer = function(_, ...)
                    return callback(...)
                end,
            }
        end

        local function createRemoteEventMock(callback)
            return {
                FireServer = function(_, ...)
                    return callback(...)
                end,
            }
        end

        -- Helper functions for mounting
        local function clearPetState(uniqueId)
            local pet = spawnerPets[uniqueId]
            if not pet or not pet.model then return end

            updateData('pet_state_managers', function(states)
                local index = findIndex(states, function(state)
                    return state.char == pet.model
                end)
                if not index then return states end

                local clonedStates = table.clone(states)
                clonedStates[index] = table.clone(clonedStates[index])
                clonedStates[index].states = {}
                return clonedStates
            end)
        end

        local function setPetState(uniqueId, id)
            local pet = spawnerPets[uniqueId]
            if not pet or not pet.model then return end

            updateData('pet_state_managers', function(states)
                local index = findIndex(states, function(state)
                    return state.char == pet.model
                end)
                if not index then return states end

                local clonedStates = table.clone(states)
                clonedStates[index] = table.clone(clonedStates[index])
                clonedStates[index].states = {{ id = id }}
                return clonedStates
            end)
        end

        local function attachPlayerToPet(pet)
            local character = LocalPlayer.Character
            if not character or not character.PrimaryPart then return false end

            local ridePosition = pet:FindFirstChild('RidePosition', true)
            if not ridePosition then return false end

            local sourceAttachment = Instance.new('Attachment')
            sourceAttachment.Parent = ridePosition
            sourceAttachment.Position = Vector3.new(0, 1.237, 0)
            sourceAttachment.Name = 'SourceAttachment'

            local stateConnection = Instance.new('RigidConstraint')
            stateConnection.Name = 'StateConnection'
            stateConnection.Attachment0 = sourceAttachment
            stateConnection.Attachment1 = character.PrimaryPart.RootAttachment
            stateConnection.Parent = character

            return true
        end

        local function clearPlayerState()
            updateData('state_manager', function(state)
                local clonedState = table.clone(state)
                clonedState.states = {}
                clonedState.is_sitting = false
                return clonedState
            end)
        end

        local function setPlayerState(id)
            updateData('state_manager', function(state)
                local clonedState = table.clone(state)
                clonedState.states = {{ id = id }}
                clonedState.is_sitting = true
                return clonedState
            end)
        end

        local function unmount(uniqueId)
            local pet = spawnerPets[uniqueId]
            if not pet or not pet.model then return end

            if currentMountTrack then
                currentMountTrack:Stop()
                currentMountTrack:Destroy()
            end

            local sourceAttachment = pet.model:FindFirstChild('SourceAttachment', true)
            if sourceAttachment then
                sourceAttachment:Destroy()
            end

            if LocalPlayer.Character then
                for _, descendant in pairs(LocalPlayer.Character:GetDescendants()) do
                    if descendant:IsA('BasePart') and descendant:GetAttribute('HaveMass') then
                        descendant.Massless = false
                    end
                end
            end

            clearPetState(uniqueId)
            clearPlayerState()
            pet.model:ScaleTo(1)
            mountedPet = nil
        end

        local function mount(uniqueId, playerState, petState)
            local pet = spawnerPets[uniqueId]
            if not pet or not pet.model then return end

            local player = LocalPlayer
            if not player.Character or not player.Character.PrimaryPart then return end

            mountedPet = uniqueId

            setPetState(uniqueId, petState)
            setPlayerState(playerState)

            pet.model:ScaleTo(2)
            attachPlayerToPet(pet.model)

            currentMountTrack = player.Character.Humanoid.Animator:LoadAnimation(
                animationManager.get_track('PlayerRidingPet')
            )
            player.Character.Humanoid.Sit = true

            for _, descendant in pairs(player.Character:GetDescendants()) do
                if descendant:IsA('BasePart') and descendant.Massless == false then
                    descendant.Massless = true
                    descendant:SetAttribute('HaveMass', true)
                end
            end

            currentMountTrack:Play()
        end

        local function fly(uniqueId)
            mount(uniqueId, 'PlayerFlyingPet', 'PetBeingFlown')
        end

        local function ride(uniqueId)
            mount(uniqueId, 'PlayerRidingPet', 'PetBeingRidden')
        end

        -- Only intercept pet equips
        local equipRemote = createRemoteFunctionMock(function(uniqueId, metadata)
            local pet = spawnerPets[uniqueId]

            if pet then
                _G.equipPet(pet.data)
                return true, { action = 'equip', is_server = true }
            end

            -- Forward non-pet equips to original handler
            return oldGet('ToolAPI/Equip'):InvokeServer(uniqueId, metadata)
        end)

        -- Only intercept pet unequips
        local unequipRemote = createRemoteFunctionMock(function(uniqueId)
            local pet = spawnerPets[uniqueId]

            if pet then
                _G.unequipPet(pet.data)
                return true, { action = 'unequip', is_server = true }
            end

            -- Forward non-pet unequips to original handler
            return oldGet('ToolAPI/Unequip'):InvokeServer(uniqueId)
        end)

        -- Pet riding/flying remotes
        local rideRemote = createRemoteFunctionMock(function(item)
            ride(item.pet_unique)
        end)

        local flyRemote = createRemoteFunctionMock(function(item)
            fly(item.pet_unique)
        end)

        local unmountRemoteFunction = createRemoteFunctionMock(function()
            unmount(mountedPet)
        end)

        local unmountRemoteEvent = createRemoteEventMock(function()
            unmount(mountedPet)
        end)

        router.get = function(name)
            -- Only intercept pet-related calls
            if name == 'ToolAPI/Equip' then
                return equipRemote
            elseif name == 'ToolAPI/Unequip' then
                return unequipRemote
            elseif name == 'AdoptAPI/RidePet' then
                return rideRemote
            elseif name == 'AdoptAPI/FlyPet' then
                return flyRemote
            elseif name == 'AdoptAPI/ExitSeatStatesYield' then
                return unmountRemoteFunction
            elseif name == 'AdoptAPI/ExitSeatStates' then
                return unmountRemoteEvent
            end

            -- Pass through all other requests
            return oldGet(name)
        end

        spawnerSystemLoaded = true
    end)
    
    if not success then
        warn("Error loading spawner system:", err)
    end
end

-- === MAIN GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetDialogGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 250)
mainFrame.Position = UDim2.new(0.5, -90, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(170, 0, 255)
uiStroke.Thickness = 3
uiStroke.Transparency = 0
uiStroke.Parent = mainFrame

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(0, 190, 0, 260)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BackgroundTransparency = 0
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 0
blackFrame.Parent = screenGui

local blackCorner = Instance.new("UICorner")
blackCorner.CornerRadius = UDim.new(0, 12)
blackCorner.Parent = blackFrame

mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    blackFrame.Position = UDim2.new(
        mainFrame.Position.X.Scale,
        mainFrame.Position.X.Offset - 5,
        mainFrame.Position.Y.Scale,
        mainFrame.Position.Y.Offset - 5
    )
end)

blackFrame.Position = UDim2.new(
    mainFrame.Position.X.Scale,
    mainFrame.Position.X.Offset - 5,
    mainFrame.Position.Y.Scale,
    mainFrame.Position.Y.Offset - 5
)

-- === COLOR ANIMATION ===
local colorPalette = {
    Color3.fromRGB(170, 0, 255), Color3.fromRGB(120, 0, 255),
    Color3.fromRGB(0, 100, 255), Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(0, 255, 150), Color3.fromRGB(0, 255, 100),
    Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 50, 150)
}

local currentIndex = 1
local function animateToNextColor()
    local nextIndex = currentIndex % #colorPalette + 1
    TweenService:Create(uiStroke, TweenInfo.new(4, Enum.EasingStyle.Linear), {
        Color = colorPalette[nextIndex]
    }):Play()
    currentIndex = nextIndex
    wait(4)
    animateToNextColor()
end
coroutine.wrap(animateToNextColor)()

-- === GUI ELEMENTS ===
local topLabel = Instance.new("TextLabel")
topLabel.Size = UDim2.new(1, 0, 0, 20)
topLabel.Position = UDim2.new(0, 0, 0, 5)
topLabel.BackgroundTransparency = 1
topLabel.Text = "bb_tricks on discord"
topLabel.Font = Enum.Font.FredokaOne
topLabel.TextSize = 14
topLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
topLabel.Parent = mainFrame

local petNameLabel = Instance.new("TextLabel")
petNameLabel.Size = UDim2.new(0.6, 0, 0, 12)
petNameLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
petNameLabel.BackgroundTransparency = 1
petNameLabel.Text = "Pet Name To Add"
petNameLabel.Font = Enum.Font.FredokaOne
petNameLabel.TextSize = 8
petNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
petNameLabel.TextXAlignment = Enum.TextXAlignment.Left
petNameLabel.Parent = mainFrame

local petListBtn = Instance.new("TextButton")
petListBtn.Size = UDim2.new(0.3, 0, 0, 12)
petListBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
petListBtn.Text = "Pet list"
petListBtn.Font = Enum.Font.FredokaOne
petListBtn.TextSize = 8
petListBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
petListBtn.TextColor3 = Color3.fromRGB(215, 215, 255)
petListBtn.AutoButtonColor = true
petListBtn.Parent = mainFrame

local uiCornerList = Instance.new("UICorner")
uiCornerList.CornerRadius = UDim.new(0, 4)
uiCornerList.Parent = petListBtn

local petNameBox = Instance.new("TextBox")
petNameBox.Size = UDim2.new(0.9, 0, 0, 20)
petNameBox.Position = UDim2.new(0.05, 0, 0.22, 0)
petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
petNameBox.BackgroundTransparency = 0.2
petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.TextSize = 11
petNameBox.Font = Enum.Font.FredokaOne
petNameBox.PlaceholderText = "insert pet name"
petNameBox.Text = ""
petNameBox.ClearTextOnFocus = false
petNameBox.Parent = mainFrame

Instance.new("UICorner", petNameBox).CornerRadius = UDim.new(0, 6)

local boxStroke = Instance.new("UIStroke", petNameBox)
boxStroke.Color = Color3.new(0, 0, 0)
boxStroke.Thickness = 1.2
boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

local boxGlow = Instance.new("UIStroke", petNameBox)
boxGlow.Color = Color3.fromRGB(255, 255, 255)
boxGlow.Thickness = 2.2
boxGlow.Transparency = 0.25
boxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- === RANDOM PET BUTTON ===
local randomPetBtn = Instance.new("TextButton")
randomPetBtn.Size = UDim2.new(0.9, 0, 0, 18)
randomPetBtn.Position = UDim2.new(0.05, 0, 0.36, 0)
randomPetBtn.Text = "Pick Random Pet"
randomPetBtn.Font = Enum.Font.FredokaOne
randomPetBtn.TextSize = 10
randomPetBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
randomPetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
randomPetBtn.AutoButtonColor = true
randomPetBtn.Parent = mainFrame

Instance.new("UICorner", randomPetBtn).CornerRadius = UDim.new(0, 6)

-- === POTION BUTTONS ===
local activeFlags = {F = false, R = false, N = false, M = false}
local flagColors = {
    M = Color3.fromRGB(170, 0, 255),
    N = Color3.fromRGB(0, 255, 100),
    F = Color3.fromRGB(0, 200, 255),
    R = Color3.fromRGB(255, 50, 150)
}

local prefixes = {"F", "R", "N", "M"}

for i, prefix in ipairs(prefixes) do
    local prefixButton = Instance.new("TextButton")
    prefixButton.Size = UDim2.new(0.18, 0, 0, 18)
    prefixButton.Position = UDim2.new(0.05 + (i-1)*0.23, 0, 0.48, 0)
    prefixButton.Text = prefix
    prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    prefixButton.BackgroundTransparency = 0.2
    prefixButton.Font = Enum.Font.FredokaOne
    prefixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    prefixButton.TextSize = 12
    prefixButton.AutoButtonColor = true
    prefixButton.Parent = mainFrame

    Instance.new("UICorner", prefixButton).CornerRadius = UDim.new(0, 6)

    local buttonStroke = Instance.new("UIStroke", prefixButton)
    buttonStroke.Color = flagColors[prefix]
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.5
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local textStroke = Instance.new("UIStroke", prefixButton)
    textStroke.Color = Color3.new(0, 0, 0)
    textStroke.Thickness = 1.5
    textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    local originalStroke = {
        Color = flagColors[prefix],
        Thickness = 2,
        Transparency = 0.5
    }

    prefixButton.MouseButton1Click:Connect(function()
        if prefix == "M" and activeFlags["N"] then return end
        if prefix == "N" and activeFlags["M"] then return end

        activeFlags[prefix] = not activeFlags[prefix]

        if activeFlags[prefix] then
            prefixButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Color = Color3.fromRGB(0, 255, 0),
                Thickness = 3,
                Transparency = 0.2
            }):Play()
        else
            prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Color = originalStroke.Color,
                Thickness = originalStroke.Thickness,
                Transparency = originalStroke.Transparency
            }):Play()
        end
    end)
end

-- === INFO BOX ===
local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(0.9, 0, 0, 22)
infoBox.Position = UDim2.new(0.05, 0, 0.62, 0)
infoBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoBox.BackgroundTransparency = 0.5
infoBox.Parent = mainFrame

Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

local infoBoxStroke = Instance.new("UIStroke", infoBox)
infoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
infoBoxStroke.Thickness = 1.2
infoBoxStroke.Transparency = 0.7

local infoTextContainer = Instance.new("Frame", infoBox)
infoTextContainer.Size = UDim2.new(1, 0, 1, 0)
infoTextContainer.BackgroundTransparency = 1

local uiListLayout = Instance.new("UIListLayout", infoTextContainer)
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 4)

-- === INFO BOX UPDATE FUNCTION ===
local function updateInfoBox()
    for _, child in ipairs(infoTextContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if activeFlags["M"] then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = "Mega Neon"
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 10
        label.TextColor3 = flagColors.M
        label.Parent = infoTextContainer
    elseif activeFlags["N"] then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = "Neon"
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 10
        label.TextColor3 = flagColors.N
        label.Parent = infoTextContainer
    end
    
    if activeFlags["F"] then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = activeFlags["N"] or activeFlags["M"] and " Fly" or "Fly"
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 10
        label.TextColor3 = flagColors.F
        label.Parent = infoTextContainer
    end
    
    if activeFlags["R"] then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = (activeFlags["N"] or activeFlags["M"] or activeFlags["F"]) and " Ride" or "Ride"
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 10
        label.TextColor3 = flagColors.R
        label.Parent = infoTextContainer
    end
    
    if not (activeFlags["M"] or activeFlags["N"] or activeFlags["F"] or activeFlags["R"]) then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = "Normal"
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 10
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Parent = infoTextContainer
        infoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
        infoBoxStroke.Thickness = 1.2
        infoBoxStroke.Transparency = 0.7
    end
end

-- Initialize info box
updateInfoBox()

-- === SHOW DIALOG BUTTON ===
local dialogBtn = Instance.new("TextButton")
dialogBtn.Size = UDim2.new(0.9, 0, 0, 20)
dialogBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
dialogBtn.Text = "Show the dialog"
dialogBtn.Font = Enum.Font.FredokaOne
dialogBtn.TextSize = 11
dialogBtn.BackgroundColor3 = Color3.fromRGB(30, 105, 210)
dialogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogBtn.AutoButtonColor = true
dialogBtn.Parent = mainFrame

Instance.new("UICorner", dialogBtn).CornerRadius = UDim.new(0, 6)

-- === PET LIST POPUP ===
local petListFrame = Instance.new("Frame")
petListFrame.Size = UDim2.new(0, 200, 0, 220)
petListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
petListFrame.Visible = false
petListFrame.ZIndex = 100
petListFrame.Parent = screenGui

Instance.new("UICorner", petListFrame).CornerRadius = UDim.new(0, 8)

local petListStroke = Instance.new("UIStroke", petListFrame)
petListStroke.Color = Color3.fromRGB(110, 0, 255)
petListStroke.Thickness = 2
petListStroke.Parent = petListFrame

local petListScroll = Instance.new("ScrollingFrame")
petListScroll.Size = UDim2.new(1, -10, 1, -10)
petListScroll.Position = UDim2.new(0, 5, 0, 5)
petListScroll.BackgroundTransparency = 1
petListScroll.ScrollBarThickness = 6
petListScroll.CanvasSize = UDim2.new(0, 0, 0, #petNames * 20 + 10)
petListScroll.BorderSizePixel = 0
petListScroll.ZIndex = 101
petListScroll.Parent = petListFrame

local petListLayout = Instance.new("UIListLayout")
petListLayout.Padding = UDim.new(0, 2)
petListLayout.SortOrder = Enum.SortOrder.LayoutOrder
petListLayout.Parent = petListScroll

for i, pet in ipairs(petNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 18)
    btn.Text = pet
    btn.Font = Enum.Font.FredokaOne
    btn.TextSize = 10
    btn.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
    btn.TextColor3 = Color3.fromRGB(215, 215, 255)
    btn.LayoutOrder = i
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextTruncate = Enum.TextTruncate.None
    btn.AutoButtonColor = true
    btn.ZIndex = 102
    btn.Parent = petListScroll
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, 5)
    textPadding.PaddingRight = UDim.new(0, 5)
    textPadding.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        petNameBox.Text = pet
        petListFrame.Visible = false
    end)
end

local function updatePetListPosition()
    if petListFrame.Visible then
        local mfPos = mainFrame.AbsolutePosition
        local mfSize = mainFrame.AbsoluteSize
        petListFrame.Position = UDim2.new(0, mfPos.X + mfSize.X + 5, 0, mfPos.Y)
    end
end

petListBtn.MouseButton1Click:Connect(function()
    petListFrame.Visible = not petListFrame.Visible
    if petListFrame.Visible then
        updatePetListPosition()
    end
end)

mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    if petListFrame.Visible then
        updatePetListPosition()
    end
end)

-- === RANDOM PET FUNCTION ===
randomPetBtn.MouseButton1Click:Connect(function()
    local randomIndex = math.random(1, #petNames)
    local randomPet = petNames[randomIndex]
    petNameBox.Text = randomPet
    
    local randomOption = math.random(1, 3)
    
    for _, prefix in ipairs(prefixes) do
        activeFlags[prefix] = false
    end
    
    if randomOption == 1 then
        activeFlags["M"] = true
    elseif randomOption == 2 then
        activeFlags["N"] = true
    end
    
    updateInfoBox()
end)

-- === FIXED DIALOG FUNCTION ===
local function showPetDialog()
    local selectedPet = petNameBox.Text
    if selectedPet == "" or selectedPet == "insert pet name" then
        return
    end
    
    -- Load spawner system if not loaded
    if not spawnerSystemLoaded then
        loadSpawnerSystem()
        wait(0.5) -- Give time to load
    end
    
    -- Use game's DialogApp with proper thread identity
    local oldIdentity = set_thread_identity(2)
    
    local success, result = pcall(function()
        local Fsys = require(ReplicatedStorage:WaitForChild('Fsys'))
        local load = Fsys.load
        
        -- Get pet ID
        local petId
        if _G.GetPetByName then
            petId = _G.GetPetByName(selectedPet)
        else
            local InventoryDB = load('InventoryDB')
            for id, pet in pairs(InventoryDB.pets) do
                if pet.name:lower() == selectedPet:lower() then
                    petId = id
                    break
                end
            end
        end
        
        if not petId then
            return false
        end
        
        local items = load('KindDB')
        local petItemData = items[petId]
        
        local petProperties = {
            pet_trick_level = math.random(1, 5),
            neon = activeFlags["N"],
            mega_neon = activeFlags["M"],
            rideable = activeFlags["R"],
            flyable = activeFlags["F"],
            age = math.random(1, 900000),
            ailments_completed = 0,
            rp_name = ""
        }
        
        -- Use game's dialog system
        local UIManager = load('UIManager')
        local DialogApp = UIManager.apps.DialogApp
        
        if DialogApp and DialogApp.dialog then
            local response = DialogApp:dialog({
                dialog_type = "ItemPreviewDialog",
                text = "Are you sure you want to buy a: " .. selectedPet,
                item = {
                    id = petId,
                    name = selectedPet,
                    category = "pets",
                    kind = petItemData and petItemData.kind or "",
                    properties = petProperties
                },
                button = "Okay!",
                yields = true
            })
            
            if response == "Okay!" and _G.createPet then
                _G.createPet(petId, petProperties)
                return true
            end
        end
        
        return false
    end)
    
    set_thread_identity(oldIdentity)
    
    -- If game dialog failed, show simple message
    if not success or not result then
        -- Simple success message
        local messageGui = Instance.new("ScreenGui")
        messageGui.Name = "SuccessMessage"
        messageGui.ResetOnSpawn = false
        messageGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 100)
        frame.Position = UDim2.new(0.5, -100, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.BackgroundTransparency = 0.1
        frame.Parent = messageGui
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.9, 0, 0.6, 0)
        label.Position = UDim2.new(0.05, 0, 0.1, 0)
        label.Text = "Pet Spawned: " .. selectedPet
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 14
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.Parent = frame
        
        local okButton = Instance.new("TextButton")
        okButton.Size = UDim2.new(0.6, 0, 0.25, 0)
        okButton.Position = UDim2.new(0.2, 0, 0.65, 0)
        okButton.Text = "Okay!"
        okButton.Font = Enum.Font.FredokaOne
        okButton.TextSize = 12
        okButton.BackgroundColor3 = Color3.fromRGB(30, 105, 210)
        okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        okButton.AutoButtonColor = true
        okButton.Parent = frame
        
        Instance.new("UICorner", okButton).CornerRadius = UDim.new(0, 6)
        
        okButton.MouseButton1Click:Connect(function()
            messageGui:Destroy()
            if _G.createPet then
                local oldId = set_thread_identity(2)
                local InventoryDB = require(ReplicatedStorage:WaitForChild('Fsys')).load('InventoryDB')
                local petId
                for id, pet in pairs(InventoryDB.pets) do
                    if pet.name:lower() == selectedPet:lower() then
                        petId = id
                        break
                    end
                end
                
                if petId then
                    local petProperties = {
                        pet_trick_level = math.random(1, 5),
                        neon = activeFlags["N"],
                        mega_neon = activeFlags["M"],
                        rideable = activeFlags["R"],
                        flyable = activeFlags["F"],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = ""
                    }
                    _G.createPet(petId, petProperties)
                end
                set_thread_identity(oldId)
            end
        end)
        
        -- Auto-remove after 5 seconds
        task.delay(5, function()
            if messageGui then
                messageGui:Destroy()
            end
        end)
    end
end

dialogBtn.MouseButton1Click:Connect(showPetDialog)

-- === DRAGGABLE GUI ===
local dragging, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close pet list when clicking outside
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and petListFrame.Visible then
        local mousePos = input.Position
        local listAbsPos = petListFrame.AbsolutePosition
        local listSize = petListFrame.AbsoluteSize
        local mainAbsPos = mainFrame.AbsolutePosition
        local mainSize = mainFrame.AbsoluteSize
        
        local isInPetList = (mousePos.X >= listAbsPos.X and mousePos.X <= listAbsPos.X + listSize.X and
                            mousePos.Y >= listAbsPos.Y and mousePos.Y <= listAbsPos.Y + listSize.Y)
        
        local isInMainFrame = (mousePos.X >= mainAbsPos.X and mousePos.X <= mainAbsPos.X + mainSize.X and
                              mousePos.Y >= mainAbsPos.Y and mousePos.Y <= mainAbsPos.Y + mainSize.Y)
        
        if not isInPetList and not isInMainFrame then
            petListFrame.Visible = false
        end
    end
end)

-- Auto-start spawner system
task.spawn(function()
    wait(1)
    loadSpawnerSystem()
end)


	end)
end)

-- SCRIPT 2
btn2.MouseButton1Click:Connect(function()
	task.spawn(function()

-- paste pet spawner + fake trade script here

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local Chat = game:GetService('Chat')

pcall(function()
    setthreadidentity(2)
end)

-- COMPREHENSIVE HOOKS FOR FAKE PLAYERS - MUST BE FIRST
local fakePlayerIds = {}
_G.fakePlayerIds = fakePlayerIds

-- Hook SettingsHelper early with better fake player detection
task.spawn(function()
    task.wait(0.1) -- Small delay to ensure modules are loaded
    local SettingsHelper =
        require(ReplicatedStorage:WaitForChild('Fsys')).load('SettingsHelper')
    local original_get_setting_server = SettingsHelper.get_setting_server

    SettingsHelper.get_setting_server = function(player, settingName, ...)
        -- Multiple checks to identify fake players
        if player and player.UserId then
            -- Check 1: Direct ID match
            if fakePlayerIds[player.UserId] then
                return false
            end

            -- Check 2: Player not in Players service
            if not Players:GetPlayerByUserId(player.UserId) then
                return false
            end
        end

        -- Only call original for real players
        local args = { ... }
        local success, result = pcall(function()
            return original_get_setting_server(
                player,
                settingName,
                table.unpack(args)
            )
        end)

        if success then
            return result
        else
            -- If error happens, assume it's a fake player and return safe default
            return false
        end
    end
end)

-- Hook FamilyHelper early
task.spawn(function()
    task.wait(0.1) -- Small delay to ensure modules are loaded
    local FamilyHelper =
        require(ReplicatedStorage:WaitForChild('Fsys')).load('FamilyHelper')

    local original_are_friends_family = FamilyHelper.are_friends_family
    local original_is_my_friend_or_family = FamilyHelper.is_my_friend_or_family
    local original_are_family_because_friends =
        FamilyHelper.are_family_because_friends
    local original_is_my_family_because_friend =
        FamilyHelper.is_my_family_because_friend

    FamilyHelper.are_friends_family = function(player1, player2)
        if
            player1
            and player2
            and (fakePlayerIds[player1.UserId] or fakePlayerIds[player2.UserId])
        then
            return false
        end
        return original_are_friends_family(player1, player2)
    end

    FamilyHelper.is_my_friend_or_family = function(player)
        if player and fakePlayerIds[player.UserId] then
            return false
        end
        return original_is_my_friend_or_family(player)
    end

    FamilyHelper.are_family_because_friends = function(player1, player2)
        if
            player1
            and player2
            and (fakePlayerIds[player1.UserId] or fakePlayerIds[player2.UserId])
        then
            return false
        end
        return original_are_family_because_friends(player1, player2)
    end

    FamilyHelper.is_my_family_because_friend = function(player)
        if player and fakePlayerIds[player.UserId] then
            return false
        end
        return original_is_my_family_because_friend(player)
    end
end)

local Fsys = require(ReplicatedStorage:WaitForChild('Fsys'))
local load = Fsys.load
local UIManager = load('UIManager')
local ClientData = load('ClientData')
local TableUtil = load('TableUtil')
local RouterClient = load('RouterClient')
local InventoryDB = load('InventoryDB')
local animationManager = load('AnimationManager')
local ColorThemeManager = load('ColorThemeManager')

if UIManager.wait_for_initialization then
    UIManager:wait_for_initialization()
else
    task.wait(2)
end

local TradeApp = UIManager.apps.TradeApp
local BackpackApp = UIManager.apps.BackpackApp
local DialogApp = UIManager.apps.DialogApp
local HintApp = UIManager.apps.HintApp
local SettingsApp = UIManager.apps.SettingsApp
local PlayerProfileApp = UIManager.apps.PlayerProfileApp
local TradeHistoryApp = UIManager.apps.TradeHistoryApp
local TradePreviewApp = UIManager.apps.TradePreviewApp

local NegotiationFrame =
    Players.LocalPlayer.PlayerGui.TradeApp.Frame.NegotiationFrame
local function FriendHighlight(FriendValue)
    NegotiationFrame.FriendHighlight.Visible = FriendValue
    NegotiationFrame.FriendBorder.Visible = FriendValue
    local PartnerFrame = NegotiationFrame.Header.PartnerFrame
    NegotiationFrame.Header.PartnerFrame.NameLabel.FriendLabel.Visible =
        FriendValue
    local ColorThemeManagerColor =
        ColorThemeManager.lookup(FriendValue and 'background' or 'saturated')
    NegotiationFrame.Header.PartnerFrame.ProfileIcon.ImageColor3 =
        ColorThemeManagerColor
    NegotiationFrame.Header.PartnerFrame.NameLabel.TextColor3 =
        ColorThemeManagerColor
    NegotiationFrame.Header.PartnerFrame.Icon.Visible = FriendValue
    NegotiationFrame.Header.PartnerFrame.Icon.Image =
        'rbxassetid://84667805159408'
end

local downloader = load('DownloadClient')
local petModels = {}

local function getPetModel(kind)
    if petModels[kind] then
        return petModels[kind]:Clone()
    end

    local success, streamed = pcall(function()
        local promise = downloader.promise_download_copy('Pets', kind)
        if promise then
            return promise:expect()
        end
        return nil
    end)

    if success and streamed then
        petModels[kind] = streamed
        return streamed:Clone()
    else
        warn('Failed to download pet model for:', kind)
        return nil
    end
end

if not TradeApp then
    return
end

local CONFIG = {
    PARTNER_NAME = 'SurenArmen',
    PARTNER_USER_ID = 987654321,
    AUTO_ACCEPT_DELAY = 0.5,
    AUTO_CONFIRM_DELAY = 0.3,
    SPECTATOR_COUNT = 0,
    AUTO_PARTNER = true,
    NEGOTIATION_LOCK = 5,
    CONFIRMATION_LOCK_PER_ITEM = 3,
    SHOW_TRADE_REQUEST = true,
    TRADE_REQUEST_DELAY = 1,
    ADD_PET_REQUEST_DELAY = 1.6,
    SPAWN_FAKE_PLAYER_WITH_RANDOM_PET = false,
    FAKE_PLAYER_ACCEPT_TRADE_REQUEST = 2,
    CHAT_MESSAGES = {
        'Can i spin this',
        'Win or lose',
        'I am followed btw',
        'Can you add',
        'add more',
        'add',
        'Did I win?',
        'Which one can I spin',
        'Omg Its real Thank you so much',
        'I am a big fan pls pet',
        'Can i still get gift pls?',
        'Can I get a free pet please?',
        'I love youre lives btw!',
        'Lose?',
        'Win?',
        'Thanks!',
        'Okay thank you so much for giving back.',
        'Yes',
        'Thanks',
        'How is youre day so far',
        'Yes can i please spin this',
        'Which one should i spin',
        'Which one you wanna spin',
        'hello',
        'Can you offer for my pet',
        'Can you add a lot more',
        'THANKS YOU SO MUCH UR TRUSTED',
        'Yes bro',
        'I got scammed ',
        'YOURE LEGIT',
        'Can i please spin this bro',
        'Can I think abt the offer',
        'Thank u so much',
        'Can I have have a pet since ur doing giveaway',
        'pet pls',
        'Yes i am followed',
        'Im watching youre live bro',
        'can i enter the giveaway',
    },
    AUTO_CHAT_DELAY = 2,
    VERIFIED_FRIENDS = {
        'Agusmareborn',
        'Kellyvault',
        'J3llynoah',
        'Rainbowriley321',
        'Bobazmalibu',
        'H3llSANG3LX',
        'Xcallmeholly',
        'Niniko_201999',
    },
    SHOW_VERIFIED_FRIEND = false,
}

local mockState = {
    active = false,
    trade = nil,
    isAddingItem = false,
    partnerActionPending = false,
    originalFunctions = {},
    controlPanelOpen = false,
    tradeCompleting = false,
    scamWarningShown = true,
    originalDialogFunction = nil,
    blockedTradeRequests = {},
    tradeHistory = {},
    addedTradeIds = {},
    pendingTradeRequest = false,
    canShowTradeRequest = true,
    tradeRequestBlocked = false,
}

local petSpawnState = {
    activeFlags = { F = false, R = false, N = false, M = false },
    validPetNames = {},
    validPetNamesClean = {},
}

-- Define pet rarity tiers (Balloon Unicorn and above)
local highValuePets = {
    'Shadow Dragon',
    'Bat Dragon',
    'Frost Dragon',
    'Giraffe',
    'Owl',
    'Parrot',
    'Crow',
    'Evil Unicorn',
    'Balloon Unicorn',
}

local completePetList = {
    'Shadow Dragon',
    'Bat Dragon',
    'Frost Dragon',
    'Giraffe',
    'Owl',
    'Parrot',
    'Crow',
    'Evil Unicorn',
    'Arctic Reindeer',
    'Hedgehog',
    'Dalmatian',
    'Turtle',
    'Kangaroo',
    'Lion',
    'Elephant',
    'Rhino',
    'Chocolate Chip Bat Dragon',
    'Cow',
    'Blazing Lion',
    'African Wild Dog',
    'Flamingo',
    'Diamond Butterfly',
    'Mini Pig',
    'Caterpillar',
    'Albino Monkey',
    'Candyfloss Chick',
    'Pelican',
    'Blue Dog',
    'Pink Cat',
    'Haetae',
    'Peppermint Penguin',
    'Winged Tiger',
    'Sugar Glider',
    'Shark Puppy',
    'Goat',
    'Sheeeeep',
    'Lion Cub',
    'Nessie',
    'Flamingo',
    'Frostbite Bear',
    'Balloon Unicorn',
    'Honey Badger',
    'Hot Doggo',
    'Crocodile',
    'Hare',
    'Ram',
    'Yeti',
    'Meetkat',
    'Jellyfish',
    'Happy Clown',
    'Orchid Butterfly',
    'Many Mackerel',
    'Strawberry Shortcake Bat Dragon',
    'Zombie Buffalo',
    'Fairy Bat Dragon',
}

-- Function to check if a pet is Balloon Unicorn or higher rarity
local function isPetAboveBalloonUnicorn(petName)
    for _, highValuePet in ipairs(highValuePets) do
        if petName == highValuePet then
            return true
        end
    end
    return false
end

-- Function to get a random pet that's Balloon Unicorn or higher
local function getRandomHighValuePet()
    return highValuePets[math.random(1, #highValuePets)]
end

local function loadPetNames()
    for category_name, category_table in pairs(InventoryDB) do
        if category_name == 'pets' then
            for id, item in pairs(category_table) do
                petSpawnState.validPetNames[#petSpawnState.validPetNames + 1] =
                    item.name
                petSpawnState.validPetNamesClean[#petSpawnState.validPetNamesClean + 1] =
                    item.name:lower():gsub('%s+', '')
            end
            break
        end
    end
end
loadPetNames()

local function checkTradeLicense(player)
    if not player then
        return false
    end

    local success, hasLicense = pcall(function()
        if TradeApp and TradeApp._check_if_player_has_trade_license then
            return TradeApp:_check_if_player_has_trade_license(player)
        end

        local RouterClient = load('RouterClient')
        if RouterClient then
            local result = RouterClient.get('TradeAPI/GetTradeLicenseStatus')
                :InvokeServer(player.UserId)
            return result and result.has_license == true
        end

        return true
    end)

    return success and hasLicense or true
end

local function isVerifiedFriend(username)
    for _, friendName in ipairs(CONFIG.VERIFIED_FRIENDS) do
        if friendName:lower() == username:lower() then
            return true
        end
    end
    return false
end

local function storeOriginalFunctions()
    local funcs = {
        '_get_local_trade_state',
        '_overwrite_local_trade_state',
        '_change_local_trade_state',
        '_get_my_offer',
        '_get_partner_offer',
        '_get_my_player',
        '_get_partner',
        '_get_current_trade_stage',
        '_on_accept_pressed',
        '_on_confirm_pressed',
        '_on_unaccept_pressed',
        '_decline_trade',
        '_add_item_to_my_offer',
        '_remove_item_from_my_offer',
        '_lock_trade_for_appropriate_time',
        '_get_lock_time',
        'refresh_all',
        '_evaluate_trade_fairness',
        '_show_scam_victim_warning',
        '_show_scam_perpetrator_warning',
    }

    for _, funcName in ipairs(funcs) do
        if TradeApp[funcName] then
            mockState.originalFunctions[funcName] = TradeApp[funcName]
        end
    end

    if TradeHistoryApp then
        if TradeHistoryApp._get_trade_history then
            mockState.originalGetTradeHistory =
                TradeHistoryApp._get_trade_history
        end
        if TradeHistoryApp.report_scam then
            mockState.originalReportScam = TradeHistoryApp.report_scam
        end
    end
end

storeOriginalFunctions()

local function createMockPartner(player)
    return setmetatable({
        Name = player and player.Name or CONFIG.PARTNER_NAME,
        DisplayName = player and player.DisplayName or CONFIG.PARTNER_NAME,
        UserId = player and player.UserId or CONFIG.PARTNER_USER_ID,
    }, {
        __index = function(t, k)
            if k == 'Parent' then
                return Players
            end
            if k == 'IsA' then
                return function(self, className)
                    return className == 'Player'
                end
            end
            return rawget(t, k)
        end,
        __tostring = function()
            return player and player.Name or CONFIG.PARTNER_NAME
        end,
    })
end

local mockPartner = createMockPartner()

local function createMockTrade(realPlayer)
    local partner = realPlayer and createMockPartner(realPlayer) or mockPartner

    local hasLicense = true
    if realPlayer then
        hasLicense = checkTradeLicense(realPlayer)
    end

    return {
        trade_id = 'MOCK_' .. tick(),
        sender = Players.LocalPlayer,
        recipient = partner,
        sender_offer = {
            items = {},
            player_name = Players.LocalPlayer.Name,
            negotiated = false,
            confirmed = false,
        },
        recipient_offer = {
            items = {},
            player_name = CONFIG.PARTNER_NAME,
            negotiated = false,
            confirmed = false,
        },
        current_stage = 'negotiation',
        offer_version = 1,
        sender_has_trade_license = true,
        recipient_has_trade_license = hasLicense,
        busy_indicators = {},
        subscriber_count = CONFIG.SPECTATOR_COUNT,
    }
end

local function createTradeHistoryRecord(trade)
    local record = {
        trade_id = trade.trade_id,
        timestamp = os.time(),
        sender_user_id = Players.LocalPlayer.UserId,
        sender_name = Players.LocalPlayer.Name,
        sender_items = TableUtil.deep_copy(trade.sender_offer.items),
        recipient_user_id = trade.recipient.UserId,
        recipient_name = CONFIG.PARTNER_NAME,
        recipient_items = TableUtil.deep_copy(trade.recipient_offer.items),
        reported = false,
        reverted = nil,
    }
    return record
end

local function appendToTradeHistory(tradeRecord)
    if mockState.addedTradeIds[tradeRecord.trade_id] then
        return
    end

    mockState.addedTradeIds[tradeRecord.trade_id] = true
    table.insert(mockState.tradeHistory, tradeRecord)
end

local function hookTradeHistoryFunctions()
    if not TradeHistoryApp then
        return
    end

    TradeHistoryApp._get_trade_history = function(self, useCache)
        local history = mockState.originalGetTradeHistory(self, useCache)

        local combined = {}
        local seenIds = {}

        if history then
            for _, realTrade in ipairs(history) do
                if not seenIds[realTrade.trade_id] then
                    table.insert(combined, realTrade)
                    seenIds[realTrade.trade_id] = true
                end
            end
        end

        for _, mockTrade in ipairs(mockState.tradeHistory) do
            if not seenIds[mockTrade.trade_id] then
                table.insert(combined, mockTrade)
                seenIds[mockTrade.trade_id] = true
            end
        end

        self.cached_trade_history = combined
        return combined
    end

    TradeHistoryApp.report_scam = function(self, tradeData)
        if tradeData and string.find(tostring(tradeData.trade_id), 'MOCK_') then
            self.UIManager.set_app_visibility(self.ClassName, false)

            local success, response1, response2, response3 = pcall(function()
                return self.UIManager.apps.DialogApp:dialog({
                    dialog_type = 'ReportScamDialog',
                    suspect_name = CONFIG.PARTNER_NAME,
                    placeholder_text = 'What happened? (Optional)',
                    max_length = 500,
                    use_utf8_length = true,
                    left = 'Cancel',
                    right = 'Report',
                })
            end)

            self.UIManager.set_app_visibility(self.ClassName, true)

            if success and response1 == 'Report' then
                for _, record in ipairs(mockState.tradeHistory) do
                    if record.trade_id == tradeData.trade_id then
                        record.reported = true
                        break
                    end
                end

                pcall(function()
                    self.UIManager.apps.DialogApp:dialog({
                        text = 'Report submitted for review.',
                        button = 'Close',
                        yields = false,
                    })
                end)
            end

            if self.instance.Frame.Visible then
                self:_refresh()
            else
                self:_clear_scrolling_frame()
            end

            return
        end

        return mockState.originalReportScam(self, tradeData)
    end
end

hookTradeHistoryFunctions()

local function update_busy_indicators(args1)
    local v144 = mockState.trade.busy_indicators
    local v145 = TradeApp._get_partner().UserId
    v144[tostring(v145)] = args1
    TradeApp.partner_negotiation_offer_pane:display_busy(v144[tostring(v145)])
end

local function addPetToPartnerOffer(petName, flags)
    if not mockState.active or not mockState.trade then
        return false, 'No active mock trade'
    end

    if mockState.trade.current_stage == 'confirmation' then
        return false, 'Cannot modify during confirmation'
    end

    if #mockState.trade.recipient_offer.items >= 18 then
        return
    end

    update_busy_indicators({
        ['picking'] = true,
    })

    task.wait(CONFIG.ADD_PET_REQUEST_DELAY)

    for category_name, category_table in pairs(InventoryDB) do
        if category_name == 'pets' then
            for id, item in pairs(category_table) do
                if item.name == petName then
                    local fake_uuid = game:GetService('HttpService')
                        :GenerateGUID()
                    local petItem = {
                        category = 'pets',
                        kind = id,
                        unique = fake_uuid,
                        properties = {
                            flyable = flags.F,
                            rideable = flags.R,
                            neon = flags.N,
                            mega_neon = flags.M,
                            age = 1,
                        },
                    }

                    table.insert(mockState.trade.recipient_offer.items, petItem)

                    mockState.trade.sender_offer.negotiated = false
                    mockState.trade.recipient_offer.negotiated = false

                    if mockState.trade.current_stage == 'confirmation' then
                        mockState.trade.current_stage = 'negotiation'
                        mockState.trade.sender_offer.confirmed = false
                        mockState.trade.recipient_offer.confirmed = false
                    end

                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    TradeApp:_overwrite_local_trade_state(mockState.trade)

                    if TradeApp._lock_trade_for_appropriate_time then
                        TradeApp:_lock_trade_for_appropriate_time()
                    end

                    if TradeApp._render_message_in_trade_chat then
                        TradeApp:_render_message_in_trade_chat(
                            nil,
                            string.format(
                                '%s added %s.',
                                CONFIG.PARTNER_NAME,
                                petName
                            ),
                            true
                        )
                    end

                    update_busy_indicators({
                        ['picking'] = false,
                    })
                    return true, 'Pet added successfully'
                end
            end
        end
    end

    return false, 'Pet not found'
end

local function removeLatestPetFromPartnerOffer()
    if not mockState.active or not mockState.trade then
        return false, 'No active mock trade'
    end

    if mockState.trade.current_stage == 'confirmation' then
        return false, 'Cannot modify during confirmation'
    end

    local partnerItems = mockState.trade.recipient_offer.items
    if #partnerItems == 0 then
        return false, 'No items to remove'
    end

    local removedItem = table.remove(partnerItems)

    mockState.trade.sender_offer.negotiated = false
    mockState.trade.recipient_offer.negotiated = false

    if mockState.trade.current_stage == 'confirmation' then
        mockState.trade.current_stage = 'negotiation'
        mockState.trade.sender_offer.confirmed = false
        mockState.trade.recipient_offer.confirmed = false
    end

    mockState.trade.offer_version = mockState.trade.offer_version + 1
    TradeApp:_overwrite_local_trade_state(mockState.trade)

    if TradeApp._lock_trade_for_appropriate_time then
        TradeApp:_lock_trade_for_appropriate_time()
    end

    if TradeApp._render_message_in_trade_chat then
        local itemName = 'item'
        if removedItem.category == 'pets' then
            for category_name, category_table in pairs(InventoryDB) do
                if category_name == 'pets' then
                    for id, item in pairs(category_table) do
                        if id == removedItem.kind then
                            itemName = item.name
                            break
                        end
                    end
                    break
                end
            end
        end

        TradeApp:_render_message_in_trade_chat(
            nil,
            string.format('%s removed %s.', CONFIG.PARTNER_NAME, itemName),
            true
        )
    end

    return true, 'Pet removed successfully'
end

local function generateRandomPetProperties()
    local petTypes = { 'FR', 'NFR' }
    local chosenType = petTypes[math.random(1, #petTypes)]

    local properties = { F = false, R = false, N = false }

    if chosenType == 'FR' then
        properties.F = true
        properties.R = true
    elseif chosenType == 'NFR' then
        properties.F = true
        properties.R = true
        properties.N = true
    end

    return properties
end

local function getPropertiesString(properties)
    local props = {}
    if properties.M then
        table.insert(props, 'Mega')
    end
    if properties.N then
        table.insert(props, 'Neon')
    end
    if properties.F then
        table.insert(props, 'Fly')
    end
    if properties.R then
        table.insert(props, 'Ride')
    end

    if #props > 0 then
        return ' (' .. table.concat(props, ' ') .. ')'
    end
    return ''
end

local function sendTradeChatMessage(message)
    if not mockState.active or not mockState.trade then
        return false
    end

    if TradeApp and TradeApp._render_message_in_trade_chat then
        -- Use Rich Text formatting to make username bold
        local boldUsername = string.format('<b>%s</b>', CONFIG.PARTNER_NAME)
        local formattedMessage = string.format('%s: %s', boldUsername, message)

        TradeApp:_render_message_in_trade_chat(nil, formattedMessage, true)
        return true
    end

    return false
end

local function partnerAutoAction()
    if
        not mockState.active
        or not mockState.trade
        or mockState.partnerActionPending
    then
        return
    end

    mockState.partnerActionPending = true

    while
        TradeApp.lock_countdown
        and TradeApp.lock_countdown.is_going
        and TradeApp.lock_countdown:is_going()
    do
        task.wait(0.1)
    end

    if mockState.trade.current_stage == 'negotiation' then
        task.wait(CONFIG.AUTO_ACCEPT_DELAY)

        if mockState.active and mockState.trade then
            mockState.trade.recipient_offer.negotiated = true

            if mockState.trade.sender_offer.negotiated then
                mockState.trade.current_stage = 'confirmation'
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                TradeApp:_overwrite_local_trade_state(mockState.trade)

                if TradeApp._evaluate_trade_fairness then
                    TradeApp:_evaluate_trade_fairness()
                end

                if TradeApp._lock_trade_for_appropriate_time then
                    TradeApp:_lock_trade_for_appropriate_time()
                end
            else
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                TradeApp:_overwrite_local_trade_state(mockState.trade)
            end
        end
    elseif mockState.trade.current_stage == 'confirmation' then
        task.wait(CONFIG.AUTO_CONFIRM_DELAY)

        if mockState.active and mockState.trade then
            mockState.trade.recipient_offer.confirmed = true
            mockState.trade.offer_version = mockState.trade.offer_version + 1

            TradeApp:_overwrite_local_trade_state(mockState.trade)

            if
                mockState.trade.sender_offer.confirmed
                and not mockState.tradeCompleting
            then
                mockState.tradeCompleting = true

                if TradeApp._set_confirmation_arrow_rotating then
                    TradeApp:_set_confirmation_arrow_rotating(true)
                end

                task.wait(3)

                local historyRecord = createTradeHistoryRecord(mockState.trade)
                appendToTradeHistory(historyRecord)

                mockState.active = false
                mockState.trade = nil
                mockState.tradeCompleting = false
                mockState.scamWarningShown = true
                mockState.canShowTradeRequest = true
                mockState.tradeRequestBlocked = false
                UIManager.set_app_visibility('TradeApp', false)

                task.wait(0.1)

                showBlockedTradeRequests()

                if HintApp then
                    HintApp:hint({
                        text = 'The trade was successful!',
                        length = 5,
                        overridable = true,
                    })
                end

                if
                    TradeHistoryApp and UIManager.is_visible('TradeHistoryApp')
                then
                    TradeHistoryApp:_refresh()
                end
            end
        end
    end

    mockState.partnerActionPending = false
end

local function hookTradeFunctions()
    TradeApp._get_local_trade_state = function(self)
        if mockState.active and mockState.trade then
            return TableUtil.deep_copy(mockState.trade)
        end
        return mockState.originalFunctions._get_local_trade_state(self)
    end

    TradeApp._overwrite_local_trade_state = function(self, newState)
        if mockState.active then
            if newState then
                mockState.trade = newState
                self.local_trade_state = newState

                if mockState.trade then
                    mockState.trade.subscriber_count = CONFIG.SPECTATOR_COUNT
                end

                if self._on_local_trade_state_changed then
                    self:_on_local_trade_state_changed(newState, newState)
                end

                if self.refresh_all then
                    self:refresh_all()
                    FriendHighlight(true)
                end
            else
                mockState.trade = nil
                mockState.active = false
                mockState.scamWarningShown = false
                mockState.canShowTradeRequest = true
                mockState.tradeRequestBlocked = false
                self.local_trade_state = nil

                showBlockedTradeRequests()
            end
        else
            return mockState.originalFunctions._overwrite_local_trade_state(
                self,
                newState
            )
        end
    end

    TradeApp._get_my_offer = function(self)
        local state = self:_get_local_trade_state()
        if mockState.active and state then
            if game.Players.LocalPlayer == state.sender then
                return state.sender_offer, 'sender_offer'
            else
                return state.recipient_offer, 'recipient_offer'
            end
        end
        return mockState.originalFunctions._get_my_offer(self)
    end

    TradeApp._get_partner_offer = function(self)
        local state = self:_get_local_trade_state()
        if mockState.active and state then
            if game.Players.LocalPlayer == state.sender then
                return state.recipient_offer, 'recipient_offer'
            else
                return state.sender_offer, 'sender_offer'
            end
        end
        return mockState.originalFunctions._get_partner_offer(self)
    end

    TradeApp._get_my_player = function(self)
        if mockState.active and mockState.trade then
            return game.Players.LocalPlayer
        end
        return mockState.originalFunctions._get_my_player(self)
    end

    TradeApp._get_partner = function(self)
        if mockState.active and mockState.trade then
            return mockState.trade.recipient
        end
        return mockState.originalFunctions._get_partner(self)
    end

    TradeApp._get_current_trade_stage = function(self)
        if mockState.active and mockState.trade then
            return mockState.trade.current_stage
        end
        return mockState.originalFunctions._get_current_trade_stage(self)
    end

    TradeApp._change_local_trade_state = function(self, changes)
        if mockState.active then
            local function recursiveMerge(target, source)
                for k, v in pairs(source) do
                    if
                        type(v) == 'table'
                        and target[k]
                        and type(target[k]) == 'table'
                    then
                        recursiveMerge(target[k], v)
                    else
                        target[k] = v
                    end
                end
                return target
            end

            self:_overwrite_local_trade_state(
                recursiveMerge(self:_get_local_trade_state(), changes)
            )
        else
            return mockState.originalFunctions._change_local_trade_state(
                self,
                changes
            )
        end
    end

    TradeApp._get_lock_time = function(self)
        if mockState.active and mockState.trade then
            if self:_get_current_trade_stage() == 'negotiation' then
                return CONFIG.NEGOTIATION_LOCK
            else
                local itemCount = #mockState.trade.sender_offer.items
                    + #mockState.trade.recipient_offer.items
                return math.clamp(
                    CONFIG.CONFIRMATION_LOCK_PER_ITEM * itemCount,
                    5,
                    15
                )
            end
        end
        return mockState.originalFunctions._get_lock_time(self)
    end

    TradeApp._lock_trade_for_appropriate_time = function(self)
        if mockState.active then
            if self.lock_countdown then
                self.lock_countdown:stop()
                self.lock_countdown:set_duration(self:_get_lock_time())
                self.lock_countdown:start()
            end
        else
            return mockState.originalFunctions._lock_trade_for_appropriate_time(
                self
            )
        end
    end

    TradeApp._add_item_to_my_offer = function(self)
        if mockState.active and mockState.trade then
            if mockState.isAddingItem then
                return
            end

            mockState.isAddingItem = true

            local pickedItem = BackpackApp:pick_item({
                keep_cached_scroll_positions_on_open = true,
                allow_callback = function(item)
                    return true
                end,
            })

            if pickedItem then
                local alreadyInTrade = false
                for _, item in ipairs(mockState.trade.sender_offer.items) do
                    if item.unique == pickedItem.unique then
                        alreadyInTrade = true
                        break
                    end
                end

                if not alreadyInTrade then
                    table.insert(mockState.trade.sender_offer.items, pickedItem)

                    mockState.trade.sender_offer.negotiated = false
                    mockState.trade.recipient_offer.negotiated = false

                    if mockState.trade.current_stage == 'confirmation' then
                        mockState.trade.current_stage = 'negotiation'
                        mockState.trade.sender_offer.confirmed = false
                        mockState.trade.recipient_offer.confirmed = false
                    end

                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    self:_overwrite_local_trade_state(mockState.trade)

                    self:_lock_trade_for_appropriate_time()

                    if BackpackApp.set_item_unique_hidden then
                        BackpackApp:set_item_unique_hidden(
                            pickedItem.unique,
                            'TradeApp'
                        )
                    end
                end
            end

            mockState.isAddingItem = false
        else
            return mockState.originalFunctions._add_item_to_my_offer(self)
        end
    end

    TradeApp._remove_item_from_my_offer = function(self, item)
        if mockState.active and mockState.trade then
            for i, v in ipairs(mockState.trade.sender_offer.items) do
                if v.unique == item.unique then
                    table.remove(mockState.trade.sender_offer.items, i)

                    mockState.trade.sender_offer.negotiated = false
                    mockState.trade.recipient_offer.negotiated = false

                    if mockState.trade.current_stage == 'confirmation' then
                        mockState.trade.current_stage = 'negotiation'
                        mockState.trade.sender_offer.confirmed = false
                        mockState.trade.recipient_offer.confirmed = false
                    end

                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    self:_overwrite_local_trade_state(mockState.trade)

                    if self._lock_trade_for_appropriate_time then
                        self:_lock_trade_for_appropriate_time()
                    end

                    if BackpackApp.reset_hidden_item_tag then
                        BackpackApp:reset_hidden_item_tag('TradeApp')
                    end

                    break
                end
            end
        else
            return mockState.originalFunctions._remove_item_from_my_offer(
                self,
                item
            )
        end
    end

    TradeApp._on_accept_pressed = function(self)
        if mockState.active and mockState.trade then
            if mockState.trade.sender_offer.negotiated then
                mockState.trade.sender_offer.negotiated = false
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                self:_overwrite_local_trade_state(mockState.trade)
            else
                mockState.trade.sender_offer.negotiated = true

                if mockState.trade.recipient_offer.negotiated then
                    mockState.trade.current_stage = 'confirmation'
                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    self:_overwrite_local_trade_state(mockState.trade)

                    if TradeApp._evaluate_trade_fairness then
                        TradeApp:_evaluate_trade_fairness()
                    end

                    if TradeApp._lock_trade_for_appropriate_time then
                        TradeApp:_lock_trade_for_appropriate_time()
                    end
                else
                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    self:_overwrite_local_trade_state(mockState.trade)
                end
            end

            if
                CONFIG.AUTO_PARTNER
                and not mockState.trade.recipient_offer.negotiated
                and mockState.trade.sender_offer.negotiated
            then
                task.spawn(partnerAutoAction)
            end
        else
            return mockState.originalFunctions._on_accept_pressed(self)
        end
    end

    TradeApp._on_confirm_pressed = function(self)
        if mockState.active and mockState.trade then
            mockState.trade.sender_offer.confirmed = true
            mockState.trade.offer_version = mockState.trade.offer_version + 1

            self:_overwrite_local_trade_state(mockState.trade)

            if
                CONFIG.AUTO_PARTNER
                and not mockState.trade.recipient_offer.confirmed
            then
                task.spawn(partnerAutoAction)
            end
        else
            return mockState.originalFunctions._on_confirm_pressed(self)
        end
    end

    TradeApp._on_unaccept_pressed = function(self)
        if mockState.active and mockState.trade then
            mockState.trade.sender_offer.negotiated = false

            if mockState.trade.current_stage == 'confirmation' then
                mockState.trade.current_stage = 'negotiation'
                mockState.trade.recipient_offer.negotiated = false
                mockState.trade.sender_offer.confirmed = false
                mockState.trade.recipient_offer.confirmed = false
            end
            mockState.trade.offer_version = mockState.trade.offer_version + 1
            self:_overwrite_local_trade_state(mockState.trade)
        else
            return mockState.originalFunctions._on_unaccept_pressed(self)
        end
    end

    TradeApp._decline_trade = function(self, silent)
        if mockState.active then
            if self.lock_countdown then
                self.lock_countdown:stop()
            end
            mockState.active = false
            mockState.trade = nil
            mockState.isAddingItem = false
            mockState.partnerActionPending = false
            mockState.tradeCompleting = false
            mockState.scamWarningShown = false
            mockState.canShowTradeRequest = true
            mockState.tradeRequestBlocked = false

            self:_overwrite_local_trade_state(nil)
            UIManager.set_app_visibility('TradeApp', false)

            if BackpackApp.reset_hidden_item_tag then
                BackpackApp:reset_hidden_item_tag('TradeApp')
            end

            showBlockedTradeRequests()
        else
            return mockState.originalFunctions._decline_trade(self, silent)
        end
    end

    TradeApp._evaluate_trade_fairness = function(self)
        if
            mockState.active
            and mockState.trade
            and not mockState.scamWarningShown
        then
            local myItems = #mockState.trade.sender_offer.items
            local partnerItems = #mockState.trade.recipient_offer.items

            if myItems > 0 and partnerItems == 0 then
                mockState.scamWarningShown = true

                if DialogApp then
                    pcall(function()
                        DialogApp:dialog({
                            text = 'This trade seems unbalanced. Be careful - you could be getting scammed.',
                            button = 'Next',
                            yields = false,
                        })
                    end)

                    pcall(function()
                        DialogApp:dialog({
                            text = 'Any items lost to scams WILL NOT be returned. Be sure before you accept!',
                            button = 'I understand',
                            yields = false,
                        })
                    end)
                end
            end
        else
            return mockState.originalFunctions._evaluate_trade_fairness(self)
        end
    end
end

hookTradeFunctions()

local function showTradeRequest()
    if
        mockState.pendingTradeRequest
        or mockState.active
        or not mockState.canShowTradeRequest
        or mockState.tradeRequestBlocked
    then
        return
    end

    mockState.pendingTradeRequest = true
    mockState.canShowTradeRequest = false

    task.wait(CONFIG.TRADE_REQUEST_DELAY)

    if not mockState.pendingTradeRequest then
        mockState.canShowTradeRequest = true
        return
    end

    local name = CONFIG.PARTNER_NAME
    local trade_request_table_friend = {
        ['text'] = name .. ' sent you a trade request',
        ['left'] = 'Decline',
        ['right'] = 'Accept',
        -- Removed dialog_type as HeaderDialog no longer exists
        ['header'] = 'Verified Friend',
        ['header_icon'] = 'rbxassetid://84667805159408',
    }

    local success, dialogApp = pcall(function()
        return load('UIManager').apps.DialogApp:dialog(trade_request_table_friend)
    end)

    if not success then
        warn("Failed to show trade request dialog:", dialogApp)
        dialogApp = 'Decline' -- Default to declining if dialog fails
    end

    if dialogApp == 'Accept' then
        mockState.active = false
        mockState.trade = nil
        mockState.isAddingItem = false
        mockState.partnerActionPending = false
        mockState.tradeCompleting = false
        mockState.scamWarningShown = true
        mockState.tradeRequestBlocked = true

        mockState.blockedTradeRequests = {}
        mockState.trade = createMockTrade()
        mockState.active = true

        UIManager.set_app_visibility('TradeApp', false)
        task.wait(0.2)

        TradeApp:_overwrite_local_trade_state(mockState.trade)

        task.wait(0.3)
        UIManager.set_app_visibility('TradeApp', true)
        FriendHighlight(true)
        TradeApp:_show_intro_message()

        task.wait(0.2)
        if TradeApp.refresh_all then
            TradeApp:refresh_all()
            FriendHighlight(true)
        end

        task.wait(0.5)
        if not UIManager.is_visible('TradeApp') then
            UIManager.set_app_visibility('TradeApp', true)
            if TradeApp.refresh_all then
                TradeApp:refresh_all()
                FriendHighlight(true)
            end
        end
    else
        mockState.canShowTradeRequest = true
        if HintApp then
            HintApp:hint({
                text = '',
                length = 3,
                overridable = true,
            })
        end
    end

    mockState.pendingTradeRequest = false
end

local function hookTradeRequestEvent()
    local RouterClient = load('RouterClient')
    local tradeRequestEvent =
        RouterClient.get_event('TradeAPI/TradeRequestReceived')

    if tradeRequestEvent then
        local originalConnections =
            getconnections(tradeRequestEvent.OnClientEvent)

        for _, connection in pairs(originalConnections) do
            connection:Disable()
        end

        tradeRequestEvent.OnClientEvent:Connect(function(requestingPlayer)
            if mockState.active or mockState.tradeRequestBlocked then
                local requestData = {
                    player = requestingPlayer,
                    timestamp = tick(),
                }
                table.insert(mockState.blockedTradeRequests, requestData)
                return
            end

            for _, connection in pairs(originalConnections) do
                if connection.Function then
                    connection.Function(requestingPlayer)
                end
            end
        end)
    end
end

local function hookDialogApp()
    if not DialogApp or not DialogApp.dialog then
        warn("DialogApp not available, trade dialogs may not work properly")
        return
    end

    -- Store original function with error handling
    local success, originalFunc = pcall(function()
        return DialogApp.dialog
    end)

    if not success then
        warn("Failed to access DialogApp.dialog:", originalFunc)
        return
    end

    mockState.originalDialogFunction = originalFunc

    -- Override with safer version that handles UI errors
    DialogApp.dialog = function(self, dialogData)
        -- Handle trade expiration messages
        if
            dialogData
            and dialogData.text
            and string.find(dialogData.text, 'has expired!')
        then
            return 'Okay'
        end

        -- Handle trade requests
        if dialogData and dialogData.handle == 'trade_request' then
            if
                mockState.pendingTradeRequest
                or mockState.active
                or mockState.tradeRequestBlocked
            then
                return 'Decline'
            end
        end

        -- Handle mock trade requests
        if dialogData and dialogData.handle == 'mock_trade_request' then
            local success, result = pcall(function()
                return mockState.originalDialogFunction(self, dialogData)
            end)
            if success then
                return result
            else
                warn("DialogApp error in mock_trade_request:", result)
                return 'Okay' -- Safe fallback
            end
        end

        -- Call original with error handling
        local success, result = pcall(function()
            return mockState.originalDialogFunction(self, dialogData)
        end)

        if success then
            return result
        else
            warn("DialogApp error:", result)
            return 'Okay' -- Safe fallback for any dialog
        end
    end
end

hookDialogApp()
hookTradeRequestEvent()

function showBlockedTradeRequests()
    if #mockState.blockedTradeRequests > 0 then
        task.wait(0.5)

        local RouterClient = load('RouterClient')
        local TradeExcluder = load('TradeExcluder')

        for _, request in ipairs(mockState.blockedTradeRequests) do
            local requestingPlayer = request.player

            if
                TradeExcluder
                and TradeExcluder.is_player_excluded(requestingPlayer)
            then
                RouterClient.get('TradeAPI/AcceptOrDeclineTradeRequest')
                    :InvokeServer(requestingPlayer, false)
            else
                if DialogApp and mockState.originalDialogFunction then
                    local requestText = string.format(
                        '%s sent you a trade request',
                        requestingPlayer.Name
                    )

                    local dialogData = {
                        text = requestText,
                        left = 'Decline',
                        right = 'Accept',
                        handle = 'trade_request',
                    }

                    local response =
                        mockState.originalDialogFunction(DialogApp, dialogData)

                    if response == 'Accept' then
                        local shouldAccept = true
                        if TradeApp._confirm_player_if_suspicious then
                            shouldAccept =
                                TradeApp:_confirm_player_if_suspicious(
                                    requestingPlayer
                                )
                        end

                        if
                            shouldAccept
                            and not TradeApp:check_and_warn_if_trading_restricted()
                        then
                            TradeApp:show_scam_warning()
                        end

                        RouterClient.get('TradeAPI/AcceptOrDeclineTradeRequest')
                            :InvokeServer(requestingPlayer, shouldAccept)
                    else
                        RouterClient.get('TradeAPI/AcceptOrDeclineTradeRequest')
                            :InvokeServer(requestingPlayer, false)
                    end
                end
            end
        end

        mockState.blockedTradeRequests = {}
    end
end

local originalProfileClick = nil
if TradeApp.partner_profile_button then
    local profileButton = TradeApp.partner_profile_button
    if
        profileButton.callbacks and profileButton.callbacks.mouse_button1_click
    then
        originalProfileClick = profileButton.callbacks.mouse_button1_click

        profileButton.callbacks.mouse_button1_click = function()
            if mockState.active and mockState.trade then
                if PlayerProfileApp then
                    PlayerProfileApp:open_player_profile_for_user_id(
                        mockState.trade.recipient.UserId
                    )
                end
            else
                if originalProfileClick then
                    originalProfileClick()
                end
            end
        end
    end
end

function updatePartnerFromUsername(username)
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success and userId then
        CONFIG.PARTNER_USER_ID = userId
        CONFIG.PARTNER_NAME = username
        mockPartner = createMockPartner()
        return true
    else
        CONFIG.PARTNER_NAME = username
        mockPartner = createMockPartner()
        return false
    end
end

-- FIXED Neon and Mega Neon Effect Functions
local function applyMegaNeonEffects(petModel, kind)
    local petRigs = load('new:PetRigs')
    local petModelInstance = petModel:FindFirstChild('PetModel') or petModel

    -- Get the actual neon configuration from the pet data
    local petData = InventoryDB.pets[kind]
    if not petData or not petData.neon_parts then
        return
    end

    -- Apply Mega Neon effects using original colors but enhanced
    for neonPart, configuration in pairs(petData.neon_parts) do
        local trueNeonPart = petRigs
            .get(petModelInstance)
            .get_geo_part(petModelInstance, neonPart)
        if trueNeonPart then
            trueNeonPart.Material = Enum.Material.Neon

            -- Enhanced Mega Neon colors (brighter and more vibrant)
            local originalColor = configuration.Color
            if originalColor then
                -- Make colors more vibrant for Mega Neon
                local h, s, v = originalColor:ToHSV()
                trueNeonPart.Color = Color3.fromHSV(
                    h,
                    math.min(s * 1.3, 1),
                    math.min(v * 1.4, 1)
                )
            else
                -- Default Mega Neon purple if no original color
                trueNeonPart.Color = Color3.fromRGB(170, 0, 255)
            end
        end
    end
end

local function applyNeonEffects(petModel, kind)
    local petRigs = load('new:PetRigs')
    local petModelInstance = petModel:FindFirstChild('PetModel') or petModel

    -- Get the actual neon configuration from the pet data
    local petData = InventoryDB.pets[kind]
    if not petData or not petData.neon_parts then
        return
    end

    -- Apply Neon effects using ORIGINAL pet colors
    for neonPart, configuration in pairs(petData.neon_parts) do
        local trueNeonPart = petRigs
            .get(petModelInstance)
            .get_geo_part(petModelInstance, neonPart)
        if trueNeonPart then
            trueNeonPart.Material = Enum.Material.Neon

            -- Use the ORIGINAL neon colors from the pet configuration
            if configuration.Color then
                trueNeonPart.Color = configuration.Color
            end
        end
    end
end

local currentTab = 'Control'
local tabFrames = {}
local tabButtons = {}
local activeTabPulseTween = nil
local hasShownAnimation = {}

local controlGui = Instance.new('ScreenGui')
controlGui.Name = 'MockTradeControl'
controlGui.ResetOnSpawn = false
controlGui.DisplayOrder = 10
controlGui.Enabled = true
controlGui.Parent = Players.LocalPlayer:WaitForChild('PlayerGui')

-- SMALLER GUI - 180x320
local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.new(0, 180, 0, 550)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = controlGui

local mainCorner = Instance.new('UICorner')
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new('UIStroke')
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Color = Color3.fromRGB(100, 100, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- SMALLER TITLE
local titleLabel = Instance.new('TextLabel')
titleLabel.Size = UDim2.new(1, 0, 0, 18)
titleLabel.Position = UDim2.new(0, 0, 0, 2)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = 'bb_tricks on discord'
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 10
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
titleLabel.Parent = mainFrame

local titleStroke = Instance.new('UIStroke')
titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
titleStroke.Color = Color3.new(0, 0, 0)
titleStroke.Thickness = 0.8
titleStroke.Parent = titleLabel

-- SMALLER TAB CONTAINER
local tabContainer = Instance.new('Frame')
tabContainer.Size = UDim2.new(0.94, 0, 0, 22)
tabContainer.Position = UDim2.new(0.03, 0, 0, 22)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local playerListButtons = {}
local userListButtons = {}

function setActiveTab(tabName)
    if currentTab == tabName then
        return
    end

    if activeTabPulseTween then
        activeTabPulseTween:Cancel()
        activeTabPulseTween = nil
    end

    currentTab = tabName

    for name, data in pairs(tabButtons) do
        local isActive = name == tabName
        TweenService
            :Create(
                data.button,
                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    BackgroundColor3 = isActive and Color3.fromRGB(50, 50, 60)
                        or Color3.fromRGB(40, 40, 50),
                }
            )
            :Play()

        local targetColor = isActive and Color3.fromRGB(100, 100, 255)
            or Color3.fromRGB(80, 80, 80)
        local targetThickness = isActive and 1.2 or 0.8

        TweenService:Create(
            data.stroke,
            TweenInfo.new(
                0.25,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Color = targetColor,
                Thickness = targetThickness,
            }
        ):Play()

        if isActive then
            local pulseInfo = TweenInfo.new(
                1.5,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true
            )
            activeTabPulseTween = TweenService:Create(data.stroke, pulseInfo, {
                Color = targetColor:Lerp(Color3.fromRGB(255, 255, 255), 0.25),
                Thickness = 1.5,
            })
            activeTabPulseTween:Play()
        end
    end

    for name, frame in pairs(tabFrames) do
        frame.Visible = name == tabName
    end

    if tabName == 'Players' and not hasShownAnimation[tabName] then
        hasShownAnimation[tabName] = true
        animatePlayerList()
    end
    if tabName == 'Users' and not hasShownAnimation[tabName] then
        hasShownAnimation[tabName] = true
        animateUserList()
    end
    if tabName == 'Pets' and not hasShownAnimation[tabName] then
        hasShownAnimation[tabName] = true
        animatePetList()
    end
end

-- Tabs with smaller buttons and text
local tabs = { 'Control', 'Players', 'Pets', 'Users', 'Spawner' }
local tabIcons = { 'ðŸŽ®', 'ðŸ‘¥', 'ðŸ¾', 'ðŸ§‘', 'ðŸ‰' }

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new('TextButton')
    tabButton.Size = UDim2.new(1 / #tabs - 0.02, 0, 1, 0)
    tabButton.Position =
        UDim2.new((i - 1) * (1 / #tabs), (i == 1) and 0 or 0, 0, 0)
    tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 60)
        or Color3.fromRGB(40, 40, 50)
    tabButton.BackgroundTransparency = 0.2
    tabButton.Text = tabIcons[i] .. ' ' .. tabName
    tabButton.Font = Enum.Font.FredokaOne
    tabButton.TextSize = 8
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new('UICorner')
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton

    local tabStroke = Instance.new('UIStroke')
    tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tabStroke.Color = i == 1 and Color3.fromRGB(100, 100, 255)
        or Color3.fromRGB(80, 80, 80)
    tabStroke.Thickness = i == 1 and 1.2 or 0.8
    tabStroke.Transparency = 0.3
    tabStroke.Parent = tabButton

    tabButtons[tabName] = { button = tabButton, stroke = tabStroke }

    -- SMALLER TAB FRAMES
    local tabFrame = Instance.new('Frame')
    tabFrame.Size = UDim2.new(0.9, 0, 0, 275)
    tabFrame.Position = UDim2.new(0.05, 0, 0, 48)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = i == 1
    tabFrame.Parent = mainFrame

    tabFrames[tabName] = tabFrame

    tabButton.MouseButton1Click:Connect(function()
        setActiveTab(tabName)
    end)
end

local controlFrame = tabFrames['Control']

local controlLayout = Instance.new('UIListLayout')
controlLayout.SortOrder = Enum.SortOrder.LayoutOrder
controlLayout.Padding = UDim.new(0, 3)
controlLayout.Parent = controlFrame

local pulsationTweens = {}

function createSettingRow(labelText, defaultValue, parent)
    local heading = Instance.new('TextLabel')
    heading.Size = UDim2.new(1, 0, 0, 12)
    heading.BackgroundTransparency = 1
    heading.Text = labelText
    heading.Font = Enum.Font.SourceSansSemibold
    heading.TextSize = 9
    heading.TextColor3 = Color3.fromRGB(180, 180, 180)
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = parent

    local box = Instance.new('TextBox')
    box.Size = UDim2.new(1, 0, 0, 20)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    box.BackgroundTransparency = 0.2
    box.Text = tostring(defaultValue)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 11
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.Parent = parent

    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = box

    local stroke = Instance.new('UIStroke')
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 0.8
    stroke.Transparency = 0.5
    stroke.Parent = box

    box.Focused:Connect(function()
        if pulsationTweens[box] then
            pulsationTweens[box]:Cancel()
        end

        local pulseInfo = TweenInfo.new(
            0.8,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            -1,
            true
        )
        pulsationTweens[box] = TweenService:Create(stroke, pulseInfo, {
            Color = Color3.fromRGB(100, 100, 255)
                :Lerp(Color3.fromRGB(150, 150, 255), 0.5),
            Thickness = 1.2,
            Transparency = 0.2,
        })
        pulsationTweens[box]:Play()
    end)

    box.FocusLost:Connect(function()
        if pulsationTweens[box] then
            pulsationTweens[box]:Cancel()
            pulsationTweens[box] = nil
        end

        TweenService
            :Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Color = Color3.fromRGB(100, 100, 100),
                Thickness = 0.8,
                Transparency = 0.5,
            })
            :Play()
    end)

    return box, stroke, heading
end

-- Create settings rows with smaller text
local partnerBox, partnerStroke =
    createSettingRow('Partner Username', CONFIG.PARTNER_NAME, controlFrame)
local acceptBox, acceptStroke =
    createSettingRow('Accept Delay (s)', CONFIG.AUTO_ACCEPT_DELAY, controlFrame)
local confirmBox, confirmStroke = createSettingRow(
    'Confirm Delay (s)',
    CONFIG.AUTO_CONFIRM_DELAY,
    controlFrame
)
local spectatorBox, spectatorStroke =
    createSettingRow('Spectator Count', CONFIG.SPECTATOR_COUNT, controlFrame)
local requestDelayBox, requestDelayStroke = createSettingRow(
    'Request Delay (s)',
    CONFIG.TRADE_REQUEST_DELAY,
    controlFrame
)

local FakePlayers = {}
local FakePetRegistry = {}
local AnimationManager = {
    running = false,
    checkInterval = 0.3, -- Faster check interval for better animation persistence
    animationTracks = {},
}

local function updateData(key, action)
    local data = ClientData.get(key)
    local clonedData = table.clone(data)
    ClientData.predict(key, action(clonedData))
end

-- IMPROVED Persistent Animation Manager
function AnimationManager:Start()
    if self.running then
        return
    end
    self.running = true

    task.spawn(function()
        while self.running do
            task.wait(self.checkInterval)

            -- Check and refresh all fake pet animations
            for _, petData in ipairs(FakePetRegistry) do
                if petData and petData.model and petData.model.Parent then
                    pcall(function()
                        local character = petData.character
                        if character and character.Parent then
                            local humanoid =
                                character:FindFirstChild('Humanoid')
                            if humanoid then
                                -- Check if riding animation is still playing
                                local animator =
                                    humanoid:FindFirstChild('Animator')
                                if animator then
                                    local isRiding = false
                                    for _, track in
                                        ipairs(
                                            animator:GetPlayingAnimationTracks()
                                        )
                                    do
                                        if
                                            track.Animation.AnimationId:find(
                                                'PlayerRidingPet'
                                            )
                                            or track.Animation.AnimationId:find(
                                                '507766666'
                                            )
                                        then
                                            isRiding = true
                                            break
                                        end
                                    end

                                    -- Re-apply riding animation if not playing
                                    if
                                        not isRiding and petData.hasRidingPet
                                    then
                                        if
                                            not petData.ridingAnim
                                            or not petData.ridingAnim.IsPlaying
                                        then
                                            if petData.ridingAnim then
                                                petData.ridingAnim:Stop()
                                            end
                                            petData.ridingAnim =
                                                animator:LoadAnimation(
                                                    animationManager.get_track(
                                                        'PlayerRidingPet'
                                                    )
                                                )
                                            petData.ridingAnim.Looped = true
                                            petData.ridingAnim:Play()
                                            humanoid.Sit = true
                                        end
                                    end
                                end
                            end
                        end

                        -- Maintain neon effects
                        if petData.wrapper.mega_neon then
                            applyMegaNeonEffects(
                                petData.model,
                                petData.wrapper.pet_id
                            )
                        elseif petData.wrapper.neon then
                            applyNeonEffects(
                                petData.model,
                                petData.wrapper.pet_id
                            )
                        end
                    end)
                end
            end
        end
    end)
end

function AnimationManager:Stop()
    self.running = false
    -- Stop all animations
    for _, petData in ipairs(FakePetRegistry) do
        if petData.ridingAnim then
            petData.ridingAnim:Stop()
        end
    end
end

function AnimationManager:AddPet(petData)
    table.insert(FakePetRegistry, petData)
    if not self.running then
        self:Start()
    end
end

local function createFakePetOwner(fakeCharacter, partnerName, partnerId)
    return setmetatable({
        Name = partnerName,
        DisplayName = partnerName,
        UserId = partnerId,
        Character = fakeCharacter,
    }, {
        __index = function(t, k)
            if k == 'Parent' then
                return Players
            end
            if k == 'IsA' then
                return function(self, className)
                    return className == 'Player'
                end
            end
            if k == 'GetChildren' then
                return function()
                    return {}
                end
            end
            return rawget(t, k)
        end,
        __tostring = function()
            return partnerName
        end,
    })
end

function OpenProfile(Id)
    load('UIManager').apps.PlayerProfileApp:open_player_profile_for_user_id(Id)
end

-- Hook InteractionsEngine to block fake pet interactions
task.spawn(function()
    task.wait(0.1)
    local InteractionsEngine = load('InteractionsEngine')
    local original_register = InteractionsEngine.register

    InteractionsEngine.register = function(self, interactionData)
        -- Block any interactions with fake pet parts
        if interactionData and interactionData.part then
            local part = interactionData.part

            -- Check if this part belongs to a fake pet
            local checkPart = part
            while checkPart do
                -- Only block if the attribute exists AND is true AND parent exists
                if
                    checkPart:GetAttribute('IsFakePet') == true
                    and checkPart.Parent
                then
                    -- Silently ignore registration for fake pets
                    return
                end
                checkPart = checkPart.Parent
            end
        end

        -- Call original for real interactions
        return original_register(self, interactionData)
    end
end)

-- MODIFIED: Fake Player Creation - Only spawn with Balloon Unicorn or higher pets
function CreateFakePlayerCharacterFromPARTNER_NAME(
    partner_name,
    partner_id,
    pros_fake_pet,
    pet_flags
)
    local maxRetries = 3
    local retryCount = 0

    local function attemptCreate()
        retryCount = retryCount + 1

        -- Register as fake player IMMEDIATELY before anything else
        fakePlayerIds[partner_id] = true
        _G.fakePlayerIds[partner_id] = true

        local folder_fake = Instance.new('Folder')
        folder_fake.Name = 'fake_folder_' .. partner_name
        folder_fake.Parent = workspace

        local character = Players:CreateHumanoidModelFromUserId(partner_id)
        local player = Players.LocalPlayer
        local playerCharacter = player.Character

        character:SetPrimaryPartCFrame(
            playerCharacter.HumanoidRootPart.CFrame
                * CFrame.new(math.random(-10, 10), 0, math.random(-10, 10))
        )

        local humanoid = character:WaitForChild('Humanoid')
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        humanoid.HealthDisplayDistance = 0

        character.Parent = folder_fake

        if pros_fake_pet ~= nil then
            local petCreated = false
            local success, err = pcall(function()
                local kind = pros_fake_pet.kind
                local petModel = getPetModel(kind)

                if not petModel then
                    warn('Could not get pet model for kind:', kind)
                    return
                end

                petModel = petModel:Clone()

                -- MARK AS FAKE PET IMMEDIATELY
                petModel:SetAttribute('IsFakePet', true)

                -- Apply Mega Neon or Neon effects if flags are provided
                if pet_flags then
                    if pet_flags.M then -- Mega Neon
                        applyMegaNeonEffects(petModel, kind)
                    elseif pet_flags.N then -- Neon
                        applyNeonEffects(petModel, kind)
                    end
                end

                petModel.Parent = folder_fake

                petModel:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame)
                petModel:ScaleTo(2) -- Scale for riding

                -- Mark all parts as fake
                for _, part in ipairs(petModel:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part:SetAttribute('IsFakePet', true)
                    end
                end

                local ridePosition =
                    petModel:FindFirstChild('RidePosition', true)
                if ridePosition then
                    local sourceAttachment = Instance.new('Attachment')
                    sourceAttachment.Parent = ridePosition
                    sourceAttachment.Position = Vector3.new(0, 1.237, 0)
                    sourceAttachment.Name = 'SourceAttachment'

                    local stateConnection = Instance.new('RigidConstraint')
                    stateConnection.Name = 'StateConnection'
                    stateConnection.Attachment0 = sourceAttachment
                    stateConnection.Attachment1 =
                        character.PrimaryPart.RootAttachment
                    stateConnection.Parent = character
                end

                -- Load and play riding animation with better handling
                local ridingAnim = character.Humanoid.Animator:LoadAnimation(
                    animationManager.get_track('PlayerRidingPet')
                )
                ridingAnim.Looped = true
                ridingAnim:Play()
                character.Humanoid.Sit = true

                -- Make character parts massless for riding
                for _, descendant in pairs(character:GetDescendants()) do
                    if
                        descendant:IsA('BasePart')
                        and descendant.Massless == false
                    then
                        descendant.Massless = true
                        descendant:SetAttribute('HaveMass', true)
                    end
                end

                local fakePetOwner =
                    createFakePetOwner(character, partner_name, partner_id)

                local petWrapper = {
                    char = petModel,
                    mega_neon = pet_flags and pet_flags.M or false,
                    neon = pet_flags and pet_flags.N or false,
                    player = fakePetOwner,
                    entity_controller = fakePetOwner,
                    controller = fakePetOwner,
                    rp_name = '',
                    pet_trick_level = math.random(1, 5),
                    pet_unique = HttpService:GenerateGUID(false),
                    pet_id = kind,
                    location = {
                        full_destination_id = 'housing',
                        destination_id = 'housing',
                        house_owner = fakePetOwner,
                    },
                    pet_progression = {
                        age = math.random(1, 900000),
                        percentage = math.random(0.01, 0.99),
                    },
                    are_colors_sealed = false,
                    is_pet = true,
                }

                local petState = {
                    char = petModel,
                    player = fakePetOwner,
                    store_key = 'pet_state_managers',
                    is_sitting = false,
                    chars_connected_to_me = {},
                    states = {
                        { id = 'PetBeingRidden' },
                    },
                }

                updateData('pet_char_wrappers', function(petWrappers)
                    petWrapper.unique = #petWrappers + 1
                    petWrapper.index = #petWrappers + 1
                    petWrappers[#petWrappers + 1] = petWrapper
                    return petWrappers
                end)

                updateData('pet_state_managers', function(petStates)
                    petStates[#petStates + 1] = petState
                    return petStates
                end)

                -- Add to animation manager with proper animation tracking
                table.insert(FakePetRegistry, {
                    wrapper = petWrapper,
                    state = petState,
                    model = petModel,
                    character = character,
                    hasRidingPet = true,
                    owner = fakePetOwner,
                    ridingAnim = ridingAnim,
                    folder = folder_fake,
                })

                if not AnimationManager.running then
                    AnimationManager:Start()
                end

                petCreated = true
                print(
                    'âœ“ Registered fake pet with native game systems:',
                    kind,
                    pet_flags
                            and (pet_flags.M and 'Mega Neon' or pet_flags.N and 'Neon' or 'Regular')
                        or 'Regular'
                )
            end)

            if not success or not petCreated then
                warn(
                    'Error creating fake pet (Attempt '
                        .. retryCount
                        .. '/'
                        .. maxRetries
                        .. '):',
                    err
                )
                folder_fake:Destroy()
                for i, folder in ipairs(FakePlayers) do
                    if folder == folder_fake then
                        table.remove(FakePlayers, i)
                        break
                    end
                end
                if retryCount < maxRetries then
                    print(
                        'ðŸ”„ Retrying fake character creation for '
                            .. partner_name
                            .. '...'
                    )
                    task.wait(0.5)
                    return attemptCreate()
                else
                    warn(
                        'âŒ Failed to create fake character after '
                            .. maxRetries
                            .. ' attempts'
                    )
                    return false
                end
            end
        else
            -- Default animation if no pet
            local Animation = Instance.new('Animation')
            Animation.AnimationId = 'http://www.roblox.com/asset/?id=507766666'
            local track = character.Humanoid.Animator:LoadAnimation(Animation)
            track.Looped = true
            track:Play()
        end

        pcall(function()
            UIManager.apps.PlayerNameApp:add_npc_id(character, partner_name)
        end)

        local Part = character:FindFirstChild('HumanoidRootPart')
        if Part then
            local InteractionsEngine = load('InteractionsEngine')
            local emptyFunc = function() end

            local v22 = {
                ['text'] = partner_name,
                ['part'] = Part,
                ['on_selected'] = {
                    {
                        ['text'] = 'Profile',
                        ['on_selected'] = function()
                            pcall(OpenProfile, partner_id)
                        end,
                    },
                    {
                        ['text'] = 'Trade',
                        ['on_selected'] = function()
                            pcall(function()
                                task.spawn(function()
                                    pcall(function()
                                        if HintApp then
                                            HintApp:hint({
                                                text = 'Trade request sent to '
                                                    .. partner_name,
                                                length = 3,
                                                overridable = true,
                                            })
                                        end
                                    end)
                                end)
                                task.wait(
                                    CONFIG.FAKE_PLAYER_ACCEPT_TRADE_REQUEST
                                )

                                partnerBox.Text = partner_name
                                updatePartnerFromUsername(partner_name)

                                mockState.active = false
                                mockState.trade = nil
                                mockState.isAddingItem = false
                                mockState.partnerActionPending = false
                                mockState.tradeCompleting = false
                                mockState.scamWarningShown = true
                                mockState.tradeRequestBlocked = true

                                mockState.blockedTradeRequests = {}
                                mockState.trade = createMockTrade()
                                mockState.active = true

                                UIManager.set_app_visibility('TradeApp', false)
                                task.wait(0.2)

                                TradeApp:_overwrite_local_trade_state(
                                    mockState.trade
                                )

                                task.wait(0.3)
                                UIManager.set_app_visibility('TradeApp', true)
                                FriendHighlight(true)
                                TradeApp:_show_intro_message()

                                task.wait(0.2)
                                if TradeApp.refresh_all then
                                    TradeApp:refresh_all()
                                    FriendHighlight(true)
                                end

                                task.wait(0.5)
                                if not UIManager.is_visible('TradeApp') then
                                    UIManager.set_app_visibility(
                                        'TradeApp',
                                        true
                                    )
                                    if TradeApp.refresh_all then
                                        TradeApp:refresh_all()
                                        FriendHighlight(true)
                                    end
                                end
                            end)
                        end,
                    },
                    { ['text'] = 'Give Item...', ['on_selected'] = emptyFunc },
                    { ['text'] = 'Mute', ['on_selected'] = emptyFunc },
                },
            }

            pcall(function()
                InteractionsEngine:register(v22)
            end)
        end

        table.insert(FakePlayers, folder_fake)

        folder_fake:SetAttribute('IsFakePlayer', true)
        folder_fake:SetAttribute('PartnerName', partner_name)
        folder_fake:SetAttribute('PartnerId', partner_id)

        return true
    end

    return attemptCreate()
end

function GetKindPet(name)
    for k, v in pairs(InventoryDB.pets) do
        if v['name']:lower() == name:lower() then
            return k
        end
    end
end
local function enableNoclip(character)
    if not character then
        return
    end

    -- Make all parts CanCollide false and set collision groups
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA('BasePart') then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false

            -- Set to noclip collision group if available
            pcall(function()
                part.CollisionGroup = 'Noclip'
            end)
        end
    end

    -- Also handle any new parts that get added
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA('BasePart') then
            task.wait()
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            pcall(function()
                descendant.CollisionGroup = 'Noclip'
            end)
        end
    end)
end

local spacer = Instance.new('Frame')
spacer.Size = UDim2.new(1, 0, 0, 4)
spacer.BackgroundTransparency = 1
spacer.Parent = controlFrame

-- SMALLER Add Random Item Button
local addRandomItemButton = Instance.new('TextButton')
addRandomItemButton.Size = UDim2.new(1, 0, 0, 22)
addRandomItemButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
addRandomItemButton.BackgroundTransparency = 0.2
addRandomItemButton.Text = 'Add Random Item'
addRandomItemButton.Font = Enum.Font.FredokaOne
addRandomItemButton.TextSize = 10
addRandomItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addRandomItemButton.Parent = controlFrame

local addRandomItemCorner = Instance.new('UICorner')
addRandomItemCorner.CornerRadius = UDim.new(0, 4)
addRandomItemCorner.Parent = addRandomItemButton

local addRandomItemStroke = Instance.new('UIStroke')
addRandomItemStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
addRandomItemStroke.Color = Color3.fromRGB(200, 100, 255)
addRandomItemStroke.Thickness = 1.0
addRandomItemStroke.Transparency = 0.3
addRandomItemStroke.Parent = addRandomItemButton

addRandomItemButton.MouseButton1Click:Connect(function()
    if mockState.active and mockState.trade then
        -- MODIFIED: Only add high-value pets (Balloon Unicorn or higher)
        local randomPet = getRandomHighValuePet()
        local randomProperties = generateRandomPetProperties()

        local success, message =
            addPetToPartnerOffer(randomPet, randomProperties)
    end
end)

local spacer5 = Instance.new('Frame')
spacer5.Size = UDim2.new(1, 0, 0, 3)
spacer5.BackgroundTransparency = 1
spacer5.Parent = controlFrame

-- SMALLER Clear Trade Button
local clearTradeButton = Instance.new('TextButton')
clearTradeButton.Size = UDim2.new(1, 0, 0, 22)
clearTradeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
clearTradeButton.BackgroundTransparency = 0.2
clearTradeButton.Text = 'Clear Trade'
clearTradeButton.Font = Enum.Font.FredokaOne
clearTradeButton.TextSize = 10
clearTradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearTradeButton.Parent = controlFrame

local clearTradeCorner = Instance.new('UICorner')
clearTradeCorner.CornerRadius = UDim.new(0, 4)
clearTradeCorner.Parent = clearTradeButton

local clearTradeStroke = Instance.new('UIStroke')
clearTradeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
clearTradeStroke.Color = Color3.fromRGB(255, 100, 100)
clearTradeStroke.Thickness = 1.0
clearTradeStroke.Transparency = 0.3
clearTradeStroke.Parent = clearTradeButton

clearTradeButton.MouseButton1Click:Connect(function()
    if mockState.active and mockState.trade then
        mockState.trade.sender_offer.items = {}
        mockState.trade.recipient_offer.items = {}
        mockState.trade.sender_offer.negotiated = false
        mockState.trade.recipient_offer.negotiated = false
        mockState.trade.current_stage = 'negotiation'
        mockState.trade.offer_version = mockState.trade.offer_version + 1
        TradeApp:_overwrite_local_trade_state(mockState.trade)
    end
end)

local spacer6 = Instance.new('Frame')
spacer6.Size = UDim2.new(1, 0, 0, 3)
spacer6.BackgroundTransparency = 1
spacer6.Parent = controlFrame

-- SMALLER Start Trade Button
local initButton = Instance.new('TextButton')
initButton.Size = UDim2.new(1, 0, 0, 22)
initButton.BackgroundColor3 = Color3.fromRGB(50, 80, 60)
initButton.BackgroundTransparency = 0.2
initButton.Text = 'Start Trade'
initButton.Font = Enum.Font.FredokaOne
initButton.TextSize = 10
initButton.TextColor3 = Color3.fromRGB(255, 255, 255)
initButton.Parent = controlFrame

local initCorner = Instance.new('UICorner')
initCorner.CornerRadius = UDim.new(0, 4)
initCorner.Parent = initButton

local initStroke = Instance.new('UIStroke')
initStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
initStroke.Color = Color3.fromRGB(0, 255, 100)
initStroke.Thickness = 1.0
initStroke.Transparency = 0.3
initStroke.Parent = initButton

function BlockPlayer(Selected)
    pcall(function()
        setthreadidentity(8)
    end)
    game:GetService('StarterGui'):SetCore('PromptBlockPlayer', Selected)
    repeat
        game:GetService('RunService').Heartbeat:Wait()
    until game:GetService('CoreGui'):FindFirstChild('BlockingModalScreen')
    game:GetService('CoreGui').BlockingModalScreen.BlockingModalContainer.BlockingModalContainerWrapper.BlockingModal.BackgroundTransparency =
        1
    game:GetService('CoreGui').BlockingModalScreen.BlockingModalContainer.BlockingModalContainerWrapper.BackgroundTransparency =
        1
    game:GetService('CoreGui').BlockingModalScreen.BlockingModalContainer.BackgroundTransparency =
        1
    game:GetService('CoreGui').BlockingModalScreen.BlockingModalContainer.BlockingModalContainerWrapper.BlockingModal.AlertModal.Position =
        UDim2.new(0.00800000038, -110, 0.5, 0)
    local interact = function(path)
        game:GetService('GuiService').SelectedObject = path
        task.wait()
        if game:GetService('GuiService').SelectedObject == path then
            game:GetService('VirtualInputManager')
                :SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            game:GetService('VirtualInputManager')
                :SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait()
        end
        game:GetService('GuiService').SelectedObject = nil
    end
    interact(
        game:GetService('CoreGui').BlockingModalScreen.BlockingModalContainer.BlockingModalContainerWrapper.BlockingModal.AlertModal.AlertContents.Footer.Buttons['3']
    )
    pcall(function()
        setthreadidentity(2)
    end)
end

-- SMALLER Block Player Button
local BlockButtonButton = Instance.new('TextButton')
BlockButtonButton.Size = UDim2.new(1, 0, 0, 22)
BlockButtonButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
BlockButtonButton.BackgroundTransparency = 0.2
BlockButtonButton.Text = 'Block Player'
BlockButtonButton.Font = Enum.Font.FredokaOne
BlockButtonButton.TextSize = 10
BlockButtonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BlockButtonButton.Parent = controlFrame
local initCorner2 = Instance.new('UICorner')
initCorner2.CornerRadius = UDim.new(0, 4)
initCorner2.Parent = BlockButtonButton
local initStroke2 = Instance.new('UIStroke')
initStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
initStroke2.Color = Color3.fromRGB(255, 100, 100)
initStroke2.Thickness = 1.0
initStroke2.Transparency = 0.3
initStroke2.Parent = BlockButtonButton
BlockButtonButton.MouseButton1Click:Connect(function()
    BlockPlayer(Players[partnerBox.Text])
end)

local spacer7 = Instance.new('Frame')
spacer7.Size = UDim2.new(1, 0, 0, 3)
spacer7.BackgroundTransparency = 1
spacer7.Parent = controlFrame

-- MAKE PARTNER ACCEPT BUTTON
local acceptButton = Instance.new('TextButton')
acceptButton.Size = UDim2.new(1, 0, 0, 22)
acceptButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
acceptButton.BackgroundTransparency = 0.2
acceptButton.Text = 'Make Partner Accept'
acceptButton.Font = Enum.Font.FredokaOne
acceptButton.TextSize = 10
acceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptButton.Parent = controlFrame

local acceptCorner = Instance.new('UICorner')
acceptCorner.CornerRadius = UDim.new(0, 4)
acceptCorner.Parent = acceptButton

local acceptStroke = Instance.new('UIStroke')
acceptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
acceptStroke.Color = Color3.fromRGB(100, 255, 100)
acceptStroke.Thickness = 1.0
acceptStroke.Transparency = 0.3
acceptStroke.Parent = acceptButton

-- Function to make partner accept
function makePartnerAccept()
    if mockState.active and mockState.trade then
        -- Make partner accept/confirm based on current stage
        if mockState.trade.current_stage == 'negotiation' then
            if not mockState.trade.recipient_offer.negotiated then
                mockState.trade.recipient_offer.negotiated = true

                if mockState.trade.sender_offer.negotiated then
                    mockState.trade.current_stage = 'confirmation'
                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    TradeApp:_overwrite_local_trade_state(mockState.trade)

                    if TradeApp._evaluate_trade_fairness then
                        TradeApp:_evaluate_trade_fairness()
                    end

                    if TradeApp._lock_trade_for_appropriate_time then
                        TradeApp:_lock_trade_for_appropriate_time()
                    end
                else
                    mockState.trade.offer_version = mockState.trade.offer_version
                        + 1
                    TradeApp:_overwrite_local_trade_state(mockState.trade)
                end
            end
        elseif mockState.trade.current_stage == 'confirmation' then
            if not mockState.trade.recipient_offer.confirmed then
                mockState.trade.recipient_offer.confirmed = true
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                TradeApp:_overwrite_local_trade_state(mockState.trade)

                -- If both confirmed, complete the trade
                if
                    mockState.trade.sender_offer.confirmed
                    and not mockState.tradeCompleting
                then
                    mockState.tradeCompleting = true

                    if TradeApp._set_confirmation_arrow_rotating then
                        TradeApp:_set_confirmation_arrow_rotating(true)
                    end

                    task.wait(3)

                    local historyRecord =
                        createTradeHistoryRecord(mockState.trade)
                    appendToTradeHistory(historyRecord)

                    mockState.active = false
                    mockState.trade = nil
                    mockState.tradeCompleting = false
                    mockState.scamWarningShown = true
                    mockState.canShowTradeRequest = true
                    mockState.tradeRequestBlocked = false
                    UIManager.set_app_visibility('TradeApp', false)

                    task.wait(0.1)
                    showBlockedTradeRequests()

                    if HintApp then
                        HintApp:hint({
                            text = 'The trade was successful!',
                            length = 5,
                            overridable = true,
                        })
                    end

                    if
                        TradeHistoryApp
                        and UIManager.is_visible('TradeHistoryApp')
                    then
                        TradeHistoryApp:_refresh()
                    end
                end
            end
        end
    else
        warn('No active trade')
    end
end
local spacerNoclip = Instance.new('Frame')
spacerNoclip.Size = UDim2.new(1, 0, 0, 3)
spacerNoclip.BackgroundTransparency = 1
spacerNoclip.Parent = controlFrame

local noclipButton = Instance.new('TextButton')
noclipButton.Size = UDim2.new(1, 0, 0, 22)
noclipButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
noclipButton.BackgroundTransparency = 0.2
noclipButton.Text = 'Toggle Noclip: ON'
noclipButton.Font = Enum.Font.FredokaOne
noclipButton.TextSize = 10
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.Parent = controlFrame

local noclipCorner = Instance.new('UICorner')
noclipCorner.CornerRadius = UDim.new(0, 4)
noclipCorner.Parent = noclipButton

local noclipStroke = Instance.new('UIStroke')
noclipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
noclipStroke.Color = Color3.fromRGB(100, 100, 255)
noclipStroke.Thickness = 1.0
noclipStroke.Transparency = 0.3
noclipStroke.Parent = noclipButton

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled

    if noclipEnabled then
        noclipButton.Text = 'Toggle Noclip: ON'
        noclipButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        noclipStroke.Color = Color3.fromRGB(100, 100, 255)
        enableNoclipForAllFakePlayers()
        enableNoclipForPets()
    else
        noclipButton.Text = 'Toggle Noclip: OFF'
        noclipButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
        noclipStroke.Color = Color3.fromRGB(255, 100, 100)
    end
end)

local spacerUnaccept = Instance.new('Frame')
spacerUnaccept.Size = UDim2.new(1, 0, 0, 3)
spacerUnaccept.BackgroundTransparency = 1
spacerUnaccept.Parent = controlFrame

-- MAKE PARTNER UNACCEPT BUTTON
local unacceptButton = Instance.new('TextButton')
unacceptButton.Size = UDim2.new(1, 0, 0, 22)
unacceptButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
unacceptButton.BackgroundTransparency = 0.2
unacceptButton.Text = 'Make Partner Unaccept'
unacceptButton.Font = Enum.Font.FredokaOne
unacceptButton.TextSize = 10
unacceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unacceptButton.Parent = controlFrame

local unacceptCorner = Instance.new('UICorner')
unacceptCorner.CornerRadius = UDim.new(0, 4)
unacceptCorner.Parent = unacceptButton

local unacceptStroke = Instance.new('UIStroke')
unacceptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
unacceptStroke.Color = Color3.fromRGB(255, 100, 100)
unacceptStroke.Thickness = 1.0
unacceptStroke.Transparency = 0.3
unacceptStroke.Parent = unacceptButton

-- Function to make partner unaccept
function makePartnerUnaccept()
    if mockState.active and mockState.trade then
        -- Make partner unaccept based on current stage
        if mockState.trade.current_stage == 'negotiation' then
            if mockState.trade.recipient_offer.negotiated then
                mockState.trade.recipient_offer.negotiated = false
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                TradeApp:_overwrite_local_trade_state(mockState.trade)
            end
        elseif mockState.trade.current_stage == 'confirmation' then
            if mockState.trade.recipient_offer.confirmed then
                mockState.trade.recipient_offer.confirmed = false
                mockState.trade.offer_version = mockState.trade.offer_version
                    + 1
                TradeApp:_overwrite_local_trade_state(mockState.trade)
            end
        end
    else
        warn('No active trade')
    end
end

unacceptButton.MouseButton1Click:Connect(function()
    makePartnerUnaccept()
end)

acceptButton.MouseButton1Click:Connect(function()
    makePartnerAccept()
end)

print('Accept Trade button added - Click to make partner accept the trade')

local spacer8 = Instance.new('Frame')
spacer8.Size = UDim2.new(1, 0, 0, 3)
spacer8.BackgroundTransparency = 1
spacer8.Parent = controlFrame

-- Add pet type selection for fake players
local petTypeContainer = Instance.new('Frame')
petTypeContainer.Size = UDim2.new(1, 0, 0, 20)
petTypeContainer.BackgroundTransparency = 1
petTypeContainer.Parent = controlFrame

local petTypeLabel = Instance.new('TextLabel')
petTypeLabel.Size = UDim2.new(0.4, 0, 1, 0)
petTypeLabel.BackgroundTransparency = 1
petTypeLabel.Text = 'Fake Player Pet:'
petTypeLabel.Font = Enum.Font.SourceSansSemibold
petTypeLabel.TextSize = 9
petTypeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
petTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
petTypeLabel.Parent = petTypeContainer

local currentFakePetType = 'regular'

local regularPetButton = Instance.new('TextButton')
regularPetButton.Size = UDim2.new(0.18, 0, 1, 0)
regularPetButton.Position = UDim2.new(0.4, 0, 0, 0)
regularPetButton.Text = 'Reg'
regularPetButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
regularPetButton.Font = Enum.Font.FredokaOne
regularPetButton.TextSize = 8
regularPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
regularPetButton.Parent = petTypeContainer

local neonPetButton = Instance.new('TextButton')
neonPetButton.Size = UDim2.new(0.18, 0, 1, 0)
neonPetButton.Position = UDim2.new(0.6, 0, 0, 0)
neonPetButton.Text = 'Neon'
regularPetButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
neonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
neonPetButton.Font = Enum.Font.FredokaOne
neonPetButton.TextSize = 8
neonPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
neonPetButton.Parent = petTypeContainer

local megaNeonPetButton = Instance.new('TextButton')
megaNeonPetButton.Size = UDim2.new(0.18, 0, 1, 0)
megaNeonPetButton.Position = UDim2.new(0.8, 0, 0, 0)
megaNeonPetButton.Text = 'Mega'
megaNeonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
megaNeonPetButton.Font = Enum.Font.FredokaOne
megaNeonPetButton.TextSize = 8
megaNeonPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
megaNeonPetButton.Parent = petTypeContainer

regularPetButton.MouseButton1Click:Connect(function()
    currentFakePetType = 'regular'
    regularPetButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    neonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    megaNeonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)

neonPetButton.MouseButton1Click:Connect(function()
    currentFakePetType = 'neon'
    regularPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    neonPetButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    megaNeonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)

megaNeonPetButton.MouseButton1Click:Connect(function()
    currentFakePetType = 'mega'
    regularPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    neonPetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    megaNeonPetButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end)

local SpawnFakePlayerButton = Instance.new('TextButton')
SpawnFakePlayerButton.Size = UDim2.new(1, 0, 0, 22)
SpawnFakePlayerButton.BackgroundColor3 = Color3.fromRGB(65, 50, 150)
SpawnFakePlayerButton.BackgroundTransparency = 0.2
SpawnFakePlayerButton.Text = 'Spawn fake player'
SpawnFakePlayerButton.Font = Enum.Font.FredokaOne
SpawnFakePlayerButton.TextSize = 10
SpawnFakePlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnFakePlayerButton.Parent = controlFrame

local SpawnFakePlayerCorner = Instance.new('UICorner')
SpawnFakePlayerCorner.CornerRadius = UDim.new(0, 4)
SpawnFakePlayerCorner.Parent = SpawnFakePlayerButton

local SpawnFakePlayerStroke = Instance.new('UIStroke')
SpawnFakePlayerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SpawnFakePlayerStroke.Color = Color3.fromRGB(74, 207, 255)
SpawnFakePlayerStroke.Thickness = 1.0
SpawnFakePlayerStroke.Transparency = 0.3
SpawnFakePlayerStroke.Parent = SpawnFakePlayerButton

SpawnFakePlayerButton.MouseButton1Click:Connect(function()
    local petData = nil
    local petFlags = nil

    if CONFIG.SPAWN_FAKE_PLAYER_WITH_RANDOM_PET then
        -- MODIFIED: Only spawn with Balloon Unicorn or higher pets
        local highValuePet = getRandomHighValuePet()

        -- Set pet flags based on selected type
        petFlags = {
            M = currentFakePetType == 'mega', -- Mega Neon
            N = currentFakePetType == 'neon', -- Neon
            F = true, -- Always flyable for riding
            R = true, -- Always rideable
        }

        petData = {
            kind = GetKindPet(highValuePet),
        }

        print('Spawning fake player with high-value pet:', highValuePet)
    end

    CreateFakePlayerCharacterFromPARTNER_NAME(
        CONFIG.PARTNER_NAME,
        Players:GetUserIdFromNameAsync(CONFIG.PARTNER_NAME),
        petData,
        petFlags
    )
end)

local spacer9 = Instance.new('Frame')
spacer9.Size = UDim2.new(1, 0, 0, 3)
spacer9.BackgroundTransparency = 1
spacer9.Parent = controlFrame

local SpawnWithPetsButton = Instance.new('TextButton')
SpawnWithPetsButton.Size = UDim2.new(1, 0, 0, 12)
SpawnWithPetsButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
SpawnWithPetsButton.BackgroundTransparency = 0.2
SpawnWithPetsButton.Text = 'Spawn with random pet: false'
SpawnWithPetsButton.Font = Enum.Font.FredokaOne
SpawnWithPetsButton.TextSize = 6
SpawnWithPetsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnWithPetsButton.Parent = controlFrame
local SpawnWithPetsCorner = Instance.new('UICorner')
SpawnWithPetsCorner.CornerRadius = UDim.new(0, 3)
SpawnWithPetsCorner.Parent = SpawnWithPetsButton
local SpawnWithPetsStroke = Instance.new('UIStroke')
SpawnWithPetsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SpawnWithPetsStroke.Color = Color3.fromRGB(255, 100, 100)
SpawnWithPetsStroke.Thickness = 0.8
SpawnWithPetsStroke.Transparency = 0.3
SpawnWithPetsStroke.Parent = SpawnWithPetsButton
SpawnWithPetsButton.MouseButton1Click:Connect(function()
    CONFIG.SPAWN_FAKE_PLAYER_WITH_RANDOM_PET =
        not CONFIG.SPAWN_FAKE_PLAYER_WITH_RANDOM_PET
    SpawnWithPetsButton.Text = 'Spawn with random pet: '
        .. (CONFIG.SPAWN_FAKE_PLAYER_WITH_RANDOM_PET and 'true' or 'false')
    if CONFIG.SPAWN_FAKE_PLAYER_WITH_RANDOM_PET then
        SpawnWithPetsButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        SpawnWithPetsStroke.Color = Color3.fromRGB(100, 255, 100)
    else
        SpawnWithPetsButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        SpawnWithPetsStroke.Color = Color3.fromRGB(255, 100, 100)
    end
end)

local spacer10 = Instance.new('Frame')
spacer10.Size = UDim2.new(1, 0, 0, 3)
spacer10.BackgroundTransparency = 1
spacer10.Parent = controlFrame
local DeleteFakePlayerButton = Instance.new('TextButton')
DeleteFakePlayerButton.Size = UDim2.new(1, 0, 0, 12)
DeleteFakePlayerButton.BackgroundColor3 = Color3.fromRGB(157, 58, 0)
DeleteFakePlayerButton.BackgroundTransparency = 0.2
DeleteFakePlayerButton.Text = 'Delete all fake players'
DeleteFakePlayerButton.Font = Enum.Font.FredokaOne
DeleteFakePlayerButton.TextSize = 6
DeleteFakePlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteFakePlayerButton.Parent = controlFrame
local DeleteFakePlayerCorner = Instance.new('UICorner')
DeleteFakePlayerCorner.CornerRadius = UDim.new(0, 3)
DeleteFakePlayerCorner.Parent = DeleteFakePlayerButton
local DeleteFakePlayerStroke = Instance.new('UIStroke')
DeleteFakePlayerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DeleteFakePlayerStroke.Color = Color3.fromRGB(255, 0, 0)
DeleteFakePlayerStroke.Thickness = 0.8
DeleteFakePlayerStroke.Transparency = 0.3
DeleteFakePlayerStroke.Parent = DeleteFakePlayerButton

DeleteFakePlayerButton.MouseButton1Click:Connect(function()
    pcall(function()
        -- Stop animation manager first
        AnimationManager:Stop()

        -- Clean up all fake pet data from game systems
        for _, petData in ipairs(FakePetRegistry) do
            if petData and petData.model then
                -- Remove from ClientData
                pcall(function()
                    updateData('pet_char_wrappers', function(petWrappers)
                        for i = #petWrappers, 1, -1 do
                            if
                                petWrappers[i].pet_unique
                                == petData.wrapper.pet_unique
                            then
                                table.remove(petWrappers, i)
                            end
                        end
                        return petWrappers
                    end)
                end)

                pcall(function()
                    updateData('pet_state_managers', function(petStates)
                        for i = #petStates, 1, -1 do
                            if petStates[i].char == petData.model then
                                table.remove(petStates, i)
                            end
                        end
                        return petStates
                    end)
                end)
            end
        end

        -- Destroy all fake player folders
        for _, folder in pairs(FakePlayers) do
            if folder and folder.Parent then
                folder:Destroy()
            end
        end

        -- Clear registries
        FakePlayers = {}
        FakePetRegistry = {}

        -- Clear fake player IDs
        fakePlayerIds = {}
        _G.fakePlayerIds = {}

        print('âœ… All fake players and pets deleted successfully')
    end)
end)

-- Initialize mock trade function (now automatically shows trade request)
local function initializeMockTrade()
    if mockState.active then
        return
    end

    -- Automatically show trade request when starting trade
    task.spawn(showTradeRequest)
end

initButton.MouseButton1Click:Connect(function()
    initializeMockTrade()
end)

-- Settings update functions
partnerBox.FocusLost:Connect(function()
    updatePartnerFromUsername(partnerBox.Text)
end)

acceptBox.FocusLost:Connect(function()
    local value = tonumber(acceptBox.Text)
    if value and value >= 0 then
        CONFIG.AUTO_ACCEPT_DELAY = value
    else
        acceptBox.Text = tostring(CONFIG.AUTO_ACCEPT_DELAY)
    end
end)

confirmBox.FocusLost:Connect(function()
    local value = tonumber(confirmBox.Text)
    if value and value >= 0 then
        CONFIG.AUTO_CONFIRM_DELAY = value
    else
        confirmBox.Text = tostring(CONFIG.AUTO_CONFIRM_DELAY)
    end
end)

spectatorBox.FocusLost:Connect(function()
    local value = tonumber(spectatorBox.Text)
    if value and value >= 0 then
        CONFIG.SPECTATOR_COUNT = value
        if mockState.trade then
            mockState.trade.subscriber_count = value
            if TradeApp.refresh_all then
                TradeApp:refresh_all()
                FriendHighlight(true)
            end
        end
    else
        spectatorBox.Text = tostring(CONFIG.SPECTATOR_COUNT)
    end
end)

requestDelayBox.FocusLost:Connect(function()
    local value = tonumber(requestDelayBox.Text)
    if value and value >= 0 then
        CONFIG.TRADE_REQUEST_DELAY = value
    else
        requestDelayBox.Text = tostring(CONFIG.TRADE_REQUEST_DELAY)
    end
end)

-- PLAYERS TAB with smaller elements
local playersFrame = tabFrames['Players']

local playerListFrame = Instance.new('ScrollingFrame')
playerListFrame.Size = UDim2.new(1, 0, 1, 0)
playerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
playerListFrame.BackgroundTransparency = 0.5
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
playerListFrame.ScrollBarImageTransparency = 0.5
playerListFrame.Parent = playersFrame

local listCorner = Instance.new('UICorner')
listCorner.CornerRadius = UDim.new(0, 4)
listCorner.Parent = playerListFrame

local playerListLayout = Instance.new('UIListLayout')
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 3)
playerListLayout.Parent = playerListFrame

local listPadding = Instance.new('UIPadding')
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingBottom = UDim.new(0, 4)
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 4)
listPadding.Parent = playerListFrame

function createPlayerButton(player, index)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, -8, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.BackgroundTransparency = 0.2
    button.Text = ''
    button.Parent = playerListFrame

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(80, 80, 80)
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button

    local nameLabel = Instance.new('TextLabel')
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.new(0, 4, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 0
    nameLabel.Parent = button

    local nameStroke = Instance.new('UIStroke')
    nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    nameStroke.Color = Color3.new(0, 0, 0)
    nameStroke.Thickness = 0.8
    nameStroke.Transparency = 0.8
    nameStroke.Parent = nameLabel

    button.BackgroundTransparency = 1
    buttonStroke.Transparency = 1
    nameLabel.TextTransparency = 1
    nameStroke.Transparency = 1

    button.MouseButton1Click:Connect(function()
        local originalSize = button.Size

        TweenService:Create(
            button,
            TweenInfo.new(
                0.08,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset - 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset - 2
                ),
            }
        ):Play()

        task.wait(0.08)

        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        setActiveTab('Control')

        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 150, 255),
                    Thickness = 1.2,
                }
            )
            :Play()

        partnerBox.Text = player.Name
        updatePartnerFromUsername(player.Name)

        task.wait(0.5)

        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 0.8,
                }
            )
            :Play()
    end)

    button.LayoutOrder = index

    return button
end

function createSelectPlayerFromTradeButton()
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, -8, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(65, 65, 81)
    button.BackgroundTransparency = 0.2
    button.Name = 'SelectFromTradeButton'
    button.Text = ''
    button.Parent = playerListFrame

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(159, 159, 159)
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button

    local nameLabel = Instance.new('TextLabel')
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.new(0, 4, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = 'Select Partner From Trade'
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 0
    nameLabel.Parent = button

    local nameStroke = Instance.new('UIStroke')
    nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    nameStroke.Color = Color3.new(0, 0, 0)
    nameStroke.Thickness = 0.8
    nameStroke.Transparency = 0.8
    nameStroke.Parent = nameLabel

    button.MouseButton1Click:Connect(function()
        local originalSize = button.Size

        TweenService:Create(
            button,
            TweenInfo.new(
                0.08,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset - 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset - 2
                ),
            }
        ):Play()

        task.wait(0.08)

        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        setActiveTab('Control')

        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 150, 255),
                    Thickness = 1.2,
                }
            )
            :Play()

        pcall(function()
            local function getPlayerByNameInsensitive(name)
                name = string.lower(name)
                for _, player in ipairs(Players:GetPlayers()) do
                    if string.lower(player.Name) == name then
                        return player
                    end
                end
                return nil
            end

            local TradePart =
                Players.LocalPlayer.PlayerGui.TradeApp.Frame.NegotiationFrame.Header.PartnerFrame.NameLabel.Text
            local Player = getPlayerByNameInsensitive(TradePart)
            partnerBox.Text = Player.Name
            updatePartnerFromUsername(Player.Name)
        end)

        task.wait(0.5)

        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 0.8,
                }
            )
            :Play()
    end)

    button.LayoutOrder = -999

    return button
end

createSelectPlayerFromTradeButton()

function animatePlayerList()
    for i, button in ipairs(playerListButtons) do
        local delay = (i - 1) * 0.07

        task.spawn(function()
            task.wait(delay)

            local buttonStroke = button:FindFirstChildOfClass('UIStroke')
            local nameLabel = button:FindFirstChildOfClass('TextLabel')
            local nameStroke = nameLabel
                and nameLabel:FindFirstChildOfClass('UIStroke')

            local stage1 = TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            local stage2 = TweenInfo.new(
                0.3,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            local stage3 = TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

            TweenService:Create(button, stage1, {
                Size = UDim2.new(1.02, -8, 0, 30),
                Position = UDim2.new(-0.01, 0, 0, 0),
                BackgroundTransparency = 0.4,
            }):Play()

            task.wait(0.12)

            TweenService:Create(button, stage2, {
                Size = UDim2.new(1, -8, 0, 28),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 0.2,
            }):Play()

            if buttonStroke then
                TweenService:Create(buttonStroke, stage2, {
                    Thickness = 1.0,
                    Transparency = 0.3,
                }):Play()
            end

            task.wait(0.08)

            if nameLabel then
                TweenService:Create(nameLabel, stage3, { TextTransparency = 0 })
                    :Play()
            end
            if nameStroke then
                TweenService:Create(nameStroke, stage3, { Transparency = 0.8 })
                    :Play()
            end
        end)
    end
end

function refreshPlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if
            child:IsA('TextButton')
            and child.Name ~= 'SelectFromTradeButton'
        then
            child:Destroy()
        end
    end
    playerListButtons = {}

    local playersList = Players:GetPlayers()
    table.sort(playersList, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    for i, player in ipairs(playersList) do
        local button = createPlayerButton(player, i)
        table.insert(playerListButtons, button)
    end

    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, (#playersList * 32) + 8)
end

refreshPlayerList()

Players.PlayerAdded:Connect(function()
    hasShownAnimation['Players'] = false
    refreshPlayerList()
    if currentTab == 'Players' then
        hasShownAnimation['Players'] = true
        animatePlayerList()
    end
end)

Players.PlayerRemoving:Connect(function()
    hasShownAnimation['Players'] = false
    refreshPlayerList()
    if currentTab == 'Players' then
        hasShownAnimation['Players'] = true
        animatePlayerList()
    end
end)

-- USERS TAB with smaller elements
local usersFrame = tabFrames['Users']

-- User selection section
local userListFrame = Instance.new('ScrollingFrame')
userListFrame.Size = UDim2.new(1, 0, 0, 100)
userListFrame.Position = UDim2.new(0, 0, 0, 0)
userListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
userListFrame.BackgroundTransparency = 0.5
userListFrame.BorderSizePixel = 0
userListFrame.ScrollBarThickness = 4
userListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
userListFrame.ScrollBarImageTransparency = 0.5
userListFrame.Parent = usersFrame

local userListCorner = Instance.new('UICorner')
userListCorner.CornerRadius = UDim.new(0, 4)
userListCorner.Parent = userListFrame

local userListLayout = Instance.new('UIListLayout')
userListLayout.SortOrder = Enum.SortOrder.LayoutOrder
userListLayout.Padding = UDim.new(0, 3)
userListLayout.Parent = userListFrame

local userListPadding = Instance.new('UIPadding')
userListPadding.PaddingTop = UDim.new(0, 4)
userListPadding.PaddingBottom = UDim.new(0, 4)
userListPadding.PaddingLeft = UDim.new(0, 4)
userListPadding.PaddingRight = UDim.new(0, 4)
userListPadding.Parent = userListFrame

-- Chat messages section
local chatSection = Instance.new('Frame')
chatSection.Size = UDim2.new(1, 0, 0, 170)
chatSection.Position = UDim2.new(0, 0, 0, 105)
chatSection.BackgroundTransparency = 1
chatSection.Parent = usersFrame

local chatHeading = Instance.new('TextLabel')
chatHeading.Size = UDim2.new(1, 0, 0, 14)
chatHeading.BackgroundTransparency = 1
chatHeading.Text = 'Chat Messages'
chatHeading.Font = Enum.Font.SourceSansSemibold
chatHeading.TextSize = 10
chatHeading.TextColor3 = Color3.fromRGB(180, 180, 180)
chatHeading.TextXAlignment = Enum.TextXAlignment.Left
chatHeading.Parent = chatSection

local chatListFrame = Instance.new('ScrollingFrame')
chatListFrame.Size = UDim2.new(1, 0, 0, 154)
chatListFrame.Position = UDim2.new(0, 0, 0, 16)
chatListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
chatListFrame.BackgroundTransparency = 0.5
chatListFrame.BorderSizePixel = 0
chatListFrame.ScrollBarThickness = 4
chatListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
chatListFrame.ScrollBarImageTransparency = 0.5
chatListFrame.Parent = chatSection

local chatListCorner = Instance.new('UICorner')
chatListCorner.CornerRadius = UDim.new(0, 4)
chatListCorner.Parent = chatListFrame

local chatListLayout = Instance.new('UIListLayout')
chatListLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatListLayout.Padding = UDim.new(0, 3)
chatListLayout.Parent = chatListFrame

local chatListPadding = Instance.new('UIPadding')
chatListPadding.PaddingTop = UDim.new(0, 4)
chatListPadding.PaddingBottom = UDim.new(0, 4)
chatListPadding.PaddingLeft = UDim.new(0, 4)
chatListPadding.PaddingRight = UDim.new(0, 4)
chatListPadding.Parent = chatListFrame

local customUsers = {
    'Agusmareborn',
    'Kellyvault',
    'J3llynoah',
    'Rainbowriley321',
    'Bobazmalibu',
    'H3llSANG3LX',
    'Xcallmeholly',
    'Niniko_201999',
    'Hugso09',
    'ruthjavxn',
    'bwpico',
    'Hugeinvestor',
    'Barborich2',
    'Underthechemtrailss',
    'Bunzvii',
    'Qwrtylostaccount',
    'Sparklingorangelol',
    'Tr3ndzyy',
    'Jellycmt',
    'Ex4clusiv3',
    'Killersana66',
    'Chasedatfund',
    'Pukgames0',
    'Lathifcal',
    'Tadhghogan009',
    'Firefelineyt',
    'Jasperisdic',
    'Coalberto',
    'Mouasx',
    'CodyPlays',
    'GustaboStraw',
    'Medinololboi',
    'Mousey_321',
    'AuraBossFarms',
    'Track_T0R',
    'Moon_Shadow3A',
    'Textymax',
    'Alisawants',
    'Colemule',
    'ColdShadow',
    'EvergreenPlane',
    'Elisacanlisten',
    'Money_Money1000',
    'Adelf_Heitler',
    'Mangowewuwu',
    'ChipsYdeutsch',
    'CheasyCheese',
    'GusPlaysYou',
    'Miami_City',
    'ZodicolWantsPets',
    'Moe_Farmsthegrass',
    'Sillyoldgoose',
    'ObamaBeenLoading',
    'Giraffe_Carrot',
    '89OliverWest',
}

function createUserButton(name, index)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, -8, 0, 26)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.BackgroundTransparency = 0.2
    button.Text = ''
    button.Parent = userListFrame

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(80, 80, 80)
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button

    local nameLabel = Instance.new('TextLabel')
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.new(0, 4, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 10
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 0
    nameLabel.Parent = button

    local nameStroke = Instance.new('UIStroke')
    nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    nameStroke.Color = Color3.new(0, 0, 0)
    nameStroke.Thickness = 0.8
    nameStroke.Transparency = 0.8
    nameStroke.Parent = nameLabel

    button.BackgroundTransparency = 1
    buttonStroke.Transparency = 1
    nameLabel.TextTransparency = 1
    nameStroke.Transparency = 1

    button.MouseButton1Click:Connect(function()
        local originalSize = button.Size
        TweenService:Create(
            button,
            TweenInfo.new(
                0.08,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset - 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset - 2
                ),
            }
        ):Play()
        task.wait(0.08)
        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        setActiveTab('Control')
        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 150, 255),
                    Thickness = 1.2,
                }
            )
            :Play()

        partnerBox.Text = name
        updatePartnerFromUsername(name)

        task.wait(0.5)
        TweenService
            :Create(
                partnerStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 0.8,
                }
            )
            :Play()
    end)

    button.LayoutOrder = index
    return button
end

function createChatButton(message, index)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, -8, 0, 26)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.BackgroundTransparency = 0.2
    button.Text = ''
    button.Parent = chatListFrame

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(100, 100, 150)
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button

    local messageLabel = Instance.new('TextLabel')
    messageLabel.Size = UDim2.new(1, -8, 1, 0)
    messageLabel.Position = UDim2.new(0, 4, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.FredokaOne
    messageLabel.TextSize = 9
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextTransparency = 0
    messageLabel.Parent = button

    local messageStroke = Instance.new('UIStroke')
    messageStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    messageStroke.Color = Color3.new(0, 0, 0)
    messageStroke.Thickness = 0.8
    messageStroke.Transparency = 0.8
    messageStroke.Parent = messageLabel

    button.BackgroundTransparency = 1
    buttonStroke.Transparency = 1
    messageLabel.TextTransparency = 1
    messageStroke.Transparency = 1

    button.MouseButton1Click:Connect(function()
        local originalSize = button.Size
        TweenService:Create(
            button,
            TweenInfo.new(
                0.08,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset - 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset - 2
                ),
            }
        ):Play()
        task.wait(0.08)
        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        if mockState.active and mockState.trade then
            sendTradeChatMessage(message)
        end
    end)

    button.LayoutOrder = index
    return button
end

function buildUsersList()
    for _, child in ipairs(userListFrame:GetChildren()) do
        if child:IsA('TextButton') then
            child:Destroy()
        end
    end
    userListButtons = {}

    for i, name in ipairs(customUsers) do
        local b = createUserButton(name, i)
        table.insert(userListButtons, b)
    end
    userListFrame.CanvasSize = UDim2.new(0, 0, 0, (#customUsers * 29) + 8)
end

function buildChatList()
    for _, child in ipairs(chatListFrame:GetChildren()) do
        if child:IsA('TextButton') then
            child:Destroy()
        end
    end

    for i, message in ipairs(CONFIG.CHAT_MESSAGES) do
        createChatButton(message, i)
    end
    chatListFrame.CanvasSize =
        UDim2.new(0, 0, 0, (#CONFIG.CHAT_MESSAGES * 29) + 8)
end

function animateUserList()
    for i, button in ipairs(userListButtons) do
        local delay = (i - 1) * 0.05
        task.spawn(function()
            task.wait(delay)
            local buttonStroke = button:FindFirstChildOfClass('UIStroke')
            local nameLabel = button:FindFirstChildOfClass('TextLabel')
            local nameStroke = nameLabel
                and nameLabel:FindFirstChildOfClass('UIStroke')

            local stage1 = TweenInfo.new(
                0.1,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            local stage2 = TweenInfo.new(
                0.25,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            local stage3 = TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

            TweenService:Create(button, stage1, {
                Size = UDim2.new(1.02, -8, 0, 28),
                Position = UDim2.new(-0.01, 0, 0, 0),
                BackgroundTransparency = 0.4,
            }):Play()

            task.wait(0.1)

            TweenService:Create(button, stage2, {
                Size = UDim2.new(1, -8, 0, 26),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 0.2,
            }):Play()

            if buttonStroke then
                TweenService:Create(buttonStroke, stage2, {
                    Thickness = 1.0,
                    Transparency = 0.3,
                }):Play()
            end

            task.wait(0.06)

            if nameLabel then
                TweenService:Create(nameLabel, stage3, { TextTransparency = 0 })
                    :Play()
            end
            if nameStroke then
                TweenService:Create(nameStroke, stage3, { Transparency = 0.8 })
                    :Play()
            end
        end)
    end

    -- Animate chat buttons
    for i, button in ipairs(chatListFrame:GetChildren()) do
        if button:IsA('TextButton') then
            local delay = (i - 1) * 0.05
            task.spawn(function()
                task.wait(delay)
                local buttonStroke = button:FindFirstChildOfClass('UIStroke')
                local messageLabel = button:FindFirstChildOfClass('TextLabel')
                local messageStroke = messageLabel
                    and messageLabel:FindFirstChildOfClass('UIStroke')

                local stage1 = TweenInfo.new(
                    0.1,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                )
                local stage2 = TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                )
                local stage3 = TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                )

                TweenService
                    :Create(button, stage1, {
                        Size = UDim2.new(1.02, -8, 0, 28),
                        Position = UDim2.new(-0.01, 0, 0, 0),
                        BackgroundTransparency = 0.4,
                    })
                    :Play()

                task.wait(0.1)

                TweenService
                    :Create(button, stage2, {
                        Size = UDim2.new(1, -8, 0, 26),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 0.2,
                    })
                    :Play()

                if buttonStroke then
                    TweenService
                        :Create(buttonStroke, stage2, {
                            Thickness = 1.0,
                            Transparency = 0.3,
                        })
                        :Play()
                end

                task.wait(0.06)

                if messageLabel then
                    TweenService
                        :Create(messageLabel, stage3, { TextTransparency = 0 })
                        :Play()
                end
                if messageStroke then
                    TweenService
                        :Create(messageStroke, stage3, { Transparency = 0.8 })
                        :Play()
                end
            end)
        end
    end
end

buildUsersList()
buildChatList()

-- PETS TAB with smaller elements
local petsFrame = tabFrames['Pets']

-- Pet input section
local petInputSection = Instance.new('Frame')
petInputSection.Size = UDim2.new(1, 0, 0, 160)
petInputSection.Position = UDim2.new(0, 0, 0, 0)
petInputSection.BackgroundTransparency = 1
petInputSection.Parent = petsFrame

local petNameHeading = Instance.new('TextLabel')
petNameHeading.Size = UDim2.new(1, 0, 0, 14)
petNameHeading.BackgroundTransparency = 1
petNameHeading.Text = 'Pet Name To Add'
petNameHeading.Font = Enum.Font.SourceSansSemibold
petNameHeading.TextSize = 10
petNameHeading.TextColor3 = Color3.fromRGB(180, 180, 180)
petNameHeading.TextXAlignment = Enum.TextXAlignment.Left
petNameHeading.Parent = petInputSection

local petNameBox = Instance.new('TextBox')
petNameBox.Size = UDim2.new(1, 0, 0, 22)
petNameBox.Position = UDim2.new(0, 0, 0, 16)
petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
petNameBox.BackgroundTransparency = 0.2
petNameBox.Text = ''
petNameBox.PlaceholderText = 'Enter pet name...'
petNameBox.Font = Enum.Font.FredokaOne
petNameBox.TextSize = 10
petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.ClearTextOnFocus = false
petNameBox.Parent = petInputSection

local petNameCorner = Instance.new('UICorner')
petNameCorner.CornerRadius = UDim.new(0, 4)
petNameCorner.Parent = petNameBox

local petNameStroke = Instance.new('UIStroke')
petNameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
petNameStroke.Color = Color3.fromRGB(100, 100, 100)
petNameStroke.Thickness = 0.8
petNameStroke.Transparency = 0.5
petNameStroke.Parent = petNameBox

function capitalizeWords(str)
    local result = ''
    local i = 1
    local n = #str

    while i <= n do
        if str:sub(i, i):match('%S') then
            local wordStart = i
            while i <= n and str:sub(i, i):match('%S') do
                i = i + 1
            end
            local word = str:sub(wordStart, i - 1)
            if #word > 0 then
                word = word:sub(1, 1):upper() .. word:sub(2):lower()
            end
            result = result .. word
        else
            result = result .. str:sub(i, i)
            i = i + 1
        end
    end

    return result
end

petNameBox:GetPropertyChangedSignal('Text'):Connect(function()
    local inputText = petNameBox.Text
    local newText = capitalizeWords(inputText)
    if newText ~= inputText then
        petNameBox.Text = newText
        return
    end

    local displayedText = petNameBox.Text
    local cleanName = displayedText:lower():gsub('%s+', '')

    local isValid = false
    for _, name in ipairs(petSpawnState.validPetNames) do
        if
            name:lower() == displayedText:lower()
            or name:lower():gsub('%s+', '') == cleanName
        then
            isValid = true
            break
        end
    end

    TweenService
        :Create(petNameStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Color = isValid and Color3.fromRGB(0, 255, 100)
                or displayedText == '' and Color3.fromRGB(100, 100, 100)
                or Color3.fromRGB(255, 100, 100),
            Thickness = isValid and 1.2 or 0.8,
        })
        :Play()
end)

local propContainer = Instance.new('Frame')
propContainer.Size = UDim2.new(1, 0, 0, 22)
propContainer.Position = UDim2.new(0, 0, 0, 43)
propContainer.BackgroundTransparency = 1
propContainer.Parent = petInputSection

local prefixes = { 'M', 'N', 'F', 'R' }
local prefixColors = {
    M = Color3.fromRGB(170, 0, 255),
    N = Color3.fromRGB(0, 255, 100),
    F = Color3.fromRGB(0, 200, 255),
    R = Color3.fromRGB(255, 50, 150),
}

local prefixButtons = {}
for i, prefix in ipairs(prefixes) do
    local prefixButton = Instance.new('TextButton')
    prefixButton.Size = UDim2.new(0.23, 0, 1, 0)
    prefixButton.Position = UDim2.new((i - 1) * 0.25 + 0.01, 0, 0, 0)
    prefixButton.Text = prefix
    prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    prefixButton.BackgroundTransparency = 0.2
    prefixButton.Font = Enum.Font.FredokaOne
    prefixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    prefixButton.TextSize = 12
    prefixButton.Parent = propContainer

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = prefixButton

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = prefixColors[prefix]
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = prefixButton

    local textStroke = Instance.new('UIStroke')
    textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    textStroke.Color = Color3.new(0, 0, 0)
    textStroke.Thickness = 1.0
    textStroke.Parent = prefixButton

    prefixButtons[prefix] = { button = prefixButton, stroke = buttonStroke }

    prefixButton.MouseButton1Click:Connect(function()
        if prefix == 'M' and petSpawnState.activeFlags['N'] then
            return
        end
        if prefix == 'N' and petSpawnState.activeFlags['M'] then
            return
        end

        petSpawnState.activeFlags[prefix] =
            not petSpawnState.activeFlags[prefix]

        if petSpawnState.activeFlags[prefix] then
            prefixButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            TweenService
                :Create(
                    buttonStroke,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                    {
                        Color = Color3.fromRGB(0, 255, 0),
                        Thickness = 1.2,
                        Transparency = 0.2,
                    }
                )
                :Play()
        else
            prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            TweenService
                :Create(
                    buttonStroke,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                    {
                        Color = prefixColors[prefix],
                        Thickness = 1.0,
                        Transparency = 0.5,
                    }
                )
                :Play()
        end
    end)
end

local requestAddPetBox, requestAddPetStroke, requestAddPetText =
    createSettingRow(
        'Add Pet Delay (s)',
        CONFIG.ADD_PET_REQUEST_DELAY,
        petInputSection
    )
requestAddPetBox.Position = UDim2.new(0, 0, 0, 72)
requestAddPetText.Position = UDim2.new(0, 0, 0, 58)
requestAddPetBox.FocusLost:Connect(function()
    local value = tonumber(requestAddPetBox.Text)
    if value and value >= 0 then
        CONFIG.ADD_PET_REQUEST_DELAY = value
    else
        requestAddPetBox.Text = tostring(CONFIG.ADD_PET_REQUEST_DELAY)
    end
end)

-- SMALLER Add Pet Button
local addPetButton = Instance.new('TextButton')
addPetButton.Size = UDim2.new(1, 0, 0, 22)
addPetButton.Position = UDim2.new(0, 0, 0, 98)
addPetButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
addPetButton.BackgroundTransparency = 0.2
addPetButton.Text = 'Add Pet to Trade'
addPetButton.Font = Enum.Font.FredokaOne
addPetButton.TextSize = 10
addPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addPetButton.Parent = petInputSection

local addPetCorner = Instance.new('UICorner')
addPetCorner.CornerRadius = UDim.new(0, 4)
addPetCorner.Parent = addPetButton

local addPetStroke = Instance.new('UIStroke')
addPetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
addPetStroke.Color = Color3.fromRGB(255, 255, 255)
addPetStroke.Thickness = 1.0
addPetStroke.Transparency = 0.3
addPetStroke.Parent = addPetButton

-- SMALLER Remove Pet Button
local removePetButton = Instance.new('TextButton')
removePetButton.Size = UDim2.new(1, 0, 0, 22)
removePetButton.Position = UDim2.new(0, 0, 0, 125)
removePetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
removePetButton.BackgroundTransparency = 0.2
removePetButton.Text = 'Remove Latest Pet'
removePetButton.Font = Enum.Font.FredokaOne
removePetButton.TextSize = 10
removePetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removePetButton.Parent = petInputSection

local removePetCorner = Instance.new('UICorner')
removePetCorner.CornerRadius = UDim.new(0, 4)
removePetCorner.Parent = removePetButton

local removePetStroke = Instance.new('UIStroke')
removePetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
removePetStroke.Color = Color3.fromRGB(255, 100, 100)
removePetStroke.Thickness = 1.0
removePetStroke.Transparency = 0.3
removePetStroke.Parent = removePetButton

-- MODIFIED: Add Random Pet Button - Only adds high-value pets
local addRandomPetButton = Instance.new('TextButton')
addRandomPetButton.Size = UDim2.new(1, 0, 0, 22)
addRandomPetButton.Position = UDim2.new(0, 0, 0, 152)
addRandomPetButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
addRandomPetButton.BackgroundTransparency = 0.2
addRandomPetButton.Text = 'Add Random High-Value Pet'
addRandomPetButton.Font = Enum.Font.FredokaOne
addRandomPetButton.TextSize = 9
addRandomPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addRandomPetButton.Parent = petInputSection

local addRandomPetCorner = Instance.new('UICorner')
addRandomPetCorner.CornerRadius = UDim.new(0, 4)
addRandomPetCorner.Parent = addRandomPetButton

local addRandomPetStroke = Instance.new('UIStroke')
addRandomPetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
addRandomPetStroke.Color = Color3.fromRGB(200, 100, 255)
addRandomPetStroke.Thickness = 1.0
addRandomPetStroke.Transparency = 0.3
addRandomPetStroke.Parent = addRandomPetButton

-- Integrated Pet List Section - SMALLER
local petListSection = Instance.new('Frame')
petListSection.Size = UDim2.new(1, 0, 0, 110)
petListSection.Position = UDim2.new(0, 0, 0, 179)
petListSection.BackgroundTransparency = 1
petListSection.Parent = petsFrame

local petListHeading = Instance.new('TextLabel')
petListHeading.Size = UDim2.new(1, 0, 0, 14)
petListHeading.BackgroundTransparency = 1
petListHeading.Text = 'High-Value Pets (Balloon Unicorn+)'
petListHeading.Font = Enum.Font.SourceSansSemibold
petListHeading.TextSize = 10
petListHeading.TextColor3 = Color3.fromRGB(180, 180, 180)
petListHeading.TextXAlignment = Enum.TextXAlignment.Left
petListHeading.Parent = petListSection

local petListFrame = Instance.new('ScrollingFrame')
petListFrame.Size = UDim2.new(1, 0, 0, 94)
petListFrame.Position = UDim2.new(0, 0, 0, 16)
petListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
petListFrame.BackgroundTransparency = 0.5
petListFrame.BorderSizePixel = 0
petListFrame.ScrollBarThickness = 4
petListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
petListFrame.ScrollBarImageTransparency = 0.5
petListFrame.Parent = petListSection

local petListCorner = Instance.new('UICorner')
petListCorner.CornerRadius = UDim.new(0, 4)
petListCorner.Parent = petListFrame

local petListLayout = Instance.new('UIListLayout')
petListLayout.SortOrder = Enum.SortOrder.LayoutOrder
petListLayout.Padding = UDim.new(0, 3)
petListLayout.Parent = petListFrame

local petListPadding = Instance.new('UIPadding')
petListPadding.PaddingTop = UDim.new(0, 4)
petListPadding.PaddingBottom = UDim.new(0, 4)
petListPadding.PaddingLeft = UDim.new(0, 4)
petListPadding.PaddingRight = UDim.new(0, 4)
petListPadding.Parent = petListFrame

local petListButtons = {}

function createPetListButton(petName, index)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, -8, 0, 22)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.BackgroundTransparency = 0.2
    button.Text = ''
    button.Parent = petListFrame

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(100, 100, 150)
    buttonStroke.Thickness = 1.0
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button

    local nameLabel = Instance.new('TextLabel')
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.new(0, 4, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = petName
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 0
    nameLabel.Parent = button

    local nameStroke = Instance.new('UIStroke')
    nameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    nameStroke.Color = Color3.new(0, 0, 0)
    nameStroke.Thickness = 0.8
    nameStroke.Transparency = 0.8
    nameStroke.Parent = nameLabel

    button.BackgroundTransparency = 1
    buttonStroke.Transparency = 1
    nameLabel.TextTransparency = 1
    nameStroke.Transparency = 1

    button.MouseButton1Click:Connect(function()
        local originalSize = button.Size
        TweenService:Create(
            button,
            TweenInfo.new(
                0.08,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset - 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset - 2
                ),
            }
        ):Play()
        task.wait(0.08)
        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        petNameBox.Text = petName
        TweenService
            :Create(
                petNameStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 150, 255),
                    Thickness = 1.2,
                }
            )
            :Play()

        task.wait(0.5)
        TweenService
            :Create(
                petNameStroke,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 0.8,
                }
            )
            :Play()
    end)

    button.LayoutOrder = index
    return button
end

-- MODIFIED: Build pet list with only high-value pets
function buildPetList()
    for _, child in ipairs(petListFrame:GetChildren()) do
        if child:IsA('TextButton') then
            child:Destroy()
        end
    end
    petListButtons = {}

    for i, petName in ipairs(highValuePets) do
        local button = createPetListButton(petName, i)
        table.insert(petListButtons, button)
    end
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, (#highValuePets * 25) + 8)
end

function animatePetList()
    for i, button in ipairs(petListButtons) do
        local delay = (i - 1) * 0.05
        task.spawn(function()
            task.wait(delay)
            local buttonStroke = button:FindFirstChildOfClass('UIStroke')
            local nameLabel = button:FindFirstChildOfClass('TextLabel')
            local nameStroke = nameLabel
                and nameLabel:FindFirstChildOfClass('UIStroke')

            local stage1 = TweenInfo.new(
                0.1,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            local stage2 = TweenInfo.new(
                0.25,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            local stage3 = TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

            TweenService:Create(button, stage1, {
                Size = UDim2.new(1.02, -8, 0, 24),
                Position = UDim2.new(-0.01, 0, 0, 0),
                BackgroundTransparency = 0.4,
            }):Play()

            task.wait(0.1)

            TweenService:Create(button, stage2, {
                Size = UDim2.new(1, -8, 0, 22),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 0.2,
            }):Play()

            if buttonStroke then
                TweenService:Create(buttonStroke, stage2, {
                    Thickness = 1.0,
                    Transparency = 0.3,
                }):Play()
            end

            task.wait(0.06)

            if nameLabel then
                TweenService:Create(nameLabel, stage3, { TextTransparency = 0 })
                    :Play()
            end
            if nameStroke then
                TweenService:Create(nameStroke, stage3, { Transparency = 0.8 })
                    :Play()
            end
        end)
    end
end

buildPetList()

-- Button functionality
addPetButton.MouseButton1Click:Connect(function()
    local petName = petNameBox.Text
    if petName and petName ~= '' then
        local success, message =
            addPetToPartnerOffer(petName, petSpawnState.activeFlags)
    end
end)

removePetButton.MouseButton1Click:Connect(function()
    local success, message = removeLatestPetFromPartnerOffer()
end)

addRandomPetButton.MouseButton1Click:Connect(function()
    -- MODIFIED: Only add high-value pets
    local randomPet = getRandomHighValuePet()
    local randomProperties = generateRandomPetProperties()

    local success, message = addPetToPartnerOffer(randomPet, randomProperties)
end)

-- Initialize the GUI and functionality
setActiveTab('Control')

-- Drag functionality
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if
        input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if
        dragging
        and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        )
    then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if
        input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = false
    end
end)
-- Continuous noclip maintenance
task.spawn(function()
    while task.wait(0.5) do
        if noclipEnabled then
            for _, folder in ipairs(FakePlayers) do
                if folder and folder.Parent then
                    for _, part in ipairs(folder:GetDescendants()) do
                        if part:IsA('BasePart') then
                            part.CanCollide = false
                            part.CanTouch = false
                            part.CanQuery = false
                        end
                    end
                end
            end
            for _, petData in ipairs(FakePetRegistry) do
                if petData and petData.model then
                    for _, part in ipairs(petData.model:GetDescendants()) do
                        if part:IsA('BasePart') then
                            part.CanCollide = false
                            part.CanTouch = false
                            part.CanQuery = false
                        end
                    end
                end
            end
        end
    end
end)
-- SPAWNER TAB
local spawnerFrame = tabFrames['Spawner']

-- Spawner UI variables (adapted from spawner.lua)
local spawnerActiveFlags = { F = false, R = false, N = false, M = false }
local spawnerBaseColors = {
    Color3.fromRGB(170, 0, 255), -- Mega Neon (purple)
    Color3.fromRGB(0, 255, 100), -- Neon (green)
    Color3.fromRGB(0, 200, 255), -- Fly (blue)
    Color3.fromRGB(255, 50, 150), -- Ride (pink)
}

-- Spawner pet spawning logic (adapted from spawner.lua)
task.spawn(function()
    local load = require(game.ReplicatedStorage.Fsys).load

    set_thread_identity(2)
    local clientData = load('ClientData')
    local items = load('KindDB')
    local router = load('RouterClient')
    local downloader = load('DownloadClient')
    local animationManager = load('AnimationManager')
    local petRigs = load('new:PetRigs')
    set_thread_identity(8)

    local petModels = {}
    local pets = {}
    local equippedPet = nil
    local mountedPet = nil
    local currentMountTrack = nil

    local function updateData(key, action)
        local data = clientData.get(key)

        local clonedData = table.clone(data)
        clientData.predict(key, action(clonedData))
    end

    local function getUniqueId()
        local HttpService = game:GetService('HttpService')
        return HttpService:GenerateGUID(false)
    end

    local function getPetModel(kind)
        if petModels[kind] then
            return petModels[kind]
        end

        local streamed = downloader.promise_download_copy('Pets', kind):expect()
        petModels[kind] = streamed
        return streamed
    end

    local function createPet(id, properties)
        local uniqueId = getUniqueId()
        local item = items[id]
        if not item then
            warn('Pet ID not found: ' .. id)
            return nil
        end

        set_thread_identity(2)
        local new_pet = {
            unique = uniqueId,
            category = 'pets',
            id = id,
            kind = item.kind,
            newness_order = math.random(1, 900000),
            properties = properties or {},
        }
        local inventory = clientData.get('inventory')
        inventory.pets[uniqueId] = new_pet

        set_thread_identity(8)
        pets[uniqueId] = {
            data = new_pet,
            model = nil,
        }
        return new_pet
    end

    -- Toy spawning function
    local function createToy(id)
        local uniqueId = getUniqueId()
        local item = items[id]
        if not item then
            warn('Toy ID not found: ' .. id)
            return nil
        end

        set_thread_identity(2)
        local new_toy = {
            unique = uniqueId,
            category = 'toys',
            id = id,
            kind = item.kind,
            newness_order = math.random(1, 900000),
            properties = {},
        }
        local inventory = clientData.get('inventory')
        inventory.toys[uniqueId] = new_toy

        set_thread_identity(8)
        return new_toy
    end

    local function neonify(model, entry)
        local petModel = model:FindFirstChild('PetModel')

        if not petModel then
            return
        end

        for neonPart, configuration in pairs(entry.neon_parts) do
            local trueNeonPart =
                petRigs.get(petModel).get_geo_part(petModel, neonPart)
            trueNeonPart.Material = configuration.Material
            trueNeonPart.Color = configuration.Color
        end
    end

    local function addPetWrapper(wrapper)
        updateData('pet_char_wrappers', function(petWrappers)
            wrapper.unique = #petWrappers + 1
            wrapper.index = #petWrappers + 1
            petWrappers[#petWrappers + 1] = wrapper
            return petWrappers
        end)
    end

    local function addPetState(state)
        updateData('pet_state_managers', function(petStates)
            petStates[#petStates + 1] = state
            return petStates
        end)
    end

    local function findIndex(array, finder)
        for index, value in pairs(array) do
            local isIt = finder(value, index)

            if isIt then
                return index
            end
        end

        return nil
    end

    local function removePetWrapper(uniqueId)
        updateData('pet_char_wrappers', function(petWrappers)
            local index = findIndex(petWrappers, function(wrapper)
                return wrapper.pet_unique == uniqueId
            end)

            if not index then
                return petWrappers
            end

            table.remove(petWrappers, index)

            for wrapperIndex, wrapper in pairs(petWrappers) do
                wrapper.unique = wrapperIndex
                wrapper.index = wrapperIndex
            end

            return petWrappers
        end)
    end

    local function clearPetState(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(states)
            local index = findIndex(states, function(state)
                return state.char == pet.model
            end)

            if not index then
                return states
            end

            local clonedStates = table.clone(states)

            clonedStates[index] = table.clone(clonedStates[index])
            clonedStates[index].states = {}

            return clonedStates
        end)
    end

    local function setPetState(uniqueId, id)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(states)
            local index = findIndex(states, function(state)
                return state.char == pet.model
            end)

            if not index then
                return states
            end

            local clonedStates = table.clone(states)

            clonedStates[index] = table.clone(clonedStates[index])
            clonedStates[index].states = {
                { id = id },
            }

            return clonedStates
        end)
    end

    local function attachPlayerToPet(pet)
        local character = game.Players.LocalPlayer.Character

        if not character then
            return false
        end

        if not character.PrimaryPart then
            return false
        end

        local ridePosition = pet:FindFirstChild('RidePosition', true)

        if not ridePosition then
            return false
        end

        local sourceAttachment = Instance.new('Attachment')

        sourceAttachment.Parent = ridePosition
        sourceAttachment.Position = Vector3.new(0, 1.237, 0)
        sourceAttachment.Name = 'SourceAttachment'

        local stateConnection = Instance.new('RigidConstraint')

        stateConnection.Name = 'StateConnection'
        stateConnection.Attachment0 = sourceAttachment
        stateConnection.Attachment1 = character.PrimaryPart.RootAttachment

        stateConnection.Parent = character

        return true
    end

    local function clearPlayerState()
        updateData('state_manager', function(state)
            local clonedState = table.clone(state)
            clonedState.states = {}
            clonedState.is_sitting = false
            return clonedState
        end)
    end

    local function setPlayerState(id)
        updateData('state_manager', function(state)
            local clonedState = table.clone(state)

            clonedState.states = {
                { id = id },
            }

            clonedState.is_sitting = true

            return clonedState
        end)
    end

    local function removePetState(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(petStates)
            local index = findIndex(petStates, function(state)
                return state.char == pet.model
            end)

            if not index then
                return petStates
            end

            table.remove(petStates, index)
            return petStates
        end)
    end

    local function unmount(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        if currentMountTrack then
            currentMountTrack:Stop()
            currentMountTrack:Destroy()
        end

        local sourceAttachment =
            pet.model:FindFirstChild('SourceAttachment', true)

        if sourceAttachment then
            sourceAttachment:Destroy()
        end

        if game.Players.LocalPlayer.Character then
            for _, descendant in
                pairs(game.Players.LocalPlayer.Character:GetDescendants())
            do
                if
                    descendant:IsA('BasePart')
                    and descendant:GetAttribute('HaveMass')
                then
                    descendant.Massless = false
                end
            end
        end

        clearPetState(uniqueId)
        clearPlayerState()

        pet.model:ScaleTo(1)

        mountedPet = nil
    end

    local function mount(uniqueId, playerState, petState)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        local player = game.Players.LocalPlayer

        if not player.Character then
            return
        end

        if not player.Character.PrimaryPart then
            return
        end

        mountedPet = uniqueId

        setPetState(uniqueId, petState)
        setPlayerState(playerState)

        pet.model:ScaleTo(2)
        attachPlayerToPet(pet.model)

        currentMountTrack = player.Character.Humanoid.Animator:LoadAnimation(
            animationManager.get_track('PlayerRidingPet')
        )
        player.Character.Humanoid.Sit = true

        for _, descendant in pairs(player.Character:GetDescendants()) do
            if descendant:IsA('BasePart') and descendant.Massless == false then
                descendant.Massless = true
                descendant:SetAttribute('HaveMass', true)
            end
        end

        currentMountTrack:Play()
    end

    local function fly(uniqueId)
        mount(uniqueId, 'PlayerFlyingPet', 'PetBeingFlown')
    end

    local function ride(uniqueId)
        mount(uniqueId, 'PlayerRidingPet', 'PetBeingRidden')
    end

    local function unequip(item)
        local pet = pets[item.unique]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        unmount(item.unique)

        removePetWrapper(item.unique)
        removePetState(item.unique)

        pet.model:Destroy()
        pet.model = nil

        equippedPet = nil
    end

    local function equip(item)
        -- Only handle pets through this custom system
        if item.category == 'pets' then
            if equippedPet then
                unequip(equippedPet)
            end

            local petModel = getPetModel(item.kind):Clone()
            petModel.Parent = workspace
            pets[item.unique].model = petModel

            if item.properties.neon or item.properties.mega_neon then
                neonify(petModel, items[item.kind])
            end

            equippedPet = item

            addPetWrapper({
                char = petModel,
                mega_neon = item.properties.mega_neon,
                neon = item.properties.neon,
                player = game.Players.LocalPlayer,
                entity_controller = game.Players.LocalPlayer,
                controller = game.Players.LocalPlayer,
                rp_name = item.properties.rp_name or '',
                pet_trick_level = item.properties.pet_trick_level,
                pet_unique = item.unique,
                pet_id = item.id,
                location = {
                    full_destination_id = 'housing',
                    destination_id = 'housing',
                    house_owner = game.Players.LocalPlayer,
                },
                pet_progression = {
                    age = math.random(1, 900000),
                    percentage = math.random(0.01, 0.99),
                },
                are_colors_sealed = false,
                is_pet = true,
            })

            addPetState({
                char = petModel,
                player = game.Players.LocalPlayer,
                store_key = 'pet_state_managers',
                is_sitting = false,
                chars_connected_to_me = {},
                states = {},
            })
        else
            -- For non-pet items, just call the original equip function
            return oldGet('ToolAPI/Equip'):InvokeServer(item.unique)
        end
    end

    local oldGet = router.get

    local function createRemoteFunctionMock(callback)
        return {
            InvokeServer = function(_, ...)
                return callback(...)
            end,
        }
    end

    local function createRemoteEventMock(callback)
        return {
            FireServer = function(_, ...)
                return callback(...)
            end,
        }
    end

    -- Only intercept pet equips
    local equipRemote = createRemoteFunctionMock(function(uniqueId, metadata)
        local pet = pets[uniqueId]

        if pet then
            equip(pet.data)
            return true,
                {
                    action = 'equip',
                    is_server = true,
                }
        end

        -- Forward non-pet equips to original handler
        return oldGet('ToolAPI/Equip'):InvokeServer(uniqueId, metadata)
    end)

    -- Only intercept pet unequips
    local unequipRemote = createRemoteFunctionMock(function(uniqueId)
        local pet = pets[uniqueId]

        if pet then
            unequip(pet.data)
            return true,
                {
                    action = 'unequip',
                    is_server = true,
                }
        end

        -- Forward non-pet unequips to original handler
        return oldGet('ToolAPI/Unequip'):InvokeServer(uniqueId)
    end)

    -- Pet-specific remotes remain unchanged
    local rideRemote = createRemoteFunctionMock(function(item)
        ride(item.pet_unique)
    end)

    local flyRemote = createRemoteFunctionMock(function(item)
        fly(item.pet_unique)
    end)

    local unmountRemoteFunction = createRemoteFunctionMock(function()
        unmount(mountedPet)
    end)

    local unmountRemoteEvent = createRemoteEventMock(function()
        unmount(mountedPet)
    end)

    router.get = function(name)
        -- Only intercept pet-related calls
        if name == 'ToolAPI/Equip' then
            return equipRemote
        elseif name == 'ToolAPI/Unequip' then
            return unequipRemote
        elseif name == 'AdoptAPI/RidePet' then
            return rideRemote
        elseif name == 'AdoptAPI/FlyPet' then
            return flyRemote
        elseif name == 'AdoptAPI/ExitSeatStatesYield' then
            return unmountRemoteFunction
        elseif name == 'AdoptAPI/ExitSeatStates' then
            return unmountRemoteEvent
        end

        -- Pass through all other requests
        return oldGet(name)
    end

    -- Only unequip pets on startup
    for _, charWrapper in pairs(clientData.get('pet_char_wrappers')) do
        oldGet('ToolAPI/Unequip'):InvokeServer(charWrapper.pet_unique)
    end

    local Loads = require(game.ReplicatedStorage.Fsys).load
    local InventoryDB = Loads('InventoryDB')

    function GetPetByName(name)
        for i, v in pairs(InventoryDB.pets) do
            if v.name:lower() == name:lower() then
                return v.id
            end
        end
        return false
    end

    function GetToyByName(name)
        for i, v in pairs(InventoryDB.toys) do
            if v.name:lower() == name:lower() then
                return v.id
            end
        end
        return false
    end

    -- Spawner UI Setup (adapted for integration)
    -- Title label for spawner tab
    local spawnerTitleLabel = Instance.new('TextLabel')
    spawnerTitleLabel.Size = UDim2.new(1, 0, 0, 20)
    spawnerTitleLabel.Position = UDim2.new(0, 0, 0, 0)
    spawnerTitleLabel.BackgroundTransparency = 1
    spawnerTitleLabel.Text = 'Spawner'
    spawnerTitleLabel.Font = Enum.Font.FredokaOne
    spawnerTitleLabel.TextSize = 16
    spawnerTitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    spawnerTitleLabel.Parent = spawnerFrame

    -- Black border around title text
    local spawnerTitleStroke = Instance.new('UIStroke')
    spawnerTitleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerTitleStroke.Color = Color3.new(0, 0, 0)
    spawnerTitleStroke.Thickness = 1.5
    spawnerTitleStroke.Transparency = 0
    spawnerTitleStroke.Parent = spawnerTitleLabel

    -- Tab buttons for Pets/Toys
    local spawnerTabFrame = Instance.new('Frame')
    spawnerTabFrame.Size = UDim2.new(1, 0, 0, 25)
    spawnerTabFrame.Position = UDim2.new(0, 0, 0, 22)
    spawnerTabFrame.BackgroundTransparency = 1
    spawnerTabFrame.Parent = spawnerFrame

    local spawnerPetTab = Instance.new('TextButton')
    spawnerPetTab.Size = UDim2.new(0.5, 0, 1, 0)
    spawnerPetTab.Position = UDim2.new(0, 0, 0, 0)
    spawnerPetTab.Text = 'Pets'
    spawnerPetTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    spawnerPetTab.BackgroundTransparency = 0.1
    spawnerPetTab.Font = Enum.Font.FredokaOne
    spawnerPetTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerPetTab.TextSize = 14
    spawnerPetTab.Parent = spawnerTabFrame

    local spawnerToyTab = Instance.new('TextButton')
    spawnerToyTab.Size = UDim2.new(0.5, 0, 1, 0)
    spawnerToyTab.Position = UDim2.new(0.5, 0, 0, 0)
    spawnerToyTab.Text = 'Toys'
    spawnerToyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    spawnerToyTab.BackgroundTransparency = 0.1
    spawnerToyTab.Font = Enum.Font.FredokaOne
    spawnerToyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerToyTab.TextSize = 14
    spawnerToyTab.Parent = spawnerTabFrame

    -- Tab corners and strokes
    local spawnerTabCorner = Instance.new('UICorner')
    spawnerTabCorner.CornerRadius = UDim.new(0, 6)
    spawnerTabCorner.Parent = spawnerPetTab
    spawnerTabCorner:Clone().Parent = spawnerToyTab

    -- Black border around tab buttons
    local spawnerPetTabBorder = Instance.new('UIStroke')
    spawnerPetTabBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerPetTabBorder.Color = Color3.fromRGB(0, 0, 0)
    spawnerPetTabBorder.Thickness = 2
    spawnerPetTabBorder.Transparency = 0.3
    spawnerPetTabBorder.Parent = spawnerPetTab

    local spawnerToyTabBorder = Instance.new('UIStroke')
    spawnerToyTabBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerToyTabBorder.Color = Color3.fromRGB(0, 0, 0)
    spawnerToyTabBorder.Thickness = 2
    spawnerToyTabBorder.Transparency = 0.3
    spawnerToyTabBorder.Parent = spawnerToyTab

    local spawnerTabStroke = Instance.new('UIStroke')
    spawnerTabStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerTabStroke.Thickness = 1.5
    spawnerTabStroke.Transparency = 0.1
    spawnerTabStroke.Parent = spawnerPetTab
    spawnerTabStroke:Clone().Parent = spawnerToyTab

    local spawnerTabTextStroke = Instance.new('UIStroke')
    spawnerTabTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerTabTextStroke.Color = Color3.new(0, 0, 0)
    spawnerTabTextStroke.Thickness = 1.5
    spawnerTabTextStroke.Transparency = 0
    spawnerTabTextStroke.Parent = spawnerPetTab
    spawnerTabTextStroke:Clone().Parent = spawnerToyTab

    -- Content frames
    local spawnerPetContent = Instance.new('Frame')
    spawnerPetContent.Size = UDim2.new(1, 0, 1, -47)
    spawnerPetContent.Position = UDim2.new(0, 0, 0, 47)
    spawnerPetContent.BackgroundTransparency = 1
    spawnerPetContent.Visible = true
    spawnerPetContent.Parent = spawnerFrame

    local spawnerToyContent = Instance.new('Frame')
    spawnerToyContent.Size = UDim2.new(1, 0, 1, -47)
    spawnerToyContent.Position = UDim2.new(0, 0, 0, 47)
    spawnerToyContent.BackgroundTransparency = 1
    spawnerToyContent.Visible = false
    spawnerToyContent.Parent = spawnerFrame

    -- Force initial visibility states
    spawnerPetContent.Visible = true
    spawnerToyContent.Visible = false

    -- Tab switching
    spawnerPetTab.MouseButton1Click:Connect(function()
        spawnerPetContent.Visible = true
        spawnerToyContent.Visible = false
        spawnerPetTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        spawnerToyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        spawnerPetTabBorder.Color = Color3.fromRGB(255, 255, 255)
        spawnerToyTabBorder.Color = Color3.fromRGB(0, 0, 0)
    end)

    spawnerToyTab.MouseButton1Click:Connect(function()
        spawnerPetContent.Visible = false
        spawnerToyContent.Visible = true
        spawnerPetTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        spawnerToyTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        spawnerPetTabBorder.Color = Color3.fromRGB(0, 0, 0)
        spawnerToyTabBorder.Color = Color3.fromRGB(255, 255, 255)
    end)

    -- Initialize tabs
    spawnerPetTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    spawnerToyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    spawnerPetTabBorder.Color = Color3.fromRGB(255, 255, 255)
    spawnerToyTabBorder.Color = Color3.fromRGB(0, 0, 0)

    -- PET CONTENT (adapted from spawner.lua)
    -- TextBox to input pet name
    local spawnerPetNameBox = Instance.new('TextBox')
    spawnerPetNameBox.Size = UDim2.new(0.85, 0, 0, 28)
    spawnerPetNameBox.Position = UDim2.new(0.075, 0, 0.1, 0)
    spawnerPetNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    spawnerPetNameBox.BackgroundTransparency = 0.2
    spawnerPetNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerPetNameBox.TextSize = 14
    spawnerPetNameBox.Font = Enum.Font.FredokaOne
    spawnerPetNameBox.PlaceholderText = 'Enter Pet Name'
    spawnerPetNameBox.Text = ''
    spawnerPetNameBox.ClearTextOnFocus = false
    spawnerPetNameBox.Parent = spawnerPetContent

    -- Rounded corners
    local spawnerBoxCorner = Instance.new('UICorner')
    spawnerBoxCorner.CornerRadius = UDim.new(0, 6)
    spawnerBoxCorner.Parent = spawnerPetNameBox

    -- Black text outline
    local spawnerTextStroke = Instance.new('UIStroke')
    spawnerTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerTextStroke.Color = Color3.new(0, 0, 0)
    spawnerTextStroke.Thickness = 1.2
    spawnerTextStroke.Transparency = 0
    spawnerTextStroke.Parent = spawnerPetNameBox

    -- Glowing outline
    local spawnerBoxGlow = Instance.new('UIStroke')
    spawnerBoxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerBoxGlow.Color = Color3.fromRGB(255, 255, 255)
    spawnerBoxGlow.Thickness = 2.2
    spawnerBoxGlow.Transparency = 0.25
    spawnerBoxGlow.Parent = spawnerPetNameBox

    -- List button
    local spawnerListButton = Instance.new('TextButton')
    spawnerListButton.Size = UDim2.new(0, 28, 0, 28)
    spawnerListButton.Position = UDim2.new(0.925, 0, 0.1, 0)
    spawnerListButton.Text = 'ðŸ“‹'
    spawnerListButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    spawnerListButton.BackgroundTransparency = 0.2
    spawnerListButton.Font = Enum.Font.FredokaOne
    spawnerListButton.TextSize = 16
    spawnerListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerListButton.Parent = spawnerPetContent

    local spawnerListButtonCorner = Instance.new('UICorner')
    spawnerListButtonCorner.CornerRadius = UDim.new(0, 6)
    spawnerListButtonCorner.Parent = spawnerListButton

    local spawnerListButtonStroke = Instance.new('UIStroke')
    spawnerListButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerListButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerListButtonStroke.Thickness = 1.5
    spawnerListButtonStroke.Transparency = 0.3
    spawnerListButtonStroke.Parent = spawnerListButton

    -- Dropdown menu frame
    local spawnerDropdownFrame = Instance.new('Frame')
    spawnerDropdownFrame.Size = UDim2.new(0.85, 0, 0, 120)
    spawnerDropdownFrame.Position = UDim2.new(0.075, 0, 0.2, 0)
    spawnerDropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    spawnerDropdownFrame.BackgroundTransparency = 0.1
    spawnerDropdownFrame.BorderSizePixel = 0
    spawnerDropdownFrame.Visible = false
    spawnerDropdownFrame.ZIndex = 10
    spawnerDropdownFrame.Parent = spawnerPetContent

    local spawnerDropdownCorner = Instance.new('UICorner')
    spawnerDropdownCorner.CornerRadius = UDim.new(0, 8)
    spawnerDropdownCorner.Parent = spawnerDropdownFrame

    local spawnerDropdownStroke = Instance.new('UIStroke')
    spawnerDropdownStroke.Color = Color3.fromRGB(170, 0, 255)
    spawnerDropdownStroke.Thickness = 2
    spawnerDropdownStroke.Transparency = 0.3
    spawnerDropdownStroke.Parent = spawnerDropdownFrame

    -- Dropdown scrolling frame
    local spawnerDropdownScroll = Instance.new('ScrollingFrame')
    spawnerDropdownScroll.Size = UDim2.new(1, 0, 1, 0)
    spawnerDropdownScroll.BackgroundTransparency = 1
    spawnerDropdownScroll.ScrollBarThickness = 4
    spawnerDropdownScroll.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
    spawnerDropdownScroll.Parent = spawnerDropdownFrame

    local spawnerDropdownLayout = Instance.new('UIListLayout')
    spawnerDropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    spawnerDropdownLayout.Padding = UDim.new(0, 2)
    spawnerDropdownLayout.Parent = spawnerDropdownScroll

    -- Populate dropdown with pet names
    local function populateDropdown()
        -- Clear existing buttons
        for _, child in ipairs(spawnerDropdownScroll:GetChildren()) do
            if child:IsA('TextButton') then
                child:Destroy()
            end
        end

        for i, petName in ipairs(spawnerValidPetNames) do
            local petButton = Instance.new('TextButton')
            petButton.Size = UDim2.new(1, 0, 0, 20)
            petButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            petButton.BackgroundTransparency = 0.5
            petButton.Text = petName
            petButton.Font = Enum.Font.FredokaOne
            petButton.TextSize = 12
            petButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            petButton.TextXAlignment = Enum.TextXAlignment.Left
            petButton.TextWrapped = true
            petButton.AutoButtonColor = true
            petButton.Parent = spawnerDropdownScroll

            local petButtonCorner = Instance.new('UICorner')
            petButtonCorner.CornerRadius = UDim.new(0, 4)
            petButtonCorner.Parent = petButton

            petButton.MouseButton1Click:Connect(function()
                spawnerPetNameBox.Text = petName
                spawnerDropdownFrame.Visible = false
            end)

            petButton.MouseEnter:Connect(function()
                petButton.BackgroundTransparency = 0.2
            end)

            petButton.MouseLeave:Connect(function()
                petButton.BackgroundTransparency = 0.5
            end)
        end

        -- Update canvas size
        spawnerDropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #spawnerValidPetNames * 22)
    end

    -- List button click handler
    spawnerListButton.MouseButton1Click:Connect(function()
        spawnerDropdownFrame.Visible = not spawnerDropdownFrame.Visible
        if spawnerDropdownFrame.Visible then
            populateDropdown()
        end
    end)

    -- Close dropdown when clicking elsewhere
    spawnerPetContent.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = input.Position
            local dropdownPos = spawnerDropdownFrame.AbsolutePosition
            local dropdownSize = spawnerDropdownFrame.AbsoluteSize
            local listButtonPos = spawnerListButton.AbsolutePosition
            local listButtonSize = spawnerListButton.AbsoluteSize

            if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                    mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) and
               not (mousePos.X >= listButtonPos.X and mousePos.X <= listButtonPos.X + listButtonSize.X and
                    mousePos.Y >= listButtonPos.Y and mousePos.Y <= listButtonPos.Y + listButtonSize.Y) then
                spawnerDropdownFrame.Visible = false
            end
        end
    end)

    -- Store valid pet names
    local spawnerValidPetNames = {}
    local spawnerValidPetNamesClean = {}

    local function spawnerLoadPetNames()
        local inventory_db = require(game.ReplicatedStorage.Fsys).load('InventoryDB')
        for category_name, category_table in pairs(inventory_db) do
            if category_name == 'pets' then
                for id, item in pairs(category_table) do
                    spawnerValidPetNames[#spawnerValidPetNames + 1] = item.name
                    spawnerValidPetNamesClean[#spawnerValidPetNamesClean + 1] = item.name:lower():gsub('%s+', '')
                end
                break
            end
        end
    end

    spawnerLoadPetNames()

    -- Color palette
    local spawnerCOLORS = {
        NEUTRAL = Color3.fromRGB(220, 220, 255),
        VALID = Color3.fromRGB(120, 255, 150),
        INVALID = Color3.fromRGB(255, 120, 120),
    }

    -- Current color tween
    local spawnerCurrentColorTween = nil

    -- Capitalize function
    local function spawnerCapitalizeWords(str)
        local result = ''
        local i = 1
        local n = #str

        while i <= n do
            if str:sub(i, i):match('%S') then
                local wordStart = i
                while i <= n and str:sub(i, i):match('%S') do
                    i = i + 1
                end
                local word = str:sub(wordStart, i - 1)
                if #word > 0 then
                    word = word:sub(1, 1):upper() .. word:sub(2):lower()
                end
                result = result .. word
            else
                result = result .. str:sub(i, i)
                i = i + 1
            end
        end

        return result
    end

    local spawnerLastCursorPosition = 1

    local function spawnerSetGlowColor(targetColor)
        if spawnerCurrentColorTween then
            spawnerCurrentColorTween:Cancel()
        end

        spawnerCurrentColorTween = TweenService:Create(
            spawnerBoxGlow,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = targetColor }
        )
        spawnerCurrentColorTween:Play()
    end

    spawnerPetNameBox:GetPropertyChangedSignal('Text'):Connect(function()
        spawnerLastCursorPosition = spawnerPetNameBox.CursorPosition
        local inputText = spawnerPetNameBox.Text

        local newText = spawnerCapitalizeWords(inputText)
        if newText ~= inputText then
            spawnerPetNameBox.Text = newText
            local addedChars = #newText - #inputText
            spawnerPetNameBox.CursorPosition = math.max(
                1,
                math.min(spawnerLastCursorPosition + addedChars, #newText + 1)
            )
            return
        end

        local displayedText = spawnerPetNameBox.Text
        local cleanName = displayedText:lower():gsub('%s+', '')

        local isExactMatch = false
        local isCleanMatch = false

        for _, name in ipairs(spawnerValidPetNames) do
            if name:lower() == displayedText:lower() then
                isExactMatch = true
                break
            end
        end

        isCleanMatch = table.find(spawnerValidPetNamesClean, cleanName) ~= nil

        local targetColor
        if displayedText == '' then
            targetColor = spawnerCOLORS.NEUTRAL
        elseif isExactMatch then
            targetColor = spawnerCOLORS.VALID
        elseif isCleanMatch then
            targetColor = spawnerCOLORS.VALID
        else
            targetColor = spawnerCOLORS.INVALID
        end

        spawnerSetGlowColor(targetColor)
    end)

    spawnerSetGlowColor(spawnerCOLORS.NEUTRAL)

    -- High Tier Pets List
    local spawnerHighTierPets = {
        'Shadow Dragon',
        'Giant Panda',
        'Cryptid',
        'Bat Dragon',
        'Frost Dragon',
        'Giraffe',
        'Owl',
        'Parrot',
        'Crow',
        'Evil Unicorn',
        'Arctic Reindeer',
        'Hedgehog',
        'Dalmatian',
        'Turtle',
        'Kangaroo',
        'Lion',
        'Elephant',
        'Rhino',
        'Chocolate Chip Bat Dragon',
        'Cow',
        'Blazing Lion',
        'African Wild Dog',
        'Flamingo',
        'Diamond Butterfly',
        'Mini Pig',
        'Caterpillar',
        'Albino Monkey',
        'Candyfloss Chick',
        'Pelican',
        'Blue Dog',
        'Pink Cat',
        'Haetae',
        'Peppermint Penguin',
        'Winged Tiger',
        'Sugar Glider',
        'Shark Puppy',
        'Goat',
        'Sheeeeep',
        'Lion Cub',
        'Nessie',
        'Flamingo',
        'Frostbite Bear',
        'Balloon Unicorn',
        'Honey Badger',
        'Hot Doggo',
        'Crocodile',
        'Hare',
        'Ram',
        'Yeti',
        'Meetkat',
        'Jellyfish',
        'Happy Clown',
        'Orchid Butterfly',
        'Many Mackerel',
        'Strawberry Shortcake Bat Dragon',
        'Zombie Buffalo',
        'Fairy Bat Dragon',
    }

    -- High Tier Spawn Button
    local spawnerHighTierButton = Instance.new('TextButton')
    spawnerHighTierButton.Size = UDim2.new(0.6, 0, 0, 25)
    spawnerHighTierButton.Position = UDim2.new(0.2, 0, 0.55, 0)
    spawnerHighTierButton.Text = 'Spawn High Tier'
    spawnerHighTierButton.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
    spawnerHighTierButton.BackgroundTransparency = 0.1
    spawnerHighTierButton.Font = Enum.Font.FredokaOne
    spawnerHighTierButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerHighTierButton.TextSize = 16
    spawnerHighTierButton.Parent = spawnerPetContent

    local spawnerHighTierCorner = Instance.new('UICorner')
    spawnerHighTierCorner.CornerRadius = UDim.new(0, 8)
    spawnerHighTierCorner.Parent = spawnerHighTierButton

    local spawnerHighTierStroke = Instance.new('UIStroke')
    spawnerHighTierStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerHighTierStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerHighTierStroke.Thickness = 1.5
    spawnerHighTierStroke.Transparency = 0.1
    spawnerHighTierStroke.Parent = spawnerHighTierButton

    local spawnerHighTierTextStroke = Instance.new('UIStroke')
    spawnerHighTierTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerHighTierTextStroke.Color = Color3.new(0, 0, 0)
    spawnerHighTierTextStroke.Thickness = 1.5
    spawnerHighTierTextStroke.Transparency = 0
    spawnerHighTierTextStroke.Parent = spawnerHighTierButton

    local spawnerHighTierOriginalProperties = {
        BackgroundColor3 = spawnerHighTierButton.BackgroundColor3,
        BackgroundTransparency = spawnerHighTierButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local spawnerHighTierActiveAnimation = {
        endTime = 0,
        tween = nil,
        resetTween = nil,
    }

    spawnerHighTierButton.MouseEnter:Connect(function()
        if spawnerHighTierActiveAnimation.endTime < os.clock() then
            spawnerHighTierButton.BackgroundColor3 = Color3.fromRGB(220, 0, 220)
            TweenService:Create(spawnerHighTierStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    spawnerHighTierButton.MouseLeave:Connect(function()
        if spawnerHighTierActiveAnimation.endTime < os.clock() then
            spawnerHighTierButton.BackgroundColor3 = spawnerHighTierOriginalProperties.BackgroundColor3
            TweenService:Create(spawnerHighTierStroke, TweenInfo.new(0.2), {
                Thickness = spawnerHighTierOriginalProperties.StrokeThickness,
                Transparency = spawnerHighTierOriginalProperties.StrokeTransparency,
            }):Play()
        end
    end)

    spawnerHighTierButton.MouseButton1Click:Connect(function()
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < spawnerHighTierActiveAnimation.endTime

        if isExtension then
            spawnerHighTierActiveAnimation.intensity = math.min(spawnerHighTierActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            spawnerHighTierActiveAnimation.intensity = 1.0
        end

        if spawnerHighTierActiveAnimation.strokeTween then
            spawnerHighTierActiveAnimation.strokeTween:Cancel()
        end
        if spawnerHighTierActiveAnimation.resetThread then
            coroutine.close(spawnerHighTierActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        for _, petName in ipairs(spawnerHighTierPets) do
            local petId = GetPetByName(petName)
            if petId then
                if spawnerActiveFlags['M'] then
                    createPet(petId, {
                        pet_trick_level = math.random(1, 5),
                        mega_neon = true,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                elseif spawnerActiveFlags['N'] then
                    createPet(petId, {
                        pet_trick_level = math.random(0, 5),
                        neon = true,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                else
                    createPet(petId, {
                        pet_trick_level = math.random(1, 5),
                        neon = false,
                        mega_neon = false,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                end
                spawnSuccess = true
            end
        end

        if spawnSuccess then
            feedbackColor = Color3.fromRGB(0, 255 * spawnerHighTierActiveAnimation.intensity, 0)
            game.StarterGui:SetCore('SendNotification', {
                Title = 'High Tier Pets Spawned!',
                Text = 'All high tier pets have been spawned!',
                Duration = 5,
            })
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Failed to spawn high tier pets!',
                Duration = 3,
            })
        end

        spawnerHighTierStroke.Color = feedbackColor
        spawnerHighTierStroke.Thickness = 2 * spawnerHighTierActiveAnimation.intensity
        spawnerHighTierStroke.Transparency = 0.1 / spawnerHighTierActiveAnimation.intensity

        if isExtension then
            spawnerHighTierActiveAnimation.strokeTween = TweenService:Create(
                spawnerHighTierStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * spawnerHighTierActiveAnimation.intensity,
                    Transparency = 0.05 / spawnerHighTierActiveAnimation.intensity,
                }
            )
            spawnerHighTierActiveAnimation.strokeTween:Play()
        end

        spawnerHighTierActiveAnimation.endTime = currentTime + extendDuration

        spawnerHighTierActiveAnimation.resetThread = task.delay(
            extendDuration,
            function()
                if os.clock() >= spawnerHighTierActiveAnimation.endTime then
                    TweenService:Create(
                        spawnerHighTierStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                        {
                            Color = spawnerHighTierOriginalProperties.StrokeColor,
                            Thickness = spawnerHighTierOriginalProperties.StrokeThickness,
                            Transparency = spawnerHighTierOriginalProperties.StrokeTransparency,
                        }
                    ):Play()
                end
            end
        )
    end)

    -- Spawn 10x High Tier Button
    local spawnerHighTier10xButton = Instance.new('TextButton')
    spawnerHighTier10xButton.Size = UDim2.new(0.6, 0, 0, 25)
    spawnerHighTier10xButton.Position = UDim2.new(0.2, 0, 0.65, 0)
    spawnerHighTier10xButton.Text = 'Spawn 10x High Tier'
    spawnerHighTier10xButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    spawnerHighTier10xButton.BackgroundTransparency = 0.1
    spawnerHighTier10xButton.Font = Enum.Font.FredokaOne
    spawnerHighTier10xButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerHighTier10xButton.TextSize = 14
    spawnerHighTier10xButton.Parent = spawnerPetContent

    local spawnerHighTier10xCorner = Instance.new('UICorner')
    spawnerHighTier10xCorner.CornerRadius = UDim.new(0, 8)
    spawnerHighTier10xCorner.Parent = spawnerHighTier10xButton

    local spawnerHighTier10xStroke = Instance.new('UIStroke')
    spawnerHighTier10xStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerHighTier10xStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerHighTier10xStroke.Thickness = 1.5
    spawnerHighTier10xStroke.Transparency = 0.1
    spawnerHighTier10xStroke.Parent = spawnerHighTier10xButton

    local spawnerHighTier10xTextStroke = Instance.new('UIStroke')
    spawnerHighTier10xTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerHighTier10xTextStroke.Color = Color3.new(0, 0, 0)
    spawnerHighTier10xTextStroke.Thickness = 1.5
    spawnerHighTier10xTextStroke.Transparency = 0
    spawnerHighTier10xTextStroke.Parent = spawnerHighTier10xButton

    local spawnerHighTier10xOriginalProperties = {
        BackgroundColor3 = spawnerHighTier10xButton.BackgroundColor3,
        BackgroundTransparency = spawnerHighTier10xButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local spawnerHighTier10xActiveAnimation = {
        endTime = 0,
        tween = nil,
        resetTween = nil,
    }

    spawnerHighTier10xButton.MouseEnter:Connect(function()
        if spawnerHighTier10xActiveAnimation.endTime < os.clock() then
            spawnerHighTier10xButton.BackgroundColor3 = Color3.fromRGB(170, 0, 170)
            TweenService:Create(spawnerHighTier10xStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    spawnerHighTier10xButton.MouseLeave:Connect(function()
        if spawnerHighTier10xActiveAnimation.endTime < os.clock() then
            spawnerHighTier10xButton.BackgroundColor3 = spawnerHighTier10xOriginalProperties.BackgroundColor3
            TweenService:Create(spawnerHighTier10xStroke, TweenInfo.new(0.2), {
                Thickness = spawnerHighTier10xOriginalProperties.StrokeThickness,
                Transparency = spawnerHighTier10xOriginalProperties.StrokeTransparency,
            }):Play()
        end
    end)

    spawnerHighTier10xButton.MouseButton1Click:Connect(function()
        local currentTime = os.clock()
        local extendDuration = 2.0 -- Longer duration for 10x

        local isExtension = currentTime < spawnerHighTier10xActiveAnimation.endTime

        if isExtension then
            spawnerHighTier10xActiveAnimation.intensity = math.min(spawnerHighTier10xActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 2.0
        else
            spawnerHighTier10xActiveAnimation.intensity = 1.0
        end

        if spawnerHighTier10xActiveAnimation.strokeTween then
            spawnerHighTier10xActiveAnimation.strokeTween:Cancel()
        end
        if spawnerHighTier10xActiveAnimation.resetThread then
            coroutine.close(spawnerHighTier10xActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        -- Spawn 10 sets of all high tier pets
        for set = 1, 10 do
            for _, petName in ipairs(spawnerHighTierPets) do
                local petId = GetPetByName(petName)
                if petId then
                    if spawnerActiveFlags['M'] then
                        createPet(petId, {
                            pet_trick_level = math.random(1, 5),
                            mega_neon = true,
                            rideable = spawnerActiveFlags['R'],
                            flyable = spawnerActiveFlags['F'],
                            age = math.random(1, 900000),
                            ailments_completed = 0,
                            rp_name = '',
                        })
                    elseif spawnerActiveFlags['N'] then
                        createPet(petId, {
                            pet_trick_level = math.random(0, 5),
                            neon = true,
                            rideable = spawnerActiveFlags['R'],
                            flyable = spawnerActiveFlags['F'],
                            age = math.random(1, 900000),
                            ailments_completed = 0,
                            rp_name = '',
                        })
                    else
                        createPet(petId, {
                            pet_trick_level = math.random(1, 5),
                            neon = false,
                            mega_neon = false,
                            rideable = spawnerActiveFlags['R'],
                            flyable = spawnerActiveFlags['F'],
                            age = math.random(1, 900000),
                            ailments_completed = 0,
                            rp_name = '',
                        })
                    end
                    spawnSuccess = true
                end
            end
        end

        if spawnSuccess then
            feedbackColor = Color3.fromRGB(0, 255 * spawnerHighTier10xActiveAnimation.intensity, 0)
            game.StarterGui:SetCore('SendNotification', {
                Title = '10x High Tier Pets Spawned!',
                Text = '10 sets of all high tier pets have been spawned!',
                Duration = 5,
            })
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Failed to spawn 10x high tier pets!',
                Duration = 3,
            })
        end

        spawnerHighTier10xStroke.Color = feedbackColor
        spawnerHighTier10xStroke.Thickness = 2 * spawnerHighTier10xActiveAnimation.intensity
        spawnerHighTier10xStroke.Transparency = 0.1 / spawnerHighTier10xActiveAnimation.intensity

        if isExtension then
            spawnerHighTier10xActiveAnimation.strokeTween = TweenService:Create(
                spawnerHighTier10xStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * spawnerHighTier10xActiveAnimation.intensity,
                    Transparency = 0.05 / spawnerHighTier10xActiveAnimation.intensity,
                }
            )
            spawnerHighTier10xActiveAnimation.strokeTween:Play()
        end

        spawnerHighTier10xActiveAnimation.endTime = currentTime + extendDuration

        spawnerHighTier10xActiveAnimation.resetThread = task.delay(
            extendDuration,
            function()
                if os.clock() >= spawnerHighTier10xActiveAnimation.endTime then
                    TweenService:Create(
                        spawnerHighTier10xStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                        {
                            Color = spawnerHighTier10xOriginalProperties.StrokeColor,
                            Thickness = spawnerHighTier10xOriginalProperties.StrokeThickness,
                            Transparency = spawnerHighTier10xOriginalProperties.StrokeTransparency,
                        }
                    ):Play()
                end
            end
        )
    end)

    -- Spawn Pet Button
    local spawnerStartButton = Instance.new('TextButton')
    spawnerStartButton.Size = UDim2.new(0.6, 0, 0, 25)
    spawnerStartButton.Position = UDim2.new(0.2, 0, 0.75, 0)
    spawnerStartButton.Text = 'Spawn Pet'
    spawnerStartButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    spawnerStartButton.BackgroundTransparency = 0.1
    spawnerStartButton.Font = Enum.Font.FredokaOne
    spawnerStartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerStartButton.TextSize = 16
    spawnerStartButton.Parent = spawnerPetContent

    local spawnerButtonCorner = Instance.new('UICorner')
    spawnerButtonCorner.CornerRadius = UDim.new(0, 8)
    spawnerButtonCorner.Parent = spawnerStartButton

    local spawnerButtonStroke = Instance.new('UIStroke')
    spawnerButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerButtonStroke.Thickness = 1.5
    spawnerButtonStroke.Transparency = 0.1
    spawnerButtonStroke.Parent = spawnerStartButton

    local spawnerButtonTextStroke = Instance.new('UIStroke')
    spawnerButtonTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerButtonTextStroke.Color = Color3.new(0, 0, 0)
    spawnerButtonTextStroke.Thickness = 1.5
    spawnerButtonTextStroke.Transparency = 0
    spawnerButtonTextStroke.Parent = spawnerStartButton

    local spawnerOriginalProperties = {
        BackgroundColor3 = spawnerStartButton.BackgroundColor3,
        BackgroundTransparency = spawnerStartButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local spawnerActiveAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
        lastSuccess = false,
    }

    spawnerStartButton.MouseEnter:Connect(function()
        if spawnerActiveAnimation.endTime < os.clock() then
            spawnerStartButton.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
            TweenService:Create(spawnerButtonStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    spawnerStartButton.MouseLeave:Connect(function()
        if spawnerActiveAnimation.endTime < os.clock() then
            spawnerStartButton.BackgroundColor3 = spawnerOriginalProperties.BackgroundColor3
            TweenService:Create(spawnerButtonStroke, TweenInfo.new(0.2), {
                Thickness = spawnerOriginalProperties.StrokeThickness,
                Transparency = spawnerOriginalProperties.StrokeTransparency,
            }):Play()
        end
    end)

    spawnerStartButton.MouseButton1Click:Connect(function()
        local pet_name = spawnerPetNameBox.Text
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < spawnerActiveAnimation.endTime

        if isExtension then
            spawnerActiveAnimation.intensity = math.min(spawnerActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            spawnerActiveAnimation.intensity = 1.0
        end

        if spawnerActiveAnimation.strokeTween then
            spawnerActiveAnimation.strokeTween:Cancel()
        end
        if spawnerActiveAnimation.resetThread then
            coroutine.close(spawnerActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        if pet_name ~= '' then
            local petId = GetPetByName(pet_name)
            if petId then
                if spawnerActiveFlags['M'] then
                    createPet(petId, {
                        pet_trick_level = math.random(1, 5),
                        mega_neon = true,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                elseif spawnerActiveFlags['N'] then
                    createPet(petId, {
                        pet_trick_level = math.random(0, 5),
                        neon = true,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                else
                    createPet(petId, {
                        pet_trick_level = math.random(1, 5),
                        neon = false,
                        mega_neon = false,
                        rideable = spawnerActiveFlags['R'],
                        flyable = spawnerActiveFlags['F'],
                        age = math.random(1, 900000),
                        ailments_completed = 0,
                        rp_name = '',
                    })
                end
                spawnSuccess = true
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Pet Spawned!',
                    Text = pet_name .. ' has been spawned!',
                    Duration = 5,
                })
            else
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Error',
                    Text = 'Pet not found: ' .. pet_name,
                    Duration = 3,
                })
            end
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Please enter a pet name!',
                Duration = 3,
            })
        end

        spawnerActiveAnimation.lastSuccess = spawnSuccess

        if isExtension and spawnerActiveAnimation.lastSuccess then
            feedbackColor = Color3.fromRGB(0, 255 * spawnerActiveAnimation.intensity, 0)
        end

        spawnerButtonStroke.Color = feedbackColor
        spawnerButtonStroke.Thickness = 2 * spawnerActiveAnimation.intensity
        spawnerButtonStroke.Transparency = 0.1 / spawnerActiveAnimation.intensity

        if isExtension then
            spawnerActiveAnimation.strokeTween = TweenService:Create(
                spawnerButtonStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * spawnerActiveAnimation.intensity,
                    Transparency = 0.05 / spawnerActiveAnimation.intensity,
                }
            )
            spawnerActiveAnimation.strokeTween:Play()
        end

        spawnerActiveAnimation.endTime = currentTime + extendDuration

        spawnerActiveAnimation.resetThread = task.delay(extendDuration, function()
            if os.clock() >= spawnerActiveAnimation.endTime then
                TweenService:Create(
                    spawnerButtonStroke,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                    {
                        Color = spawnerOriginalProperties.StrokeColor,
                        Thickness = spawnerOriginalProperties.StrokeThickness,
                        Transparency = spawnerOriginalProperties.StrokeTransparency,
                    }
                ):Play()
            end
        end)
    end)

    -- Info box for spawner
    local spawnerInfoBox = Instance.new('Frame')
    spawnerInfoBox.Size = UDim2.new(0.85, 0, 0, 30)
    spawnerInfoBox.Position = UDim2.new(0.075, 0, 0.45, 0)
    spawnerInfoBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    spawnerInfoBox.BackgroundTransparency = 0.5
    spawnerInfoBox.BorderSizePixel = 0
    spawnerInfoBox.Parent = spawnerPetContent

    local spawnerInfoBoxCorner = Instance.new('UICorner')
    spawnerInfoBoxCorner.CornerRadius = UDim.new(0, 8)
    spawnerInfoBoxCorner.Parent = spawnerInfoBox

    local spawnerInfoBoxStroke = Instance.new('UIStroke')
    spawnerInfoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerInfoBoxStroke.Thickness = 1.2
    spawnerInfoBoxStroke.Transparency = 0.7
    spawnerInfoBoxStroke.Parent = spawnerInfoBox

    local spawnerInfoTextContainer = Instance.new('Frame')
    spawnerInfoTextContainer.Size = UDim2.new(1, 0, 1, 0)
    spawnerInfoTextContainer.BackgroundTransparency = 1
    spawnerInfoTextContainer.Parent = spawnerInfoBox

    local spawnerUiListLayout = Instance.new('UIListLayout')
    spawnerUiListLayout.FillDirection = Enum.FillDirection.Horizontal
    spawnerUiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    spawnerUiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    spawnerUiListLayout.Padding = UDim.new(0, 4)
    spawnerUiListLayout.Parent = spawnerInfoTextContainer

    local spawnerBaseColors = {
        M = Color3.fromRGB(170, 0, 255),
        N = Color3.fromRGB(0, 255, 100),
        F = Color3.fromRGB(0, 200, 255),
        R = Color3.fromRGB(255, 50, 150),
    }

    local spawnerAnimationSystem = {
        pulsePhase = 0,
        pulseSpeed = 2,
        baseThickness = 1.2,
        maxThickness = 3,
        activeColors = nil,
        active = false,
    }

    local function spawnerUpdateAnimation(dt)
        if not spawnerAnimationSystem.active then
            return
        end

        spawnerAnimationSystem.pulsePhase = spawnerAnimationSystem.pulsePhase + dt * spawnerAnimationSystem.pulseSpeed
        local pulse = (math.sin(spawnerAnimationSystem.pulsePhase) + 1) * 0.5

        spawnerInfoBoxStroke.Thickness = spawnerAnimationSystem.baseThickness + (spawnerAnimationSystem.maxThickness - spawnerAnimationSystem.baseThickness) * pulse
        spawnerInfoBoxStroke.Transparency = 0.7 - (0.5 * pulse)

        if spawnerAnimationSystem.activeColors then
            local brightness = 0.8 + (0.4 * pulse)
            local r, g, b = 0, 0, 0

            for _, color in ipairs(spawnerAnimationSystem.activeColors) do
                r = r + (color.R * brightness)
                g = g + (color.G * brightness)
                b = b + (color.B * brightness)
            end

            local mixedColor = Color3.new(
                math.min(r / #spawnerAnimationSystem.activeColors, 1),
                math.min(g / #spawnerAnimationSystem.activeColors, 1),
                math.min(b / #spawnerAnimationSystem.activeColors, 1)
            )

            spawnerInfoBoxStroke.Color = mixedColor
        end
    end

    local function spawnerCreateTextLabel(text, color)
        local label = Instance.new('TextLabel')
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 16
        label.TextColor3 = color
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center

        if text == 'Mega Neon' then
            label.Text = 'Mega Neon'
        elseif text ~= 'Ride' and text ~= 'Neon' and text ~= 'Fly' then
            label.Text = label.Text .. ' '
        end

        return label
    end

    local function spawnerUpdateInfoBox(activeFlags)
        for _, child in ipairs(spawnerInfoTextContainer:GetChildren()) do
            if child:IsA('TextLabel') then
                child:Destroy()
            end
        end

        local activeColors = {}
        local hasFlags = false
        local labels = {}

        if activeFlags['M'] then
            table.insert(labels, { 'Mega Neon', spawnerBaseColors.M })
            table.insert(activeColors, spawnerBaseColors.M)
            hasFlags = true
        end
        if activeFlags['N'] then
            table.insert(labels, { 'Neon', spawnerBaseColors.N })
            table.insert(activeColors, spawnerBaseColors.N)
            hasFlags = true
        end
        if activeFlags['F'] then
            table.insert(labels, { 'Fly', spawnerBaseColors.F })
            table.insert(activeColors, spawnerBaseColors.F)
            hasFlags = true
        end
        if activeFlags['R'] then
            table.insert(labels, { 'Ride', spawnerBaseColors.R })
            table.insert(activeColors, spawnerBaseColors.R)
            hasFlags = true
        end

        for i, labelData in ipairs(labels) do
            local label = spawnerCreateTextLabel(labelData[1], labelData[2])
            label.Parent = spawnerInfoTextContainer
        end

        if hasFlags then
            spawnerAnimationSystem.active = true
            spawnerAnimationSystem.activeColors = activeColors
        else
            spawnerAnimationSystem.active = false
            spawnerCreateTextLabel('Normal', Color3.fromRGB(255, 255, 255)).Parent = spawnerInfoTextContainer
            spawnerInfoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
            spawnerInfoBoxStroke.Thickness = spawnerAnimationSystem.baseThickness
            spawnerInfoBoxStroke.Transparency = 0.7
        end
    end

    RunService.Heartbeat:Connect(spawnerUpdateAnimation)
    spawnerUpdateInfoBox({ F = false, R = false, N = false, M = false })

    local spawnerPrefixes = { 'F', 'R', 'N', 'M' }

    local spawnerTotalButtons = #spawnerPrefixes
    local spawnerButtonWidth = 0.18
    local spawnerSpaceBetweenButtons = 0.07
    local spawnerTotalWidth = spawnerTotalButtons * spawnerButtonWidth + (spawnerTotalButtons - 1) * spawnerSpaceBetweenButtons
    local spawnerStartingX = (1 - spawnerTotalWidth) / 2

    for i, prefix in ipairs(spawnerPrefixes) do
        local spawnerPrefixButton = Instance.new('TextButton')
        spawnerPrefixButton.Size = UDim2.new(spawnerButtonWidth, 0, 0, 25)
        spawnerPrefixButton.Position = UDim2.new(
            spawnerStartingX + (spawnerButtonWidth + spawnerSpaceBetweenButtons) * (i - 1),
            0,
            0.3,
            0
        )
        spawnerPrefixButton.Text = prefix
        spawnerPrefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        spawnerPrefixButton.BackgroundTransparency = 0.2
        spawnerPrefixButton.Font = Enum.Font.FredokaOne
        spawnerPrefixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        spawnerPrefixButton.TextSize = 16
        spawnerPrefixButton.Parent = spawnerPetContent

        local spawnerButtonCorner = Instance.new('UICorner')
        spawnerButtonCorner.CornerRadius = UDim.new(0, 6)
        spawnerButtonCorner.Parent = spawnerPrefixButton

        local spawnerButtonStroke = Instance.new('UIStroke')
        spawnerButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        spawnerButtonStroke.Color = spawnerBaseColors[prefix]
        spawnerButtonStroke.Thickness = 2
        spawnerButtonStroke.Transparency = 0.5
        spawnerButtonStroke.Parent = spawnerPrefixButton

        local spawnerTextStroke = Instance.new('UIStroke')
        spawnerTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        spawnerTextStroke.Color = Color3.new(0, 0, 0)
        spawnerTextStroke.Thickness = 1.5
        spawnerTextStroke.Transparency = 0
        spawnerTextStroke.Parent = spawnerPrefixButton

        local spawnerOriginalStroke = {
            Color = spawnerBaseColors[prefix],
            Thickness = 2,
            Transparency = 0.5,
        }

        spawnerPrefixButton.MouseButton1Click:Connect(function()
            if prefix == 'M' and spawnerActiveFlags['N'] then
                return
            end
            if prefix == 'N' and spawnerActiveFlags['M'] then
                return
            end

            spawnerActiveFlags[prefix] = not spawnerActiveFlags[prefix]

            if spawnerActiveFlags[prefix] then
                spawnerPrefixButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

                TweenService:Create(
                    spawnerButtonStroke,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                    {
                        Color = Color3.fromRGB(0, 255, 0),
                        Thickness = 3,
                        Transparency = 0.2,
                    }
                ):Play()
            else
                spawnerPrefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

                TweenService:Create(
                    spawnerButtonStroke,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                    {
                        Color = spawnerOriginalStroke.Color,
                        Thickness = spawnerOriginalStroke.Thickness,
                        Transparency = spawnerOriginalStroke.Transparency,
                    }
                ):Play()
            end

            spawnerUpdateInfoBox(spawnerActiveFlags)
        end)
    end

    -- TOY CONTENT
    local spawnerToyNameBox = Instance.new('TextBox')
    spawnerToyNameBox.Size = UDim2.new(0.85, 0, 0, 28)
    spawnerToyNameBox.Position = UDim2.new(0.075, 0, 0.1, 0)
    spawnerToyNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    spawnerToyNameBox.BackgroundTransparency = 0.2
    spawnerToyNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerToyNameBox.TextSize = 14
    spawnerToyNameBox.Font = Enum.Font.FredokaOne
    spawnerToyNameBox.PlaceholderText = 'Enter Toy Name'
    spawnerToyNameBox.Text = ''
    spawnerToyNameBox.ClearTextOnFocus = false
    spawnerToyNameBox.Parent = spawnerToyContent

    local spawnerToyBoxCorner = Instance.new('UICorner')
    spawnerToyBoxCorner.CornerRadius = UDim.new(0, 6)
    spawnerToyBoxCorner.Parent = spawnerToyNameBox

    local spawnerToyTextStroke = Instance.new('UIStroke')
    spawnerToyTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerToyTextStroke.Color = Color3.new(0, 0, 0)
    spawnerToyTextStroke.Thickness = 1.2
    spawnerToyTextStroke.Transparency = 0
    spawnerToyTextStroke.Parent = spawnerToyNameBox

    local spawnerToyBoxGlow = Instance.new('UIStroke')
    spawnerToyBoxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerToyBoxGlow.Color = Color3.fromRGB(255, 255, 255)
    spawnerToyBoxGlow.Thickness = 2.2
    spawnerToyBoxGlow.Transparency = 0.25
    spawnerToyBoxGlow.Parent = spawnerToyNameBox

    local spawnerValidToyNames = {}
    local spawnerValidToyNamesClean = {}

    local function spawnerLoadToyNames()
        local inventory_db = require(game.ReplicatedStorage.Fsys).load('InventoryDB')
        for category_name, category_table in pairs(inventory_db) do
            if category_name == 'toys' then
                for id, item in pairs(category_table) do
                    spawnerValidToyNames[#spawnerValidToyNames + 1] = item.name
                    spawnerValidToyNamesClean[#spawnerValidToyNamesClean + 1] = item.name:lower():gsub('%s+', '')
                end
                break
            end
        end
    end

    spawnerLoadToyNames()

    local spawnerToyCurrentColorTween = nil

    spawnerToyNameBox:GetPropertyChangedSignal('Text'):Connect(function()
        spawnerLastCursorPosition = spawnerToyNameBox.CursorPosition
        local inputText = spawnerToyNameBox.Text

        local newText = spawnerCapitalizeWords(inputText)
        if newText ~= inputText then
            spawnerToyNameBox.Text = newText
            local addedChars = #newText - #inputText
            spawnerToyNameBox.CursorPosition = math.max(
                1,
                math.min(spawnerLastCursorPosition + addedChars, #newText + 1)
            )
            return
        end

        local displayedText = spawnerToyNameBox.Text
        local cleanName = displayedText:lower():gsub('%s+', '')

        local isExactMatch = false
        local isCleanMatch = false

        for _, name in ipairs(spawnerValidToyNames) do
            if name:lower() == displayedText:lower() then
                isExactMatch = true
                break
            end
        end

        isCleanMatch = table.find(spawnerValidToyNamesClean, cleanName) ~= nil

        local targetColor
        if displayedText == '' then
            targetColor = spawnerCOLORS.NEUTRAL
        elseif isExactMatch then
            targetColor = spawnerCOLORS.VALID
        elseif isCleanMatch then
            targetColor = spawnerCOLORS.VALID
        else
            targetColor = spawnerCOLORS.INVALID
        end

        if spawnerToyCurrentColorTween then
            spawnerToyCurrentColorTween:Cancel()
        end

        spawnerToyCurrentColorTween = TweenService:Create(
            spawnerToyBoxGlow,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = targetColor }
        )
        spawnerToyCurrentColorTween:Play()
    end)

    if spawnerToyCurrentColorTween then
        spawnerToyCurrentColorTween:Cancel()
    end
    spawnerToyCurrentColorTween = TweenService:Create(
        spawnerToyBoxGlow,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Color = spawnerCOLORS.NEUTRAL }
    )
    spawnerToyCurrentColorTween:Play()

    local spawnerToySpawnButton = Instance.new('TextButton')
    spawnerToySpawnButton.Size = UDim2.new(0.6, 0, 0, 25)
    spawnerToySpawnButton.Position = UDim2.new(0.2, 0, 0.3, 0)
    spawnerToySpawnButton.Text = 'Spawn Toy'
    spawnerToySpawnButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    spawnerToySpawnButton.BackgroundTransparency = 0.1
    spawnerToySpawnButton.Font = Enum.Font.FredokaOne
    spawnerToySpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spawnerToySpawnButton.TextSize = 16
    spawnerToySpawnButton.Parent = spawnerToyContent

    local spawnerToyButtonCorner = Instance.new('UICorner')
    spawnerToyButtonCorner.CornerRadius = UDim.new(0, 8)
    spawnerToyButtonCorner.Parent = spawnerToySpawnButton

    local spawnerToyButtonStroke = Instance.new('UIStroke')
    spawnerToyButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    spawnerToyButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    spawnerToyButtonStroke.Thickness = 1.5
    spawnerToyButtonStroke.Transparency = 0.1
    spawnerToyButtonStroke.Parent = spawnerToySpawnButton

    local spawnerToyTextStroke = Instance.new('UIStroke')
    spawnerToyTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    spawnerToyTextStroke.Color = Color3.new(0, 0, 0)
    spawnerToyTextStroke.Thickness = 1.5
    spawnerToyTextStroke.Transparency = 0
    spawnerToyTextStroke.Parent = spawnerToySpawnButton

    local spawnerToyOriginalProperties = {
        BackgroundColor3 = spawnerToySpawnButton.BackgroundColor3,
        BackgroundTransparency = spawnerToySpawnButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local spawnerToyActiveAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
        lastSuccess = false,
    }

    spawnerToySpawnButton.MouseEnter:Connect(function()
        if spawnerToyActiveAnimation.endTime < os.clock() then
            spawnerToySpawnButton.BackgroundColor3 = Color3.fromRGB(220, 120, 0)
            TweenService:Create(spawnerToyButtonStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    spawnerToySpawnButton.MouseLeave:Connect(function()
        if spawnerToyActiveAnimation.endTime < os.clock() then
            spawnerToySpawnButton.BackgroundColor3 = spawnerToyOriginalProperties.BackgroundColor3
            TweenService:Create(spawnerToyButtonStroke, TweenInfo.new(0.2), {
                Thickness = spawnerToyOriginalProperties.StrokeThickness,
                Transparency = spawnerToyOriginalProperties.StrokeTransparency,
            }):Play()
        end
    end)

    spawnerToySpawnButton.MouseButton1Click:Connect(function()
        local toy_name = spawnerToyNameBox.Text
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < spawnerToyActiveAnimation.endTime

        if isExtension then
            spawnerToyActiveAnimation.intensity = math.min(spawnerToyActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            spawnerToyActiveAnimation.intensity = 1.0
        end

        if spawnerToyActiveAnimation.strokeTween then
            spawnerToyActiveAnimation.strokeTween:Cancel()
        end
        if spawnerToyActiveAnimation.resetThread then
            coroutine.close(spawnerToyActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        if toy_name ~= '' then
            local toyId = GetToyByName(toy_name)
            if toyId then
                createToy(toyId)
                spawnSuccess = true
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Toy Spawned!',
                    Text = toy_name .. ' has been spawned!',
                    Duration = 5,
                })
            else
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Error',
                    Text = 'Toy not found: ' .. toy_name,
                    Duration = 3,
                })
            end
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Please enter a toy name!',
                Duration = 3,
            })
        end

        spawnerToyActiveAnimation.lastSuccess = spawnSuccess

        if isExtension and spawnerToyActiveAnimation.lastSuccess then
            feedbackColor = Color3.fromRGB(0, 255 * spawnerToyActiveAnimation.intensity, 0)
        end

        spawnerToyButtonStroke.Color = feedbackColor
        spawnerToyButtonStroke.Thickness = 2 * spawnerToyActiveAnimation.intensity
        spawnerToyButtonStroke.Transparency = 0.1 / spawnerToyActiveAnimation.intensity

        if isExtension then
            spawnerToyActiveAnimation.strokeTween = TweenService:Create(
                spawnerToyButtonStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * spawnerToyActiveAnimation.intensity,
                    Transparency = 0.05 / spawnerToyActiveAnimation.intensity,
                }
            )
            spawnerToyActiveAnimation.strokeTween:Play()
        end

        spawnerToyActiveAnimation.endTime = currentTime + extendDuration

        spawnerToyActiveAnimation.resetThread = task.delay(extendDuration, function()
            if os.clock() >= spawnerToyActiveAnimation.endTime then
                TweenService:Create(
                    spawnerToyButtonStroke,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                    {
                        Color = spawnerToyOriginalProperties.StrokeColor,
                        Thickness = spawnerToyOriginalProperties.StrokeThickness,
                        Transparency = spawnerToyOriginalProperties.StrokeTransparency,
                    }
                ):Play()
            end
        end)
    end)
end)

print('âœ… Complete MockTrade with HIGH-VALUE PETS ONLY loaded successfully!')
print('ðŸŽˆ Fake players will only ride Balloon Unicorn or higher rarity pets!')
print('ðŸ“± GUI size optimized to 180x320 with smaller buttons and text!')
print('ðŸ‰ Spawner tab integrated successfully!')
print('ðŸ‰ Spawner tab integrated successfully!')


	end)
end)