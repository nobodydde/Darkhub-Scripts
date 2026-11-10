-- Darkhub Main Menu Config
local Players, TS, UIS, RS = game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local plr = Players.LocalPlayer
local old = plr:WaitForChild("PlayerGui"):FindFirstChild("Darkhub")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "Darkhub", false, true, 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr.PlayerGui

local Lib = {accent = Color3.fromRGB(225,45,65)}
local C = {bg=Color3.fromRGB(25,25,30), side=Color3.fromRGB(20,20,24), card=Color3.fromRGB(32,32,38), hover=Color3.fromRGB(40,40,48),
	elem=Color3.fromRGB(42,42,50), line=Color3.fromRGB(48,48,57), text=Color3.fromRGB(232,232,240), sub=Color3.fromRGB(172,172,188), dim=Color3.fromRGB(132,132,150)}
local FAM, W = "rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight
local AY = Enum.AutomaticSize.Y
local painters, tabs, current = {}, {}, nil

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
local function text(t, size, col, w, p)
	p = p or {}
	p.BackgroundTransparency, p.Text, p.TextSize, p.TextColor3 = 1, t, size, col
	p.FontFace = Font.new(FAM, w or W.Regular)
	p.TextXAlignment = p.TextXAlignment or Enum.TextXAlignment.Left
	return new("TextLabel", p)
end
local function paint(f) table.insert(painters, f) f(Lib.accent, true) end
local function accent(i, prop) paint(function(c, now) if now then i[prop] = c else tw(i, {[prop] = c}, .4) end end) return i end
local function accentGrad(i) -- accent fill with a soft light-to-dark sheen
	i.BackgroundColor3 = Color3.new(1,1,1)
	local g = new("UIGradient", {Parent=i, Rotation=0})
	paint(function(c) g.Color = ColorSequence.new(c:Lerp(Color3.new(1,1,1),.15), c:Lerp(Color3.new(0,0,0),.25)) end)
	return i
end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local leaves = {} -- every "mouse left" effect, so touch screens can clear stuck highlights
local function onLeave(o, f) o.MouseLeave:Connect(f) table.insert(leaves, {o, f}) end
local fadeEdges = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(.5,0), NumberSequenceKeypoint.new(1,1)})

---------------- window
local SIZE = Vector2.new(940, 570)
local holder = new("Frame", {Parent=gui, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromOffset(SIZE.X, SIZE.Y), BackgroundTransparency=1}, new("UIScale", {}))
local scale = holder.UIScale
local shadows = {}
for i = 1, 5 do -- soft shadow from layered rounded frames (no images)
	shadows[i] = new("Frame", {Parent=holder, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,.5,i*2), Size=UDim2.new(1,i*7,1,i*7),
		BackgroundColor3=Color3.new(), BackgroundTransparency=.8+i*.035, ZIndex=0}, corner(14+i*4))
end

local main = new("Frame", {Parent=holder, Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(1,1,1)}, corner(14))
local mainGrad = new("UIGradient", {Parent=main, Rotation=90})
paint(function(c) mainGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.bg:Lerp(c,.07)), ColorSequenceKeypoint.new(.35, C.bg), ColorSequenceKeypoint.new(1, C.bg:Lerp(Color3.new(),.15))}) end)
new("UIStroke", {Parent=main, Color=Color3.new(1,1,1), Transparency=.88, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, new("UIGradient", {Rotation=90, Transparency=NumberSequence.new(0,.8)}))

-- sidebar
local sideTop, sideBot = C.side:Lerp(Color3.new(1,1,1),.04), C.side
local side = new("Frame", {Parent=main, Size=UDim2.new(0,220,1,0), BackgroundColor3=Color3.new(1,1,1)}, corner(14), grad(sideTop, sideBot))
new("Frame", {Parent=side, Position=UDim2.new(1,-14,0,0), Size=UDim2.new(0,14,1,0), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0}, grad(sideTop, sideBot))
new("Frame", {Parent=side, Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,1,1,0), BackgroundColor3=C.line, BorderSizePixel=0})

-- logo: glow sits BEHIND the tile (as a sibling), image is cropped inside a rounded tile with an accent ring
local LOGO = 42
local logoGlow = accent(new("Frame", {Parent=side, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromOffset(14+LOGO/2, 14+LOGO/2), Size=UDim2.fromOffset(LOGO+8, LOGO+8), BackgroundTransparency=.85}, corner(15)), "BackgroundColor3")
local logoTile = new("Frame", {Parent=side, Position=UDim2.fromOffset(14,14), Size=UDim2.fromOffset(LOGO,LOGO), BackgroundColor3=Color3.new(1,1,1), ClipsDescendants=true},
	corner(12), grad(C.card:Lerp(Color3.new(1,1,1),.06), C.side), new("UIScale", {}))
accent(new("UIStroke", {Parent=logoTile, Thickness=1.5, Transparency=.3, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}), "Color")
local logo = new("ImageLabel", {Parent=logoTile, Size=UDim2.fromScale(1,1), Image="rbxassetid://129745620825874", BackgroundTransparency=1, ScaleType=Enum.ScaleType.Crop}, corner(12))
logoTile.MouseEnter:Connect(function() tw(logoTile.UIScale, {Scale=1.08}, .3, Enum.EasingStyle.Back) end)
onLeave(logoTile, function() tw(logoTile.UIScale, {Scale=1}, .3) end)
text("Darkhub", 17, C.text, W.Bold, {Parent=side, Position=UDim2.fromOffset(66,15), Size=UDim2.new(1,-76,0,20)})
local subtitle = text("Arsenal", 14, C.dim, W.Medium, {Parent=side, Position=UDim2.fromOffset(66,36), Size=UDim2.new(1,-76,0,14), TextScaled=true})
new("UITextSizeConstraint", {Parent=subtitle, MaxTextSize=11, MinTextSize=8})

local search = new("Frame", {Parent=side, Position=UDim2.fromOffset(12,70), Size=UDim2.new(1,-24,0,34), BackgroundColor3=C.card}, corner(8), stroke())
text("🔍", 11, C.dim, nil, {Parent=search, Position=UDim2.fromOffset(10,0), Size=UDim2.fromOffset(14,34)})
local searchBox = new("TextBox", {Parent=search, BackgroundTransparency=1, Position=UDim2.fromOffset(30,0), Size=UDim2.new(1,-62,1,0), Text="", PlaceholderText="Search",
	PlaceholderColor3=C.dim, TextColor3=C.text, TextSize=13, FontFace=Font.new(FAM), TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false})
local keyChip = new("Frame", {Parent=search, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-6,.5,0), Size=UDim2.fromOffset(20,20), BackgroundColor3=C.elem}, corner(5))
text("/", 11, C.sub, W.Medium, {Parent=keyChip, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center})
searchBox.Focused:Connect(function() tw(search.S, {Color=Lib.accent}, .2) end)
searchBox.FocusLost:Connect(function() tw(search.S, {Color=C.line}, .2) end)

new("Frame", {Parent=side, Position=UDim2.fromOffset(12,116), Size=UDim2.new(1,-24,0,1), BackgroundColor3=C.line, BorderSizePixel=0})
text("Modules", 12, C.dim, W.Medium, {Parent=side, Position=UDim2.fromOffset(16,124), Size=UDim2.new(1,-32,0,14)})
local tabList = new("ScrollingFrame", {Parent=side, Position=UDim2.fromOffset(0,144), Size=UDim2.new(1,0,1,-210), BackgroundTransparency=1, BorderSizePixel=0,
	ScrollBarThickness=0, CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, list(3), pad(10,2))

local prof = new("Frame", {Parent=side, Position=UDim2.new(0,10,1,-58), Size=UDim2.new(1,-20,0,48), BackgroundColor3=C.card}, corner(10), stroke())
local av = accentGrad(new("Frame", {Parent=prof, Position=UDim2.fromOffset(9,9), Size=UDim2.fromOffset(30,30)}, corner(15)))
text(string.upper(string.sub(plr.DisplayName,1,1)), 14, Color3.new(1,1,1), W.Bold, {Parent=av, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center})
new("Frame", {Parent=av, AnchorPoint=Vector2.new(1,1), Position=UDim2.fromScale(1.05,1.05), Size=UDim2.fromOffset(9,9), BackgroundColor3=Color3.fromRGB(70,210,110)}, corner(5), stroke(C.card))
text(plr.DisplayName, 14, C.text, W.Bold, {Parent=prof, Position=UDim2.fromOffset(47,8), Size=UDim2.new(1,-54,0,16), TextTruncate=Enum.TextTruncate.AtEnd})
text("@"..plr.Name, 12, C.dim, nil, {Parent=prof, Position=UDim2.fromOffset(47,25), Size=UDim2.new(1,-54,0,14), TextTruncate=Enum.TextTruncate.AtEnd})

-- content
local content = new("Frame", {Parent=main, Position=UDim2.fromOffset(221,0), Size=UDim2.new(1,-221,1,0), BackgroundTransparency=1})

-- falling snow (plain frames, no images)
local snow = new("Frame", {Parent=content, Size=UDim2.new(1,-8,1,-8), BackgroundTransparency=1, ClipsDescendants=true})
task.spawn(function()
	while gui.Parent do
		if holder.Visible then
			local s = math.random(2,4)
			local flake = new("Frame", {Parent=snow, Position=UDim2.new(math.random(), 0, 0, -6), Size=UDim2.fromOffset(s,s),
				BackgroundColor3=Color3.new(1,1,1), BackgroundTransparency=math.random(50,80)/100, BorderSizePixel=0}, corner(s))
			local t = math.random(60,100)/10
			tw(flake, {Position=UDim2.new(flake.Position.X.Scale + math.random(-8,8)/100, 0, 1, 6), BackgroundTransparency=.96}, t, Enum.EasingStyle.Linear)
			task.delay(t, flake.Destroy, flake)
		end
		task.wait(.2)
	end
end)

local top = new("Frame", {Parent=content, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1, Active=true},
	new("Frame", {Position=UDim2.new(0,0,1,-1), Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line, BorderSizePixel=0}))
local crumb = text("", 15, C.text, nil, {Parent=top, RichText=true, Position=UDim2.fromOffset(18,0), Size=UDim2.new(0,220,1,0)})

local stats = new("Frame", {Parent=top, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-70,.5,0), Size=UDim2.fromOffset(300,28), BackgroundTransparency=1},
	new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Right, Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}))
