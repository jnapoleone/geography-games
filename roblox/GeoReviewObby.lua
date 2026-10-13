--[[
  GEO REVIEW OBBY: CGC1D Unit 2 (Landform Regions of Canada + Climate)

  HOW TO USE
  1. Open Roblox Studio and start a new "Baseplate" place.
  2. In the Explorer, right-click ServerScriptService > Insert Object > Script.
  3. Delete the line in the new script and paste this whole file in.
  4. Press Play to test. The course builds itself in the sky.
  5. File > Publish to Roblox to save it and share it with Sebastian.

  HOW IT PLAYS
  Each stage shows a question on a sign above three doors.
  Walk through the door with the right answer to reach the next stage.
  The wrong doors drop you into the magma, and you respawn at your
  last stage with the explanation on screen. Then try again.

  TO CHANGE QUESTIONS: edit the QUESTIONS list below. The first answer
  in each list is the correct one; the game shuffles the doors.
]]

local Players = game:GetService("Players")

local QUESTIONS = {
	{q = "Which landform region is the oldest in Canada?", a = {"Canadian Shield", "Cordillera", "Interior Plains"}, why = "The Canadian Shield is 2.5 to 4.28 billion years old, one of the oldest regions on Earth."},
	{q = "Where do most Canadians live?", a = {"Great Lakes–St. Lawrence Lowlands", "Interior Plains", "Canadian Shield"}, why = "The Great Lakes–St. Lawrence Lowlands hold most of Canada's people and most of its farmland."},
	{q = "Which region has the youngest mountains in Canada?", a = {"Cordillera", "Appalachian Uplands", "Arctic Lands"}, why = "The Cordillera is youngest. The Innuitian Mountains in the Arctic are second-youngest."},
	{q = "Potash, coal, oil and lots of farming describe which region?", a = {"Interior Plains", "Hudson Bay Lowland", "Appalachian Uplands"}, why = "Sediment on the Interior Plains holds potash, coal and oil, and the flat land is great for farming."},
	{q = "Nickel, uranium, gold, copper and zinc are mined mostly in the:", a = {"Canadian Shield", "Interior Plains", "Great Lakes–St. Lawrence Lowlands"}, why = "The Canadian Shield is Canada's mineral storehouse."},
	{q = "A swampy plain sitting in a dip on the Canadian Shield is the:", a = {"Hudson Bay Lowland", "Interior Plains", "Arctic Lowlands"}, why = "The Hudson Bay Lowland formed as glaciers retreated and left sediment behind."},
	{q = "Gros Morne National Park, with its fjord-like inlets, is in the:", a = {"Appalachian Uplands", "Cordillera", "Arctic Lands"}, why = "The Appalachian Uplands cover southern Quebec, the Maritimes and the island of Newfoundland."},
	{q = "The Niagara Escarpment and the Bruce Trail are in the:", a = {"Great Lakes–St. Lawrence Lowlands", "Appalachian Uplands", "Canadian Shield"}, why = "The Niagara Escarpment is a long ridge across southern Ontario."},
	{q = "What is a pingo?", a = {"A small hill with a core of ice", "A mountain peak sticking through ice", "A pond on the Prairies"}, why = "Pingos are found in the Mackenzie Delta on the Arctic Coastal Plain."},
	{q = "The Thule culture, whose houses are on Igloolik Island, were the ancestors of:", a = {"Today's Inuit", "The Haudenosaunee", "Early French settlers"}, why = "The Thule are the direct ancestors of all modern Inuit and Yupik people."},
	{q = "Why does so much of the Canadian Shield look bare and rocky?", a = {"Glaciers scraped the soil off the rock", "Volcanoes covered it in ash", "It used to be a desert"}, why = "Heavy glaciation and erosion scoured the soil off, leaving bare rock and many lakes."},
	{q = "In LOWERN, what does the L stand for?", a = {"Latitude", "Lakes", "Longitude"}, why = "Places closer to the Equator are warmer because sunlight is more concentrated there."},
	{q = "In LOWERN, what does the R stand for?", a = {"Relief", "Rainfall", "Rivers"}, why = "Moist air rises up a mountain, cools and drops rain; the far side stays dry."},
	{q = "In LOWERN, what does the N stand for?", a = {"Near water", "North", "Night"}, why = "Places near large bodies of water have milder, maritime climates."},
	{q = "Canada's prevailing winds (the westerlies) blow:", a = {"West to east", "East to west", "North to south"}, why = "That's why weather systems reach Toronto from the west."},
	{q = "As elevation increases, temperature:", a = {"Drops", "Rises", "Stays the same"}, why = "Rising air expands and cools, so higher places are colder."},
	{q = "The dry side of a mountain, away from the wind, is called the:", a = {"Rain shadow (leeward side)", "Windward side", "Jet stream"}, why = "Moist air drops its rain on the windward side, leaving the leeward side dry."},
	{q = "The warmest month is 22°C and the coldest is −4°C. What is the temperature range?", a = {"26°C", "18°C", "22°C"}, why = "22 − (−4) = 22 + 4 = 26°C."},
	{q = "A place has a 14°C range and 1245 mm of precipitation. Its climate is:", a = {"Maritime", "Continental", "Modified continental"}, why = "Range under 25°C and precipitation over 1000 mm = maritime."},
	{q = "Which months count toward the growing season?", a = {"Months at 6°C or warmer", "Months at 0°C or warmer", "Months with over 50 mm of rain"}, why = "Plants grow at 6°C or warmer. Count the DAYS in those months."},
	{q = "On a climate graph, temperature is shown as a:", a = {"Red line", "Blue bars", "Green bars"}, why = "Temperature = red line graph. Precipitation = blue bars."},
	{q = "A growing season from April to October is how long?", a = {"214 days", "7 days", "180 days"}, why = "30 + 31 + 30 + 31 + 31 + 30 + 31 = 214 days."},
}

