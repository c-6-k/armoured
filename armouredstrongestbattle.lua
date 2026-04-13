-- ARMOURED :: STRONGEST BATTLEGROUNDS
-- Movement, exploits, combat, teleport, and animation mods.

local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local SafeUI = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui")
if not pcall(function() return SafeUI.Name end) then
    SafeUI = LocalPlayer:WaitForChild("PlayerGui")
end

local ExpectedPlaceId = 10449761463

local function DestroyExistingUIs()
    for _, name in ipairs({"Armoured_TSB_Splash", "Armoured_TSB_Hub"}) do
        local existing = SafeUI:FindFirstChild(name)
        if existing then pcall(function() existing:Destroy() end) end
    end
end

_G.ArmouredTSBVersion = (_G.ArmouredTSBVersion or 0) + 1
local MY_VERSION = _G.ArmouredTSBVersion
local Unloaded = false

if game.PlaceId ~= ExpectedPlaceId then
    if type(_G.ArmouredTSBShutdown) == "function" then pcall(_G.ArmouredTSBShutdown) end
    DestroyExistingUIs()
    return
end

if type(_G.ArmouredTSBShutdown) == "function" then pcall(_G.ArmouredTSBShutdown) end
DestroyExistingUIs()

local function IsActive()
    return _G.ArmouredTSBVersion == MY_VERSION and not Unloaded
end

print("[ARMOURED] Strongest Battlegrounds v1 booting.")

local Connections = {}
local function TrackConnection(conn)
    Connections[#Connections + 1] = conn
    return conn
end

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Header     = Color3.fromRGB(20, 20, 20),
    Sidebar    = Color3.fromRGB(12, 12, 12),
    Panel      = Color3.fromRGB(24, 24, 24),
    PanelAlt   = Color3.fromRGB(32, 32, 32),
    Stroke     = Color3.fromRGB(40, 40, 40),
    Accent     = Color3.fromRGB(230, 140, 60),
    AccentDim  = Color3.fromRGB(120, 70, 30),
    Text       = Color3.fromRGB(240, 240, 240),
    SubText    = Color3.fromRGB(160, 160, 160),
    GreyText   = Color3.fromRGB(110, 110, 110),
    Danger     = Color3.fromRGB(220, 70, 70),
}

