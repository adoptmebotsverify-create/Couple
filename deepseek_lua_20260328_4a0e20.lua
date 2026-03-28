-- Simple Daily Login & Routine GUI - WORKING VERSION
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Create the main GUI directly (no spawn button)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DailyLoginGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 1100, 0, 700)
mainFrame.Position = UDim2.new(0.5, -550, 0.5, -350)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DAILY LOGIN & ROUTINE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = topBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Tagline
local taglineFrame = Instance.new("Frame")
taglineFrame.Size = UDim2.new(1, 0, 0, 40)
taglineFrame.Position = UDim2.new(0, 0, 0, 45)
taglineFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
taglineFrame.BorderSizePixel = 0
taglineFrame.Parent = mainFrame

local tagline = Instance.new("TextLabel")
tagline.Size = UDim2.new(1, -20, 1, 0)
tagline.Position = UDim2.new(0, 10, 0, 0)
tagline.BackgroundTransparency = 1
tagline.Text = "You're early! You can claim tomorrow's reward now!"
tagline.TextColor3 = Color3.fromRGB(255, 200, 100)
tagline.TextSize = 12
tagline.Font = Enum.Font.Gotham
tagline.TextXAlignment = Enum.TextXAlignment.Left
tagline.Parent = taglineFrame

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 45)
tabContainer.Position = UDim2.new(0, 0, 0, 85)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local dailyTab = Instance.new("TextButton")
dailyTab.Size = UDim2.new(0, 150, 1, 0)
dailyTab.Position = UDim2.new(0, 10, 0, 0)
dailyTab.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
dailyTab.Text = "Daily Login"
dailyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
dailyTab.Font = Enum.Font.GothamSemibold
dailyTab.TextSize = 14
dailyTab.Parent = tabContainer

local routineTab = Instance.new("TextButton")
routineTab.Size = UDim2.new(0, 150, 1, 0)
routineTab.Position = UDim2.new(0, 170, 0, 0)
routineTab.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
routineTab.Text = "Daily Routine"
routineTab.TextColor3 = Color3.fromRGB(255, 255, 255)
routineTab.Font = Enum.Font.GothamSemibold
routineTab.TextSize = 14
routineTab.Parent = tabContainer

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -40, 1, -150)
contentFrame.Position = UDim2.new(0, 20, 0, 140)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- LEFT COLUMN - Day Rewards
local leftColumn = Instance.new("ScrollingFrame")
leftColumn.Size = UDim2.new(0.65, -10, 1, 0)
leftColumn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
leftColumn.BorderSizePixel = 0
leftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
leftColumn.ScrollBarThickness = 5
leftColumn.Parent = contentFrame

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 8)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = leftColumn

-- RIGHT COLUMN - Backpack Info
local rightColumn = Instance.new("Frame")
rightColumn.Size = UDim2.new(0.35, 0, 1, 0)
rightColumn.Position = UDim2.new(0.68, 0, 0, 0)
rightColumn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
rightColumn.BorderSizePixel = 0
rightColumn.Parent = contentFrame

local backpackHeader = Instance.new("TextLabel")
backpackHeader.Size = UDim2.new(1, 0, 0, 45)
backpackHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
backpackHeader.Text = "Open Your Backpack"
backpackHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
backpackHeader.TextSize = 16
backpackHeader.Font = Enum.Font.GothamBold
backpackHeader.Parent = rightColumn

local backpackDesc = Instance.new("TextLabel")
backpackDesc.Size = UDim2.new(1, -20, 0, 60)
backpackDesc.Position = UDim2.new(0, 10, 0, 55)
backpackDesc.BackgroundTransparency = 1
backpackDesc.Text = "Your pets and items are kept in\nyour backpack"
backpackDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
backpackDesc.TextSize = 14
backpackDesc.TextWrapped = true
backpackDesc.Parent = rightColumn

local backpackIcon = Instance.new("ImageLabel")
backpackIcon.Size = UDim2.new(0, 100, 0, 100)
backpackIcon.Position = UDim2.new(0.5, -50, 0, 130)
backpackIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
backpackIcon.Image = "rbxassetid://6991531327"
backpackIcon.ScaleType = Enum.ScaleType.Fit
backpackIcon.Parent = rightColumn

