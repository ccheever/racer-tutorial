local drawSprite =
  require "https://raw.githubusercontent.com/ccheever/castle-utils/c35e540893e4ee0136d540f3e0ed4f13f840adb2/drawSprite.lua"
-- local log =
  -- require "https://raw.githubusercontent.com/ccheever/castle-utils/c5a150bf783bfcaf24bbcf8cbe0824fae34a8198/log.lua"

local car
local carImage
local raceTrackImage
local raceTrackData

function love.load()
  raceTrackImage = love.graphics.newImage("./race-track.png")
  raceTrackData = love.image.newImageData("./race-track-data.png")
  carImage = love.graphics.newImage("./car.png")

  car = createCar()
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(raceTrackImage, 0, 0)

  local radiansPerSprite = 2 * math.pi / 16
  local sprite = math.floor((car.rotation + radiansPerSprite / 2) / radiansPerSprite) + 1
  if car.rotation >= math.pi then
    sprite = 18 - sprite
  end
  drawSprite(carImage, 12, 12, sprite, car.x - 6, car.y - 6, car.rotation >= math.pi)
end

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

function love.update(dt)
  -- Turn the car by pressing the left and right keys
  local turnSpeed =
    3 * math.min(math.max(0, math.abs(car.speed) / 20), 1) - (car.speed > 20 and (car.speed - 20) / 20 or 0)
  if love.keyboard.isDown("left") then
    car.rotation = car.rotation - turnSpeed * dt
  end
  if love.keyboard.isDown("right") then
    car.rotation = car.rotation + turnSpeed * dt
  end
  car.rotation = (car.rotation + 2 * math.pi) % (2 * math.pi)

  if love.keyboard.isDown("down") then
    -- Press down to brake
    car.speed = math.max(car.speed - 20 * dt, -10)
  elseif love.keyboard.isDown("up") then
    -- Press up to accelerate
    car.speed = math.min(car.speed + 50 * dt, 40)
  else
    -- Slow down when not accelerating
    car.speed = car.speed * 0.98
  end

  -- Apply the car's velocity
  car.x = car.x + car.speed * -math.sin(car.rotation) * dt + car.bounceVelocityX * dt
  car.y = car.y + car.speed * math.cos(car.rotation) * dt + car.bounceVelocityY * dt

  -- Check what terrain the car is currently on by looking at the race track data image
  local pixelX = math.min(math.max(0, math.floor(car.x)), 191)
  local pixelY = math.min(math.max(0, math.floor(car.y)), 191)
  local r, g, b = raceTrackData:getPixel(pixelX, pixelY)
  local isInWall = r > 0 -- red = wall
  local isInGrass = b > 0 -- blue = grass

  -- If the car runs off the track, it slows down
  if isInGrass then
    car.speed = car.speed * 0.95
  end

  -- If the car becomes lodged in a barrier, bounce it away
  if isInWall then
    local vx = car.speed * -math.sin(car.rotation) + car.bounceVelocityX
    local vy = car.speed * math.cos(car.rotation) + car.bounceVelocityY
    car.bounceVelocityX = -2 * vx
    car.bounceVelocityY = -2 * vy
    car.speed = car.speed * 0.50
  end
  car.bounceVelocityX = car.bounceVelocityX * 0.90
  car.bounceVelocityY = car.bounceVelocityY * 0.90

  -- If the car ever gets out of bounds, reset it
  if car.x < 0 or car.y < 0 or car.x > 191 or car.y > 191 then
    car = createCar()
  end
end
