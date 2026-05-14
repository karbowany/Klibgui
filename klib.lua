--[[
    ═══════════════════════════════════════════════════════════
    █▀▀ █░█ █▀█ █▀█ █▀▄▀█ █▀▀   █░░ █ █▄▄ █▀█ ▄▀█ █▀█ █▄█
    █▄▄ █▀█ █▀▄ █▄█ █░▀░█ ██▄   █▄▄ █ █▄█ █▀▄ █▀█ █▀▄ ░█░
    ═══════════════════════════════════════════════════════════
    Zaawansowana biblioteka GUI - Wersja 2.0 Premium
    Niewykrywalny system z pełnym zestawem funkcji
    ═══════════════════════════════════════════════════════════
]]

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Kolory motywu
local Theme = {
    -- Główne kolory
    Background = Color3.fromRGB(15, 15, 15),
    SecondaryBackground = Color3.fromRGB(20, 20, 20),
    TertiaryBackground = Color3.fromRGB(25, 25, 25),
    
    -- Akcent
    Accent = Color3.fromRGB(138, 43, 226), -- Fioletowy
    AccentDark = Color3.fromRGB(108, 33, 186),
    AccentLight = Color3.fromRGB(168, 73, 255),
    
    -- Tekst
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(120, 120, 120),
    
    -- Statusy
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Error = Color3.fromRGB(244, 67, 54),
    Info = Color3.fromRGB(33, 150, 243),
    
    -- Elementy UI
    Border = Color3.fromRGB(40, 40, 40),
    Hover = Color3.fromRGB(35, 35, 35),
    Active = Color3.fromRGB(45, 45, 45),
}

-- Ikony (Lucide icons)
local Icons = {
    Home = "rbxassetid://10734950309",
    Settings = "rbxassetid://10734950886",
    User = "rbxassetid://10734949856",
    Shield = "rbxassetid://10747374131",
    Zap = "rbxassetid://10747383882",
    Eye = "rbxassetid://10747318698",
    Target = "rbxassetid://10723407389",
    Gamepad = "rbxassetid://10723374161",
    Code = "rbxassetid://10709818534",
    Bell = "rbxassetid://10709761530",
    Check = "rbxassetid://10709819149",
    X = "rbxassetid://10747384394",
    Minimize = "rbxassetid://10734896844",
    Copy = "rbxassetid://10709818534",
}

-- Funkcje zabezpieczające
local function getContainer()
    local containers = {
        gethui and gethui(),
        game:GetService("CoreGui"),
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    }
    
    for _, container in ipairs(containers) do
        if container then
            local success = pcall(function()
                local test = Instance.new("Frame")
                test.Parent = container
                test:Destroy()
            end)
            if success then return container end
        end
    end
    
    return game:GetService("Players").LocalPlayer.PlayerGui
end

local function randomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

local function createElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            element[prop] = value
        end
    end
    if properties.Parent then
        element.Parent = properties.Parent
    end
    return element
end

local function createGradient(parent, rotation)
    local gradient = createElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentLight)
        }),
        Rotation = rotation or 45,
        Parent = parent
    })
    return gradient
end

-- Animacje
local function smoothTween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Notyfikacje
local NotificationManager = {}
NotificationManager.Notifications = {}

function NotificationManager:Create(config)
    local notifType = config.Type or "Info"
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    
    local typeColors = {
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error,
        Info = Theme.Info
    }
    
    local color = typeColors[notifType] or Theme.Info
    
    local NotifContainer = createElement("ScreenGui", {
        Name = randomString(16),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getContainer()
    })
    
    local Notification = createElement("Frame", {
        Name = randomString(12),
        Size = UDim2.new(0, 320, 0, 0),
        Position = UDim2.new(1, -340, 0, 20 + (#NotificationManager.Notifications * 90)),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifContainer
    })
    
    createElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Notification
    })
    
    createElement("UIStroke", {
        Color = color,
        Thickness = 2,
        Transparency = 0.5,
        Parent = Notification
    })
    
    local AccentBar = createElement("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = Notification
    })
    
    local Icon = createElement("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 15, 0, 15),
        BackgroundTransparency = 1,
        Image = Icons.Bell,
        ImageColor3 = color,
        Parent = Notification
    })
    
    local Title = createElement("TextLabel", {
        Size = UDim2.new(1, -90, 0, 20),
        Position = UDim2.new(0, 50, 0, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })
    
    local Message = createElement("TextLabel", {
        Size = UDim2.new(1, -90, 0, 30),
        Position = UDim2.new(0, 50, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = Notification
    })
    
    local CloseBtn = createElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Theme.TextSecondary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = Notification
    })
    
    table.insert(NotificationManager.Notifications, NotifContainer)
    
    smoothTween(Notification, {Size = UDim2.new(0, 320, 0, 80)}, 0.4)
    
    local function closeNotif()
        smoothTween(Notification, {
            Size = UDim2.new(0, 320, 0, 0),
            Position = UDim2.new(1, -340, 0, Notification.Position.Y.Offset)
        }, 0.3)
        task.wait(0.3)
        NotifContainer:Destroy()
        
        for i, notif in ipairs(NotificationManager.Notifications) do
            if notif == NotifContainer then
                table.remove(NotificationManager.Notifications, i)
                break
            end
        end
    end
    
    CloseBtn.MouseButton1Click:Connect(closeNotif)
    
    task.delay(duration, closeNotif)
