-- LocalScript by ChatGPT – Full Modern UI System (2025-ready)

-- SETTINGS
local correctKey = "openai-2025"
local getKeyURL = "https://example.com/get-key" -- Placeholder

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Name = "ModernUI"

-- FUNCTIONS
local function createUICorner(radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	return corner
end

local function createGradient()
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 103, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 76, 255))
	}
	gradient.Rotation = 45
	return gradient
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- LOADING UI
local loadingFrame = Instance.new("Frame", gui)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
loadingFrame.Size = UDim2.fromScale(1, 1)
loadingFrame.Position = UDim2.new(0, 0, 0, 0)
createUICorner(0).Parent = loadingFrame
createGradient().Parent = loadingFrame

local progressBar = Instance.new("Frame", loadingFrame)
progressBar.Size = UDim2.new(0, 0, 0, 5)
progressBar.Position = UDim2.new(0, 0, 0.9, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
createUICorner(5).Parent = progressBar

-- Simulate loading
for i = 1, 100 do
	wait(0.02)
	tween(progressBar, {Size = UDim2.new(i / 100, 0, 0, 5)}, 0.03)
end
wait(0.5)

-- Fade out loading
tween(loadingFrame, {BackgroundTransparency = 1}, 0.5)
tween(progressBar, {BackgroundTransparency = 1}, 0.5)
wait(0.5)
loadingFrame:Destroy()

-- KEY SYSTEM UI
local keyFrame = Instance.new("Frame", gui)
keyFrame.Size = UDim2.fromScale(0.4, 0.4)
keyFrame.Position = UDim2.fromScale(0.3, 0.3)
keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
createUICorner(12).Parent = keyFrame
createGradient().Parent = keyFrame

local title = Instance.new("TextLabel", keyFrame)
title.Size = UDim2.fromScale(1, 0.2)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🔐 Enter Your Key"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.PlaceholderText = "Enter key here..."
keyBox.Text = ""
keyBox.Size = UDim2.fromScale(0.8, 0.2)
keyBox.Position = UDim2.fromScale(0.1, 0.25)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
createUICorner(8).Parent = keyBox

local pasteBtn = Instance.new("TextButton", keyFrame)
pasteBtn.Text = "📋 Paste"
pasteBtn.Size = UDim2.fromScale(0.35, 0.15)
pasteBtn.Position = UDim2.fromScale(0.1, 0.5)
pasteBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
pasteBtn.Font = Enum.Font.Gotham
pasteBtn.TextSize = 16
pasteBtn.TextColor3 = Color3.new(1,1,1)
createUICorner(8).Parent = pasteBtn

local getKeyBtn = Instance.new("TextButton", keyFrame)
getKeyBtn.Text = "🔗 Get Key"
getKeyBtn.Size = UDim2.fromScale(0.35, 0.15)
getKeyBtn.Position = UDim2.fromScale(0.55, 0.5)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
getKeyBtn.Font = Enum.Font.Gotham
getKeyBtn.TextSize = 16
getKeyBtn.TextColor3 = Color3.new(1,1,1)
createUICorner(8).Parent = getKeyBtn

local submitBtn = Instance.new("TextButton", keyFrame)
submitBtn.Text = "✔️ Submit"
submitBtn.Size = UDim2.fromScale(0.8, 0.15)
submitBtn.Position = UDim2.fromScale(0.1, 0.7)
submitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 18
submitBtn.TextColor3 = Color3.new(1,1,1)
createUICorner(8).Parent = submitBtn

-- Key system logic
pasteBtn.MouseButton1Click:Connect(function()
	pcall(function()
		keyBox.Text = tostring(setclipboard and getclipboard and getclipboard() or "")
	end)
end)

getKeyBtn.MouseButton1Click:Connect(function()
	if syn then
		syn.request({Url = getKeyURL, Method = "GET"})
	elseif request then
		request({Url = getKeyURL, Method = "GET"})
	end
end)

submitBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == correctKey then
		tween(keyFrame, {Position = UDim2.fromScale(1.5, 0.3)}, 0.5)
		wait(0.5)
		keyFrame:Destroy()
		showMainUI()
	else
		submitBtn.Text = "❌ Invalid"
		wait(1)
		submitBtn.Text = "✔️ Submit"
	end
end)

-- MAIN UI (only shows after key entry)
function showMainUI()
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.fromScale(1, 1)
	main.Position = UDim2.new(0, 0, 0, 0)
	main.BackgroundTransparency = 1

	local sidebar = Instance.new("Frame", main)
	sidebar.Size = UDim2.fromScale(0.2, 1)
	sidebar.Position = UDim2.new(0, 0, 0, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sidebar.BackgroundTransparency = 0.2
	createUICorner(0).Parent = sidebar

	local homeBtn = Instance.new("TextButton", sidebar)
	homeBtn.Text = "🏠 Home"
	homeBtn.Size = UDim2.fromScale(0.9, 0.1)
	homeBtn.Position = UDim2.fromScale(0.05, 0.1)
	homeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	homeBtn.Font = Enum.Font.Gotham
	homeBtn.TextSize = 18
	homeBtn.TextColor3 = Color3.new(1,1,1)
	createUICorner(6).Parent = homeBtn

	local logoutBtn = Instance.new("TextButton", sidebar)
	logoutBtn.Text = "🚪 Logout"
	logoutBtn.Size = UDim2.fromScale(0.9, 0.1)
	logoutBtn.Position = UDim2.fromScale(0.05, 0.8)
	logoutBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
	logoutBtn.Font = Enum.Font.GothamBold
	logoutBtn.TextSize = 18
	logoutBtn.TextColor3 = Color3.new(1,1,1)
	createUICorner(6).Parent = logoutBtn

	logoutBtn.MouseButton1Click:Connect(function()
		main:Destroy()
		gui:ClearAllChildren()
		script:Clone().Parent = player:WaitForChild("PlayerGui")
	end)
end