-- ==================== Library ====================
local Library = {}
local KeybindListening = false

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function Library:CreateSplash(title, subtitle, steps, onDone)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Armoured_TSB_Splash"
    gui.Parent = SafeUI
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 50

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.Parent = gui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 420, 0, 120)
    container.Position = UDim2.new(0.5, -210, 0.5, -60)
    container.BackgroundTransparency = 1
    container.Parent = backdrop

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 28)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextColor3 = Theme.Accent
    titleLbl.Text = title
    titleLbl.TextTransparency = 1
    titleLbl.Parent = container

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, 0, 0, 16)
    subLbl.Position = UDim2.new(0, 0, 0, 32)
    subLbl.BackgroundTransparency = 1
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextColor3 = Theme.SubText
    subLbl.Text = subtitle
    subLbl.TextTransparency = 1
    subLbl.Parent = container

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, 0, 0, 14)
    statusLbl.Position = UDim2.new(0, 0, 0, 58)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Theme.GreyText
    statusLbl.Text = ""
    statusLbl.TextTransparency = 1
    statusLbl.Parent = container

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 300, 0, 2)
    barBg.Position = UDim2.new(0.5, -150, 0, 90)
    barBg.BackgroundColor3 = Theme.Stroke
    barBg.BorderSizePixel = 0
    barBg.BackgroundTransparency = 1
    barBg.Parent = container

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    task.spawn(function()
        local fadeIn = TweenInfo.new(0.3)
        TweenService:Create(backdrop, fadeIn, {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(titleLbl, fadeIn, {TextTransparency = 0}):Play()
        TweenService:Create(subLbl, fadeIn, {TextTransparency = 0}):Play()
        TweenService:Create(statusLbl, fadeIn, {TextTransparency = 0}):Play()
        TweenService:Create(barBg, fadeIn, {BackgroundTransparency = 0}):Play()
        task.wait(0.3)

        local total = 0
        for _, s in ipairs(steps) do total = total + s.duration end
        local accum = 0
        for _, s in ipairs(steps) do
            if not IsActive() then break end
            statusLbl.Text = s.label
            accum = accum + s.duration
            local alpha = accum / total
            TweenService:Create(barFill, TweenInfo.new(s.duration, Enum.EasingStyle.Linear), {
                Size = UDim2.new(alpha, 0, 1, 0)
            }):Play()
            task.wait(s.duration)
        end

        if not IsActive() then gui:Destroy() return end

        local fadeOut = TweenInfo.new(0.3)
        TweenService:Create(backdrop, fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLbl, fadeOut, {TextTransparency = 1}):Play()
        TweenService:Create(subLbl, fadeOut, {TextTransparency = 1}):Play()
        TweenService:Create(statusLbl, fadeOut, {TextTransparency = 1}):Play()
        TweenService:Create(barBg, fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(barFill, fadeOut, {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        gui:Destroy()
        if onDone then onDone() end
    end)
end

function Library:CreateWindow(name)
    local existing = SafeUI:FindFirstChild("Armoured_TSB_Hub")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Armoured_TSB_Hub"
    ScreenGui.Parent = SafeUI
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 640, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -220)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 8)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    addCorner(Header, 8)

    local HeaderFill = Instance.new("Frame")
    HeaderFill.Size = UDim2.new(1, 0, 0, 8)
    HeaderFill.Position = UDim2.new(0, 0, 1, -8)
    HeaderFill.BackgroundColor3 = Theme.Header
    HeaderFill.BorderSizePixel = 0
    HeaderFill.Parent = Header

    local AccentStrip = Instance.new("Frame")
    AccentStrip.Size = UDim2.new(1, 0, 0, 2)
    AccentStrip.BackgroundColor3 = Theme.Accent
    AccentStrip.BorderSizePixel = 0
    AccentStrip.ZIndex = 2
    AccentStrip.Parent = Header

    local Diamond = Instance.new("Frame")
    Diamond.Size = UDim2.new(0, 11, 0, 11)
    Diamond.Position = UDim2.new(0, 15, 0.5, -5)
    Diamond.Rotation = 45
    Diamond.BackgroundColor3 = Theme.Accent
    Diamond.BorderSizePixel = 0
    Diamond.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 36, 0, 0)
    Title.Size = UDim2.new(1, -36, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = Header

    local Sidebar = Instance.new("Frame")
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 160, 1, -40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local VersionLbl = Instance.new("TextLabel")
    VersionLbl.Size = UDim2.new(1, -16, 0, 14)
    VersionLbl.Position = UDim2.new(0, 8, 1, -22)
    VersionLbl.BackgroundTransparency = 1
    VersionLbl.Font = Enum.Font.Gotham
    VersionLbl.TextSize = 11
    VersionLbl.TextColor3 = Theme.GreyText
    VersionLbl.TextXAlignment = Enum.TextXAlignment.Right
    VersionLbl.Text = "v1"
    VersionLbl.Parent = Sidebar

    local dragging, dragStart, startPos, targetPos = false, nil, nil, nil
    local ready, open, toggling, playingIntro = false, true, false, false

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            targetPos = startPos
        end
    end)

    TrackConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    TrackConnection(RunService.RenderStepped:Connect(function()
        if not IsActive() or not targetPos or toggling or playingIntro or not MainFrame.Visible then return end
        local current = MainFrame.Position
        local alpha = dragging and 0.18 or 0.14
        local nextX = current.X.Offset + (targetPos.X.Offset - current.X.Offset) * alpha
        local nextY = current.Y.Offset + (targetPos.Y.Offset - current.Y.Offset) * alpha
        if math.abs(nextX - targetPos.X.Offset) < 0.5 then nextX = targetPos.X.Offset end
        if math.abs(nextY - targetPos.Y.Offset) < 0.5 then nextY = targetPos.Y.Offset end
        MainFrame.Position = UDim2.new(targetPos.X.Scale, nextX, targetPos.Y.Scale, nextY)
    end))

    TrackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not ready or input.KeyCode ~= Enum.KeyCode.RightShift or toggling then return end
        toggling = true
        open = not open
        if not open then
            local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, Size = UDim2.new(0, 640, 0, 0)})
            tw:Play()
            tw.Completed:Wait()
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
            local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2.new(0, 640, 0, 440)})
            tw:Play()
            tw.Completed:Wait()
        end
        toggling = false
    end))

    local CurrentTab, CurrentTabBtn, CurrentIcon, CurrentLabel, CurrentIndicator
    local TabCount = 0
    local Window = {}

    function Window:PlayIntro()
        playingIntro = true
        MainFrame.Visible = true
        MainFrame.BackgroundTransparency = 1
        MainFrame.Size = UDim2.new(0, math.floor(640 * 0.92), 0, math.floor(440 * 0.92))
        MainFrame.Position = UDim2.new(0.5, -math.floor(640 * 0.92 / 2), 0.5, -math.floor(440 * 0.92 / 2))
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 640, 0, 440),
            Position = UDim2.new(0.5, -320, 0.5, -220),
        })
        tw:Play()
        tw.Completed:Wait()
        targetPos = MainFrame.Position
        playingIntro = false
        ready = true
    end

    function Window:CreateTab(tabname, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -16, 0, 34)
        TabBtn.Position = UDim2.new(0, 8, 0, 10 + (TabCount * 40))
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = Sidebar
        addCorner(TabBtn, 6)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 1, -10)
        Indicator.Position = UDim2.new(0, 0, 0, 5)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.BackgroundTransparency = 1
        Indicator.Parent = TabBtn
        addCorner(Indicator, 2)

        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 0, 0, 0)
        IconLbl.BackgroundTransparency = 1
        IconLbl.Text = ""
        IconLbl.Parent = TabBtn

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 13
        Label.TextColor3 = Theme.GreyText
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Text = tabname
        Label.Parent = TabBtn

        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = tabname .. "_Container"
        TabContainer.Position = UDim2.new(0, 172, 0, 52)
        TabContainer.Size = UDim2.new(1, -184, 1, -64)
        TabContainer.BackgroundTransparency = 1
        TabContainer.BorderSizePixel = 0
        TabContainer.ScrollBarThickness = 3
        TabContainer.ScrollBarImageColor3 = Theme.Accent
        TabContainer.ScrollingDirection = Enum.ScrollingDirection.Y
        TabContainer.Visible = false
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContainer.Parent = MainFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 8)
        Padding.PaddingRight = UDim.new(0, 12)
        Padding.PaddingTop = UDim.new(0, 4)
        Padding.Parent = TabContainer

        local UIList = Instance.new("UIListLayout")
        UIList.Padding = UDim.new(0, 6)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Parent = TabContainer

        UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
        end)

        local function SetActive()
            if CurrentTab == TabContainer then return end
            if CurrentTab then CurrentTab.Visible = false end
            if CurrentTabBtn then
                TweenService:Create(CurrentTabBtn, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Sidebar}):Play()
                if CurrentIcon then TweenService:Create(CurrentIcon, TweenInfo.new(0.18), {TextColor3 = Theme.GreyText}):Play() end
                if CurrentLabel then TweenService:Create(CurrentLabel, TweenInfo.new(0.18), {TextColor3 = Theme.GreyText}):Play() end
                if CurrentIndicator then TweenService:Create(CurrentIndicator, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play() end
            end
            CurrentTab = TabContainer
            CurrentTabBtn = TabBtn
            CurrentIcon = IconLbl
            CurrentLabel = Label
            CurrentIndicator = Indicator
            TabContainer.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Panel}):Play()
            TweenService:Create(IconLbl, TweenInfo.new(0.18), {TextColor3 = Theme.Accent}):Play()
            TweenService:Create(Label, TweenInfo.new(0.18), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
        end

        if TabCount == 0 then SetActive() end
        TabBtn.MouseButton1Click:Connect(SetActive)
        TabBtn.MouseEnter:Connect(function()
            if CurrentTab ~= TabContainer then
                TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Panel}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.SubText}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if CurrentTab ~= TabContainer then
                TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Sidebar}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.GreyText}):Play()
            end
        end)
        TabCount = TabCount + 1
        return TabContainer
    end

    function Window:CreateSection(name, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 26)
        Frame.BackgroundTransparency = 1
        Frame.Parent = parent

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 14)
        Label.Position = UDim2.new(0, 0, 0, 6)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 11
        Label.TextColor3 = Theme.Accent
        Label.Text = string.upper(name)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Underline = Instance.new("Frame")
        Underline.Size = UDim2.new(1, 0, 0, 1)
        Underline.Position = UDim2.new(0, 0, 0, 22)
        Underline.BackgroundColor3 = Theme.Stroke
        Underline.BorderSizePixel = 0
        Underline.Parent = Frame
    end

    function Window:CreateToggle(name, parent, default, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundTransparency = 1
        Frame.Parent = parent

        local Text = Instance.new("TextLabel")
        Text.Text = name
        Text.Size = UDim2.new(1, -50, 1, 0)
        Text.TextColor3 = Theme.Text
        Text.Font = Enum.Font.Gotham
        Text.TextSize = 13
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.BackgroundTransparency = 1
        Text.Parent = Frame

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 34, 0, 18)
        Box.Position = UDim2.new(1, -40, 0.5, -9)
        Box.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(42, 42, 42)
        Box.BorderSizePixel = 0
        Box.Parent = Frame
        addCorner(Box, 9)
        local BoxStroke = addStroke(Box, Theme.Stroke, 1)
        BoxStroke.Transparency = default and 0.3 or 0
        BoxStroke.Color = default and Theme.Accent or Theme.Stroke

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Circle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        Circle.BorderSizePixel = 0
        Circle.Parent = Box
        addCorner(Circle, 7)

        local on = default and true or false

        local function apply(value)
            on = value
            TweenService:Create(Circle, TweenInfo.new(0.18), {Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            TweenService:Create(Box, TweenInfo.new(0.18), {BackgroundColor3 = on and Theme.Accent or Color3.fromRGB(42, 42, 42)}):Play()
            TweenService:Create(BoxStroke, TweenInfo.new(0.18), {Color = on and Theme.Accent or Theme.Stroke, Transparency = on and 0.3 or 0}):Play()
        end

        Frame.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            apply(not on)
            callback(on)
        end)
        Frame.MouseEnter:Connect(function() TweenService:Create(Circle, TweenInfo.new(0.15), {Size = UDim2.new(0, 15, 0, 15)}):Play() end)
        Frame.MouseLeave:Connect(function() TweenService:Create(Circle, TweenInfo.new(0.15), {Size = UDim2.new(0, 14, 0, 14)}):Play() end)

        return {
            Frame = Frame,
            SetValue = function(v) if v ~= on then apply(v) callback(on) end end,
            GetValue = function() return on end,
        }
    end

    function Window:CreateSlider(name, parent, minValue, maxValue, step, default, suffix, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 50)
        Frame.BackgroundTransparency = 1
        Frame.Parent = parent

        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, -110, 0, 16)
        Text.BackgroundTransparency = 1
        Text.Font = Enum.Font.Gotham
        Text.TextColor3 = Theme.Text
        Text.TextSize = 13
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.Text = name
        Text.Parent = Frame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 100, 0, 16)
        ValueLabel.Position = UDim2.new(1, -100, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamSemibold
        ValueLabel.TextColor3 = Theme.Text
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Frame

        local BarButton = Instance.new("TextButton")
        BarButton.Size = UDim2.new(1, 0, 0, 6)
        BarButton.Position = UDim2.new(0, 0, 0, 30)
        BarButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
        BarButton.Text = ""
        BarButton.AutoButtonColor = false
        BarButton.BorderSizePixel = 0
        BarButton.Parent = Frame
        addCorner(BarButton, 3)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = BarButton
        addCorner(Fill, 3)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.AccentDim), ColorSequenceKeypoint.new(1, Theme.Accent)})
        Gradient.Parent = Fill

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 12, 0, 12)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(0, 0, 0.5, 0)
        Knob.BackgroundColor3 = Theme.Accent
        Knob.BorderSizePixel = 0
        Knob.Parent = BarButton
        addCorner(Knob, 6)
        addStroke(Knob, Color3.fromRGB(240, 240, 240), 1)

        local value = math.clamp(default, minValue, maxValue)
        local draggingSlider = false

        local function snap(n)
            return math.clamp(minValue + math.floor(((n - minValue) / step) + 0.5) * step, minValue, maxValue)
        end

        local function redraw()
            local alpha = (value - minValue) / (maxValue - minValue)
            Fill.Size = UDim2.new(alpha, 0, 1, 0)
            Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            ValueLabel.Text = string.format("%g%s", value, suffix or "")
        end

        local function setFromX(x)
            local px = x - BarButton.AbsolutePosition.X
            local alpha = math.clamp(px / math.max(BarButton.AbsoluteSize.X, 1), 0, 1)
            value = snap(minValue + ((maxValue - minValue) * alpha))
            redraw()
            callback(value)
        end

        redraw()

        BarButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true setFromX(input.Position.X) end
        end)
        TrackConnection(UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end
        end))
        TrackConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
        end))

        return {
            Frame = Frame,
            SetValue = function(v) value = math.clamp(snap(v), minValue, maxValue) redraw() callback(value) end,
            GetValue = function() return value end,
        }
    end

    function Window:CreateButton(name, parent, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = Theme.Panel
        Button.Text = name
        Button.TextColor3 = Theme.Text
        Button.TextSize = 13
        Button.Font = Enum.Font.GothamSemibold
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = false
        Button.Parent = parent
        addCorner(Button, 6)
        local Stroke = addStroke(Button, Theme.Stroke, 1)

        Button.MouseButton1Click:Connect(callback)
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.18), {BackgroundColor3 = Theme.PanelAlt}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.18), {Color = Theme.Accent}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Panel}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.18), {Color = Theme.Stroke}):Play()
        end)
    end

    function Window:CreateInput(name, parent, placeholder, numeric, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 54)
        Frame.BackgroundTransparency = 1
        Frame.Parent = parent

        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, 0, 0, 16)
        Text.BackgroundTransparency = 1
        Text.Font = Enum.Font.Gotham
        Text.TextColor3 = Theme.Text
        Text.TextSize = 13
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.Text = name
        Text.Parent = Frame

        local InputBg = Instance.new("Frame")
        InputBg.Size = UDim2.new(1, 0, 0, 30)
        InputBg.Position = UDim2.new(0, 0, 0, 20)
        InputBg.BackgroundColor3 = Theme.Panel
        InputBg.BorderSizePixel = 0
        InputBg.Parent = Frame
        addCorner(InputBg, 6)
        local InputStroke = addStroke(InputBg, Theme.Stroke)

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -16, 1, 0)
        Box.Position = UDim2.new(0, 8, 0, 0)
        Box.BackgroundTransparency = 1
        Box.Font = Enum.Font.GothamSemibold
        Box.TextSize = 12
        Box.TextColor3 = Theme.Text
        Box.PlaceholderText = placeholder or ""
        Box.PlaceholderColor3 = Theme.GreyText
        Box.Text = ""
        Box.ClearTextOnFocus = false
        Box.Parent = InputBg

        Box.Focused:Connect(function()
            TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
        end)
        Box.FocusLost:Connect(function()
            TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Theme.Stroke}):Play()
            local val = Box.Text
            if numeric then
                val = tonumber(val)
                if val == nil then return end
            end
            callback(val)
        end)

        return {
            Frame = Frame,
            SetValue = function(v) Box.Text = tostring(v) end,
            GetValue = function() return Box.Text end,
        }
    end

    function Window:CreateDropdown(name, parent, options, defaultIndex, callback)
        local itemH = 26
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 54)
        Frame.BackgroundTransparency = 1
        Frame.ClipsDescendants = false
        Frame.Parent = parent

        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, 0, 0, 16)
        Text.BackgroundTransparency = 1
        Text.Font = Enum.Font.Gotham
        Text.TextColor3 = Theme.Text
        Text.TextSize = 13
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.Text = name
        Text.Parent = Frame

        local selected = options[defaultIndex] or options[1]
        local isOpen = false

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.Position = UDim2.new(0, 0, 0, 20)
        Btn.BackgroundColor3 = Theme.Panel
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = false
        Btn.Text = selected
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextColor3 = Theme.Text
        Btn.TextSize = 12
        Btn.Parent = Frame
        addCorner(Btn, 6)
        local BtnStroke = addStroke(Btn, Theme.Stroke)

        local List = Instance.new("Frame")
        List.Size = UDim2.new(1, 0, 0, #options * itemH)
        List.Position = UDim2.new(0, 0, 0, 54)
        List.BackgroundColor3 = Theme.PanelAlt
        List.BorderSizePixel = 0
        List.ZIndex = 5
        List.Visible = false
        List.Parent = Frame
        addCorner(List, 6)
        addStroke(List, Theme.Accent)

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = List

        local optBtns = {}
        for i, opt in ipairs(options) do
            local OBtn = Instance.new("TextButton")
            OBtn.Size = UDim2.new(1, 0, 0, itemH)
            OBtn.BackgroundTransparency = 1
            OBtn.BorderSizePixel = 0
            OBtn.AutoButtonColor = false
            OBtn.Text = opt
            OBtn.Font = Enum.Font.Gotham
            OBtn.TextColor3 = opt == selected and Theme.Accent or Theme.SubText
            OBtn.TextSize = 12
            OBtn.ZIndex = 6
            OBtn.LayoutOrder = i
            OBtn.Parent = List
            optBtns[i] = OBtn

            OBtn.MouseButton1Click:Connect(function()
                selected = opt
                Btn.Text = opt .. "  ▾"
                isOpen = false
                Frame.Size = UDim2.new(1, 0, 0, 54)
                List.Visible = false
                for _, b in ipairs(optBtns) do
                    b.TextColor3 = b.Text == selected and Theme.Accent or Theme.SubText
                end
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Theme.Stroke}):Play()
                callback(opt)
            end)
        end

        Btn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            List.Visible = isOpen
            if isOpen then
                Frame.Size = UDim2.new(1, 0, 0, 54 + #options * itemH + 4)
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
            else
                Frame.Size = UDim2.new(1, 0, 0, 54)
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Theme.Stroke}):Play()
            end
        end)

        return {
            Frame = Frame,
            SetValue = function(v)
                selected = v
                Btn.Text = v .. "  ▾"
                for _, b in ipairs(optBtns) do b.TextColor3 = b.Text == selected and Theme.Accent or Theme.SubText end
                callback(v)
            end,
            GetValue = function() return selected end,
        }
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

