--!strict
-- Server owns targets, resources and hits. No client damage or target payloads.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.CombatConfig)
type State = {
	Character: Model,
	Humanoid: Humanoid,
	NextAttack: number,
	LastUse: number,
	Guarding: boolean,
	StunnedUntil: number,
	Tokens: number,
	LastToken: number,
	Generation: number,
}
local states: { [Player]: State } = {}
local CombatService = {}
local started = false
local function amount(character: Model, key: string): number
	local value = character:GetAttribute(key)
	return if typeof(value) == "number" then value else 0
end
local function set(character: Model, key: string, value: number, maximum: number)
	character:SetAttribute(key, math.clamp(value, 0, maximum))
end
local function alive(player: Player): State?
	local s = states[player]
	if
		not s
		or player.Character ~= s.Character
		or not s.Character.Parent
		or s.Humanoid.Health <= 0
	then
		return nil
	end
	return s
end
local function setup(player: Player, character: Model)
	local hum = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not hum or player.Character ~= character then
		return
	end
	local now = os.clock()
	local s: State = {
		Character = character,
		Humanoid = hum,
		NextAttack = 0,
		LastUse = 0,
		Guarding = false,
		StunnedUntil = 0,
		Tokens = Config.InputBurst,
		LastToken = now,
		Generation = 0,
	}
	states[player] = s
	hum.MaxHealth = Config.MaxHealth
	hum.Health = Config.MaxHealth
	for name, value in
		{
			Health = Config.MaxHealth,
			Body = Config.MaxBody,
			Stamina = Config.MaxStamina,
			Guard = Config.MaxGuard,
		}
	do
		character:SetAttribute(name, value)
	end
	character:SetAttribute("Guarding", false)
	hum.HealthChanged:Connect(function(health)
		if states[player] == s then
			character:SetAttribute("Health", health)
		end
	end)
end
local function opponent(player: Player): Player?
	local id = player:GetAttribute("MMAOpponentUserId")
	return if typeof(id) == "number" and id ~= 0 then Players:GetPlayerByUserId(id) else nil
end
local function hit(
	player: Player,
	s: State,
	move: {
		Cost: number,
		Cooldown: number,
		Windup: number,
		Range: number,
		Health: number,
		Body: number,
		Head: boolean,
	},
	generation: number
)
	if
		states[player] ~= s
		or s.Generation ~= generation
		or not alive(player)
		or s.StunnedUntil > os.clock()
	then
		return
	end
	local other = opponent(player)
	local target = if other then alive(other) else nil
	if not target or opponent(other :: Player) ~= player then
		return
	end
	local root = s.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or not targetRoot then
		return
	end
	local delta = targetRoot.Position - root.Position
	if
		delta.Magnitude > move.Range + 1
		or delta.Magnitude < 0.01
		or root.CFrame.LookVector:Dot(delta.Unit) < 0.35
	then
		return
	end
	-- Opponents must belong to the same active cage; queries remain isolated per bout.
	local cageId = player:GetAttribute("MMACageId")
	if typeof(cageId) ~= "number" or cageId <= 0 or other:GetAttribute("MMACageId") ~= cageId then
		return
	end
	local gym = workspace:FindFirstChild("MMAGym")
	local cages = gym and gym:FindFirstChild("Cages")
	local cage = cages and cages:FindFirstChild("Cage" .. tostring(cageId))
	local floor = if cage then cage:FindFirstChild("FightMat") :: BasePart? else nil
	if not floor or cage:GetAttribute("State") ~= "Fighting" then
		return
	end
	for _, r in { root, targetRoot } do
		local relative = floor.CFrame:PointToObjectSpace(r.Position)
		if
			math.abs(relative.X) > 29
			or math.abs(relative.Z) > 29
			or relative.Y < 0
			or relative.Y > 18
		then
			return
		end
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { target.Character }
	local box = root.CFrame * CFrame.new(0, if move.Head then 1.5 else 0, -move.Range * 0.5)
	local touched = workspace:GetPartBoundsInBox(box, Vector3.new(4, 3, move.Range), params)
	local found = false
	for _, p in touched do
		if p.Name ~= "HumanoidRootPart" then
			found = true
			break
		end
	end
	if not found then
		return
	end
	local blocked = target.Guarding and targetRoot.CFrame.LookVector:Dot(-delta.Unit) > 0.2
	local healthDamage = move.Health
	local bodyDamage = move.Body
	if blocked then
		healthDamage *= Config.GuardHealthMultiplier
		bodyDamage *= Config.GuardBodyMultiplier
		set(
			target.Character,
			"Guard",
			amount(target.Character, "Guard") - Config.GuardHitCost,
			Config.MaxGuard
		)
		if amount(target.Character, "Guard") <= 0 then
			target.Guarding = false
			target.Character:SetAttribute("Guarding", false)
			target.StunnedUntil = os.clock() + Config.GuardBreakStun
		end
	end
	set(target.Character, "Body", amount(target.Character, "Body") - bodyDamage, Config.MaxBody)
	target.Humanoid:TakeDamage(healthDamage)
