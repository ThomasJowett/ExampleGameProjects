jumpSpeed = 8.0
forwardSpeed = 1.0

local rigidBody = {}
local transform = {}
local sprite = {}

local standing = false;

-- Called when entity is created
function OnCreate()
	rigidBody = CurrentEntity:GetRigidBody2DComponent()
	transform = CurrentEntity:GetTransformComponent()
	sprite = CurrentEntity:GetAnimatedSpriteComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)

	local velocity = rigidBody:GetLinearVelocity()

	if velocity.y == 0.0 and Input.IsKeyPressed(" ") then
		local xTransform = transform.Position.x
		local forward = 0.0
		if transform.Position.x < 0.0 then
			forward = forwardSpeed
		end
		rigidBody:SetLinearVelocity(Vec2.new(forward, jumpSpeed))
	end

	if velocity.x < 0 then
		if not standing then 
			sprite.Animation = "Idle"
			standing = true
		end
	else
		if standing then
			sprite.Animation = "Run"
			standing = false
		end
	end

end
-- Called on a fixed interval
function OnFixedUpdate()

	local offscreen = (CurrentScene:GetPrimaryCamera():GetCameraComponent().Camera:GetOrthoSize() * CurrentScene:GetPrimaryCamera():GetCameraComponent().Camera:GetAspectRatio()) / 2 * -1
	
	if CurrentEntity:GetTransformComponent().Position.x + (CurrentEntity:GetBoxCollider2DComponent().Size.x * CurrentEntity:GetTransformComponent().Scale.x) < offscreen then
		ChangeScene("Scenes/Main.scene")
	end

end
-- Called when entity is destroyed
function OnDestroy()

end
