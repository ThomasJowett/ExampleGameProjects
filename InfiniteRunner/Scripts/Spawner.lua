local timer = 0.0
function SpawnItem()

	local obstacle = CurrentScene:CreateEntity("Obstacle")
	rigidBody = obstacle:AddRigidBody2DComponent()
	--rigidBody:SetLinearVelocity(Vec2.new(-1,0))
	local sprite = obstacle:AddSpriteComponent()
	sprite.Texture = AssetManager.GetTexture("Sprites/crate.png")

end
-- Called when entity is created
function OnCreate()

end

-- Called once per frame
function OnUpdate(deltaTime)
	timer = timer + deltaTime;
	if timer > 1.0 then
		SpawnItem()
		Log.Debug("Spawned New obstacle")
		timer = 0.0

	end
end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end




