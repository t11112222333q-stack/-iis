--[[
	User Interface Library
	Made by Late (Fixed SetTheme Dynamic Colors & Mobile Toggle Edition)
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.RightControl,
	Transparency = 0,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// (Dark Theme Default)
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),

	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240, 240, 240),
	Description = Color3.fromRGB(160, 160, 160),

	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),
	Icon = Color3.fromRGB(220, 220, 220),
}

local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {}, Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	if not Object then return end
	local Style, Direction
	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	if not Object then return end
	for Index, Property in next, Properties do
		pcall(function() Object[Index] = Property end)
	end
	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}
	return UDim2.new(unpack(New))
end

local Color = function(ColorVal, Factor, Mode)
	Mode = Mode or Setup.ThemeMode
	if Mode == "Light" then
		return Color3.fromRGB((ColorVal.R * 255) - Factor, (ColorVal.G * 255) - Factor, (ColorVal.B * 255) - Factor)
	else
		return Color3.fromRGB((ColorVal.R * 255) + Factor, (ColorVal.G * 255) + Factor, (ColorVal.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging = false
		local DragInput, Start, StartPosition

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Canvas.InputBegan:Connect(function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				local connection
				connection = Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						connection:Disconnect()
					end
				end)
			end
		end)

		Canvas.InputChanged:Connect(function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				DragInput = Input
			end
		end)

		Services.Input.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

local Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, 1)};
}

local Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Types.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Types.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize") and Tab.Resize:FindFirstChild(Type.Name) == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				Tab.Position = UDim2.new(
					UIPos.X.Scale, UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale, UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
			end
		end

		Player.Mouse.Move:Connect(function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
local Screen
if (identifyexecutor) then
	pcall(function()
		Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
		Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
	end)
else
	Screen = (script.Parent);
	Blur = require(script.Blur)
end

if not Screen then return warn("[UI LIB]: Failed to load Screen Asset!") end
Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = Screen:FindFirstChild("Components");
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	if not Window then return end
	local Original = (UseCurrentSize and Window.Size) or Setup.Size or UDim2.fromOffset(580, 440)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	if Shadow then SetProperty(Shadow, { Transparency = 0.5 }) end
	SetProperty(Window, {
		Size = Original,
		GroupTransparency = Transparency or 0,
		Visible = true,
	})
end

function Animations:Close(Window: CanvasGroup)
	if not Window then return end
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	if Shadow then Tween(Shadow, .15, { Transparency = 1 }) end
	Tween(Window, .15, { GroupTransparency = 1 })

	task.wait(.15)
	Window.Visible = false
end

function Animations:Component(Component: any, Custom: boolean)	
	if not Component then return end
	Component.InputBegan:Connect(function() 
		if Custom then
			Tween(Component, .15, { Transparency = .85 });
		else
			Tween(Component, .15, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Component.InputEnded:Connect(function() 
		if Custom then
			Tween(Component, .15, { Transparency = 1 });
		else
			Tween(Component, .15, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string })
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size or UDim2.fromOffset(580, 440)
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring and Blur then
		pcall(function()
			Blurs[Settings.Title] = Blur.new(Window, 5)
			BlurEnabled = true
		end)
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	local Close = function()
		if Opened then
			if BlurEnabled and Blurs[Settings.Title] and Blurs[Settings.Title].root then
				Blurs[Settings.Title].root.Parent = nil
			end
			Opened = false
			Animations:Close(Window)
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true
			if BlurEnabled and Blurs[Settings.Title] and Blurs[Settings.Title].root then
				Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
			end
		end
	end

	function Options:Toggle()
		Close()
	end

	function Options:SetVisible(Visible: boolean)
		if Visible ~= Opened then
			Close()
		end
	end

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)

			Button.MouseButton1Click:Connect(function() 
				if Name == "Close" or Name == "Minimize" then
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local OpenedVal, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not OpenedVal.Value then
					if Padding then Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) }); end
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(OpenedVal, { Value = true });
				elseif not SameName and OpenedVal.Value then
					if Padding then Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) }); end
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(OpenedVal, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local OpenedVal, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not OpenedVal.Value then
					OpenedVal.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 });
					if Scroll and Scroll:FindFirstChild("UIPadding") then
						Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });
					end
				elseif not SameName and OpenedVal.Value then
					OpenedVal.Value = false
					Tween(Main, .15, { GroupTransparency = 1 });
					if Scroll and Scroll:FindFirstChild("UIPadding") then
						Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	
					end
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		if not Example then return end
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			return error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local TabBtn = Clone(Example);

		if not Settings.Icon and TabBtn:FindFirstChild("ICO") then
			Destroy(TabBtn["ICO"]);
		elseif TabBtn:FindFirstChild("ICO") then
			SetProperty(TabBtn["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { TabBtn }
		if TabBtn:FindFirstChild("TextLabel") then
			SetProperty(TabBtn["TextLabel"], { Text = Settings.Title });
		end

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});

		SetProperty(TabBtn, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		TabBtn.MouseButton1Click:Connect(function()
			Options:SetTab(TabBtn.Name);
		end)

		return Main.ScrollingFrame
	end
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, { Parent = Screen["Frame"] })
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			Animations:Open(Notification, Setup.Transparency, true); 
			if Timer then Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) }); end
			task.wait(Duration);
			Animations:Close(Notification);
			task.wait(0.3);
			Notification:Destroy();
		end)
	end

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		if Labels then
			return Labels:FindFirstChild("Title"), Labels:FindFirstChild("Description")
		end
		return Component, Component
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		Button.MouseButton1Click:Connect(Settings.Callback or function() end)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input:FindFirstChild("Main") and Input.Main:FindFirstChild("Input");

		Input.MouseButton1Click:Connect(function() 
			if TextBox then TextBox:CaptureFocus() end
		end)

		if TextBox then
			TextBox.FocusLost:Connect(function() 
				if Settings.Callback then Settings.Callback(TextBox.Text) end
			end)
		end

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			On.Value = Value
		end 

		Toggle.MouseButton1Click:Connect(function()
			local Value = not On.Value
			Set(Value)
			if Settings.Callback then Settings.Callback(Value) end
		end)

		Animations:Component(Toggle);
		Set(Settings.Default or false);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown:FindFirstChild("Main") and Dropdown.Main:FindFirstChild("Options");

		Dropdown.MouseButton1Click:Connect(function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example:FindFirstChild("Top") and Example.Top:FindFirstChild("Buttons");

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			local function CloseDropdown()
				Tween(BG, .25, { BackgroundTransparency = 1 });
				Animations:Close(Example);
				task.wait(0.3)
				Example:Destroy();
			end

			if Buttons then
				for Index, Button in next, Buttons:GetChildren() do
					if Button:IsA("TextButton") then
						Animations:Component(Button, true)
						Button.MouseButton1Click:Connect(CloseDropdown)
					end
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local BtnTitle, BtnDesc = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(BtnTitle, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				if BtnDesc then Destroy(BtnDesc) end

				Button.MouseButton1Click:Connect(function() 
					local NewValue = not Selected.Value 
					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						if Settings.Callback then Settings.Callback(Option) end
						if Text then Text.Text = Index end
					end
					Selected.Value = NewValue
					CloseDropdown()
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main:FindFirstChild("Main") and Main.Main:FindFirstChild("Input");
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = math.clamp(Scale, 0, 1)
			
			if Number then
				Number = math.clamp(Number, 0, Settings.MaxValue)
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			if Amount then Amount.Text = tostring(Value) end
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			if Settings.Callback then Settings.Callback(Value) end
		end

		if Amount then
			Amount.FocusLost:Connect(function() 
				Update(tonumber(Amount.Text) or 0)
			end)
		end

		Fire.MouseButton1Down:Connect(function()
			Active = true
			while Active do
				Update()
				task.wait()
			end
		end)

		Services.Input.InputEnded:Connect(function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(0, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})

		return {
			SetDescription = function(self, newText)
				if Description then Description.Text = tostring(newText) end
			end,
			SetTitle = function(self, newText)
				if Title then Title.Text = tostring(newText) end
			end
		}
	end

	-- HÀM ĐỔI THEME DYNAMIC MỚI TỰ ĐỘNG QUÉT VÀ ÉP ĐỔI MÀU REALTIME
	function Options:SetTheme(Info)
		Theme = Info or Theme

		pcall(function()
			Window.BackgroundColor3 = Theme.Primary
			if Sidebar then Sidebar.BackgroundColor3 = Theme.Primary end
			if Holder then Holder.BackgroundColor3 = Theme.Secondary end
			
			local stroke = Window:FindFirstChildOfClass("UIStroke")
			if stroke then stroke.Color = Theme.Shadow end

			-- Quét sạch mọi nút/khung/nhãn chữ được khởi tạo động
			for _, v in pairs(Screen:GetDescendants()) do
				pcall(function()
					if v:IsA("TextLabel") then
						if v.Name == "Title" or v.Name == "Section" or v.Name == "TextLabel" then
							v.TextColor3 = Theme.Title
						elseif v.Name == "Description" then
							v.TextColor3 = Theme.Description
						end
					elseif v:IsA("Frame") or v:IsA("TextButton") or v:IsA("CanvasGroup") then
						if v.Name == "Main" or v.Name == "Button" or v.Name == "Toggle" or v.Name == "Slider" or v.Name == "Input" or v.Name == "Dropdown" then
							v.BackgroundColor3 = Theme.Component
						elseif v.Name == "Sidebar" then
							v.BackgroundColor3 = Theme.Primary
						end
					elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
						if v.Name ~= "ToggleButton" then
							v.ImageColor3 = Theme.Icon
						end
					elseif v:IsA("UIStroke") then
						v.Color = Theme.Outline
					end
				end)
			end
		end)
	end

	function Options:SetSetting(Setting, Value)
		if Setting == "Size" then
			Window.Size = Value
			Setup.Size = Value
		elseif Setting == "Transparency" then
			Window.GroupTransparency = Value
			Setup.Transparency = Value
		elseif Setting == "Theme" and typeof(Value) == "table" then
			Options:SetTheme(Value)
		elseif Setting == "Keybind" then
			Setup.Keybind = Value
		end
	end

	SetProperty(Window, { Size = Settings.Size or UDim2.fromOffset(580, 440), Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
