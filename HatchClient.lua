local replicatedstroage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local uis = game:GetService("UserInputService")


local camera = workspace.Camera
local player = game.Players.LocalPlayer

local Pillows = replicatedstroage:WaitForChild("Pillows")
local Boxs = workspace:WaitForChild("Boxs")
local module3D = require(replicatedstroage:WaitForChild("Module3D"))


local maxDisplayDistance = 15
local canHatch = false
local isHatching = false
local hatchOneConnection = nil
local cooldown = false
local cantOpenBillboard = false


wait(.5)

local function animateBillboard(billboard, openOrClose)
	if openOrClose == true then
		tweenservice:Create(billboard,TweenInfo.new(.1),{Size = UDim2.new(7,0,8,0)}):Play()
	else
		tweenservice:Create(billboard,TweenInfo.new(.1),{Size = UDim2.new(0,0,0,0)}):Play()
		wait(.1)
		billboard.Enabled = false
		
	end
	wait(.5)
end

local function disableAllBillboards()
	cantOpenBillboard = true
	for i,v in pairs(script.Parent.Parent.BoxBillboards:GetChildren()) do
		if v:IsA("BillboardGui") then
			animateBillboard(v, false)
			animateBillboard(v:FindFirstChild("Btn"), false)
		end
	end
end

local function enableAllBillboards()
	cantOpenBillboard = false
	for i,v in pairs(script.Parent.Parent.BoxBillboards:GetChildren()) do
		if v:IsA("BillboardGui") then
			animateBillboard(v, true)
			animateBillboard(v:FindFirstChild("Btn"), true)
		end
	end
end

	
	for i, v in pairs(Boxs:GetChildren()) do
	local boxPillows = Pillows:FindFirstChild(v.Name)
	
	if boxPillows ~= nil then
		local billboardTemplate = script.Template:Clone()
		local Container = billboardTemplate:WaitForChild("Container")
		local mainFrame = Container:WaitForChild("MainFrame")
		local template = mainFrame:WaitForChild("Template") --button template
		local display = template:WaitForChild("Display")
		
		
		billboardTemplate.Parent = script.Parent.Parent.BoxBillboards
		billboardTemplate.Name = v.Name
		billboardTemplate.Adornee = v.Box
		billboardTemplate.Btn.Adornee = v.Box
		billboardTemplate.Enabled = true
		
		local pillows = {}
		
		for x, pillow in pairs(boxPillows:GetChildren()) do
			table.insert(pillows,pillow.Rarity.Value)
		end
		
		table.sort(pillows)
		for i = 1, math.floor(#pillows/2) do
			local j = #pillows - i + 1
			pillows[i], pillows[j] = pillows[j], pillows[i]
		end
		
		for _, rarity in pairs(pillows) do
			
		
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
						pillowModel:SetCFrame(CFrame.Angles(0,0,0) * CFrame.Angles(math.rad(-10),0,0))
					end)
					break
				else
					continue
				end
				end
				
				end	
		
		 runService.RenderStepped:Connect(function()
			if player:DistanceFromCharacter(v.Box.PrimaryPart.Position) < maxDisplayDistance then
				if cantOpenBillboard == false then
					billboardTemplate.Enabled = true
					billboardTemplate:FindFirstChild("Btn").Enabled = true
					animateBillboard(billboardTemplate,true)
					animateBillboard(billboardTemplate:FindFirstChild("Btn"),true)
				end
			else
				if cantOpenBillboard == false then
					animateBillboard(billboardTemplate,false)
					animateBillboard(billboardTemplate:FindFirstChild("Btn"),true)
				end
			end
		end)
	end
end
_G.hatchOne = function(pillowName,box)
	spawn(function() disableAllBillboards() end)
	
	print(pillowName)
	local pillow = Pillows[box.Name]:FindFirstChild(pillowName):Clone()

	
	isHatching = true
	local boxModel = box:FindFirstChild("Box"):Clone()
	for i,v in pairs(boxModel:GetChildren()) do
		if v:IsA("BasePart") and not v:IsA("BillboardGui") then
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
		if v:IsA("BasePart") and not v:IsA("BillboardGui") then
			local tape = v:FindFirstChild("Tape")
			
			tweenservice:Create(v,TweenInfo.new(0.5),{Transparency = 1}):Play()
			tweenservice:Create(tape,TweenInfo.new(0.5),{Transparency = 1}):Play()
		end
		wait(.5)
		
		hatchOneConnection:Disconnect()

		boxModel:Destroy()
		
		script.Parent.pillowDisplay.Visible = true
		script.Parent.pillowDisplay.Pillow.Text = pillowName
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
		spawn(function() enableAllBillboards() end)
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
				
				local result = replicatedstroage:WaitForChild("Remotes"):WaitForChild("HatchServer"):InvokeServer(nearestBox)
				if result ~= nil then
					if not cooldown then
						cooldown = true
						_G.hatchOne(result,nearestBox)
						wait(.1)
						cooldown = false
					end
					
			end
			end
			
		end
	end
end)

for i,v in pairs(script.Parent.Parent.BoxBillboards:GetChildren()) do
	local Ebtn = v.Btn.TextButton
	
	Ebtn.MouseButton1Click:Connect(function()
		if  player.Character ~= nil and isHatching == false  then
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

				local result = replicatedstroage:WaitForChild("Remotes"):WaitForChild("HatchServer"):InvokeServer(nearestBox)
				if result ~= nil then
					
					if not cooldown then
						cooldown = true
						_G.hatchOne(result,nearestBox)
						wait(.1)
						cooldown = false
						
					end
				end
			end
		end
	end)
end
