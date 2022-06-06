local rigidBody = {}
local transform = {}
local sprite = {}
local count = 1
local backwards = false
local attacking = false

-- Called when entity is created
function OnCreate()
	rigidBody = Entity:GetOrAddRigidBody2DComponent()
	transform = Entity:GetTransformComponent()
	sprite = Entity:GetAnimatedSpriteComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)

end
-- Called on a fixed interval
function OnFixedUpdate()
	if(not backwards and not attacking) then
		rigidBody:ApplyForce(Vec2.new(700.0, 0.0))
	elseif (not attacking) then
		rigidBody:ApplyForce(Vec2.new(-700.0, 0.0))
	end

	if(count > 500 and not attacking) then
		attacking = true
		sprite:SelectAnimation("Unnamed Animation (4)")
	end

	if(count > 700) then
		count = 0
		backwards = not backwards
		transform.Scale.x = -transform.Scale.x
		sprite:SelectAnimation("Unnamed Animation (5)")
		attacking = false
	else
		count = count + 1
	end
end
-- Called when entity is destroyed
function OnDestroy()

end


