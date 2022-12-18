local rigidBody2DComp = {}
velocity = Vec2.new(-3, 0)
local camera = {}
local transform = {}

-- Called when entity is created
function OnCreate()
	rigidBody2DComp = CurrentEntity:GetRigidBody2DComponent()
	camera = CurrentScene:GetPrimaryCamera():GetCameraComponent()
	transform = CurrentEntity:GetTransformComponent()
end

-- Called on a fixed interval
function OnFixedUpdate()
	rigidBody2DComp:SetLinearVelocity(velocity)

	local offscreen = (CurrentScene:GetPrimaryCamera():GetCameraComponent().Camera:GetOrthoSize() * camera.Camera:GetAspectRatio()) / 2 * -1
	
	if CurrentEntity:GetTransformComponent().Position.x + (CurrentEntity:GetBoxCollider2DComponent().Size.x * CurrentEntity:GetTransformComponent().Scale.x) < offscreen then
		CurrentEntity:Destroy()
	end
end
