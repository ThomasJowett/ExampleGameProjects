local timer = 0.0
local spawnLocation = nil

local obstacles = {}

-- Called when entity is created
function OnCreate()
	local transform = CurrentEntity:GetTransformComponent()
	spawnLocation = transform.Position;
	Log.Debug(tostring(spawnLocation))

	obstacles[0] = LoadScene("Scenes/Obstacle.scene")
	obstacles[1] = LoadScene("Scenes/Chair.scene")
end

-- Called once per frame
function OnUpdate(deltaTime)
	timer = timer + deltaTime;
	if timer > math.random(1.0, 2.0) then
		local index = math.random(0, 1)
		CurrentScene:InstantiateScene(obstacles[index], spawnLocation)
		timer = 0.0
	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
