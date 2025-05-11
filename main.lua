local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- CONFIG
local CORRECT_KEY = "Perplexity2025" -- Your access key

-- PALETTE
local PALETTE = {
    Dark = {
        Background = Color3.fromRGB(18, 20, 28),
        Glass = Color3.fromRGB(34, 38, 54),
        Accent1 = Color3.fromRGB(120, 82, 255),
        Accent2 = Color3.fromRGB(82, 109, 255),
        Accent3 = Color3.fromRGB(0, 255, 200),
        Text = Color3.fromRGB(240, 240, 255),
        Success = Color3.fromRGB(80, 220, 120),
        Error = Color3.fromRGB(255, 80, 100),
        Shadow = Color3.fromRGB(0,0,0)
    },
    Light = {
        Background = Color3.fromRGB(245, 247, 255),
        Glass = Color3.fromRGB(255, 255, 255),
        Accent1 = Color3.fromRGB(120, 82, 255),
        Accent2 = Color3.fromRGB(82, 109, 255),
        Accent3 = Color3.fromRGB(0, 255, 200),
        Text = Color3.fromRGB(32, 34, 44),
        Success = Color3.fromRGB(80, 220, 120),
        Error = Color3.fromRGB(255, 80, 100),
        Shadow = Color3.fromRGB(0,0,0)
    }
}
local THEME = "Dark"
local COLORS = PALETTE[THEME]
local FONT = Enum.Font.Gotham

-- Responsive sizing
local function getScale()
    local res = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    if res.X < 700 or UIS.TouchEnabled then
        return 0.98, 0.52
    else
        return 0.44, 0.52
    end
end

-- Drop shadow
local function makeShadow(parent, size, pos, z)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.8
    shadow.Size = size or UDim2.new(1,60,1,60)
    shadow.Position = pos or UDim2.new(-0.03,0,-0.03,0)
    shadow.ZIndex = z or 0
    shadow.Parent = parent
    return shadow
end

-- Gradient utility
local function addGradient(parent, c1, c2)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    }
    grad.Rotation = 45
    grad.Parent = parent
    return grad
end

-- Glassmorphism (blur)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local function glassOn()
    TS:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = 16}):Play()
end
local function glassOff()
    TS:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = 0}):Play()
end

-- Profile avatar
local avatarImgUrl = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=180&h=180"

-- ICONS
local function icon(txt)
    return "<font color=\"#7e52ff\">"..txt.."</font>"
end

-- Ripple effect for buttons
local function ripple(btn)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x, y)
        local abs = btn.AbsolutePosition
        local rel = Vector2.new(x - abs.X, y - abs.Y)
        local circle = Instance.new("Frame")
        circle.BackgroundTransparency = 1
        circle.BackgroundColor3 = COLORS.Accent3
        circle.Size = UDim2.new(0,0,0,0)
        circle.Position = UDim2.new(0, rel.X, 0, rel.Y)
        circle.AnchorPoint = Vector2.new(0.5,0.5)
        circle.ZIndex = btn.ZIndex + 5
        circle.Parent = btn
        local uic = Instance.new("UICorner", circle)
        uic.CornerRadius = UDim.new(1,0)
        local goal = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.2
        TS:Create(circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(0, goal, 0, goal), BackgroundTransparency = 1}):Play()
        wait(0.5)
        circle:Destroy()
    end)
end

-- Notifications (toast)
local function notify(text, color)
    local toast = Instance.new("TextLabel")
    toast.Text = text
    toast.Font = FONT
    toast.TextSize = 20
    toast.TextColor3 = color or COLORS.Text
    toast.BackgroundColor3 = COLORS.Glass
    toast.BackgroundTransparency = 0.15
    toast.Size = UDim2.new(0, 0, 0, 40)
    toast.Position = UDim2.new(0.5, 0, 0.13, 0)
    toast.AnchorPoint = Vector2.new(0.5,0)
    toast.Parent = playerGui:FindFirstChild("PerplexityUI") or playerGui
    toast.ZIndex = 100
    toast.TextStrokeTransparency = 0.8
    toast.TextStrokeColor3 = Color3.new(0,0,0)
    toast.RichText = true
    local uic = Instance.new("UICorner", toast)
    uic.CornerRadius = UDim.new(0,12)
    TS:Create(toast, TweenInfo.new(0.25), {Size = UDim2.new(0, 320, 0, 40)}):Play()
    wait(1.7)
    TS:Create(toast, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    wait(0.3)
    toast:Destroy()
end

-- Utility: create UI elements
local function create(class, props, children)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k]=v end
    for _,child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

