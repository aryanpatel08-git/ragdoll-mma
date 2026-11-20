--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MMACombatHUD"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = localPlayer:WaitForChild("PlayerGui")
local colors = {
	Health = Color3.fromRGB(222, 73, 83),
	Body = Color3.fromRGB(235, 164, 72),
	Stamina = Color3.fromRGB(97, 208, 160),
	Guard = Color3.fromRGB(80, 158, 234),
}
local bars: { [string]: { [string]: Frame } } = {}
local names: { [string]: TextLabel } = {}
for _, side in { "You", "Opponent" } do
	local panel = Instance.new("Frame")
	panel.Name = side
	panel.AnchorPoint = Vector2.new(if side == "You" then 0 else 1, 0)
	panel.Position = UDim2.fromScale(if side == "You" then 0.02 else 0.98, 0.03)
	panel.Size = UDim2.new(0.32, 0, 0, 113)
	panel.BackgroundColor3 = Color3.fromRGB(17, 25, 39)
	panel.BackgroundTransparency = 0.12
	panel.Parent = gui
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 25)
	title.Position = UDim2.fromOffset(8, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.Parent = panel
	names[side] = title
	bars[side] = {}
	for i, key in { "Health", "Body", "Stamina", "Guard" } do
		local back = Instance.new("Frame")
		back.Name = key
		back.Position = UDim2.new(0, 8, 0, 28 + (i - 1) * 20)
		back.Size = UDim2.new(1, -16, 0, 14)
		back.BackgroundColor3 = Color3.fromRGB(45, 53, 65)
		back.BorderSizePixel = 0
		back.Parent = panel
		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(1, 1)
		fill.BackgroundColor3 = colors[key]
		fill.BorderSizePixel = 0
		fill.Parent = back
		bars[side][key] = fill
		local label = Instance.new("TextLabel")
		label.Name = "Readout"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextSize = 11
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0.4
		label.Font = Enum.Font.GothamBold
		label.Parent = back
	end
end
local notice = Instance.new("TextLabel")
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.fromScale(0.5, 0.03)
notice.Size = UDim2.new(0.26, 0, 0, 55)
notice.BackgroundTransparency = 1
notice.TextWrapped = true
notice.TextColor3 = Color3.new(1, 1, 1)
notice.TextSize = 12
notice.Font = Enum.Font.GothamBold
notice.Parent = gui
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	local id = localPlayer:GetAttribute("MMAOpponentUserId")
	local opponent = if typeof(id) == "number" and id ~= 0
		then Players:GetPlayerByUserId(id)
		else nil
	notice.Text = if opponent
		then "COMBAT PROTOTYPE\nQ / E punch · Z / C kick · F guard"
		else "WAITING FOR SECOND FIGHTER\nUse Quick Play or join a cage"
	for _, side in { "You", "Opponent" } do
		local p = if side == "You" then localPlayer else opponent
		local panel = names[side].Parent :: Frame
		panel.Visible = opponent ~= nil
		names[side].Text = if p then p.DisplayName else "Waiting for opponent"
		for key, fill in bars[side] do
			local value = if p and p.Character then p.Character:GetAttribute(key) else nil
			local n = if typeof(value) == "number" then math.clamp(value, 0, 100) else 0
			fill.Size = UDim2.fromScale(n / 100, 1)
			local label = fill.Parent:FindFirstChild("Readout") :: TextLabel
			label.Text = key .. " " .. tostring(math.floor(n))
		end
	end
end)
