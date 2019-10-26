local log =
  require "https://raw.githubusercontent.com/ccheever/castle-utils/c5a150bf783bfcaf24bbcf8cbe0824fae34a8198/log.lua"

local GAME_WIDTH = 192
local GAME_HEIGHT = 192
local car
local puffs
local raceTrackData

local carImage
local raceTrackImage
local engineSound
local crashSound

function love.load()
  log("loaded")

  -- Load assets
  carImage = love.graphics.newImage("./img/car.png")
  raceTrackImage = love.graphics.newImage("./img/race-track.png")
  --  carImage:setFilter('nearest', 'nearest')
  -- raceTrackImage:setFilter('nearest', 'nearest')
  engineSounds = {
    love.audio.newSource("sfx/engine1.wav", "static"),
    love.audio.newSource("sfx/engine2.wav", "static"),
    love.audio.newSource("sfx/engine3.wav", "static"),
    love.audio.newSource("sfx/engine4.wav", "static")
  }
  crashSound = love.audio.newSource("sfx/crash.wav", "static")

  log("Assets loaded:", carImage, raceTrackImage, engineSounds, crashSound)

  -- Load race track data from an image
  raceTrackData = love.image.newImageData("img/race-track-data.png")

  -- Create the car and an array for the puffs of exhaust
  puffs = {}
  car = createCar()
end

-- Creates the playable car
function createCar()
  return {
    x = 95,
    y = 28,
    bounceVelocityX = 0,
    bounceVelocityY = 0,
    speed = 0,
    rotation = math.pi / 2,
    engineNoiseTimer = 0.00,
    puffTimer = 0.00
  }
end

function love.draw()
  -- Draw the race track
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(raceTrackImage, 0, 0)

  -- Draw the car
  local radiansPerSprite = 2 * math.pi / 16
  local sprite = math.floor((car.rotation + radiansPerSprite / 2) / radiansPerSprite) + 1
  if car.rotation >= math.pi then
    sprite = 18 - sprite
  end
  drawSprite(carImage, 12, 12, sprite, car.x - 6, car.y - 6, car.rotation >= math.pi)

end

function drawSprite(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  local numColumns = math.floor(width / spriteWidth)
  local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
  love.graphics.draw(
    spriteSheetImage,
    love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
    x + spriteWidth / 2,
    y + spriteHeight / 2,
    rotation or 0,
    flipHorizontal and -1 or 1,
    flipVertical and -1 or 1,
    spriteWidth / 2,
    spriteHeight / 2
  )
end