local function pill(i)
	local p = new("Frame", {Parent=stats, LayoutOrder=i, Size=UDim2.fromOffset(0,28), AutomaticSize=Enum.AutomaticSize.X, BackgroundColor3=C.card}, corner(7), stroke(), pad(10,0))
	return text("", 12, C.sub, W.Medium, {Parent=p, Size=UDim2.fromScale(0,1), AutomaticSize=Enum.AutomaticSize.X})
end
local fpsL, pingL, plrL = pill(1), pill(2), pill(3)
local frames = 0
RS.RenderStepped:Connect(function() frames += 1 end)
task.spawn(function()
	while gui.Parent do
		task.wait(.5)
		fpsL.Text = (frames * 2).." fps" frames = 0
		pingL.Text = math.floor(plr:GetNetworkPing() * 1000 + .5).." ms"
		plrL.Text = #Players:GetPlayers().."/"..Players.MaxPlayers
	end
end)

local function topBtn(t, x, hoverCol)
	local b = new("TextButton", {Parent=top, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,x,.5,0), Size=UDim2.fromOffset(24,24), BackgroundColor3=C.elem,
		BackgroundTransparency=1, AutoButtonColor=false, Text=t, TextSize=15, TextColor3=C.dim, FontFace=Font.new(FAM, W.Bold)}, corner(7))
	b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency=0, BackgroundColor3=hoverCol, TextColor3=Color3.new(1,1,1)}, .15) end)
	onLeave(b, function() tw(b, {BackgroundTransparency=1, TextColor3=C.dim}, .15) end)
	return b
end
local closeBtn, minBtn = topBtn("×", -12, Color3.fromRGB(220,60,70)), topBtn("–", -40, C.elem)
local pages = new("Frame", {Parent=content, Position=UDim2.fromOffset(0,50), Size=UDim2.new(1,0,1,-50), BackgroundTransparency=1, ClipsDescendants=true})

---------------- notifications (slide in from the right, with a timer bar)
local toasts = new("Frame", {Parent=gui, AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-20,1,-20), Size=UDim2.fromOffset(250,400), BackgroundTransparency=1},
	new("UIListLayout", {VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,8)}))
function Lib.notify(title, msg, time)
	time = time or 3
	local slot = new("Frame", {Parent=toasts, Size=UDim2.fromOffset(250,0), BackgroundTransparency=1})
	local f = new("Frame", {Parent=slot, Position=UDim2.fromOffset(280,0), Size=UDim2.fromOffset(250,54), BackgroundColor3=Color3.new(1,1,1)},
		corner(10), stroke(), grad(C.card:Lerp(Lib.accent,.08), C.card, 0))
	new("Frame", {Parent=f, Position=UDim2.fromOffset(12,13), Size=UDim2.fromOffset(3,28), BackgroundColor3=Lib.accent, BorderSizePixel=0}, corner(2))
	text(tostring(title), 13, C.text, W.Bold, {Parent=f, Position=UDim2.fromOffset(24,9), Size=UDim2.new(1,-34,0,16)})
	text(tostring(msg or ""), 11, C.sub, nil, {Parent=f, Position=UDim2.fromOffset(24,27), Size=UDim2.new(1,-34,0,14), TextTruncate=Enum.TextTruncate.AtEnd})
	local timer = new("Frame", {Parent=f, Position=UDim2.new(0,12,1,-4), Size=UDim2.new(1,-24,0,1), BackgroundColor3=Lib.accent, BorderSizePixel=0})
	tw(slot, {Size=UDim2.fromOffset(250,54)}, .3)
	tw(f, {Position=UDim2.new()}, .5, Enum.EasingStyle.Back)
	tw(timer, {Size=UDim2.new(0,0,0,1)}, time, Enum.EasingStyle.Linear)
	task.delay(time, function()
		tw(f, {Position=UDim2.fromOffset(280,0)}, .35, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
		tw(slot, {Size=UDim2.fromOffset(250,0)}, .2).Completed:Wait()
		slot:Destroy()
	end)
end

function Lib.setAccent(c) Lib.accent = c for _, p in painters do p(c, false) end end

-- Christmas themes: Lib.setTheme("Candy Cane")
Lib.themes = {
	["Candy Cane"]      = Color3.fromRGB(225,45,65),
	["Holly Berry"]     = Color3.fromRGB(190,25,50),
	["Evergreen"]       = Color3.fromRGB(45,170,95),
	["Mistletoe"]       = Color3.fromRGB(130,205,95),
	["Snowfall"]        = Color3.fromRGB(185,220,255),
	["Frostbite"]       = Color3.fromRGB(80,175,255),
	["Golden Star"]     = Color3.fromRGB(255,200,60),
	["Gingerbread"]     = Color3.fromRGB(205,130,70),
	["Hot Cocoa"]       = Color3.fromRGB(165,105,70),
	["Reindeer"]        = Color3.fromRGB(180,120,80),
	["Sugar Plum"]      = Color3.fromRGB(185,95,225),
	["Northern Lights"] = Color3.fromRGB(80,230,190),
	["Tinsel"]          = Color3.fromRGB(210,215,230),
	["Rudolph"]         = Color3.fromRGB(255,60,40),
	["Eggnog"]          = Color3.fromRGB(240,215,150),
	["Winter Night"]    = Color3.fromRGB(100,110,255),
}
function Lib.setTheme(name)
	local c = Lib.themes[name]
	if not c then warn("[Darkhub] No theme called '"..tostring(name).."'") return end
	Lib.setAccent(c)
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
	end
	crumb.Text = ('<font color="#6e6e80">Darkhub</font>  <font color="#4a4a58">›</font>  <b>%s</b>'):format(name)
	crumb.TextTransparency = 1 crumb.Position = UDim2.fromOffset(28,0)
	tw(crumb, {TextTransparency=0, Position=UDim2.fromOffset(18,0)}, .35)
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
UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.Slash and holder.Visible then task.defer(function() searchBox:CaptureFocus() searchBox.Text = "" end) end
end)

