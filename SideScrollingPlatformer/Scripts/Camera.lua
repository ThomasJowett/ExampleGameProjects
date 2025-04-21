lookAheadDistance = 20.0

local player = nil
local transform = nil
local camera = nil

local smoothing = 0.1
local worldMinX = 0.0
local worldMaxX = 100.0
local worldMinY = -30.0
local worldMaxY = 100.0

local halfScreenWidth = 10
local halfScreenHeight = 10

function Lerp(a, b, t)
	return a + (b - a) * t
end

-- Called when entity is created
function OnCreate()
	local playerEntity = CurrentScene:FindEntity("Player")
	player = playerEntity:GetTransformComponent()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()

	transform = CurrentEntity:GetTransformComponent()
	transform.Position = player.Position
end

-- Called once per frame
function OnUpdate(deltaTime)
	
end
-- Called on a fixed interval
function OnFixedUpdate()
	halfScreenWidth = (camera.Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()) / 2.0
	halfScreenHeight = camera.Camera:GetOrthoSize() / 2.0
	
		
	local targetX = player.Position.x
	local targetY = player.Position.y

	transform.Position.x = Lerp(transform.Position.x, targetX, smoothing)
	transform.Position.y = Lerp(transform.Position.y, targetY, smoothing)

	transform.Position.x = math.max(worldMinX + halfScreenWidth, math.min(worldMaxX - halfScreenWidth, transform.Position.x))
	transform.Position.y = math.max(worldMinY + halfScreenHeight, math.min(worldMaxY - halfScreenHeight, transform.Position.y))
end
-- Called when entity is destroyed
function OnDestroy()

end
