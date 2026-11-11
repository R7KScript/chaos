
local Config = {
    Title = "UI Library",                                   -- عنوان الواجهة
    Description = "discord.gg/BHRUtyTbk2",                  -- النص الصغير تحت العنوان
    Logo = "http://www.roblox.com/asset/?id=18810965406",   -- صورة اللوقو
    Keybind = Enum.KeyCode.LeftControl,                     -- زر اخفاء/اظهار الواجهة
    Size = UDim2.new(0.1, 445, 0.1, 315),                   -- حجم الواجهة
    Theme = "Crimson",                                      -- Crimson | Midnight | Emerald | Violet | Graphite
    Opacity = 0.6,                                          -- كثافة الخلفية من 0.35 الى 1
    LowQualitySolid = true,                                 -- خلفية صلبة اذا جودة الرسوم اقل من 8 (مثل الاصلي)
    Blur = true,                                            -- تغبيش ما خلف الواجهة
    SettingsTab = false,                                    -- تاب اعدادات جاهز (شفافية + ثيم + زر + بلور)
    SettingsTabName = "Settings",
    ConfigFolder = "SugarConfigs",                          -- مجلد حفظ الاعدادات
    Font = Enum.Font.GothamBold,
    HomeIcon = "rbxassetid://7733993211",                   -- ايقونة الواجهة وهي مصغّرة
    DefaultIcon = "rbxassetid://7733964640",                -- ايقونة التابات/الاقسام الافتراضية
    Corner = { Window = 7, Panel = 3, Element = 2 },        -- استدارة الزوايا
}

local Themes = {
    Crimson  = { Window = Color3.fromRGB(15, 5, 5),   Panel = Color3.fromRGB(20, 5, 5),   Accent = Color3.fromRGB(150, 0, 0),   Shadow = Color3.fromRGB(50, 0, 0) },
    Midnight = { Window = Color3.fromRGB(5, 8, 18),   Panel = Color3.fromRGB(8, 12, 26),  Accent = Color3.fromRGB(40, 90, 220), Shadow = Color3.fromRGB(0, 10, 50) },
    Emerald  = { Window = Color3.fromRGB(4, 14, 8),   Panel = Color3.fromRGB(6, 20, 11),  Accent = Color3.fromRGB(20, 170, 90), Shadow = Color3.fromRGB(0, 40, 15) },
    Violet   = { Window = Color3.fromRGB(10, 5, 18),  Panel = Color3.fromRGB(15, 8, 26),  Accent = Color3.fromRGB(130, 60, 220), Shadow = Color3.fromRGB(30, 0, 60) },
    Graphite = { Window = Color3.fromRGB(12, 12, 12), Panel = Color3.fromRGB(18, 18, 18), Accent = Color3.fromRGB(150, 150, 150), Shadow = Color3.fromRGB(0, 0, 0) },
}

----------------------------------------------------------------------
-- أدوات داخلية
----------------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Root = (gethui and gethui()) or game:FindFirstChild("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

local WHITE, BLACK, ELEMENT = Color3.new(1, 1, 1), Color3.new(0, 0, 0), Color3.fromRGB(17, 17, 17)
local XL, XR, CENTER = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right, Enum.HorizontalAlignment.Center
local FIT = Enum.AspectType.ScaleWithParentSize
local function Seq(...)
    local k = {}
    for _, p in ipairs({ ... }) do k[#k + 1] = NumberSequenceKeypoint.new(p[1], p[2]) end
    return NumberSequence.new(k)
end
local FADE = Seq({ 0, 0 }, { 0.84, 0.25 }, { 1, 1 })      -- تدرج النصوص
local ICONFADE = Seq({ 0, 0 }, { 0.75, 0.27 }, { 1, 1 })  -- تدرج الايقونات

local Library = { Icons = {}, Themes = Themes }  -- Library.Icons["home"] = "rbxassetid://..." لاضافة ايقونات بالاسم
local Cfg, Theme, Tinted = Config, Themes.Crimson, {}

local function Merge(t, d)
    t = t or {}
    for k, v in next, d do if t[k] == nil then t[k] = v end end
    return t
end
local function Tween(o, t, p, style)
    TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint), p):Play()
end
local function In(o, prop, to, t) o[prop] = 1; Tween(o, t or 0.3, { [prop] = to }) end
local function Img(i) if type(i) == "number" then return "rbxassetid://" .. i end return Library.Icons[i] or i end

local function New(class, props, parent)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then o.BorderSizePixel = 0; o.BackgroundColor3 = WHITE; o.BackgroundTransparency = 1 end
    if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
        o.Font = Cfg.Font; o.TextColor3 = WHITE; o.TextScaled = true; o.TextWrapped = true; o.Text = ""
    end
    for k, v in next, props do o[k] = v end
    o.Parent = parent
    return o
