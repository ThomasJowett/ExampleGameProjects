-- Owns the Grunt's health/hurt/death reaction, and the actual damage-dealing
-- for its own melee swing. Movement and attack *timing* live entirely in
-- Scripts/Grunt.behaviourtree (a plain Wait/EmitSignal sequence - see the
-- Attack branch) + Scripts/AI/*.lua; this script reacts to the
-- "GruntAttackActive"/"GruntAttackEnd" signals the tree emits, and tells the
-- tree the Grunt is hurt or dead through the "Hurt"/"Dead" blackboard bools
-- (see GruntAliveCheck.lua).
local maxHealth = 6
local health = maxHealth

local hurtDuration = 0.3
local hurtTimer = 0

local dead = false
local deadTimer = 0
local DEAD_FADE_TIME = 0.6

local ATTACK_RANGE = 1.3
local ATTACK_DAMAGE = 1
local ATTACK_KNOCKBACK = 6.0

local NORMAL_TINT = Colour.new(1, 1, 1, 1)
local FLASH_TINT = Colour.new(1, 0.4, 0.4, 1)

local sprite = {}
local rigidBody = {}
local blackboard = nil

-- Facing last used for an Attack/Hurt/Death clip - these three are the only
-- times this script (rather than the movement leaves) needs a facing.
local lastFacing = "Down"

local function computeFacing(dx, dy)
	if math.abs(dx) > math.abs(dy) then
		return dx > 0 and "Right" or "Left"
	else
		return dy > 0 and "Up" or "Down"
	end
end

local function SetFlag(key, value)
	if blackboard then
		blackboard:SetBool(key, value)
	end
end

function OnCreate()
	sprite = CurrentEntity:GetAnimatedSpriteComponent()
	rigidBody = CurrentEntity:GetRigidBody2DComponent()
	sprite.Tint = NORMAL_TINT

	local behaviourTree = CurrentEntity:GetBehaviourTreeComponent()
	if behaviourTree then
		blackboard = behaviourTree:GetBlackboard()
	end
	SetFlag("Hurt", false)
	SetFlag("Dead", false)

	Signal.Connect("EntityDamaged", CurrentEntity, function(sender, data)
		if dead then
			return
		end
		if data.target ~= CurrentEntity then
			return
		end

		health = health - data.damage
		hurtTimer = hurtDuration
		SetFlag("Hurt", true)

		if data.knockbackX and data.knockbackY then
			rigidBody:ApplyImpulse(Vec2.new(data.knockbackX, data.knockbackY))
			-- Knockback points away from the attacker, so it's also a
			-- reasonable facing for the Hurt/Death clip.
			if data.knockbackX ~= 0 or data.knockbackY ~= 0 then
				lastFacing = computeFacing(data.knockbackX, data.knockbackY)
			end
		end

		if health <= 0 then
			health = 0
			dead = true
			deadTimer = 0
			SetFlag("Dead", true)
			sprite.Animation = "Death_" .. lastFacing
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
		else
			sprite.Animation = "Hurt_" .. lastFacing
		end
	end)

	-- Emitted by Grunt.behaviourtree's Attack sequence (Wait/EmitSignal only,
	-- no CustomTask) at the start/end of the active hit-check window.
	Signal.Connect("GruntAttackActive", CurrentEntity, function(sender, data)
		if sender ~= CurrentEntity or dead then
			return
		end

		local player = CurrentScene:FindEntity("Player")
		if not player then
			return
		end

		local sp = CurrentEntity:GetTransformComponent().Position
		local pp = player:GetTransformComponent().Position
		local dx, dy = pp.x - sp.x, pp.y - sp.y
		local dist = math.sqrt(dx * dx + dy * dy)

		lastFacing = computeFacing(dx, dy)
		sprite.Animation = "Attack_" .. lastFacing

		if dist <= ATTACK_RANGE then
			local nx, ny = 0, 0
			if dist > 0.001 then
				nx, ny = dx / dist, dy / dist
			end
			Signal.Emit("EntityDamaged", CurrentEntity, {
				target = player,
				damage = ATTACK_DAMAGE,
				knockbackX = nx * ATTACK_KNOCKBACK,
				knockbackY = ny * ATTACK_KNOCKBACK,
			})
		end
	end)

	Signal.Connect("GruntAttackEnd", CurrentEntity, function(sender, data)
		-- Nothing to do: the next Wander/Chase tick sets the right
		-- Idle/Run clip once the tree's Attack sequence finishes.
	end)
end

function OnDestroy()
	Signal.Disconnect("EntityDamaged", CurrentEntity)
	Signal.Disconnect("GruntAttackActive", CurrentEntity)
	Signal.Disconnect("GruntAttackEnd", CurrentEntity)
end

function OnUpdate(deltaTime)
	if dead then
		deadTimer = deadTimer + deltaTime
		local a = 1 - math.min(deadTimer / DEAD_FADE_TIME, 1)
		sprite.Tint = Colour.new(1, 1, 1, a)
		if deadTimer >= DEAD_FADE_TIME then
			CurrentEntity:Destroy()
		end
		return
	end

	if hurtTimer > 0 then
		hurtTimer = hurtTimer - deltaTime
		if math.floor(hurtTimer * 20) % 2 == 0 then
			sprite.Tint = FLASH_TINT
		else
			sprite.Tint = NORMAL_TINT
		end
		if hurtTimer <= 0 then
			sprite.Tint = NORMAL_TINT
			SetFlag("Hurt", false)
		end
	end
end