function Lib.addTab(name, order, icon)
	order = tonumber(order) or 0
	local b = new("TextButton", {Parent=tabList, LayoutOrder=order, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,40), BackgroundColor3=C.card, BackgroundTransparency=1}, corner(8))
	accent(new("Frame", {Name="Bar", Parent=b, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,-8,.5,0), Size=UDim2.fromOffset(3,0), BorderSizePixel=0}, corner(2)), "BackgroundColor3")
	local box = new("Frame", {Name="Box", Parent=b, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,6,.5,0), Size=UDim2.fromOffset(28,28), BackgroundColor3=C.elem}, corner(8))
	accentGrad(new("Frame", {Name="Fill", Parent=box, Size=UDim2.fromScale(1,1), BackgroundTransparency=1}, corner(7)))
	text(icon or "•", 14, C.text, nil, {Parent=box, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=2})
	text(name, 14, C.sub, W.Medium, {Name="Label", Parent=b, Position=UDim2.fromOffset(44,0), Size=UDim2.new(1,-50,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
	local page = new("ScrollingFrame", {Parent=pages, Visible=false, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
		ScrollBarImageColor3=C.line, CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, pad(0,16)) -- side margins live on the columns (scale sizes ignore ScrollingFrame padding)
	local function col(x)
		return new("Frame", {Parent=page, Position=UDim2.new(x, x == 0 and 18 or 7, 0, 0), Size=UDim2.new(.5,-25,0,0), AutomaticSize=AY, BackgroundTransparency=1}, list(16))
	end
	tabs[name] = {btn=b, page=page, order=order, cols={col(0), col(.5)}, sections={}, wraps={}, nextSide=1}
	b.MouseEnter:Connect(function() if current ~= name then tw(b, {BackgroundTransparency=.5}, .15) tw(b.Label, {TextColor3=C.text}, .15) end end)
	onLeave(b, function() if current ~= name then tw(b, {BackgroundTransparency=1}, .15) tw(b.Label, {TextColor3=C.sub}, .15) end end)
	b.MouseButton1Click:Connect(function() select(name) end)
	if not current or order < tabs[current].order then select(name) end
end

---------------- sections (cards with a header). Optional: buttons go into "General" if you never make one.
local function makeSection(t, name, sideName)
	local colIndex
	if sideName then colIndex = string.lower(tostring(sideName)) == "right" and 2 or 1
	else colIndex = t.nextSide t.nextSide = 3 - t.nextSide end
	local wrap = new("Frame", {Parent=t.cols[colIndex], LayoutOrder=#t.wraps + 1, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, list(8), new("UIScale", {}))
	local hdr = new("Frame", {Parent=wrap, LayoutOrder=1, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16)})
	accent(new("Frame", {Parent=hdr, Position=UDim2.fromOffset(2,1), Size=UDim2.fromOffset(3,14), BorderSizePixel=0}, corner(1)), "BackgroundColor3")
	text(name, 14, C.text, W.SemiBold, {Parent=hdr, Position=UDim2.fromOffset(14,0), Size=UDim2.new(1,-14,1,0)})
	local card = new("Frame", {Parent=wrap, LayoutOrder=2, BackgroundColor3=C.card, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, corner(10), stroke(), list(0), pad(14,0,4))
	local shine = accent(new("Frame", {Parent=card, LayoutOrder=-1, Size=UDim2.new(1,0,0,1), BorderSizePixel=0}), "BackgroundColor3")
	new("UIGradient", {Parent=shine, Transparency=fadeEdges})
	local s = {card=card, count=0}
	t.sections[name] = s
	table.insert(t.wraps, wrap)
	return s
end
function Lib.addSection(tab, name, sideName)
	local t = assert(tabs[tab], "[Darkhub] No tab named '"..tostring(tab).."' - call addTab first")
	local s = t.sections[name] or makeSection(t, name, sideName)
	t.last = s
	return s
end

---------------- buttons
-- addButton(tab, name, description, type, callback, options) -> returns {value, Set}
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
	new("Frame", {Parent=row, LayoutOrder=99, Size=UDim2.new(1,0,0,1), BackgroundColor3=C.line, BackgroundTransparency=.35, BorderSizePixel=0})
	local stacked = kind == "slider" or kind == "dropdown" or kind == "input" or kind == "textbox" or kind == "dropbox"
	local h = desc and 48 or (stacked and 34 or 42)
	local head = new("TextButton", {Parent=row, LayoutOrder=1, Text="", AutoButtonColor=false, BackgroundTransparency=1, Size=UDim2.new(1,0,0,h)})
	local title = text(name, 14, C.text, W.Medium, {Parent=head, Position=UDim2.fromOffset(0, desc and 7 or 0), Size=UDim2.new(1,-120,0, desc and 18 or h), TextTruncate=Enum.TextTruncate.AtEnd})
	if desc then text(desc, 12, C.dim, nil, {Parent=head, Position=UDim2.fromOffset(0,26), Size=UDim2.new(1,-120,0,15), TextTruncate=Enum.TextTruncate.AtEnd}) end
	local extra
	local function getExtra()
		extra = extra or new("Frame", {Parent=row, LayoutOrder=2, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=AY}, list(6), pad(0,0,10))
		return extra
	end
	local function right(class, w, ht, p)
		p = p or {}
		p.Parent, p.AnchorPoint, p.Position, p.Size = head, Vector2.new(1,.5), UDim2.new(1,0,.5,0), UDim2.fromOffset(w, ht)
		p.BackgroundColor3 = p.BackgroundColor3 or C.elem
		if class ~= "Frame" then p.Text, p.TextColor3, p.TextSize, p.FontFace = p.Text or "", C.text, 13, Font.new(FAM, W.Medium) end
		if class == "TextButton" then p.AutoButtonColor = false end
		return new(class, p, corner(ht <= 18 and ht/2 or 6), stroke())
	end
	local function box(class, p) -- full-width box under the title
		p = p or {}
		p.Parent, p.Size, p.BackgroundColor3 = getExtra(), UDim2.new(1,0,0,34), C.elem
		if class ~= "Frame" then p.Text, p.TextColor3, p.TextSize, p.FontFace = p.Text or "", C.text, 13, Font.new(FAM, W.Medium) end
		if class == "TextButton" then p.AutoButtonColor = false end
		return new(class, p, corner(7), stroke())
	end

	if kind == "click" or kind == "button" then
		title.Visible = false
		head.Size = UDim2.new(1,0,0,50)
		local b = new("TextButton", {Parent=head, AnchorPoint=Vector2.new(0,.5), Position=UDim2.fromScale(0,.5), Size=UDim2.new(1,0,0,36), BackgroundColor3=C.elem,
			AutoButtonColor=false, Text=name, TextSize=13, TextColor3=C.text, FontFace=Font.new(FAM, W.Medium)}, corner(7), stroke(), new("UIScale", {}))
		if desc then text(desc, 12, C.dim, nil, {Parent=getExtra(), Size=UDim2.new(1,0,0,0), AutomaticSize=AY, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Center}) end
		b.MouseEnter:Connect(function() tw(b, {BackgroundColor3=C.hover}, .15) tw(b.S, {Color=C.line:Lerp(Lib.accent,.5)}, .15) end)
		onLeave(b, function() tw(b, {BackgroundColor3=C.elem}, .15) tw(b.S, {Color=C.line}, .15) tw(b.UIScale, {Scale=1}, .2) end)
		b.MouseButton1Down:Connect(function() tw(b.UIScale, {Scale=.97}, .1) end)
		b.MouseButton1Up:Connect(function() tw(b.UIScale, {Scale=1}, .35, Enum.EasingStyle.Back) end)
		function api.Set() fire() end
		b.MouseButton1Click:Connect(function()
			b.BackgroundColor3 = C.elem:Lerp(Lib.accent, .45) tw(b, {BackgroundColor3=C.hover}, .5)
			fire()
		end)

	elseif kind == "toggle" then
		local sw = right("Frame", 40, 20)
		local fill = accentGrad(new("Frame", {Parent=sw, Size=UDim2.fromScale(1,1), BackgroundTransparency=1}, corner(10)))
		local knob = new("Frame", {Parent=sw, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,3,.5,0), Size=UDim2.fromOffset(14,14), BackgroundColor3=C.sub, ZIndex=2}, corner(7))
		local function render(_, now)
			local on, t1 = api.value, now and 0 or .3
			tw(fill, {BackgroundTransparency = on and 0 or 1}, t1)
			tw(sw.S, {Transparency = on and 1 or 0}, t1)
			tw(title, {TextColor3 = on and C.text or C.sub}, t1)
			if not now then knob.Size = UDim2.fromOffset(19,14) tw(knob, {Size=UDim2.fromOffset(14,14)}, .35, Enum.EasingStyle.Back) end
			tw(knob, {Position = on and UDim2.new(1,-17,.5,0) or UDim2.new(0,3,.5,0), BackgroundColor3 = on and Color3.new(1,1,1) or C.sub}, t1)
		end
		api.value = o.default == true
		function api.Set(v) api.value = v render() fire(v) end
		head.MouseButton1Click:Connect(function() api.Set(not api.value) end)
		paint(render)

	elseif kind == "slider" then
		local mn, mx, step = o.min or 0, o.max or 100, o.step or 1
		local valBox = right("TextBox", 56, 24, {ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Center})
		local tr = new("TextButton", {Parent=getExtra(), Text="", AutoButtonColor=false, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14)})
		local bar = new("Frame", {Parent=tr, AnchorPoint=Vector2.new(0,.5), Position=UDim2.fromScale(0,.5), Size=UDim2.new(1,0,0,5), BackgroundColor3=C.elem}, corner(3))
		local fill = new("Frame", {Parent=bar, BorderSizePixel=0, BackgroundColor3=Color3.new(1,1,1)}, corner(2))
		local fg = new("UIGradient", {Parent=fill})
		paint(function(c) fg.Color = ColorSequence.new(c:Lerp(Color3.new(0,0,0),.4), c:Lerp(Color3.new(1,1,1),.1)) end)
		local knob = new("Frame", {Parent=tr, AnchorPoint=Vector2.new(.5,.5), Size=UDim2.fromOffset(12,12), BackgroundColor3=Color3.new(1,1,1)}, corner(6))
		local ring = accent(new("UIStroke", {Parent=knob, Thickness=0}), "Color")
		function api.Set(v, silent)
			v = tonumber(v) or api.value or mn
			v = math.clamp(math.round((v - mn) / step) * step + mn, mn, mx)
			v = math.round(v * 100) / 100
			valBox.Text = tostring(v)..(o.suffix or "")
			if v == api.value and not silent then return end
			api.value = v
			local a = (v - mn) / (mx - mn)
			tw(fill, {Size=UDim2.fromScale(a,1)}, silent and 0 or .12) tw(knob, {Position=UDim2.fromScale(a,.5)}, silent and 0 or .12)
			if not silent then fire(v) end
		end
		valBox.Focused:Connect(function() valBox.Text = tostring(api.value) tw(valBox.S, {Color=Lib.accent}, .2) end)
		valBox.FocusLost:Connect(function() tw(valBox.S, {Color=C.line}, .2) api.Set(tonumber((valBox.Text:gsub("[^%d%.%-]", ""))) or api.value) end)
		local drag = false
		local function upd(x) api.Set(mn + (mx - mn) * math.clamp((x - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)) end
		tr.InputBegan:Connect(function(i)
			if isPress(i) then drag = true t.page.ScrollingEnabled = false upd(i.Position.X) tw(knob, {Size=UDim2.fromOffset(15,15)}, .2, Enum.EasingStyle.Back) tw(ring, {Thickness=3}, .2) end
		end)
		UIS.InputChanged:Connect(function(i) if drag and isMove(i) then upd(i.Position.X) end end)
		UIS.InputEnded:Connect(function(i)
			if drag and isPress(i) then drag = false t.page.ScrollingEnabled = true tw(knob, {Size=UDim2.fromOffset(12,12)}, .2) tw(ring, {Thickness=0}, .2) end
		end)
		api.Set(o.default or mn, true)

	elseif kind == "input" or kind == "textbox" then
		local tb = box("TextBox", {Text=o.default or "", PlaceholderText=o.placeholder or "Type here...", PlaceholderColor3=C.dim, ClearTextOnFocus=false,
			TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd})
		pad(10).Parent = tb
		api.value = tb.Text
		tb.Focused:Connect(function() tw(tb.S, {Color=Lib.accent}, .2) end)
		function api.Set(v) tb.Text = tostring(v) api.value = tb.Text fire(tb.Text) end
		tb.FocusLost:Connect(function(enter) tw(tb.S, {Color=C.line}, .2) api.value = tb.Text fire(tb.Text, enter) end)

	elseif kind == "dropdown" then
		local opts = o.options or {}
		api.value = o.default or opts[1]
		local b = box("TextButton")
		local lbl = text(tostring(api.value or "Select"), 13, C.text, W.Medium, {Parent=b, Position=UDim2.fromOffset(10,0), Size=UDim2.new(1,-34,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
		local arrow = new("Frame", {Parent=b, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-10,.5,0), Size=UDim2.fromOffset(12,12), BackgroundTransparency=1}) -- chevron drawn from 2 bars (the arrow glyph showed as a box)
		for _, r in {-45, 45} do new("Frame", {Parent=arrow, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5, r < 0 and -2 or 2, .5, 0), Size=UDim2.fromOffset(2,8), Rotation=r, BackgroundColor3=C.sub, BorderSizePixel=0}, corner(1)) end
		local menu = new("Frame", {Parent=getExtra(), Visible=false, Size=UDim2.new(1,0,0,0), AutomaticSize=AY, BackgroundColor3=C.side}, corner(7), stroke(), list(0), pad(4,4))
		local items = {}
		local function mark()
			pcall(function()
				for opt, it in items do
					local sel = opt == api.value
					if it.Bar then tw(it.Bar, {BackgroundTransparency = sel and 0 or 1}, .2) end
					if it.Check then tw(it.Check, {TextTransparency = sel and 0 or 1}, .2) end
					if it.Label then tw(it.Label, {TextColor3 = sel and C.text or C.sub}, .2) end
				end
			end)
		end
		function api.Set(v) api.value = v lbl.Text = tostring(v) mark() fire(v) end
		for _, opt in opts do
			local it = new("TextButton", {Parent=menu, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,30), BackgroundColor3=C.card, BackgroundTransparency=1}, corner(5), new("UIScale", {}))
			text(tostring(opt), 13, C.sub, nil, {Name="Label", Parent=it, Position=UDim2.fromOffset(10,0), Size=UDim2.new(1,-34,1,0)})
			accent(new("Frame", {Name="Bar", Parent=it, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,2,.5,0), Size=UDim2.fromOffset(2,14), BackgroundTransparency=1, BorderSizePixel=0}, corner(1)), "BackgroundColor3")
			text("✓", 12, C.text, W.Bold, {Name="Check", Parent=it, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-8,.5,0), Size=UDim2.fromOffset(14,14), TextTransparency=1, TextXAlignment=Enum.TextXAlignment.Center})
			items[opt] = it
			it.MouseEnter:Connect(function() tw(it, {BackgroundTransparency=0}, .12) end)
			onLeave(it, function() tw(it, {BackgroundTransparency=1}, .12) end)
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
					it.UIScale.Scale = .9
					task.delay(i * .025, function() tw(it.UIScale, {Scale=1}, .3, Enum.EasingStyle.Back) end)
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
		local lbl = text("", 13, C.text, W.Medium, {Parent=b, Position=UDim2.fromOffset(10,0), Size=UDim2.new(1,-40,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
		local arrow = new("Frame", {Parent=b, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-10,.5,0), Size=UDim2.fromOffset(12,12), BackgroundTransparency=1})
		for _, r in {-45, 45} do new("Frame", {Parent=arrow, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5, r < 0 and -2 or 2, .5, 0), Size=UDim2.fromOffset(2,8), Rotation=r, BackgroundColor3=C.sub, BorderSizePixel=0}, corner(1)) end
		local menu = new("Frame", {Parent=getExtra(), Visible=false, Size=UDim2.new(1,0,0,0), AutomaticSize=AY, BackgroundColor3=C.side}, corner(7), stroke(), list(4), pad(4,4))
		local sb = new("TextBox", {Parent=menu, LayoutOrder=1, Size=UDim2.new(1,0,0,28), BackgroundColor3=C.card, Text="", PlaceholderText="Search...", PlaceholderColor3=C.dim,
			TextColor3=C.text, TextSize=12, FontFace=Font.new(FAM), TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false}, corner(5), stroke(), pad(8))
		local scroll = new("ScrollingFrame", {Parent=menu, LayoutOrder=2, Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2,
			ScrollBarImageColor3=C.line, CanvasSize=UDim2.new(), AutomaticCanvasSize=AY}, list(0))
		local empty = text("Nothing here", 12, C.dim, nil, {Parent=menu, LayoutOrder=3, Size=UDim2.new(1,0,0,26), TextXAlignment=Enum.TextXAlignment.Center, Visible=false})
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
			pcall(function()
				for _, it in items do
					local sel = isSel(it.v)
					if it.btn and it.btn.Bar then tw(it.btn.Bar, {BackgroundTransparency = sel and 0 or 1}, .2) end
					if it.btn and it.btn.Check then tw(it.btn.Check, {TextTransparency = sel and 0 or 1}, .2) end
					if it.btn and it.btn.Label then tw(it.btn.Label, {TextColor3 = sel and C.text or C.sub}, .2) end
				end
			end)
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
					local it = new("TextButton", {Parent=scroll, LayoutOrder=#items + 1, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,30), BackgroundColor3=C.card, BackgroundTransparency=1}, corner(5), new("UIScale", {}))
					text(l, 13, C.sub, nil, {Name="Label", Parent=it, Position=UDim2.fromOffset(10,0), Size=UDim2.new(1,-34,1,0), TextTruncate=Enum.TextTruncate.AtEnd})
					accent(new("Frame", {Name="Bar", Parent=it, AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,2,.5,0), Size=UDim2.fromOffset(2,14), BackgroundTransparency=1, BorderSizePixel=0}, corner(1)), "BackgroundColor3")
					text("✓", 12, C.text, W.Bold, {Name="Check", Parent=it, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-8,.5,0), Size=UDim2.fromOffset(14,14), TextTransparency=1, TextXAlignment=Enum.TextXAlignment.Center})
					it.MouseEnter:Connect(function() tw(it, {BackgroundTransparency=0}, .12) end)
					onLeave(it, function() tw(it, {BackgroundTransparency=1}, .12) end)
					it.MouseButton1Click:Connect(function() choose(v) end)
					table.insert(items, {v=v, btn=it})
					if animate then
						it.UIScale.Scale = .9
						task.delay(#items * .025, function() tw(it.UIScale, {Scale=1}, .3, Enum.EasingStyle.Back) end)
					end
				end
			end
			scroll.Size = UDim2.new(1,0,0, math.min(#items, 6) * 30)
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
			Players.PlayerAdded:Connect(function() if gui.Parent and menu.Visible then build(false) end end)
			Players.PlayerRemoving:Connect(function(p)
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
		local b = right("TextButton", 78, 24, {Text=api.value.Name})
		b.AutomaticSize = Enum.AutomaticSize.X pad(8).Parent = b -- grows for long names like MouseButton2
		local waiting = false
		function api.Set(k) api.value = k b.Text = k.Name tw(b.S, {Color=C.line}, .2) tw(b, {TextColor3=C.text}, .2) end
		b.MouseButton1Click:Connect(function() waiting = true b.Text = "..." tw(b.S, {Color=Lib.accent}, .2) tw(b, {TextColor3=Lib.accent}, .2) end)
		local UIT = Enum.UserInputType
		UIS.InputBegan:Connect(function(i, gp)
			local key = i.UserInputType == UIT.Keyboard or i.UserInputType == UIT.Gamepad1
			local extraMouse = i.UserInputType == UIT.MouseButton2 or i.UserInputType == UIT.MouseButton3
			if waiting then
				if key then waiting = false api.Set(i.KeyCode)
				elseif extraMouse then waiting = false api.Set(i.UserInputType)
				elseif isPress(i) then -- tapped/clicked somewhere else: cancel and keep the old bind
					task.defer(function() if waiting then waiting = false api.Set(api.value) end end)
				end
			elseif not gp and ((key and i.KeyCode == api.value) or (extraMouse and i.UserInputType == api.value)) then
				b.BackgroundColor3 = Lib.accent tw(b, {BackgroundColor3=C.elem}, .4)
				fire()
			end
		end)

	elseif kind == "color" then
		api.value = o.default or Lib.accent
		local sw = right("TextButton", 40, 20, {BackgroundColor3=api.value})
		sw.S.Transparency = .6
		local sc = new("UIScale", {Parent=sw})
		function api.Set(c) api.value = c tw(sw, {BackgroundColor3=c}, .3) fire(c) end
		local function shift()
			sc.Scale = .8 tw(sc, {Scale=1}, .4, Enum.EasingStyle.Back)
			local hh, s, v = api.value:ToHSV()
			api.Set(Color3.fromHSV((hh + .08) % 1, math.max(s, .6), math.max(v, .85)))
		end
		sw.MouseButton1Click:Connect(shift) head.MouseButton1Click:Connect(shift)

	elseif kind == "label" then
		title.TextColor3, title.TextSize, title.TextWrapped = C.sub, 13, true
		title.TextTruncate = Enum.TextTruncate.None
		title.Position, title.Size, title.AutomaticSize = UDim2.new(), UDim2.new(1,0,0,0), AY
		head.Size, head.AutomaticSize = UDim2.new(1,0,0,0), AY
		pad(0,9).Parent = head

	else
		warn("[Darkhub] Unknown type '"..kind.."' for "..name..". Use Click, Toggle, Slider, Input, Dropdown, Dropbox, Keybind, Color or Label")
	end
	return api
end

---------------- drag (smooth follow) / show / hide
local dragging, dStart, pStart
top.InputBegan:Connect(function(i) if isPress(i) then dragging, dStart, pStart = true, i.Position, holder.Position end end)
UIS.InputChanged:Connect(function(i)
	if dragging and isMove(i) then
		local d = i.Position - dStart
		tw(holder, {Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)}, .12)
	end
end)
UIS.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)

local function fit() local v = workspace.CurrentCamera.ViewportSize return math.min(1, (v.X-32)/SIZE.X, (v.Y-32)/SIZE.Y) end
local shown = true
function Lib.setShown(v)
	shown = v
	if v then
		holder.Visible = true scale.Scale = fit()*.85
		tw(scale, {Scale=fit()}, .5, Enum.EasingStyle.Back)
		for i, s in shadows do s.BackgroundTransparency = 1 tw(s, {BackgroundTransparency=.8+i*.035}, .6) end
	else
		tw(scale, {Scale=fit()*.88}, .18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(.18, function() if not shown then holder.Visible = false end end)
	end
end
local function hide() Lib.setShown(false) Lib.notify("Darkhub hidden", "Press Left Ctrl to reopen") end
closeBtn.MouseButton1Click:Connect(hide) minBtn.MouseButton1Click:Connect(hide)
UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.LeftControl then Lib.setShown(not shown) end end)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() if shown then scale.Scale = fit() end end)

task.spawn(function() -- logo breathing glow
	while gui.Parent do
		tw(logoGlow, {Size=UDim2.fromOffset(LOGO+16,LOGO+16), BackgroundTransparency=.93}, 1.6, Enum.EasingStyle.Sine).Completed:Wait()
		tw(logoGlow, {Size=UDim2.fromOffset(LOGO+6,LOGO+6), BackgroundTransparency=.82}, 1.6, Enum.EasingStyle.Sine).Completed:Wait()
	end
end)
Lib.setShown(true)

---------------- MOBILE / SMALL SCREENS (add-on: on a normal PC screen nothing above changes)
-- * Phones/tablets/small windows: the menu resizes to fit the screen instead of shrinking into tiny text.
-- * Narrow screens: icon-only sidebar, and sections stack in one column.
-- * Touch devices: a floating, draggable Darkhub button opens/closes the menu.
-- * Controllers: R3 (right stick click) opens/closes the menu.
local BASE, origFit = SIZE, fit
local touch = UIS.TouchEnabled
if touch then gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end -- keep clear of notches / home bar

local sideBits, divider = {}, nil -- sidebar parts that only fit in the wide layout
for _, c in side:GetChildren() do
	if c:IsA("TextLabel") or c == search then table.insert(sideBits, c) end
	if c:IsA("Frame") and c.Position == UDim2.fromOffset(12,116) then divider = c end
end
local profBits = {}
for _, c in prof:GetChildren() do if c:IsA("TextLabel") then table.insert(profBits, c) end end

local compact, single = false, false
local function compactTab(t)
	t.btn.Label.Visible = not compact
	t.btn.Box.Position = compact and UDim2.new(.5,-14,.5,0) or UDim2.new(0,6,.5,0)
end
local function singleTab(t)
	local stack = t.page:FindFirstChild("MobileStack")
	if single and not stack then
		new("UIListLayout", {Name="MobileStack", Parent=t.page, Padding=UDim.new(0,16), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center})
		t.cols[1].LayoutOrder, t.cols[2].LayoutOrder = 1, 2
		for _, c in t.cols do c.Size = UDim2.new(1,-36,0,0) end
	elseif not single and stack then
		stack:Destroy()
		t.cols[1].Position, t.cols[1].Size = UDim2.new(0,18,0,0), UDim2.new(.5,-25,0,0)
		t.cols[2].Position, t.cols[2].Size = UDim2.new(.5,7,0,0), UDim2.new(.5,-25,0,0)
	end
end
local function setCompact(on)
	compact = on
	local sw = on and 64 or 220
	side.Size = UDim2.new(0,sw,1,0)
	content.Position, content.Size = UDim2.fromOffset(sw+1,0), UDim2.new(1,-(sw+1),1,0)
	logoTile.Position = UDim2.fromOffset(on and 11 or 14, 14)
	logoGlow.Position = UDim2.fromOffset((on and 11 or 14) + LOGO/2, 14 + LOGO/2)
	for _, c in sideBits do c.Visible = not on end
	for _, c in profBits do c.Visible = not on end
	if divider then divider.Position = UDim2.fromOffset(12, on and 66 or 116) end
	tabList.Position, tabList.Size = UDim2.fromOffset(0, on and 76 or 144), UDim2.new(1,0,1, on and -142 or -210)
	av.Position = UDim2.fromOffset(on and 7 or 9, 9)
	for _, t in tabs do compactTab(t) end
end

local function layout()
	local vp = gui.AbsoluteSize
	if vp.X < 2 then return end
	local small = touch or vp.X < 1000 or vp.Y < 620
	local s, w, h = nil, BASE.X, BASE.Y
	if small then
		s = math.clamp(math.min(vp.X/760, vp.Y/470), .72, 1)   -- never shrink text below 72%
		w, h = math.min(BASE.X, (vp.X-20)/s), math.min(BASE.Y, (vp.Y-20)/s)
		fit = function() return s end
	else
		fit = origFit
	end
	SIZE = Vector2.new(w, h)
	holder.Size = UDim2.fromOffset(w, h)
	if (w < 760) ~= compact then setCompact(w < 760) end
	local contentW = w - (compact and 65 or 221)
	stats.Visible = contentW >= 560
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

-- the "reopen" hint should make sense on touch screens
local origNotify = Lib.notify
function Lib.notify(title, msg, time)
	if touch and msg == "Press Left Ctrl to reopen" then msg = "Tap the Darkhub button to reopen" end
	return origNotify(title, msg, time)
end

-- floating open/close button (touch devices)
local fabGlow = accent(new("Frame", {Parent=gui, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(0,46,.5,0), Size=UDim2.fromOffset(64,64),
	BackgroundTransparency=.82, Visible=touch, ZIndex=9}, corner(32)), "BackgroundColor3")
local fab = new("ImageButton", {Parent=gui, Name="MobileToggle", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(0,46,.5,0), Size=UDim2.fromOffset(52,52),
	BackgroundColor3=C.card, Image="rbxassetid://129745620825874", ScaleType=Enum.ScaleType.Crop, AutoButtonColor=false, Visible=touch, ZIndex=10},
	corner(26), new("UIScale", {}))
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
UIS.InputChanged:Connect(function(i)
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
UIS.InputEnded:Connect(function(i)
	if fabDown and isPress(i) then
		fabDown = false
		tw(fab.UIScale, {Scale=1}, .35, Enum.EasingStyle.Back)
		if not fabMoved then Lib.setShown(not shown) end
	end
end)
task.spawn(function() -- gentle pulse so it's easy to find
	while gui.Parent do
		tw(fabGlow, {Size=UDim2.fromOffset(72,72)}, 1.4, Enum.EasingStyle.Sine).Completed:Wait()
		tw(fabGlow, {Size=UDim2.fromOffset(62,62)}, 1.4, Enum.EasingStyle.Sine).Completed:Wait()
	end
end)

-- touch: phones never fire "mouse left", so clear hover highlights shortly after each tap
if touch then
	UIS.TouchEnded:Connect(function()
		task.delay(.35, function()
			for i = #leaves, 1, -1 do
				local o, f = leaves[i][1], leaves[i][2]
				if not o.Parent then table.remove(leaves, i) else task.spawn(f) end
			end
		end)
	end)
end

-- controller: click the right stick to open/close
UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.ButtonR3 then Lib.setShown(not shown) end end)

gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
task.defer(layout)
fabState()

--[[ ========================== DARKHUB ==========================
 addTab(name, order, icon)
     order = position in the sidebar (1 = top). icon is optional (an emoji).

 addSection(tab, name, side)        (optional)
     Makes a card with a header, like "Movement" or "Camera". side = "Left" or "Right"
     (leave it out and sections alternate left/right). Buttons added after it go inside it.
     If you never make a section, buttons go into one called "General".

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

 addButton returns a control:  ctl.value  (current value)  |  ctl.Set(x)  (change it from code)
 Extras:  notify(title, message, seconds)  |  setTheme("Evergreen")  |  UI.setAccent(Color3)  |  UI.setShown(true/false)

 Christmas themes:  Candy Cane, Holly Berry, Evergreen, Mistletoe, Snowfall, Frostbite,
   Golden Star, Gingerbread, Hot Cocoa, Reindeer, Sugar Plum, Northern Lights,
   Tinsel, Rudolph, Eggnog, Winter Night
 Left Ctrl shows or hides the menu.  "/" jumps to the tab search.
================================================================= ]]
local UI = Lib
local addTab, addSection, addButton, notify, setTheme = UI.addTab, UI.addSection, UI.addButton, UI.notify, UI.setTheme

-------------------- YOUR CODE BELOW --------------------







addTab("Aimbot", 1, "🎯")
addTab("Visuals", 2, "👁")
addTab("Player", 3, "🧍")
addTab("Misc", 4, "🛠")
addTab("Settings", 5, "⚙️")

-------------------- AIMBOT: SILENT AIM & CAMERA --------------------
local AimSettings = {
	silentEnabled = false,
	silentPart = "Head",
	silentFov = 150,
	silentShowFov = true,
	silentColor = Color3.fromRGB(225, 45, 65),
	silentTeamCheck = true,

	camEnabled = false,
	camPart = "Head",
	camFov = 150,
	camShowFov = true,
	camColor = Color3.fromRGB(255, 255, 255),
	camSmoothness = 1,
	camKey = Enum.UserInputType.MouseButton2,
	camTeamCheck = true,
}

local currentSilentTarget = nil
local currentCamTarget = nil
local isKeyHeld = false
local hookedFunctions = {}

-- FOV GUIS
local silentGui, silentCircle
local camGui, camCircle

local function updateFovVisuals()
	if not silentGui then
		silentGui = Instance.new("ScreenGui")
		silentGui.Name = "DarkhubSilentFOV"
		silentGui.ResetOnSpawn = false
		silentGui.IgnoreGuiInset = true
		silentGui.DisplayOrder = 99
		silentGui.Parent = plr.PlayerGui

		silentCircle = Instance.new("Frame")
		silentCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		silentCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		silentCircle.BackgroundTransparency = 1
		silentCircle.Parent = silentGui
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = silentCircle
		
		local stroke = Instance.new("UIStroke")
		stroke.Name = "Ring"
		stroke.Thickness = 1.5
		stroke.Transparency = 0.5
		stroke.Parent = silentCircle
	end
	silentGui.Enabled = AimSettings.silentShowFov and AimSettings.silentEnabled
	if silentGui.Enabled then
		silentCircle.Size = UDim2.fromOffset(AimSettings.silentFov * 2, AimSettings.silentFov * 2)
		silentCircle.Ring.Color = AimSettings.silentColor
	end

	if not camGui then
		camGui = Instance.new("ScreenGui")
		camGui.Name = "DarkhubCamFOV"
		camGui.ResetOnSpawn = false
		camGui.IgnoreGuiInset = true
		camGui.DisplayOrder = 99
		camGui.Parent = plr.PlayerGui

		camCircle = Instance.new("Frame")
		camCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		camCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		camCircle.BackgroundTransparency = 1
		camCircle.Parent = camGui
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = camCircle
		
		local stroke = Instance.new("UIStroke")
		stroke.Name = "Ring"
		stroke.Thickness = 1.5
		stroke.Transparency = 0.5
		stroke.Parent = camCircle
	end
	camGui.Enabled = AimSettings.camShowFov and AimSettings.camEnabled
	if camGui.Enabled then
		camCircle.Size = UDim2.fromOffset(AimSettings.camFov * 2, AimSettings.camFov * 2)
		camCircle.Ring.Color = AimSettings.camColor
	end
end

-- TARGET FINDERS (Throttled to save FPS)
local targetAccumulator = 0
RS.RenderStepped:Connect(function(dt)
	targetAccumulator += dt
	if targetAccumulator < 0.05 then return end 
	targetAccumulator = 0
	
	local camera = workspace.CurrentCamera
	local myChar = plr.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	-- Get the spectator box location
	local specBox = workspace:FindFirstChild("SpectatorBox")
	local specSpawn = specBox and specBox:FindFirstChild("SpawnLocation")
	local specPos = specSpawn and specSpawn.Position
	
	local function isValidTarget(player)
		local char = player.Character
		if not char then return false end
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		
		if not hum or not hrp then return false end
		
		-- 1. STRICT HEALTH & STATE CHECK
		if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then 
			return false 
		end
		
		-- 2. SPECTATOR BOX CHECK (The ultimate fix)
		if specPos and (hrp.Position - specPos).Magnitude < 50 then
			return false 
		end
		
		-- 3. DISTANCE CHECK (Max 350 studs)
		local distToMe = (hrp.Position - myHRP.Position).Magnitude
		if distToMe > 350 then return false end
		
		return true
	end
	
	local function passesTeamCheck(player, checkEnabled)
		if not checkEnabled then return true end
		if not plr.Team or not player.Team then return true end
		return plr.Team ~= player.Team
	end

	if AimSettings.silentEnabled then
		local closestDist = math.huge
		local closestPart = nil
		for _, v in pairs(game.Players:GetPlayers()) do
			if v ~= plr and isValidTarget(v) and passesTeamCheck(v, AimSettings.silentTeamCheck) then
				local char = v.Character
				local part = char:FindFirstChild(AimSettings.silentPart == "Random" and "Head" or AimSettings.silentPart)
				if part then
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen and screenPos.Z > 0 then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
						if dist < closestDist and dist < AimSettings.silentFov then 
							closestDist = dist
							closestPart = part
						end
					end
				end
			end
		end
		currentSilentTarget = closestPart
	else
		currentSilentTarget = nil
	end
	
	if AimSettings.camEnabled and isKeyHeld then
		local closestDist = math.huge
		local closestPart = nil
		
		for _, v in pairs(game.Players:GetPlayers()) do
			if v ~= plr and isValidTarget(v) and passesTeamCheck(v, AimSettings.camTeamCheck) then
				local char = v.Character
				local part = char:FindFirstChild(AimSettings.camPart == "Random" and "Head" or AimSettings.camPart)
				if part then
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen and screenPos.Z > 0 then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
						
						if dist < closestDist and dist < AimSettings.camFov then
							-- LINE OF SIGHT CHECK
							local origin = camera.CFrame.Position
							local params = RaycastParams.new()
							params.FilterType = Enum.RaycastFilterType.Exclude
							params.FilterDescendantsInstances = {plr.Character}
							params.IgnoreWater = true
							
							local direction = (part.Position - origin)
							local result = workspace:Raycast(origin, direction, params)
							
							local isVisible = true
							if result then
								local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
								isVisible = (game.Players:GetPlayerFromCharacter(hitModel) == v)
							end

							if isVisible then
								closestDist = dist
								closestPart = part
							end
						end
					end
				end
			end
		end
		currentCamTarget = closestPart
	else
		currentCamTarget = nil
	end
end)

-- CAMERA SMOOTHING
RS.RenderStepped:Connect(function(dt)
	if AimSettings.camEnabled and isKeyHeld and currentCamTarget then
		local camera = workspace.CurrentCamera
		
		local targetParent = currentCamTarget.Parent
		local targetHum = targetParent and targetParent:FindFirstChild("Humanoid")
		local targetHRP = targetParent and targetParent:FindFirstChild("HumanoidRootPart")
		
		-- Force drop the target if they die, fly up, or go beyond the map limit
		if not targetHum or targetHum.Health <= 0 or not targetHRP or targetHRP.Position.Y > 300 or targetHRP.AssemblyLinearVelocity.Y > 50 then
			currentCamTarget = nil 
			return
		end

		local targetCFrame = CFrame.lookAt(camera.CFrame.Position, currentCamTarget.Position)
		
		if AimSettings.camSmoothness <= 0 then
			camera.CFrame = targetCFrame
		else
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, math.clamp(dt * (10 / AimSettings.camSmoothness), 0, 1))
		end
	end
end)

-- HOOK FUNCTION
local function applyHook(v)
	if hookedFunctions[v] then return end 
	hookedFunctions[v] = true
	
	local old
	old = hookfunction(v, function(p1, p2)
		if AimSettings.silentEnabled and currentSilentTarget and currentSilentTarget.Position then
			local myChar = plr.Character
			if myChar and myChar:FindFirstChild("Head") then
				local myHead = myChar:FindFirstChild("Head")
				local direction = (currentSilentTarget.Position - myHead.Position)
				if typeof(p1) == "Ray" then
					p1 = Ray.new(myHead.Position, direction)
				end
			end
		end
		return old(p1, p2)
	end)
end

local function scanForCast()
	for i, v in pairs(getgc(true)) do 
		if type(v) == "function" and islclosure(v) and not hookedFunctions[v] then
			if debug.info(v, "n") == "cast" then
				applyHook(v)
			end
		end
	end
end

plr.CharacterAdded:Connect(function()
	task.wait(2)
	scanForCast()
end)
plr.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.5)
			scanForCast()
		end
	end)
end)

-- KEYBIND LISTENER
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == AimSettings.camKey or input.KeyCode == AimSettings.camKey then
		isKeyHeld = true
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == AimSettings.camKey or input.KeyCode == AimSettings.camKey then
		isKeyHeld = false
	end
end)