end
local function request(player: Player, action: unknown, pressed: unknown)
	local s = alive(player)
	if not s or typeof(action) ~= "string" or #action > 20 or typeof(pressed) ~= "boolean" then
		return
	end
	local now = os.clock()
	s.Tokens = math.min(Config.InputBurst, s.Tokens + (now - s.LastToken) * Config.InputRate)
	s.LastToken = now
	if s.Tokens < 1 then
		return
	end
	s.Tokens -= 1
	if action == "Guard" then
		if not pressed then
			s.Guarding = false
			s.Character:SetAttribute("Guarding", false)
			return
		end
		if
			s.StunnedUntil > now
			or s.NextAttack > now
			or amount(s.Character, "Guard") <= 0
			or not opponent(player)
		then
			return
		end
		s.Guarding = true
		s.Character:SetAttribute("Guarding", true)
		return
	end
	if not pressed or s.Guarding or s.StunnedUntil > now or s.NextAttack > now then
		return
	end
	local move = Config.Moves[action]
	if not move or not opponent(player) or amount(s.Character, "Stamina") < move.Cost then
		return
	end
	set(s.Character, "Stamina", amount(s.Character, "Stamina") - move.Cost, Config.MaxStamina)
	s.NextAttack = now + move.Cooldown
	s.LastUse = now
	s.Generation += 1
	task.delay(move.Windup, hit, player, s, move, s.Generation)
end
function CombatService.Start()
	assert(not started, "CombatService already started")
	started = true
	local folder = Instance.new("Folder")
	folder.Name = "MMARemotes"
	folder.Parent = ReplicatedStorage
	local remote = Instance.new("RemoteEvent")
	remote.Name = "CombatIntent"
	remote.Parent = folder
	remote.OnServerEvent:Connect(request)
	local function joined(player: Player)
		player.CharacterAdded:Connect(function(character)
			setup(player, character)
		end)
		if player.Character then
			task.spawn(setup, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(joined)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	for _, p in Players:GetPlayers() do
		joined(p)
	end
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then
			return
		end
		local step = math.min(elapsed, 0.25)
		elapsed = 0
		local now = os.clock()
		for player, s in states do
			if not alive(player) then
				continue
			end
			if not opponent(player) then
				s.Guarding = false
				s.Character:SetAttribute("Guarding", false)
			end
			if s.Guarding then
				set(
					s.Character,
					"Guard",
					amount(s.Character, "Guard") - Config.GuardDrain * step,
					Config.MaxGuard
				)
				if amount(s.Character, "Guard") <= 0 then
					s.Guarding = false
					s.Character:SetAttribute("Guarding", false)
					s.StunnedUntil = now + Config.GuardBreakStun
				end
			else
				set(
					s.Character,
					"Guard",
					amount(s.Character, "Guard") + Config.GuardRegen * step,
					Config.MaxGuard
				)
			end
			if not s.Guarding and now - s.LastUse > Config.RegenDelay then
				local factor = 0.25 + 0.75 * amount(s.Character, "Body") / Config.MaxBody
				set(
					s.Character,
					"Stamina",
					amount(s.Character, "Stamina") + Config.StaminaRegen * factor * step,
					Config.MaxStamina
				)
			end
		end
	end)
end
return CombatService
