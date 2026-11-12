-- Darkhub UI Library
-- Load with:  local UI = loadstring(game:HttpGet("<raw github url>/Library.lua"))()
-- Optional before loading:  getgenv().DarkhubGame = "Arsenal"   (sidebar subtitle)
local Players, TS, UIS, RS, HS = game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("HttpService")
local plr = Players.LocalPlayer
local old = plr:WaitForChild("PlayerGui"):FindFirstChild("Darkhub")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "Darkhub", false, true, 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr.PlayerGui

local GAME_NAME = "Arsenal"
pcall(function() if getgenv and getgenv().DarkhubGame then GAME_NAME = tostring(getgenv().DarkhubGame) end end)

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
local subtitle = text(GAME_NAME, 14, C.dim, W.Medium, {Parent=side, Position=UDim2.fromOffset(66,36), Size=UDim2.new(1,-76,0,14), TextScaled=true})
new("UITextSizeConstraint", {Parent=subtitle, MaxTextSize=11, MinTextSize=8})
function Lib.setSubtitle(s) subtitle.Text = tostring(s) end

local search = new("Frame", {Parent=side, Position=UDim2.fromOffset(12,70), Size=UDim2.new(1,-24,0,34), BackgroundColor3=C.card}, corner(8), stroke())
text("🔍", 11, C.dim, nil, {Parent=search, Position=UDim2.fromOffset(10,0), Size=UDim2.fromOffset(14,34)})
local searchBox = new("TextBox", {Parent=search, BackgroundTransparency=1, Position=UDim2.fromOffset(30,0), Size=UDim2.new(1,-62,1,0), Text="", PlaceholderText="Search",
	PlaceholderColor3=C.dim, TextColor3=C.text, TextSize=13, FontFace=Font.new(FAM), TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false})
local keyChip = new("Frame", {Parent=search, AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-6,.5,0), Size=UDim2.fromOffset(20,20), BackgroundColor3=C.elem}, corner(5))
text("/", 11, C.sub, W.Medium, {Parent=keyChip, Size=UDim2.fromScale(1,1), TextXAlignment=Enum.TextXAlignment.Center})
searchBox.Focused:Connect(function() tw(search.S, {Color=Lib.accent}, .2) end)
searchBox.FocusLost:Connect(function() tw(search.S, {Color=C.line}, .2) end)

do -- candy-cane divider (red/white stripes)
	local k = {}
	for i = 0, 9 do
		local c = i % 2 == 0 and Color3.fromRGB(225,45,65) or Color3.new(1,1,1)
		table.insert(k, ColorSequenceKeypoint.new(i == 0 and 0 or i/10 + .001, c))
		table.insert(k, ColorSequenceKeypoint.new((i+1)/10, c))
	end
	new("Frame", {Parent=side, Position=UDim2.fromOffset(12,116), Size=UDim2.new(1,-24,0,3), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0},
		new("UIGradient", {Color=ColorSequence.new(k)}), corner(2))
end
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

-- falling snow (plain frames, no images) + bigger spinning ❄ flakes + soft snow drifts
local snow = new("Frame", {Parent=content, Size=UDim2.new(1,-8,1,-8), BackgroundTransparency=1, ClipsDescendants=true})
for _, d in {{.12,.4},{.5,.35},{.85,.45}} do
	new("Frame", {Parent=snow, AnchorPoint=Vector2.new(.5,0), Position=UDim2.new(d[1],0,1,-14), Size=UDim2.new(d[2],0,0,40),
		BackgroundColor3=Color3.new(1,1,1), BackgroundTransparency=.93, BorderSizePixel=0}, corner(20))
