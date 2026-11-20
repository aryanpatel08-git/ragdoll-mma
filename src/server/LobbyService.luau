--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
type Cage = {
	Model: Model,
	Queue: { Player },
	Fighters: { Player },
	Connections: { RBXScriptConnection },
	Token: number,
	Active: boolean,
}
local cages: { Cage } = {}
local membership: { [Player]: Cage } = {}
local cooldowns: { [Player]: number } = {}
local gym: Model
local remote: RemoteEvent
local started = false
local LobbyService = {}
local function notify(p: Player, message: string)
	if p.Parent then
		remote:FireClient(p, "Notice", message)
	end
end
local function alive(p: Player): Humanoid?
	local c = p.Character
	local h = if c then c:FindFirstChildOfClass("Humanoid") else nil
	return if h and h.Health > 0 then h else nil
end
local function teleport(p: Player, cf: CFrame)
	if p.Character and alive(p) then
		p.Character:PivotTo(cf)
		local root = p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end
local function returnLobby(p: Player)
	p:SetAttribute("MMAOpponentUserId", 0)
	p:SetAttribute("MMACageId", 0)
	p.RespawnLocation = gym.LobbySpawn :: SpawnLocation
	teleport(p, (gym.LobbySpawn :: BasePart).CFrame * CFrame.new(0, 4, 0))
