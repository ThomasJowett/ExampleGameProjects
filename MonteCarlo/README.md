# Monte Carlo

![Monte Carlo screenshot](../Screenshots/MonteCarlo.png)

Not a game — a visualization of the [Monte Carlo method](https://en.wikipedia.org/wiki/Monte_Carlo_method)
estimating π: every fixed update it drops a point at a random position in a unit square,
colours it red if it lands inside the inscribed quarter-circle and blue otherwise, and
the ratio of red to total points converges on π/4. It's the smallest project in this
repository, and a good first one to open.

## Engine features demonstrated

- **Runtime entity creation and destruction** — [`MonteCarlo.lua`](Scripts/MonteCarlo.lua)
  calls `CurrentScene:CreateEntity(name)` every fixed update to spawn each sample point,
  and once `monteCarloRuns` samples have accumulated, destroys all of them
  (`entity:Destroy()`) and starts over — nothing about the point cloud is authored in the
  scene file, it's 100% script-driven.
- **Flat-tint sprites** — each sample point is a bare `SpriteComponent` with no texture,
  just a `Tint` colour, scaled down via `Transform.Scale` — showing that `Sprite` doesn't
  require an image to be useful as a coloured quad.
- **Named colour constants** — tints are set with `Colour.new(Colours.Red)` /
  `Colour.new(Colours.Blue)` rather than raw RGBA values.
- **Live text output** — a single `TextComponent` is updated every frame with the
  running π estimate and its error against `math.pi`, showing `TextComponent.Text` being
  driven entirely by a calculation rather than game state.
- **Minimal scene setup** — the whole project is two entities (a camera + background,
  and the script-driving entity), making it the clearest reference for "what's the least
  I need to run a Lua script every frame."
