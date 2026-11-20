--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FoundationConfig")
)
local player = Players.LocalPlayer
local character: Model? = nil
local humanoid: Humanoid? = nil
local root: BasePart? = nil
local alignment: AlignOrientation? = nil
local attachment: Attachment? = nil
local lastCamera: CFrame? = nil
local function bind(model: Model)
	if alignment then
		alignment:Destroy()
	end
	if attachment then
		attachment:Destroy()
	end
	character = model
	humanoid = model:WaitForChild("Humanoid") :: Humanoid
	root = model:WaitForChild("HumanoidRootPart") :: BasePart
	attachment = Instance.new("Attachment")
	attachment.Name = "MMAFacingAttachment"
	attachment.Parent = root
	alignment = Instance.new("AlignOrientation")
	alignment.Name = "MMAFacing"
	alignment.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignment.Attachment0 = attachment
	alignment.MaxTorque = 40000
	alignment.Responsiveness = 22
	alignment.Enabled = false
	alignment.Parent = root
	lastCamera = nil
end
player.CharacterAdded:Connect(bind)
if player.Character then
	task.spawn(bind, player.Character)
end
RunService:BindToRenderStep("MMAFightCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local cam = workspace.CurrentCamera
	local hrp = root
	local hum = humanoid
	if not cam or not hrp or not hum or not hrp.Parent then
		return
	end
	local id = player:GetAttribute("MMAOpponentUserId")
	local opponent = if typeof(id) == "number" and id ~= 0
		then Players:GetPlayerByUserId(id)
		else nil
	local opponentRoot = if opponent and opponent.Character
		then opponent.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		else nil
	if not opponentRoot or hum.Health <= 0 then
		if alignment then
			alignment.Enabled = false
		end
		hum.AutoRotate = true
		cam.CameraType = Enum.CameraType.Custom
		cam.CameraSubject = hum
		lastCamera = nil
		return
	end
	local delta = opponentRoot.Position - hrp.Position
	local horizontal = Vector3.new(delta.X, 0, delta.Z)
	if alignment and horizontal.Magnitude > 0.05 then
		hum.AutoRotate = false
		alignment.CFrame = CFrame.lookAt(Vector3.zero, horizontal.Unit)
		alignment.Enabled = true
	end
	local midpoint = (hrp.Position + opponentRoot.Position) * 0.5
	local distance = math.clamp(
		Config.CameraDistance + horizontal.Magnitude * 0.55,
		Config.MinimumCameraDistance,
		Config.MaximumCameraDistance
	)
	-- Stable world-side camera avoids flipping as fighters circle.
	local desired = CFrame.lookAt(
		midpoint + Vector3.new(0, Config.CameraHeight, distance),
		midpoint + Vector3.new(0, 2, 0)
	)
	lastCamera = if lastCamera then lastCamera:Lerp(desired, 1 - math.exp(-8 * dt)) else desired
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = lastCamera :: CFrame
end)
