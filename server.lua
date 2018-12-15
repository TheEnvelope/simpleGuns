--[[
	simpleGun by GetEnveloped
	December 12, 2018
	
	Server
--]]

-- // Variables

local Tool = script.Parent.Parent
local Handle = Tool:WaitForChild("Handle")
local AimPart = Tool:WaitForChild("AimPart")
local Main = Tool:WaitForChild("Main")

local GunEvent = Tool:WaitForChild("GunEvent")
local GunFunction = Tool:WaitForChild("GunFunction")

local Configuration = require(script.Parent:WaitForChild("Configuration"))

local Settings = {
	Debounce = false,
	Shooting = false,
	CurrentAmmo = Configuration.ClipSize,
	CurrentClip = Configuration.Clips
}

-- // FUNCTIONS

function GunFunction.OnServerInvoke (Player)
	return {Settings.CurrentAmmo,Settings.CurrentClip}
end

function newProjectile(Player,MouseHit)
	spawn(function()
		
		local spreadRandom = math.random(1,3)
		if spreadRandom == 1 then
			MouseHit = MouseHit + Vector3.new(Configuration.Spread,0,0)
		elseif spreadRandom == 2 then
			MouseHit = MouseHit + Vector3.new(0,Configuration.Spread,0)
		elseif spreadRandom == 3 then
			MouseHit = MouseHit + Vector3.new(0,0,Configuration.Spread)
		end
		
		local ray = Ray.new(Main.CFrame.p, (MouseHit.p - Main.CFrame.p).unit * 300)
		local part, position = workspace:FindPartOnRay(ray, game.Players:GetPlayerFromCharacter(Tool.Parent).Character, false, true)
		
		if Configuration.Raycasts then
			local beam = Instance.new("Part")
			beam.BrickColor = BrickColor.new("Bright yellow")
			beam.FormFactor = "Custom"
			beam.Material = "Neon"
			beam.Transparency = 0.75
			beam.Anchored = true
			beam.Locked = true
			beam.CanCollide = false
			beam.Parent = workspace
			
			local distance = (Main.CFrame.p - position).magnitude
			beam.Size = Vector3.new(0.1, 0.1, distance - 15)
			beam.CFrame = CFrame.new(Main.CFrame.p, position) * CFrame.new(0, 0, -distance / 2)
			game:GetService("Debris"):AddItem(beam, .03)
		end
		
		if Configuration.BulletHoles then
			local mark = Instance.new("Part")
			mark.BrickColor = BrickColor.new("Really black")
			mark.Anchored = true
			mark.Locked = true
			mark.CanCollide = false
			mark.Size = Vector3.new(.1,.1,.1)
			mark.Parent = workspace
			mark.Position = position
			
			local timeOut = 1
			if Configuration.Testing == true then
				timeOut = 10
			end
			
			game:GetService("Debris"):AddItem(mark,timeOut)
		end
		
		local shootAudio = Instance.new("Sound")
		shootAudio.Parent = Main
		shootAudio.SoundId = Configuration.ShootSound
		shootAudio.PlayOnRemove = true
		shootAudio:Destroy()
		
		Settings.CurrentAmmo = Settings.CurrentAmmo - 1
		
		if part then
			local humanoid = part.Parent:FindFirstChild("Humanoid")
			
			if not humanoid then
				humanoid = part.Parent.Parent:FindFirstChild("Humanoid")
			end
			
			if humanoid then
				local targetPlayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)
				local canKill = true
				if targetPlayer and targetPlayer.TeamColor == Player.TeamColor and Configuration.FriendlyFire == false then
					canKill = false
				end
				if canKill then
					humanoid:TakeDamage(Configuration.Damage)
					local hitAudio = Instance.new("Sound")
					hitAudio.Parent = part
					hitAudio.SoundId = Configuration.PlayerHitSound
					hitAudio.PlayOnRemove = true
					hitAudio:Destroy()
				else
					local hitAudio = Instance.new("Sound")
					hitAudio.Parent = part
					hitAudio.SoundId = Configuration.HitSound
					hitAudio.PlayOnRemove = true
					hitAudio:Destroy()
				end
			else
				local hitAudio = Instance.new("Sound")
				hitAudio.Parent = part
				hitAudio.SoundId = Configuration.HitSound
				hitAudio.PlayOnRemove = true
				hitAudio:Destroy()
			end
		end
	end)
end

function reload(Player)
	spawn(function()
		local reloadAudio = Instance.new("Sound")
		reloadAudio.Parent = Handle
		reloadAudio.SoundId = Configuration.ReloadSound
		reloadAudio.PlayOnRemove = true
		reloadAudio:Destroy()
	end)
end

-- // GUNEVENT

GunEvent.OnServerEvent:Connect(function(Player,Action,MouseHit)
	if game.Players:GetPlayerFromCharacter(Tool.Parent).UserId ~= Player.UserId then return end
	if Settings.Debounce then return end
	
	if Action == "Fire" then
		Settings.Debounce = true
		if Settings.CurrentAmmo > 0 then
			newProjectile(Player,MouseHit)
			wait(Configuration.FireRate)
		end
		Settings.Debounce = false
	elseif Action == "Reload" then
		if Settings.CurrentClip > 0 then
			Settings.CurrentAmmo = Configuration.ClipSize
			Settings.CurrentClip = Settings.CurrentClip - 1
			Settings.Debounce = true
			Settings.Shooting = false
			reload(Player)
			Settings.Debounce = false
		end
	end
end)


