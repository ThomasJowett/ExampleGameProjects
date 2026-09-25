# Side Scrolling Platformer

![Side Scrolling Platformer screenshot](../Screenshots/SideScrollingPlatformer.png)

A 2D platformer: an animated adventurer runs and jumps across a tile-built jungle level
past a patrolling shield robot, over layered parallax backgrounds with footstep, jump,
and landing sound effects.

## Engine features demonstrated

- **Tilemaps** — the level's foreground (collidable) and background (decorative) layers
  are both `Tilemap` components against `Tilemaps/Jungle.tileset`, at different sizes and
  Z-depths.
- **Parallax backgrounds** — five `Primitive` planes, each on its own `Material`, are
  nested under one "Backgrounds" entity and scrolled at different rates by
  [`Parallax Background.lua`](Scripts/Parallax%20Background.lua) to give the scene depth.
- **Physics bodies, colliders and materials** — the player combines a `RigidBody2D`
  with a `BoxCollider2D` trigger (ground detection) and a `CapsuleCollider2D` carrying a
  `.physicsmaterial` asset (`Player.physicsmaterial`) for friction/restitution; the robot
  uses its own `Robot.physicsmaterial`.
- **Physics contact events** — [`PlayerController.lua`](Scripts/PlayerController.lua)
  implements `OnBeginContact`/`OnEndContact` to track how many ground contacts are active
  and derive an `isGrounded` state from it, rather than trusting a single collision.
- **Animation driven by physics state** — the player's `AnimatedSprite` animation
  (`Idle` / `Run` / `Jump Start` / `Jump Loop`) is chosen from the rigid body's current
  velocity and grounded state each fixed update.
- **Gamepad input alongside keyboard** — `PlayerController.lua` reads
  `Input.GetJoystickAxis` and `Input.IsJoystickButtonPressed` next to the equivalent
  keyboard checks, so either works.
- **Signals decoupling gameplay from audio** — the player emits `player_jump` and
  `player_land` signals; two separate child entities ("Jump Sound Effect", "Land Sound
  Effect") each run a small [`PlaySoundOnSignal.lua`](Scripts/PlaySoundOnSignal.lua)
  script that connects to one signal and plays its own `AudioSource` — the player script
  never references the sound entities directly.
- **Spatial audio** — footstep/jump/landing `AudioSource` components carry
  `MinDistance`/`MaxDistance`/`Rolloff`, and the player has a primary `AudioListener`;
  background music loops from a dedicated entity with `PlayOnStart="true"`.
- **Camera follow** — [`Camera.lua`](Scripts/Camera.lua) lerps the camera toward the
  player's position each fixed update and clamps it inside fixed world bounds, using the
  camera's own `OrthoSize`/`AspectRatio` to know how much margin it needs at the edges.
- **AI components** — the robot entity carries `BehaviourTree` and `StateMachine`
  components (with a `Robot.behaviourtree` asset alongside it) in addition to its own
  simple counter-driven patrol/attack logic in
  [`ShieldRobot.lua`](Scripts/ShieldRobot.lua).