end

-- Watermark
local function createWatermark()
    local WatermarkGui = createElement("ScreenGui", {
        Name = randomString(16),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getContainer()
    })
    
    local Watermark = createElement("Frame", {
        Size = UDim2.new(0, 280, 0, 45),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = WatermarkGui
    })
    
    createElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Watermark
    })
    
    createElement("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.5,
        Transparency = 0.7,
        Parent = Watermark
    })
    
    local GradientBg = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Watermark
    })
    
    createGradient(GradientBg, 90)
    
    local Logo = createElement("TextLabel", {
        Size = UDim2.new(0, 120, 1, -5),
        Position = UDim2.new(0, 12, 0, 2),
        BackgroundTransparency = 1,
        Text = "CHROME",
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark
    })
    
    local gradient = createGradient(Logo, 45)
    
    local Version = createElement("TextLabel", {
        Size = UDim2.new(0, 60, 0, 15),
        Position = UDim2.new(0, 12, 0, 22),
        BackgroundTransparency = 1,
        Text = "v2.0 Premium",
        TextColor3 = Theme.Accent,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark
    })
    
    local Separator = createElement("Frame", {
        Size = UDim2.new(0, 1, 0, 30),
        Position = UDim2.new(0, 140, 0, 7),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = Watermark
    })
    
    local FPS = createElement("TextLabel", {
        Size = UDim2.new(0, 50, 0, 15),
        Position = UDim2.new(0, 150, 0, 8),
        BackgroundTransparency = 1,
        Text = "0 FPS",
        TextColor3 = Theme.Success,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark
    })
    
    local Ping = createElement("TextLabel", {
        Size = UDim2.new(0, 70, 0, 15),
        Position = UDim2.new(0, 150, 0, 22),
        BackgroundTransparency = 1,
        Text = "0ms",
        TextColor3 = Theme.Info,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Watermark
    })
    
    local Time = createElement("TextLabel", {
        Size = UDim2.new(0, 70, 0, 15),
        Position = UDim2.new(1, -75, 0, 15),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M:%S"),
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Watermark
    })
    
    -- Aktualizacja FPS i Ping
    local frameCounter = 0
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCounter = frameCounter + 1
        
        if tick() - lastUpdate >= 1 then
            local fps = frameCounter
            FPS.Text = fps .. " FPS"
            
            if fps >= 50 then
                FPS.TextColor3 = Theme.Success
            elseif fps >= 30 then
                FPS.TextColor3 = Theme.Warning
            else
                FPS.TextColor3 = Theme.Error
            end
            
            frameCounter = 0
            lastUpdate = tick()
            
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            Ping.Text = ping
            
            Time.Text = os.date("%H:%M:%S")
        end
    end)
    
    -- Animacja gradient
    spawn(function()
        while wait() do
            smoothTween(gradient, {Rotation = gradient.Rotation + 360}, 8)
            wait(8)
        end
    end)
    
    return WatermarkGui
end

