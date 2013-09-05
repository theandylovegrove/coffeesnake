
  BLOCK_SIZE = undefined
  FIELD_HEIGHT = undefined
  FIELD_WIDTH = undefined
  HEIGHT = undefined
  INITIAL_LENGTH = undefined
  MOVEMENT_SPEED = undefined
  WIDTH = undefined
  animate = undefined
  canvas = undefined
  context = undefined
  g_over = undefined
  g_place_food = undefined
  newGame = undefined
  newsnake = undefined
  renderSnake = undefined
  snake = undefined
  soundHandle = undefined
  _block_in_snake = undefined
  _modify_coordinate = undefined
  _movement_allowed = undefined
  BLOCK_SIZE = 8
  WIDTH = 32
  HEIGHT = 32
  FIELD_WIDTH = WIDTH * BLOCK_SIZE
  FIELD_HEIGHT = HEIGHT * BLOCK_SIZE
  INITIAL_LENGTH = 3
  MOVEMENT_SPEED = 150
  newsnake = ->
    snake = undefined
    _i = undefined
    _ref = undefined
    _x = undefined
    snake =
      score: 0
      direction: 2
      blocks: []

    _x = _i = _ref = INITIAL_LENGTH - 1
    while (if _ref <= 0 then _i <= 0 else _i >= 0)
      snake.blocks.push
        x: _x
        y: 0

      _x = (if _ref <= 0 then ++_i else --_i)
    snake

  snake = newsnake()
  document._LAST_KEY = 0
  document._GAME_PAUSED = false
  document.onkeydown = (e) ->
    direction = undefined
    direction = 0
    switch e.keyCode
      when 38 then direction = 1
      when 39 then direction = 2
      when 40 then direction = 3
      when 37 then direction = 4
      when 8 then newGame()
      when 32 then document._GAME_PAUSED = not document._GAME_PAUSED

    document.getElementById("score").innerHTML = if document._GAME_PAUSED then "Pause" else snake.score
    document._LAST_KEY = direction

  newGame = ->
    if document.getElementById("score").innerHTML is "Game over"
      snake = newsnake()
      g_place_food snake
      renderSnake snake, context
      setTimeout (->
        startTime = undefined
        startTime = (new Date()).getTime()
        animate snake, context, canvas, startTime
      ), 500

  canvas = document.getElementById("canvas")
  canvas.style.display = "block"
  canvas.style.width = FIELD_WIDTH + "px"
  canvas.style.height = FIELD_HEIGHT + "px"
  canvas.width = FIELD_WIDTH
  canvas.height = FIELD_HEIGHT
  canvas.style.border = "2px solid black"
  canvas.style.margin = "100px auto 0"
  context = canvas.getContext("2d")
  soundHandle = document.getElementById("soundHandle")
  soundHandle.src = "/bite.mp3"
  _modify_coordinate = (x, y, direction, delta) ->
    switch direction
      when 1 then y -= delta
      when 2 then x += delta
      when 3 then y += delta
      when 4 then x -= delta
    x: x
    y: y

  _block_in_snake = (x, y, snake) ->
    block = undefined
    _i = undefined
    _len = undefined
    _ref = undefined
    _ref = snake.blocks
    _i = 0
    _len = _ref.length

    while _i < _len
      block = _ref[_i]
      return true  if block.x is x and block.y is y
      _i++
    false

  _movement_allowed = (x, y, snake, canvas) ->
    x >= 0 and y >= 0 and x < WIDTH and y < HEIGHT and not _block_in_snake(x, y, snake)

  window.requestAnimFrame = ((callback) ->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
      window.setTimeout callback, 1000 / 60
  )()
  renderSnake = (snake, context) ->
    block = undefined
    _i = undefined
    _len = undefined
    _ref = undefined
    context.clearRect 0, 0, canvas.width, canvas.height
    context.fillStyle = "black"
    context.lineWidth = 1
    context.strokeStyle = "black"
    context.beginPath()
    _ref = snake.blocks
    _i = 0
    _len = _ref.length

    while _i < _len
      block = _ref[_i]
      context.rect block.x * BLOCK_SIZE, block.y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE
      _i++
    context.fill()
    context.stroke()
    context.beginPath()
    context.arc (snake.food.x + 0.5) * BLOCK_SIZE, (snake.food.y + 0.5) * BLOCK_SIZE, BLOCK_SIZE / 2, 0, 2 * Math.PI, false
    context.fill()
    context.stroke()

  animate = (snake, context, canvas, lastframetime) ->
    movementDelta = undefined
    new_snake_head = undefined
    time = undefined
    timeDelta = undefined
    time = (new Date()).getTime()
    timeDelta = time - lastframetime
    movementDelta = parseInt(timeDelta / MOVEMENT_SPEED)
    if document._GAME_PAUSED or movementDelta < 1
      return window.requestAnimFrame(->
        animate snake, context, canvas, lastframetime
      )
    if document._LAST_KEY
      snake.direction = document._LAST_KEY  if Math.abs(snake.direction - document._LAST_KEY) isnt 2
      document._LAST_KEY = 0
    new_snake_head = _modify_coordinate(snake.blocks[0].x, snake.blocks[0].y, snake.direction, 1)
    return g_over(snake, context, canvas)  unless _movement_allowed(new_snake_head.x, new_snake_head.y, snake, canvas)
    snake.blocks.unshift new_snake_head
    if snake.blocks[0].x is snake.food.x and snake.blocks[0].y is snake.food.y
      snake.score += 1
      document.getElementById("score").innerHTML = snake.score
      soundHandle.play()
      g_place_food snake
    else
      snake.blocks.pop()
    renderSnake snake, context
    window.requestAnimFrame ->
      animate snake, context, canvas, time


  g_over = (snake, context, canvas) ->
    context.clearRect 0, 0, canvas.width, canvas.height
    document.getElementById("score").innerHTML = "Game over"

  g_place_food = (snake) ->
    x = undefined
    y = undefined
    x = snake.blocks[0].x
    y = snake.blocks[0].y
    while _block_in_snake(x, y, snake)
      x = parseInt(Math.floor(Math.random() * WIDTH))
      y = parseInt(Math.floor(Math.random() * HEIGHT))
    snake.food =
      x: x
      y: y

  g_place_food snake
  renderSnake snake, context
  setTimeout =>
    startTime = undefined
    startTime = (new Date()).getTime()
    animate snake, context, canvas, startTime
  , 500
