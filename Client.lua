-- Stand Client

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")

local Remotes = Storage:WaitForChild("Remotes")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Q then
		-- fire server

		Remotes.StandEvent:InvokeServer('StandActivation')
		
	end
	
end)
