--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

--// STATES
local espEnabled, flyEnabled, noclipEnabled, tpEnabled = false,false,false,false
local flySpeed, walkSpeed = 60,16

local hotkeysEnabled = false
local minimized = false

local Hotkeys = {
	Fly = Enum.KeyCode.F,
	ESP = Enum.KeyCode.G,
	Noclip = Enum.KeyCode.N,
	TP = Enum.KeyCode.V,
	Minimize = Enum.KeyCode.X
}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "c00lgui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// BLUR INTRO
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 24
TweenService:Create(blur, TweenInfo.new(0.6), {Size = 0}):Play()
task.delay(0.7, function() blur:Destroy() end)

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,0,0,0)
main.Position = UDim2.new(0.5,0,0.5,0)
main.BackgroundColor3 = Color3.fromRGB(15,0,0)
main.BorderColor3 = Color3.fromRGB(255,0,0)
main.BorderSizePixel = 2
main.ClipsDescendants = true

TweenService:Create(
	main,
	TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Size = UDim2.new(0,360,0,460), Position = UDim2.new(0.5,-180,0.5,-230)}
):Play()

--// TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(35,0,0)
top.BorderColor3 = Color3.fromRGB(255,0,0)
top.BorderSizePixel = 2

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "c00lgui Forsaken'd -- by Pal1t0H10 v1.3"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,90,90)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

--// TOP BUTTONS
local function topBtn(txt, x)
	local b = Instance.new("TextButton", top)
	b.Size = UDim2.new(0,30,0,25)
	b.Position = UDim2.new(1,x,0,5)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(255,120,120)
	b.BackgroundColor3 = Color3.fromRGB(60,0,0)
	b.BorderColor3 = Color3.fromRGB(255,0,0)
	b.BorderSizePixel = 1
	return b
end

local minBtn = topBtn("-", -70)
local closeBtn = topBtn("X", -35)

--// CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-35)
content.Position = UDim2.new(0,0,0,35)
content.BackgroundTransparency = 1

--// DRAG
do
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

--// BUTTON MAKER
local function hubButton(text, y)
	local b = Instance.new("TextButton", content)
	b.Size = UDim2.new(0,240,0,40)
	b.Position = UDim2.new(0.5,-120,0,y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(255,210,210)
	b.BackgroundColor3 = Color3.fromRGB(60,0,0)
	b.BorderColor3 = Color3.fromRGB(255,0,0)
	b.BorderSizePixel = 1
	return b
end

--// BUTTONS
local espBtn = hubButton("ESP : OFF", 10)
local flyBtn = hubButton("FLY : OFF", 60)
local noclipBtn = hubButton("NOCLIP : OFF", 110)
local tpBtn = hubButton("CLICK TP : OFF", 160)
local hkBtn = hubButton("HOTKEYS : OFF", 210)

--// SLIDER
local function createSlider(text,min,max,default,y,cb)
	local f = Instance.new("Frame", content)
	f.Size = UDim2.new(0,260,0,50)
	f.Position = UDim2.new(0.5,-130,0,y)
	f.BackgroundColor3 = Color3.fromRGB(30,0,0)
	f.BorderColor3 = Color3.fromRGB(200,0,0)
	f.BorderSizePixel = 1

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1,0,0,18)
	l.BackgroundTransparency = 1
	l.Text = text..": "..default
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(255,200,200)

	local bar = Instance.new("Frame", f)
	bar.Size = UDim2.new(1,-20,0,6)
	bar.Position = UDim2.new(0,10,0,30)
	bar.BackgroundColor3 = Color3.fromRGB(70,0,0)
	bar.BorderSizePixel = 0

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
	fill.BorderSizePixel = 0

	local dragging=false
	bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local pct = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
			fill.Size = UDim2.new(pct,0,1,0)
			local v = math.floor(min+(max-min)*pct)
			l.Text = text..": "..v
			cb(v)
		end
	end)
end

createSlider("Fly Speed",20,200,flySpeed,260,function(v) flySpeed=v end)
createSlider("Walk Speed",10,50,walkSpeed,320,function(v) walkSpeed=v end)

--// SPEED FORCE (Forsaken fix)
RunService.Heartbeat:Connect(function()
	if player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed ~= walkSpeed then
			hum.WalkSpeed = walkSpeed
		end
	end
end)

--// ROLE DETECTION (Forsaken)
local function getRole(plr)
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum.MaxHealth > 500 then return "KILLER" end
	return "SURVIVOR"
end