-- ==================== Feature State ====================
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Speed
local WalkSpeedConns = { wsLoop = nil, wsCA = nil }
local CFrameSpeedConn = nil
local SelectedSpeedMethod = "Disabled"
local LastSpeedValue = 0

local function applySpeedBoost(Character, Value, Method)
    local Human = Character:FindFirstChildOfClass("Humanoid")
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not Human or not HRP then return end
    if WalkSpeedConns.wsLoop then WalkSpeedConns.wsLoop:Disconnect() end
    if WalkSpeedConns.wsCA then WalkSpeedConns.wsCA:Disconnect() end
    if CFrameSpeedConn then CFrameSpeedConn:Disconnect() end

    if Method == "CFrame Speed" then
        CFrameSpeedConn = RunService.Heartbeat:Connect(function()
            if Character and HRP and Human.MoveDirection.Magnitude > 0 then
                HRP.CFrame = HRP.CFrame + Human.MoveDirection * Value / 50
            end
        end)
    elseif Method == "Velocity Speed" then
        CFrameSpeedConn = RunService.Heartbeat:Connect(function()
            if Character and HRP and Human.MoveDirection.Magnitude > 0 then
                local d = Human.MoveDirection * Value
                HRP.Velocity = Vector3.new(d.X, HRP.Velocity.Y, d.Z)
            end
        end)
    elseif Method == "Loop WalkSpeed" then
        local function WalkSpeedChange()
            if Character and Human then Human.WalkSpeed = Value end
        end
        WalkSpeedChange()
        WalkSpeedConns.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
        WalkSpeedConns.wsCA = LocalPlayer.CharacterAdded:Connect(function(nChar)
            local NH = nChar:WaitForChild("Humanoid")
            Character, Human = nChar, NH
            WalkSpeedChange()
            WalkSpeedConns.wsLoop = (WalkSpeedConns.wsLoop and WalkSpeedConns.wsLoop:Disconnect() and false)
                or NH:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
        end)
    end