end
local function Corner(o, r) return New("UICorner", { CornerRadius = type(r) == "number" and UDim.new(0, r) or r }, o) end
local function Stroke(o, t) return New("UIStroke", { Color = WHITE, Transparency = t }, o) end
local function Fade(o, seq, rot) return New("UIGradient", { Rotation = rot or 90, Transparency = seq or FADE }, o) end
local function Txt(p, props) local l = New("TextLabel", props, p); Fade(l); return l end
local function Click(p, z) return New("TextButton", { Size = UDim2.fromScale(1, 1), ZIndex = z or 15 }, p) end
local function Tint(o, prop, key) o[prop] = Theme[key]; Tinted[#Tinted + 1] = { o, prop, key } end
local function Shadow(p, pad, alpha, z)
    return New("ImageLabel", {
        Name = "Shadow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, pad, 1, pad), ZIndex = z, Image = "rbxassetid://6015897843", ImageColor3 = BLACK,
        ImageTransparency = alpha, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
    }, p)
end
local function Line(p, props, seq, rot)
    local l = New("Frame", props, p)
    Corner(l, UDim.new(0.5, 0)); Fade(l, seq, rot)
    return l
end

-- صف عنصر (نفس النسب الاصلية)
local function Row(parent, aspect, color, alpha)
    local f = New("Frame", { Name = "Element", BackgroundColor3 = color or ELEMENT, Size = UDim2.new(0.95, 0, 0.5, 0), ZIndex = 17 }, parent)
    local ar = New("UIAspectRatioConstraint", { AspectRatio = aspect, AspectType = FIT }, f)
    Corner(f, Cfg.Corner.Element)
    In(f, "BackgroundTransparency", alpha or 0.8, 0.5)
    return f, ar
end
local function Cap(r, text, y, h)
    return Txt(r, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, y), Size = UDim2.fromScale(0.95, h), ZIndex = 18, Text = text, TextXAlignment = XL, TextTransparency = 0.25 })
end
local function Inset(r, y, h)
    local b = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = BLACK, BackgroundTransparency = 0.8, Position = UDim2.fromScale(0.5, y), Size = UDim2.fromScale(0.95, h), ClipsDescendants = true, ZIndex = 18 }, r)
    Corner(b, Cfg.Corner.Element); Stroke(b, 0.975)
    return b
end

----------------------------------------------------------------------
-- تغبيش الخلفية (Glass + DepthOfField)
----------------------------------------------------------------------
local function Blur(frame)
    local B = { Enabled = true }
    local name = HttpService:GenerateGUID(false)
    local part = New("Part", { Name = name, Material = Enum.Material.Glass, Transparency = 1, Reflectance = 1, CastShadow = false, Anchored = true, CanCollide = false, CanQuery = false, Size = Vector3.new(0.01, 0.01, 0.01), Color = BLACK }, workspace)
    local dof = New("DepthOfFieldEffect", { Name = name, FarIntensity = 1, FocusDistance = 0, InFocusRadius = 500, NearIntensity = 1 }, Lighting)
    local mesh = Instance.new("BlockMesh", part)
    local function onPlane(ray, origin, look)
        return ray.Origin + ray.Direction * ((origin - ray.Origin):Dot(look) / ray.Direction:Dot(look))
    end
    function B.Update()
        if not B.Enabled then return end
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        local a = frame.AbsolutePosition
        local b = a + frame.AbsoluteSize
        local origin = cf.Position + cf.LookVector * (0.05 - cam.NearPlaneZ)
        local p0 = cf:PointToObjectSpace(onPlane(cam:ScreenPointToRay(a.X, a.Y, 1), origin, cf.LookVector))
        local p1 = cf:PointToObjectSpace(onPlane(cam:ScreenPointToRay(b.X, b.Y, 1), origin, cf.LookVector))
        mesh.Offset = (p0 + p1) / 2
        mesh.Scale = (p1 - p0) / 0.0101
        part.CFrame = cf
    end
    function B.SetEnabled(on)
        B.Enabled = on; dof.Enabled = on
        Tween(part, 0.5, { Transparency = on and 0.8 or 1 })
        if on then B.Update() end
    end
    function B.Destroy() B.Conn:Disconnect(); dof:Destroy(); part:Destroy() end
    B.Conn = RunService.RenderStepped:Connect(B.Update)
    B.SetEnabled(Cfg.Blur)
    return B
end

