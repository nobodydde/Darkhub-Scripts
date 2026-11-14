-- Darkhub UI Library  v2
-- Load with:  local UI = loadstring(game:HttpGet("<raw github url>/Library.lua"))()
--
-- Optional settings. Set any of these BEFORE the loadstring line:
--   getgenv().DarkhubGame         = "Arsenal"                    -- sidebar subtitle
--   getgenv().DarkhubKeybind      = Enum.KeyCode.RightShift      -- open/close key (a name works too: "RightShift")
--   getgenv().DarkhubTheme        = "Darkhub Red"                      -- starting theme (any name in UI.themeNames)
--   getgenv().DarkhubAccent       = Color3.fromRGB(46,125,255)   -- or an exact starting color
--   getgenv().DarkhubResetPresets = true                         -- wipe every saved preset when the script runs
local Players, TS, UIS, RS, HS = game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("HttpService")
local plr = Players.LocalPlayer
local old = plr:WaitForChild("PlayerGui"):FindFirstChild("Darkhub")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "Darkhub", false, true, 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr.PlayerGui

-- every global connection is tracked, so re-running the script never leaves old keybinds firing
local conns = {}
local function on(sig, f) local c = sig:Connect(f) table.insert(conns, c) return c end
gui.Destroying:Connect(function() for _, c in conns do pcall(function() c:Disconnect() end) end table.clear(conns) end)

---------------- settings (getgenv)
local genv
pcall(function() genv = getgenv() end)
local function setting(k)
	if type(genv) ~= "table" then return nil end
	local ok, v = pcall(function() return genv[k] end)
	if ok then return v end
	return nil
end

local KEY_NAMES = {LeftControl="Left Ctrl", RightControl="Right Ctrl", LeftShift="Left Shift", RightShift="Right Shift", LeftAlt="Left Alt", RightAlt="Right Alt",
	MouseButton2="Right Click", MouseButton3="Middle Click", ButtonR3="R3", ButtonL3="L3", PageUp="Page Up", PageDown="Page Down", CapsLock="Caps Lock"}
local function keyName(k) if typeof(k) ~= "EnumItem" then return tostring(k) end return KEY_NAMES[k.Name] or k.Name end
local function toKey(v)
	if typeof(v) == "EnumItem" and (v.EnumType == Enum.KeyCode or v.EnumType == Enum.UserInputType) then return v end
	if type(v) == "string" then
		local s = v:gsub("%s", "")
		local ok, k = pcall(function() return Enum.KeyCode[s] end)
		if ok and k then return k end
		ok, k = pcall(function() return Enum.UserInputType[s] end)
		if ok and k then return k end
	end
	return nil
end

local GAME_NAME = "Arsenal"
if setting("DarkhubGame") ~= nil then GAME_NAME = tostring(setting("DarkhubGame")) end

local toggleKey = toKey(setting("DarkhubKeybind")) or Enum.KeyCode.LeftControl
if setting("DarkhubKeybind") ~= nil and not toKey(setting("DarkhubKeybind")) then
	warn("[Darkhub] DarkhubKeybind '"..tostring(setting("DarkhubKeybind")).."' isn't a key - using Left Ctrl")
end

---------------- themes
local DEFAULT_ACCENT = Color3.fromRGB(46,125,255)
local THEMES = {
	["Darkhub Blue"]     = DEFAULT_ACCENT,
	["Darkhub Red"]      = Color3.fromRGB(235,55,70),
	["Darkhub Purple"]   = Color3.fromRGB(145,90,255),
	["Darkhub Pink"]     = Color3.fromRGB(255,85,170),
	["Darkhub Rose"]     = Color3.fromRGB(255,95,125),
	["Darkhub Orange"]   = Color3.fromRGB(255,130,45),
	["Darkhub Gold"]     = Color3.fromRGB(245,190,50),
	["Darkhub Yellow"]   = Color3.fromRGB(250,220,70),
	["Darkhub Lime"]     = Color3.fromRGB(150,230,60),
	["Darkhub Green"]    = Color3.fromRGB(50,200,110),
	["Darkhub Mint"]     = Color3.fromRGB(70,225,170),
	["Darkhub Teal"]     = Color3.fromRGB(30,190,180),
	["Darkhub Cyan"]     = Color3.fromRGB(40,200,240),
	["Darkhub Sky"]      = Color3.fromRGB(95,180,255),
	["Darkhub Indigo"]   = Color3.fromRGB(95,100,255),
	["Darkhub Violet"]   = Color3.fromRGB(180,100,240),
	["Darkhub Magenta"]  = Color3.fromRGB(225,70,220),
	["Darkhub Crimson"]  = Color3.fromRGB(190,25,55),
	["Darkhub Brown"]    = Color3.fromRGB(190,120,75),
	["Darkhub Silver"]   = Color3.fromRGB(185,195,215),
	["Darkhub White"]    = Color3.fromRGB(235,240,250),
}

local startAccent = DEFAULT_ACCENT
do
	local th, ac = setting("DarkhubTheme"), setting("DarkhubAccent")
	if typeof(ac) == "Color3" then startAccent = ac
	elseif th ~= nil and THEMES[tostring(th)] then startAccent = THEMES[tostring(th)]
	elseif th ~= nil then warn("[Darkhub] No theme called '"..tostring(th).."' - using Darkhub Blue") end
end

local Lib = {accent = startAccent, version = "2.0"}
local C = {
	bg    = Color3.fromRGB(12,15,22),   -- window
	side  = Color3.fromRGB(9,11,17),    -- sidebar
	card  = Color3.fromRGB(16,20,29),   -- section cards
	hover = Color3.fromRGB(24,29,41),   -- selected / hovered
	elem  = Color3.fromRGB(21,26,37),   -- inputs, boxes, buttons
	line  = Color3.fromRGB(31,37,51),   -- borders + dividers
	text  = Color3.fromRGB(236,240,248),
	sub   = Color3.fromRGB(152,162,182),
	dim   = Color3.fromRGB(96,106,128),
}
local FAM, W = "rbxasset://fonts/families/Montserrat.json", Enum.FontWeight
local AY = Enum.AutomaticSize.Y
local painters, tabs, current = {}, {}, nil
local touch = UIS.TouchEnabled
local TOUCH_PAD = touch and 6 or 0 -- bigger rows / hit areas on phones and tablets

---------------- helpers
local function tw(o, p, t, style, dir)
	local tween = TS:Create(o, TweenInfo.new(t or .25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
	tween:Play() return tween
end
local function new(c, p, ...)
	local i = Instance.new(c)
	for k, v in p do if k ~= "Parent" then i[k] = v end end
	for _, k in {...} do k.Parent = i end
	i.Parent = p.Parent
	return i
end
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}) end
local function stroke(col, tr) return new("UIStroke", {Name="S", Color=col or C.line, Transparency=tr or 0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function grad(a, b, rot) return new("UIGradient", {Rotation = rot or 90, Color = ColorSequence.new(a, b)}) end
local function pad(l, t, b) return new("UIPadding", {PaddingLeft=UDim.new(0,l), PaddingRight=UDim.new(0,l), PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or t or 0)}) end
local function list(gap) return new("UIListLayout", {Padding = UDim.new(0, gap or 0), SortOrder = Enum.SortOrder.LayoutOrder}) end
local function hlist(gap, align)
	return new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center,
		HorizontalAlignment=align or Enum.HorizontalAlignment.Left, Padding=UDim.new(0, gap or 0), SortOrder=Enum.SortOrder.LayoutOrder})
end
local function text(t, size, col, w, p)
	p = p or {}
	p.BackgroundTransparency, p.Text, p.TextSize, p.TextColor3 = 1, t, size, col
	p.FontFace = Font.new(FAM, w or W.Regular)
	p.TextXAlignment = p.TextXAlignment or Enum.TextXAlignment.Left
	return new("TextLabel", p)
end
local function paint(f) table.insert(painters, f) f(Lib.accent, true) end
local function accent(i, prop) paint(function(c, now) if now then i[prop] = c else tw(i, {[prop] = c}, .4) end end) return i end
local function accentGrad(i) -- accent fill with a soft dark-to-light sheen
	i.BackgroundColor3 = Color3.new(1,1,1)
	local g = new("UIGradient", {Parent=i, Rotation=0})
	paint(function(c) g.Color = ColorSequence.new(c:Lerp(Color3.new(0,0,0),.22), c:Lerp(Color3.new(1,1,1),.12)) end)
	return i
end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local leaves = {} -- every "mouse left" effect, so touch screens can clear stuck highlights
local function onLeave(o, f) o.MouseLeave:Connect(f) table.insert(leaves, {o, f}) end
local fadeEdges = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(.5,0), NumberSequenceKeypoint.new(1,1)})
-- theme logos: the swirl recolored for every theme. A custom accent color uses the closest one.
local LOGO_IDS = {
	["Darkhub Blue"]     = "rbxassetid://88022401621783",
	["Darkhub Red"]      = "rbxassetid://126488767889957",
	["Darkhub Purple"]   = "rbxassetid://116556846774406",
	["Darkhub Pink"]     = "rbxassetid://76974246617829",
	["Darkhub Rose"]     = "rbxassetid://108154237461406",
	["Darkhub Orange"]   = "rbxassetid://90170526520348",
	["Darkhub Gold"]     = "rbxassetid://115251976456907",
	["Darkhub Yellow"]   = "rbxassetid://90077256437642",
	["Darkhub Lime"]     = "rbxassetid://78108287151774",
	["Darkhub Green"]    = "rbxassetid://136888995344546",
	["Darkhub Mint"]     = "rbxassetid://119680775223298",
	["Darkhub Teal"]     = "rbxassetid://128459876058630",
	["Darkhub Cyan"]     = "rbxassetid://95027884641816",
	["Darkhub Sky"]      = "rbxassetid://97988060540899",
	["Darkhub Indigo"]   = "rbxassetid://104804435127923",
	["Darkhub Violet"]   = "rbxassetid://132682631079793",
	["Darkhub Magenta"]  = "rbxassetid://103974805044045",
	["Darkhub Crimson"]  = "rbxassetid://125280890066582",
	["Darkhub Brown"]    = "rbxassetid://77738904072442",
	["Darkhub Silver"]   = "rbxassetid://83054095884776",
	["Darkhub White"]    = "rbxassetid://82261329980293",
}
local FALLBACK_LOGO = "rbxassetid://129745620825874"
local logoImages, currentLogo = {}, nil
local function nearestLogo(c)
	local best, bd = nil, math.huge
	for n, col in THEMES do
		local id = LOGO_IDS[n]
		if id and not id:find("LOGO_") then
			local d = (col.R-c.R)^2 + (col.G-c.G)^2 + (col.B-c.B)^2
			if d < bd then best, bd = id, d end
		end
	end
	return best or FALLBACK_LOGO