end
local function update(c: Cage)
	local status = if c.Active then "Fighting" elseif #c.Queue > 0 then "Waiting" else "Open"
	c.Model:SetAttribute("State", status)
	c.Model:SetAttribute("QueueCount", #c.Queue)
	local color = if c.Active
		then Color3.fromRGB(222, 73, 83)
		elseif #c.Queue > 0 then Color3.fromRGB(240, 183, 77)
		else Color3.fromRGB(89, 209, 151)
	local light = c.Model.StatusLight :: BasePart
	light.Color = color
	local door = c.Model.Door :: BasePart
	door.CanCollide = c.Active
	door.Transparency = if c.Active then 0.6 else 1
	for _, v in c.Model.StatusBoard:GetDescendants() do
		if v:IsA("TextLabel") then
			v.Text = "CAGE "
				.. tostring(c.Model:GetAttribute("CageId"))
				.. " · "
				.. string.upper(status)
				.. (if #c.Queue > 0 then "\n" .. #c.Queue .. " queued" else "")
		end
	end
end
local function finish(c: Cage, reason: string)
	if not c.Active then
		return
	end
	c.Active = false
	c.Token += 1
	for _, connection in c.Connections do
		connection:Disconnect()
	end
	table.clear(c.Connections)
	local participants = c.Fighters
	c.Fighters = {}
	for _, p in participants do
		membership[p] = nil
		returnLobby(p)
		notify(p, reason)
	end
	update(c)
end
local function tryStart(c: Cage)
	if c.Active or #c.Queue < 2 then
		return
	end
	local a = table.remove(c.Queue, 1)
	local b = table.remove(c.Queue, 1)
	if not alive(a) or not alive(b) then
		for _, p in { a, b } do
			membership[p] = nil
			notify(p, "Rejoin a cage after respawning.")
		end
		update(c)
		return
	end
	c.Active = true
	c.Fighters = { a, b }
	c.Token += 1
	for index, p in c.Fighters do
		local other = if index == 1 then b else a
		local char = p.Character :: Model
		local hum = alive(p) :: Humanoid
		hum.Health = hum.MaxHealth
		for name in { Body = 100, Stamina = 100, Guard = 100 } do
			char:SetAttribute(name, 100)
		end
		p:SetAttribute("MMACageId", c.Model:GetAttribute("CageId"))
		p:SetAttribute("MMAOpponentUserId", other.UserId)
		local marker = c.Model:FindFirstChild(
			if index == 1 then "RedFighterSpawn" else "BlueFighterSpawn"
		) :: BasePart
		teleport(p, marker.CFrame)
		table.insert(
			c.Connections,
			hum.Died:Connect(function()
				finish(c, other.DisplayName .. " wins this practice bout. Rejoin to rematch.")
			end)
		)
		notify(p, "Practice bout versus " .. other.DisplayName)
	end
	update(c)
end
local function leave(p: Player)
	local c = membership[p]
	if not c then
		return
	end
	if c.Active and table.find(c.Fighters, p) then
		finish(c, p.DisplayName .. " left the cage. Practice bout ended.")
	else
		local index = table.find(c.Queue, p)
		if index then
			table.remove(c.Queue, index)
		end
		membership[p] = nil
		returnLobby(p)
		update(c)
	end
end
local function join(p: Player, c: Cage)
	if membership[p] then
		notify(p, "Leave your current queue or fight first.")
		return
	end
	if not alive(p) then
		return
	end
	if #c.Queue >= 4 then
		notify(p, "Queue is full. Try another cage.")
		return
	end
	membership[p] = c
	table.insert(c.Queue, p)
	notify(p, "Queued for " .. c.Model.Name .. ". Waiting for a second fighter.")
	update(c)
	tryStart(c)
end
function LobbyService.Start()
	assert(not started, "Lobby already started")
	started = true
	gym = workspace:WaitForChild("MMAGym") :: Model
	remote = Instance.new("RemoteEvent")
	remote.Name = "MMALobbyIntent"
	remote.Parent = ReplicatedStorage
	for _, model in gym.Cages:GetChildren() do
		if not model:IsA("Model") then
			continue
		end
		local c: Cage =
			{ Model = model, Queue = {}, Fighters = {}, Connections = {}, Token = 0, Active = false }
		table.insert(cages, c)
		update(c)
		local prompt = model.Entry:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
		prompt.Triggered:Connect(function(p)
			local root = if p.Character
				then p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				else nil
			if root and (root.Position - (model.Entry :: BasePart).Position).Magnitude <= 13 then
				join(p, c)
			end
		end)
	end
	table.sort(cages, function(a, b)
		return (a.Model:GetAttribute("CageId") :: number)
			< b.Model:GetAttribute("CageId") :: number
	end)
	remote.OnServerEvent:Connect(function(p, action: unknown, value: unknown)
		if typeof(action) ~= "string" then
			return
		end
		local now = os.clock()
		if now - (cooldowns[p] or 0) < 0.4 then
			return
		end
		cooldowns[p] = now
		if action == "Leave" then
			leave(p)
		elseif action == "QuickPlay" then
			local chosen: Cage? = nil
			for _, c in cages do
				if not c.Active and #c.Queue == 1 then
					chosen = c
					break
				end
			end
			if not chosen then
				for _, c in cages do
					if not c.Active and #c.Queue == 0 then
						chosen = c
						break
					end
				end
			end
			if chosen then
				join(p, chosen)
			else
				notify(p, "All cages are busy. Queue at a cage door.")
			end
		elseif
			action == "Challenge"
			and typeof(value) == "number"
			and value == math.floor(value)
		then
			local other = Players:GetPlayerByUserId(value)
			if not other or other == p or membership[p] or membership[other] then
				return
			end
			-- Invitation only: the recipient must choose Quick Play or join a cage themselves.
			notify(other, p.DisplayName .. " challenges you. Join the same cage to accept.")
		end
	end)
	local function added(p: Player)
		p:SetAttribute("MMAOpponentUserId", 0)
		p:SetAttribute("MMACageId", 0)
		p.RespawnLocation = gym.LobbySpawn :: SpawnLocation
		p.CharacterRemoving:Connect(function()
			leave(p)
		end)
		p.CharacterAdded:Connect(function(char)
			local root = char:WaitForChild("HumanoidRootPart", 10)
			if root and p.Character == char then
				returnLobby(p)
			end
		end)
		if p.Character then
			returnLobby(p)
		end
	end
	Players.PlayerAdded:Connect(added)
	Players.PlayerRemoving:Connect(function(p)
		leave(p)
		cooldowns[p] = nil
	end)
	for _, p in Players:GetPlayers() do
		added(p)
	end
	-- Queued players are admitted when a practice bout frees its cage.
	task.spawn(function()
		while gym.Parent do
			task.wait(1)
			for _, c in cages do
				if not c.Active then
					tryStart(c)
				end
			end
		end
	end)
	for _, bag in gym.Training:GetChildren() do
		local prompt = bag:FindFirstChild("PracticePrompt")
		if not prompt or not bag:IsA("BasePart") then
			continue
		end
		local base = bag.CFrame(prompt :: ProximityPrompt).Triggered:Connect(function(p)
			local char = p.Character
			local root = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
			if
				not root
				or membership[p]
				or not alive(p)
				or (root.Position - bag.Position).Magnitude > 12
			then
				return
			end
			local now = os.clock()
			if now - (cooldowns[p] or 0) < 0.6 then
				return
			end
			cooldowns[p] = now
			local stamina = char:GetAttribute("Stamina")
			if typeof(stamina) ~= "number" or stamina < 7 then
				return
			end
			char:SetAttribute("Stamina", stamina - 7)
			local tween = TweenService:Create(
				bag,
				TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{ CFrame = base * CFrame.Angles(0, 0, 0.12) }
			)
			tween:Play()
			notify(p, "Practice strike: 8 health / 4 body damage · 7 stamina")
		end)
	end
	for _, kind in { "SHOP", "CUSTOMIZE" } do
		local counter = gym:FindFirstChild(kind .. "Counter")
		local prompt = counter and counter:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(p)
				local root = if p.Character
					then p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
					else nil
				if root and (root.Position - (counter :: BasePart).Position).Magnitude <= 13 then
					remote:FireClient(p, "Panel", kind)
				end
			end)
		end
	end
end
return LobbyService
