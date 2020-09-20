-- Stand Module

local m = {};

local storage = game:GetService("ReplicatedStorage")
local modules = storage:WaitForChild('Modules')

local dataCore = require(modules.Core.DataCore)

local standInfo = require(script:WaitForChild("StandInfo"))

local standDatas = {};
local cooldowns = {};

m.__index = m

local function compareNames(old, new)
	if old ~= new then
		return true
	end
	return false
end

function m.Init(plr)
	local plrData = dataCore.GetData(plr)
	local standName = plrData.StandName
	
	assert(standInfo[standName], 'ERROR On LINE 9 STANDCORE MODULE. | COULD NOT GET STAND FROM STANDINFO MODULE')
	
	local data = {
		Stand_Dict = standInfo[standName],
		Owner = plr.Name,

		Active = false,
		CanActivate = true,
	};

	setmetatable(data, m)

	warn("Stand data is has been initialized for ".. plr.Name.. " | Stand name is: ".. standName)
	standDatas[plr.UserId] = data
	return data
end

function m:Update(plr) -- plr is an instance
	local plrData = dataCore.GetData(plr)
	local standName = plrData.StandName

	if compareNames(self.Stand_Dict.Name, standName) then
		-- if true then different names, else not different

		warn("New stand has been found for ".. plr.Name.. " | Old Name: ".. self.Stand_Dict.Name.. ' .. New Name: '.. standName)
		self.Stand_Dict.Name = standName
	end
end

function m:Request(plr, action)
	if action == 'Activate' then
		if self.CanActivate == false then 
			return 
		end
		
		if cooldowns[plr.UserId..'-Activate'] then 
		--	warn("Cooldown activate.")
			return 
		end

		local bool = self.Active
		
		if bool == true then
			-- stop activation

			warn(plr.Name.." has requested to DE-ACTIVATE his/her stand. | Stand Name: ".. self.Stand_Dict.Name)
			self.Active = false
			-- cooldown
			coroutine.resume(coroutine.create(function()
				cooldowns[plr.UserId..'-Activate'] = true
				wait(2)
				cooldowns[plr.UserId..'-Activate'] = nil
			end))
			
		elseif bool == false then
			-- activate

			warn(plr.Name.." has requested to ACTIVATE his/her stand. | Stand Name: ".. self.Stand_Dict.Name)
			self.Active = true
			-- cooldown

			coroutine.resume(coroutine.create(function()
				cooldowns[plr.UserId..'-Activate'] = true
				wait(2)
				cooldowns[plr.UserId..'-Activate'] = nil
			end))

		end
	end
end

function m:Died()
	warn(self.Owner.. ' has died.. resetting activity states')

	self.CanActivate = false
	self.Active = false

	-- reset everything else
end

function m:CharacterAdded(plr)
	if standDatas[plr.UserId] then
		self.CanActivate = true
		warn(self.CanActivate)
	else
		warn'nope'
	end
end

return m