end

-- Jump
local JumpBoostConns = { jpLoop = nil, jpCA = nil }
local SelectedJumpMethod = "Disabled"
local LastJumpValue = 0

local function applyJumpBoost(Character, Value, Method)
    local Human = Character:FindFirstChildOfClass("Humanoid")
    if not Human then return end
    if JumpBoostConns.jpLoop then JumpBoostConns.jpLoop:Disconnect() end
    if JumpBoostConns.jpCA then JumpBoostConns.jpCA:Disconnect() end
    if Method == "Disabled" then return end

    local function JumpChange()
        if Human then Human.UseJumpPower = true Human.JumpPower = Value end
    end
    JumpChange()
    JumpBoostConns.jpLoop = Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpChange)
    JumpBoostConns.jpCA = LocalPlayer.CharacterAdded:Connect(function(newChar)
        local NH = newChar:WaitForChild("Humanoid")
        Character, Human = newChar, NH
        JumpChange()
        JumpBoostConns.jpLoop = (JumpBoostConns.jpLoop and JumpBoostConns.jpLoop:Disconnect() and false)
            or NH:GetPropertyChangedSignal("JumpPower"):Connect(JumpChange)
    end)
end

-- Infinite Jump
local InfiniteJumpConn = nil
local function toggleInfiniteJump(state)
    if state then
        InfiniteJumpConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Touch
            or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space) then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end
        end)
    else
        if InfiniteJumpConn then InfiniteJumpConn:Disconnect() InfiniteJumpConn = nil end
    end
end

-- Fly
local FLY_ENABLED = false
local FLY_SPEED = 100
local flyConns = {}
local flyControl = { Forward=0, Backward=0, Left=0, Right=0, Up=0, Down=0 }

local function stopFlying()
    FLY_ENABLED = false
    for _, c in ipairs(flyConns) do c:Disconnect() end
    flyConns = {}
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then obj:Destroy() end
            end
        end
    end
end

local function startFlying()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hrp then return end
    stopFlying()

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.cframe = hrp.CFrame
    bodyGyro.Parent = hrp

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.velocity = Vector3.new(0,0,0)
    bodyVelocity.maxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp

    FLY_ENABLED = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    table.insert(flyConns, RunService.Heartbeat:Connect(function()
        if not FLY_ENABLED then return end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(flyControl.Right-flyControl.Left, flyControl.Up-flyControl.Down, flyControl.Forward-flyControl.Backward)
        if dir.Magnitude > 0 then
            local move = (cam.CFrame.LookVector * dir.Z) + (cam.CFrame.RightVector * dir.X) + (Vector3.new(0,1,0) * dir.Y)
            bodyVelocity.velocity = move * FLY_SPEED
        else
            bodyVelocity.velocity = Vector3.new(0,0,0)
        end
        bodyGyro.cframe = cam.CFrame
    end))
    table.insert(flyConns, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local k = input.KeyCode.Name:lower()
        if k=="w" then flyControl.Forward=1 elseif k=="s" then flyControl.Backward=1
        elseif k=="a" then flyControl.Left=1 elseif k=="d" then flyControl.Right=1
        elseif k=="e" then flyControl.Up=1 elseif k=="q" then flyControl.Down=1 end
    end))
    table.insert(flyConns, UserInputService.InputEnded:Connect(function(input)
        local k = input.KeyCode.Name:lower()
        if k=="w" then flyControl.Forward=0 elseif k=="s" then flyControl.Backward=0
        elseif k=="a" then flyControl.Left=0 elseif k=="d" then flyControl.Right=0
        elseif k=="e" then flyControl.Up=0 elseif k=="q" then flyControl.Down=0 end
    end))
end

-- Dash system
local dashConfigs = {
    front = { animationId="rbxassetid://10479335397", speed=100, duration=0.60, maxForce=1e8, pValue=1e8, obstacleDistance=6, enabled=false, direction=function(hrp) return hrp.CFrame.LookVector end },
    left  = { animationId="rbxassetid://10480796021", speed=150, duration=0.25, maxForce=1e8, pValue=1e8, enabled=false, direction=function(hrp) return -hrp.CFrame.RightVector end },
    right = { animationId="rbxassetid://10480793962", speed=150, duration=0.25, maxForce=1e8, pValue=1e8, enabled=false, direction=function(hrp) return hrp.CFrame.RightVector end },
    back  = { animationId="rbxassetid://10491993682", speed=100, duration=0.5, enabled=false, direction=function(hrp) return -hrp.CFrame.LookVector end, requiresExistingBV=true }
}

local dashConnections = {}
local activeDashes = {}

local function dashCleanup()
    for _, conn in pairs(dashConnections) do if conn and conn.Connected then conn:Disconnect() end end
    dashConnections = {}
    activeDashes = {}
end

local function findBV(hrp)
    for _, child in pairs(hrp:GetChildren()) do if child:IsA("BodyVelocity") then return child end end
end

local function applyDash(hrp, dashType, animTrack)
    local config = dashConfigs[dashType]
    local bv = findBV(hrp)
    local finalSpeed = config.speed

    if dashType == "front" then
        if bv then finalSpeed = bv.Velocity.Magnitude * config.speed
        else bv = Instance.new("BodyVelocity") bv.MaxForce = Vector3.new(config.maxForce, 0, config.maxForce) bv.P = config.pValue bv.Parent = hrp end
    elseif dashType == "left" or dashType == "right" then
        if not bv then bv = Instance.new("BodyVelocity") bv.MaxForce = Vector3.new(config.maxForce, 0, config.maxForce) bv.P = config.pValue bv.Parent = hrp end
    elseif dashType == "back" and config.requiresExistingBV then
        if not bv then return end
    end
    if not bv then return end

    local stopped = false
    local dashId = dashType .. "_" .. tick()
    activeDashes[dashId] = true

    local rayParams
    if dashType == "front" then
        rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    end

    local function stopDash(conn)
        if stopped then return end
        if bv and bv.Parent and dashType ~= "back" then bv:Destroy()
        elseif bv and dashType == "back" then bv.Velocity = Vector3.zero end
        if conn and conn.Connected then conn:Disconnect() end
        activeDashes[dashId] = nil
        stopped = true
    end

    local animStoppedConn
    if animTrack then animStoppedConn = animTrack.Stopped:Connect(function() stopDash(animStoppedConn) end) end

    local hbConn
    hbConn = RunService.Heartbeat:Connect(function()
        if not bv or not bv.Parent or stopped or not config.enabled then stopDash(hbConn) return end
        if animTrack and not animTrack.IsPlaying then stopDash(hbConn) return end
        if dashType == "front" and rayParams then
            local result = Workspace:Raycast(hrp.Position, config.direction(hrp) * config.obstacleDistance, rayParams)
            if result and result.Instance then stopDash(hbConn) return end
        end
        bv.Velocity = config.direction(hrp) * finalSpeed
    end)

    task.delay(config.duration, function()
        if not stopped then stopDash(hbConn) if animStoppedConn and animStoppedConn.Connected then animStoppedConn:Disconnect() end end
    end)
end

local function setupDashCharacter()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid")
    dashConnections[#dashConnections+1] = humanoid.AnimationPlayed:Connect(function(track)
        local animId = track.Animation.AnimationId
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for dashType, config in pairs(dashConfigs) do
            if config.enabled and animId == config.animationId then applyDash(hrp, dashType, track) break end
        end
    end)
