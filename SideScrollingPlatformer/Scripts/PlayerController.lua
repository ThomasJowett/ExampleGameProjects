maxSpeed = 7

local spriteComp = {}
local rigidBodyComp = {}
local collider = {}
local physicsMaterial = {}
local transformComp = {}

local isGrounded = false;

function CheckIsGrounded()
	local hit = CurrentScene:RayCast2D(
		Vec2.new(transformComp.Position.x, transformComp.Position.y- (collider.Height * transformComp.Scale.y * 0.5)),
		Vec2.new(transformComp.Position.x, transformComp.Position.y - (collider.Height * transformComp.Scale.y * 0.5) - 1))

	isGrounded = hit.Hit;
	--Log.Debug(tostring(hit.Hit))
end


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
	CheckIsGrounded()
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
	else
		--spriteComp:SelectAnimation("Run")
	end


	rigidBodyComp:SetLinearVelocity(Vec2.new(moveInput * maxSpeed, velocity.y))

	if Input.IsKeyPressed(' ') and isGrounded then
		rigidBodyComp:ApplyImpulse(Vec2.new(0, 5.0))
	end 
	
	if(rigidBodyComp:GetLinearVelocity().x > 0.0001) then
		transformComp.Scale.x = math.abs(transformComp.Scale.x)
	elseif(rigidBodyComp:GetLinearVelocity().x < -0.0001) then
		transformComp.Scale.x = -math.abs(transformComp.Scale.x)
	end
end
-- Called when entity is destroyed
function OnDestroy()

end

