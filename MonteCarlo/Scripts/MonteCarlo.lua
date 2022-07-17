monteCarloRuns = 1000
local redPositions = 0
local bluePositions = 0
local entities = {}

-- Called when entity is created
function OnCreate()
end

-- Called once per frame
function OnUpdate(deltaTime)
	local pi = 4 * redPositions / (bluePositions + redPositions)

	--TODO: display this as text on the screen
	Log.Info(tostring(pi))
end

-- Called on a fixed interval
function OnFixedUpdate()
	if(redPositions + bluePositions > monteCarloRuns) then
		for key, entity in pairs(entities) do
			entity:Destroy()
		end
		redPositions = 0
		bluePositions = 0
		entities = {}
	end

	local position = Vec2.new(math.random(), math.random())
	local entity = {}
	if (position:SqrLength() < 1.0) then
		redPositions = redPositions + 1
		entity = CurrentScene:CreateEntity("Red Position " .. tostring(redPositions))
		local sprite = entity:AddSpriteComponent()
		sprite.Tint = Colour.new(Colours.Red)
	else
		bluePositions = bluePositions + 1
		entity = CurrentScene:CreateEntity("Blue Position " .. tostring(bluePositions))
		local sprite = entity:AddSpriteComponent()
		sprite.Tint = Colour.new(Colours.Blue)
	end

	table.insert(entities, entity)
	local transform = entity:GetTransformComponent()
	transform.Position = Vec3.new(position.x, position.y, 0.1)
	entity:GetTransformComponent().Scale = Vec3.new(0.01, 0.01, 0.01)
end
-- Called when entity is destroyed
function OnDestroy()

end


