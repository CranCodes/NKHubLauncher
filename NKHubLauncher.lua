
--// UNIVERSAL GAME LOADER
--// Automatically detects game and displays loading UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

--// GAME SCRIPTS
-- Replace these IDs and URLs with your own
local GameScripts = {
    [120219252362013] = "https://raw.githubusercontent.com/CranCodes/nkhubs/refs/heads/main/TFFA.lua",
    [75108253383447] = "https://raw.githubusercontent.com/CranCodes/nkhubs/refs/heads/main/PSAC.lua",
    [125677257801200] = "https://raw.githubusercontent.com/CranCodes/nkhubs/refs/heads/main/NSS.lua"
}

--// DETECT GAME
local GameId = game.PlaceId
local ScriptURL = GameScripts[GameId]

--// GET GAME NAME
local GameName = "Unknown Game"

pcall(function()
    local Info = MarketplaceService:GetProductInfo(GameId)
    GameName = Info.Name
end)

--// CREATE GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Compatible with common executor environments
local ParentGui = Player:WaitForChild("PlayerGui")

if type(gethui) == "function" then
    local success, result = pcall(gethui)
    if success and result then
        ParentGui = result
    end
end

ScreenGui.Parent = ParentGui

--// MAIN FRAME
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 90)
Frame.Position = UDim2.new(0.5, -150, 0.5, -45)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BackgroundTransparency = 1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 100, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Frame

--// LOADING TEXT
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, -20, 0, 45)
LoadingText.Position = UDim2.new(0, 10, 0, 10)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading " .. GameName .. "..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 17
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextScaled = true
LoadingText.TextWrapped = true
LoadingText.Parent = Frame

local TextLimit = Instance.new("UITextSizeConstraint")
TextLimit.MaxTextSize = 17
TextLimit.Parent = LoadingText

--// LOADING BAR BACKGROUND
local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0.85, 0, 0, 5)
BarBackground.Position = UDim2.new(0.075, 0, 0.78, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = Frame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarBackground

--// LOADING BAR
local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = BarBackground

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(1, 0)
LoadingCorner.Parent = LoadingBar

--// FADE IN
TweenService:Create(
    Frame,
    TweenInfo.new(0.4),
    {BackgroundTransparency = 0}
):Play()

--// LOADING ANIMATION
local Running = true

task.spawn(function()
    while Running do
        LoadingBar.Size = UDim2.new(0, 0, 1, 0)

        local Tween = TweenService:Create(
            LoadingBar,
            TweenInfo.new(1.5, Enum.EasingStyle.Linear),
            {Size = UDim2.new(1, 0, 1, 0)}
        )

        Tween:Play()
        Tween.Completed:Wait()
    end
end)

--// EXECUTE GAME SCRIPT
task.wait(0.8)

if ScriptURL then
    local Success, Error = pcall(function()
        loadstring(game:HttpGet(ScriptURL))()
    end)

    if Success then
        LoadingText.Text = "Loaded " .. GameName .. "!"
        LoadingText.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        LoadingText.Text = "Failed to load!"
        LoadingText.TextColor3 = Color3.fromRGB(255, 100, 100)
        warn(Error)
    end
else
    LoadingText.Text = "Game not supported!"
    LoadingText.TextColor3 = Color3.fromRGB(255, 100, 100)
end

--// FINISH LOADING
Running = false
LoadingBar.Size = UDim2.new(1, 0, 1, 0)

task.wait(1.5)

TweenService:Create(
    Frame,
    TweenInfo.new(0.4),
    {BackgroundTransparency = 1}
):Play()

task.wait(0.4)
ScreenGui:Destroy()