-- UI SETUP
addSection("Aimbot", "Silent Aim", "Left")
addSection("Aimbot", "Camera Aimbot", "Right")

addButton("Aimbot", "Enable Silent Aim", "Hooks the game's raycast to hit the closest player", "Toggle", function(on)
	AimSettings.silentEnabled = on
	updateFovVisuals()
	if on then scanForCast() end
end, {default = false, section = "Silent Aim"})
addButton("Aimbot", "Target Part", "Where to aim on the target", "Dropdown", function(val) AimSettings.silentPart = val end, {options = {"Head", "HumanoidRootPart", "Random"}, default = "Head", section = "Silent Aim"})
addButton("Aimbot", "Team Check", "Ignore players on your own team", "Toggle", function(on) AimSettings.silentTeamCheck = on end, {default = true, section = "Silent Aim"})
addButton("Aimbot", "Aim FOV", "Size of the silent aim radius", "Slider", function(val) AimSettings.silentFov = val updateFovVisuals() end, {min = 10, max = 500, default = 150, section = "Silent Aim"})
addButton("Aimbot", "Show FOV Circle", "Draws a ring showing the aimbot radius", "Toggle", function(on) AimSettings.silentShowFov = on updateFovVisuals() end, {default = true, section = "Silent Aim"})
addButton("Aimbot", "FOV Color", "Color of the Silent Aim FOV", "Color", function(c) AimSettings.silentColor = c updateFovVisuals() end, {default = AimSettings.silentColor, section = "Silent Aim"})

