local replicatedstroage = game:GetService("ReplicatedStorage") -- ReplicatedStorage
local runService = game:GetService("RunService") -- RunService
local tweenservice = game:GetService("TweenService") -- TweenService Using for animate
local uis = game:GetService("UserInputService") -- UserInputService


local camera = workspace.Camera -- Camera
local player = game.Players.LocalPlayer -- Player

local Pillows = replicatedstroage:WaitForChild("Pillows") -- replicatedstroage.Pillows
local Boxs = workspace:WaitForChild("Boxs") -- workspace.Boxs
local module3D = require(replicatedstroage:WaitForChild("Module3D")) --replicatedstroage.Module3D


local maxDisplayDistance = 15 -- Display Distance for billboards
local canHatch = false -- If true then player can hatch box
local isHatching = false -- Is Hatching Now 
local hatchOneConnection = nil -- Connection

wait(.5) -- Wait half seconds

local function animateBillboard(billboard, openOrClose) -- bilboard: Instance, openOrClose: Bool

	if openOrClose == true then -- open 
		tweenservice:Create(billboard,TweenInfo.new(.1),{Size = UDim2.new(7,0,8,0)}):Play() -- Play Tween (Animation)
	else
		tweenservice:Create(billboard,TweenInfo.new(.1),{Size = UDim2.new(0,0,0,0)}):Play() -- Stop Tween 
		wait(.1) 
		billboard.Enabled = false -- Close billboard (Player Can't see)
		
	end
	wait(.5)  -- Wait half seconds
end
	
	for i, v in pairs(Boxs:GetChildren()) do -- get boxs childrens
	local boxPillows = Pillows:FindFirstChild(v.Name) -- find box in pillows folder
	
	if boxPillows ~= nil then -- If box's found then
		local billboardTemplate = script.Template:Clone() -- clone template
		local Container = billboardTemplate:WaitForChild("Container") -- billboardTemplate.Container
		local mainFrame = Container:WaitForChild("MainFrame") --Container.MainFrame
		local template = mainFrame:WaitForChild("Template") --button template
		local display = template:WaitForChild("Display") -- template.Display
		
		
		billboardTemplate.Parent = script.Parent.Parent.BoxBillboards -- billboardTemplate Parent => BoxBillboard
		billboardTemplate.Name = v.Name -- Box's name
		billboardTemplate.Adornee = v.Box -- Display on Box
		billboardTemplate.Enabled = true -- Player Can see
		
		local pillows = {} -- Pillows
		
		for x, pillow in pairs(boxPillows:GetChildren()) do -- Get pillows in box
			table.insert(pillows,pillow.Rarity.Value) -- Inserts Pillow Rarity
		end
		
		table.sort(pillows) -- Sort Pillows by Rarities
		for i = 1, math.floor(#pillows/2) do -- Sort Pillows by Rarities
			local j = #pillows - i + 1
			pillows[i], pillows[j] = pillows[j], pillows[i]
		end
		
		for _, rarity in pairs(pillows) do --  Get rarity in Each pillow
			
		
		for _, pillow in pairs(boxPillows:GetChildren()) do
			if pillow.Rarity.Value == rarity then
					local rarity = pillow.Rarity.Value

					local clonedTemplate = template:Clone()

					clonedTemplate.Name = pillow.Name
					clonedTemplate.Rarity.Text = tostring(pillow.Rarity.Value).."%"
					clonedTemplate.Visible = true
					clonedTemplate.Parent = mainFrame

					local pillowModel = module3D:Attach3D(clonedTemplate.Display,pillow:Clone())
					pillowModel:SetDepthMultiplier(1.2)
					pillowModel.Camera.FieldOfView = 5
					pillowModel.Visible = true

					runService.RenderStepped:Connect(function() 
						pillowModel:SetCFrame(CFrame.Angles(0,0,0) * CFrame.Angles(math.rad(-10),0,0)) -- rotation module3D
					end)
					break
				else
					continue
				end
				end
				
				end	
		
		 runService.RenderStepped:Connect(function()
			if player:DistanceFromCharacter(v.Box.PrimaryPart.Position) < maxDisplayDistance then
				
				billboardTemplate.Enabled = true
				animateBillboard(billboardTemplate,true)
			else
				animateBillboard(billboardTemplate,false)
				
			end
		end)
	end
end
_G.hatchOne = function(pillowName,box)

	print(pillowName)
	local pillow = Pillows[box.Name]:FindFirstChild(pillowName):Clone()

	
	isHatching = true
	local boxModel = box:FindFirstChild("Box"):Clone()
	for i,v in pairs(boxModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			v.CanCollide = false
		end
		
	end
	hatchOneConnection = runService.RenderStepped:Connect(function()
		local cf = CFrame.new(0,0,-boxModel.PrimaryPart.Size.Z * 2) * CFrame.Angles(0,0,math.sin(time() / 2 * 20/2.1))
		boxModel:SetPrimaryPartCFrame(camera.CFrame * cf)
	end)
	boxModel.Parent = camera
	wait(3)
	for i,v in pairs(boxModel:GetChildren()) do
		if v:IsA("BasePart") then
			local tape = v:FindFirstChild("Tape")
			
			tweenservice:Create(v,TweenInfo.new(0.5),{Transparency = 1}):Play()
			tweenservice:Create(tape,TweenInfo.new(0.5),{Transparency = 1}):Play()
		end
		wait(.5)
		
		hatchOneConnection:Disconnect()

		boxModel:Destroy()
		
		script.Parent.pillowDisplay.Visible = true
		local pillowModel = module3D:Attach3D(script.Parent.pillowDisplay, pillow)
		pillowModel:SetDepthMultiplier(1.2)
		pillowModel.Camera.FieldOfView = 5
		pillowModel.Visible = true
		_G.newTemplate(pillow.Name)
		
		runService.RenderStepped:Connect(function()
			pillowModel:SetCFrame(CFrame.Angles(0,0,0) * CFrame.Angles(math.rad(-10),0,0))
		end)

		wait(3)
		for i,v in pairs(script.Parent.pillowDisplay:GetDescendants()) do
			if v:IsA("ViewportFrame") then
				v:Destroy()
			end
		end
		isHatching = false
    
		script.Parent.pillowDisplay.Visible = false
	end
end



uis.InputBegan:Connect(function(input, GPE)
	if GPE then return end
	if input.KeyCode == Enum.KeyCode.E then
		if  player.Character ~= nil and isHatching == false then
			
			local nearestBox
			local plrPos = player.Character.HumanoidRootPart.Position
			
			for i,v in pairs(Boxs:GetChildren()) do
				if nearestBox == nil then
					nearestBox = v
				else
					if (plrPos - v.PrimaryPart.Position).Magnitude < (nearestBox.PrimaryPart.Position - plrPos).Magnitude then
						nearestBox = v
						
					end
				end
			end
			if player:DistanceFromCharacter(nearestBox.Box.PrimaryPart.Position) < maxDisplayDistance then

				canHatch = true
			else
				canHatch = false

			end
			
			if canHatch == true  then 
				
				local result = replicatedstroage:WaitForChild("Remotes"):WaitForChild("HatchServer"):InvokeServer(nearestBox) -- Random pillow
				if result ~= nil then -- If its not empty then
					
					_G.hatchOne(result,nearestBox) -- Hatch box
			end
			end
			
		end
	end
end)
