local camera = nil
local parallaxLayers = {}

local scrollFactors = {0.0, 0.1, 0.2, 0.6, 1.0}
--local scrollFactors = {1.0, 0.6, 0.2, 0.1, 0.0}

function GetAllChildren(entity)
	local children = {}
	local child = CurrentEntity:GetChild()
	
	while child:IsSceneValid() do
		table.insert(children, child)
		child = child:GetSibling()
	end
	return children
end

-- Called when entity is created
function OnCreate()
	camera = CurrentScene:GetPrimaryCamera():GetTransformComponent()
	
	local children = GetAllChildren(CurrentEntity)
	for i, child in ipairs(children) do
		local transform = child:GetTransformComponent()
		table.insert(parallaxLayers,  {
			entity = child,
			originalX = transform.Position.x,
			originalY = transform.Position.y,
			scrollFactor = scrollFactors[i] or 1.0
		})
	end

	local backgrounds_transform = CurrentEntity:GetTransformComponent()
	backgrounds_transform.Position.x = camera.Position.x
	backgrounds_transform.Position.y = camera.Position.y
end

-- Called once per frame
function OnUpdate(deltaTime)
	
end
-- Called on a fixed interval
function OnFixedUpdate()
	local camX = camera.Position.x
	local camY = camera.Position.y

	local backgrounds_transform = CurrentEntity:GetTransformComponent()

	backgrounds_transform.Position.x = camX
	backgrounds_transform.Position.y = camY

	for _, layer in ipairs(parallaxLayers) do
		local offsetX = camX * (layer.scrollFactor) * 0.01
	
		local material = layer.entity:GetPrimitiveComponent().Material
		
		local texOffset = Vec2.new(layer.originalX + offsetX, 0)
		material:SetTextureOffset(texOffset)
	end
end
-- Called when entity is destroyed
function OnDestroy()

end
