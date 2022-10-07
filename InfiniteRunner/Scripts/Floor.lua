speed = 1
local camera = {}
local plane = {}
local collider = {}
local size = 0
-- Called when entity is created
function OnCreate()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()
	plane = CurrentEntity:GetPrimitiveComponent()
	collider = CurrentEntity:GetBoxCollider2DComponent()
	collider.Size.x = camera.Camera:GetOrthoSize() / 2;
	transform = CurrentEntity:GetTransformComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)
	local cameraSize = camera.Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()
	if cameraSize ~= size then
		plane:SetPlane(cameraSize / 2, 1, 4, 4, cameraSize / 2, 1)
		size = cameraSize
	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end

