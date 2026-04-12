-- ARMOURED :: LOADER
-- Validates key via Junkie then loads the main hub.

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local SafeUI = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui")
if not pcall(function() return SafeUI.Name end) then
    SafeUI = LocalPlayer:WaitForChild("PlayerGui")
end

-- ── Junkie SDK ─────────────────────────────────────────────────────────────
local ok, Junkie = pcall(function()
    return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
end)
if not ok or not Junkie then
    warn("[ARMOURED] Failed to load Junkie SDK.")
    return
end

Junkie.service    = "ARMOURED"
Junkie.identifier = "1073929"
Junkie.provider   = "Mixed"

-- ── Config ─────────────────────────────────────────────────────────────────
local SCRIPT_URL = "RAW_SCRIPT_URL_HERE"  -- paste your GitHub raw / hosting URL
local MAX_TRIES  = 5

-- ── Theme ───────────────────────────────────────────────────────────────────
local Theme = {
    Bg      = Color3.fromRGB(15, 15, 15),
    Header  = Color3.fromRGB(20, 20, 20),
    Panel   = Color3.fromRGB(24, 24, 24),
    PanelAlt = Color3.fromRGB(32, 32, 32),
    Stroke  = Color3.fromRGB(40, 40, 40),
    Accent  = Color3.fromRGB(230, 140, 60),
    Text    = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    GreyText = Color3.fromRGB(110, 110, 110),
    Red     = Color3.fromRGB(220, 70, 70),
    Green   = Color3.fromRGB(60, 200, 100),
}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end
local function addStroke(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.Stroke
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- ── GUI ─────────────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "Armoured_Loader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = SafeUI

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 195)
frame.Position = UDim2.new(0.5, -180, 0.5, -97)
frame.BackgroundColor3 = Theme.Bg
frame.BorderSizePixel = 0
frame.Parent = gui
corner(frame)
addStroke(frame, Theme.Stroke)

-- Accent top strip
local strip = Instance.new("Frame")
strip.Size = UDim2.new(1, 0, 0, 2)
strip.BackgroundColor3 = Theme.Accent
strip.BorderSizePixel = 0
strip.ZIndex = 2
strip.Parent = frame

-- Diamond
local diamond = Instance.new("Frame")
diamond.Size = UDim2.new(0, 9, 0, 9)
diamond.Position = UDim2.new(0, 15, 0, 20)
diamond.Rotation = 45
diamond.BackgroundColor3 = Theme.Accent
diamond.BorderSizePixel = 0
diamond.Parent = frame

-- Title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -40, 0, 36)
titleLbl.Position = UDim2.new(0, 33, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextColor3 = Theme.Text
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = "ARMOURED :: KEY VALIDATION"
titleLbl.Parent = frame

-- Status
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -20, 0, 14)
statusLbl.Position = UDim2.new(0, 10, 0, 46)
statusLbl.BackgroundTransparency = 1
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextColor3 = Theme.SubText
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "enter your key below"
statusLbl.Parent = frame

-- Input
local inputBg = Instance.new("Frame")
inputBg.Size = UDim2.new(1, -20, 0, 34)
inputBg.Position = UDim2.new(0, 10, 0, 68)
inputBg.BackgroundColor3 = Theme.Panel
inputBg.BorderSizePixel = 0
inputBg.Parent = frame
corner(inputBg, 6)
local inputStroke = addStroke(inputBg, Theme.Stroke)

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -16, 1, 0)
inputBox.Position = UDim2.new(0, 8, 0, 0)
inputBox.BackgroundTransparency = 1
inputBox.Font = Enum.Font.GothamSemibold
inputBox.TextSize = 12
inputBox.TextColor3 = Theme.Text
inputBox.PlaceholderText = "paste key here..."
inputBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 70)
inputBox.Text = ""
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputBg

-- Get Key button
local linkBtn = Instance.new("TextButton")
linkBtn.Size = UDim2.new(0.5, -15, 0, 34)
linkBtn.Position = UDim2.new(0, 10, 0, 112)
linkBtn.BackgroundColor3 = Theme.Panel
linkBtn.AutoButtonColor = false
linkBtn.BorderSizePixel = 0
linkBtn.Font = Enum.Font.GothamSemibold
linkBtn.TextSize = 12
linkBtn.TextColor3 = Theme.SubText
linkBtn.Text = "Get Key"
linkBtn.Parent = frame
corner(linkBtn, 6)
local linkStroke = addStroke(linkBtn, Theme.Stroke)

