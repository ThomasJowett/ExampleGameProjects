local camera = {}
local plane = {}
local size = 0
-- Called when entity is created
function OnCreate()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()
	plane = CurrentEntity:GetPrimitiveComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)
	if cameraSize ~= size then
		local cameraSizeX = camera.Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()
		local cameraSizeY = camera.Camera:GetOrthoSize()
		plane:SetPlane(cameraSizeX / 2, cameraSizeY/2, 4, 4, cameraSizeX /2, cameraSizeY/2)
		size = cameraSizeX
	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end
