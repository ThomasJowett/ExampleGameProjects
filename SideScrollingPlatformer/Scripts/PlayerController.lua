maxSpeed = 7

local spriteComp = {}
local rigidBodyComp = {}
local collider = {}
local physicsMaterial = {}


-- Called when entity is created
function OnCreate()
	spriteComp = CurrentEntity:GetAnimatedSpriteComponent()
	rigidBodyComp = CurrentEntity:GetRigidBody2DComponent()
	collider = CurrentEntity:GetBoxCollider2DComponent()
	physicsMaterial = collider.PhysicsMaterial
end

-- Called once per frame
function OnUpdate(deltaTime)

end
-- Called on a fixed interval
function OnFixedUpdate()
	--rigidBodyComp.
	if Input.IsKeyPressed('A') then
		rigidBodyComp:ApplyForce(Vec2.new(-100.0, 0))
		--physicsMaterial.Friction = 0.01
	elseif(Input.IsKeyPressed('D')) then
		rigidBodyComp:ApplyForce(Vec2.new(100.0, 0))
		--physicsMaterial.Friction = 0.01
	else
		--physicsMaterial.Friction = 0.5
	end

	if Input.IsKeyPressed(' ') then
		rigidBodyComp:ApplyImpulse(Vec2.new(0, 10.0))
	end 

end
-- Called when entity is destroyed
function OnDestroy()

end


