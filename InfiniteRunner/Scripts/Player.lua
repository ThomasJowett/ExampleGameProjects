jumpSpeed = 6.0
forwardSpeed = 1.0

local rigidBody = {}
local transform = {}

-- Called when entity is created
function OnCreate()
	rigidBody = CurrentEntity:GetRigidBody2DComponent()
	transform = CurrentEntity:GetTransformComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)

	local yVelocity = rigidBody:GetLinearVelocity().y

	if yVelocity == 0.0 and Input.IsKeyPressed(" ") then
		local xTransform = transform.Position.x
		local forward = 0.0
		if transform.Position.x < 0.0 then
			forward = forwardSpeed
		end
		rigidBody:SetLinearVelocity(Vec2.new(forward, jumpSpeed))
	end

end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end

