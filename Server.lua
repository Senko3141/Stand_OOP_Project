-- Senko

local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")

local RS = game:GetService("RunService")

local Modules = Storage:WaitForChild("Modules")
local Remotes = Storage:WaitForChild("Remotes")

local DataCore = require(Modules.Core.DataCore)
local StandCore = require(Modules.Core.StandCore)

local Datastore = game:GetService("DataStoreService")
local Save = Datastore:GetDataStore("JoJo_New_World_Testing_002")

local CanSave = false

local ChatCooldowns = {};
local StandDatas = {};

Players.PlayerAdded:Connect(function(plr)

	local findSave = Save:GetAsync(plr.UserId..'-DataSave')

	if findSave then
		-- load returning data
		DataCore.Init(plr, findSave)
	elseif not findSave then
		-- default data
		DataCore.Init(plr)
	end
	
	local StandData = StandCore.Init(plr)
	StandDatas[plr.UserId] = StandData


	plr.CharacterAdded:Connect(function(char)
		-- setting stand values
		print'char added'
		StandData:Update(plr)
		StandData:CharacterAdded(plr)
	end)

	plr.Character:WaitForChild('Humanoid').Died:Connect(function()
		print'died'
		StandData:Died()
	end)

	-- TODO: Fix issue where Humanoid.Died doesn't wok after second death.
	
	plr.Chatted:Connect(function(msg)
		local msgSplit = msg:split(" ")
		
		local command = msgSplit[1]
		command = command:lower()
		
		if command == "!check" then
			if ChatCooldowns[plr.UserId..'-CheckCMD'] then 
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'CHECK SYSTEM', Message = "Please wait two seconds before you use this command again.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return 
			end
			
			local Target = msgSplit[2]
			if not Target then 
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'CHECK SYSTEM', Message = "Please specify a player name. (Ex. SenkoDevs)", Targ = plr, Icon = "rbxassetid://5689201348"})
				return 
			end
			
			if game.Players:FindFirstChild(Target) then
				local targetData = DataCore.GetData(game.Players[Target])
				local standName = targetData.StandName
				
				if standName == "" then
					standName = "No Stand"
				end
				
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'CHECK SYSTEM', Message = game.Players[Target].Name.."'s Stand is: ".. tostring(standName), Targ = game.Players[Target]})
				ChatCooldowns[plr.UserId..'-CheckCMD'] = true
				
				coroutine.wrap(function()
					wait(2)
					ChatCooldowns[plr.UserId..'-CheckCMD'] = nil
				end)()
			else
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'CHECK SYSTEM', Message = "Invalid player name!", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
		elseif command == "!trade" then
			
		elseif command == "!giveitem" then
			
		elseif command == "!pay" then
			if ChatCooldowns[plr.UserId..'-Pay'] then 
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please wait two seconds before you use this command again.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return 
			end
			
			local target = msgSplit[2]
			
			if not target then
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please specify a player name.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			target = tostring(target)
			target = game.Players:FindFirstChild(target)
			
			if not target then
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please specify a valid player name.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			if target.Name == plr.Name then
				-- cant get urself
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "You can not give yourself yen.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			local amount = msgSplit[3]
			if not amount then
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please specify a set amount.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			amount = tonumber(amount)
			if not amount then
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please specify a valid amount. (Ex. 100)", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			if amount <= 0 then
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Please specify a set amount.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			local yourData = DataCore.GetData(plr)
			local targetData = DataCore.GetData(target)
			
			local yourYen = yourData.Yen
			local targetYen = targetData.Yen
			
			if yourYen < amount then
				-- not enough
				Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "You do not have enough to give to the player.", Targ = plr, Icon = "rbxassetid://5689201348"})
				return
			end
			
			yourYen = yourYen - amount
			targetYen = targetYen + amount
			
			ChatCooldowns[plr.UserId..'-Pay'] = true
			
			-- send notif
			Remotes.Notif:FireClient(plr, 'Notif', {Title = 'YEN SYSTEM', Message = "Successfully gave ".. target.Name.." ".. amount.. " yen!", Targ = target})
			Remotes.Notif:FireClient(target, 'Notif', {Title = 'YEN SYSTEM', Message = "You have received ".. amount.. " yen from ".. plr.Name..'!', Targ = plr, Icon = plr})
			
			coroutine.wrap(function()
				wait(2)
				ChatCooldowns[plr.UserId..'-Pay'] = nil
			end)()
		end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	if CanSave == false then return end
	
	if not RS:IsStudio() then
	
		local s,e = pcall(function()
			Save:SetAsync(plr.UserId..'-DataSave', DataCore.GetData(plr))
		end)
		
		DataCore.Clear(plr)
		StandDatas[plr.UserId] = nil
		
		if e then
			warn(e)
		end
	end
end)

game:BindToClose(function()
	if CanSave == false then return end
	
	if RS:IsStudio() then
		for _,v in next, Players:GetPlayers() do
			local s,e = pcall(function()
				Save:SetAsync(v.UserId..'-DataSave', DataCore.GetData(v))
			end)
			
			DataCore.Clear(v)
			StandDatas[v.UserId] = nil
			
			if e then
				warn(e)
			end
		end
	end
	
end)

-- Events Handling

Remotes.StandEvent.OnServerInvoke = function(plr, action)
	if action == 'StandActivation' then
		local standData = StandDatas[plr.UserId]

		standData:Request(plr, 'Activate')
	end
	
end