-- Clean up old GUIs if re-executed
if playerGui:FindFirstChild("PerplexityUI") then
    playerGui.PerplexityUI:Destroy()
end

local screenGui = create("ScreenGui", {
    Name = "PerplexityUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui
})

-- Responsive
local scaleX, scaleY = getScale()

-- KEY SYSTEM UI
local keyFrame = create("Frame", {
    Name = "KeyFrame",
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.22,
    Size = UDim2.new(scaleX,0,scaleY-0.12,0),
    Position = UDim2.new(0.5,0,0.5,0),
    AnchorPoint = Vector2.new(0.5,0.5),
    BorderSizePixel = 0,
    Parent = screenGui,
    ZIndex = 2,
    Visible = true
}, {
    create("UICorner", {CornerRadius = UDim.new(0,28)}),
    create("UIStroke", {Color = COLORS.Accent1, Thickness = 2, Transparency = 0.22}),
    create("UIListLayout", {
        Padding = UDim.new(0,0),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    }),
    -- Animated Avatar
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.22,0),
        LayoutOrder = 1
    }, {
        create("ImageLabel", {
            Name = "Avatar",
            BackgroundTransparency = 1,
            Image = avatarImgUrl,
            Size = UDim2.new(0,68,0,68),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ZIndex = 3
        }, {
            create("UICorner", {CornerRadius = UDim.new(1,0)}),
            create("UIStroke", {Color = COLORS.Accent2, Thickness = 2, Transparency = 0.1})
        })
    }),
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.13,0),
        LayoutOrder = 2
    }, {
        create("TextLabel", {
            Name = "Title",
            Text = icon("🔒").." <b>Access Key Required</b>",
            Font = FONT,
            TextSize = 30,
            TextColor3 = COLORS.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            RichText = true
        })
    }),
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.18,0),
        LayoutOrder = 3
    }, {
        create("TextBox", {
            Name = "KeyBox",
            PlaceholderText = "Type your key...",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Text,
            BackgroundColor3 = COLORS.Background,
            Size = UDim2.new(0.8,0,1,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            ClearTextOnFocus = false,
            Text = "",
            ZIndex = 3
        }, {
            create("UICorner", {CornerRadius = UDim.new(0,14)}),
            create("UIStroke", {Color = COLORS.Accent2, Thickness = 1, Transparency = 0.4})
        })
    }),
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.15,0),
        LayoutOrder = 4
    }, {
        create("TextButton", {
            Name = "SubmitBtn",
            Text = "<b>"..icon("✨").." Unlock</b>",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Text,
            BackgroundColor3 = COLORS.Accent1,
            Size = UDim2.new(0.8,0,1,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            AutoButtonColor = true,
            RichText = true,
            ZIndex = 3
        }, {
            create("UICorner", {CornerRadius = UDim.new(0,14)}),
            create("UIStroke", {Color = COLORS.Accent2, Thickness = 1, Transparency = 0.3})
        })
    }),
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.10,0),
        LayoutOrder = 5
    }, {
        create("TextLabel", {
            Name = "Status",
            Text = "",
            Font = FONT,
            TextSize = 18,
            TextColor3 = COLORS.Error,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            ZIndex = 3
        })
    })
})
makeShadow(keyFrame, UDim2.new(1,60,1,60), UDim2.new(-0.03,0,-0.03,0), 1)
addGradient(keyFrame, COLORS.Accent1, COLORS.Accent2)

-- Animate avatar border color
local avatarStroke = keyFrame:FindFirstChildWhichIsA("Frame"):FindFirstChild("Avatar"):FindFirstChildWhichIsA("UIStroke")
spawn(function()
    local t = 0
    while keyFrame and keyFrame.Parent do
        t = t + 0.03
        avatarStroke.Color = Color3.fromHSV((tick()%5)/5, 0.6, 1)
        wait(0.03)
    end
end)

-- Key system logic
local keyBox = keyFrame.KeyBox
local submitBtn = keyFrame.SubmitBtn
local statusLbl = keyFrame.Status
ripple(submitBtn)

local function showStatus(text, color)
    statusLbl.Text = text
    statusLbl.TextColor3 = color
end

local function unlock()
    TS:Create(keyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1, Size = UDim2.new(scaleX*1.1,0,scaleY*1.1,0)}):Play()
    glassOn()
    wait(0.4)
    keyFrame.Visible = false
    screenGui.LoadingFrame.Visible = true
    screenGui.LoadingFrame:FindFirstChild("StartLoading"):Fire()
end

submitBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == CORRECT_KEY then
        showStatus("Access Granted!", COLORS.Success)
        notify(icon("✅").." Welcome!", COLORS.Success)
        wait(0.3)
        unlock()
    else
        showStatus("Invalid key! Try again.", COLORS.Error)
        notify(icon("❌").." Invalid key.", COLORS.Error)
    end
end)

keyBox.FocusLost:Connect(function(enter)
    if enter then submitBtn:Activate() end
end)

-- LOADING SCREEN (after key system)
local loadingFrame = create("Frame", {
    Name = "LoadingFrame",
    BackgroundColor3 = COLORS.Background,
    BackgroundTransparency = 0.1,
    Size = UDim2.new(1,0,1,0),
    Position = UDim2.new(0,0,0,0),
    BorderSizePixel = 0,
    Visible = false,
    Parent = screenGui,
    ZIndex = 10
}, {
    create("UICorner", {CornerRadius = UDim.new(0,0)}),
    create("TextLabel", {
        Name = "LoadingText",
        Text = "<b>Loading Experience...</b>",
        Font = FONT,
        TextSize = 38,
        TextColor3 = COLORS.Accent2,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,60),
        Position = UDim2.new(0,0,0.4,0),
        RichText = true,
        ZIndex = 11
    }),
    -- Animated loading icon
    create("ImageLabel", {
        Name = "Spinner",
        Image = "rbxassetid://77339698", -- Roblox spinner asset
        BackgroundTransparency = 1,
        Size = UDim2.new(0,38,0,38),
        Position = UDim2.new(0.5,-19,0.48,0),
        AnchorPoint = Vector2.new(0.5,0),
        ZIndex = 12
    }),
    create("Frame", {
        Name = "BarBG",
        BackgroundColor3 = COLORS.Glass,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0.36,0,0,18),
        Position = UDim2.new(0.32,0,0.54,0),
        BorderSizePixel = 0,
        ZIndex = 11
    }, {
        create("UICorner", {CornerRadius = UDim.new(1,0)}),
        create("UIStroke", {Color = COLORS.Accent2, Thickness = 1, Transparency = 0.2})
    }),
    create("Frame", {
        Name = "Bar",
        BackgroundColor3 = COLORS.Accent1,
        Size = UDim2.new(0,0,1,0),
        Position = UDim2.new(0,0,0,0),
        BorderSizePixel = 0,
        ZIndex = 12
    }, {
        create("UICorner", {CornerRadius = UDim.new(1,0)}),
        create("UIStroke", {Color = COLORS.Accent3, Thickness = 1, Transparency = 0.1})
    }),
    create("BindableEvent", {Name = "StartLoading"})
})
makeShadow(loadingFrame.BarBG, UDim2.new(1,18,1,18), UDim2.new(-0.04,0,-0.13,0), 12)
addGradient(loadingFrame.Bar, COLORS.Accent1, COLORS.Accent3)

-- Animated spinner
spawn(function()
    while loadingFrame and loadingFrame:FindFirstChild("Spinner") do
        local spinner = loadingFrame.Spinner
        spinner.Rotation = (spinner.Rotation + 10) % 360
        wait(0.02)
    end
end)