local N = #QUESTIONS
local BASE_Y = 100
local STAGE_LEN = 60
local LANE_X = {-12, 0, 12}
local DOOR_COLORS = {
	Color3.fromRGB(217, 88, 26),
	Color3.fromRGB(28, 128, 120),
	Color3.fromRGB(110, 76, 160),
}
local rng = Random.new()

local course = workspace:FindFirstChild("GeoObby")
if course then course:Destroy() end
course = Instance.new("Folder")
course.Name = "GeoObby"
course.Parent = workspace

local function makePart(name, size, pos, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color or Color3.fromRGB(120, 130, 125)
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = course
	return p
end

-- Text on the side of a part that faces a player walking toward +Z
local function addText(p, text, textColor)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	sg.PixelsPerStud = 40
	sg.LightInfluence = 0
	sg.Parent = p
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor or Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = sg
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 20)
	pad.PaddingRight = UDim.new(0, 20)
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = label
	return label
end

local function shuffled(list)
	local out = {}
	for i = 1, #list do out[i] = list[i] end
	for i = #out, 2, -1 do
		local j = rng:NextInteger(1, i)
		out[i], out[j] = out[j], out[i]
	end
	return out
end

-- Player state
local progress = {}   -- number of questions answered correctly
local ui = {}         -- on-screen labels
local finished = {}
local startTime = {}
local wrongCooldown = {}

local function spawnCFrame(p)
	local pos = Vector3.new(0, BASE_Y + 4, p * STAGE_LEN + 6)
	return CFrame.lookAt(pos, pos + Vector3.new(0, 0, 1))
end

local function setStatus(plr)
	local labels = ui[plr]
	if not labels then return end
	local p = progress[plr] or 0
	if p >= N then
		labels.status.Text = "All " .. N .. " questions done!"
	else
		labels.status.Text = "Stage " .. (p + 1) .. " of " .. N
	end
end

local function say(plr, text)
	local labels = ui[plr]
	if labels then labels.msg.Text = text end
end

local function playerFromHit(hit)
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then return nil, nil end
	return Players:GetPlayerFromCharacter(model), model
end

local function onCorrect(i, q)
	return function(hit)
		local plr = playerFromHit(hit)
		if not plr or progress[plr] ~= i - 1 then return end
		progress[plr] = i
		local stat = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Stage")
		if stat then stat.Value = i end
		setStatus(plr)
		say(plr, "Correct! " .. q.why)
	end
end

local function onWrong(i, q)
	return function(hit)
		local plr = playerFromHit(hit)
		if not plr or progress[plr] ~= i - 1 then return end
		local now = os.clock()
		if wrongCooldown[plr] and now - wrongCooldown[plr] < 2 then return end
		wrongCooldown[plr] = now
		say(plr, "Not quite! The answer is: " .. q.a[1] .. ". " .. q.why)
	end
end

-- Build one stage per question
for i, q in ipairs(QUESTIONS) do
	local z0 = (i - 1) * STAGE_LEN

	local floor = makePart("Stage" .. i, Vector3.new(40, 1, 26), Vector3.new(0, BASE_Y, z0 + 13),
		Color3.fromRGB(96, 112, 104), Enum.Material.Slate)

	local sign = makePart("Question" .. i, Vector3.new(36, 9, 1), Vector3.new(0, BASE_Y + 18, z0 + 26),
		Color3.fromRGB(16, 49, 44))
	addText(sign, "Q" .. i .. " of " .. N .. ": " .. q.q)

	-- Walls that keep each answer lane separate
	for _, wx in ipairs({-18, -6, 6, 18}) do
		local wall = makePart("Wall", Vector3.new(1, 20, 34), Vector3.new(wx, BASE_Y + 10.5, z0 + 43),
			Color3.fromRGB(70, 82, 78), Enum.Material.Rock)
		wall.Transparency = 0.3
	end

	local answers = shuffled(q.a)
	for lane, answer in ipairs(answers) do
		local x = LANE_X[lane]
		local door = makePart("Door", Vector3.new(10, 12, 1), Vector3.new(x, BASE_Y + 6.5, z0 + 26),
			DOOR_COLORS[lane], Enum.Material.SmoothPlastic)
		door.CanCollide = false
		door.Transparency = 0.15
		addText(door, answer)

		local trigger = makePart("Trigger", Vector3.new(10, 8, 2), Vector3.new(x, BASE_Y + 4.5, z0 + 28.5))
		trigger.Transparency = 1
		trigger.CanCollide = false

		if answer == q.a[1] then
			makePart("Bridge", Vector3.new(10, 1, 34), Vector3.new(x, BASE_Y, z0 + 43),
				Color3.fromRGB(120, 160, 110), Enum.Material.Grass)
			trigger.Touched:Connect(onCorrect(i, q))
		else
			trigger.Touched:Connect(onWrong(i, q))
		end
	end