end

local function initDash()
    dashCleanup()
    if LocalPlayer.Character then setupDashCharacter() end
    dashConnections[#dashConnections+1] = LocalPlayer.CharacterAdded:Connect(function()
        dashCleanup()
        task.wait(0.1)
        setupDashCharacter()
    end)
end
initDash()

-- Status removal helpers
local function makeStatusRemover(attrName)
    local conn = nil
    return function(state)
        if state then
            conn = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local v = char:FindFirstChild(attrName)
                    if v then v:Destroy() end
                end
            end)
        else
            if conn then conn:Disconnect() conn = nil end
        end
    end
end

local toggleNoRagdoll   = makeStatusRemover("Ragdoll")
local toggleNoFreeze    = makeStatusRemover("Freeze")
local toggleNoJump      = makeStatusRemover("NoJump")
local toggleNoSlow      = makeStatusRemover("Slowed")

local NoStunConn = nil
local function toggleNoStun(state)
    if state then
        NoStunConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, name in ipairs({"ComboStun", "StopRunning"}) do
                    local v = char:FindFirstChild(name)
                    if v then v:Destroy() end
                end
            end
        end)
    else
        if NoStunConn then NoStunConn:Disconnect() NoStunConn = nil end
    end
end

local noBlockConn1, noBlockConn2 = nil, nil
local function toggleNoBlock(state)
    if state then
        local function setupBlockWatcher(char)
            local function reset() if char:GetAttribute("Blocking") == true then char:SetAttribute("Blocking", false) end end
            reset()
            noBlockConn1 = char:GetAttributeChangedSignal("Blocking"):Connect(reset)
        end
        if LocalPlayer.Character then setupBlockWatcher(LocalPlayer.Character) end
        noBlockConn2 = LocalPlayer.CharacterAdded:Connect(function(char) setupBlockWatcher(char) end)
    else
        if noBlockConn1 then noBlockConn1:Disconnect() noBlockConn1 = nil end
        if noBlockConn2 then noBlockConn2:Disconnect() noBlockConn2 = nil end
    end
end

-- Invisible Moves
local invisMoves = {
    { name="No Block Animation",    id="rbxassetid://10470389827" },
    { name="Prey's Peril",          id="rbxassetid://12351854556" },
    { name="Omni Directional Punch",id="rbxassetid://13927612951" },
    { name="Serious Punch",         id="rbxassetid://12983333733" },
    { name="Table Flip",            id="rbxassetid://11365563255" },
    { name="Hold Trashcan",         id="rbxassetid://13813448561" },
}
local invisStates = {}
local invisConns  = {}

for i, move in ipairs(invisMoves) do
    invisStates[i] = false
    invisConns[i]  = nil
end

local function setupInvisMove(moveIndex, char)
    if invisConns[moveIndex] then invisConns[moveIndex]:Disconnect() end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not invisStates[moveIndex] then return end
    local animId = invisMoves[moveIndex].id
    invisConns[moveIndex] = hum.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId == animId then track:Stop() end
    end)
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    for i = 1, #invisMoves do setupInvisMove(i, char) end
end))

local function makeInvisToggle(i)
    return function(state)
        invisStates[i] = state
        local char = LocalPlayer.Character
        if state then
            setupInvisMove(i, char)
        else
            if invisConns[i] then invisConns[i]:Disconnect() invisConns[i] = nil end
        end
    end
end

-- M1 Catch
local m1CatchZone = Instance.new("Part")
m1CatchZone.Size = Vector3.new(20, 20, 20)
m1CatchZone.Transparency = 1
m1CatchZone.Anchored = true
m1CatchZone.CanCollide = false
m1CatchZone.Name = "ArmouredM1Zone"
m1CatchZone.Parent = Workspace

local m1SystemEnabled = false
local m1PlayersInZone = {}
local m1IsMonitoring = false

TrackConnection(RunService.Heartbeat:Connect(function()
    if not m1SystemEnabled then return end
    local hrp = getHRP()
    if hrp then m1CatchZone.Position = hrp.Position end

    local newList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if phrp then
                local dist = (phrp.Position - m1CatchZone.Position).Magnitude
                if dist <= m1CatchZone.Size.X / 2 then
                    table.insert(newList, plr)
                end
            end
        end
    end
    m1PlayersInZone = newList
    m1IsMonitoring = #newList > 0

    if m1IsMonitoring then
        local localHRP = getHRP()
        if not localHRP then return end
        local closest, closestDist = nil, math.huge
        for _, plr in ipairs(m1PlayersInZone) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (plr.Character.HumanoidRootPart.Position - localHRP.Position).Magnitude
                if d < closestDist then closestDist = d closest = plr end
            end
        end
        if closest then
            local char = LocalPlayer.Character
            local m1ing = char and char:FindFirstChild("M1ing")
            if m1ing and closest.Character then
                local tHRP = closest.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    local offset = tHRP.CFrame.LookVector * -3
                    localHRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
                end
            end
        end
    end
end))

-- Auto Block
local abEnabled = false
local abZone = nil
local abZoneSize = 20
local abZoneTransp = 0.5
local abHeartbeat = nil
local abFollow = nil
local abPressed = {}
local abCharConn = nil

local function abCreateZone()
    abZone = Instance.new("Part")
    abZone.Size = Vector3.new(abZoneSize, abZoneSize, abZoneSize)
    abZone.Transparency = abZoneTransp
    abZone.Anchored = true
    abZone.CanCollide = false
    abZone.Name = "ArmouredShieldZone"
    abZone.Parent = Workspace
end

local function abStopConns()
    if abHeartbeat then abHeartbeat:Disconnect() abHeartbeat = nil end
    if abFollow then abFollow:Disconnect() abFollow = nil end
    for plr, _ in pairs(abPressed) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Communicate") then
            char:FindFirstChild("Communicate"):FireServer({{Goal="KeyRelease", Key=Enum.KeyCode.F}})
        end
    end
    abPressed = {}
end

local function abStartSystem()
    abStopConns()
    if not abZone then abCreateZone() end
    abFollow = RunService.Heartbeat:Connect(function()
        if abZone and LocalPlayer.Character then
            local hrp = getHRP()
            if hrp then abZone.Position = hrp.Position end
        end
    end)
    abHeartbeat = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Communicate") then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local inZone = phrp and abZone and (phrp.Position - abZone.Position).Magnitude <= abZone.Size.X / 2
                local hasM1ing = plr.Character:FindFirstChild("M1ing")
                if inZone then
                    if hasM1ing and not abPressed[plr] then
                        abPressed[plr] = true
                        char:FindFirstChild("Communicate"):FireServer({{Goal="KeyPress", Key=Enum.KeyCode.F}})
                    end
                    if not hasM1ing and abPressed[plr] then
                        abPressed[plr] = nil
                        char:FindFirstChild("Communicate"):FireServer({{Goal="KeyRelease", Key=Enum.KeyCode.F}})
                    end
                else
                    if abPressed[plr] then
                        abPressed[plr] = nil
                        char:FindFirstChild("Communicate"):FireServer({{Goal="KeyRelease", Key=Enum.KeyCode.F}})
                    end
                end
            end
        end
    end)
end

local function abStopSystem()
    abStopConns()
    if abCharConn then abCharConn:Disconnect() abCharConn = nil end
    if abZone then abZone:Destroy() abZone = nil end
end

abCharConn = LocalPlayer.CharacterAdded:Connect(function()
    if abEnabled then
        task.wait(1)
        if abZone then
            local hrp = getHRP()
            if hrp then abZone.Position = hrp.Position end
            abStopConns()
            abStartSystem()
        else
            abStartSystem()
        end
    end
end)

-- Extra Damage
local edToggleActive = false
local edReturnToOriginal = true
local edTeleportDistance = 100
local edAnimConn = nil
local edCharConn = nil
local edOriginalPos = nil
local edAnimId = "rbxassetid://12296113986"