-- Loading bar animation
local function loadingAnim()
    local bar = loadingFrame.Bar
    local duration = 2.8
    local steps = 120
    bar.Size = UDim2.new(0,0,1,0)
    for i = 1, steps do
        bar.Size = UDim2.new(i/steps,0,1,0)
        wait(duration/steps)
    end
    wait(0.5)
    TS:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
    TS:Create(loadingFrame.Bar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TS:Create(loadingFrame.BarBG, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TS:Create(loadingFrame.LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TS:Create(loadingFrame.Spinner, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    wait(0.5)
    loadingFrame.Visible = false
    glassOff()
    screenGui.MainFrame.Visible = true
    TS:Create(screenGui.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0.11, Size = UDim2.new(scaleX,0,scaleY,0)}):Play()
    notify(icon("🌈").." Welcome to the UI!", COLORS.Accent2)
end

loadingFrame.StartLoading.Event:Connect(loadingAnim)

-- MAIN UI with TABS
local mainFrame = create("Frame", {
    Name = "MainFrame",
    BackgroundColor3 = COLORS.Glass,
    BackgroundTransparency = 0.11,
    Size = UDim2.new(scaleX,0,scaleY,0),
    Position = UDim2.new(0.5,0,0.5,0),
    AnchorPoint = Vector2.new(0.5,0.5),
    BorderSizePixel = 0,
    Visible = false,
    Parent = screenGui,
    ZIndex = 20
}, {
    create("UICorner", {CornerRadius = UDim.new(0,32)}),
    create("UIStroke", {Color = COLORS.Accent3, Thickness = 2, Transparency = 0.18}),
    create("Frame", {
        Name = "TabBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.13,0),
        Position = UDim2.new(0,0,0,0),
        ZIndex = 21
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0,10)
        }),
        create("TextButton", {
            Name = "TabHome",
            Text = icon("🏠").." <b>Home</b>",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Accent1,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,110,0,36),
            RichText = true,
            ZIndex = 22
        }),
        create("TextButton", {
            Name = "TabSettings",
            Text = icon("⚙️").." <b>Settings</b>",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,120,0,36),
            RichText = true,
            ZIndex = 22
        }),
        create("TextButton", {
            Name = "TabAbout",
            Text = icon("💡").." <b>About</b>",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,110,0,36),
            RichText = true,
            ZIndex = 22
        }),
    }),
    -- Content frames
    create("Frame", {
        Name = "ContentHome",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.87,0),
        Position = UDim2.new(0,0,0.13,0),
        ZIndex = 30,
        Visible = true
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0,8)
        }),
        create("ImageLabel", {
            Name = "Avatar",
            BackgroundTransparency = 1,
            Image = avatarImgUrl,
            Size = UDim2.new(0,60,0,60),
            Position = UDim2.new(0.5,0,0,0),
            AnchorPoint = Vector2.new(0.5,0),
            ZIndex = 31
        }, {
            create("UICorner", {CornerRadius = UDim.new(1,0)}),
            create("UIStroke", {Color = COLORS.Accent2, Thickness = 2, Transparency = 0.1})
        }),
        create("TextLabel", {
            Name = "WelcomeText",
            Text = "Welcome, <b>"..player.DisplayName.."</b>!<br>Enjoy the <font color=\"#00ffc8\">ultimate</font> modern Roblox UI.<br>Everything is sleek, animated, and mobile-friendly.",
            Font = FONT,
            TextSize = 22,
            TextColor3 = COLORS.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,64),
            TextWrapped = true,
            RichText = true,
            ZIndex = 31
        }),
        create("TextButton", {
            Name = "ActionBtn",
            Text = "<b>"..icon("✨").." Try Me!</b>",
            Font = FONT,
            TextSize = 24,
            TextColor3 = COLORS.Text,
            BackgroundColor3 = COLORS.Accent2,
            Size = UDim2.new(0,180,0,40),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0,0),
            AutoButtonColor = true,
            RichText = true,
            ZIndex = 32
        }, {
            create("UICorner", {CornerRadius = UDim.new(0,16)}),
            create("UIStroke", {Color = COLORS.Accent1, Thickness = 1, Transparency = 0.2})
        })
    }),
    create("Frame", {
        Name = "ContentSettings",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.87,0),
        Position = UDim2.new(0,0,0.13,0),
        ZIndex = 30,
        Visible = false
    }, {
        create("TextLabel", {
            Name = "SettingsHeader",
            Text = icon("⚙️").." <b>Settings</b>",
            Font = FONT,
            TextSize = 26,
            TextColor3 = COLORS.Accent2,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,36),
            RichText = true
        }),
        create("TextButton", {
            Name = "ThemeBtn",
            Text = "<b>"..icon("🌗").." Toggle Dark/Light Mode</b>",
            Font = FONT,
            TextSize = 20,
            TextColor3 = COLORS.Text,
            BackgroundColor3 = COLORS.Accent3,
            Size = UDim2.new(0,220,0,40),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0,0.2),
            AutoButtonColor = true,
            RichText = true
        }, {
            create("UICorner", {CornerRadius = UDim.new(0,14)}),
            create("UIStroke", {Color = COLORS.Accent2, Thickness = 1, Transparency = 0.2})
        })
        }),
    create("Frame", {
        Name = "ContentAbout",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0.87,0),
        Position = UDim2.new(0,0,0.13,0),
        ZIndex = 30,
        Visible = false
    }, {
        create("TextLabel", {
            Name = "AboutHeader",
            Text = icon("💡").." <b>About This UI</b>",
            Font = FONT,
            TextSize = 26,
            TextColor3 = COLORS.Accent2,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,36),
            RichText = true
        }),
        create("TextLabel", {
            Name = "AboutText",
            Text = "Created by <b>Perplexity AI</b>.<br>All client-sided, fully dynamic, and ready for your game.<br><font color=\"#7e52ff\">Maxed out modern UI.</font>",
            Font = FONT,
            TextSize = 20,
            TextColor3 = COLORS.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,64),
            TextWrapped = true,
            RichText = true
        })
    })
})
makeShadow(mainFrame, UDim2.new(1,80,1,80), UDim2.new(-0.04,0,-0.04,0), 18)
addGradient(mainFrame, COLORS.Accent2, COLORS.Accent3)

