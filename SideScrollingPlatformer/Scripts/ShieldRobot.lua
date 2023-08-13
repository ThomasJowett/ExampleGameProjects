local rigidBody = {}
local transform = {}
local sprite = {}
local count = 1
local backwards = false
local attacking = false

-- Called when entity is created
function OnCreate()
	rigidBody = CurrentEntity:GetOrAddRigidBody2DComponent()
	transform = CurrentEntity:GetTransformComponent()
	sprite = CurrentEntity:GetAnimatedSpriteComponent()
end

-- Called once per frame
function OnUpdate(deltaTime)

end
-- Called on a fixed interval
function OnFixedUpdate()
	if(not backwards and not attacking) then
		rigidBody:ApplyForce(Vec2.new(70.0, 0.0))
	elseif (not attacking) then
		rigidBody:ApplyForce(Vec2.new(-70.0, 0.0))
	end

	if(count > 500 and not attacking) then
		attacking = true
		sprite.Animation = "Attack"
	end

	if(count > 700) then
		count = 0
		backwards = not backwards
		transform.Scale.x = -transform.Scale.x
		sprite.Animation = "Walk"
		attacking = false
	else
		count = count + 1
	end
end
-- Called when entity is destroyed
function OnDestroy()

end