addButton("Aimbot", "Enable Aimbot", "Moves your camera smoothly to the target when holding the key", "Toggle", function(on) AimSettings.camEnabled = on updateFovVisuals() end, {default = false, section = "Camera Aimbot"})
addButton("Aimbot", "Target Part", "Where to aim on the target", "Dropdown", function(val) AimSettings.camPart = val end, {options = {"Head", "HumanoidRootPart", "Random"}, default = "Head", section = "Camera Aimbot"})
addButton("Aimbot", "Team Check", "Ignore players on your own team", "Toggle", function(on) AimSettings.camTeamCheck = on end, {default = true, section = "Camera Aimbot"})
addButton("Aimbot", "Smoothness", "1 is normal, 0 is instant snap, 3 is very smooth", "Slider", function(val) AimSettings.camSmoothness = val end, {min = 0, max = 3, default = 1, section = "Camera Aimbot"})
addButton("Aimbot", "Aim FOV", "Size of the camera aimbot radius", "Slider", function(val) AimSettings.camFov = val updateFovVisuals() end, {min = 10, max = 500, default = 150, section = "Camera Aimbot"})
addButton("Aimbot", "Show FOV Circle", "Draws a ring showing the aimbot radius", "Toggle", function(on) AimSettings.camShowFov = on updateFovVisuals() end, {default = true, section = "Camera Aimbot"})
addButton("Aimbot", "FOV Color", "Color of the Camera Aimbot FOV", "Color", function(c) AimSettings.camColor = c updateFovVisuals() end, {default = AimSettings.camColor, section = "Camera Aimbot"})
addButton("Aimbot", "Aimbot Keybind", "Hold this key to activate the camera aimbot", "Keybind", function(key) if type(key) == "EnumItem" then AimSettings.camKey = key end end, {default = Enum.UserInputType.MouseButton2, section = "Camera Aimbot"})

