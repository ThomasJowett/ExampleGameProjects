local ATTACK_RANGE = 1.15

function OnStateUpdate(deltaTime)
	local self = CurrentEntity
	local player = CurrentScene:FindEntity("Player")
	if not player then
		return NodeStatus.Failure
	end

	local sp = self:GetTransformComponent().Position
	local pp = player:GetTransformComponent().Position
	local dx, dy = pp.x - sp.x, pp.y - sp.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist <= ATTACK_RANGE then
		return NodeStatus.Success
	end
	return NodeStatus.Failure
end
