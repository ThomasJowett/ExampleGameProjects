local camera = {}
local plane = {}
local size = 0
local material = nil
local texOffset = Vec2.new(0,0)
speed = Vec2.new(1,0)

-- Called when entity is created
function OnCreate()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()
	plane = CurrentEntity:GetPrimitiveComponent()
	material = plane.Material
end

-- Called once per frame
function OnUpdate(deltaTime)
	if cameraSize ~= size then
		local cameraSizeX = camera.Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()
		local cameraSizeY = camera.Camera:GetOrthoSize()
		plane:SetPlane(cameraSizeX, cameraSizeY, 4, 4, cameraSizeX, cameraSizeY)
		size = cameraSizeX
	end

	texOffset = texOffset + speed * deltaTime;
	material:SetTextureOffset(texOffset)
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end