local function setupExtraDamage(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    if edAnimConn then edAnimConn:Disconnect() end
    if not edToggleActive then return end
    edAnimConn = humanoid.AnimationPlayed:Connect(function(track)
        if edToggleActive and track.Animation.AnimationId == edAnimId then
            edOriginalPos = hrp.CFrame
            task.wait(1)
            hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + edTeleportDistance, hrp.Position.Z)
            local sc
            sc = track.Stopped:Connect(function()
                if edOriginalPos and edReturnToOriginal then hrp.CFrame = edOriginalPos end
                edOriginalPos = nil
                sc:Disconnect()
            end)
        end
    end)
end

setupExtraDamage(LocalPlayer.Character)
edCharConn = LocalPlayer.CharacterAdded:Connect(setupExtraDamage)

-- Skill Teleport
local stToggleActive = false
local stReturnToOriginal = false
local stAnimConn2 = nil
local stCharConn = nil
local stOriginalPos = nil
local stSelectedLocation = "Void"
local stLocations = {
    ["Void"]               = CFrame.new(0, -492, 0),
    ["Atomic Room"]        = CFrame.new(1079, 155, 23003),
    ["Death Counter Room"] = CFrame.new(-92, 29, 20347),
    ["Baseplate"]          = CFrame.new(968, 20, 23088),
    ["Middle of Map"]      = CFrame.new(148, 441, 27),
    ["Mountain 1"]         = CFrame.new(266, 699, 458),
    ["Mountain 2"]         = CFrame.new(551, 630, -265),
    ["Mountain 3"]         = CFrame.new(-107, 642, -328),
}
local stTargetPos = stLocations["Void"]
local stAnimIds = { "rbxassetid://12296113986", "rbxassetid://12273188754" }

