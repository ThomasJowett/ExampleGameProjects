-- Klondike solitaire. One script drives the whole game: it owns the pile data model
-- (stock/waste/foundations/tableau, as plain Lua tables of card records) and the 52 card
-- entities are just dumb Transform+Sprite puppets that Relayout() positions/textures to match.

suits = { "Clubs", "Diamonds", "Hearts", "Spades" }
rankNames = { "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King" }

CARD_W, CARD_H = 1.0, 1.342857
COL_SPACING = 1.3
FAN_OFFSET = 0.35
TOP_ROW_Y = 4.3
TABLEAU_TOP_Y = 2.6
TOP_ROW_THRESHOLD = (TOP_ROW_Y + TABLEAU_TOP_Y) / 2
DRAG_Z = 1.0
Z_STEP = 0.001
DRAW_COUNT = 1
DOUBLE_CLICK_TIME = 0.35

local function ColX(i) return i * COL_SPACING end
STOCK_X = ColX(-3)
WASTE_X = ColX(-2)
FOUNDATION_X = { ColX(0), ColX(1), ColX(2), ColX(3) }
TABLEAU_X = { ColX(-3), ColX(-2), ColX(-1), ColX(0), ColX(1), ColX(2), ColX(3) }

NEWGAME_RECT = { x = 5.5, y = 5.4, hw = 1.8, hh = 0.45 }
STOCK_RECT = { x = STOCK_X, y = TOP_ROW_Y, hw = CARD_W / 2, hh = CARD_H / 2 }
WASTE_RECT = { x = WASTE_X, y = TOP_ROW_Y, hw = CARD_W / 2, hh = CARD_H / 2 }

allCards = {}
stock, waste = {}, {}
foundations = {}
tableau = {}
dragging = nil
lastClickCard, lastClickTime = nil, 0
score, moves, elapsed = 0, 0, 0
gameWon = false

backTexture = nil
scoreText, timeText, winText = nil, nil, nil

function PointInRect(p, r)
	return p.x >= r.x - r.hw and p.x <= r.x + r.hw and p.y >= r.y - r.hh and p.y <= r.y + r.hh
end

function FormatTime(t)
	local m = math.floor(t / 60)
	local s = math.floor(t % 60)
	return string.format("%02d:%02d", m, s)
end

function IsRed(suit)
	return suit == "Hearts" or suit == "Diamonds"
end

function BuildDeck()
	for _, suit in ipairs(suits) do
		for rank = 1, 13 do
			local entity = CurrentScene:CreateEntity(rankNames[rank] .. " of " .. suit)
			local transform = entity:AddTransformComponent()
			transform.Scale = Vec3.new(CARD_W, CARD_H, 1)
			local sprite = entity:AddSpriteComponent()
			sprite.Texture = backTexture
			table.insert(allCards, {
				suit = suit,
				rank = rank,
				faceUp = false,
				entity = entity,
				transform = transform,
				sprite = sprite,
			})
		end
	end
end

function CreateSlotMarkers()
	local positions = { { STOCK_X, TOP_ROW_Y } }
	for _, x in ipairs(FOUNDATION_X) do table.insert(positions, { x, TOP_ROW_Y }) end
	for _, x in ipairs(TABLEAU_X) do table.insert(positions, { x, TABLEAU_TOP_Y }) end

	for _, p in ipairs(positions) do
		local entity = CurrentScene:CreateEntity("Slot Marker")
		local transform = entity:AddTransformComponent()
		transform.Position = Vec3.new(p[1], p[2], -0.01)
		transform.Scale = Vec3.new(CARD_W, CARD_H, 1)
		local sprite = entity:AddSpriteComponent()
		sprite.Tint = Colour.new(1, 1, 1, 0.12)
	end
end

function Shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function NewGame()
	stock, waste = {}, {}
	for _, s in ipairs(suits) do foundations[s] = {} end
	tableau = { {}, {}, {}, {}, {}, {}, {} }
	dragging = nil
	lastClickCard = nil
	score, moves, elapsed = 0, 0, 0
	gameWon = false
	winText.Text = ""

	local deck = {}
	for _, card in ipairs(allCards) do
		card.faceUp = false
		table.insert(deck, card)
	end
	Shuffle(deck)

	local idx = 1
	for col = 1, 7 do
		for row = 1, col do
			local card = deck[idx]
			idx = idx + 1
			card.faceUp = (row == col)
			table.insert(tableau[col], card)
		end
	end
	for i = idx, #deck do table.insert(stock, deck[i]) end

	Relayout()
