maxSpeed = 7

local spriteComp = {}
local rigidBodyComp = {}
local collider = {}
local physicsMaterial = {}
local transformComp = {}
local footCollider = {}

local isGrounded = false;
local numContacts = 0;
local jumpTimeout = 0;


-- Called when entity is created
function OnCreate()
	spriteComp = CurrentEntity:GetAnimatedSpriteComponent()
	rigidBodyComp = CurrentEntity:GetRigidBody2DComponent()
	collider = CurrentEntity:GetCapsuleCollider2DComponent()
	physicsMaterial = collider.PhysicsMaterial
	transformComp = CurrentEntity:GetTransformComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)
	
end
-- Called on a fixed interval
function OnFixedUpdate()
	local velocity = rigidBodyComp:GetLinearVelocity()
	local moveInput = InputAction.Move:GetValue()

	physicsMaterial:SetFriction(0.01)

	if isGrounded then 
		if moveInput == 0 then
			physicsMaterial:SetFriction(1.0)
			spriteComp.Animation = "Idle"
		else
			spriteComp.Animation = "Run"
		end
	elseif rigidBodyComp:GetLinearVelocity().y > 0.0 then
		spriteComp.Animation = "Jump Start"
	elseif rigidBodyComp:GetLinearVelocity().y < 0.0 then
		spriteComp.Animation = "Jump Loop"
	end


	rigidBodyComp:SetLinearVelocity(Vec2.new(moveInput * maxSpeed, velocity.y))

	local canJump = isGrounded and jumpTimeout == 0

	if InputAction.Jump:IsTriggered() and canJump then
		rigidBodyComp:ApplyImpulse(Vec2.new(0, 30.0))
		jumpTimeout = 15
		Signal.Emit("player_jump", CurrentEntity, {})
	end 
	
	local velocityX = rigidBodyComp:GetLinearVelocity().x
	if velocityX > 0.0001 or velocityX < -0.0001 then
		local scale = transformComp.Scale
		local newScaleX = velocityX > 0.0001 and math.abs(scale.x) or -math.abs(scale.x)
		transformComp.Scale = Vec3.new(newScaleX, scale.y, scale.z)
	end
	
	if jumpTimeout > 0 then
		jumpTimeout = jumpTimeout - 1
	end
end
-- Called when entity is destroyed
function OnDestroy()

end

function OnBeginContact(entity, normal, point)
	numContacts = numContacts + 1
	if(numContacts > 0) then
		if not isGrounded then
			Signal.Emit("player_land", CurrentEntity, {})
		end
		isGrounded = true
	end
end

function OnEndContact(entity, normal, point)
	numContacts = numContacts - 1
	if(numContacts == 0) then
		isGrounded = false
	end
end