end
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
task.spawn(function()
	while gui.Parent do
		if holder.Visible and snow.Visible then
			local s = math.random(9,16)
			local f = text("❄", s, Color3.fromRGB(220,235,255), nil, {Parent=snow, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(math.random(),0,0,-10),
				Size=UDim2.fromOffset(s,s), TextTransparency=math.random(40,70)/100, TextXAlignment=Enum.TextXAlignment.Center})
			local t = math.random(80,130)/10
			tw(f, {Position=UDim2.new(f.Position.X.Scale + math.random(-10,10)/100, 0, 1, 10), Rotation=math.random(-180,180), TextTransparency=.95}, t, Enum.EasingStyle.Linear)
			task.delay(t, f.Destroy, f)
		end
		task.wait(.7)
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
local xmasL, fpsL, pingL, plrL = pill(0), pill(1), pill(2), pill(3)
local function countdown() -- days until Christmas
	local d = os.date("*t")
	local target = os.time({year=d.year, month=12, day=25, hour=0})
	if os.time() > target + 86400 then target = os.time({year=d.year+1, month=12, day=25, hour=0}) end
	local n = math.ceil((target - os.time()) / 86400)
	return n <= 0 and "🎄 Merry Xmas!" or ("🎄 "..n.."d")
end
local frames = 0
RS.RenderStepped:Connect(function() frames += 1 end)
task.spawn(function()
	while gui.Parent do
		task.wait(.5)
		fpsL.Text = (frames * 2).." fps" frames = 0
		pingL.Text = math.floor(plr:GetNetworkPing() * 1000 + .5).." ms"
		plrL.Text = #Players:GetPlayers().."/"..Players.MaxPlayers
		xmasL.Text = countdown()
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
function Lib.setSnow(v) snow.Visible = v end

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

-- Themes: Lib.setTheme("Candy Cane")   |   Lib.themeNames = sorted list of every theme name
Lib.themes = {
	-- Christmas
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
	["Peppermint"]      = Color3.fromRGB(255,90,110),
	["Cranberry"]       = Color3.fromRGB(160,20,55),
	["Krampus"]         = Color3.fromRGB(130,15,25),
	["Frosted Pine"]    = Color3.fromRGB(70,140,110),
	["Spruce"]          = Color3.fromRGB(30,120,80),
	["Wreath"]          = Color3.fromRGB(60,150,70),
	["Elf"]             = Color3.fromRGB(110,200,60),
	["Ice Queen"]       = Color3.fromRGB(150,210,255),
	["Glacier"]         = Color3.fromRGB(110,200,230),
	["Icicle"]          = Color3.fromRGB(200,235,255),
	["Blizzard"]        = Color3.fromRGB(230,240,255),
	["Frozen Lake"]     = Color3.fromRGB(60,140,200),
	["Polar Night"]     = Color3.fromRGB(70,90,200),
	["Midnight Snow"]   = Color3.fromRGB(120,130,220),
	["Silver Bells"]    = Color3.fromRGB(190,195,210),
	["Ornament Gold"]   = Color3.fromRGB(240,180,40),
	["Starlight"]       = Color3.fromRGB(255,230,120),
	["Firelight"]       = Color3.fromRGB(255,130,40),
	["Yule Log"]        = Color3.fromRGB(150,85,45),
	["Cinnamon"]        = Color3.fromRGB(190,100,55),
	["Sleigh Ride"]     = Color3.fromRGB(235,55,55),
	["Snow Angel"]      = Color3.fromRGB(240,225,255),
	["Aurora Pink"]     = Color3.fromRGB(255,110,190),
	["Christmas Eve"]   = Color3.fromRGB(90,60,200),
	-- Classic
	["Crimson"]         = Color3.fromRGB(220,20,60),
	["Ocean"]           = Color3.fromRGB(0,140,220),
	["Violet"]          = Color3.fromRGB(140,80,255),
	["Mint"]            = Color3.fromRGB(80,230,160),
	["Sunset"]          = Color3.fromRGB(255,110,70),
	["Cyber"]           = Color3.fromRGB(0,255,200),
	["Rose"]            = Color3.fromRGB(255,80,140),
	["Lime"]            = Color3.fromRGB(170,255,60),
	["Amber"]           = Color3.fromRGB(255,170,0),
	["Grape"]           = Color3.fromRGB(120,50,200),
	["Bubblegum"]       = Color3.fromRGB(255,150,220),
	["Toxic"]           = Color3.fromRGB(120,255,0),
}
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
		Lib.notify("💾 Preset saved", name..(canSave and "  (auto-loads next time)" or "  (this session only)"), 3)
		return name
	end
	function Lib.loadPreset(name)
		name = clean(name)
		local data = readP(name)
		if not data then Lib.notify("Preset not found", name, 3) return false end
		Saves.pending = data
		for key, api in Saves.reg do applyOne(key, api) end
		setAuto(name)
		Lib.notify("🎄 Preset loaded", name, 3)
		return true
	end
	function Lib.deletePreset(name)
		name = clean(name)
		if canSave and fs.del then pcall(fs.del, path(name)) else Saves.mem[name] = nil end
		if Saves.auto == name then setAuto(nil) end
		Lib.notify("🗑️ Preset deleted", name, 3)
	end

	-- autoload the last saved/loaded preset
	local last = readFile(DIR.."/autoload.txt")
	if last and last ~= "" then
		local data = readP(last)
		if data then Saves.pending, Saves.auto = data, last task.delay(1.5, function() Lib.notify("🎄 Preset loaded", last, 3) end) end
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
	Saves.register(tab, name, api, kind, o) -- remember it for presets (and apply the autoloaded value)
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
                            nosave = true  (leave this control out of presets)

 addButton returns a control:  ctl.value  (current value)  |  ctl.Set(x)  (change it from code)
 Extras:  notify(title, message, seconds)  |  setTheme("Evergreen")  |  UI.setAccent(Color3)  |  UI.setShown(true/false)
          UI.setSnow(true/false)  |  UI.setSubtitle("Game Name")  |  UI.themeNames (sorted list of all themes)

 PRESETS (every Toggle/Slider/Input/Dropdown/Dropbox/Keybind/Color is saved by tab + name):
   savePreset("Legit")     saves everything now           loadPreset("Legit")   applies it
   deletePreset("Legit")   removes it                     listPresets()         list of saved names
   UI.currentPreset()      last saved/loaded name          UI.canSave            true if files work
   The last preset you SAVED or LOADED loads by itself next time the script runs.

 Themes (52): Christmas - Candy Cane, Holly Berry, Evergreen, Mistletoe, Snowfall, Frostbite, Golden Star,
   Gingerbread, Hot Cocoa, Reindeer, Sugar Plum, Northern Lights, Tinsel, Rudolph, Eggnog, Winter Night,
   Peppermint, Cranberry, Krampus, Frosted Pine, Spruce, Wreath, Elf, Ice Queen, Glacier, Icicle, Blizzard,
   Frozen Lake, Polar Night, Midnight Snow, Silver Bells, Ornament Gold, Starlight, Firelight, Yule Log,
   Cinnamon, Sleigh Ride, Snow Angel, Aurora Pink, Christmas Eve
   Classic - Crimson, Ocean, Violet, Mint, Sunset, Cyber, Rose, Lime, Amber, Grape, Bubblegum, Toxic
 Left Ctrl shows or hides the menu.  "/" jumps to the tab search.
================================================================= ]]
return Lib
