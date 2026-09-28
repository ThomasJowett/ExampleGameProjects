-- Owns the Grunt's health/hurt/death reaction. Movement and attack
-- decisions live entirely in Scripts/Grunt.behaviourtree + Scripts/AI/*.lua;
-- this script tells the tree the Grunt is hurt or dead through the "Hurt" and
-- "Dead" blackboard bools (see GruntAliveCheck.lua).
local maxHealth = 6
local health = maxHealth

local hurtDuration = 0.3
local hurtTimer = 0

local dead = false
local deadTimer = 0
local DEAD_FADE_TIME = 0.6

local NORMAL_TINT = Colour.new(1, 0.55, 0.55, 1)
local FLASH_TINT = Colour.new(1, 1, 1, 1)

local sprite = {}
local rigidBody = {}
local blackboard = nil

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
		end

		if health <= 0 then
			health = 0
			dead = true
			deadTimer = 0
			SetFlag("Dead", true)
			sprite.Animation = "Dead"
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
		else
			sprite.Animation = "Hurt"
		end
	end)
end

function OnDestroy()
	Signal.Disconnect("EntityDamaged", CurrentEntity)
end

function OnUpdate(deltaTime)
	if dead then
		deadTimer = deadTimer + deltaTime
		local a = 1 - math.min(deadTimer / DEAD_FADE_TIME, 1)
		sprite.Tint = Colour.new(1, 0.55, 0.55, a)
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
