local timeElapsed = 0.0

local scoreText = {}

function FormatTime(t)
	local minutes = math.floor(t / 60)
	local seconds = t - minutes * 60
	return string.format("%02i", minutes) .. ":" .. string.format("%02.0f", seconds)
end

-- Called when entity is created
function OnCreate()
	scoreText = CurrentEntity:GetTextComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)

	timeElapsed = timeElapsed + deltaTime

	local t = FormatTime(timeElapsed)

	scoreText.Text = "TIME: " .. t
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end


