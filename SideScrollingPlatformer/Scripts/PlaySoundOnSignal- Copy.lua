signal = "player_jump"
local sound = nil

-- Called when entity is created
function OnCreate()
	sound = CurrentEntity:GetAudioSourceComponent()

	Signal.Connect(signal, CurrentEntity, function(sender, data)
				--sound.Play()
				local soundComp = CurrentEntity:GetAudioSourceComponent()
				soundComp:Play()
			end)
end

-- Called once per frame
function OnUpdate(deltaTime)

end
-- Called on a fixed interval
function OnFixedUpdate()

end
-- Called when entity is destroyed
function OnDestroy()

end
