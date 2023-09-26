local timeElapsed = 0.0

local scoreText = {}
local bestScore = 0.0

local full_screen = false

local filename = App.GetDocumentDirectory() .. "/score.txt"

function FormatTime(t)
	local minutes = math.floor(t / 60)
	local seconds = t - minutes * 60
	return string.format("%02i", minutes) .. ":" .. string.format("%02.0f", seconds)
end

-- Called when entity is created
function OnCreate()
	Input.DisableCursor()
	scoreText = CurrentEntity:GetTextComponent()

	local file = io.open(filename, "r")

	if file then

		local contents = file:read("*a")

		bestScore = tonumber(contents)
		Log.Debug("Best Score: " .. tostring(bestScore))
	end
end

-- Called once per frame
function OnUpdate(deltaTime)

	timeElapsed = timeElapsed + deltaTime

	local t = FormatTime(timeElapsed)
	local b = FormatTime(bestScore)

	scoreText.Text = "TIME: " .. t .. "\nBEST: " .. b

	if Input.IsKeyPressed('F') then
		Log.Debug("Pressed")
		full_screen = not full_screen
		if full_screen then
			App.SetWindowMode(WindowMode.Full_Screen)
		else
			App.SetWindowMode(WindowMode.Windowed)
		end
	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()
	if timeElapsed > bestScore then
		local file = io.open(filename, "w")
		
		if file then
			file:write(tostring(timeElapsed))
			file:close()
		else
			Log.Error("Failed to open file for writing")
		end
	end

end