-------------------- VISUALS: ESP & CAMERA --------------------
local ESP = {
	playerEnabled = false,
	teamCheck = true,
	useCustomColor = false,
	customColor = Color3.fromRGB(255, 255, 255),
	showDistance = true,
	showTracers = false,
	tracerColor = Color3.fromRGB(225, 45, 65),
	tracerStart = "Bottom",
	
	maxDist = 500,
	objects = {},
	drawings = {},
	conns = {},
}
local COL_ENEMY = Color3.fromRGB(255, 60, 60)
local COL_TEAM = Color3.fromRGB(60, 255, 60)

local CameraMods = {
	fovEnabled = false, -- NEW: Don't force FOV until toggled
	fov = 70,
	mouseUnlocked = false,
	mouseKey = Enum.KeyCode.X,
	unlockEnabled = true,
}

local function getRpName(player)
	return player.DisplayName
end

local function createESP(player)
	if ESP.objects[player] then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	if not hrp or not head then return end

	local hl = Instance.new("Highlight")
	hl.Name = "DarkhubESP"
	hl.FillTransparency = 0.6
	hl.OutlineTransparency = 1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = char
	hl.Parent = char

	local bb = Instance.new("BillboardGui")
	bb.Name = "DarkhubESPBb"
	bb.Size = UDim2.fromOffset(200, 50)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	bb.Parent = char

	local nameLbl = Instance.new("TextLabel")
	nameLbl.BackgroundTransparency = 1
	nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextScaled = true
	nameLbl.TextColor3 = Color3.new(1,1,1)
	nameLbl.TextStrokeTransparency = 0.2
	nameLbl.Text = getRpName(player)
	nameLbl.Parent = bb

	local distLbl = Instance.new("TextLabel")
	distLbl.BackgroundTransparency = 1
	distLbl.Position = UDim2.new(0, 0, 0.5, 0)
	distLbl.Size = UDim2.new(1, 0, 0.4, 0)
	distLbl.Font = Enum.Font.Gotham
	distLbl.TextScaled = true
	distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	distLbl.TextStrokeTransparency = 0.4
	distLbl.Text = "0m"
	distLbl.Parent = bb

	ESP.objects[player] = {hl = hl, bb = bb, name = nameLbl, dist = distLbl}