end
local function logoImage(img) table.insert(logoImages, img) img.Image = currentLogo or nearestLogo(Lib.accent) return img end
paint(function(c) currentLogo = nearestLogo(c) for _, i in logoImages do i.Image = currentLogo end end)
local function isImage(s) return type(s) == "string" and (s:find("^rbxasset") ~= nil or s:find("^rbxthumb") ~= nil or s:find("^http") ~= nil) end

-- tiny vector icons drawn from frames (no image uploads needed, crisp at every scale)
local function seg(parent, x1, y1, x2, y2, col, th)
	th = th or 1.5
	local dx, dy = x2 - x1, y2 - y1
	return new("Frame", {Parent=parent, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromOffset((x1+x2)/2, (y1+y2)/2),
		Size=UDim2.fromOffset(math.sqrt(dx*dx + dy*dy) + th, th), Rotation=math.deg(math.atan2(dy, dx)), BackgroundColor3=col, BorderSizePixel=0}, corner(th/2))
end
local function ringStroke(parent, x, y, s, col, th)
	local f = new("Frame", {Parent=parent, Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(s,s), BackgroundTransparency=1}, corner(s/2))
	return new("UIStroke", {Parent=f, Color=col, Thickness=th or 1.4})
end
local function dot(parent, x, y, w, h, col, r)
	return new("Frame", {Parent=parent, Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h), BackgroundColor3=col, BorderSizePixel=0}, corner(r or 1.5))
end
local function glyph(kind, parent, col, props)
	props = props or {}
	props.Parent, props.Size, props.BackgroundTransparency = parent, UDim2.fromOffset(14,14), 1
	props.Name = props.Name or "Glyph"
	local g = new("Frame", props)
	local parts = {}
	local function add(o) table.insert(parts, o) return o end
	if kind == "search" then
		add(ringStroke(g, 2, 2, 7, col)) add(seg(g, 9.5, 9.5, 12.5, 12.5, col, 1.5))
	elseif kind == "fps" then
		local pts = {{1,8},{4,8},{6,3.5},{8.5,11},{10.5,7},{13,7}}
		for i = 1, #pts - 1 do add(seg(g, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], col, 1.4)) end
	elseif kind == "ping" then
		for i, h in {4, 7, 10} do add(dot(g, 1.5 + (i-1)*4.3, 12.5 - h, 2.4, h, col, 1)) end
	elseif kind == "players" then
		add(ringStroke(g, 5, 1.5, 4, col))
		local clip = new("Frame", {Parent=g, Size=UDim2.fromOffset(14,13.4), BackgroundTransparency=1, ClipsDescendants=true})
		add(ringStroke(clip, 2.5, 9.2, 9, col))
	elseif kind == "sliders" then
		add(seg(g, 1, 4, 13, 4, col, 1.3)) add(seg(g, 1, 10, 13, 10, col, 1.3))
		add(dot(g, 7.5, 2, 4, 4, col, 2)) add(dot(g, 2.5, 8, 4, 4, col, 2))
	elseif kind == "grid" then
		for _, p in {{1.5,1.5},{8,1.5},{1.5,8},{8,8}} do add(dot(g, p[1], p[2], 4.5, 4.5, col, 1.5)) end
	end
	return g, parts
end
local function recolor(parts, col, t)
	for _, p in parts do
		local prop = p:IsA("UIStroke") and "Color" or "BackgroundColor3"
		if t == 0 then p[prop] = col else tw(p, {[prop] = col}, t or .2) end
	end
end
-- an icon slot that accepts an emoji/text, an image id, or nothing (falls back to a drawn glyph)
local function iconInto(parent, icon, fallback, col, size)
	if isImage(icon) then
		return new("ImageLabel", {Parent=parent, Name="Img", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(size or 16, size or 16),
			BackgroundTransparency=1, Image=icon, ImageColor3=col, ZIndex=2}), nil
	elseif icon ~= nil and icon ~= "" then
		return text(tostring(icon), size or 14, col, W.Medium, {Parent=parent, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=2}), nil
	end
	local g, parts = glyph(fallback, parent, col, {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), ZIndex=2})
	return g, parts
end

---------------- window
local SIZE = Vector2.new(940, 580)
local SIDE_W, TOP_H = 220, 56
local holder = new("Frame", {Parent=gui, Name="Window", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(SIZE.X, SIZE.Y), BackgroundTransparency=1}, new("UIScale", {}))
local scale = holder.UIScale
local shadows = {}
local function shadowT(i) return .8 + i*.03 end
for i = 1, 6 do -- soft drop shadow from layered rounded frames (no images)
	shadows[i] = new("Frame", {Parent=holder, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,4+i*2), Size=UDim2.new(1,i*8,1,i*8),
		BackgroundColor3=Color3.new(), BackgroundTransparency=shadowT(i), ZIndex=0}, corner(16+i*4))
end

local main = new("Frame", {Parent=holder, Name="Main", Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(1,1,1)}, corner(14))
local mainGrad = new("UIGradient", {Parent=main, Rotation=90})
paint(function(c)
	mainGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.bg:Lerp(c,.11)), ColorSequenceKeypoint.new(.28, C.bg:Lerp(c,.03)),
		ColorSequenceKeypoint.new(1, C.bg:Lerp(Color3.new(),.3))})
end)
new("UIStroke", {Parent=main, Color=Color3.new(1,1,1), Transparency=.86, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, new("UIGradient", {Rotation=90, Transparency=NumberSequence.new(0,.85)}))

-- sidebar
local sideTop, sideBot = C.side:Lerp(Color3.new(1,1,1),.025), C.side
local side = new("Frame", {Parent=main, Name="Sidebar", Size=UDim2.new(0,SIDE_W,1,0), BackgroundColor3=Color3.new(1,1,1)}, corner(14), grad(sideTop, sideBot))
new("Frame", {Parent=side, Position=UDim2.new(1,-14,0,0), Size=UDim2.new(0,14,1,0), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0}, grad(sideTop, sideBot))
new("Frame", {Parent=side, Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,1,1,0), BackgroundColor3=C.line, BorderSizePixel=0})

-- logo: glow sits BEHIND the tile, the image is cropped inside a rounded tile with an accent ring
local LOGO, LX, LY = 40, 16, 16
local logoGlow = accent(new("Frame", {Parent=side, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromOffset(LX+LOGO/2, LY+LOGO/2), Size=UDim2.fromOffset(LOGO+8, LOGO+8), BackgroundTransparency=.86}, corner(14)), "BackgroundColor3")
local logoTile = new("Frame", {Parent=side, Position=UDim2.fromOffset(LX,LY), Size=UDim2.fromOffset(LOGO,LOGO), BackgroundColor3=Color3.new(1,1,1), ClipsDescendants=true},
	corner(11), grad(C.elem:Lerp(Color3.new(1,1,1),.05), C.side), new("UIScale", {}))
accent(new("UIStroke", {Parent=logoTile, Thickness=1.2, Transparency=.35, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}), "Color")
logoImage(new("ImageLabel", {Parent=logoTile, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromScale(.84,.84), BackgroundTransparency=1, ScaleType=Enum.ScaleType.Fit}))
logoTile.MouseEnter:Connect(function() tw(logoTile.UIScale, {Scale=1.08}, .3, Enum.EasingStyle.Back) end)
onLeave(logoTile, function() tw(logoTile.UIScale, {Scale=1}, .3) end)
local titleL = text("Darkhub", 16, C.text, W.Bold, {Parent=side, Position=UDim2.fromOffset(66,18), Size=UDim2.new(1,-78,0,18)})
local subtitle = text(GAME_NAME, 11, C.dim, W.Medium, {Parent=side, Position=UDim2.fromOffset(66,37), Size=UDim2.new(1,-78,0,13), TextScaled=true})
new("UITextSizeConstraint", {Parent=subtitle, MaxTextSize=11, MinTextSize=8})
function Lib.setSubtitle(s) subtitle.Text = tostring(s) end

local search = new("Frame", {Parent=side, Name="Search", Position=UDim2.fromOffset(12,72), Size=UDim2.new(1,-24,0,34), BackgroundColor3=C.elem, BackgroundTransparency=.25}, corner(8), stroke())
glyph("search", search, C.dim, {AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,10,.5,0)})
local searchBox = new("TextBox", {Parent=search, BackgroundTransparency=1, Position=UDim2.fromOffset(32,0), Size=UDim2.new(1,-62,1,0), Text="", PlaceholderText="Search",
	PlaceholderColor3=C.dim, TextColor3=C.text, TextSize=12, FontFace=Font.new(FAM, W.Medium), TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false})
local keyChip = new("Frame", {Parent=search, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-7,.5,0), Size=UDim2.fromOffset(20,20), BackgroundColor3=C.side}, corner(5), stroke())
text("/", 11, C.sub, W.Medium, {Parent=keyChip, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center})
searchBox.Focused:Connect(function() tw(search.S, {Color=Lib.accent}, .2) end)
searchBox.FocusLost:Connect(function() tw(search.S, {Color=C.line}, .2) end)

local divider = new("Frame", {Parent=side, Position=UDim2.fromOffset(12,118), Size=UDim2.new(1,-24,0,1), BackgroundColor3=C.line, BorderSizePixel=0},
	new("UIGradient", {Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.6), NumberSequenceKeypoint.new(.5,0), NumberSequenceKeypoint.new(1,.6)})}))