-- Validate button
local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.5, -15, 0, 34)
submitBtn.Position = UDim2.new(0.5, 5, 0, 112)
submitBtn.BackgroundColor3 = Theme.Accent
submitBtn.AutoButtonColor = false
submitBtn.BorderSizePixel = 0
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 13
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Text = "Validate"
submitBtn.Parent = frame
corner(submitBtn, 6)

-- Attempt counter
local attemptsLbl = Instance.new("TextLabel")
attemptsLbl.Size = UDim2.new(1, -20, 0, 12)
attemptsLbl.Position = UDim2.new(0, 10, 0, 156)
attemptsLbl.BackgroundTransparency = 1
attemptsLbl.Font = Enum.Font.Gotham
attemptsLbl.TextSize = 10
attemptsLbl.TextColor3 = Theme.GreyText
attemptsLbl.TextXAlignment = Enum.TextXAlignment.Left
attemptsLbl.Text = ""
attemptsLbl.Parent = frame

-- Version label
local versionLbl = Instance.new("TextLabel")
versionLbl.Size = UDim2.new(1, -10, 0, 12)
versionLbl.Position = UDim2.new(0, 0, 0, 174)
versionLbl.BackgroundTransparency = 1
versionLbl.Font = Enum.Font.Gotham
versionLbl.TextSize = 10
versionLbl.TextColor3 = Color3.fromRGB(50, 50, 50)
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl.Text = "v2"
versionLbl.Parent = frame

-- ── Drag ────────────────────────────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ── Logic ────────────────────────────────────────────────────────────────────
local tries = 0
local validating = false

local function setStatus(msg, color)
    statusLbl.Text = msg
    TweenService:Create(statusLbl, TweenInfo.new(0.15), {TextColor3 = color or Theme.SubText}):Play()
end

local function setInputHighlight(state) -- true=green, false=red, nil=default
    TweenService:Create(inputStroke, TweenInfo.new(0.15), {
        Color = state == true and Theme.Green or state == false and Theme.Red or Theme.Stroke
    }):Play()
end

linkBtn.MouseButton1Click:Connect(function()
    setStatus("fetching link...", Theme.SubText)
    task.spawn(function()
        local link, err = Junkie.get_key_link()
        if link then
            pcall(function() setclipboard(link) end)
            setStatus("link copied to clipboard!", Theme.Green)
        elseif err == "RATE_LIMITTED" then
            setStatus("rate limited — try again in 5 min", Theme.Red)
        else
            setStatus("could not fetch link", Theme.Red)
        end
    end)
end)

local function doValidate()
    if validating then return end
    local key = inputBox.Text
    if key == "" then
        setStatus("key cannot be empty", Theme.Red)
        setInputHighlight(false)
        return
    end

    tries = tries + 1
    validating = true
    submitBtn.Text = "..."
    setStatus("validating...", Theme.SubText)
    setInputHighlight(nil)

    task.spawn(function()
        local result = Junkie.check_key(key)
        validating = false
        submitBtn.Text = "Validate"

        if result.valid or result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = key
            setStatus("key accepted  loading hub...", Theme.Green)
            setInputHighlight(true)
            task.wait(0.7)
            gui:Destroy()
            loadstring(game:HttpGet(SCRIPT_URL))()
        else
            local code = result.error or ""
            local display = ({
                KEY_INVALID      = "invalid key",
                KEY_EXPIRED      = "key has expired",
                HWID_BANNED      = "your device is banned",
                HWID_MISMATCH    = "hwid mismatch — reset key",
                SERVICE_MISMATCH = "wrong service",
                PREMIUM_REQUIRED = "premium key required",
            })[code] or code:lower()

            setStatus(display, Theme.Red)
            setInputHighlight(false)

            if tries >= MAX_TRIES then
                setStatus("too many failed attempts", Theme.Red)
                task.wait(1.2)
                gui:Destroy()
            else
                attemptsLbl.Text = string.format("%d / %d attempts", tries, MAX_TRIES)
            end
        end
    end)
end

submitBtn.MouseButton1Click:Connect(doValidate)
inputBox.FocusLost:Connect(function(enter) if enter then doValidate() end end)

-- Hover FX
submitBtn.MouseEnter:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 165, 80)}):Play()
end)
submitBtn.MouseLeave:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
end)
linkBtn.MouseEnter:Connect(function()
    TweenService:Create(linkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.PanelAlt}):Play()
    TweenService:Create(linkStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
end)
linkBtn.MouseLeave:Connect(function()
    TweenService:Create(linkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Panel}):Play()
    TweenService:Create(linkStroke, TweenInfo.new(0.15), {Color = Theme.Stroke}):Play()
end)
