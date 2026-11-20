--!strict
assert(game.PlaceId == 74547971656749, "Wrong place")
assert(not workspace:FindFirstChild("MMAGym"), "Lobby already exists")
local template = workspace:FindFirstChild("MMAFoundation") :: Model
assert(template, "Missing prototype cage")
local gym = Instance.new("Model")
gym.Name = "MMAGym"
gym.Parent = workspace
local navy = Color3.fromRGB(18, 25, 37)
local gray = Color3.fromRGB(53, 62, 74)
local white = Color3.fromRGB(233, 236, 240)
local gold = Color3.fromRGB(240, 183, 77)
local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	pos: Vector3,
	color: Color3
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function sign(p: BasePart, text: string, face: Enum.NormalId?)
	local g = Instance.new("SurfaceGui")
	g.Face = face or Enum.NormalId.Front
	g.PixelsPerStud = 30
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = white
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = g
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.05, 0)
	pad.PaddingRight = UDim.new(0.05, 0)
	pad.Parent = t
end
part(gym, "GymFloor", Vector3.new(280, 1, 205), Vector3.new(200, 0, 0), navy)
part(gym, "MainAisle", Vector3.new(245, 0.06, 29), Vector3.new(200, 0.54, 0), gray)
local cages = Instance.new("Folder")
cages.Name = "Cages"
cages.Parent = gym
for index = 1, 6 do
	local row = if index <= 3 then -1 else 1
	local center = Vector3.new(120 + ((index - 1) % 3) * 80, 0, row * 53)
	local cage = template:Clone()
	cage.Name = "Cage" .. index
	cage:SetAttribute("CageId", index)
	cage:SetAttribute("State", "Open")
	cage:PivotTo(template:GetPivot() + center)
	local doorZ = center.Z - row * 30
	for _, p in cage:GetChildren() do
		if p:IsA("BasePart") then
			if p.Name == "PrototypeSign" or p.Name == "ArenaHeader" then
				p:Destroy()
			elseif
				math.abs(p.Position.Z - doorZ) < 0.7
				and math.abs(p.Position.X - center.X) < 5
				and (p.Name == "FenceBar" or p.Name == "PaddedPost")
			then
				p:Destroy()
			elseif p.Name == "FenceCollision" and math.abs(p.Position.Z - doorZ) < 0.7 then
				p.Size = Vector3.new(25, 8, 0.25)
				p.Position = Vector3.new(center.X - 17.5, 5.5, doorZ)
				local other = p:Clone()
				other.Position = Vector3.new(center.X + 17.5, 5.5, doorZ)
				other.Parent = cage
			end
		end
	end
	local door =
		part(cage, "Door", Vector3.new(10, 8, 0.3), Vector3.new(center.X, 5.5, doorZ), gray)
	door.Transparency = 1
	door.CanCollide = false
	local entry = part(
		cage,
		"Entry",
		Vector3.new(8, 0.15, 5),
		Vector3.new(center.X, 0.65, doorZ - row * 5),
		gold
	)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "JoinPrompt"
	prompt.ActionText = "Join cage"
	prompt.ObjectText = "Cage " .. index
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0.2
	prompt.Parent = entry
	local light = part(
		cage,
		"StatusLight",
		Vector3.new(2, 1, 1),
		Vector3.new(center.X, 11, doorZ),
		Color3.fromRGB(89, 209, 151)
	)
	light.Material = Enum.Material.Neon
	local board =
		part(cage, "StatusBoard", Vector3.new(22, 3, 0.4), Vector3.new(center.X, 13, doorZ), navy)
	sign(board, "CAGE " .. index .. " · OPEN")
	sign(board, "CAGE " .. index .. " · OPEN", Enum.NormalId.Back)
	cage.Parent = cages
	task.wait()