local modulesL = text("Modules", 11, C.dim, W.Medium, {Parent=side, Position=UDim2.fromOffset(16,128), Size=UDim2.new(1,-32,0,14)})
local tabList = new("ScrollingFrame", {Parent=side, Position=UDim2.fromOffset(0,148), Size=UDim2.new(1,0,1,-220), BackgroundTransparency=1, BorderSizePixel=0,
	ScrollBarThickness=0, CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, list(4), pad(10,2))

-- profile card (Roblox headshot, with the initial behind it as a fallback)
local prof = new("Frame", {Parent=side, Position=UDim2.new(0,10,1,-62), Size=UDim2.new(1,-20,0,52), BackgroundColor3=C.card, BackgroundTransparency=.1}, corner(10), stroke())
local av = accentGrad(new("Frame", {Parent=prof, Position=UDim2.fromOffset(9,9), Size=UDim2.fromOffset(34,34)}, corner(17)))
text(string.upper(string.sub(plr.DisplayName,1,1)), 14, Color3.new(1,1,1), W.Bold, {Parent=av, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center})
new("ImageLabel", {Parent=av, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=2,
	Image="rbxthumb://type=AvatarHeadShot&id="..tostring(math.max(plr.UserId, 1)).."&w=150&h=150"}, corner(17))
new("Frame", {Parent=av, AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,1,1,1), Size=UDim2.fromOffset(10,10), BackgroundColor3=Color3.fromRGB(70,210,110), ZIndex=3}, corner(5), stroke(C.card))
local nameL = text(plr.DisplayName, 13, C.text, W.Bold, {Parent=prof, Position=UDim2.fromOffset(52,10), Size=UDim2.new(1,-60,0,16), TextTruncate=Enum.TextTruncate.AtEnd})
local userL = text("@"..plr.Name, 11, C.dim, W.Medium, {Parent=prof, Position=UDim2.fromOffset(52,27), Size=UDim2.new(1,-60,0,14), TextTruncate=Enum.TextTruncate.AtEnd})

-- content
local content = new("Frame", {Parent=main, Name="Content", Position=UDim2.fromOffset(SIDE_W+1,0), Size=UDim2.new(1,-(SIDE_W+1),1,0), BackgroundTransparency=1})

-- soft accent glow pooled at the bottom of the content area
local glow = new("Frame", {Parent=content, AnchorPoint=Vector2.new(.5,1), Position=UDim2.new(.55,0,1,0), Size=UDim2.fromOffset(440,190), BackgroundTransparency=1})
for i = 1, 10 do -- many faint layers = a smooth falloff instead of visible rings
	local k = 1 - (i-1)*.085
	accent(new("Frame", {Parent=glow, AnchorPoint=Vector2.new(.5,1), Position=UDim2.fromScale(.5,1), Size=UDim2.fromScale(k,k), BackgroundTransparency=.988, BorderSizePixel=0},
		new("UICorner", {CornerRadius=UDim.new(1,0)})), "BackgroundColor3")
end

-- falling snow dots (plain frames). UI.setSnow(false) turns it off.
local snow = new("Frame", {Parent=content, Position=UDim2.fromOffset(0,TOP_H), Size=UDim2.new(1,-10,1,-(TOP_H+10)), BackgroundTransparency=1, ClipsDescendants=true})
task.spawn(function()
	while gui.Parent do
		if holder.Visible and snow.Visible then
			local s = math.random(2,3)
			local flake = new("Frame", {Parent=snow, Position=UDim2.new(math.random(), 0, 0, -4), Size=UDim2.fromOffset(s,s),
				BackgroundColor3=Color3.new(1,1,1), BackgroundTransparency=math.random(45,75)/100, BorderSizePixel=0}, corner(s))
			local t = math.random(70,110)/10
			tw(flake, {Position=UDim2.new(flake.Position.X.Scale + math.random(-6,6)/100, 0, 1, 4), BackgroundTransparency=.95}, t, Enum.EasingStyle.Linear)
			task.delay(t, flake.Destroy, flake)
		end
		task.wait(touch and .45 or .25)
	end
end)

-- top bar: breadcrumb, live stats, minimize / close
local top = new("Frame", {Parent=content, Name="Topbar", Size=UDim2.new(1,0,0,TOP_H), BackgroundTransparency=1, Active=true})
new("Frame", {Parent=top, Position=UDim2.new(0,0,1,-1), Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line, BorderSizePixel=0})
local crumb = text("", 13, C.text, W.Medium, {Parent=top, RichText=true, Position=UDim2.fromOffset(22,0), Size=UDim2.new(1,-360,1,0), TextTruncate=Enum.TextTruncate.AtEnd})

local stats = new("Frame", {Parent=top, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-86,.5,0), Size=UDim2.fromOffset(320,28), BackgroundTransparency=1},
	hlist(6, Enum.HorizontalAlignment.Right))
local function pill(i, icon)
	local p = new("Frame", {Parent=stats, LayoutOrder=i, Size=UDim2.fromOffset(0,28), AutomaticSize=Enum.AutomaticSize.X, BackgroundColor3=C.card, BackgroundTransparency=.15},
		corner(7), stroke(), pad(10,0), hlist(6))
	glyph(icon, p, C.dim, {LayoutOrder=1})
	return text("", 11, C.sub, W.Medium, {Parent=p, LayoutOrder=2, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X})
end
local fpsL, pingL, plrL = pill(1, "fps"), pill(2, "ping"), pill(3, "players")
local frames = 0
on(RS.RenderStepped, function() frames += 1 end)
task.spawn(function()
	while gui.Parent do
		task.wait(.5)
		fpsL.Text = (frames * 2).." fps" frames = 0
		pingL.Text = math.floor(plr:GetNetworkPing() * 1000 + .5).." ms"
		plrL.Text = #Players:GetPlayers().."/"..Players.MaxPlayers
	end
end)

local function topBtn(kind, x, hoverCol)
	local b = new("TextButton", {Parent=top, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,x,.5,0), Size=UDim2.fromOffset(28,28), BackgroundColor3=hoverCol,
		BackgroundTransparency=1, AutoButtonColor=false, Text=""}, corner(7))
	local ic = new("Frame", {Parent=b, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(14,14), BackgroundTransparency=1})
	local parts = kind == "close" and {seg(ic, 3.5, 3.5, 10.5, 10.5, C.dim), seg(ic, 10.5, 3.5, 3.5, 10.5, C.dim)} or {seg(ic, 3, 7, 11, 7, C.dim)}
	b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency=0}, .15) recolor(parts, Color3.new(1,1,1), .15) end)
	onLeave(b, function() tw(b, {BackgroundTransparency=1}, .15) recolor(parts, C.dim, .15) end)
	return b
end
local closeBtn, minBtn = topBtn("close", -14, Color3.fromRGB(220,60,70)), topBtn("min", -46, C.hover)
local pages = new("Frame", {Parent=content, Position=UDim2.fromOffset(0,TOP_H), Size=UDim2.new(1,-4,1,-(TOP_H+6)), BackgroundTransparency=1, ClipsDescendants=true})
function Lib.setSnow(v) snow.Visible = v end

---------------- notifications (slide in from the right, with a timer bar)
local TOAST_W = 280
local toasts = new("Frame", {Parent=gui, AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,touch and -12 or -20,1,touch and -12 or -20), Size=UDim2.fromOffset(TOAST_W,420), BackgroundTransparency=1},
	new("UIListLayout", {VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}))
