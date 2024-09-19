


local composer = require("composer")
local physics = require("physics")
physics.start()
local audio = require("audio")
local scene = composer.newScene()

-- Hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- Go to the menu scene
composer.gotoScene("menu")

-- Sound Area
local backgroundMusic = audio.loadStream("sounds/fightSong.wav")
local backgroundMusicChannel = audio.play(backgroundMusic, { loops = -1 })

local jumpSound = audio.loadSound("sounds/jump.wav")
local stepSound = audio.loadSound("sounds/knife.wav")
local explosion = audio.loadSound("sounds/explosion.wav")

audio.setVolume(0.3, { channel = backgroundMusicChannel })
audio.setVolume(0.5, { channel = stepSound })
audio.setVolume(0.3, { channel = jumpSound })

--                                             Grafix                                 ---
local background = display.newImageRect( "images/bg.png", display.actualContentWidth, display.actualContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background.id = "background"
background.rotation = 180


-- Girl
local girlConfig = {
    idle = { file = "images/Girl_Idle.png", isVisible = true },
    walk = { file = "images/Girl_walk.png", isVisible = false },
    walkToo = { file = "images/Girl_walk2.png", isVisible = false },
    glide = { file = "images/Girl_glide.png", isVisible = false },
    jump = { file = "images/Girl_jump.png", isVisible = false }
}

local girl = {}

for state, config in pairs(girlConfig) do
    girl[state] = display.newImageRect(config.file, 100, 120)
    girl[state].x = 395
    girl[state].y = 603
    girl[state].id = "girl"
    girl[state].isVisible = config.isVisible
end

-- Guy
local guyConfig = {
    idle = { file = "images/Guy_idle.png", isVisible = true },
    walk = { file = "images/Guy_walk.png", isVisible = false },
    glide = { file = "images/Guy_Glide.png", isVisible = false },
    jump = { file = "images/Guy_jump.png", isVisible = false }
}

local guy = {}

for state, config in pairs(guyConfig) do
    guy[state] = display.newImageRect(config.file, 100, 120)
    guy[state].xScale = -1
    guy[state].x = 700
    guy[state].y = 603
    guy[state].id = "guy"
    guy[state].isVisible = config.isVisible
end

-- Objects
local tree = display.newImageRect("images/Tree.png", 350, 450)
tree.x = 188
tree.y = 436
tree.id = "tree"

local skeleton = display.newImageRect("images/Skeleton.png", 60, 60)
skeleton.x = 550
skeleton.y = 629
skeleton.id = "skeleton"

local boschet = display.newImageRect("images/Boschet.png", 200, 200)
boschet.x = 900
boschet.y = 555

-- Platform
local platform = display.newImageRect("images/Platform.png", 700, 110)
platform.x = 540
platform.y = 710
platform.id = "platform"

local leftPlatform = display.newImageRect("images/LeftPlatform.png", 320, 110)
leftPlatform.x = 160
leftPlatform.y = 710
leftPlatform.id = "leftPlatform"

local rightPlatform = display.newImageRect("images/RightPlatform.png", 160, 110)
rightPlatform.x = 940
rightPlatform.y = 710
rightPlatform.id = "rightPlatform"

-- Projectile
local fireballConfig = {
    fireball = { file = "images/Fireball.png", x = 420, y = 615, isVisible = false },
    explosion = { file = "images/FireballExp.png", x = 420, y = 615, isVisible = false }
}

local fire = {}

for element, config in pairs(fireballConfig) do
    fire[element] = display.newImageRect(config.file, 100, 100)
    fire[element].x = config.x
    fire[element].y = config.y
    fire[element].id = element
    fire[element].isVisible = config.isVisible
end

local frostballConfig = {
    frostball = { file = "images/Frostball.png", x = 660, y = 615, isVisible = false },
    explosion = { file = "images/FireballExp.png", x = 820, y = 615, isVisible = false }
}

local frost = {}

for element, config in pairs(frostballConfig) do
    frost[element] = display.newImageRect(config.file, 100, 100)
    frost[element].x = config.x
    frost[element].y = config.y
    frost[element].id = element
    frost[element].isVisible = config.isVisible
end

-- Game Over
local gameOverText = display.newText("", 500, 200, native.systemFont, 66)
gameOverText:setFillColor(1, 0, 0)
gameOverText.isVisible = false

local countdown = 30
local countdownText = display.newText(countdown, 500, 100, native.systemFont, 66)
countdownText:setFillColor(1, 0, 0)

local function freezeGame()

    transition.cancel(girl["idle"])
    transition.cancel(girl["walk"])
    transition.cancel(girl["jump"])
    transition.cancel(guy["idle"])
    transition.cancel(guy["walk"])
    transition.cancel(guy["jump"])

    Runtime:removeEventListener("key", onKeyEvent)

    if countdownTimer then
        timer.cancel(countdownTimer)
        countdownTimer = nil
    end
end

local restartText = display.newText("Press Ctrl+R to Restart", 500, 260, native.systemFont, 36)
restartText:setFillColor(1, 1, 1) 
restartText.isVisible = false

local function updateCountdown()
    countdown = countdown - 1
    countdownText.text = countdown

    if countdown == 0 then
        countdownText.isVisible = false
        gameOverText.isVisible = true
        gameOverText.text = "Game Over"
        restartText.isVisible = true
        freezeGame()
    end
end

countdownTimer = timer.performWithDelay(1000, updateCountdown, 0)

-- Health Bar

local redHealth1 = display.newRect(0, 0, 300, 40)
redHealth1:setFillColor(1, 0, 0)
redHealth1.x = 200
redHealth1.y = 100

local redHealth2 = display.newRect(0, 0, 300, 40)
redHealth2:setFillColor(1, 0, 0)
redHealth2.x = 800
redHealth2.y = 100

local maxHealth = 300
local currentHealth = maxHealth

local healthGirl = display.newRect(0, 0, maxHealth, 40)
healthGirl:setFillColor(0, 1, 0)
healthGirl.x = 800
healthGirl.y = 100

local function updateHealthGirl()
    local healthRatio = currentHealth / maxHealth
    local newWidth = maxHealth * healthRatio
    healthGirl.width = newWidth

    if currentHealth <= 0 then
        gameOverText.isVisible = true
        gameOverText.text = "Guy Wins!"
        restartText.isVisible = true
        freezeGame()
    end
end

local maxHealthGuy = 300
local currentHealthGuy = maxHealthGuy

local healthGuy = display.newRect(0, 0, maxHealthGuy, 40)
healthGuy:setFillColor(0, 1, 0)
healthGuy.x = 200
healthGuy.y = 100

local function updateHealthGuy()
    local healthRatio = currentHealthGuy / maxHealthGuy
    local newWidth = maxHealthGuy * healthRatio
    healthGuy.width = newWidth

    if currentHealthGuy <= 0 then
        gameOverText.isVisible = true
        gameOverText.text = "Girl Wins!"
        restartText.isVisible = true
        freezeGame()
        
    end
end

-- Add physics to the girl guy, and platforms
physics.addBody(girl["idle"], "dynamic", { bounce = 0.0, friction = 0.7 })
physics.addBody(guy["idle"], "dynamic", { bounce = 0.0, friction = 0.7 })

-- Add physics to the platforms
physics.addBody(platform, "static", { bounce = 0.2, friction = 0.7 })
physics.addBody(leftPlatform, "static", { bounce = 0.2, friction = 0.7 })
physics.addBody(rightPlatform, "static", { bounce = 0.2, friction = 0.7 })


-- Stances Handler
local function setStanceVisibility(character, visibleStance)

    local currentX
    for stance, stanceObject in pairs(character) do
        if stanceObject.isVisible then
            currentX = stanceObject.x
            break
        end
    end

    for stance, stanceObject in pairs(character) do
        stanceObject.isVisible = false
    end

    character[visibleStance].isVisible = true
    if currentX then
        character[visibleStance].x = currentX
    end
end


-- Function to handle Movement and Shooting
local function onKeyEvent(event)
    local speedX = 35
    local jumpHeight = 350
    local groundLevelGirl = girl["idle"].y
    local groundLevelGuy = guy["idle"].y

    if (event.phase == "down") then
        if (event.keyName == "w") then
            audio.play(jumpSound)
            setStanceVisibility(girl, "jump")

            girl["jump"].x = girl["idle"].x
            transition.to(girl["jump"], {time=500, y=jumpHeight, onComplete=function()
                transition.to(girl["jump"], {time=500, y=groundLevelGirl, onComplete=function()
                    girl["jump"].isVisible = false
                    girl["idle"].isVisible = true
                    girl["idle"].x = girl["jump"].x
                end})
            end})
        elseif (event.keyName == "a") then
            audio.play(stepSound)
            girl["idle"].isVisible = false
            setStanceVisibility(girl, "walk")

            girl["walk"].x = girl["walk"].x - speedX
            girl["walkToo"].x = girl["walkToo"].x - speedX
            girl["walk"].xScale = -1
            girl["idle"].xScale = -1

        elseif (event.keyName == "d") then
            audio.play(stepSound)
            girl["idle"].isVisible = false
            setStanceVisibility(girl, "walk")

            girl["walk"].x = girl["walk"].x + speedX
            girl["walkToo"].x = girl["walkToo"].x + speedX
            girl["walk"].xScale = 1
            girl["idle"].xScale = 1


        elseif (event.keyName == "s") then
            fire["fireball"].x = girl["idle"].x
            fire["fireball"].isVisible = true
            -- Adjust targetX logic
            local targetX = guy["jump"].isVisible and 50 or math.min(guy["idle"].x, 1000)
            transition.to(fire["fireball"], {
                time = 1000, 
                x = targetX,
                onComplete = function()
                    fire["fireball"].isVisible = false
                    if not guy["jump"].isVisible then  
                        fire["explosion"].x = fire["fireball"].x
                        fire["explosion"].y = fire["fireball"].y
                        fire["explosion"].isVisible = true
                        audio.play(explosion)
                        timer.performWithDelay(500, function()
                            fire["explosion"].isVisible = false
                            fire["fireball"].x = girl["idle"].x
                            currentHealth = currentHealth - 60  
                            updateHealthGirl()
                        end)
                    end
                end
            })    

        elseif (event.keyName == "up") then
            audio.play(jumpSound)
            setStanceVisibility(guy, "jump")
            guy["jump"].x = guy["idle"].x
            transition.to(guy["jump"], {time=100, y=jumpHeight, onComplete=function()
                transition.to(guy["jump"], {time=1500, y=groundLevelGuy, onComplete=function()
                    guy["jump"].isVisible = false
                    guy["idle"].isVisible = true
                    guy["idle"].x = guy["jump"].x
                end})
            end})
        elseif (event.keyName == "left") then
            audio.play(stepSound)
            setStanceVisibility(guy, "walk")
            guy["walk"].x = guy["walk"].x - speedX
            guy["walk"].xScale = -1
            guy["idle"].xScale = -1
        elseif (event.keyName == "right") then
            audio.play(stepSound)
            setStanceVisibility(guy, "walk")
            guy["walk"].x = guy["walk"].x + speedX
            guy["walk"].xScale = 1
            guy["idle"].xScale = 1
        end
    elseif (event.phase == "up") then
        if (event.keyName == "a" or event.keyName == "d") then
            girl["idle"].isVisible = true
            girl["walk"].isVisible = false
            girl["walkToo"].isVisible = false
            girl["idle"].x = girl["walk"].x
        elseif (event.keyName == "left" or event.keyName == "right") then
            guy["idle"].isVisible = true
            guy["walk"].isVisible = false
            guy["idle"].x = guy["walk"].x

elseif (event.keyName == "down") then
    frost["frostball"].x = guy["idle"].x
    frost["frostball"].isVisible = true
    local targetX = girl["jump"].isVisible and 50 or math.max(girl["idle"].x, 100)
            transition.to(frost["frostball"], {
                time = 1000,
                x = targetX,
                onComplete = function()
                    frost["frostball"].isVisible = false
                    if not girl["jump"].isVisible then  
                        frost["explosion"].x = frost["frostball"].x
                        frost["explosion"].y = frost["frostball"].y
                        frost["explosion"].isVisible = true
                        audio.play(explosion)
                        timer.performWithDelay(500, function()
                            frost["explosion"].isVisible = false
                            frost["frostball"].x = guy["idle"].x
                            currentHealthGuy = currentHealthGuy - 60 
                            updateHealthGuy()
                        end)
                    end
                end
            })
        

        end
    end
    return false
end


-- Falling off the edge

local function checkForEdge()

    if (girl["idle"].x <= leftPlatform.x - (leftPlatform.width / 2)) or
       (girl["idle"].x >= rightPlatform.x + (rightPlatform.width / 2)) then
        setStanceVisibility(girl, "glide")
        gameOverText.isVisible = true
        gameOverText.text = "Game Over"
        restartText.isVisible = true
        freezeGame()
    end

    if (guy["idle"].x <= leftPlatform.x - (leftPlatform.width / 2)) or
       (guy["idle"].x >= rightPlatform.x + (rightPlatform.width / 2)) then
        setStanceVisibility(guy, "glide")
        gameOverText.isVisible = true
        gameOverText.text = "Game Over"
        restartText.isVisible = true
        freezeGame()
    end
end


timer.performWithDelay(100, checkForEdge, 0)
Runtime:addEventListener("key", onKeyEvent)
return scene