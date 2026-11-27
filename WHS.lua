-- Webhook Sender | LocalScript
-- Executor-style GUI: draggable, minimize, close, webhook + message boxes, send button

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Paste your Discord webhook URL between the quotes
local WEBHOOK_URL = "https://discord.com/api/webhooks/1480865186263859200/Om_2C2e_yx3p2j7zUal3BqR3Kpf4Z9DRPDjw4Tmnn8zE8haOGf_rm4iHuEOKeennBW7x"

-- Pick the best parent available (executor-friendly, falls back to PlayerGui)
local function getGuiParent()
	local ok, result = pcall(function()
		if gethui then
			return gethui()
		end
	end)
	if ok and result then
		return result
	end
	return player:WaitForChild("PlayerGui")
end

-- Remove any previous copy
local parent = getGuiParent()
local old = parent:FindFirstChild("WebhookSender")
if old then
	old:Destroy()
end

-- Request function (executors expose one of these; normal LocalScripts have none)
local function getRequestFunction()
	return (syn and syn.request)
		or (http and http.request)
		or http_request
		or request
		or (fluxus and fluxus.request)
end

-- Theme
local COLORS = {
	Background = Color3.fromRGB(18, 18, 22),
	TitleBar = Color3.fromRGB(26, 26, 32),
	Field = Color3.fromRGB(30, 30, 38),
	Stroke = Color3.fromRGB(55, 55, 70),
	Text = Color3.fromRGB(230, 230, 240),
	SubText = Color3.fromRGB(140, 140, 160),
	Accent = Color3.fromRGB(88, 101, 242),
	Success = Color3.fromRGB(67, 181, 129),
	Error = Color3.fromRGB(237, 66, 69),
	Close = Color3.fromRGB(237, 66, 69),
	Minimize = Color3.fromRGB(250, 166, 26),
}

local FULL_SIZE = UDim2.new(0, 360, 0, 250)
local MINI_SIZE = UDim2.new(0, 360, 0, 34)

-- Helpers
local function corner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.Stroke
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function padding(inst, p)
	local u = Instance.new("UIPadding")
	u.PaddingLeft = UDim.new(0, p)
	u.PaddingRight = UDim.new(0, p)
	u.PaddingTop = UDim.new(0, p)
	u.PaddingBottom = UDim.new(0, p)
	u.Parent = inst
	return u
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WebhookSender"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = parent

-- Main window
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = FULL_SIZE
main.Position = UDim2.new(0.5, -180, 0.5, -125)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui
corner(main, 8)
stroke(main, COLORS.Stroke, 1)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = COLORS.TitleBar
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local accentLine = Instance.new("Frame")
accentLine.Name = "AccentLine"
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = COLORS.Accent
accentLine.BorderSizePixel = 0
accentLine.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Webhook Sender"
title.TextColor3 = COLORS.Text
title.Font = Enum.Font.Code
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local function makeTitleButton(name, text, color, xOffset)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 24, 0, 22)
	btn.Position = UDim2.new(1, xOffset, 0.5, -11)
	btn.BackgroundColor3 = COLORS.Field
	btn.AutoButtonColor = false
	btn.Text = text
	btn.TextColor3 = COLORS.Text
	btn.Font = Enum.Font.Code
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.Parent = titleBar
	corner(btn, 5)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.Field }):Play()
	end)
	return btn
end

local closeBtn = makeTitleButton("Close", "X", COLORS.Close, -32)
local minimizeBtn = makeTitleButton("Minimize", "-", COLORS.Minimize, -60)

-- Body
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -34)
body.Position = UDim2.new(0, 0, 0, 34)
body.BackgroundTransparency = 1
body.Parent = main
padding(body, 12)

