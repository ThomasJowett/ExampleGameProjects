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
	local moveInput = 0.0

	
	physicsMaterial:SetFriction(0.01)
	
	if Input.IsKeyPressed('A') then
		moveInput = -1.0
		
	end

	if (Input.IsKeyPressed('D')) then
		moveInput = moveInput + 1.0
	end

	if not isGrounded or moveInput == 0 then
		physicsMaterial:SetFriction(1.0)
		spriteComp.Animation = "Idle"
	else
		spriteComp.Animation = "Run"
	end


	rigidBodyComp:SetLinearVelocity(Vec2.new(moveInput * maxSpeed, velocity.y))

	if Input.IsKeyPressed(' ') and isGrounded and jumpTimeout == 0 then
		rigidBodyComp:ApplyImpulse(Vec2.new(0, 30.0))
		jumpTimeout = 15
	end 
	
	if(rigidBodyComp:GetLinearVelocity().x > 0.0001) then
		transformComp.Scale.x = math.abs(transformComp.Scale.x)
	elseif(rigidBodyComp:GetLinearVelocity().x < -0.0001) then
		transformComp.Scale.x = -math.abs(transformComp.Scale.x)
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
		isGrounded = true
	end
end

function OnEndContact(entity, normal, point)
	numContacts = numContacts - 1
	if(numContacts == 0) then
		isGrounded = false
	end
end




