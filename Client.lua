--[[
	simpleGun by GetEnveloped
	December 12, 2018
	
	Client
--]]

-- // Variables

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Input = game:GetService("UserInputService")

local Tool = script.Parent.Parent
local Handle = Tool:WaitForChild("Handle")
local AimPart = Tool:WaitForChild("AimPart")

local GunEvent = Tool:WaitForChild("GunEvent")
local GunFunction = Tool:WaitForChild("GunFunction")

local Configuration = require(script.Parent:WaitForChild("Configuration"))

local Settings = {
	Firing = false,
	GunOut = false,
	Reloading = false,
	GUI = nil
}

-- // FUNCTIONS

function SetGui()
	if Player.PlayerGui:FindFirstChild("GunUI") then Player.PlayerGui:FindFirstChild("GunUI"):Destroy() end
	local new = script:WaitForChild("GunUI"):Clone()
	new.background.GunName.Text = Tool.Name
	new.background.AmmoText.Text = "NaN | NaN"
	new.Parent = Player.PlayerGui
	
	local Tab = GunFunction:InvokeServer()
	UpdateGui(Tab)
end

function UpdateGui(Tab)
	local UI = Player.PlayerGui:FindFirstChild("GunUI")
	if UI then
		UI.background.GunName.Text = Tool.Name
		UI.background.AmmoText.Text = Tab[1] .. " | "..Tab[2]
	end
end

function RemoveGui()
	if Player.PlayerGui:FindFirstChild("GunUI") then Player.PlayerGui:FindFirstChild("GunUI"):Destroy() end
end

-- // ACTION

Input.InputBegan:Connect(function(Input,Processed)
	if Processed == true then return end
	if not Settings.GunOut then return end
	if Settings.Reloading then return end
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Settings.Firing == false then
			Settings.Firing = true
			
			if Configuration.Type == "Auto" then
				spawn(function()
					while Settings.Firing == true do
						local Camera = workspace.CurrentCamera
						GunEvent:FireServer("Fire", Mouse.Hit)
						local Tab = GunFunction:InvokeServer()
						UpdateGui(Tab)
						if Tab[1] > 0 then
							Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(Configuration.VerticalRecoil),math.rad(Configuration.HorizontalRecoil),0)
							wait(Configuration.FireRate)
						end
					end
				end)
			elseif Configuration.Type == "Semi" then
				spawn(function()
					local Camera = workspace.CurrentCamera
					GunEvent:FireServer("Fire", Mouse.Hit)
					local Tab = GunFunction:InvokeServer()
					UpdateGui(Tab)
					Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(Configuration.VerticalRecoil),math.rad(Configuration.HorizontalRecoil),0)
					if Tab[1] > 0 then
						Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(Configuration.VerticalRecoil),math.rad(Configuration.HorizontalRecoil),0)
						wait(Configuration.FireRate)
					end
					Settings.Firing = false
				end)
			end
		end
		
	elseif Input.KeyCode == Enum.KeyCode.R then
		Settings.Firing = false
		Settings.Reloading = true
		GunEvent:FireServer("Reload")
		local Tab = GunFunction:InvokeServer()
		UpdateGui(Tab)
		wait(Configuration.ReloadSpeed)
		Settings.Reloading = false
	end
end)

Input.InputEnded:Connect(function(Input,Processed)
	if Processed then return end
	if not Settings.GunOut then return end
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Configuration.Type == "Auto" then
			if Settings.Firing == true then
				Settings.Firing = false
			end
		end
	end
end)


-- // TOOL ACTION

Tool.Equipped:Connect(function()
	Settings.GunOut = true
	Mouse.Icon = Configuration.GunCursor
	SetGui()
end)

Tool.Unequipped:Connect(function()
	Settings.GunOut = false
	Settings.Firing = false
	Mouse.Icon = ""
	RemoveGui()
end)

-- // GUN WELD