-- // qPerfectionWeld

local NEVER_BREAK_JOINTS = false -- If you set this to true it will never break joints (this can create some welding issues, but can save stuff like hinges).

local function CallOnChildren(Instance, FunctionToCall)
	-- Calls a function on each of the children of a certain object, using recursion.  

	FunctionToCall(Instance)

	for _, Child in next, Instance:GetChildren() do
		CallOnChildren(Child, FunctionToCall)
	end
end

local function GetNearestParent(Instance, ClassName)
	-- Returns the nearest parent of a certain class, or returns nil

	local Ancestor = Instance
	repeat
		Ancestor = Ancestor.Parent
		if Ancestor == nil then
			return nil
		end
	until Ancestor:IsA(ClassName)

	return Ancestor
end

local function GetBricks(StartInstance)
	local List = {}

	-- if StartInstance:IsA("BasePart") then
	-- 	List[#List+1] = StartInstance
	-- end

	CallOnChildren(StartInstance, function(Item)
		if Item:IsA("BasePart") then
			List[#List+1] = Item;
		end
	end)

	return List
end

local function Modify(Instance, Values)
	-- Modifies an Instance by using a table.  

	assert(type(Values) == "table", "Values is not a table");

	for Index, Value in next, Values do
		if type(Index) == "number" then
			Value.Parent = Instance
		else
			Instance[Index] = Value
		end
	end
	return Instance
end

local function Make(ClassType, Properties)
	-- Using a syntax hack to create a nice way to Make new items.  

	return Modify(Instance.new(ClassType), Properties)
end

local Surfaces = {"TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface"}
local HingSurfaces = {"Hinge", "Motor", "SteppingMotor"}

local function HasWheelJoint(Part)
	for _, SurfaceName in pairs(Surfaces) do
		for _, HingSurfaceName in pairs(HingSurfaces) do
			if Part[SurfaceName].Name == HingSurfaceName then
				return true
			end
		end
	end
	
	return false
end

local function ShouldBreakJoints(Part)
	--- We do not want to break joints of wheels/hinges. This takes the utmost care to not do this. There are
	--  definitely some edge cases. 

	if NEVER_BREAK_JOINTS then
		return false
	end
	
	if HasWheelJoint(Part) then
		return false
	end
	
	local Connected = Part:GetConnectedParts()
	
	if #Connected == 1 then
		return false
	end
	
	for _, Item in pairs(Connected) do
		if HasWheelJoint(Item) then
			return false
		elseif not Item:IsDescendantOf(Tool) then
			return false
		end
	end
	
	return true
end

local function WeldTogether(Part0, Part1, JointType, WeldParent)
	--- Weld's 2 parts together
	-- @param Part0 The first part
	-- @param Part1 The second part (Dependent part most of the time).
	-- @param [JointType] The type of joint. Defaults to weld.
	-- @param [WeldParent] Parent of the weld, Defaults to Part0 (so GC is better).
	-- @return The weld created.

	JointType = JointType or "Weld"
	local RelativeValue = Part1:FindFirstChild("qRelativeCFrameWeldValue")
	
	local NewWeld = Part1:FindFirstChild("qCFrameWeldThingy") or Instance.new(JointType)
	Modify(NewWeld, {
		Name = "qCFrameWeldThingy";
		Part0  = Part0;
		Part1  = Part1;
		C0     = CFrame.new();--Part0.CFrame:inverse();
		C1     = RelativeValue and RelativeValue.Value or Part1.CFrame:toObjectSpace(Part0.CFrame); --Part1.CFrame:inverse() * Part0.CFrame;-- Part1.CFrame:inverse();
		Parent = Part1;
	})

	if not RelativeValue then
		RelativeValue = Make("CFrameValue", {
			Parent     = Part1;
			Name       = "qRelativeCFrameWeldValue";
			Archivable = true;
			Value      = NewWeld.C1;
		})
	end

	return NewWeld
end

local function WeldParts(Parts, MainPart, JointType, DoNotUnanchor)
	-- @param Parts The Parts to weld. Should be anchored to prevent really horrible results.
	-- @param MainPart The part to weld the model to (can be in the model).
	-- @param [JointType] The type of joint. Defaults to weld. 
	-- @parm DoNotUnanchor Boolean, if true, will not unachor the model after cmopletion.
	
	for _, Part in pairs(Parts) do
		if ShouldBreakJoints(Part) then
			Part:BreakJoints()
		end
	end
	
	for _, Part in pairs(Parts) do
		if Part ~= MainPart then
			WeldTogether(MainPart, Part, JointType, MainPart)
		end
	end

	if not DoNotUnanchor then
		for _, Part in pairs(Parts) do
			Part.Anchored = false
		end
		MainPart.Anchored = false
	end
end

local function PerfectionWeld()	
	local Tool = GetNearestParent(script, "Tool")

	local Parts = GetBricks(Tool)
	local PrimaryPart = Tool and Tool:FindFirstChild("Handle") and Tool.Handle:IsA("BasePart") and Tool.Handle or Tool:IsA("Model") and Tool.PrimaryPart or Parts[1]

	if PrimaryPart then
		WeldParts(Parts, PrimaryPart, "Weld", false)
	else
		warn("qWeld - Unable to weld part")
	end
	
	return Tool
end

local Tool = PerfectionWeld()


if Tool and script.ClassName == "Script" then
	--- Don't bother with local scripts

	Tool.AncestryChanged:connect(function()
		PerfectionWeld()
	end)
end
