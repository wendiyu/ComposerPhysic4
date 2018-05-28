-----------------------------------------------------------------------------------------
--
-- main.lua
-- Created by: Wendi Yu
-- Created on: May 2018
-- 
-- This file is create a game scene composer
-----------------------------------------------------------------------------------------
-- game scene

-- place all the require statements here
local composer = require( "composer" )
local physics = require("physics")
local json = require("json")
local tiled = require("com.ponywolf.ponytiled")

local scene = composer.newScene()
 
-- you need these to exist the entire scene
-- this is called "forward reference"
local map = nil
local knight = nil
local rightArrow = nil
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onRightArrowTouch( event )
    if (event.phase == "began") then
        if (knight.sequence ~= "run") then
            knight.sequence = "run"
            knight:setSequence("run")
            knight:play()
        end

    elseif (event.phase == "ended") then
        if (knight.sequence ~= "idle") then
            knight.sequence = "idle"
            knight:setSequence("idle")
            knight:play()
        end
    end
    return true
    
end

local moveKnight = function( event )
    
    if knight.sequence == "run" then
        transition.moveBy( knight, {
            x = 20,
            y = 0,
            time = 0
            })
    end
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- start physics
    physics.start()
    physics.setGravity(0, 32)
    --physics.setDrawMode("hybrid")
    -- get character
    local sheetOptionsIdle = require("assets.spritesheets.knight.knightIdle")
    local sheetIdleKnight = graphics.newImageSheet("./assets/spritesheets/knight/knightIdle.png", sheetOptionsIdle:getSheet() )

    local sheetOptionsRun = require("assets.spritesheets.knight.knightRun")
    local sheetRunningKnight = graphics.newImageSheet("./assets/spritesheets/knight/knightRun.png", sheetOptionsRun:getSheet() )

    local sequence_data_ninja = {
    -- consecutive frames sequence
    {
        name = "idle",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetIdleKnight
    }, 
    {
        name = "run",
        start = 1,
        count = 10,
        time = 1000,
        loopCount = 0,
        sheet = sheetRunningKnight
    }             
}
        knight = display.newSprite( sheetIdleKnight, sequence_data_ninja )
        knight.x = display.contentWidth * 0.5
        knight.y = 0
        knight.id = "knight"
        knight.sequence = "idle"
        -- add physics
        physics.addBody(knight, "dynamic", {
            density = 2.5,
            friction = 0.1,
            bounce = 0.2
            })
        knight.isFixedRotation = true -- If you apply this property before the physics.addBody() command for the object, it will merely be treated as a property of the object like any other custom property and, in that case, it will not cause any physical change in terms of locking rotation. 

        knight:setSequence( "idle" )
        knight:play()

        -- add right arrow
        rightArrow = display.newImage("./assets/sprites/rightButton.png")
        rightArrow.x = 268
        rightArrow.y = display.contentHeight - 150
        rightArrow.alpha = 0.5
        rightArrow.id = "right arrow"

        local filename = "assets/maps/level0.json" 
        local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
        map = tiled.new( mapData, "assets/maps" )

        sceneGroup:insert( map )
        sceneGroup:insert( knight )
        sceneGroup:insert( rightArrow )

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- add in code to check character movement
        rightArrow:addEventListener( "touch", onRightArrowTouch )
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener ( "enterFrame", moveKnight )
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener ( "enterFrame", moveKnight )
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