local toastN = 0
function Lib.notify(title, msg, time)
	time = tonumber(time) or 3
	toastN += 1
	local slot = new("Frame", {Parent=toasts, LayoutOrder=toastN, Size=UDim2.fromOffset(TOAST_W,0), BackgroundTransparency=1})
	local f = new("Frame", {Parent=slot, Position=UDim2.fromOffset(TOAST_W+30,0), Size=UDim2.fromOffset(TOAST_W,60), BackgroundColor3=Color3.new(1,1,1)},
		corner(10), stroke(), grad(C.card:Lerp(Lib.accent,.12), C.card, 0))
	local badge = new("Frame", {Parent=f, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,12,.5,-1), Size=UDim2.fromOffset(32,32), BackgroundColor3=C.elem, ClipsDescendants=true},
		corner(8), new("UIStroke", {Color=Lib.accent, Transparency=.4, Thickness=1.2}))
	new("ImageLabel", {Parent=badge, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromScale(.8,.8), BackgroundTransparency=1, ScaleType=Enum.ScaleType.Fit, Image=currentLogo or FALLBACK_LOGO})
	text(tostring(title), 13, C.text, W.Bold, {Parent=f, Position=UDim2.fromOffset(54,12), Size=UDim2.new(1,-64,0,16), TextTruncate=Enum.TextTruncate.AtEnd})
	text(tostring(msg or ""), 11, C.sub, W.Medium, {Parent=f, Position=UDim2.fromOffset(54,30), Size=UDim2.new(1,-64,0,14), TextTruncate=Enum.TextTruncate.AtEnd})
	local timer = new("Frame", {Parent=f, Position=UDim2.new(0,12,1,-4), Size=UDim2.new(1,-24,0,2), BackgroundColor3=Lib.accent, BorderSizePixel=0}, corner(1))
	tw(slot, {Size=UDim2.fromOffset(TOAST_W,60)}, .3)
	tw(f, {Position=UDim2.new()}, .5, Enum.EasingStyle.Back)
	tw(timer, {Size=UDim2.new(0,0,0,2)}, time, Enum.EasingStyle.Linear)
	task.delay(time, function()
		tw(f, {Position=UDim2.fromOffset(TOAST_W+30,0)}, .35, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
		tw(slot, {Size=UDim2.fromOffset(TOAST_W,0)}, .2).Completed:Wait()
		slot:Destroy()
	end)
end

function Lib.setAccent(c) Lib.accent = c for _, p in painters do p(c, false) end end

-- Themes: Lib.setTheme("Darkhub Red")   |   Lib.themeNames = sorted list of every theme name
Lib.themes = THEMES
Lib.themeNames = {}
for n in Lib.themes do table.insert(Lib.themeNames, n) end
table.sort(Lib.themeNames)
function Lib.setTheme(name)
	local c = Lib.themes[name]
	if not c then warn("[Darkhub] No theme called '"..tostring(name).."'") return end
	Lib.setAccent(c)
end

---------------- presets: saves every Toggle / Slider / Input / Dropdown / Dropbox / Keybind / Color.
-- The last preset you saved or loaded loads by itself next time the script runs.
-- Uses writefile/readfile when they exist; otherwise presets only last for this session.
local Saves = {reg={}, pending={}, mem={}, auto=nil}
do
	local fs = {w=writefile, r=readfile, isf=isfile, mk=makefolder, ls=listfiles, del=delfile}
	local canSave = (fs.w and fs.r and fs.isf) and true or false
	local DIR, PDIR = "Darkhub", "Darkhub/presets"
	local PRESET_VERSION = "2" -- bump this to wipe everyone's presets once
	if canSave and fs.mk then pcall(fs.mk, DIR) pcall(fs.mk, PDIR) end

	local function clean(s) s = tostring(s or ""):gsub("[^%w%s%-_]", ""):gsub("^%s+", ""):gsub("%s+$", "") return s ~= "" and s or "Default" end
	local function path(n) return PDIR.."/"..n..".json" end
	local function enc(v)
		local t = typeof(v)
		if t == "boolean" or t == "number" or t == "string" then return v
		elseif t == "Color3" then return {__c={v.R, v.G, v.B}}
		elseif t == "EnumItem" then return {__e={tostring(v.EnumType), v.Name}}
		elseif t == "table" then local o = {} for _, x in v do local e = enc(x) if e ~= nil then table.insert(o, e) end end return {__t=o} end
		return nil -- players / instances aren't saved
	end
	local function dec(v)
		if type(v) ~= "table" then return v end
		if v.__c then return Color3.new(v.__c[1], v.__c[2], v.__c[3]) end
		if v.__e then local ok, r = pcall(function() return Enum[v.__e[1]][v.__e[2]] end) return ok and r or nil end
		if v.__t then local o = {} for _, x in v.__t do table.insert(o, dec(x)) end return o end
	end
	local function readFile(p) if not canSave then return nil end local ok, s = pcall(function() return fs.isf(p) and fs.r(p) or nil end) return ok and s or nil end
	local function readP(n)
		if not canSave then return Saves.mem[n] end
		local s = readFile(path(n)) if not s then return nil end
		local ok, d = pcall(HS.JSONDecode, HS, s) return ok and type(d) == "table" and d or nil
	end
	local function setAuto(n) Saves.auto = n if canSave then pcall(fs.w, DIR.."/autoload.txt", n or "") end end
	local function applyOne(key, api) if Saves.pending[key] ~= nil then local v = dec(Saves.pending[key]) if v ~= nil then pcall(api.Set, v) end end end
	local function wipe()
		if canSave then
			if fs.ls and fs.del then
				local ok, files = pcall(fs.ls, PDIR)
				if ok and type(files) == "table" then
					for _, p in files do if tostring(p):match("%.json$") then pcall(fs.del, p) end end
				end
			end
			pcall(fs.w, DIR.."/autoload.txt", "")
		end
		Saves.mem, Saves.pending, Saves.auto = {}, {}, nil
	end

	-- one-time reset for v2 (and every run while getgenv().DarkhubResetPresets = true)
	if canSave and (readFile(DIR.."/version.txt") ~= PRESET_VERSION or setting("DarkhubResetPresets") == true) then
		wipe()
		pcall(fs.w, DIR.."/version.txt", PRESET_VERSION)
	end

	function Saves.register(tab, name, api, kind, o) -- called by addButton for every control that has a value
		if kind == "click" or kind == "button" or kind == "label" or o.nosave then return end
		local key, n = tostring(tab).."/"..tostring(name), 2
		while Saves.reg[key] do key = tostring(tab).."/"..tostring(name).."#"..n n += 1 end
		Saves.reg[key] = api
		applyOne(key, api) -- controls made after an autoload still get their saved value
	end

	Lib.canSave = canSave
	function Lib.currentPreset() return Saves.auto end
	function Lib.listPresets()
		local l = {}
		if canSave and fs.ls then
			local ok, files = pcall(fs.ls, PDIR)
			if ok then for _, p in files do local n = tostring(p):match("([^/\\]+)%.json$") if n then table.insert(l, n) end end end
		else for n in Saves.mem do table.insert(l, n) end end
		table.sort(l) return l
	end
	function Lib.savePreset(name)
		name = clean(name or Saves.auto)
		local data = table.clone(Saves.pending)
		for key, api in Saves.reg do local e = enc(api.value) if e ~= nil then data[key] = e end end
		if canSave then pcall(fs.w, path(name), HS:JSONEncode(data)) else Saves.mem[name] = data end
		Saves.pending = data setAuto(name)
		Lib.notify("Preset saved", name..(canSave and "  ·  auto-loads next time" or "  ·  this session only"), 3)
		return name
	end
	function Lib.loadPreset(name)
		name = clean(name)
		local data = readP(name)
		if not data then Lib.notify("Preset not found", name, 3) return false end
		Saves.pending = data
		for key, api in Saves.reg do applyOne(key, api) end
		setAuto(name)
		Lib.notify("Preset loaded", name, 3)
		return true
	end
	function Lib.deletePreset(name)
		name = clean(name)
		if canSave and fs.del then pcall(fs.del, path(name)) else Saves.mem[name] = nil end
		if Saves.auto == name then setAuto(nil) end
		Lib.notify("Preset deleted", name, 3)
	end
	function Lib.resetPresets() -- deletes every saved preset (controls keep their current values)
		wipe()
		Lib.notify("Presets reset", "Every saved preset was cleared", 3)
	end

	-- autoload the last saved/loaded preset
	local last = readFile(DIR.."/autoload.txt")
	if last and last ~= "" then
		local data = readP(last)
		if data then Saves.pending, Saves.auto = data, last task.delay(1.5, function() Lib.notify("Preset loaded", last, 3) end) end
	end
end

---------------- tabs
local function select(name)
	if current == name then return end
	current = name
	for n, t in tabs do
		local on = n == name
		t.page.Visible = on
		tw(t.btn, {BackgroundTransparency = on and 0 or 1})
		tw(t.btn.Label, {TextColor3 = on and C.text or C.sub})
		tw(t.btn.Bar, {Size = UDim2.fromOffset(3, on and 18 or 0)}, .35, Enum.EasingStyle.Back)
		tw(t.btn.Box.Fill, {BackgroundTransparency = on and 0 or 1}, .25)
		tw(t.btn.Box.S, {Transparency = on and 1 or 0}, .25)
		if t.iconParts then recolor(t.iconParts, on and Color3.new(1,1,1) or C.sub, .25)
		elseif t.icon and t.icon:IsA("TextLabel") then tw(t.icon, {TextColor3 = on and Color3.new(1,1,1) or C.sub}, .25)
		elseif t.icon and t.icon:IsA("ImageLabel") then tw(t.icon, {ImageColor3 = on and Color3.new(1,1,1) or C.sub}, .25) end
	end
	crumb.Text = ('<font color="#%s">Darkhub</font>   <font color="#%s">›</font>   <b>%s</b>'):format(C.dim:ToHex(), C.line:Lerp(C.dim,.5):ToHex(), name)
	crumb.TextTransparency = 1 crumb.Position = UDim2.fromOffset(32,0)
	tw(crumb, {TextTransparency=0, Position=UDim2.fromOffset(22,0)}, .35)
	for i, w in tabs[name].wraps do -- sections pop in one after another
		w.UIScale.Scale = .96
		task.delay(i * .04, function() tw(w.UIScale, {Scale=1}, .45, Enum.EasingStyle.Back) end)
	end
	local p = tabs[name].page
	p.Position = UDim2.fromOffset(0,12) tw(p, {Position=UDim2.new()}, .4)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(searchBox.Text)
	for n, t in tabs do t.btn.Visible = q == "" or string.find(string.lower(n), q, 1, true) ~= nil end
end)
on(UIS.InputBegan, function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.Slash and holder.Visible then task.defer(function() searchBox:CaptureFocus() searchBox.Text = "" end) end
end)

