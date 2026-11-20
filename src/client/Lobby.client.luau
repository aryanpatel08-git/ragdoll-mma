--!strict
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local player = Players.LocalPlayer
local remote = game:GetService("ReplicatedStorage"):WaitForChild("MMALobbyIntent") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name = "MMALobbyHUD"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = player:WaitForChild("PlayerGui")
local bar = Instance.new("Frame")
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.fromScale(0.5, 0.97)
bar.Size = UDim2.new(0.56, 0, 0, 52)
bar.BackgroundColor3 = Color3.fromRGB(18, 25, 37)
bar.Parent = gui
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = bar
local status = Instance.new("TextLabel")
status.AnchorPoint = Vector2.new(0.5, 1)
status.Position = UDim2.fromScale(0.5, 0.88)
status.Size = UDim2.new(0.7, 0, 0, 48)
status.TextWrapped = true
status.BackgroundColor3 = Color3.fromRGB(18, 25, 37)
status.BackgroundTransparency = 0.2
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Text = "Walk to a cage door or select Quick Play."
status.Parent = gui
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.65, 0.52)
panel.BackgroundColor3 = Color3.fromRGB(18, 25, 37)
panel.Visible = false
panel.Parent = gui
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 42)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = panel
local body = Instance.new("TextLabel")
body.Position = UDim2.fromOffset(18, 56)
body.Size = UDim2.new(1, -36, 1, -70)
body.BackgroundTransparency = 1
body.TextColor3 = Color3.fromRGB(210, 218, 229)
body.TextWrapped = true
body.Font = Enum.Font.Gotham
body.TextSize = 17
body.Parent = panel
local function button(parent: Instance, text: string, callback: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.Text = text
	b.Size = UDim2.new(0.18, 0, 0, 44)
	b.BackgroundColor3 = Color3.fromRGB(52, 65, 84)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = 14
	b.Font = Enum.Font.GothamBold
	b.Parent = parent
	b.Activated:Connect(callback)
	return b
end
local close = button(panel, "×", function()
	panel.Visible = false
end)
close.Size = UDim2.fromOffset(44, 44)
close.Position = UDim2.new(1, -44, 0, 0)
button(bar, "Quick Play", function()
	remote:FireServer("QuickPlay")
end)
button(bar, "Leave", function()
	remote:FireServer("Leave")
end)
button(bar, "Customize", function()
	title.Text = "CUSTOMIZE"
	body.Text =
		"Changing area reserved for owned styles, builds and cosmetics. These progression systems are not built yet."
	panel.Visible = true
end)
button(bar, "Shop", function()
	title.Text = "SHOP"
	body.Text =
		"Shop counter reserved for the later cosmetics and economy step. No purchases are enabled."
	panel.Visible = true
end)
button(bar, "Cheer", function()
	local humanoid = if player.Character
		then player.Character:FindFirstChildOfClass("Humanoid")
		else nil
	if humanoid then
		local ok = pcall(function()
			humanoid:PlayEmote("cheer")
		end)
		if not ok then
			status.Text = "Your avatar does not have the Cheer emote available."
		end
	end
end)
remote.OnClientEvent:Connect(function(kind, message)
	if typeof(message) ~= "string" then
		return
	end
	if kind == "Notice" then
		status.Text = message
	elseif kind == "Panel" then
		title.Text = message
		body.Text = "This station is ready for the later "
			.. string.lower(message)
			.. " systems. No purchases, spins or saved customization are enabled yet."
		panel.Visible = true
	end
end)
-- An explicit click opens Roblox's invitation dialog; it never sends invites automatically.
local invite = button(gui, "Invite friends", function()
	pcall(function()
		SocialService:PromptGameInvite(player)
	end)
end)
invite.AnchorPoint = Vector2.new(1, 0)
invite.Position = UDim2.fromScale(0.98, 0.24)
invite.Size = UDim2.fromOffset(130, 44)