-- Główna funkcja tworzenia okna
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Chrome UI"
    local windowSize = config.Size or UDim2.new(0, 650, 0, 450)
    
    -- Tworzenie watermark
    createWatermark()
    
    local ScreenGui = createElement("ScreenGui", {
        Name = randomString(16),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getContainer()
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
    
    -- Główne okno
    local MainFrame = createElement("Frame", {
        Name = randomString(12),
        Size = windowSize,
        Position = UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    createElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })
    
    -- Cień zewnętrzny
    local Shadow = createElement("ImageLabel", {
        Name = randomString(8),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = MainFrame
    })
    
    -- Nagłówek z gradientem
    local Header = createElement("Frame", {
        Name = randomString(10),
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    createElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = Header
    })
    
    local HeaderCover = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    local HeaderGradient = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    createGradient(HeaderGradient, 90)
    
    -- Logo i tytuł
    local LogoContainer = createElement("Frame", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local Logo = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = windowName,
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    createGradient(Logo, 45)
    
    local Subtitle = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Premium Edition",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    -- Przyciski kontrolne
    local ControlButtons = createElement("Frame", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -110, 0, 10),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local function createControlButton(icon, position, callback)
        local button = createElement("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = position,
            BackgroundColor3 = Theme.TertiaryBackground,
            Text = "",
            Parent = ControlButtons
        })
        
        createElement("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = button
        })
        
        local iconLabel = createElement("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Theme.TextSecondary,
            Parent = button
        })
        
        button.MouseEnter:Connect(function()
            smoothTween(button, {BackgroundColor3 = Theme.Hover})
            smoothTween(iconLabel, {ImageColor3 = Theme.TextPrimary})
        end)
        
        button.MouseLeave:Connect(function()
            smoothTween(button, {BackgroundColor3 = Theme.TertiaryBackground})
            smoothTween(iconLabel, {ImageColor3 = Theme.TextSecondary})
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    local minimized = false
    createControlButton(Icons.Minimize, UDim2.new(0, 0, 0, 0), function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 650, 0, 50) or windowSize
        smoothTween(MainFrame, {Size = targetSize}, 0.4)
    end)
    
    createControlButton(Icons.Copy, UDim2.new(0, 35, 0, 0), function()
        NotificationManager:Create({
            Type = "Info",
            Title = "Link skopiowany",
            Message = "Link do GUI został skopiowany do schowka!",
            Duration = 2
        })
    end)
    
    createControlButton(Icons.X, UDim2.new(0, 70, 0, 0), function()
        smoothTween(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Kontener na zakładki (sidebar)
    local Sidebar = createElement("Frame", {
        Name = randomString(10),
        Size = UDim2.new(0, 160, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Theme.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    createElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Sidebar
    })
    
    local SidebarList = createElement("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = Sidebar
    })
    
    createElement("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = Sidebar
    })
    
    -- Kontener na zawartość
    local ContentContainer = createElement("Frame", {
        Name = randomString(10),
        Size = UDim2.new(1, -190, 1, -60),
        Position = UDim2.new(0, 180, 0, 55),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    local Window = {
        MainFrame = MainFrame,
        Tabs = {},
        CurrentTab = nil,
        Notifications = NotificationManager
    }
    
    -- Funkcja tworzenia zakładki
    function Window:CreateTab(config)
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or Icons.Home
        
        local TabButton = createElement("TextButton", {
            Name = randomString(8),
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Theme.TertiaryBackground,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Parent = Sidebar
        })
        
        createElement("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabButton
        })
        
        local TabIcon = createElement("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0.5, -10),
            BackgroundTransparency = 1,
            Image = tabIcon,
            ImageColor3 = Theme.TextSecondary,
            Parent = TabButton
        })
        
        local TabLabel = createElement("TextLabel", {
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        local TabIndicator = createElement("Frame", {
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = TabButton
        })
        
        createElement("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = TabIndicator
        })
        
        local TabContent = createElement("ScrollingFrame", {
            Name = randomString(10),
            Size = UDim2.new(1, -10, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentContainer
        })
        
        local ContentList = createElement("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = TabContent
        })
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)
        
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Active = false
        }
        
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                smoothTween(TabButton, {BackgroundColor3 = Theme.Hover})
                smoothTween(TabIcon, {ImageColor3 = Theme.TextPrimary})
                smoothTween(TabLabel, {TextColor3 = Theme.TextPrimary})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                smoothTween(TabButton, {BackgroundColor3 = Theme.TertiaryBackground})
                smoothTween(TabIcon, {ImageColor3 = Theme.TextSecondary})
                smoothTween(TabLabel, {TextColor3 = Theme.TextSecondary})
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Active = false
                smoothTween(tab.Button, {BackgroundColor3 = Theme.TertiaryBackground})
                smoothTween(tab.Button:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Theme.TextSecondary})
                smoothTween(tab.Button:FindFirstChildOfClass("TextLabel"), {TextColor3 = Theme.TextSecondary})
                smoothTween(tab.Button:FindFirstChildOfClass("Frame"), {Size = UDim2.new(0, 3, 0, 0)})
            end
            
            TabContent.Visible = true
            Tab.Active = true
            smoothTween(TabButton, {BackgroundColor3 = Theme.Active})
            smoothTween(TabIcon, {ImageColor3 = Theme.Accent})
            smoothTween(TabLabel, {TextColor3 = Theme.TextPrimary})
            smoothTween(TabIndicator, {Size = UDim2.new(0, 3, 0, 30)})
            Window.CurrentTab = Tab
        end)
        
        -- === SEKCJA ===
        function Tab:AddSection(sectionName)
            local Section = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local SectionLabel = createElement("TextLabel", {
                Size = UDim2.new(0, 200, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })
            
            local SectionLine = createElement("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -5),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = Section
            })
            
            createGradient(SectionLine, 90)
            
            return Section
        end
        
        -- === PARAGRAPH ===
        function Tab:AddParagraph(config)
            local title = config.Title or "Paragraph"
            local content = config.Content or ""
            
            local Paragraph = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = Paragraph
            })
            
            createElement("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.8,
                Parent = Paragraph
            })
            
            local ParagraphTitle = createElement("TextLabel", {
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.Accent,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Paragraph
            })
            
            local ParagraphContent = createElement("TextLabel", {
                Size = UDim2.new(1, -30, 0, 1000),
                Position = UDim2.new(0, 15, 0, 35),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = Theme.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = Paragraph
            })
            
            local contentHeight = game:GetService("TextService"):GetTextSize(
                content,
                13,
                Enum.Font.Gotham,
                Vector2.new(ParagraphContent.AbsoluteSize.X, math.huge)
            ).Y
            
            Paragraph.Size = UDim2.new(1, 0, 0, contentHeight + 50)
            ParagraphContent.Size = UDim2.new(1, -30, 0, contentHeight)
        end
        
        -- === BUTTON ===
        function Tab:AddButton(config)
            local buttonText = config.Text or "Button"
            local callback = config.Callback or function() end
            
            local ButtonFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = ButtonFrame
            })
            
            local Button = createElement("TextButton", {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundColor3 = Theme.TertiaryBackground,
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = Button
            })
            
            createElement("UIStroke", {
                Color = Theme.Accent,
                Thickness = 1,
                Transparency = 0.8,
                Parent = Button
            })
            
            local ButtonLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = buttonText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Button
            })
            
            local ButtonIcon = createElement("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -28, 0.5, -9),
                BackgroundTransparency = 1,
                Image = Icons.Zap,
                ImageColor3 = Theme.Accent,
                Parent = Button
            })
            
            Button.MouseEnter:Connect(function()
                smoothTween(Button, {BackgroundColor3 = Theme.Hover})
                smoothTween(ButtonIcon, {ImageColor3 = Theme.AccentLight})
            end)
            
            Button.MouseLeave:Connect(function()
                smoothTween(Button, {BackgroundColor3 = Theme.TertiaryBackground})
                smoothTween(ButtonIcon, {ImageColor3 = Theme.Accent})
            end)
            
            Button.MouseButton1Click:Connect(function()
                smoothTween(Button, {BackgroundColor3 = Theme.Active})
                task.wait(0.1)
                smoothTween(Button, {BackgroundColor3 = Theme.Hover})
                pcall(callback)
            end)
            
            return Button
        end
        
        -- === TOGGLE ===
        function Tab:AddToggle(config)
            local toggleText = config.Text or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            
            local ToggleFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = ToggleFrame
            })
            
            local ToggleLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -90, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleOuter = createElement("Frame", {
                Size = UDim2.new(0, 50, 0, 26),
                Position = UDim2.new(1, -60, 0.5, -13),
                BackgroundColor3 = default and Theme.Success or Theme.TertiaryBackground,
                BorderSizePixel = 0,
                Parent = ToggleFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleOuter
            })
            
            local ToggleInner = createElement("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0,
                Parent = ToggleOuter
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleInner
            })
            
            local toggled = default
            
            local ToggleButton = createElement("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ToggleFrame
            })
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                smoothTween(ToggleOuter, {
                    BackgroundColor3 = toggled and Theme.Success or Theme.TertiaryBackground
                }, 0.3)
                
                smoothTween(ToggleInner, {
                    Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                }, 0.3)
                
                pcall(callback, toggled)
            end)
            
            return {
                Set = function(value)
                    toggled = value
                    ToggleOuter.BackgroundColor3 = toggled and Theme.Success or Theme.TertiaryBackground
                    ToggleInner.Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                    pcall(callback, toggled)
                end
            }
        end
        
        -- === SLIDER ===
        function Tab:AddSlider(config)
            local sliderText = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local callback = config.Callback or function() end
            
            local SliderFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = SliderFrame
            })
            
            local SliderLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -80, 0, 20),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = sliderText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local SliderValue = createElement("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 10),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = Theme.Accent,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local SliderTrack = createElement("Frame", {
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 1, -20),
                BackgroundColor3 = Theme.TertiaryBackground,
                BorderSizePixel = 0,
                Parent = SliderFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderTrack
            })
            
            local SliderFill = createElement("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderFill
            })
            
            createGradient(SliderFill, 90)
            
            local SliderButton = createElement("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderButton
            })
            
            createElement("UIStroke", {
                Color = Theme.Accent,
                Thickness = 2,
                Parent = SliderButton
            })
            
            local dragging = false
            local currentValue = default
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * pos
                value = math.floor(value / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                
                currentValue = value
                SliderValue.Text = tostring(value)
                
                smoothTween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                smoothTween(SliderButton, {Position = UDim2.new(pos, -8, 0.5, -8)}, 0.1)
                
                pcall(callback, value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                    smoothTween(SliderButton, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
                end
            end)
            
            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    smoothTween(SliderButton, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            return {
                Set = function(value)
                    value = math.clamp(value, min, max)
                    currentValue = value
                    local pos = (value - min) / (max - min)
                    SliderValue.Text = tostring(value)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
                    pcall(callback, value)
                end
            }
        end
        
        -- === DROPDOWN ===
        function Tab:AddDropdown(config)
            local dropdownText = config.Text or "Dropdown"
            local options = config.Options or {"Option 1", "Option 2"}
            local default = config.Default or options[1]
            local callback = config.Callback or function() end
            
            local currentOption = default
            local dropdownOpen = false
            
            local DropdownFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = DropdownFrame
            })
            
            local DropdownLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -100, 0, 45),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdownText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropdownFrame
            })
            
            local DropdownButton = createElement("TextButton", {
                Size = UDim2.new(1, -30, 0, 35),
                Position = UDim2.new(0, 15, 0, 5),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropdownFrame
            })
            
            local DropdownValue = createElement("TextLabel", {
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(1, -165, 0, 0),
                BackgroundTransparency = 1,
                Text = currentOption,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = DropdownButton
            })
            
            local DropdownArrow = createElement("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                Parent = DropdownButton
            })
            
            local OptionsList = createElement("Frame", {
                Size = UDim2.new(1, -30, 0, 0),
                Position = UDim2.new(0, 15, 0, 45),
                BackgroundColor3 = Theme.TertiaryBackground,
                BorderSizePixel = 0,
                Parent = DropdownFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = OptionsList
            })
            
            local OptionsLayout = createElement("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = OptionsList
            })
            
            for _, option in ipairs(options) do
                local OptionButton = createElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = option == currentOption and Theme.Active or Color3.fromRGB(0, 0, 0, 0),
                    BackgroundTransparency = option == currentOption and 0 or 1,
                    Text = option,
                    TextColor3 = option == currentOption and Theme.Accent or Theme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    Parent = OptionsList
                })
                
                OptionButton.MouseEnter:Connect(function()
                    if option ~= currentOption then
                        smoothTween(OptionButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover})
                    end
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    if option ~= currentOption then
                        smoothTween(OptionButton, {BackgroundTransparency = 1})
                    end
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    for _, btn in ipairs(OptionsList:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundTransparency = 1
                            btn.TextColor3 = Theme.TextSecondary
                        end
                    end
                    
                    OptionButton.BackgroundTransparency = 0
                    OptionButton.BackgroundColor3 = Theme.Active
                    OptionButton.TextColor3 = Theme.Accent
                    
                    currentOption = option
                    DropdownValue.Text = option
                    
                    dropdownOpen = false
                    smoothTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3)
                    smoothTween(DropdownArrow, {Rotation = 0}, 0.3)
                    
                    pcall(callback, option)
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                
                local targetSize = dropdownOpen and UDim2.new(1, 0, 0, 50 + (#options * 32)) or UDim2.new(1, 0, 0, 45)
                smoothTween(DropdownFrame, {Size = targetSize}, 0.3)
                smoothTween(DropdownArrow, {Rotation = dropdownOpen and 180 or 0}, 0.3)
            end)
            
            return {
                Set = function(option)
                    if table.find(options, option) then
                        currentOption = option
                        DropdownValue.Text = option
                        pcall(callback, option)
                    end
                end
            }
        end
        
        -- === TEXTBOX ===
        function Tab:AddTextbox(config)
            local textboxText = config.Text or "Textbox"
            local placeholder = config.Placeholder or "Enter text..."
            local default = config.Default or ""
            local callback = config.Callback or function() end
            
            local TextboxFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 70),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = TextboxFrame
            })
            
            local TextboxLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = textboxText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TextboxFrame
            })
            
            local TextboxInput = createElement("TextBox", {
                Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0, 15, 0, 33),
                BackgroundColor3 = Theme.TertiaryBackground,
                PlaceholderText = placeholder,
                Text = default,
                TextColor3 = Theme.TextPrimary,
                PlaceholderColor3 = Theme.TextDisabled,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = false,
                Parent = TextboxFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = TextboxInput
            })
            
            createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = TextboxInput
            })
            
            local TextboxStroke = createElement("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.8,
                Parent = TextboxInput
            })
            
            TextboxInput.Focused:Connect(function()
                smoothTween(TextboxStroke, {Color = Theme.Accent, Transparency = 0}, 0.2)
            end)
            
            TextboxInput.FocusLost:Connect(function(enterPressed)
                smoothTween(TextboxStroke, {Color = Theme.Border, Transparency = 0.8}, 0.2)
                if enterPressed then
                    pcall(callback, TextboxInput.Text)
                end
            end)
            
            return {
                Set = function(text)
                    TextboxInput.Text = text
                end
            }
        end
        
        -- === KEYBIND ===
        function Tab:AddKeybind(config)
            local keybindText = config.Text or "Keybind"
            local default = config.Default or Enum.KeyCode.E
            local callback = config.Callback or function() end
            
            local currentKey = default
            local binding = false
            
            local KeybindFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = KeybindFrame
            })
            
            local KeybindLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = keybindText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindButton = createElement("TextButton", {
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -90, 0.5, -15),
                BackgroundColor3 = Theme.TertiaryBackground,
                Text = currentKey.Name,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent = KeybindFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = KeybindButton
            })
            
            local KeybindStroke = createElement("UIStroke", {
                Color = Theme.Accent,
                Thickness = 1,
                Transparency = 0.8,
                Parent = KeybindButton
            })
            
            KeybindButton.MouseButton1Click:Connect(function()
                binding = true
                KeybindButton.Text = "..."
                smoothTween(KeybindStroke, {Transparency = 0}, 0.2)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        binding = false
                        smoothTween(KeybindStroke, {Transparency = 0.8}, 0.2)
                    end
                elseif input.KeyCode == currentKey and not gameProcessed then
                    pcall(callback)
                end
            end)
            
            return {
                Set = function(key)
                    currentKey = key
                    KeybindButton.Text = key.Name
                end
            }
        end
        
        -- === COLOR PICKER ===
        function Tab:AddColorPicker(config)
            local pickerText = config.Text or "Color Picker"
            local default = config.Default or Color3.fromRGB(255, 255, 255)
            local callback = config.Callback or function() end
            
            local PickerFrame = createElement("Frame", {
                Name = randomString(8),
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = Theme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = PickerFrame
            })
            
            local PickerLabel = createElement("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = pickerText,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = PickerFrame
            })
            
            local ColorDisplay = createElement("TextButton", {
                Size = UDim2.new(0, 35, 0, 35),
                Position = UDim2.new(1, -45, 0.5, -17.5),
                BackgroundColor3 = default,
                Text = "",
                AutoButtonColor = false,
                Parent = PickerFrame
            })
            
            createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = ColorDisplay
            })
            
            createElement("UIStroke", {
                Color = Theme.Border,
                Thickness = 2,
                Parent = ColorDisplay
            })
            
            ColorDisplay.MouseButton1Click:Connect(function()
                -- Tutaj można dodać picker kolorów
                NotificationManager:Create({
                    Type = "Info",
                    Title = "Color Picker",
                    Message = "Funkcja w rozwoju!",
                    Duration = 2
                })
            end)
            
            return {
                Set = function(color)
                    ColorDisplay.BackgroundColor3 = color
                    pcall(callback, color)
                end
            }
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.MouseButton1Click()
        end
        
        return Tab
    end
    
    return Window
end

return Library