local function makeLabel(text, y)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.Position = UDim2.new(0, 0, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = COLORS.SubText
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = body
	return lbl
end

local function makeBox(name, placeholder, y, height, multiline)
	local box = Instance.new("TextBox")
	box.Name = name
	box.Size = UDim2.new(1, 0, 0, height)
	box.Position = UDim2.new(0, 0, 0, y)
	box.BackgroundColor3 = COLORS.Field
	box.BorderSizePixel = 0
	box.Text = ""
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = COLORS.SubText
	box.TextColor3 = COLORS.Text
	box.Font = Enum.Font.Code
	box.TextSize = 13
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
	box.ClearTextOnFocus = false
	box.MultiLine = multiline or false
	box.TextWrapped = multiline or false
	box.TextTruncate = multiline and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
	box.Parent = body
	corner(box, 5)
	local s = stroke(box, COLORS.Stroke, 1)
	padding(box, 8)

	box.Focused:Connect(function()
		TweenService:Create(s, TweenInfo.new(0.12), { Color = COLORS.Accent }):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(s, TweenInfo.new(0.12), { Color = COLORS.Stroke }):Play()
	end)
	return box
end

makeLabel("// message", 0)
local messageBox = makeBox("MessageBox", "Type the message to send...", 18, 100, true)

-- Send button
local sendBtn = Instance.new("TextButton")
sendBtn.Name = "SendButton"
sendBtn.Size = UDim2.new(1, 0, 0, 34)
sendBtn.Position = UDim2.new(0, 0, 0, 130)
sendBtn.BackgroundColor3 = COLORS.Accent
sendBtn.AutoButtonColor = false
sendBtn.Text = "SEND"
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.Font = Enum.Font.Code
sendBtn.TextSize = 14
sendBtn.BorderSizePixel = 0
sendBtn.Parent = body
corner(sendBtn, 5)

sendBtn.MouseEnter:Connect(function()
	TweenService:Create(sendBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(110, 122, 255) }):Play()
end)
sendBtn.MouseLeave:Connect(function()
	TweenService:Create(sendBtn, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.Accent }):Play()
end)

-- Status line
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 16)
status.Position = UDim2.new(0, 0, 0, 172)
status.BackgroundTransparency = 1
status.Text = "> idle"
status.TextColor3 = COLORS.SubText
status.Font = Enum.Font.Code
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = body

local function setStatus(text, color)
	status.Text = "> " .. text
	status.TextColor3 = color or COLORS.SubText
end

-- Sending logic
local sending = false

local function sendWebhook()
	if sending then
		return
	end

	local url = WEBHOOK_URL
	local message = messageBox.Text

	if not url:match("^https://discord%.com/api/webhooks/") and not url:match("^https://discordapp%.com/api/webhooks/") then
		setStatus("set WEBHOOK_URL at top of script", COLORS.Error)
		return
	end
	if message:gsub("%s+", "") == "" then
		setStatus("enter a message", COLORS.Error)
		return
	end

	-- Discord code block: ```lua, newline, message, newline, ```
	local formatted = "```lua\n" .. message .. "\n```"

	if #formatted > 2000 then
		setStatus("message too long (max ~1989 chars)", COLORS.Error)
		return
	end

	local requestFn = getRequestFunction()
	if not requestFn then
		setStatus("no http request function found", COLORS.Error)
		return
	end

	sending = true
	sendBtn.Text = "SENDING..."
	setStatus("sending...", COLORS.Minimize)

	local ok, response = pcall(function()
		return requestFn({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({ content = formatted }),
		})
	end)

	if ok and response and (response.StatusCode == 204 or response.StatusCode == 200) then
		setStatus("sent successfully", COLORS.Success)
	elseif ok and response then
		setStatus("failed (status " .. tostring(response.StatusCode) .. ")", COLORS.Error)
	else
		setStatus("request error", COLORS.Error)
	end

	sendBtn.Text = "SEND"
	sending = false
end

sendBtn.MouseButton1Click:Connect(sendWebhook)

-- Minimize / close
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	minimizeBtn.Text = minimized and "+" or "-"
	if minimized then
		body.Visible = false
	end
	local tween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = minimized and MINI_SIZE or FULL_SIZE,
	})
	tween:Play()
	if not minimized then
		tween.Completed:Connect(function()
			if not minimized then
				body.Visible = true
			end
		end)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Dragging (mouse + touch)
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