end

-- Finish platform
do
	local z0 = N * STAGE_LEN
	makePart("Finish", Vector3.new(40, 1, 30), Vector3.new(0, BASE_Y, z0 + 15),
		Color3.fromRGB(240, 240, 240), Enum.Material.Glacier)
	local sign = makePart("FinishSign", Vector3.new(36, 9, 1), Vector3.new(0, BASE_Y + 8, z0 + 29),
		Color3.fromRGB(217, 88, 26))
	addText(sign, "SUMMIT REACHED! You finished the Unit 2 review.")
	local trigger = makePart("FinishTrigger", Vector3.new(40, 6, 20), Vector3.new(0, BASE_Y + 3.5, z0 + 15))
	trigger.Transparency = 1
	trigger.CanCollide = false
	trigger.Touched:Connect(function(hit)
		local plr = playerFromHit(hit)
		if not plr or progress[plr] ~= N or finished[plr] then return end
		finished[plr] = true
		local secs = math.floor(os.clock() - (startTime[plr] or os.clock()))
		say(plr, string.format("You finished all %d questions in %d:%02d! Rejoin to race your time.", N, math.floor(secs / 60), secs % 60))
	end)
end

-- Magma under the whole course
do
	local length = (N + 1) * STAGE_LEN + 60
	local magma = makePart("Magma", Vector3.new(90, 1, length), Vector3.new(0, BASE_Y - 30, length / 2 - 30),
		Color3.fromRGB(255, 90, 20), Enum.Material.Neon)
	magma.Touched:Connect(function(hit)
		local _, model = playerFromHit(hit)
		local hum = model and model:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then hum.Health = 0 end
	end)
end

-- On-screen status box
local function makeGui(plr)
	local sg = Instance.new("ScreenGui")
	sg.Name = "GeoGui"
	sg.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.6, 0, 0, 120)
	frame.Position = UDim2.new(0.2, 0, 0, 12)
	frame.BackgroundColor3 = Color3.fromRGB(16, 49, 44)
	frame.BackgroundTransparency = 0.15
	frame.Parent = sg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -24, 0, 30)
	status.Position = UDim2.new(0, 12, 0, 8)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamBlack
	status.TextSize = 24
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextColor3 = Color3.fromRGB(255, 160, 100)
	status.Parent = frame

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -24, 0, 74)
	msg.Position = UDim2.new(0, 12, 0, 40)
	msg.BackgroundTransparency = 1
	msg.Font = Enum.Font.Gotham
	msg.TextScaled = true
	msg.TextWrapped = true
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextYAlignment = Enum.TextYAlignment.Top
	msg.TextColor3 = Color3.new(1, 1, 1)
	msg.Parent = frame
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 22
	limit.Parent = msg

	sg.Parent = plr:WaitForChild("PlayerGui")
	ui[plr] = { status = status, msg = msg }
end

local function onCharacter(plr, char)
	local root = char:WaitForChild("HumanoidRootPart", 10)
	if not root then return end
	task.wait(0.1)
	char:PivotTo(spawnCFrame(progress[plr] or 0))
end

local function onPlayer(plr)
	progress[plr] = 0
	startTime[plr] = os.clock()

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 0
	stage.Parent = stats
	stats.Parent = plr

	makeGui(plr)
	setStatus(plr)
	say(plr, "Read the question on the sign, then walk through the door with the right answer.")

	plr.CharacterAdded:Connect(function(char) onCharacter(plr, char) end)
	if plr.Character then task.spawn(onCharacter, plr, plr.Character) end
end

Players.RespawnTime = 1.5
Players.PlayerAdded:Connect(onPlayer)
for _, plr in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, plr) end
Players.PlayerRemoving:Connect(function(plr)
	progress[plr] = nil
	ui[plr] = nil
	finished[plr] = nil
	startTime[plr] = nil
	wrongCooldown[plr] = nil
end)