end

local function removeESP(player)
	local obj = ESP.objects[player]
	if obj then
		if obj.hl then obj.hl:Destroy() end
		if obj.bb then obj.bb:Destroy() end
		ESP.objects[player] = nil
	end
	if ESP.drawings[player] then
		if ESP.drawings[player].line then ESP.drawings[player].line:Remove() end
		ESP.drawings[player] = nil
	end
end

-- UPDATE ESP LOOP
table.insert(ESP.conns, RS.RenderStepped:Connect(function()
	local myChar = plr.Character
	local myTeam = plr.Team
	local camera = workspace.CurrentCamera
	
	if not ESP.playerEnabled and next(ESP.objects) then
		for p in pairs(ESP.objects) do removeESP(p) end
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player == plr then continue end
		
		local char = player.Character
		local isAlive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		
		local shouldShow = ESP.playerEnabled and isAlive and hrp
		if shouldShow and ESP.teamCheck and player.Team and myTeam and player.Team == myTeam then
			shouldShow = false
		end
		
		if shouldShow and (hrp.Position - camera.CFrame.Position).Magnitude <= ESP.maxDist and hrp.Position.Y < 1000 then
			if not ESP.objects[player] then createESP(player) end
			local obj = ESP.objects[player]
			
			local isEnemy = not (player.Team and myTeam and player.Team == myTeam)
			local finalColor = ESP.useCustomColor and ESP.customColor or (isEnemy and COL_ENEMY or COL_TEAM)
			
			obj.hl.FillColor = finalColor
			obj.name.TextColor3 = finalColor
			
			obj.name.Text = getRpName(player)
			obj.dist.Text = ("%d studs"):format(math.floor((hrp.Position - camera.CFrame.Position).Magnitude))
			obj.dist.Visible = ESP.showDistance

			if ESP.showTracers then
				if not ESP.drawings[player] then
					ESP.drawings[player] = { line = Drawing.new("Line") }
				end
				local line = ESP.drawings[player].line
				
				local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					line.Visible = true
					line.Color = ESP.tracerColor
					line.Thickness = 1.5
					line.Transparency = 1
					
					local startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
					if ESP.tracerStart == "Mouse" then
						startPos = UIS:GetMouseLocation()
					end
					
					line.From = startPos
					line.To = Vector2.new(screenPos.X, screenPos.Y)
				else
					line.Visible = false
				end
			else
				if ESP.drawings[player] and ESP.drawings[player].line then
					ESP.drawings[player].line:Remove()
					ESP.drawings[player] = nil
				end
			end
		else
			removeESP(player)
		end
	end
end))