--// ESP
local function createESP(plr)
	if plr==player or not plr.Character or not plr.Character:FindFirstChild("Head") then return end
	if plr.Character:FindFirstChild("ESP_H") then return end

	local role = getRole(plr)
	local color = role=="KILLER" and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,150,255)

	local h = Instance.new("Highlight", plr.Character)
	h.Name="ESP_H"
	h.FillColor=color
	h.FillTransparency=0.35

	local bb = Instance.new("BillboardGui", plr.Character.Head)
	bb.Name="ESP_BB"
	bb.Size=UDim2.new(0,220,0,35)
	bb.StudsOffset=Vector3.new(0,3,0)
	bb.AlwaysOnTop=true

	local t = Instance.new("TextLabel", bb)
	t.Size=UDim2.new(1,0,1,0)
	t.BackgroundTransparency=1
	t.TextScaled=true
	t.Font=Enum.Font.GothamBold
	t.TextStrokeTransparency=0
	t.TextColor3=color
	t.Text=plr.Name.." ["..role.."]"
end

local function clearESP()
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character then
			if p.Character:FindFirstChild("ESP_H") then p.Character.ESP_H:Destroy() end
			if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESP_BB") then
				p.Character.Head.ESP_BB:Destroy()
			end
		end
	end
end

--// FLY
local bv,bg
RunService.RenderStepped:Connect(function()
	if flyEnabled and bv and bg then
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += camera.CFrame.UpVector end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= camera.CFrame.UpVector end
		bv.Velocity = dir * flySpeed
		bg.CFrame = camera.CFrame
	end
end)

--// BUTTON LOGIC
espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "ESP : ON" or "ESP : OFF"
	if espEnabled then
		for _,p in pairs(Players:GetPlayers()) do createESP(p) end
	else
		clearESP()
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = flyEnabled and "FLY : ON" or "FLY : OFF"
	if flyEnabled then
		local hrp = player.Character:WaitForChild("HumanoidRootPart")
		bv = Instance.new("BodyVelocity",hrp)
		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bg = Instance.new("BodyGyro",hrp)
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = noclipEnabled and "NOCLIP : ON" or "NOCLIP : OFF"
end)

tpBtn.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	tpBtn.Text = tpEnabled and "CLICK TP : ON" or "CLICK TP : OFF"
end)

--// TP CLICK
mouse.Button1Down:Connect(function()
	if tpEnabled and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0)) end
	end
end)

--// NOCLIP
RunService.Stepped:Connect(function()
	if noclipEnabled and player.Character then
		for _,p in pairs(player.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

--// MINIMIZE
local function toggleMinimize()
	minimized = not minimized
	TweenService:Create(
		content,
		TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
		{Size = minimized and UDim2.new(1,0,0,0) or UDim2.new(1,0,1,-35)}
	):Play()
end

minBtn.MouseButton1Click:Connect(toggleMinimize)

--// HOTKEYS
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Hotkeys.Fly then flyBtn:Activate() end
	if i.KeyCode == Hotkeys.ESP then espBtn:Activate() end
	if i.KeyCode == Hotkeys.Noclip then noclipBtn:Activate() end
	if i.KeyCode == Hotkeys.TP then tpBtn:Activate() end
	if i.KeyCode == Hotkeys.Minimize then toggleMinimize() end
end)

--// CLOSE
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--// KILLER NEAR WARNING (Forsaken)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WARNING_DISTANCE = 45 -- studs (ajústalo si quieres)

--// GUI WARNING
local warnGui = Instance.new("ScreenGui")
warnGui.Name = "KillerWarningGui"
warnGui.ResetOnSpawn = false
warnGui.Parent = player:WaitForChild("PlayerGui")

local warnText = Instance.new("TextLabel", warnGui)
warnText.Size = UDim2.new(0,420,0,60)
warnText.Position = UDim2.new(0.5,-210,0.15,0)
warnText.BackgroundTransparency = 1
warnText.Text = "⚠ NEAR TO KILLER ⚠"
warnText.Font = Enum.Font.GothamBlack
warnText.TextSize = 28
warnText.TextColor3 = Color3.fromRGB(255,0,0)
warnText.TextStrokeTransparency = 0
warnText.TextTransparency = 1
warnText.Visible = true

local visible = false

local function isKiller(plr)
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	return hum and hum.MaxHealth > 500
end

local function showWarning()
	if visible then return end
	visible = true
	TweenService:Create(
		warnText,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	):Play()
end

local function hideWarning()
	if not visible then return end
	visible = false
	TweenService:Create(
		warnText,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 1}
	):Play()
end

--// DISTANCE CHECK
RunService.Heartbeat:Connect(function()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hideWarning()
		return
	end

	local killerNear = false

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and isKiller(plr) and plr.Character then
			local khrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if khrp then
				local dist = (hrp.Position - khrp.Position).Magnitude
				if dist <= WARNING_DISTANCE then
					killerNear = true
					break
				end
			end
		end
	end

	if killerNear then
		showWarning()
	else
		hideWarning()
	end
end)
