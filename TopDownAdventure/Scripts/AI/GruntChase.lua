-- Chase action leaf. Keeps running (and re-picking a facing/anim each tick)
-- until the player gets out of LOSE_RANGE, at which point it fails so the
-- Selector falls through to GruntWander.lua. It re-checks distance itself
-- every tick rather than relying on the parent Sequence to re-evaluate
-- GruntCanChase.lua, since composite "memory" semantics for a Running
-- child weren't confirmed - this keeps the behaviour correct either way.
local CHASE_SPEED = 2.4
local LOSE_RANGE = 6.0

function OnStateUpdate(deltaTime)
	local self = CurrentEntity
	local player = CurrentScene:FindEntity("Player")
	if not player then
		return NodeStatus.Failure
	end

	local rb = self:GetRigidBody2DComponent()
	local sprite = self:GetAnimatedSpriteComponent()

	local sp = self:GetTransformComponent().Position
	local pp = player:GetTransformComponent().Position
	local dx, dy = pp.x - sp.x, pp.y - sp.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist > LOSE_RANGE then
		rb:SetLinearVelocity(Vec2.new(0, 0))
		return NodeStatus.Failure
	end

	local facing
	if math.abs(dx) > math.abs(dy) then
		facing = dx > 0 and "Right" or "Left"
	else
		facing = dy > 0 and "Up" or "Down"
	end

	if dist < 0.05 then
		rb:SetLinearVelocity(Vec2.new(0, 0))
		sprite.Animation = "Idle_" .. facing
		return NodeStatus.Running
	end

	local nx, ny = dx / dist, dy / dist
	rb:SetLinearVelocity(Vec2.new(nx * CHASE_SPEED, ny * CHASE_SPEED))
	sprite.Animation = "Run_" .. facing

	return NodeStatus.Running
end

function OnStateExit(status)
	CurrentEntity:GetRigidBody2DComponent():SetLinearVelocity(Vec2.new(0, 0))
end