-- CAMERA FOV LOOP (Only runs if FOV toggle is enabled)
table.insert(ESP.conns, RS.RenderStepped:Connect(function()
	if CameraMods.fovEnabled and workspace.CurrentCamera.FieldOfView ~= CameraMods.fov then
		workspace.CurrentCamera.FieldOfView = CameraMods.fov
	end
end))

-- MOUSE UNLOCK LOGIC
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if CameraMods.unlockEnabled and input.KeyCode == CameraMods.mouseKey then
		CameraMods.mouseUnlocked = not CameraMods.mouseUnlocked
		if CameraMods.mouseUnlocked then
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		else
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end
end)

-- Hook Players
local function hookPlayer(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.5)
		if ESP.objects[p] then removeESP(p) end
	end)
	p.CharacterRemoving:Connect(function()
		removeESP(p)
	end)
end
for _, p in pairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

-------------------- VISUALS TAB BUTTONS --------------------
addSection("Visuals", "Player ESP", "Left")
addSection("Visuals", "Tracers", "Right")
addSection("Visuals", "Camera", "Left")

-- LEFT: Player ESP
addButton("Visuals", "Enable Player ESP", "Shows boxes and names for players", "Toggle", function(on)
	ESP.playerEnabled = on
end, {default = false, section = "Player ESP"})

addButton("Visuals", "Team Check", "Don't draw teammates", "Toggle", function(on)
	ESP.teamCheck = on
end, {default = true, section = "Player ESP"})

addButton("Visuals", "Show Distance", "Display distance in studs", "Toggle", function(on)
	ESP.showDistance = on
end, {default = true, section = "Player ESP"})

addButton("Visuals", "Custom Color", "Use a specific color instead of team colors", "Toggle", function(on)
	ESP.useCustomColor = on
end, {default = false, section = "Player ESP"})

addButton("Visuals", "Pick Custom Color", "The color of the ESP", "Color", function(c)
	ESP.customColor = c
end, {default = ESP.customColor, section = "Player ESP"})

addButton("Visuals", "Max Distance", "Only show ESP for players within this range", "Slider", function(val)
	ESP.maxDist = val
end, {min = 100, max = 2000, default = 500, suffix = " studs", section = "Player ESP"})


-- RIGHT: Tracers
addButton("Visuals", "Enable Tracers", "Draws 2D lines from you to the enemy", "Toggle", function(on)
	ESP.showTracers = on
end, {default = false, section = "Tracers"})

addButton("Visuals", "Tracer Origin", "Where the line starts", "Dropdown", function(val)
	ESP.tracerStart = val
end, {options = {"Bottom", "Mouse"}, default = "Bottom", section = "Tracers"})

addButton("Visuals", "Tracer Color", "Color of the tracer lines", "Color", function(c)
	ESP.tracerColor = c
end, {default = ESP.tracerColor, section = "Tracers"})

-- LEFT: Camera
addButton("Visuals", "Enable Camera FOV", "Applies your custom FOV", "Toggle", function(on)
	CameraMods.fovEnabled = on
	if not on then
		-- Revert to default if turned off
		workspace.CurrentCamera.FieldOfView = 70
	end
end, {default = false, section = "Camera"})

addButton("Visuals", "Camera FOV", "Change your Field of View (Zoom out)", "Slider", function(val)
	CameraMods.fov = val
end, {min = 50, max = 120, default = 70, section = "Camera"})

addButton("Visuals", "Unlock Mouse", "Allows you to use your cursor in first person", "Toggle", function(on)
	CameraMods.unlockEnabled = on
	if not on and CameraMods.mouseUnlocked then
		CameraMods.mouseUnlocked = false
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end, {default = true, section = "Camera"})

addButton("Visuals", "Mouse Unlock Key", "Press this key to lock/unlock your mouse", "Keybind", function(key)
	if type(key) == "EnumItem" then
		CameraMods.mouseKey = key
	end
end, {default = Enum.KeyCode.X, section = "Camera"})

-------------------- PLAYER --------------------
local PlayerMods = {
	walkEnabled = false,
	walkSpeed = 16,
	
	jumpEnabled = false,
	jumpPower = 50,
	
	infJumpEnabled = false,
	teleportKey = Enum.KeyCode.P,
}

local TeleportMods = {
	selectedPlayer = nil,
}

-- 1. WalkSpeed Loop
table.insert(ESP.conns, RS.RenderStepped:Connect(function()
	if not PlayerMods.walkEnabled then return end
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = PlayerMods.walkSpeed
	end
end))

-- 2. JumpPower Loop
table.insert(ESP.conns, RS.RenderStepped:Connect(function()
	if not PlayerMods.jumpEnabled then return end
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = PlayerMods.jumpPower
	end
end))

-- 3. Infinite Jump (Press Space mid-air)
local lastJump = 0
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space and PlayerMods.infJumpEnabled then
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
			if tick() - lastJump > 0.15 then
				lastJump = tick()
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- 4. Teleport Keybind Listener
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == PlayerMods.teleportKey then
		local targetPlayer = TeleportMods.selectedPlayer
		if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then return end
		
		local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetHum = targetPlayer.Character:FindFirstChild("Humanoid")
		local myHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		
		if targetHRP and targetHum and myHRP then
			-- Get Spectator Box Position
			local specBox = workspace:FindFirstChild("SpectatorBox")
			local specSpawn = specBox and specBox:FindFirstChild("SpawnLocation")
			local specPos = specSpawn and specSpawn.Position
			
			-- 1. Check if they are dead
			local state = targetHum:GetState()
			if targetHum.Health <= 0 or state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Physics then
				notify("Teleport Error", targetPlayer.Name .. " is dead.")
				return
			end
			
			-- 2. Check if they are in the Spectator Box
			if specPos and (targetHRP.Position - specPos).Magnitude < 50 then
				notify("Teleport Error", targetPlayer.Name .. " is in the spectator box.")
				return
			end
			
			-- 3. All clear, teleport!
			myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
			notify("Teleported", "Moved to " .. targetPlayer.Name)
		end
	end
end)

-------------------- PLAYER TAB BUTTONS --------------------
addSection("Player", "Movement", "Left")
addSection("Player", "Teleport", "Right")

-- Movement (Left Side)
addButton("Player", "Enable WalkSpeed", "Overrides your speed with a custom value", "Toggle", function(on)
	PlayerMods.walkEnabled = on
	if not on then
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
end, {default = false, section = "Movement"})

addButton("Player", "WalkSpeed Amount", "Change how fast you walk", "Slider", function(val)
	PlayerMods.walkSpeed = val
end, {min = 16, max = 150, default = 16, section = "Movement"})

addButton("Player", "Enable Jump Power", "Forces the game to use your custom jump power", "Toggle", function(on)
	PlayerMods.jumpEnabled = on
	if not on then
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = 50 end
	end
end, {default = false, section = "Movement"})

addButton("Player", "Jump Power Amount", "Change how high you jump", "Slider", function(val)
	PlayerMods.jumpPower = val
end, {min = 50, max = 300, default = 50, section = "Movement"})

addButton("Player", "Infinite Jump", "Press Space in mid-air to jump again", "Toggle", function(on)
	PlayerMods.infJumpEnabled = on
end, {default = false, section = "Movement"})


-- Teleport (Right Side)
addButton("Player", "Select Player", "Choose a player to teleport to", "Dropbox", function(val)
	TeleportMods.selectedPlayer = val
end, {
	options = "players", 
	includeSelf = false,
	search = true,
	default = nil,
	section = "Teleport"
})

addButton("Player", "Teleport Keybind", "Press this key to teleport to the selected player", "Keybind", function(key)
	if type(key) == "EnumItem" then
		PlayerMods.teleportKey = key
	end
end, {default = Enum.KeyCode.P, section = "Teleport"})




-------------------- SETTINGS: DESTROY --------------------
addSection("Settings", "General", "Left")

addButton("Settings", "Unload / Destroy Script", "Removes the hub, disables everything it enabled, and cleans up", "Click", function()
	-- Safely disconnect all loops (ESP, WalkSpeed, etc.)
	pcall(function()
		if ESP and ESP.conns then 
			for _, c in ipairs(ESP.conns) do 
				pcall(function() c:Disconnect() end) 
			end 
		end
	end)
	
	-- Safely remove all ESP objects
	pcall(function()
		if ESP and ESP.objects and removeESP then 
			for p in pairs(ESP.objects) do 
				removeESP(p) 
			end 
		end
	end)
	
	-- Destroy FOV circles
	pcall(function() if silentGui then silentGui:Destroy() end end)
	pcall(function() if camGui then camGui:Destroy() end end)
	
	-- Restore FOV
	pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
	
	-- Destroy the UI
	local g = plr.PlayerGui:FindFirstChild("Darkhub")
	if g then g:Destroy() end
	
	print("[Darkhub] Unloaded successfully.")
end, {section = "General"})