----------------------------------------------------------------------
-- قائمة الدروب داون (واحدة مشتركة)
----------------------------------------------------------------------
local function Popup(Gui, Window)
    local P, open, target, inside = {}, false, nil, false
    local DD = New("Frame", { Name = "DropdownFrame", BackgroundColor3 = ELEMENT, Size = UDim2.fromOffset(150, 0), ZIndex = 100, Visible = false }, Gui)
    Corner(DD, 4)
    local Sh = Shadow(DD, 47, 1, 99)
    local Edge = Stroke(DD, 1)
    local Body = New("Frame", { Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 100 }, DD)
    Corner(Body, 4)
    local Value = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.97, 0.5), ZIndex = 101, Text = "NONE", TextTransparency = 1, TextXAlignment = XR }, Body)
    New("UIAspectRatioConstraint", { AspectRatio = 15, AspectType = FIT }, Value)
    local Scroll = New("ScrollingFrame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.556), Size = UDim2.fromScale(0.95, 0.888), ZIndex = 102, ScrollBarThickness = 1, TopImage = "", BottomImage = "", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarImageTransparency = 1, Active = true }, Body)
    New("UIListLayout", { HorizontalAlignment = CENTER, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, Scroll)
    local Rule = Line(Body, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.08), Size = UDim2.new(1, 0, 0, 1), ZIndex = 102 }, Seq({ 0, 1 }, { 0.03, 0 }, { 0.98, 0 }, { 1, 1 }), 0)

    local function Show(on)
        Tween(DD, 0.3, { BackgroundTransparency = on and 0.1 or 1 })
        Tween(Edge, 0.3, { Transparency = on and 0.9 or 1 })
        Tween(Sh, 0.3, { ImageTransparency = on and 0.6 or 1 })
        Tween(Value, 0.3, { TextTransparency = on and 0.8 or 1 })
        Tween(Scroll, 0.3, { ScrollBarImageTransparency = on and 0.5 or 1 })
        Tween(Rule, 0.3, { BackgroundTransparency = on and 0.8 or 1 })
    end
    local function Clear() for _, c in ipairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end

    local function Item(text, selected)
        local f = New("Frame", { BackgroundColor3 = BLACK, BackgroundTransparency = 0.75, Size = UDim2.fromScale(0.97, 0.5), ClipsDescendants = true, ZIndex = 103 }, Scroll)
        New("UIAspectRatioConstraint", { AspectRatio = 6.25, AspectType = FIT }, f)
        Corner(f, Cfg.Corner.Panel); Stroke(f, 0.9)
        local t = Txt(f, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.025, 0.5), Size = UDim2.fromScale(1, 0.5), ZIndex = 104, Text = text, TextXAlignment = XL })
        local m = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 0.6, Position = UDim2.fromScale(1.125, 0.5), Size = UDim2.fromScale(0.055, 0.7), ZIndex = 104 }, f)
        Corner(m, Cfg.Corner.Panel); Fade(m)
        local function mark(on)
            Tween(m, 0.1, { Position = UDim2.fromScale(on and 1.025 or 1.125, 0.5) })
            Tween(t, 0.1, { TextTransparency = on and 0 or 0.25 })
        end
        mark(selected)
        return Click(f, 105), mark
    end

    function P.Open(tgt, list, current, callback)
        target, open, inside = tgt, true, false
        DD.Visible = true
        Value.Text = tostring(current)
        Show(true); Clear()
        local items = {}
        for _, v in ipairs(list) do
            local btn, mark = Item(tostring(v), v == current)
            items[#items + 1] = { v = v, mark = mark }
            btn.MouseButton1Click:Connect(function()
                for _, o in ipairs(items) do o.mark(o.v == v) end
                Value.Text = tostring(v)
                callback(v)
            end)
        end
    end
    function P.Close()
        if not open then return end
        open = false; Show(false); Clear()
    end

    DD.MouseEnter:Connect(function() inside = true end)
    DD.MouseLeave:Connect(function() inside = false end)
    Window:Bind(UIS.InputBegan, function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not inside then P.Close() end
    end)
    Window:Bind(RunService.RenderStepped, function()
        if not target then return end
        local h = DD.AbsoluteSize.Y
        h = h + ((open and 150 or 0) - h) * 0.2
        if not open and h < 1 then DD.Visible = false; return end
        local p, s = target.AbsolutePosition, target.AbsoluteSize
        local y = p.Y + s.Y + 6
        if y + 150 > Gui.AbsoluteSize.Y then y = p.Y - h - 6 end
        DD.Size = UDim2.fromOffset(s.X, h)
        DD.Position = UDim2.fromOffset(p.X, y)
    end)
    return P
end

----------------------------------------------------------------------
-- العناصر (مشتركة بين Section و CollapsibleSection)
----------------------------------------------------------------------
local function Mixin(Obj, Box, Window)
    Obj.Elements = {}
    local function Add(el) Obj.Elements[#Obj.Elements + 1] = el; return el end
    local function Pointer(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end

    function Obj:NewToggle(c)
        c = Merge(c, { Title = "Toggle", Default = false, Callback = function() end }); c.Name = c.Name or c.Title
        local R = Row(Box, 8)
        local Text = Cap(R, c.Title, 0.5, 0.48)
        Stroke(R, 0.95)
        local Sys = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = BLACK, Position = UDim2.fromScale(0.975, 0.5), Size = UDim2.fromScale(0.155, 0.6), ZIndex = 18 }, R)
        Corner(Sys, UDim.new(0.5, 0)); Stroke(Sys, 0.85)
        local Knob = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 0.5, Position = UDim2.fromScale(0.25, 0.5), Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 17 }, Sys)
        Corner(Knob, UDim.new(1, 0))
        local function Render(v)
            Tween(Text, 0.15, { TextTransparency = v and 0.02 or 0.25 })
            Tween(Knob, 0.15, { Position = UDim2.fromScale(v and 0.75 or 0.25, 0.5), BackgroundTransparency = v and 0.4 or 0.5 })
        end
        local function Set(v) c.Default = v; Render(v); task.spawn(c.Callback, v) end
        Set(c.Default)
        Click(R).MouseButton1Click:Connect(function() Set(not c.Default) end)
        return Add({ Name = c.Name, Get = function() return c.Default end, Set = Set, Visible = function(v) R.Visible = v end })
    end

    function Obj:NewButton(c)
        c = Merge(c, { Title = "Button", Callback = function() end })
        local R, ar = Row(Box, 7, Color3.fromRGB(71, 71, 71), 0.75)
        Tween(ar, 0.5, { AspectRatio = 7.65 })
        local Sh = Shadow(R, 20, 0.6, 16)
        local Text = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 0.48), ZIndex = 18, Text = c.Title, TextTransparency = 0.25 }, R)
        Fade(Text); Stroke(R, 0.92)
        local B = Click(R)
        B.MouseEnter:Connect(function() Tween(Sh, 0.2, { ImageTransparency = 0.35 }); Tween(Text, 0.2, { TextTransparency = 0 }) end)
        B.MouseLeave:Connect(function() Tween(Sh, 0.2, { ImageTransparency = 0.6 }); Tween(Text, 0.2, { TextTransparency = 0.25 }) end)
        B.MouseButton1Click:Connect(function() task.spawn(c.Callback) end)
        return { Fire = c.Callback, Set = function(t) Text.Text = t end, Visible = function(v) R.Visible = v end }
    end

    function Obj:NewKeybind(c)
        c = Merge(c, { Title = "Keybind", Default = Enum.KeyCode.E, Callback = function() end }); c.Name = c.Name or c.Title
        local R = Row(Box, 8)
        local Text = Cap(R, c.Title, 0.5, 0.48)
        Stroke(R, 0.95)
        local Sys = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = BLACK, Position = UDim2.fromScale(0.975, 0.5), Size = UDim2.new(0, 50, 0.6, 0), ZIndex = 18 }, R)
        Corner(Sys, UDim.new(0.35, 0)); Stroke(Sys, 0.95)
        local Key = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 0.65), TextTransparency = 0.5 }, Sys)
        local listening = false
        local function Show(k)
            local s = type(k) == "string" and k or k.Name
            Key.Text = s
            Tween(Sys, 0.2, { Size = UDim2.new(0, TextService:GetTextSize(s, 14, Cfg.Font, Vector2.new(1e5, 1e5)).X + 2, 0.6, 0) })
        end
        Show(c.Default)
        Click(R).MouseButton1Click:Connect(function()
            if listening then return end
            listening = true; Show("..."); Tween(Text, 0.1, { TextTransparency = 0 })
            local con
            con = UIS.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode ~= Enum.KeyCode.Unknown then
                    con:Disconnect(); listening = false
                    c.Default = i.KeyCode; Show(i.KeyCode); Tween(Text, 0.1, { TextTransparency = 0.25 })
                    task.spawn(c.Callback, i.KeyCode)
                end
            end)
        end)
        if c.Pressed then -- اختياري: يشتغل عند ضغط الزر نفسه
            Window:Bind(UIS.InputBegan, function(i, gp)
                if not gp and not listening and i.KeyCode == c.Default then task.spawn(c.Pressed) end
            end)
        end
        return Add({
            Name = c.Name, Get = function() return c.Default.Name end,
            Set = function(v) c.Default = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]; Show(c.Default); task.spawn(c.Callback, c.Default) end,
            Visible = function(v) R.Visible = v end,
        })
    end

    function Obj:NewSlider(c)
        c = Merge(c, { Title = "Slider", Min = 0, Max = 100, Default = 50, Increment = 1, Callback = function() end }); c.Name = c.Name or c.Title
        local R = Row(Box, 6)
        local Text = Cap(R, c.Title, 0.26, 0.38)
        Stroke(R, 0.95)
        local Val = Txt(R, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.26), Size = UDim2.fromScale(0.95, 0.35), ZIndex = 18, TextXAlignment = XR, TextTransparency = 0.5 })
        local Track = Inset(R, 0.75, 0.29)
        local Fill = New("Frame", { BackgroundTransparency = 0.5, ZIndex = 17 }, Track)
        Corner(Fill, Cfg.Corner.Element)
        local value = c.Default
        local function Render(v)
            value = v
            Val.Text = v .. "/" .. c.Max
            Tween(Fill, 0.1, { Size = UDim2.fromScale((v - c.Min) / (c.Max - c.Min), 1) })
        end
        local function Set(v)
            v = math.clamp(math.round((v - c.Min) / c.Increment) * c.Increment + c.Min, c.Min, c.Max)
            v = math.round(v * 1000) / 1000
            Render(v); c.Callback(v)
        end
        Render(c.Default)
        local holding = false
        local function Drag(i) Set(c.Min + (c.Max - c.Min) * math.clamp((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)) end
        Track.InputBegan:Connect(function(i) if Pointer(i) then holding = true; Drag(i); Tween(Text, 0.1, { TextTransparency = 0 }) end end)
        Window:Bind(UIS.InputEnded, function(i) if holding and Pointer(i) then holding = false; Tween(Text, 0.1, { TextTransparency = 0.3 }) end end)
        Window:Bind(UIS.InputChanged, function(i)
            if holding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Drag(i) end
        end)
        return Add({ Name = c.Name, Get = function() return value end, Set = Set, Visible = function(v) R.Visible = v end })
    end

    function Obj:NewDropdown(c)
        c = Merge(c, { Title = "Dropdown", Data = { "One", "Two", "Three", "Four" }, Default = "Two", Callback = function() end }); c.Name = c.Name or c.Title
        local R = Row(Box, 5)
        Cap(R, c.Title, 0.2, 0.32); Stroke(R, 0.95)
        local Boxf = Inset(R, 0.7, 0.375)
        local Val = Txt(Boxf, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 0.8), ZIndex = 18, Text = tostring(c.Default or "NONE"), TextTransparency = 0.5 })
        Boxf.MouseEnter:Connect(function() Tween(Val, 0.3, { TextTransparency = 0.1 }) end)
        Boxf.MouseLeave:Connect(function() Tween(Val, 0.3, { TextTransparency = 0.5 }) end)
        local function Set(v) c.Default = v; Val.Text = tostring(v); c.Callback(v) end
        local function Open() Window.Popup.Open(Boxf, c.Data, c.Default, Set) end
        Click(R, 25).MouseButton1Click:Connect(Open)
        return Add({
            Name = c.Name, Get = function() return c.Default end, Set = Set, Open = Open,
            Close = function() Window.Popup.Close() end,
            Visible = function(v) R.Visible = v end,
            SetOptions = function(t) c.Data = t end,
            Clear = function() c.Data = {} end,
            Refresh = function(t) if t then c.Data = t end; Window.Popup.Close(); Open() end,
        })
    end

    function Obj:NewTextbox(c)
        c = Merge(c, { Title = "Textbox", Default = "", FileType = "", Placeholder = "", Callback = function() end }); c.Name = c.Name or c.Title
        local R = Row(Box, 5)
        Cap(R, c.Title, 0.2, 0.32); Stroke(R, 0.95)
        local Boxf = Inset(R, 0.7, 0.375)
        Txt(Boxf, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.8), ZIndex = 18, Text = c.FileType, TextXAlignment = XR, TextTransparency = 0.1 })
        local T = New("TextBox", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.426, 0.5), Size = UDim2.fromScale(0.753, 0.8), ZIndex = 35, ClearTextOnFocus = false, Text = tostring(c.Default), PlaceholderText = c.Placeholder, TextTransparency = 0.6, TextXAlignment = XL }, Boxf)
        T.FocusLost:Connect(function(enter) if enter then c.Callback(T.Text) end end)
        return Add({ Name = c.Name, Get = function() return T.Text end, Set = function(v) T.Text = v end, Visible = function(v) R.Visible = v end })
    end

    function Obj:NewTitle(text)
        text = type(text) == "table" and (text.Title or text.Text) or text
        local R = Row(Box, 8)
        local T = Cap(R, text, 0.5, 0.6)
        In(T, "TextTransparency", 0.25, 0.5)
        return { Set = function(s) T.Text = s end, Visible = function(v) R.Visible = v end }
    end
    Obj.NewLabel = Obj.NewTitle

    function Obj:NewImage(c)
        c = Merge(c, { ImageId = "rbxassetid://0", Size = UDim2.new(0.98, 0, 0.5, 0) })
        local R = Row(Box, 2.5)
        R.Size = c.Size
        local I = New("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 18, Image = c.ImageId, ScaleType = Enum.ScaleType.Fit }, R)
        Fade(I, ICONFADE); In(I, "ImageTransparency", 0, 0.5)
        return { SetImage = function(id) I.Image = id end, Visible = function(v) R.Visible = v end }
    end
end

----------------------------------------------------------------------
-- الاشعارات
----------------------------------------------------------------------
local NotifyList
function Library.Notify(c)
    c = Merge(c, { Title = "Notification", Description = "Description", Duration = 5, Icon = "rbxassetid://8997385628" })
    if not NotifyList or not NotifyList.Parent then
        local g = New("ScreenGui", { Name = HttpService:GenerateGUID(false), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = true }, Root)
        NotifyList = New("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(0.98, 0.98), Size = UDim2.fromScale(0.25, 0.5) }, g)
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5) }, NotifyList)
    end
    local mobile = UIS.TouchEnabled
    local card = New("Frame", { BackgroundColor3 = BLACK, Size = mobile and UDim2.fromScale(0.8, 0.2) or UDim2.fromScale(1, 0.15), ClipsDescendants = true }, NotifyList)
    Corner(card, 4)
    local tx = mobile and 0.25 or 0.2
    local icon = New("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.05, 0.5), Size = mobile and UDim2.fromOffset(30, 30) or UDim2.fromOffset(60, 60), Image = Img(c.Icon), ImageTransparency = 1 }, card)
    Corner(icon, 4)
    local title = New("TextLabel", { Position = UDim2.fromScale(tx, 0.1), Size = UDim2.fromScale(0.8, 0.3), Text = c.Title, TextXAlignment = XL, TextTransparency = 1 }, card)
    local desc = New("TextLabel", { Position = UDim2.fromScale(tx, 0.4), Size = UDim2.fromScale(0.8, 0.5), Text = c.Description, TextScaled = false, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = XL, TextYAlignment = Enum.TextYAlignment.Top, TextTransparency = 1 }, card)
    Tween(card, 0.5, { BackgroundTransparency = 0.35 })
    Tween(icon, 0.5, { ImageTransparency = 0 }); Tween(title, 0.5, { TextTransparency = 0 }); Tween(desc, 0.5, { TextTransparency = 0 })
    task.delay(c.Duration, function()
        Tween(card, 0.5, { BackgroundTransparency = 1 })
        Tween(icon, 0.5, { ImageTransparency = 1 }); Tween(title, 0.5, { TextTransparency = 1 }); Tween(desc, 0.5, { TextTransparency = 1 })
        task.delay(0.6, card.Destroy, card)
    end)
end
Library.Notification = function() return { new = Library.Notify } end -- توافق مع الاصدار القديم

----------------------------------------------------------------------
-- النافذة
----------------------------------------------------------------------
function Library.new(user)
    Cfg = Merge(user, Config)
    Cfg.Corner = Merge(Cfg.Corner, Config.Corner)
    Theme = Themes[Cfg.Theme] or Themes.Crimson
    table.clear(Tinted)
    if Cfg.LowQualitySolid and Cfg.Blur then
        pcall(function()
            if UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value < 8 then Cfg.Opacity = 1 end
        end)
    end

    local Window = { Tabs = {}, Conns = {}, WindowToggle = true, Keybind = Cfg.Keybind, ConfigFolder = Cfg.ConfigFolder,
        OpenPosition = UDim2.fromScale(0.5, 0.5), LastPosition = UDim2.fromScale(0.5, 0.05) }
    function Window:Bind(sig, fn) local c = sig:Connect(fn); table.insert(self.Conns, c); return c end

    local Gui = New("ScreenGui", { Name = "RobloxGameGui", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = true }, Root)
    local Main = New("Frame", { Name = "MainFrame", AnchorPoint = Vector2.new(0.5, 0.5), Position = Window.OpenPosition, Size = UDim2.fromOffset(Cfg.Size.X.Offset, Cfg.Size.Y.Offset), ClipsDescendants = true, Active = true }, Gui)
    Tint(Main, "BackgroundColor3", "Window")
    Tween(Main, 0.5, { BackgroundTransparency = 1 - Cfg.Opacity, Size = Cfg.Size })
    local MainCorner = Corner(Main, Cfg.Corner.Window)
    local Sh = Shadow(Main, 47, 1, 0); Tint(Sh, "ImageColor3", "Shadow"); Tween(Sh, 0.3, { ImageTransparency = 0.6 })
    Window.Blur = Blur(Main)
    local Content = New("Frame", { Name = "Content", Size = UDim2.fromScale(1, 1) }, Main)

    -- الهيدر + الخطوط
    local Head = New("Frame", { Name = "Headers", Position = UDim2.new(0.01, 0, 0.015, 0), Size = UDim2.new(0.3, 0, 0.1784, 0), ClipsDescendants = true, ZIndex = 3 }, Content)
    Tint(Head, "BackgroundColor3", "Panel"); In(Head, "BackgroundTransparency", 0.5); Corner(Head, 4)
    In(New("ImageLabel", { Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.95, 0.95), ZIndex = 4, Image = Cfg.Logo, ScaleType = Enum.ScaleType.Crop }, Head), "ImageTransparency", 0)
    In(New("TextLabel", { Name = "Title", Position = UDim2.new(0.32757, 0, 0.01266, 0), Size = UDim2.new(0.671, 0, 0.05187, 0), Text = Cfg.Title, TextXAlignment = XL }, Content), "TextTransparency", 0)
    In(New("TextLabel", { Name = "Description", Position = UDim2.new(0.32757, 0, 0.0709, 0), Size = UDim2.new(0.671, 0, 0.02908, 0), Text = Cfg.Description, TextXAlignment = XL }, Content), "TextTransparency", 0.5)
    for _, l in ipairs({
        Line(Content, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.317, 0, 0.5, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 3 }, Seq({ 0, 1 }, { 0.05, 0 }, { 0.96, 0 }, { 1, 1 }), 90),
        Line(Content, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.317, 0, 0.12006, 0), Size = UDim2.new(0.683, 0, 0, 1), ZIndex = 3 }, Seq({ 0, 0 }, { 0.98, 0 }, { 1, 1 }), 0),
        Line(Content, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(-0.001, 0, 0.205, 0), Size = UDim2.new(0.31847, 0, 0, 1), ZIndex = 3 }, Seq({ 0, 0 }, { 0.98, 0 }, { 1, 1 }), -180),
    }) do Tint(l, "BackgroundColor3", "Accent"); In(l, "BackgroundTransparency", 0.8) end

    -- قائمة التابات + منطقة المحتوى
    local TabBox = New("Frame", { Name = "TabButtonFrame", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.16, 0, 0.215, 0), Size = UDim2.new(0.3, 0, 0.775, 0), ClipsDescendants = true }, Content)
    Tint(TabBox, "BackgroundColor3", "Panel"); In(TabBox, "BackgroundTransparency", 0.5); Corner(TabBox, Cfg.Corner.Panel)
    local TabList = New("ScrollingFrame", { Name = "TabButtons", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.97, 0.97), ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = false, Active = true }, TabBox)
    New("UIListLayout", { HorizontalAlignment = CENTER, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, TabList)
    local Pages = New("Frame", { Name = "MainTabFrame", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.658, 0, 0.131, 0), Size = UDim2.new(0.67, 0, 0.86, 0), ClipsDescendants = true }, Content)
    Tint(Pages, "BackgroundColor3", "Panel"); In(Pages, "BackgroundTransparency", 0.5); Corner(Pages, Cfg.Corner.Panel)

    -- منطقة السحب + زر التصغير
    local Drag = New("Frame", { Name = "InputFrame", Size = UDim2.new(1, 0, 0.12, 0), ZIndex = 15 }, Main)
    local Toggle = New("ImageButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(0.9925, 0, 0.01, 0), Size = UIS.TouchEnabled and UDim2.fromScale(0.12, 0.12) or UDim2.fromScale(0.085, 0.085), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 50, Image = "rbxassetid://10002398990" }, Main)
    In(Toggle, "ImageTransparency", 0.5, 0.5)
    local Home = New("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.7, 0.7), ZIndex = 49, Image = Cfg.HomeIcon, ImageTransparency = 1 }, Toggle)

    function Window:Toggle(on)
        if on == nil then on = not self.WindowToggle end
        self.WindowToggle = on
        self.Popup.Close()
        if on then
            Content.Visible = true
            Drag.Size = UDim2.new(1, 0, 0.12, 0)
            Tween(Main, 0.7, { BackgroundTransparency = 1 - Cfg.Opacity, Size = Cfg.Size })
            Tween(Main, 0.3, { Position = self.OpenPosition })
            Tween(MainCorner, 0.5, { CornerRadius = UDim.new(0, Cfg.Corner.Window) })
            Tween(Sh, 0.5, { ImageTransparency = 0.6 })
            Tween(Toggle, 0.4, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(0.9925, 0, 0.01, 0), Size = UIS.TouchEnabled and UDim2.fromScale(0.12, 0.12) or UDim2.fromScale(0.085, 0.085), ImageTransparency = 0.5 })
            Tween(Home, 0.3, { ImageTransparency = 1 })
            self.Blur.SetEnabled(Cfg.Blur)
        else
            self.OpenPosition = Main.Position
            Drag.Size = UDim2.fromScale(1, 1)
            Tween(Main, 0.5, { BackgroundTransparency = 1, Size = UDim2.new(0.085, 10, 0.05, 0) })
            Tween(Main, 0.3, { Position = self.LastPosition })
            Tween(MainCorner, 0.5, { CornerRadius = UDim.new(0.1, 0) })
            Tween(Sh, 0.5, { ImageTransparency = 1 })
            Tween(Toggle, 0.4, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ImageTransparency = 1 })
            Tween(Home, 0.5, { ImageTransparency = 0.5 })
            self.Blur.SetEnabled(false)
            task.delay(0.25, function() if not self.WindowToggle then Content.Visible = false end end)
        end
        local cb = self.OnToggle or self.ToggleButton
        if cb then cb(on) end
    end
    Toggle.MouseButton1Click:Connect(function() Window:Toggle() end)
    Window:Bind(UIS.InputBegan, function(i, gp) if not gp and i.KeyCode == Window.Keybind then Window:Toggle() end end)
    Window.Popup = Popup(Gui, Window)

    -- سحب النافذة
    local dragging, dStart, pStart
    Drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dStart, pStart = true, i.Position, Main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Window:Bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            local p = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)
            Tween(Main, 0.1, { Position = p })
            if Window.WindowToggle then Window.OpenPosition = p else Window.LastPosition = p end
        end
    end)

    -- التابات
    function Window:NewTab(c)
        c = Merge(c, { Title = "Example", Description = "Tab: " .. (#Window.Tabs + 1), Icon = Cfg.DefaultIcon })
        local Tab = { Sections = {} }
        local Btn = New("Frame", { Name = "TabButton", BackgroundColor3 = BLACK, Size = UDim2.new(0.97, 0, 0.5, 0), ZIndex = 5, ClipsDescendants = true }, TabList)
        New("UIAspectRatioConstraint", { AspectRatio = 4.25, AspectType = FIT }, Btn)
        Corner(Btn, Cfg.Corner.Panel); Tween(Btn, 0.3, { BackgroundTransparency = 0.75 })
        local Icon = New("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.1, 0.5), Size = UDim2.fromScale(0.6, 0.6), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 6, Image = Img(c.Icon) }, Btn)
        Corner(Icon, 3); Fade(Icon, ICONFADE)
        local Title = Txt(Btn, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.2, 0.375), Size = UDim2.fromScale(1, 0.4), Text = c.Title, TextXAlignment = XL })
        local Desc = Txt(Btn, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.2, 0.7), Size = UDim2.fromScale(1, 0.3), Text = c.Description, TextXAlignment = XL })
        local Mark = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1.1, 0.4), Size = UDim2.fromScale(0.055, 0.7), ZIndex = 6 }, Btn)
        Tint(Mark, "BackgroundColor3", "Accent"); Corner(Mark, Cfg.Corner.Panel); Fade(Mark); Tween(Mark, 0.3, { BackgroundTransparency = 0.1 })

        local Page = New("Frame", { Name = "Init", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.98, 0.98), ZIndex = 4 }, Pages)
        local function Column(x)
            local s = New("ScrollingFrame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.5), Size = UDim2.fromScale(0.5, 1), ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = false, Active = true }, Page)
            New("UIListLayout", { HorizontalAlignment = CENTER, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, s)
            return s
        end
        local ColL, ColR = Column(0.25), Column(0.75)

        local function Select(on)
            Page.Visible = on
            Tween(Icon, 0.3, { ImageTransparency = on and 0.1 or 0.25 })
            Tween(Title, 0.3, { TextTransparency = on and 0 or 0.25 })
            Tween(Desc, 0.3, { TextTransparency = on and 0.5 or 0.65 })
            Tween(Mark, 0.3, { Position = on and UDim2.fromScale(1.025, 0.5) or UDim2.fromScale(1.1, 0.4) })
        end
        Select(#Window.Tabs == 0)
        table.insert(Window.Tabs, { Page = Page, Select = Select, Sections = Tab.Sections })
        Click(Btn).MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do t.Select(t.Page == Page) end
        end)

        -- قسم عادي
        function Tab:NewSection(s)
            s = Merge(s, { Position = "Left", Title = "Section", Icon = Cfg.DefaultIcon })
            local Sec = {}
            local F = New("Frame", { Name = "Section", BackgroundColor3 = BLACK, Size = UDim2.new(0.98, 0, 0, 200), ClipsDescendants = true }, s.Position == "Left" and ColL or ColR)
            Corner(F, Cfg.Corner.Panel); Tween(F, 0.5, { BackgroundTransparency = 0.75 })
            local H = New("Frame", { Name = "Header", BackgroundColor3 = BLACK, BackgroundTransparency = 0.9, Size = UDim2.fromScale(1, 0.5) }, F)
            New("UIAspectRatioConstraint", { AspectRatio = 8, AspectType = FIT }, H); Corner(H, Cfg.Corner.Panel)
            Fade(Corner(New("ImageLabel", { Name = "Icon", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.065, 0.5), Size = UDim2.fromScale(0.6, 0.6), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 6, Image = Img(s.Icon) }, H), Cfg.Corner.Panel).Parent, ICONFADE)
            Line(H, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, BackgroundTransparency = 0.8 }, Seq({ 0, 1 }, { 0.1, 0 }, { 0.9, 0 }, { 1, 1 }), 0)
            In(Txt(H, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.125, 0.45), Size = UDim2.fromScale(1, 0.5), Text = s.Title, TextXAlignment = XL }), "TextTransparency", 0)
            local L = New("UIListLayout", { HorizontalAlignment = CENTER, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, F)
            L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Tween(F, 0.1, { Size = UDim2.new(0.98, 0, 0, math.max(L.AbsoluteContentSize.Y, 50) + 3.36) })
            end)
            local St = Stroke(F, 1); Tween(St, 0.5, { Transparency = 0.9 })
            Fade(St, Seq({ 0, 0 }, { 0.17, 1 }, { 0.82, 1 }, { 1, 0 }))
            table.insert(Tab.Sections, Sec)
            Mixin(Sec, F, Window)
            return Sec
        end

        -- قسم قابل للطي
        function Tab:NewCollapsibleSection(s)
            s = Merge(s, { Position = "Left", Title = "Collapsible Section", Icon = Cfg.DefaultIcon, DefaultOpen = true })
            local Sec, open = {}, s.DefaultOpen
            local F = New("Frame", { Name = "Collapsible", BackgroundColor3 = BLACK, Size = UDim2.new(0.98, 0, 0, 30), ClipsDescendants = true }, s.Position == "Left" and ColL or ColR)
            Corner(F, Cfg.Corner.Panel); Tween(F, 0.5, { BackgroundTransparency = 0.75 })
            local H = New("Frame", { Name = "Header", BackgroundColor3 = BLACK, BackgroundTransparency = 0.9, Size = UDim2.new(1, 0, 0, 30) }, F)
            Corner(H, Cfg.Corner.Panel)
            Fade(Corner(New("ImageLabel", { Name = "Icon", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.065, 0.5), Size = UDim2.fromScale(0.6, 0.6), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 6, Image = Img(s.Icon) }, H), Cfg.Corner.Panel).Parent, ICONFADE)
            Line(H, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, BackgroundTransparency = 0.8 }, Seq({ 0, 1 }, { 0.1, 0 }, { 0.9, 0 }, { 1, 1 }), 0)
            Txt(H, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.125, 0.45), Size = UDim2.fromScale(0.85, 0.5), Text = s.Title, TextXAlignment = XL })
            local Arrow = New("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.975, 0.5), Size = UDim2.fromScale(0.6, 0.6), SizeConstraint = Enum.SizeConstraint.RelativeYY, ZIndex = 6, Text = ">", Rotation = open and -90 or 90, TextTransparency = 0.3 }, H)
            local C = New("Frame", { Name = "Content", Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 1, -30), Visible = open }, F)
            local L = New("UIListLayout", { HorizontalAlignment = CENTER, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, C)
            local function Resize()
                Tween(F, 0.3, { Size = UDim2.new(0.98, 0, 0, 30 + (open and L.AbsoluteContentSize.Y + 3 or 0)) })
            end
            L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)
            Click(H, 10).MouseButton1Click:Connect(function()
                open = not open
                if open then C.Visible = true end
                Tween(Arrow, 0.3, { Rotation = open and -90 or 90 })
                Resize()
                task.delay(0.3, function() if not open then C.Visible = false end end)
            end)
            local St = Stroke(F, 0.9)
            Fade(St, Seq({ 0, 0 }, { 0.17, 1 }, { 0.82, 1 }, { 1, 0 }))
            table.insert(Tab.Sections, Sec)
            Mixin(Sec, C, Window)
            return Sec
        end
        return Tab
    end

    -- الاعدادات (حفظ / تحميل)
    function Window:GetAllElements()
        local all = {}
        for _, t in ipairs(self.Tabs) do
            for _, s in ipairs(t.Sections) do for _, e in ipairs(s.Elements) do all[#all + 1] = e end end
        end
        return all
    end
    function Window:GetConfig()
        local cfg = {}
        for _, e in ipairs(self:GetAllElements()) do if e.Name then cfg[e.Name] = e.Get() end end
        return cfg
    end
    function Window:SetConfig(cfg)
        for _, e in ipairs(self:GetAllElements()) do if e.Name and cfg[e.Name] ~= nil then e.Set(cfg[e.Name]) end end
    end
    pcall(function() if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end end)
    local function File(n) return Window.ConfigFolder .. "/" .. n .. ".json" end
    Window.SaveConfig = function(n) writefile(File(n), HttpService:JSONEncode(Window:GetConfig())) end
    Window.LoadConfig = function(n) if isfile(File(n)) then Window:SetConfig(HttpService:JSONDecode(readfile(File(n)))) end end
    Window.DeleteConfig = function(n) if isfile(File(n)) then delfile(File(n)) end end
    Window.ListConfigs = function()
        local names = {}
        for _, f in ipairs(listfiles(Window.ConfigFolder) or {}) do
            local n = f:match("([^/\\]+)%.json$")
            if n then names[#names + 1] = n end
        end
        return names
    end

    -- تغيير المظهر والاعدادات اثناء التشغيل
    function Window:SetKeybind(k) self.Keybind = k end
    function Window:SetTheme(name)
        local t = Themes[name]; if not t then return end
        Theme = t
        for i = #Tinted, 1, -1 do
            local e = Tinted[i]
            if e[1].Parent then e[1][e[2]] = t[e[3]] else table.remove(Tinted, i) end
        end
    end
    function Window:SetOpacity(o)
        Cfg.Opacity = math.clamp(o, 0.35, 1)
        if self.WindowToggle then Tween(Main, 0.2, { BackgroundTransparency = 1 - Cfg.Opacity }) end
    end
    function Window:SetBlur(on) Cfg.Blur = on; if self.WindowToggle then self.Blur.SetEnabled(on) end end
    function Window:Destroy()
        for _, c in ipairs(self.Conns) do c:Disconnect() end
        self.Blur.Destroy(); Gui:Destroy()
    end

    if Cfg.SettingsTab then
        local names = {}
        for n in pairs(Themes) do names[#names + 1] = n end
        table.sort(names)
        local S = Window:NewTab({ Title = Cfg.SettingsTabName, Description = "Appearance" }):NewSection({ Title = "Appearance" })
        S:NewSlider({ Title = "Opacity", Min = 35, Max = 100, Default = math.floor(Cfg.Opacity * 100 + 0.5), Callback = function(v) Window:SetOpacity(v / 100) end })
        S:NewDropdown({ Title = "Theme", Data = names, Default = Cfg.Theme, Callback = function(v) Window:SetTheme(v) end })
        S:NewKeybind({ Title = "Toggle Key", Default = Window.Keybind, Callback = function(k) Window:SetKeybind(k) end })
        S:NewToggle({ Title = "Blur", Default = Cfg.Blur, Callback = function(v) Window:SetBlur(v) end })
    end

    return Window
end

return table.freeze(Library)
