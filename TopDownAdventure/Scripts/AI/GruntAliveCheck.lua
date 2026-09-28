-- Guards the whole tree: while the Grunt is hurt or dead (flags set on the
-- blackboard by GruntController.lua), the tree fails so nothing else moves or attacks.
function OnStateUpdate(deltaTime)
	if Blackboard:GetBool("Hurt") or Blackboard:GetBool("Dead") then
		return NodeStatus.Failure
	end

	return NodeStatus.Success
end
