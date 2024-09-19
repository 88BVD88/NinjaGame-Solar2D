local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view


    local background = display.newImageRect(sceneGroup, "images/Mainbg.png", display.actualContentWidth, display.actualContentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY


    local title = display.newText(sceneGroup, "", display.contentCenterX, 100, native.systemFont, 54, bold)
    title:setFillColor(1, 1, 1)

  
    local buttonY = title.y + title.height + 20 


    local buttonWidth = 200
    local buttonHeight = 60


    local buttonBackground = display.newRoundedRect(sceneGroup, display.contentCenterX, buttonY, buttonWidth, buttonHeight, 12)
    buttonBackground:setFillColor(0.82, 0.71, 0.55)
    
    local playButtonText = display.newText(sceneGroup, "Play", display.contentCenterX, buttonY, native.systemFont, 32)
    playButtonText:setFillColor(1, 1, 1) 


    local function onPlayButtonTapped(event)
        composer.gotoScene("game") 
    end
    buttonBackground:addEventListener("tap", onPlayButtonTapped) 
end

scene:addEventListener("create", scene)

return scene
