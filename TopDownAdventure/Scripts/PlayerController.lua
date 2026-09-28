-- Top-down 4-direction player controller. State is tracked as a plain Lua
-- variable (state/facing below) rather than via StateMachineComponent,
-- which the engine never ticks - see the project README for why.
--
-- Movement/Attack/Roll read from InputAction (Generated/InputMappings.inputmappings)
-- rather than polling Input.IsKeyPressed directly, so keyboard + gamepad and
-- Shift/Escape-class keys (unreachable through the char-based IsKeyPressed
-- binding) all just work without any key-code workarounds here.

local MOVE_SPEED = 4.5
local ROLL_SPEED = 10.0
local ROLL_DURATION = 0.22
local ROLL_COOLDOWN = 0.35
local ATTACK_WINDUP = 0.12
local ATTACK_ACTIVE = 0.16
local ATTACK_RECOVERY = 0.16
local HURT_DURATION = 0.35

local MAX_HEALTH = 8

local STATE_ANIM_PREFIX = {
	Idle = "Idle",
	Walk = "Run",
	Attack = "Attack1",
	Roll = "Run",
}

local FACING_OFFSET = {
	Down = { x = 0, y = -0.75 },
	Up = { x = 0, y = 0.75 },
	Left = { x = -0.75, y = 0 },
	Right = { x = 0.75, y = 0 },
}

local sprite = {}
local rigidBody = {}
local transform = {}
local hitboxRigidBody = {}

local state = "Idle"
local facing = "Down"
local stateTimer = 0

local rollCooldownTimer = 0
local rollDirX, rollDirY = 0, 1

local health = MAX_HEALTH
local invulnerable = false

local attackPhase = nil

local NORMAL_TINT = Colour.new(1, 1, 1, 1)
local FLASH_TINT = Colour.new(1, 0.4, 0.4, 1)

local function computeFacing(dx, dy)
	if math.abs(dx) > math.abs(dy) then
		return dx > 0 and "Right" or "Left"
	else
		return dy > 0 and "Up" or "Down"
	end
end

local function setAnimation()
	if state == "Hurt" then
		sprite.Animation = "Hurt"
	elseif state == "Dead" then
		sprite.Animation = "Dead"
	else
		sprite.Animation = STATE_ANIM_PREFIX[state] .. "_" .. facing
	end
end

local FIXED_DT = App.GetFixedUpdateInterval()

local function updateHitboxPosition()
	local off = FACING_OFFSET[facing]
	hitboxRigidBody:SetTransform(Vec2.new(transform.Position.x + off.x, transform.Position.y + off.y), 0)
end

function OnCreate()
	sprite = CurrentEntity:GetAnimatedSpriteComponent()
	rigidBody = CurrentEntity:GetRigidBody2DComponent()
	transform = CurrentEntity:GetTransformComponent()

	local hitboxEntity = CurrentScene:FindEntity("PlayerSwordHitbox")
	hitboxRigidBody = hitboxEntity:GetRigidBody2DComponent()

	setAnimation()

	Signal.Connect("EntityDamaged", CurrentEntity, function(sender, data)
		if state == "Dead" or invulnerable then
			return
		end
		if not data.target or data.target:GetName() ~= CurrentEntity:GetName() then
			return
		end

		health = health - data.damage
		if data.knockbackX and data.knockbackY then
			rigidBody:ApplyImpulse(Vec2.new(data.knockbackX, data.knockbackY))
		end

		Signal.Emit("PlayerHealthChanged", CurrentEntity, { health = health, max = MAX_HEALTH })

		if health <= 0 then
			health = 0
			state = "Dead"
			stateTimer = 0
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
		else
			state = "Hurt"
			stateTimer = 0
			invulnerable = true
		end
		setAnimation()
	end)

	Signal.Emit("PlayerHealthChanged", CurrentEntity, { health = health, max = MAX_HEALTH })
end

function OnDestroy()
	Signal.Disconnect("EntityDamaged", CurrentEntity)
end

function OnUpdate(deltaTime)
	if state == "Hurt" then
		if math.floor(stateTimer * 20) % 2 == 0 then
			sprite.Tint = FLASH_TINT
		else
			sprite.Tint = NORMAL_TINT
		end
	elseif sprite.Tint.r ~= NORMAL_TINT.r or sprite.Tint.a ~= NORMAL_TINT.a then
		sprite.Tint = NORMAL_TINT
	end
end

function OnFixedUpdate()
	if rollCooldownTimer > 0 then
		rollCooldownTimer = rollCooldownTimer - FIXED_DT
	end

	if state == "Dead" then
		return
	end

	if state == "Idle" or state == "Walk" then
		local move = InputAction.Move:GetAxis2D()
		local inputX, inputY = move.x, move.y

		local mag = math.sqrt(inputX * inputX + inputY * inputY)
		if mag > 0.001 then
			inputX, inputY = inputX / mag, inputY / mag
			facing = computeFacing(inputX, inputY)
			state = "Walk"
			rigidBody:SetLinearVelocity(Vec2.new(inputX * MOVE_SPEED, inputY * MOVE_SPEED))
		else
			state = "Idle"
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
		end

		local wantsAttack = InputAction.Attack:IsTriggered()
		local wantsRoll = InputAction.Roll:IsTriggered() and rollCooldownTimer <= 0

		if wantsRoll then
			state = "Roll"
			stateTimer = 0
			invulnerable = true
			rollDirX, rollDirY = FACING_OFFSET[facing].x, FACING_OFFSET[facing].y
			local rollMag = math.sqrt(rollDirX * rollDirX + rollDirY * rollDirY)
			rollDirX, rollDirY = rollDirX / rollMag, rollDirY / rollMag
			rigidBody:SetLinearVelocity(Vec2.new(rollDirX * ROLL_SPEED, rollDirY * ROLL_SPEED))
		elseif wantsAttack then
			state = "Attack"
			stateTimer = 0
			attackPhase = "Windup"
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
		end

		setAnimation()
	elseif state == "Attack" then
		stateTimer = stateTimer + FIXED_DT
		updateHitboxPosition()

		if stateTimer < ATTACK_WINDUP then
			if attackPhase ~= "Windup" then
				attackPhase = "Windup"
			end
		elseif stateTimer < ATTACK_WINDUP + ATTACK_ACTIVE then
			if attackPhase ~= "Active" then
				attackPhase = "Active"
				Signal.Emit("PlayerAttackActive", CurrentEntity, {})
			end
		else
			if attackPhase ~= "Recovery" then
				attackPhase = "Recovery"
				Signal.Emit("PlayerAttackEnd", CurrentEntity, {})
			end
		end

		if stateTimer >= ATTACK_WINDUP + ATTACK_ACTIVE + ATTACK_RECOVERY then
			state = "Idle"
			setAnimation()
		end
	elseif state == "Roll" then
		stateTimer = stateTimer + FIXED_DT
		rigidBody:SetLinearVelocity(Vec2.new(rollDirX * ROLL_SPEED, rollDirY * ROLL_SPEED))

		if stateTimer >= ROLL_DURATION then
			state = "Idle"
			invulnerable = false
			rollCooldownTimer = ROLL_COOLDOWN
			rigidBody:SetLinearVelocity(Vec2.new(0, 0))
			setAnimation()
		end
	elseif state == "Hurt" then
		stateTimer = stateTimer + FIXED_DT
		if stateTimer >= HURT_DURATION then
			state = "Idle"
			invulnerable = false
			setAnimation()
		end
	end

	if state ~= "Attack" then
		updateHitboxPosition()
	end
end