end
local spawn = Instance.new("SpawnLocation")
spawn.Name = "LobbySpawn"
spawn.Size = Vector3.new(12, 0.3, 12)
spawn.Position = Vector3.new(200, 0.8, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = gold
spawn.Material = Enum.Material.SmoothPlastic
spawn.Parent = gym
local banner = part(gym, "Welcome", Vector3.new(46, 6, 1), Vector3.new(200, 10, 101), navy)
sign(banner, "RAGDOLL MMA\nTRAIN · CHALLENGE · REMATCH")
local training = Instance.new("Folder")
training.Name = "Training"
training.Parent = gym
for i = 1, 3 do
	local x = 87 + (i - 1) * 12
	part(training, "BagFrame", Vector3.new(1, 12, 1), Vector3.new(x, 6, 96), gray)
	part(training, "BagArm", Vector3.new(1, 1, 8), Vector3.new(x, 12, 92), gray)
	local bag = part(
		training,
		"Bag" .. i,
		Vector3.new(4, 7, 4),
		Vector3.new(x, 7, 89),
		if i % 2 == 0 then gold else Color3.fromRGB(194, 53, 66)
	)
	bag.Shape = Enum.PartType.Cylinder
	bag.Orientation = Vector3.new(0, 0, 90)
	local p = Instance.new("ProximityPrompt")
	p.Name = "PracticePrompt"
	p.ActionText = "Practice strike"
	p.ObjectText = "Punching bag"
	p.MaxActivationDistance = 9
	p.RequiresLineOfSight = false
	p.Parent = bag
	local board =
		part(training, "Readout" .. i, Vector3.new(10, 3, 0.3), Vector3.new(x, 3, 95), navy)
	sign(board, "TRAINING\nDamage / stamina")
end
local dummy = part(training, "ComboDummy", Vector3.new(3, 5, 2), Vector3.new(134, 4, 90), gold)
part(training, "DummyHead", Vector3.new(2, 2, 2), Vector3.new(134, 7.5, 90), white)
local dp = Instance.new("ProximityPrompt")
dp.Name = "PracticePrompt"
dp.ActionText = "Practice combo"
dp.ObjectText = "Combo dummy"
dp.MaxActivationDistance = 9
dp.RequiresLineOfSight = false
dp.Parent = dummy
local db = part(training, "Readout4", Vector3.new(13, 3, 0.3), Vector3.new(134, 3, 95), navy)
sign(db, "COMBO PRACTICE\nQ → E → C")
for i = 1, 4 do
	local x = 83 + (i - 1) * 77
	for _, z in { -10, 10 } do
		part(gym, "SpectatorBench", Vector3.new(12, 1, 3), Vector3.new(x, 2, z), gray)
		for _, dx in { -4, 4 } do
			part(gym, "BenchLeg", Vector3.new(0.6, 1.5, 2), Vector3.new(x + dx, 1, z), navy)
		end
	end
end
for i, title in { "CUSTOMIZE", "SHOP" } do
	local x = 255 + (i - 1) * 33
	local counter =
		part(gym, title .. "Counter", Vector3.new(25, 4, 7), Vector3.new(x, 2.5, 91), gray)
	local board = part(gym, title .. "Sign", Vector3.new(25, 4, 0.4), Vector3.new(x, 8, 95), navy)
	sign(board, title)
	local p = Instance.new("ProximityPrompt")
	p.Name = title .. "Prompt"
	p.ActionText = "Open " .. string.lower(title)
	p.ObjectText = title
	p.MaxActivationDistance = 10
	p.Parent = counter
end
local tutorial =
	part(gym, "TutorialMat", Vector3.new(33, 0.15, 18), Vector3.new(200, 0.65, 89), gray)
sign(tutorial, "TUTORIAL\nMove · Strike · Guard · Recover", Enum.NormalId.Top)
local old = workspace:FindFirstChild("SpawnLocation")
if old and old:IsA("SpawnLocation") then
	old:SetAttribute("MMAOriginalEnabled", old.Enabled)
	old.Enabled = false
end
return {
	cages = #cages:GetChildren(),
	parts = #gym:GetDescendants(),
	spawn = tostring(spawn.Position),
}