local COL_M, COL_GAP = 20, 16 -- page side margin, gap between the two columns
function Lib.addTab(name, order, icon)
	order = tonumber(order) or 0
	local b = new("TextButton", {Parent=tabList, LayoutOrder=order, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,40 + TOUCH_PAD), BackgroundColor3=C.hover, BackgroundTransparency=1}, corner(8))
	accent(new("Frame", {Name="Bar", Parent=b, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,0,.5,0), Size=UDim2.fromOffset(3,0), BorderSizePixel=0}, corner(2)), "BackgroundColor3")
	local box = new("Frame", {Name="Box", Parent=b, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,10,.5,0), Size=UDim2.fromOffset(28,28), BackgroundColor3=C.elem}, corner(8), stroke())
	accentGrad(new("Frame", {Name="Fill", Parent=box, Size=UDim2.fromScale(1,1), BackgroundTransparency=1}, corner(8)))
	local ic, parts = iconInto(box, icon, "grid", C.sub, 14)
	text(name, 13, C.sub, W.Medium, {Name="Label", Parent=b, Position=UDim2.fromOffset(48,0), Size=UDim2.new(1,-54,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
	local page = new("ScrollingFrame", {Parent=pages, Visible=false, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
		ScrollBarImageColor3=C.line:Lerp(C.sub,.25), CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, pad(0,18)) -- side margins live on the columns
	local function col(x)
		return new("Frame", {Parent=page, Position=UDim2.new(x, x == 0 and COL_M or COL_GAP/2, 0, 0), Size=UDim2.new(.5,-(COL_M + COL_GAP/2),0,0), AutomaticSize=AY, BackgroundTransparency=1}, list(18))
	end
	tabs[name] = {btn=b, page=page, order=order, cols={col(0), col(.5)}, sections={}, wraps={}, nextSide=1, icon=ic, iconParts=parts}
	b.MouseEnter:Connect(function() if current ~= name then tw(b, {BackgroundTransparency=.5}, .15) tw(b.Label, {TextColor3=C.text}, .15) end end)
	onLeave(b, function() if current ~= name then tw(b, {BackgroundTransparency=1}, .15) tw(b.Label, {TextColor3=C.sub}, .15) end end)
	b.MouseButton1Click:Connect(function() select(name) end)
	if not current or order < tabs[current].order then select(name) end
end

---------------- sections (cards with a header). Optional: buttons go into "General" if you never make one.
local function makeSection(t, name, sideName, icon)
	local colIndex
	if sideName then colIndex = string.lower(tostring(sideName)) == "right" and 2 or 1
	else colIndex = t.nextSide t.nextSide = 3 - t.nextSide end
	local wrap = new("Frame", {Parent=t.cols[colIndex], LayoutOrder=#t.wraps + 1, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, list(10), new("UIScale", {}))
	local hdr = new("Frame", {Parent=wrap, LayoutOrder=1, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16)})
	local iconHolder = new("Frame", {Parent=hdr, Position=UDim2.fromOffset(1,1), Size=UDim2.fromOffset(14,14), BackgroundTransparency=1})
	local ic, parts = iconInto(iconHolder, icon, "sliders", C.sub, 14)
	paint(function(c, now)
		local col = c:Lerp(C.sub, .45)
		if parts then recolor(parts, col, now and 0 or .4)
		elseif ic:IsA("ImageLabel") then ic.ImageColor3 = col
		elseif ic:IsA("TextLabel") then ic.TextColor3 = col end
	end)
	text(name, 13, C.sub, W.Medium, {Parent=hdr, Position=UDim2.fromOffset(22,0), Size=UDim2.new(1,-22,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
	local card = new("Frame", {Parent=wrap, LayoutOrder=2, BackgroundColor3=C.card, BackgroundTransparency=.04, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, corner(10), stroke(), list(0), pad(14,0,2))
	local shine = accent(new("Frame", {Parent=card, LayoutOrder=-1, Size=UDim2.new(1,0,0,1), BackgroundTransparency=.35, BorderSizePixel=0}), "BackgroundColor3")
	new("UIGradient", {Parent=shine, Transparency=fadeEdges})
	local s = {card=card, count=0, rows={}}
	t.sections[name] = s
	table.insert(t.wraps, wrap)
	return s
end
function Lib.addSection(tab, name, sideName, icon)
	local t = assert(tabs[tab], "[Darkhub] No tab named '"..tostring(tab).."' - call addTab first")
	local s = t.sections[name] or makeSection(t, name, sideName, icon)
	t.last = s
	return s
end

-- hide the divider above whichever row is first in a card
local function fixLines(sec)
	local first, fo
	for _, r in sec.rows do
		r.Sep.Visible = true
		if not first or r.LayoutOrder < fo then first, fo = r, r.LayoutOrder end
	end
	if first then first.Sep.Visible = false end
end

---------------- buttons
-- addButton(tab, name, description, type, callback, options) -> returns {value, Set}
local binding, bindAt = false, 0 -- a Keybind control is listening (so the menu key doesn't fire)
function Lib.addButton(tab, name, desc, kind, cb, o)
	local t = assert(tabs[tab], "[Darkhub] No tab named '"..tostring(tab).."' - call addTab first")
	o, kind = o or {}, string.lower(kind or "click")
	if desc == "" then desc = nil end
	local sec = (o.section and (t.sections[o.section] or makeSection(t, o.section, o.side))) or t.last or makeSection(t, "General")
	t.last = sec
	sec.count += 1
	local api = {}
	local function fire(...) if cb then task.spawn(cb, ...) end end

	local row = new("Frame", {Parent=sec.card, LayoutOrder=o.order or sec.count, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, list(0))
	new("Frame", {Name="Sep", Parent=row, LayoutOrder=0, Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line, BackgroundTransparency=.25, BorderSizePixel=0})
	table.insert(sec.rows, row)
	fixLines(sec)
	local stacked = kind == "slider" or kind == "dropdown" or kind == "input" or kind == "textbox" or kind == "dropbox"
	local h = (desc and 52 or (stacked and 38 or 44)) + TOUCH_PAD
	local head = new("TextButton", {Parent=row, LayoutOrder=1, Text="", AutoButtonColor=false, BackgroundTransparency=1, Size=UDim2.new(1,0,0,h)})
	local title = text(name, 13, C.text, W.Medium, {Parent=head, Position=UDim2.new(0,0,0, desc and 9 + TOUCH_PAD/2 or 0), Size=UDim2.new(1,-120,0, desc and 17 or h), TextTruncate=Enum.TextTruncate.AtEnd})
	if desc then text(desc, 11, C.dim, W.Medium, {Parent=head, Position=UDim2.fromOffset(0, 28 + TOUCH_PAD/2), Size=UDim2.new(1,-120,0,14), TextTruncate=Enum.TextTruncate.AtEnd}) end
	local extra
	local function getExtra()
		extra = extra or new("Frame", {Parent=row, LayoutOrder=2, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, list(6), pad(0,0,12))
		return extra
	end
	local function right(class, w, ht, p, rad)
		p = p or {}
		p.Parent, p.AnchorPoint, p.Position, p.Size = head, Vector2.new(1,.5), UDim2.new(1,0,.5,0), UDim2.fromOffset(w, ht)
		p.BackgroundColor3 = p.BackgroundColor3 or C.elem
		if class ~= "Frame" then p.Text, p.TextColor3, p.TextSize, p.FontFace = p.Text or "", C.text, 12, Font.new(FAM, W.Medium) end
		if class == "TextButton" then p.AutoButtonColor = false end
		return new(class, p, corner(rad or 7), stroke())
	end
	local BOX_H = 36 + (touch and 4 or 0)
	local function box(class, p) -- full-width box under the title
		p = p or {}
		p.Parent, p.Size, p.BackgroundColor3 = getExtra(), UDim2.new(1,0,0,BOX_H), C.elem
		if class ~= "Frame" then p.Text, p.TextColor3, p.TextSize, p.FontFace = p.Text or "", C.text, 12, Font.new(FAM, W.Medium) end
		if class == "TextButton" then p.AutoButtonColor = false end
		return new(class, p, corner(8), stroke())
	end
	local function chevron(parent)
		local arrow = new("Frame", {Parent=parent, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-12,.5,0), Size=UDim2.fromOffset(12,12), BackgroundTransparency=1})
		seg(arrow, 2.5, 4.5, 6, 8, C.sub, 1.5) seg(arrow, 6, 8, 9.5, 4.5, C.sub, 1.5)
		return arrow
	end
	local ITEM_H = 32 + (touch and 6 or 0)
	local function menuItem(parent, label, order)
		local it = new("TextButton", {Parent=parent, LayoutOrder=order or 0, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,ITEM_H), BackgroundColor3=C.hover, BackgroundTransparency=1}, corner(6), new("UIScale", {}))
		text(label, 12, C.sub, W.Medium, {Name="Label", Parent=it, Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-36,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
		accent(new("Frame", {Name="Bar", Parent=it, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,3,.5,0), Size=UDim2.fromOffset(2,14), BackgroundTransparency=1, BorderSizePixel=0}, corner(1)), "BackgroundColor3")
		local chk = new("Frame", {Name="Check", Parent=it, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-10,.5,0), Size=UDim2.fromOffset(12,12), BackgroundTransparency=1})
		chk:SetAttribute("on", false)
		accent(seg(chk, 1.5, 6.5, 4.5, 9.5, Lib.accent, 1.6), "BackgroundColor3") accent(seg(chk, 4.5, 9.5, 10.5, 3, Lib.accent, 1.6), "BackgroundColor3")
		for _, s in chk:GetChildren() do s.BackgroundTransparency = 1 end
		it.MouseEnter:Connect(function() tw(it, {BackgroundTransparency=0}, .12) end)
		onLeave(it, function() tw(it, {BackgroundTransparency=1}, .12) end)
		return it
	end
	local function markItem(it, sel)
		tw(it.Bar, {BackgroundTransparency = sel and 0 or 1}, .2)
		for _, s in it.Check:GetChildren() do tw(s, {BackgroundTransparency = sel and 0 or 1}, .2) end
		tw(it.Label, {TextColor3 = sel and C.text or C.sub}, .2)
	end
	local function menuFrame(gap)
		return new("Frame", {Parent=getExtra(), Visible=false, Size=UDim2.new(1,0,0,0), AutomaticSize=AY, BackgroundColor3=C.side}, corner(8), stroke(), list(gap or 2), pad(4,4))
	end

	if kind == "click" or kind == "button" then
		title.Visible = false
		head.Size = UDim2.new(1,0,0,52 + TOUCH_PAD)
		local b = new("TextButton", {Parent=head, AnchorPoint=Vector2.new(0,.5), Position=UDim2.fromScale(0,.5), Size=UDim2.new(1,0,0,BOX_H), BackgroundColor3=C.elem,
			AutoButtonColor=false, Text=name, TextSize=12, TextColor3=C.text, FontFace=Font.new(FAM, W.SemiBold)}, corner(8), stroke(), new("UIScale", {}))
		if desc then text(desc, 11, C.dim, W.Medium, {Parent=getExtra(), Size=UDim2.new(1,0,0,0), AutomaticSize=AY, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Center}) end
		b.MouseEnter:Connect(function() tw(b, {BackgroundColor3=C.hover}, .15) tw(b.S, {Color=C.line:Lerp(Lib.accent,.55)}, .15) end)
		onLeave(b, function()
			tw(b, {BackgroundColor3=C.elem}, .15)
			tw(b.S, {Color=C.line}, .15)
			if b:FindFirstChildOfClass("UIScale") then tw(b.UIScale, {Scale=1}, .2) end
		end)
		b.MouseButton1Down:Connect(function() tw(b.UIScale, {Scale=.97}, .1) end)
		b.MouseButton1Up:Connect(function() tw(b.UIScale, {Scale=1}, .35, Enum.EasingStyle.Back) end)
		function api.Set() fire() end
		b.MouseButton1Click:Connect(function()
			b.BackgroundColor3 = C.elem:Lerp(Lib.accent, .45) tw(b, {BackgroundColor3=C.hover}, .5)
			fire()
		end)

	elseif kind == "toggle" then
		local sw = right("Frame", 42, 22, nil, 11)
		local fill = accentGrad(new("Frame", {Parent=sw, Size=UDim2.fromScale(1,1), BackgroundTransparency=1}, corner(11)))
		local knob = new("Frame", {Parent=sw, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,3,.5,0), Size=UDim2.fromOffset(16,16), BackgroundColor3=C.sub, ZIndex=2}, corner(8))
		local function render(_, now)
			local on, t1 = api.value, now and 0 or .3
			tw(fill, {BackgroundTransparency = on and 0 or 1}, t1)
			tw(sw.S, {Transparency = on and 1 or 0}, t1)
			tw(title, {TextColor3 = on and C.text or C.sub}, t1)
			if not now then knob.Size = UDim2.fromOffset(21,16) tw(knob, {Size=UDim2.fromOffset(16,16)}, .35, Enum.EasingStyle.Back) end
			tw(knob, {Position = on and UDim2.new(1,-19,.5,0) or UDim2.new(0,3,.5,0), BackgroundColor3 = on and Color3.new(1,1,1) or C.sub}, t1)
		end
		api.value = o.default == true
		function api.Set(v) api.value = v render() fire(v) end
		head.MouseButton1Click:Connect(function() api.Set(not api.value) end)
		paint(render)

	elseif kind == "slider" then
		local mn, mx, step = o.min or 0, o.max or 100, o.step or 1
		local valBox = right("TextBox", 54, 26, {ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Center})
		local tr = new("TextButton", {Parent=getExtra(), Text="", AutoButtonColor=false, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16 + (touch and 12 or 0))})
		local bar = new("Frame", {Parent=tr, AnchorPoint=Vector2.new(0,.5), Position=UDim2.fromScale(0,.5), Size=UDim2.new(1,0,0,4), BackgroundColor3=C.elem}, corner(2), stroke(C.line, .3))
		local fill = new("Frame", {Parent=bar, BorderSizePixel=0, BackgroundColor3=Color3.new(1,1,1), Size=UDim2.fromScale(0,1)}, corner(2))
		local fg = new("UIGradient", {Parent=fill})
		paint(function(c) fg.Color = ColorSequence.new(c:Lerp(Color3.new(0,0,0),.35), c:Lerp(Color3.new(1,1,1),.08)) end)
		local knob = new("Frame", {Parent=tr, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(0,.5), Size=UDim2.fromOffset(13,13), BackgroundColor3=Color3.new(1,1,1), ZIndex=2}, corner(7))
		local ring = accent(new("UIStroke", {Parent=knob, Thickness=0, Transparency=.45}), "Color")
		function api.Set(v, silent)
			v = tonumber(v) or api.value or mn
			v = math.clamp(math.round((v - mn) / step) * step + mn, mn, mx)
			v = math.round(v * 100) / 100
			valBox.Text = tostring(v)..(o.suffix or "")
			if v == api.value and not silent then return end
			api.value = v
			local a = mx == mn and 0 or (v - mn) / (mx - mn)
			if silent then fill.Size = UDim2.fromScale(a,1) knob.Position = UDim2.fromScale(a,.5)
			else tw(fill, {Size=UDim2.fromScale(a,1)}, .12) tw(knob, {Position=UDim2.fromScale(a,.5)}, .12) end
			if not silent then fire(v) end
		end
		valBox.Focused:Connect(function() valBox.Text = tostring(api.value) tw(valBox.S, {Color=Lib.accent}, .2) end)
		valBox.FocusLost:Connect(function() tw(valBox.S, {Color=C.line}, .2) api.Set(tonumber((valBox.Text:gsub("[^%d%.%-]", ""))) or api.value) end)
		local drag = false
		local function upd(x) api.Set(mn + (mx - mn) * math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)) end
		tr.InputBegan:Connect(function(i)
			if isPress(i) then drag = true t.page.ScrollingEnabled = false upd(i.Position.X) tw(knob, {Size=UDim2.fromOffset(16,16)}, .2, Enum.EasingStyle.Back) tw(ring, {Thickness=4}, .2) end
		end)
		on(UIS.InputChanged, function(i) if drag and isMove(i) then upd(i.Position.X) end end)
		on(UIS.InputEnded, function(i)
			if drag and isPress(i) then drag = false t.page.ScrollingEnabled = true tw(knob, {Size=UDim2.fromOffset(13,13)}, .2) tw(ring, {Thickness=0}, .2) end
		end)
		api.Set(o.default or mn, true)

	elseif kind == "input" or kind == "textbox" then
		local tb = box("TextBox", {Text=o.default or "", PlaceholderText=o.placeholder or "Type here...", PlaceholderColor3=C.dim, ClearTextOnFocus=false,
			TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd})
		pad(12).Parent = tb
		api.value = tb.Text
		tb.Focused:Connect(function() tw(tb.S, {Color=Lib.accent}, .2) end)
		function api.Set(v) tb.Text = tostring(v) api.value = tb.Text fire(tb.Text) end
		tb.FocusLost:Connect(function(enter) tw(tb.S, {Color=C.line}, .2) api.value = tb.Text fire(tb.Text, enter) end)

	elseif kind == "dropdown" then
		local opts = o.options or {}
		api.value = o.default or opts[1]
		local b = box("TextButton")
		local lbl = text(tostring(api.value or "Select"), 12, C.text, W.Medium, {Parent=b, Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-40,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
		local arrow = chevron(b)
		local menu = menuFrame(2)
		local items = {}
		local function mark()
			pcall(function() for opt, it in items do markItem(it, opt == api.value) end end)
		end
		function api.Set(v) api.value = v lbl.Text = tostring(v) mark() fire(v) end
		for i, opt in opts do
			local it = menuItem(menu, tostring(opt), i)
			items[opt] = it
			it.MouseButton1Click:Connect(function() api.Set(opt) end)
		end
		local function flip()
			menu.Visible = not menu.Visible
			tw(arrow, {Rotation = menu.Visible and 180 or 0}, .3, Enum.EasingStyle.Back)
			tw(b.S, {Color = menu.Visible and Lib.accent or C.line}, .2)
			if menu.Visible then
				mark()
				for i, opt in opts do
					local it = items[opt]
					if it then
						it.UIScale.Scale = .9
						task.delay(i * .025, function() tw(it.UIScale, {Scale=1}, .3, Enum.EasingStyle.Back) end)
					end
				end
			end
		end
		b.MouseButton1Click:Connect(flip) head.MouseButton1Click:Connect(flip)

	elseif kind == "dropbox" then
		-- A dropdown whose list can be ANYTHING and can change:
		--   options = {"A","B"} / {workspace.Part, ...}   a table of any values
		--   options = function() return {...} end           re-read every time it opens / refreshes
		--   options = "players"                             live player list (updates on join/leave)
		-- extras: multi = true (pick many), search = true/false, placeholder = "...",
		--         format = function(v) return "label" end, includeSelf = false (players only)
		local multi = o.multi == true
		local function label(v)
			if o.format then return tostring(o.format(v)) end
			if typeof(v) == "Instance" then
				if v:IsA("Player") then return v.DisplayName == v.Name and v.Name or v.DisplayName.." (@"..v.Name..")" end
				return v.Name
			end
			return tostring(v)
		end
		local function source()
			local src = o.options
			if src == "players" then
				local l = {}
				for _, p in Players:GetPlayers() do if not (o.includeSelf == false and p == plr) then table.insert(l, p) end end
				return l
			elseif type(src) == "function" then
				local ok, r = pcall(src)
				if not ok then warn("[Darkhub] Dropbox '"..name.."' options function errored: "..tostring(r)) end
				return ok and type(r) == "table" and r or {}
			end
			return type(src) == "table" and src or {}
		end
		local function isSel(v) if multi then return table.find(api.value, v) ~= nil end return api.value == v end

		if multi then api.value = {} for _, v in (type(o.default) == "table" and o.default or {}) do table.insert(api.value, v) end
		else api.value = o.default end

		local b = box("TextButton")
		local lbl = text("", 12, C.text, W.Medium, {Parent=b, Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-44,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
		local arrow = chevron(b)
		local menu = menuFrame(4)
		local sb = new("TextBox", {Parent=menu, LayoutOrder=1, Size=UDim2.new(1,0,0,30 + (touch and 4 or 0)), BackgroundColor3=C.card, Text="", PlaceholderText="Search...", PlaceholderColor3=C.dim,
			TextColor3=C.text, TextSize=12, FontFace=Font.new(FAM, W.Medium), TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false}, corner(6), stroke(), pad(10))
		local scroll = new("ScrollingFrame", {Parent=menu, LayoutOrder=2, Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2,
			ScrollBarImageColor3=C.line:Lerp(C.sub,.25), CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, list(2))
		local empty = text("Nothing here", 12, C.dim, W.Medium, {Parent=menu, LayoutOrder=3, Size=UDim2.new(1,0,0,28), TextXAlignment=Enum.TextXAlignment.Center, Visible=false})
		sb.Focused:Connect(function() tw(sb.S, {Color=Lib.accent}, .2) end)
		sb.FocusLost:Connect(function() tw(sb.S, {Color=C.line}, .2) end)

		local items = {}
		local function summary()
			local n = multi and #api.value or (api.value ~= nil and 1 or 0)
			if n == 0 then lbl.Text = o.placeholder or (multi and "None" or "Select...")
			elseif multi and n > 1 then lbl.Text = label(api.value[1]).."  +"..(n-1).." more"
			else lbl.Text = label(multi and api.value[1] or api.value) end
			lbl.TextColor3 = n == 0 and C.dim or C.text
		end
		local function mark()
			pcall(function() for _, it in items do if it.btn and it.btn.Parent then markItem(it.btn, isSel(it.v)) end end end)
		end
		local function out() if multi then fire(table.clone(api.value)) else fire(api.value) end end
		local close
		local function choose(v)
			if multi then
				local i = table.find(api.value, v)
				if i then table.remove(api.value, i) else table.insert(api.value, v) end
				summary() mark() out()
			else
				api.value = v summary() mark() close() out()
			end
		end
		local function build(animate)
			for _, it in items do it.btn:Destroy() end
			items = {}
			local opts = source()
			sb.Visible = o.search == true or (o.search ~= false and #opts > 6)
			local q = sb.Visible and string.lower(sb.Text) or ""
			for _, v in opts do
				local l = label(v)
				if q == "" or string.find(string.lower(l), q, 1, true) then
					local it = menuItem(scroll, l, #items + 1)
					it.MouseButton1Click:Connect(function() choose(v) end)
					table.insert(items, {v=v, btn=it})
					if animate then
						it.UIScale.Scale = .9
						task.delay(#items * .025, function() tw(it.UIScale, {Scale=1}, .3, Enum.EasingStyle.Back) end)
					end
				end
			end
			local shownN = math.min(#items, 6)
			scroll.Size = UDim2.new(1,0,0, shownN * ITEM_H + math.max(shownN - 1, 0) * 2)
			empty.Visible = #items == 0
			empty.Text = #opts == 0 and "Nothing here" or "No matches"
			mark()
		end
		local function open()
			menu.Visible = true sb.Text = ""
			build(true)
			tw(arrow, {Rotation = 180}, .3, Enum.EasingStyle.Back) tw(b.S, {Color = Lib.accent}, .2)
		end
		function close()
			menu.Visible = false
			tw(arrow, {Rotation = 0}, .3, Enum.EasingStyle.Back) tw(b.S, {Color = C.line}, .2)
		end
		local function flip() if menu.Visible then close() else open() end end
		b.MouseButton1Click:Connect(flip) head.MouseButton1Click:Connect(flip)
		sb:GetPropertyChangedSignal("Text"):Connect(function() if menu.Visible then build(false) end end)

		function api.Set(v)
			if multi then api.value = type(v) == "table" and table.clone(v) or {} else api.value = v end
			summary() mark() out()
		end
		function api.Refresh(newOptions) -- swap the list (or re-read a function / players) without touching the selection
			if newOptions ~= nil then o.options = newOptions end
			if menu.Visible then build(false) end
		end
		function api.Clear() api.Set(multi and {} or nil) end

		if o.options == "players" then -- keep the player list live, and drop players who leave
			on(Players.PlayerAdded, function() if gui.Parent and menu.Visible then build(false) end end)
			on(Players.PlayerRemoving, function(p)
				if not gui.Parent then return end
				local was = isSel(p)
				if multi then local i = table.find(api.value, p) if i then table.remove(api.value, i) end
				elseif api.value == p then api.value = nil end
				task.defer(function()
					if menu.Visible then build(false) end
					if was then summary() out() end
				end)
			end)
		end
		summary()

	elseif kind == "keybind" then
		api.value = o.default or Enum.KeyCode.E
		local b = right("TextButton", 64, 28 + (touch and 4 or 0), {Text=keyName(api.value), TextXAlignment=Enum.TextXAlignment.Center})
		b.AutomaticSize = Enum.AutomaticSize.X pad(10).Parent = b -- grows for long names like MouseButton2
		local waiting = false
		function api.Set(k) api.value = k b.Text = keyName(k) tw(b.S, {Color=C.line}, .2) tw(b, {TextColor3=C.text}, .2) end
		b.MouseButton1Click:Connect(function() waiting = true binding = true b.Text = "..." tw(b.S, {Color=Lib.accent}, .2) tw(b, {TextColor3=Lib.accent}, .2) end)
		local UIT = Enum.UserInputType
		on(UIS.InputBegan, function(i, gp)
			local key = i.UserInputType == UIT.Keyboard or i.UserInputType == UIT.Gamepad1
			local extraMouse = i.UserInputType == UIT.MouseButton2 or i.UserInputType == UIT.MouseButton3
			if waiting then
				if key then waiting = false binding = false bindAt = os.clock() api.Set(i.KeyCode)
				elseif extraMouse then waiting = false binding = false bindAt = os.clock() api.Set(i.UserInputType)
				elseif isPress(i) then -- tapped/clicked somewhere else: cancel and keep the old bind
					task.defer(function() if waiting then waiting = false binding = false api.Set(api.value) end end)
				end
			elseif not gp and ((key and i.KeyCode == api.value) or (extraMouse and i.UserInputType == api.value)) then
				b.BackgroundColor3 = Lib.accent tw(b, {BackgroundColor3=C.elem}, .4)
				fire()
			end
		end)

	elseif kind == "color" then
		api.value = o.default or Lib.accent
		local sw = right("TextButton", 42, 24, {BackgroundColor3=api.value}, 7)
		sw.S.Transparency = .5
		local sc = new("UIScale", {Parent=sw})
		new("UIGradient", {Parent=sw, Rotation=90, Color=ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(205,205,205))})
		function api.Set(c) api.value = c tw(sw, {BackgroundColor3=c}, .3) fire(c) end
		local function shift()
			sc.Scale = .8 tw(sc, {Scale=1}, .4, Enum.EasingStyle.Back)
			local hh, s, v = api.value:ToHSV()
			api.Set(Color3.fromHSV((hh + .08) % 1, math.max(s, .6), math.max(v, .85)))
		end
		sw.MouseButton1Click:Connect(shift) head.MouseButton1Click:Connect(shift)

	elseif kind == "label" then
		title.TextColor3, title.TextSize, title.TextWrapped = C.sub, 12, true
		title.TextTruncate = Enum.TextTruncate.None
		title.Position, title.Size, title.AutomaticSize = UDim2.new(), UDim2.new(1,0,0,0), AY
		head.Size, head.AutomaticSize = UDim2.new(1,0,0,0), AY
		pad(0,12).Parent = head

	else
		warn("[Darkhub] Unknown type '"..kind.."' for "..name..". Use Click, Toggle, Slider, Input, Dropdown, Dropbox, Keybind, Color or Label")
	end
	Saves.register(tab, name, api, kind, o) -- remember it for presets (and apply the autoloaded value)
	return api
end

---------------- drag (smooth follow) / show / hide
local dragging, dStart, pStart
top.InputBegan:Connect(function(i) if isPress(i) then dragging, dStart, pStart = true, i.Position, holder.Position end end)
on(UIS.InputChanged, function(i)
	if dragging and isMove(i) then
		local d = i.Position - dStart
		tw(holder, {Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)}, .12)
	end
end)
on(UIS.InputEnded, function(i) if isPress(i) then dragging = false end end)

local function fit() local v = workspace.CurrentCamera.ViewportSize return math.min(1, (v.X-32)/SIZE.X, (v.Y-32)/SIZE.Y) end
local shown = true
function Lib.setShown(v)
	shown = v
	if v then
		holder.Visible = true scale.Scale = fit()*.85
		tw(scale, {Scale=fit()}, .5, Enum.EasingStyle.Back)
		for i, s in shadows do s.BackgroundTransparency = 1 tw(s, {BackgroundTransparency=shadowT(i)}, .6) end
	else
		tw(scale, {Scale=fit()*.88}, .18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(.18, function() if not shown then holder.Visible = false end end)
	end
end
local function hide()
	Lib.setShown(false)
	Lib.notify("Darkhub hidden", touch and "Tap the Darkhub button to reopen" or ("Press "..keyName(toggleKey).." to reopen"))
end
closeBtn.MouseButton1Click:Connect(hide) minBtn.MouseButton1Click:Connect(hide)

-- menu key (change it with getgenv().DarkhubKeybind before loading, or UI.setToggleKey(key) any time)
function Lib.setToggleKey(k)
	local key = toKey(k)
	if not key then warn("[Darkhub] setToggleKey: '"..tostring(k).."' isn't a key") return false end
	toggleKey = key
	return true
end
function Lib.getToggleKey() return toggleKey end
on(UIS.InputBegan, function(i)
	if binding or os.clock() - bindAt < .15 or UIS:GetFocusedTextBox() then return end
	if i.KeyCode == toggleKey or i.UserInputType == toggleKey then Lib.setShown(not shown) end
end)
on(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() if shown then scale.Scale = fit() end end)

task.spawn(function() -- logo breathing glow
	while gui.Parent do
		tw(logoGlow, {Size=UDim2.fromOffset(LOGO+16,LOGO+16), BackgroundTransparency=.93}, 1.6, Enum.EasingStyle.Sine).Completed:Wait()
		tw(logoGlow, {Size=UDim2.fromOffset(LOGO+6,LOGO+6), BackgroundTransparency=.83}, 1.6, Enum.EasingStyle.Sine).Completed:Wait()
	end
end)
Lib.setShown(true)

---------------- MOBILE / SMALL SCREENS (on a normal PC screen nothing here changes the layout)
-- * Phones/tablets/small windows: the menu resizes to fit the screen instead of shrinking into tiny text.
-- * Narrow screens: icon-only sidebar, and sections stack in one column.
-- * Touch devices: bigger rows and hit areas, plus a floating, draggable Darkhub button that opens/closes the menu.
-- * Controllers: R3 (right stick click) opens/closes the menu.
local BASE, origFit = SIZE, fit
if touch then gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end -- keep clear of notches / home bar

local sideBits = {titleL, subtitle, search, modulesL}
local profBits = {nameL, userL}

local compact, single = false, false
local function compactTab(t)
	t.btn.Label.Visible = not compact
	t.btn.Box.Position = compact and UDim2.new(.5,-14,.5,0) or UDim2.new(0,10,.5,0)
end
local function singleTab(t)
	local stack = t.page:FindFirstChild("MobileStack")
	if single and not stack then
		new("UIListLayout", {Name="MobileStack", Parent=t.page, Padding=UDim.new(0,18), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center})
		t.cols[1].LayoutOrder, t.cols[2].LayoutOrder = 1, 2
		for _, c in t.cols do c.Size = UDim2.new(1,-28,0,0) end
	elseif not single and stack then
		stack:Destroy()
		t.cols[1].Position, t.cols[1].Size = UDim2.new(0,COL_M,0,0), UDim2.new(.5,-(COL_M + COL_GAP/2),0,0)
		t.cols[2].Position, t.cols[2].Size = UDim2.new(.5,COL_GAP/2,0,0), UDim2.new(.5,-(COL_M + COL_GAP/2),0,0)
	end
end
local function setCompact(onc)
	compact = onc
	local sw = onc and 64 or SIDE_W
	side.Size = UDim2.new(0,sw,1,0)
	content.Position, content.Size = UDim2.fromOffset(sw+1,0), UDim2.new(1,-(sw+1),1,0)
	local lx = onc and 12 or LX
	logoTile.Position = UDim2.fromOffset(lx, LY)
	logoGlow.Position = UDim2.fromOffset(lx + LOGO/2, LY + LOGO/2)
	for _, c in sideBits do c.Visible = not onc end
	for _, c in profBits do c.Visible = not onc end
	divider.Position = UDim2.fromOffset(12, onc and 70 or 118)
	tabList.Position, tabList.Size = UDim2.fromOffset(0, onc and 80 or 148), UDim2.new(1,0,1, onc and -152 or -220)
	av.Position = UDim2.fromOffset(onc and 5 or 9, 9)
	for _, t in tabs do compactTab(t) end
end

local function layout()
	local vp = gui.AbsoluteSize
	if vp.X < 2 then return end
	local small = touch or vp.X < 1000 or vp.Y < 620
	local s, w, h = nil, BASE.X, BASE.Y
	if small then
		s = math.clamp(math.min(vp.X/760, vp.Y/470), .74, 1)   -- never shrink text below 74%
		w, h = math.min(BASE.X, (vp.X-20)/s), math.min(BASE.Y, (vp.Y-20)/s)
		fit = function() return s end
	else
		fit = origFit
	end
	SIZE = Vector2.new(w, h)
	holder.Size = UDim2.fromOffset(w, h)
	if (w < 760) ~= compact then setCompact(w < 760) end
	local contentW = w - (compact and 65 or SIDE_W + 1)
	stats.Visible = contentW >= 600
	crumb.Size = UDim2.new(1, stats.Visible and -360 or -100, 1, 0)
	single = contentW < 600
	for _, t in tabs do singleTab(t) end
	if shown and small then tw(scale, {Scale=fit()}, .3) end
	-- keep the window on screen after a rotate / resize
	if small then holder.Position = UDim2.fromScale(.5,.5) end
end

-- tabs added later get the same mobile treatment
local origAddTab = Lib.addTab
function Lib.addTab(name, ...)
	origAddTab(name, ...)
	local t = tabs[name]
	if t then compactTab(t) singleTab(t) end
end

-- floating open/close button (touch devices)
local fabGlow = accent(new("Frame", {Parent=gui, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(0,46,.5,0), Size=UDim2.fromOffset(64,64),
	BackgroundTransparency=.82, Visible=touch, ZIndex=9}, corner(32)), "BackgroundColor3")
local fab = new("ImageButton", {Parent=gui, Name="MobileToggle", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(0,46,.5,0), Size=UDim2.fromOffset(52,52),
	BackgroundColor3=C.card, ScaleType=Enum.ScaleType.Fit, AutoButtonColor=false, Visible=touch, ZIndex=10},
	corner(26), new("UIScale", {}))
logoImage(fab)
local fabRing = accent(new("UIStroke", {Parent=fab, Thickness=2, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}), "Color")

local function fabState()
	tw(fab, {ImageTransparency = shown and 0 or .1}, .25)
	tw(fabRing, {Transparency = shown and 0 or .5}, .25)
	tw(fabGlow, {BackgroundTransparency = shown and .75 or .9}, .25)
end
local origSetShown = Lib.setShown
function Lib.setShown(v) origSetShown(v) fabState() end

local fabDown, fabStart, fabPos, fabMoved
fab.InputBegan:Connect(function(i)
	if isPress(i) then
		fabDown, fabStart, fabPos, fabMoved = true, i.Position, fab.Position, false
		tw(fab.UIScale, {Scale=.9}, .1)
	end
end)
on(UIS.InputChanged, function(i)
	if fabDown and isMove(i) then
		local d = i.Position - fabStart
		if d.Magnitude > 8 then fabMoved = true end
		if fabMoved then
			local vp = gui.AbsoluteSize
			local x = math.clamp(fabPos.X.Offset + fabPos.X.Scale*vp.X + d.X, 30, vp.X-30)
			local y = math.clamp(fabPos.Y.Offset + fabPos.Y.Scale*vp.Y + d.Y, 30, vp.Y-30)
			fab.Position = UDim2.fromOffset(x, y) fabGlow.Position = fab.Position
		end
	end
end)
on(UIS.InputEnded, function(i)
	if fabDown and isPress(i) then
		fabDown = false
		tw(fab.UIScale, {Scale=1}, .35, Enum.EasingStyle.Back)
		if not fabMoved then Lib.setShown(not shown) end
	end
end)
if touch then
	task.spawn(function() -- gentle pulse so it's easy to find
		while gui.Parent do
			tw(fabGlow, {Size=UDim2.fromOffset(72,72)}, 1.4, Enum.EasingStyle.Sine).Completed:Wait()
			tw(fabGlow, {Size=UDim2.fromOffset(62,62)}, 1.4, Enum.EasingStyle.Sine).Completed:Wait()
		end
	end)
	-- phones never fire "mouse left", so clear hover highlights shortly after each tap
	on(UIS.TouchEnded, function()
		task.delay(.35, function()
			for i = #leaves, 1, -1 do
				local o, f = leaves[i][1], leaves[i][2]
				if not o.Parent then table.remove(leaves, i) else task.spawn(f) end
			end
		end)
	end)
end

-- controller: click the right stick to open/close
on(UIS.InputBegan, function(i) if i.KeyCode == Enum.KeyCode.ButtonR3 then Lib.setShown(not shown) end end)

on(gui:GetPropertyChangedSignal("AbsoluteSize"), layout)
task.defer(layout)
fabState()

--[[ ========================== DARKHUB v2 ==========================
 SETTINGS (optional, put these BEFORE the loadstring line):
   getgenv().DarkhubGame         = "Hood Roleplay Chicago"     sidebar subtitle
   getgenv().DarkhubKeybind      = Enum.KeyCode.RightShift     open/close key  (or "RightShift", "Insert", "MouseButton3"...)
   getgenv().DarkhubTheme        = "Darkhub Red"                     starting theme   (default: "Darkhub Blue")
   getgenv().DarkhubAccent       = Color3.fromRGB(46,125,255)  exact starting color (beats DarkhubTheme)
   getgenv().DarkhubResetPresets = true                        wipe every saved preset each time it runs

 addTab(name, order, icon)
     order = position in the sidebar (1 = top). icon is optional: an emoji, or an image id ("rbxassetid://123").

 addSection(tab, name, side, icon)        (optional)
     Makes a card with a header, like "Movement" or "Camera". side = "Left" or "Right"
     (leave it out and sections alternate left/right). Buttons added after it go inside it.
     If you never make a section, buttons go into one called "General". icon works like addTab's.

 addButton(tab, name, description, type, function, options)
   TYPE         YOUR FUNCTION GETS     OPTIONS (all optional)
   "Click"      nothing                -
   "Toggle"     true / false           {default = true}
   "Slider"     number                 {min = 0, max = 100, default = 50, step = 1, suffix = "%"}
   "Input"      text, pressedEnter     {placeholder = "...", default = "..."}
   "Dropdown"   chosen option          {options = {"A","B","C"}, default = "A"}
   "Dropbox"    chosen value           {options = {...} | function() return {...} end | "players",
                (or a table if multi)   multi = true, search = true, placeholder = "...",
                                        format = function(v) return "label" end, includeSelf = false}
                Dropbox control also has:  ctl.Refresh(newOptions)  |  ctl.Clear()
   "Keybind"    nothing (runs on key)  {default = Enum.KeyCode.F}
   "Color"      Color3                 {default = Color3.new(1,0,0)}
   "Label"      (just small text)      -
   Any type can also take:  order = 5  (position inside its section)
                            section = "Movement", side = "Right"  (put it in that section)
                            nosave = true  (leave this control out of presets)

 addButton returns a control:  ctl.value  (current value)  |  ctl.Set(x)  (change it from code)
 Extras:  notify(title, message, seconds)  |  setTheme("Darkhub Red")  |  UI.setAccent(Color3)  |  UI.setShown(true/false)
          UI.setSnow(true/false)  |  UI.setSubtitle("Game Name")  |  UI.themeNames (sorted list of all themes)
          UI.setToggleKey(Enum.KeyCode.RightShift)  |  UI.getToggleKey()

 PRESETS (every Toggle/Slider/Input/Dropdown/Dropbox/Keybind/Color is saved by tab + name):
   savePreset("Legit")     saves everything now           loadPreset("Legit")   applies it
   deletePreset("Legit")   removes it                     listPresets()         list of saved names
   UI.resetPresets()       deletes every saved preset     UI.currentPreset()    last saved/loaded name
   UI.canSave              true if files work
   The last preset you SAVED or LOADED loads by itself next time the script runs.
   v2 wipes old (v1) presets once, the first time it runs.

 Themes (21): Darkhub Blue (default), Darkhub Red, Darkhub Purple, Darkhub Pink, Darkhub Rose, Darkhub Orange,
   Darkhub Gold, Darkhub Yellow, Darkhub Lime, Darkhub Green, Darkhub Mint, Darkhub Teal, Darkhub Cyan, Darkhub Sky,
   Darkhub Indigo, Darkhub Violet, Darkhub Magenta, Darkhub Crimson, Darkhub Brown, Darkhub Silver, Darkhub White
 Left Ctrl (or your DarkhubKeybind) shows or hides the menu.  "/" jumps to the tab search.
================================================================= ]]
return Lib