-- Daily Routine Content
local routineContent = Instance.new("Frame")
routineContent.Size = UDim2.new(1, -40, 1, -150)
routineContent.Position = UDim2.new(0, 20, 0, 140)
routineContent.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
routineContent.BorderSizePixel = 0
routineContent.Visible = false
routineContent.Parent = mainFrame

-- Create Daily Login Rewards
local dayRewards = {}
local claimedDays = {126 = true, 127 = true}

for i = 1, 30 do
    local dayNum = 125 + i
    local isToday = (i == 3)
    local isBonus = (i == 5 or i == 10 or i == 15 or i == 20 or i == 25 or i == 30)
    
    local rewardText = ""
    local rewardIcon = ""
    local starsText = ""
    local dayMod = (i - 1) % 5 + 1
    
    if isBonus then
        local weekNum = math.floor((i - 1) / 5) + 1
        local bonusRewards = {
            [1] = {text = "Small Gift", icon = "rbxassetid://6991531327", stars = "5 STARS"},
            [2] = {text = "Big Gift", icon = "rbxassetid://6991531524", stars = "10 STARS"},
            [3] = {text = "Legend Chest", icon = "rbxassetid://6991531421", stars = "10 STARS"},
            [4] = {text = "Regal Chest", icon = "rbxassetid://6991531380", stars = "15 STARS"},
            [5] = {text = "Massive Gift", icon = "rbxassetid://6991531524", stars = "15 STARS"},
            [6] = {text = "Cracked Egg", icon = "rbxassetid://6991531380", stars = "20 STARS"}
        }
        local bonus = bonusRewards[weekNum]
        rewardText = bonus.text
        rewardIcon = bonus.icon
        starsText = bonus.stars
    else
        local moneyAmounts = {25, 50, 100, 200}
        rewardText = "$" .. moneyAmounts[dayMod]
        rewardIcon = "rbxassetid://6991531327"
    end
    
    local dayFrame = Instance.new("Frame")
    dayFrame.Size = UDim2.new(1, -10, 0, 85)
    dayFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    dayFrame.BorderSizePixel = 0
    dayFrame.Parent = leftColumn
    
    local dayLabel = Instance.new("TextLabel")
    dayLabel.Size = UDim2.new(0, 80, 1, 0)
    dayLabel.BackgroundTransparency = 1
    dayLabel.Text = isToday and "TODAY" or "DAY " .. dayNum
    dayLabel.TextColor3 = isToday and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(200, 200, 200)
    dayLabel.TextSize = 14
    dayLabel.Font = Enum.Font.GothamBold
    dayLabel.TextXAlignment = Enum.TextXAlignment.Center
    dayLabel.Parent = dayFrame
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 55, 0, 55)
    icon.Position = UDim2.new(0, 90, 0.5, -27.5)
    icon.BackgroundTransparency = 1
    icon.Image = rewardIcon
    icon.Parent = dayFrame
    
    local rewardLabel = Instance.new("TextLabel")
    rewardLabel.Size = UDim2.new(0, 120, 0, 40)
    rewardLabel.Position = UDim2.new(0, 155, 0.5, -20)
    rewardLabel.BackgroundTransparency = 1
    rewardLabel.Text = rewardText
    rewardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rewardLabel.TextSize = 13
    rewardLabel.Font = Enum.Font.GothamSemibold
    rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
    rewardLabel.Parent = dayFrame
    
    local starsLabel = Instance.new("TextLabel")
    starsLabel.Size = UDim2.new(0, 80, 0, 25)
    starsLabel.Position = UDim2.new(1, -90, 0.5, -12.5)
    starsLabel.BackgroundTransparency = 1
    starsLabel.Text = starsText
    starsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    starsLabel.TextSize = 11
    starsLabel.Font = Enum.Font.GothamBold
    starsLabel.Parent = dayFrame
    
    if isBonus then
        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(1, 0, 1, 0)
        glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        glow.BackgroundTransparency = 0.7
        glow.BorderSizePixel = 0
        glow.Parent = dayFrame
        spawn(function()
            while glow and glow.Parent do
                local pulse = (tick() * 2) % (math.pi * 2)
                glow.BackgroundTransparency = 0.5 + math.sin(pulse) * 0.2
                wait(0.05)
            end
        end)
    end
    
    local claimedOverlay = Instance.new("Frame")
    claimedOverlay.Size = UDim2.new(1, 0, 1, 0)
    claimedOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    claimedOverlay.BackgroundTransparency = 0.6
    claimedOverlay.Visible = claimedDays[dayNum] or false
    claimedOverlay.Parent = dayFrame
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
    checkmark.TextSize = 35
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = claimedOverlay
    
    dayRewards[dayNum] = {frame = dayFrame, claimedOverlay = claimedOverlay, dayLabel = dayLabel}
