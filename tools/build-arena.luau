--!strict
-- Run once in Studio Edit mode. Remove Workspace.MMAFoundation to undo geometry.
assert(game.PlaceId == 74547971656749, "Wrong place: expected MMA Dev")
assert(not workspace:FindFirstChild("MMAFoundation"), "Arena already exists; preserve it")
local model = Instance.new("Model")
model.Name = "MMAFoundation"
model:SetAttribute("Milestone", "Step 1 - movement prototype")
model.Parent = workspace
local navy = Color3.fromRGB(17, 25, 39)
local steel = Color3.fromRGB(45, 53, 65)
local mat = Color3.fromRGB(218, 224, 226)
local red = Color3.fromRGB(220, 61, 67)
local blue = Color3.fromRGB(49, 132, 231)
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end
local function label(p: BasePart, text: string, face: Enum.NormalId, color: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = gui
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.06, 0)
	pad.PaddingRight = UDim.new(0.06, 0)
	pad.Parent = t
end
part("Stage", Vector3.new(82, 1, 82), CFrame.new(0, 0.5, 0), navy)
local floor = part("FightMat", Vector3.new(60, 0.4, 60), CFrame.new(0, 1.2, 0), mat)
label(floor, "RAGDOLL\nMMA", Enum.NormalId.Top, navy)
for _, z in { -29, 29 } do
	part("MatTrim", Vector3.new(58, 0.03, 0.3), CFrame.new(0, 1.42, z), navy, false)
end
for _, x in { -29, 29 } do
	part("MatTrim", Vector3.new(0.3, 0.03, 58), CFrame.new(x, 1.42, 0), navy, false)
end
for edge = 0, 3 do
	local frame = CFrame.Angles(0, math.rad(edge * 90), 0)
	local function at(x: number, y: number, z: number): CFrame
		return frame * CFrame.new(x, y, z)
	end
	part("FenceCollision", Vector3.new(60, 8, 0.25), at(0, 5.5, 30), steel).Transparency = 1
	for _, y in { 1.7, 9.5 } do
		part("FenceRail", Vector3.new(60, 0.3, 0.3), at(0, y, 30), steel)
	end
	for i = -14, 14 do
		-- Thin bars provide an inexpensive readable cage without imported assets.
		part("FenceBar", Vector3.new(0.055, 7.7, 0.055), at(i * 2, 5.6, 30), steel, false)
	end
	for _, x in { -30, 0, 30 } do
		part(
			"PaddedPost",
			Vector3.new(0.9, 8.7, 0.9),
			at(x, 5.6, 30),
			if edge % 2 == 0 then red else blue
		)
	end
	task.wait()
end
for i, x in { -16, 16 } do
	local color = if i == 1 then red else blue
	local marker = part(
		if i == 1 then "RedCorner" else "BlueCorner",
		Vector3.new(7, 0.04, 7),
		CFrame.new(x, 1.44, 0),
		color,
		false
	)
	label(marker, if i == 1 then "RED" else "BLUE", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local spawn = Instance.new("Part")
	spawn.Name = if i == 1 then "RedFighterSpawn" else "BlueFighterSpawn"
	spawn.Size = Vector3.new(1, 1, 1)
	spawn.CFrame = CFrame.lookAt(Vector3.new(x, 5, 0), Vector3.new(-x, 5, 0))
	spawn.Transparency = 1
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Parent = model
end
local board = part("ArenaHeader", Vector3.new(42, 6, 0.7), CFrame.new(0, 15, 32), navy)
label(board, "RAGDOLL MMA  /  TRAINING CAGE", Enum.NormalId.Front, Color3.new(1, 1, 1))
for _, x in { -28, 28 } do
	part("LightMast", Vector3.new(1, 19, 1), CFrame.new(x, 10, 33), steel)
	local lamp = part(
		"ArenaLight",
		Vector3.new(10, 0.3, 2),
		CFrame.new(x, 19.5, 27),
		Color3.fromRGB(220, 235, 255),
		false
	)
	lamp.Material = Enum.Material.Neon
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Range = 42
	light.Angle = 110
	light.Brightness = 2
	light.Shadows = false
	light.Parent = lamp
end
local sign = part("PrototypeSign", Vector3.new(32, 4, 0.5), CFrame.new(0, 4, -37), navy)
label(
	sign,
	"MOVEMENT PROTOTYPE\nTwo fighters · facing · camera",
	Enum.NormalId.Back,
	Color3.fromRGB(220, 230, 240)
)
return { name = model.Name, parts = #model:GetDescendants() }
