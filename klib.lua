local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow(title)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AntigravityLib"
	ScreenGui.Parent = CoreGui
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 450, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = MainFrame
	
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 35)
	TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -10, 1, 0)
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title or "UI Library"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 18
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar
	
	-- Dragging Logic
	local dragging, dragInput, dragStart, startPos
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	local ContentFrame = Instance.new("ScrollingFrame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.Size = UDim2.new(1, -20, 1, -45)
	ContentFrame.Position = UDim2.new(0, 10, 0, 40)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.BorderSizePixel = 0
	ContentFrame.ScrollBarThickness = 4
	ContentFrame.Parent = MainFrame
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Parent = ContentFrame
	
	local Elements = {}
	
	function Elements:CreateButton(text, callback)
		local Button = Instance.new("TextButton")
		Button.Name = text .. "Btn"
		Button.Size = UDim2.new(1, -10, 0, 30)
		Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		Button.Text = text
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Button.AutoButtonColor = false
		Button.Parent = ContentFrame
		
		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = Button
		
		Button.MouseEnter:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		end)
		
		Button.MouseLeave:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
		end)
		
		Button.MouseButton1Click:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			wait(0.1)
			Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			callback()
		end)
	end
	
	function Elements:CreateToggle(text, callback)
		local ToggleFrame = Instance.new("Frame")
		ToggleFrame.Name = text .. "Toggle"
		ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
		ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		ToggleFrame.Parent = ContentFrame
		
		local TCorner = Instance.new("UICorner")
		TCorner.CornerRadius = UDim.new(0, 6)
		TCorner.Parent = ToggleFrame
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -40, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 14
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = ToggleFrame
		
		local Indicator = Instance.new("Frame")
		Indicator.Name = "Indicator"
		Indicator.Size = UDim2.new(0, 20, 0, 20)
		Indicator.Position = UDim2.new(1, -30, 0.5, -10)
		Indicator.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		Indicator.Parent = ToggleFrame
		
		local ICorner = Instance.new("UICorner")
		ICorner.CornerRadius = UDim.new(1, 0)
		ICorner.Parent = Indicator
		
		local state = false
		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
		ToggleBtn.BackgroundTransparency = 1
		ToggleBtn.Text = ""
		ToggleBtn.Parent = ToggleFrame
		
		ToggleBtn.MouseButton1Click:Connect(function()
			state = not state
			local color = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
			TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
			callback(state)
		end)
	end
	
	function Elements:CreateSlider(text, min, max, default, callback)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, -10, 0, 45)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		SliderFrame.Parent = ContentFrame
		
		local SCorner = Instance.new("UICorner")
		SCorner.CornerRadius = UDim.new(0, 6)
		SCorner.Parent = SliderFrame
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -20, 0, 20)
		Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1
		Label.Text = text .. ": " .. default
		Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = SliderFrame
		
		local SliderBar = Instance.new("Frame")
		SliderBar.Size = UDim2.new(1, -20, 0, 6)
		SliderBar.Position = UDim2.new(0, 10, 0, 30)
		SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		SliderBar.Parent = SliderFrame
		
		local Filler = Instance.new("Frame")
		Filler.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
		Filler.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		Filler.BorderSizePixel = 0
		Filler.Parent = SliderBar
		
		local dragging = false
		local function update(input)
			local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
			local val = math.floor(min + (max - min) * pos)
			Filler.Size = UDim2.new(pos, 0, 1, 0)
			Label.Text = text .. ": " .. val
			callback(val)
		end
		
		SliderBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				update(input)
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				update(input)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end
	
	return Elements
end

return Library