end

leftColumn.CanvasSize = UDim2.new(0, 0, 0, #dayRewards * 93)

-- Daily Routine Content
local routineTitle = Instance.new("TextLabel")
routineTitle.Size = UDim2.new(1, 0, 0, 50)
routineTitle.Position = UDim2.new(0, 0, 0, 10)
routineTitle.BackgroundTransparency = 1
routineTitle.Text = "DAILY ROUTINE"
routineTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
routineTitle.TextSize = 20
routineTitle.Font = Enum.Font.GothamBold
routineTitle.Parent = routineContent

local routineDesc = Instance.new("TextLabel")
routineDesc.Size = UDim2.new(1, -40, 0, 80)
routineDesc.Position = UDim2.new(0, 20, 0, 70)
routineDesc.BackgroundTransparency = 1
routineDesc.Text = "Complete the Daily Routine on a pet"
routineDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
routineDesc.TextSize = 14
routineDesc.TextWrapped = true
routineDesc.Parent = routineContent

-- Progress Bar
local progressFrame = Instance.new("Frame")
progressFrame.Size = UDim2.new(0.8, 0, 0, 30)
progressFrame.Position = UDim2.new(0.1, 0, 0, 160)
progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
progressFrame.BorderSizePixel = 0
progressFrame.Parent = routineContent

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(66, 185, 66)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressFrame

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.BackgroundTransparency = 1
progressText.Text = "0/1 Steps"
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextSize = 12
progressText.Font = Enum.Font.GothamBold
progressText.Parent = progressFrame

-- Reward Display
local rewardFrame = Instance.new("Frame")
rewardFrame.Size = UDim2.new(0.8, 0, 0, 80)
rewardFrame.Position = UDim2.new(0.1, 0, 0, 210)
rewardFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
rewardFrame.BorderSizePixel = 0
rewardFrame.Parent = routineContent

local rewardIcon = Instance.new("ImageLabel")
rewardIcon.Size = UDim2.new(0, 50, 0, 50)
rewardIcon.Position = UDim2.new(0, 15, 0.5, -25)
rewardIcon.BackgroundTransparency = 1
rewardIcon.Image = "rbxassetid://6991531327"
rewardIcon.Parent = rewardFrame

local rewardLabel = Instance.new("TextLabel")
rewardLabel.Size = UDim2.new(1, -80, 0, 30)
rewardLabel.Position = UDim2.new(0, 80, 0.5, -15)
rewardLabel.BackgroundTransparency = 1
rewardLabel.Text = "Reward: 25 Coins"
rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
rewardLabel.TextSize = 14
rewardLabel.Font = Enum.Font.GothamBold
rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
rewardLabel.Parent = rewardFrame

-- Start Routine Button
local startRoutineBtn = Instance.new("TextButton")
startRoutineBtn.Size = UDim2.new(0, 200, 0, 45)
startRoutineBtn.Position = UDim2.new(0.5, -100, 0, 310)
startRoutineBtn.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
startRoutineBtn.Text = "START ROUTINE"
startRoutineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startRoutineBtn.Font = Enum.Font.GothamBold
startRoutineBtn.TextSize = 16
startRoutineBtn.Parent = routineContent

-- Daily Routine Logic
local routineRunning = false
local stepsCompleted = 0
local stepsNeeded = 1

local function updateRoutineDisplay()
    local progress = stepsCompleted / stepsNeeded
    progressFill.Size = UDim2.new(progress, 0, 1, 0)
    progressText.Text = stepsCompleted .. "/" .. stepsNeeded .. " Steps"
    
    if stepsCompleted >= stepsNeeded then
        rewardLabel.Text = "✓ REWARD READY! ✓"
        rewardLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        startRoutineBtn.Visible = false
    else
        rewardLabel.Text = "Reward: 25 Coins"
        rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        startRoutineBtn.Visible = true
    end
    
    startRoutineBtn.Text = routineRunning and "STOP ROUTINE" or "START ROUTINE"
end

local function completeStep()
    if routineRunning and stepsCompleted < stepsNeeded then
        stepsCompleted = stepsCompleted + 1
        updateRoutineDisplay()
        
        if stepsCompleted >= stepsNeeded then
            local completeMsg = Instance.new("TextLabel")
            completeMsg.Size = UDim2.new(0.6, 0, 0, 50)
            completeMsg.Position = UDim2.new(0.2, 0, 0, 370)
            completeMsg.BackgroundColor3 = Color3.fromRGB(66, 185, 66)
            completeMsg.Text = "✓ ROUTINE COMPLETE! +25 COINS ✓"
            completeMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
            completeMsg.TextSize = 14
            completeMsg.Font = Enum.Font.GothamBold
            completeMsg.Parent = routineContent
            routineRunning = false
            
            spawn(function()
                wait(3)
                completeMsg:Destroy()
            end)
        end
    end
end

startRoutineBtn.MouseButton1Click:Connect(function()
    if routineRunning then
        routineRunning = false
        startRoutineBtn.Text = "START ROUTINE"
        startRoutineBtn.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    else
        stepsCompleted = 0
        routineRunning = true
        startRoutineBtn.Text = "STOP ROUTINE"
        startRoutineBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        updateRoutineDisplay()
        
        -- Simulate routine completion after 3 seconds
        spawn(function()
            wait(3)
            if routineRunning then
                completeStep()
            end
        end)
    end
end)

-- Claim Button for Daily Login
local claimBtn = Instance.new("TextButton")
claimBtn.Size = UDim2.new(0, 180, 0, 45)
claimBtn.Position = UDim2.new(0.5, -90, 1, -15)
claimBtn.BackgroundColor3 = Color3.fromRGB(66, 185, 66)
claimBtn.Text = "CLAIM!"
claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimBtn.Font = Enum.Font.GothamBold
claimBtn.TextSize = 18
claimBtn.Parent = mainFrame

local currentDay = 128
local canClaim = true

claimBtn.MouseButton1Click:Connect(function()
    if canClaim and dayRewards[currentDay] and not dayRewards[currentDay].claimedOverlay.Visible then
        canClaim = false
        claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        claimBtn.Text = "CLAIMED!"
        
        local current = dayRewards[currentDay]
        
        local sparkle = Instance.new("Frame")
        sparkle.Size = UDim2.new(1, 0, 1, 0)
        sparkle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        sparkle.BackgroundTransparency = 0.5
        sparkle.Parent = current.frame
        TweenService:Create(sparkle, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        
        current.claimedOverlay.Visible = true
        
        if current.dayLabel.Text == "TODAY" then
            current.dayLabel.Text = "DAY " .. currentDay
            current.dayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            local nextDay = dayRewards[currentDay + 1]
            if nextDay then
                nextDay.dayLabel.Text = "TODAY"
                nextDay.dayLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
        end
        
        currentDay = currentDay + 1
        
        spawn(function()
            wait(1.5)
            canClaim = true
            claimBtn.BackgroundColor3 = Color3.fromRGB(66, 185, 66)
            claimBtn.Text = "CLAIM!"
        end)
    end
end)

-- Tab switching
dailyTab.MouseButton1Click:Connect(function()
    contentFrame.Visible = true
    routineContent.Visible = false
    claimBtn.Visible = true
    dailyTab.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
    routineTab.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
end)

routineTab.MouseButton1Click:Connect(function()
    contentFrame.Visible = false
    routineContent.Visible = true
    claimBtn.Visible = false
    routineTab.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
    dailyTab.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    updateRoutineDisplay()
end)

-- Make GUI draggable
local dragging = false
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Daily Login & Routine GUI loaded!")