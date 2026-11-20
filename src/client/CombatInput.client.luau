--!strict
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local remote = game:GetService("ReplicatedStorage")
	:WaitForChild("MMARemotes")
	:WaitForChild("CombatIntent") :: RemoteEvent
local keys = {
	LeftPunch = { Enum.KeyCode.Q, Enum.KeyCode.ButtonX },
	RightPunch = { Enum.KeyCode.E, Enum.KeyCode.ButtonY },
	LeftKick = { Enum.KeyCode.Z, Enum.KeyCode.ButtonL1 },
	RightKick = { Enum.KeyCode.C, Enum.KeyCode.ButtonR1 },
	Guard = { Enum.KeyCode.F, Enum.KeyCode.ButtonL2 },
}
local positions = {
	LeftPunch = UDim2.fromScale(0.68, 0.45),
	RightPunch = UDim2.fromScale(0.83, 0.45),
	LeftKick = UDim2.fromScale(0.63, 0.66),
	RightKick = UDim2.fromScale(0.78, 0.66),
	Guard = UDim2.fromScale(0.58, 0.86),
}
for name, bindings in keys do
	CAS:BindAction("MMA_" .. name, function(_, state)
		if UIS:GetFocusedTextBox() then
			if name == "Guard" then
				remote:FireServer("Guard", false)
			end
			return Enum.ContextActionResult.Pass
		end
		if state == Enum.UserInputState.Begin then
			remote:FireServer(name, true)
		elseif
			name == "Guard"
			and (state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel)
		then
			remote:FireServer(name, false)
		end
		return Enum.ContextActionResult.Sink
	end, true, table.unpack(bindings))
	CAS:SetTitle("MMA_" .. name, name)
	CAS:SetPosition("MMA_" .. name, positions[name])
end
UIS.WindowFocusReleased:Connect(function()
	remote:FireServer("Guard", false)
end)
-- Native movement and jump remain available. Grab, dodge and submissions are later tasks.
