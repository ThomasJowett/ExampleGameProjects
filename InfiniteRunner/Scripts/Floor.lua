speed = 1
local camera = {}
local plane = {}
local collider = {}
local transform = {}
local size = 0
-- Called when entity is created
function OnCreate()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()
	plane = CurrentEntity:GetPrimitiveComponent()
	collider = CurrentEntity:GetBoxCollider2DComponent()
	collider.Size.x = camera.Camera:GetOrthoSize() / 4;
	transform = CurrentEntity:GetTransformComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)
	local cameraSize = camera.Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()
	if cameraSize ~= size then
		plane:SetPlane(cameraSize / 4, 1, 4, 4, cameraSize / 4, 1)
		collider.Size.x = cameraSize / 2;
		size = cameraSize
	end
	transform.Position.x = transform.Position.x - (speed * deltaTime)
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end
