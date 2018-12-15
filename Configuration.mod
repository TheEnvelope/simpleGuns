--[[
	simpleGun by GetEnveloped
	December 12, 2018
	
	Configuration
--]]

-- // EDIT BELOW

local Config = {
	
	FriendlyFire = true, -- WORKS
	BulletHoles = true, -- WORKS
	Raycasts = true, -- WORKS
	GetLatestScript = false, -- DOESNT WORK When set to true, it will grab the latest script
	
	Type = "Auto", -- Semi, Auto
	ClipSize = 30,
	Clips = 3,
	ReloadSpeed = 2, -- WORKS
	Spread = .1, -- WORKS
	VerticalRecoil = .1, -- WORKS
	HorizontalRecoil = -.1, -- WORKS
	FireRate = .03, -- WORKS
	Damage = 30, -- WORKS
	
	HitSound = "rbxassetid://1489924400", -- WORKS
	PlayerHitSound = "rbxassetid://144884872", -- WORKS
	ShootSound = "rbxassetid://131070686", -- WORKS
	ReloadSound = "rbxassetid://1710833557", -- WORKS 
	HitmarkerSound = "rbxassetid://0",
	
	GunCursor = "rbxassetid://1588092778", -- WORKS
	
	Testing = true -- when true, the mark disappear after 15 seconds for spread
	
}

return Config