end

function SetCardVisual(card, x, y, z)
	card.transform.Position = Vec3.new(x, y, z)
	if card.faceUp then
		card.sprite.Texture = AssetManager.GetTexture("Sprites/" .. rankNames[card.rank] .. " " .. card.suit .. ".png")
	else
		card.sprite.Texture = backTexture
	end
end

function Relayout()
	for i, card in ipairs(stock) do
		SetCardVisual(card, STOCK_X, TOP_ROW_Y, i * Z_STEP)
	end
	for i, card in ipairs(waste) do
		SetCardVisual(card, WASTE_X, TOP_ROW_Y, (100 + i) * Z_STEP)
	end
	for i, suit in ipairs(suits) do
		for j, card in ipairs(foundations[suit]) do
			SetCardVisual(card, FOUNDATION_X[i], TOP_ROW_Y, (200 + j) * Z_STEP)
		end
	end
	for col = 1, 7 do
		for i, card in ipairs(tableau[col]) do
			local y = TABLEAU_TOP_Y - (i - 1) * FAN_OFFSET
			SetCardVisual(card, TABLEAU_X[col], y, (300 + col * 20 + i) * Z_STEP)
		end
	end

	scoreText.Text = "Score: " .. score .. "   Moves: " .. moves
end

function ExposeTop(col)
	local pile = tableau[col]
	if #pile > 0 and not pile[#pile].faceUp then
		pile[#pile].faceUp = true
		score = score + 5
	end
end

function CanStackTableau(movingCard, targetCard)
	if targetCard == nil then return movingCard.rank == 13 end
	return targetCard.faceUp
		and IsRed(movingCard.suit) ~= IsRed(targetCard.suit)
		and movingCard.rank == targetCard.rank - 1
end

function CanPlaceFoundation(slot, card)
	if card.suit ~= suits[slot] then return false end
	local pile = foundations[suits[slot]]
	if #pile == 0 then return card.rank == 1 end
	return card.rank == pile[#pile].rank + 1
end

function CheckWin()
	for _, s in ipairs(suits) do
		if #foundations[s] < 13 then return end
	end
	gameWon = true
	winText.Text = "You Win!\nMoves: " .. moves .. "   Time: " .. FormatTime(elapsed)
end

function TryAutoToFoundation(card)
	for slot = 1, 4 do
		if CanPlaceFoundation(slot, card) then
			table.insert(foundations[suits[slot]], card)
			score = score + 10
			moves = moves + 1
			CheckWin()
			return true
		end
	end
	return false
end

function DrawFromStock()
	if #stock == 0 then
		for i = #waste, 1, -1 do
			waste[i].faceUp = false
			table.insert(stock, waste[i])
		end
		waste = {}
	else
		for _ = 1, math.min(DRAW_COUNT, #stock) do
			local card = table.remove(stock)
			card.faceUp = true
			table.insert(waste, card)
		end
	end
	moves = moves + 1
	Relayout()
end

function BeginDrag(sourceType, sourceCol, cards, grabWorld)
	dragging = { sourceType = sourceType, sourceCol = sourceCol, cards = cards, grabWorld = grabWorld }

	local base = cards[1].transform.Position
	dragging.basePos = { x = base.x, y = base.y }
	dragging.offsets = {}
	for i, card in ipairs(cards) do
		local p = card.transform.Position
		dragging.offsets[i] = { x = p.x - base.x, y = p.y - base.y }
	end
end

function TryBeginDrag(sourceType, sourceCol, index, grabWorld)
	local card
	if sourceType == "waste" then
		card = waste[#waste]
	else
		card = tableau[sourceCol][index]
	end
	if not card.faceUp then return end

	local isTopSingle = (sourceType == "waste") or (index == #tableau[sourceCol])
	local now = os.clock()
	if isTopSingle and lastClickCard == card and (now - lastClickTime) < DOUBLE_CLICK_TIME then
		lastClickCard = nil
		if TryAutoToFoundation(card) then
			if sourceType == "waste" then
				table.remove(waste)
			else
				table.remove(tableau[sourceCol])
				ExposeTop(sourceCol)
			end
			Relayout()
			return
		end
	end
	lastClickCard = card
	lastClickTime = now

	local cards = {}
	if sourceType == "waste" then
		cards = { table.remove(waste) }
	else
		for i = index, #tableau[sourceCol] do table.insert(cards, tableau[sourceCol][i]) end
		for _ = 1, #cards do table.remove(tableau[sourceCol]) end
	end

	BeginDrag(sourceType, sourceCol, cards, grabWorld)
end

function HandleMouseDown(pos)
	if PointInRect(pos, NEWGAME_RECT) then
		NewGame()
		return
	end
	if gameWon then return end

	if PointInRect(pos, STOCK_RECT) then
		DrawFromStock()
		return
	end

	if #waste > 0 and PointInRect(pos, WASTE_RECT) then
		TryBeginDrag("waste", nil, #waste, pos)
		return
	end

	for col = 1, 7 do
		local pile = tableau[col]
		for i = #pile, 1, -1 do
			local y = TABLEAU_TOP_Y - (i - 1) * FAN_OFFSET
			if PointInRect(pos, { x = TABLEAU_X[col], y = y, hw = CARD_W / 2, hh = CARD_H / 2 }) then
				if pile[i].faceUp then
					TryBeginDrag("tableau", col, i, pos)
				end
				return
			end
		end
	end
end

function DragUpdate(mouseWorld)
	local dx = mouseWorld.x - dragging.grabWorld.x
	local dy = mouseWorld.y - dragging.grabWorld.y
	for i, card in ipairs(dragging.cards) do
		local off = dragging.offsets[i]
		card.transform.Position = Vec3.new(dragging.basePos.x + dx + off.x, dragging.basePos.y + dy + off.y, DRAG_Z + i * 0.01)
	end
end

function DragEnd(mouseWorld)
	local d = dragging
	dragging = nil

	local colIndex = math.floor(mouseWorld.x / COL_SPACING + 0.5)
	local topRow = mouseWorld.y > TOP_ROW_THRESHOLD
	local placed = false

	if topRow and #d.cards == 1 and colIndex >= 0 and colIndex <= 3 then
		local slot = colIndex + 1
		if CanPlaceFoundation(slot, d.cards[1]) then
			table.insert(foundations[suits[slot]], d.cards[1])
			score = score + 10
			placed = true
			CheckWin()
		end
	elseif (not topRow) and colIndex >= -3 and colIndex <= 3 then
		local col = colIndex + 4
		local destPile = tableau[col]
		if CanStackTableau(d.cards[1], destPile[#destPile]) then
			for _, card in ipairs(d.cards) do table.insert(destPile, card) end
			placed = true
		end
	end

	if placed then
		moves = moves + 1
		if d.sourceType == "tableau" then ExposeTop(d.sourceCol) end
	else
		if d.sourceType == "waste" then
			table.insert(waste, d.cards[1])
		else
			for _, card in ipairs(d.cards) do table.insert(tableau[d.sourceCol], card) end
		end
	end

	Relayout()
end

function OnCreate()
	math.randomseed(os.time())
	backTexture = AssetManager.GetTexture("Sprites/Back - Blue.png")

	scoreText = CurrentScene:FindEntity("ScoreText"):GetTextComponent()
	timeText = CurrentScene:FindEntity("TimeText"):GetTextComponent()
	winText = CurrentScene:FindEntity("WinText"):GetTextComponent()

	BuildDeck()
	CreateSlotMarkers()
	NewGame()
end

function OnUpdate(deltaTime)
	if not gameWon then
		elapsed = elapsed + deltaTime
		timeText.Text = "Time: " .. FormatTime(elapsed)
	end

	local mx, my = Input.GetMousePos()
	local mouseWorld = CurrentScene:ScreenToWorldPoint(Vec2.new(mx, my), 0.0)

	if dragging then
		if Input.IsMouseButtonPressed(MouseButton.Left) then
			DragUpdate(mouseWorld)
		end
		if Input.IsMouseButtonReleased(MouseButton.Left) then
			DragEnd(mouseWorld)
		end
	elseif Input.IsMouseJustPressed(MouseButton.Left) then
		HandleMouseDown(mouseWorld)
	end
end