-- Tab switching logic
local tabBar = mainFrame.TabBar
local tabs = {"Home", "Settings", "About"}
local contentFrames = {
    Home = mainFrame.ContentHome,
    Settings = mainFrame.ContentSettings,
    About = mainFrame.ContentAbout
}
for _,tab in ipairs(tabs) do
    local btn = tabBar["Tab"..tab]
    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(tabs) do
            tabBar["Tab"..t].TextColor3 = (t==tab) and COLORS.Accent1 or COLORS.Text
            contentFrames[t].Visible = (t==tab)
            -- Animate tab content in
            if contentFrames[t].Visible then
                TS:Create(contentFrames[t], TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = UDim2.new(0,0,0.13,0)}):Play()
            else
                contentFrames[t].Position = UDim2.new(0,0,0.18,0)
            end
        end
        notify(icon("🔄").." Switched to "..tab.."!", COLORS.Accent2)
    end)
end

-- Ripple for tab buttons
for _,tab in ipairs(tabs) do
    ripple(tabBar["Tab"..tab])
end

-- Home tab action
local actionBtn = mainFrame.ContentHome.ActionBtn
ripple(actionBtn)
actionBtn.MouseEnter:Connect(function()
    TS:Create(actionBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent3}):Play()
end)
actionBtn.MouseLeave:Connect(function()
    TS:Create(actionBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent2}):Play()
end)
actionBtn.TouchTap:Connect(function()
    TS:Create(actionBtn, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.Accent3}):Play()
    wait(0.18)
    TS:Create(actionBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent2}):Play()
end)
actionBtn.MouseButton1Click:Connect(function()
    mainFrame.ContentHome.WelcomeText.Text = "You clicked the button! <b>🎉</b>"
    notify(icon("🎉").." Button clicked!", COLORS.Success)
end)

-- Settings tab: theme toggle
local themeBtn = mainFrame.ContentSettings.ThemeBtn
ripple(themeBtn)
themeBtn.MouseButton1Click:Connect(function()
    THEME = (THEME == "Dark") and "Light" or "Dark"
    COLORS = PALETTE[THEME]
    notify(icon("🌗").." Theme: "..THEME, COLORS.Accent2)
    -- Update colors live everywhere
    mainFrame.BackgroundColor3 = COLORS.Glass
    mainFrame.ContentHome.ActionBtn.BackgroundColor3 = COLORS.Accent2
    mainFrame.ContentSettings.ThemeBtn.BackgroundColor3 = COLORS.Accent3
    mainFrame.ContentHome.WelcomeText.TextColor3 = COLORS.Text
    mainFrame.ContentSettings.SettingsHeader.TextColor3 = COLORS.Accent2
    mainFrame.ContentAbout.AboutHeader.TextColor3 = COLORS.Accent2
    mainFrame.ContentAbout.AboutText.TextColor3 = COLORS.Text
    for _,tab in ipairs(tabs) do
        tabBar["Tab"..tab].TextColor3 = COLORS.Text
    end
    tabBar.TabHome.TextColor3 = COLORS.Accent1
    mainFrame.UIStroke.Color = COLORS.Accent3
    keyFrame.BackgroundColor3 = COLORS.Glass
    keyFrame.UIStroke.Color = COLORS.Accent1
    keyFrame.KeyBox.BackgroundColor3 = COLORS.Background
    keyFrame.KeyBox.UIStroke.Color = COLORS.Accent2
    keyFrame.SubmitBtn.BackgroundColor3 = COLORS.Accent1
    keyFrame.SubmitBtn.UIStroke.Color = COLORS.Accent2
    keyFrame.Title.TextColor3 = COLORS.Text
    keyFrame.Status.TextColor3 = COLORS.Error
    loadingFrame.BackgroundColor3 = COLORS.Background
    loadingFrame.BarBG.BackgroundColor3 = COLORS.Glass
    loadingFrame.BarBG.UIStroke.Color = COLORS.Accent2
    loadingFrame.Bar.BackgroundColor3 = COLORS.Accent1
    loadingFrame.Bar.UIStroke.Color = COLORS.Accent3
    loadingFrame.LoadingText.TextColor3 = COLORS.Accent2
end)

-- Make UI draggable (desktop only)
if not UIS.TouchEnabled then
    local dragging, dragInput, dragStart, startPos
    mainFrame.Active = true
    mainFrame.Selectable = true

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Clean up blur on removal
screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        blur:Destroy()
    end
  end)
