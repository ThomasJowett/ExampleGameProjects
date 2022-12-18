local timer = 0.0
local interval = 1.0
local spawnLocation = nil

local obstacles = {}

-- Called when entity is created
function OnCreate()
	local transform = CurrentEntity:GetTransformComponent()
	spawnLocation = transform.Position;

	obstacles[0] = LoadScene("Scenes/Crate.scene")
	obstacles[1] = LoadScene("Scenes/Chair.scene")
	obstacles[2] = LoadScene("Scenes/Desk 1.scene")
	obstacles[3] = LoadScene("Scenes/Desk 2.scene")
	obstacles[4] = LoadScene("Scenes/Desk 3.scene")
end

-- Called once per frame
function OnUpdate(deltaTime)
	timer = timer + deltaTime;
	if timer > interval then
		local index = math.random(0, 4)
		CurrentScene:InstantiateScene(obstacles[index], spawnLocation)
		timer = 0.0
		interval = math.random(1.0, 2.0)
	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