local function setupSkillTP(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    if stAnimConn2 then stAnimConn2:Disconnect() end
    if not stToggleActive then return end
    stAnimConn2 = humanoid.AnimationPlayed:Connect(function(track)
        if not stToggleActive then return end
        for _, id in ipairs(stAnimIds) do
            if track.Animation.AnimationId == id then
                if stReturnToOriginal then stOriginalPos = hrp.CFrame end
                task.wait(1)
                hrp.CFrame = stTargetPos
                if stReturnToOriginal then
                    local sc
                    sc = track.Stopped:Connect(function()
                        if stOriginalPos then hrp.CFrame = stOriginalPos stOriginalPos = nil end
                        sc:Disconnect()
                    end)
                end
                break
            end
        end
    end)
end

setupSkillTP(LocalPlayer.Character)
stCharConn = LocalPlayer.CharacterAdded:Connect(setupSkillTP)

-- Saved position
local savedPosition = Vector3.new(0, 0, 0)

-- Walk/Run animation replacement
local walkBlockedAnims = {}
local walkCurrentAnimId = nil
local walkCurrentTrack = nil
local walkHumanoid, walkRootPart

local function updateWalkAnim(newId)
    walkCurrentAnimId = newId
    if walkCurrentTrack then walkCurrentTrack:Stop() walkCurrentTrack = nil end
    if walkHumanoid and newId then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(newId)
        walkCurrentTrack = walkHumanoid:LoadAnimation(anim)
    end
end

local function setupWalkChar(char)
    walkHumanoid = char:WaitForChild("Humanoid")
    walkRootPart = char:WaitForChild("HumanoidRootPart")
    if walkCurrentAnimId then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(walkCurrentAnimId)
        walkCurrentTrack = walkHumanoid:LoadAnimation(anim)
    end
    walkHumanoid.AnimationPlayed:Connect(function(track)
        if walkBlockedAnims[track.Animation.AnimationId] then
            track:Stop()
            if walkRootPart.Velocity.Magnitude > 1 and walkCurrentTrack and not walkCurrentTrack.IsPlaying then
                walkCurrentTrack.Looped = true
                walkCurrentTrack:Play()
            end
        end
    end)
end

TrackConnection(RunService.RenderStepped:Connect(function()
    if walkCurrentTrack and walkCurrentTrack.IsPlaying and walkRootPart and walkRootPart.Velocity.Magnitude <= 1 then
        walkCurrentTrack:Stop()
    end
end))

LocalPlayer.CharacterAdded:Connect(setupWalkChar)
if LocalPlayer.Character then setupWalkChar(LocalPlayer.Character) end

-- Idle animation
local idleAnimId = nil
local idleAnimTrack = nil
local idleHumanoid, idleAnimator

local function playIdleAnim(id)
    if idleAnimTrack then idleAnimTrack:Stop() end
    if not idleAnimator or not id or id == "rbxassetid://0" then idleAnimId = nil return end
    idleAnimId = id
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    idleAnimTrack = idleAnimator:LoadAnimation(anim)
    idleAnimTrack:Play()
end

local function setupIdleChar(char)
    idleHumanoid = char:WaitForChild("Humanoid")
    idleAnimator = idleHumanoid:FindFirstChildOfClass("Animator") or idleHumanoid:WaitForChild("Animator")
    idleAnimTrack = nil
end

LocalPlayer.CharacterAdded:Connect(setupIdleChar)
if LocalPlayer.Character then setupIdleChar(LocalPlayer.Character) end

task.spawn(function()
    while true do
        if idleHumanoid and idleAnimId then
            local moving = idleHumanoid.MoveDirection.Magnitude > 0
            if not moving then
                if not idleAnimTrack or not idleAnimTrack.IsPlaying then
                    if idleAnimator then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = idleAnimId
                        idleAnimTrack = idleAnimator:LoadAnimation(anim)
                        idleAnimTrack:Play()
                    end
                end
            else
                if idleAnimTrack and idleAnimTrack.IsPlaying then idleAnimTrack:Stop() end
            end
        end
        task.wait(0.1)
    end
end)

-- M1 animation replacement
local m1OrigToReplace = {}
local m1SelectedCharType = "Fist"
local m1SelectedSet = nil
local m1Humanoid, m1RootPart

local m1AnimSets = {
    Fist         = {10469493270, 10469630950, 10469639222, 10469643643},
    Bat          = {14004222985, 13997092940, 14001963401, 14136436157},
    Ninjato      = {13370310513, 13390230973, 13378751717, 13378708199},
    Katana       = {15259161390, 15240216931, 15240176873, 15162694192},
    LightningFist= {89044067797964, 74334194837918, 94353845974131, 80601239139774},
    HunterFist   = {13532562418, 13532600125, 13532604085, 13294471966},
    CyborgFist   = {13491635433, 13296577783, 13295919399, 13295936866},
    EsperFist    = {16515503507, 16515520431, 16515448089, 16552234590},
    KJFist       = {17325510002, 17325513870, 17325522388, 17325537719},
    PurpleFist   = {17889458563, 17889461810, 17889471098, 17889290569},
}

local function setM1Replacement(setName)
    m1OrigToReplace = {}
    m1SelectedSet = setName
    if not setName then return end
    local originalSet = m1AnimSets[m1SelectedCharType]
    local newSet = m1AnimSets[setName]
    if not originalSet or not newSet then return end
    for i = 1, #originalSet do
        if newSet[i] then
            m1OrigToReplace["rbxassetid://" .. originalSet[i]] = "rbxassetid://" .. newSet[i]
        end
    end
end

local function setupM1Char(char)
    m1Humanoid = char:WaitForChild("Humanoid")
    m1RootPart = char:WaitForChild("HumanoidRootPart")
    local conn
    conn = m1Humanoid.AnimationPlayed:Connect(function(track)
        local rep = m1OrigToReplace[track.Animation.AnimationId]
        if rep then
            track:Stop()
            task.spawn(function()
                task.wait(0.1)
                local anim = Instance.new("Animation")
                anim.AnimationId = rep
                local newTrack = m1Humanoid:LoadAnimation(anim)
                newTrack:Play()
            end)
        end
    end)
    char.AncestryChanged:Connect(function() if not char.Parent then conn:Disconnect() end end)
    if m1SelectedSet then
        task.spawn(function()
            task.wait(1)
            setM1Replacement(m1SelectedSet)
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(setupM1Char)
if LocalPlayer.Character then setupM1Char(LocalPlayer.Character) end

-- Void Protection
local voidProtectionEnabled = false
local voidProtConn = nil

local function toggleVoidProtection(state)
    voidProtectionEnabled = state
    if state then
        local existing = Workspace:FindFirstChild("VoidProtection")
        if not existing then
            local part = Instance.new("Part")
            part.Size = Vector3.new(10000, 10, 10000)
            part.Position = Vector3.new(0, -500, 0)
            part.Anchored = true
            part.CanCollide = true
            part.Transparency = 0.5
            part.Color = Color3.fromRGB(255, 0, 0)
            part.Name = "VoidProtection"
            part.Parent = Workspace
        end
    else
        local existing = Workspace:FindFirstChild("VoidProtection")
        if existing then existing:Destroy() end
    end
end

-- ==================== Shutdown ====================
local Window

local function Shutdown()
    if Unloaded then return end
    Unloaded = true
    stopFlying()
    abStopSystem()
    toggleVoidProtection(false)
    if m1CatchZone then m1CatchZone:Destroy() end
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    Connections = {}
    if Window then pcall(function() Window:Destroy() end) end
    DestroyExistingUIs()
    if _G.ArmouredTSBShutdown == Shutdown then _G.ArmouredTSBShutdown = nil end
end

_G.ArmouredTSBShutdown = Shutdown

-- ==================== Build UI ====================
local function BuildUI()
    Window = Library:CreateWindow("ARMOURED :: STRONGEST BATTLEGROUNDS")

    local TabMovement   = Window:CreateTab("Movement",   "")
    local TabExploits   = Window:CreateTab("Exploits",   "")
    local TabCombat     = Window:CreateTab("Combat",     "")
    local TabTeleports  = Window:CreateTab("Teleports",  "")
    local TabAnimations = Window:CreateTab("Animations", "")
    local TabSettings   = Window:CreateTab("Settings",   "")

    -- ── Movement ──────────────────────────────────────────────────
    Window:CreateSection("CHARACTER", TabMovement)

    Window:CreateDropdown("Speed Method", TabMovement,
        {"Disabled", "CFrame Speed", "Velocity Speed", "Loop WalkSpeed"}, 1,
        function(val)
            SelectedSpeedMethod = val
            if WalkSpeedConns.wsLoop then WalkSpeedConns.wsLoop:Disconnect() end
            if WalkSpeedConns.wsCA  then WalkSpeedConns.wsCA:Disconnect()  end
            if CFrameSpeedConn      then CFrameSpeedConn:Disconnect()      end
            if val ~= "Disabled" and LocalPlayer.Character and LastSpeedValue ~= 0 then
                applySpeedBoost(LocalPlayer.Character, LastSpeedValue, val)
            end
        end)

    Window:CreateInput("Speed Value", TabMovement, "enter speed (e.g. 50)", true, function(val)
        LastSpeedValue = val
        if SelectedSpeedMethod ~= "Disabled" and LocalPlayer.Character then
            applySpeedBoost(LocalPlayer.Character, val, SelectedSpeedMethod)
        end
    end)

    Window:CreateDropdown("Jump Method", TabMovement,
        {"Disabled", "Loop JumpPower"}, 1,
        function(val)
            SelectedJumpMethod = val
            if JumpBoostConns.jpLoop then JumpBoostConns.jpLoop:Disconnect() JumpBoostConns.jpLoop = nil end
            if JumpBoostConns.jpCA  then JumpBoostConns.jpCA:Disconnect()  JumpBoostConns.jpCA  = nil end
            if val ~= "Disabled" and LocalPlayer.Character and LastJumpValue ~= 0 then
                applyJumpBoost(LocalPlayer.Character, LastJumpValue, val)
            end
        end)

    Window:CreateInput("Jump Value", TabMovement, "enter jump power (e.g. 100)", true, function(val)
        LastJumpValue = val
        if SelectedJumpMethod ~= "Disabled" and LocalPlayer.Character then
            applyJumpBoost(LocalPlayer.Character, val, SelectedJumpMethod)
        end
    end)

    Window:CreateToggle("Infinite Jump", TabMovement, false, toggleInfiniteJump)

    Window:CreateSection("FLY", TabMovement)
    Window:CreateToggle("Fly", TabMovement, false, function(state)
        if state then startFlying() else stopFlying() end
    end)
    Window:CreateSlider("Fly Speed", TabMovement, 10, 500, 10, 100, "", function(val) FLY_SPEED = val end)

    -- ── Exploits ──────────────────────────────────────────────────
    Window:CreateSection("EMOTES", TabExploits)
    Window:CreateToggle("Emote Search Bar", TabExploits, false, function(state)
        LocalPlayer:SetAttribute("EmoteSearchBar", state)
    end)
    Window:CreateToggle("Extra Slots", TabExploits, false, function(state)
        LocalPlayer:SetAttribute("ExtraSlots", state)
    end)

    Window:CreateSection("CUSTOM DASHES", TabExploits)
    Window:CreateInput("Front Dash Speed", TabExploits, "default: 100", true, function(val)
        dashConfigs.front.speed = val
    end)
    Window:CreateToggle("Custom Front Dash", TabExploits, false, function(state)
        dashConfigs.front.enabled = state
        if state and LocalPlayer.Character then setupDashCharacter() end
    end)
    Window:CreateInput("Side Dash Speed", TabExploits, "default: 150", true, function(val)
        dashConfigs.left.speed = val
        dashConfigs.right.speed = val
    end)
    Window:CreateToggle("Custom Side Dash", TabExploits, false, function(state)
        dashConfigs.left.enabled = state
        dashConfigs.right.enabled = state
        if state and LocalPlayer.Character then setupDashCharacter() end
    end)
    Window:CreateInput("Back Dash Speed", TabExploits, "default: 100", true, function(val)
        dashConfigs.back.speed = val
    end)
    Window:CreateToggle("Custom Back Dash", TabExploits, false, function(state)
        dashConfigs.back.enabled = state
        if state and LocalPlayer.Character then setupDashCharacter() end
    end)

    Window:CreateSection("STATUS REMOVAL", TabExploits)
    Window:CreateToggle("No Dash Cooldown", TabExploits, false, function(state)
        Workspace:SetAttribute("NoDashCooldown", state)
    end)
    Window:CreateToggle("No Fatigue", TabExploits, false, function(state)
        Workspace:SetAttribute("NoFatigue", state)
    end)
    Window:CreateToggle("No Ragdoll", TabExploits, false, toggleNoRagdoll)
    Window:CreateToggle("No Freeze", TabExploits, false, toggleNoFreeze)
    Window:CreateToggle("No Jump Bypass", TabExploits, false, toggleNoJump)
    Window:CreateToggle("No Slow", TabExploits, false, toggleNoSlow)
    Window:CreateToggle("No Stun", TabExploits, false, toggleNoStun)
    Window:CreateToggle("No Block Slowdown", TabExploits, false, toggleNoBlock)

    Window:CreateSection("INVISIBLE MOVES", TabExploits)
    for i, move in ipairs(invisMoves) do
        Window:CreateToggle(move.name, TabExploits, false, makeInvisToggle(i))
    end

    -- ── Combat ────────────────────────────────────────────────────
    Window:CreateSection("M1 CATCH", TabCombat)
    Window:CreateToggle("M1 Catch", TabCombat, false, function(state)
        m1SystemEnabled = state
        m1CatchZone.Transparency = state and 0.5 or 1
    end)
    Window:CreateSlider("Zone Size", TabCombat, 5, 100, 1, 20, "", function(val)
        m1CatchZone.Size = Vector3.new(val, val, val)
    end)
    Window:CreateSlider("Zone Transparency", TabCombat, 0, 1, 0.05, 0.5, "", function(val)
        if m1SystemEnabled then m1CatchZone.Transparency = val end
    end)

    Window:CreateSection("AUTO BLOCK (BETA)", TabCombat)
    Window:CreateSlider("AB Zone Size", TabCombat, 5, 50, 1, 20, "", function(val)
        abZoneSize = val
        if abZone then abZone.Size = Vector3.new(val, val, val) end
    end)
    Window:CreateSlider("AB Zone Transparency", TabCombat, 0, 1, 0.05, 0.5, "", function(val)
        abZoneTransp = val
        if abZone then
            abZone.Transparency = val
            for _, c in pairs(abZone:GetChildren()) do if c:IsA("Texture") then c.Transparency = val end end
        end
    end)
    Window:CreateToggle("Auto Block M1ing (re-enable after respawn)", TabCombat, false, function(state)
        abEnabled = state
        if state then abStartSystem() else abStopSystem() end
    end)

    Window:CreateSection("EXTRA DAMAGE", TabCombat)
    Window:CreateToggle("Extra Damage (Lethal Whirlwind Stream)", TabCombat, false, function(state)
        edToggleActive = state
        if state then setupExtraDamage(LocalPlayer.Character)
        else if edAnimConn then edAnimConn:Disconnect() edAnimConn = nil end end
    end)
    Window:CreateToggle("Return to Original Position", TabCombat, true, function(state)
        edReturnToOriginal = state
    end)
    Window:CreateSlider("Teleport Distance", TabCombat, 100, 1000, 50, 100, " studs", function(val)
        edTeleportDistance = val
    end)

    Window:CreateSection("SKILL BRING / TELEPORT", TabCombat)
    Window:CreateDropdown("Teleport Location", TabCombat,
        {"Void","Atomic Room","Death Counter Room","Baseplate","Middle of Map","Mountain 1","Mountain 2","Mountain 3"}, 1,
        function(val)
            stSelectedLocation = val
            stTargetPos = stLocations[val]
        end)
    Window:CreateToggle("Auto Teleport on Skill", TabCombat, false, function(state)
        stToggleActive = state
        if state then setupSkillTP(LocalPlayer.Character)
        else if stAnimConn2 then stAnimConn2:Disconnect() stAnimConn2 = nil end end
    end)
    Window:CreateToggle("TP Back After Skill", TabCombat, false, function(state)
        stReturnToOriginal = state
    end)

    -- ── Teleports ─────────────────────────────────────────────────
    Window:CreateSection("SAVED POSITION", TabTeleports)
    Window:CreateButton("Save Position", TabTeleports, function()
        local hrp = getHRP()
        if hrp then savedPosition = hrp.Position end
    end)
    Window:CreateButton("Teleport to Saved Position", TabTeleports, function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(savedPosition) end
    end)

    Window:CreateSection("LOCATIONS", TabTeleports)
    local tpLocations = {
        {"Atomic Room",        CFrame.new(1079, 155, 23003)},
        {"Death Counter Room", CFrame.new(-92, 29, 20347)},
        {"Void",               CFrame.new(0, -492, 0)},
        {"Baseplate",          CFrame.new(968, 20, 23088)},
        {"Middle of Map",      CFrame.new(148, 441, 27)},
        {"Mountain 1",         CFrame.new(266, 699, 458)},
        {"Mountain 2",         CFrame.new(551, 630, -265)},
        {"Mountain 3",         CFrame.new(-107, 642, -328)},
        {"Trap 1",             CFrame.new(378, 440, 448)},
        {"Trap 2",             CFrame.new(287, 440, 481)},
        {"Corner 1",           CFrame.new(-226, 440, -415)},
        {"Corner 2",           CFrame.new(526, 440, 481)},
    }
    for _, loc in ipairs(tpLocations) do
        local locName, locCFrame = loc[1], loc[2]
        Window:CreateButton(locName, TabTeleports, function()
            local hrp = getHRP()
            if hrp then hrp.CFrame = locCFrame end
        end)
    end

    -- ── Animations ────────────────────────────────────────────────
    Window:CreateSection("WALK / RUN", TabAnimations)
    Window:CreateButton("Default Walk", TabAnimations, function()
        walkBlockedAnims["rbxassetid://7815618175"] = nil
        walkBlockedAnims["rbxassetid://7807831448"] = nil
        updateWalkAnim(nil)
    end)
    local walkAnims = {
        {"Helicopter", 17862998594}, {"Hunter", 15962326593}, {"March", 15962443652},
        {"Gojo",       18897115785}, {"wtf",   17122254184}, {"Girl",  17861862787},
        {"Girl 2",     17861893094}, {"Sword", 17120635926}, {"Runner", 18897724289},
        {"Runner 2",   95575238948327},
    }
    for _, a in ipairs(walkAnims) do
        local aName, aId = a[1], a[2]
        Window:CreateButton(aName, TabAnimations, function()
            walkBlockedAnims["rbxassetid://7815618175"] = true
            walkBlockedAnims["rbxassetid://7807831448"] = true
            updateWalkAnim(aId)
        end)
    end

    Window:CreateSection("IDLE", TabAnimations)
    Window:CreateButton("Default Idle", TabAnimations, function() playIdleAnim("rbxassetid://0") end)
    local idleAnims = {
        {"Fly",                  "rbxassetid://17124061663"}, {"Fly 2",             "rbxassetid://18897538537"},
        {"Fly 3",                "rbxassetid://14840458512"}, {"Unknown",           "rbxassetid://18897713456"},
        {"Watch",                "rbxassetid://18897733312"}, {"Confident",         "rbxassetid://17109012516"},
        {"Aka Stance",           "rbxassetid://118383042869348"}, {"Ao Stance",    "rbxassetid://113201609340793"},
        {"Helicopter",           "rbxassetid://17862998594"}, {"Perfect Concentration","rbxassetid://102959457211902"},
        {"Sit",                  "rbxassetid://114499085231058"}, {"Sit 2",         "rbxassetid://18450698238"},
        {"wtf",                  "rbxassetid://17122254184"}, {"Insane",            "rbxassetid://104862750267967"},
        {"Insane 2",             "rbxassetid://127234845846317"},
    }
    for _, a in ipairs(idleAnims) do
        local aName, aId = a[1], a[2]
        Window:CreateButton(aName, TabAnimations, function() playIdleAnim(aId) end)
    end

    Window:CreateSection("M1 ATTACK ANIMATIONS", TabAnimations)
    Window:CreateDropdown("Character Type", TabAnimations,
        {"Fist","Bat","Ninjato","Katana","LightningFist","HunterFist","CyborgFist","EsperFist","KJFist","PurpleFist"}, 1,
        function(val)
            m1SelectedCharType = val
            if m1SelectedSet then setM1Replacement(m1SelectedSet) end
        end)
    Window:CreateButton("Default M1", TabAnimations, function()
        m1OrigToReplace = {}
        m1SelectedSet = nil
    end)
    local m1Buttons = {"Fist","Bat","Ninjato","Katana","LightningFist","HunterFist","CyborgFist","EsperFist","KJFist","PurpleFist"}
    for _, setName in ipairs(m1Buttons) do
        Window:CreateButton(setName .. " M1", TabAnimations, function()
            setM1Replacement(setName)
        end)
    end

    -- ── Settings ──────────────────────────────────────────────────
    Window:CreateSection("UTILITY", TabSettings)
    Window:CreateToggle("Void Protection", TabSettings, false, toggleVoidProtection)
    Window:CreateButton("Unload Script & UI", TabSettings, Shutdown)

    Window:PlayIntro()
end

-- ==================== Runtime ====================
TrackConnection(RunService.RenderStepped:Connect(function()
    if not IsActive() then return end
end))

-- ==================== Splash ====================
Library:CreateSplash(
    "ARMOURED :: STRONGEST BATTLEGROUNDS",
    "ARMOURED HUB V1",
    {
        { label = "initializing systems...",  duration = 0.4 },
        { label = "setting up exploits...",   duration = 0.4 },
        { label = "loading combat tools...",  duration = 0.35 },
        { label = "ready.",                   duration = 0.25 },
    },
    function()
        if not IsActive() then return end
        BuildUI()
    end
)

print("[ARMOURED] Strongest Battlegrounds loaded.")
print("[ARMOURED] Press RightShift to toggle UI.")
