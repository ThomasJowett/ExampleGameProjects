-- Attack action leaf: drives the Grunt's own windup/active/recovery swing
-- and applies damage to the player during the active window. Deals with
-- the player directly (rather than via a dedicated hurtbox child entity)
-- since this leaf already has both entities to hand.
local WINDUP = 0.18
local ACTIVE = 0.16
local RECOVERY = 0.28
local RANGE = 1.3
local DAMAGE = 1
local KNOCKBACK = 6.0

local elapsed = 0
local hasHit = false

function OnStateEntry()
	elapsed = 0
	hasHit = false
end

function OnStateUpdate(deltaTime)
	local self = CurrentEntity
	local player = CurrentScene:FindEntity("Player")
	if not player then
		return NodeStatus.Failure
	end

	elapsed = elapsed + deltaTime

	local sp = self:GetTransformComponent().Position
	local pp = player:GetTransformComponent().Position
	local dx, dy = pp.x - sp.x, pp.y - sp.y
	local dist = math.sqrt(dx * dx + dy * dy)

	local facing
	if math.abs(dx) > math.abs(dy) then
		facing = dx > 0 and "Right" or "Left"
	else
		facing = dy > 0 and "Up" or "Down"
	end

	local sprite = self:GetAnimatedSpriteComponent()

	if elapsed < WINDUP then
		sprite.Animation = "Idle_" .. facing
	elseif elapsed < WINDUP + ACTIVE then
		sprite.Animation = "Attack1_" .. facing
		if not hasHit and dist <= RANGE then
			hasHit = true
			local nx, ny = 0, 0
			if dist > 0.001 then
				nx, ny = dx / dist, dy / dist
			end
			Signal.Emit("EntityDamaged", self, {
				target = player,
				damage = DAMAGE,
				knockbackX = nx * KNOCKBACK,
				knockbackY = ny * KNOCKBACK,
			})
		end
	else
		sprite.Animation = "Idle_" .. facing
	end

	if elapsed >= WINDUP + ACTIVE + RECOVERY then
		return NodeStatus.Success
	end
	return NodeStatus.Running
end

function OnStateExit(status)
end
