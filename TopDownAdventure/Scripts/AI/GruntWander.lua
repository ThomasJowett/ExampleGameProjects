-- Default/lowest-priority leaf: idles and ambles in a random direction
-- when the player is out of sight range. Always returns Running so the
-- Selector only leaves this branch when a higher-priority branch
-- (Attack/Chase) succeeds ahead of it.
local WANDER_SPEED = 1.0

local dirTimer = 0
local dirX, dirY = 0, 0

local function pickDirection()
	local angle = math.random() * math.pi * 2
	dirX, dirY = math.cos(angle), math.sin(angle)
	dirTimer = 1.0 + math.random() * 1.5
end

function OnStateEntry()
	pickDirection()
end

function OnStateUpdate(deltaTime)
	local self = CurrentEntity

	dirTimer = dirTimer - deltaTime
	if dirTimer <= 0 then
		if math.random() < 0.4 then
			dirX, dirY = 0, 0
			dirTimer = 0.6 + math.random() * 0.8
		else
			pickDirection()
		end
	end

	local rb = self:GetRigidBody2DComponent()
	local sprite = self:GetAnimatedSpriteComponent()

	if dirX == 0 and dirY == 0 then
		rb:SetLinearVelocity(Vec2.new(0, 0))
		local anim = sprite.Animation
		if anim ~= "Idle_Down" and anim ~= "Idle_Up" and anim ~= "Idle_Left" and anim ~= "Idle_Right" then
			sprite.Animation = "Idle_Down"
		end
	else
		rb:SetLinearVelocity(Vec2.new(dirX * WANDER_SPEED, dirY * WANDER_SPEED))
		local facing
		if math.abs(dirX) > math.abs(dirY) then
			facing = dirX > 0 and "Right" or "Left"
		else
			facing = dirY > 0 and "Up" or "Down"
		end
		sprite.Animation = "Run_" .. facing
	end

	return NodeStatus.Running
end

function OnStateExit(status)
	CurrentEntity:GetRigidBody2DComponent():SetLinearVelocity(Vec2.new(0, 0))
end
