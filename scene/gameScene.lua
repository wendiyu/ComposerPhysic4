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
local ninjaBoy = nil
local rightArrow = nil
local jumpButton = nil
local shootButton = nil
local playerKunais ={}
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onRightArrowTouch( event )
    if (event.phase == "began") then
        if (ninjaBoy.sequence ~= "run") then
            ninjaBoy.sequence = "run"
            ninjaBoy:setSequence("run")
            ninjaBoy:play()
        end

    elseif (event.phase == "ended") then
        if (ninjaBoy.sequence ~= "idle") then
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence("idle")
            ninjaBoy:play()
        end
    end
    return true
    
end

local function onJumpButtonTouch( event )
    if ( event.phase == "began" ) then
        if ninjaBoy.sequence ~= "jump" then
            -- make the character jump
            ninjaBoy:setLinearVelocity( 0, -750 )
            ninjaBoy.sequence = "jump"
            ninjaBoy:setSequence( "jump" )
            ninjaBoy:play()
        end

    elseif ( event.phase == "ended" ) then

    end
    return true
end

local moveNinja = function( event )
    
    if ninjaBoy.sequence == "run" then
        transition.moveBy( ninjaBoy, { 
            x = 10, 
            y = 0, 
            time = 0 
            } )
    end

    if ninjaBoy.sequence == "jump" then
        -- can also check if the NinjaBoy has landed from a jump
        local ninjaBoyVelocityX, ninjaBoyVelocityY = ninjaBoy:getLinearVelocity()
        
        if ninjaBoyVelocityY == 0 then
            -- the ninja is currently not jumping
            -- it was jumping so set to idle
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence( "idle" )
            ninjaBoy:play()
        end

    end
end 

local ninjaBoyThrow = function( event )
     -- after 1 second go back to idle
     ninjaBoy.sequence = "idle"
     ninjaBoy:setSequence( "idle" )
     ninjaBoy:play()
 end


local checkPlayerKunaisOutOfBounds = function ( event )
	-- check if any bullets have gone off the screen
	local kunaisCounter

    if #playerKunais > 0 then
        for kunaisCounter = #playerKunais, 1 ,-1 do
            if playerKunais[kunaisCounter].x > display.contentWidth *2 then
                playerKunais[kunaisCounter]:removeSelf()
                playerKunais[kunaisCounter] = nil
                table.remove(playerKunais, kunaisCounter)
                print("remove kunais")
            end
        end
    end
end

local function onshootButtonTouch( event )
    if ( event.phase == "began" ) then
        if (ninjaBoy.sequence ~= "throw") then
            ninjaBoy.sequence = "throw"
            ninjaBoy:setSequence("throw")
            ninjaBoy:play()
            timer.performWithDelay( 1000, ninjaBoyThrow )
   
        -- make a bullet appear
        local aSingleKunai = display.newImage( "./assets/sprites/Kunai.png" )
        aSingleKunai.x = ninjaBoy.x
        aSingleKunai.y = ninjaBoy.y 
        physics.addBody( aSingleKunai, 'dynamic' )
        -- Make the object a "bullet" type object
        aSingleKunai.isBullet = true
        aSingleKunai.isFixedRotation = true
        aSingleKunai.gravityScale = 0
        aSingleKunai.id = "bullet"
        aSingleKunai:setLinearVelocity( 1500, 0 )

        table.insert(playerKunais,aSingleKunai)
        print("# of bullet: " .. tostring(#playerKunais))
    end

  	elseif ( event.phase == "ended" ) then
  
  	end
    return true
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
    local sheetOptionsIdle = require("assets.spritesheets.ninjaBoy.ninjaBoyIdle")
    local sheetIdleNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyIdle.png", sheetOptionsIdle:getSheet() )

    local sheetOptionsRun = require("assets.spritesheets.ninjaBoy.ninjaBoyRun")
    local sheetRunningNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyRun.png", sheetOptionsRun:getSheet() )
 
    local sheetOptionsThrow = require("assets.spritesheets.ninjaBoy.ninjaBoyThrow")
    local sheetThrowNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyThrow.png", sheetOptionsThrow:getSheet() )
 
    local sheetOptionsJump = require("assets.spritesheets.ninjaBoy.ninjaBoyJump")
    local sheetJumpingNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyJump.png", sheetOptionsJump:getSheet() )

    local sequence_data_ninja = {
    -- consecutive frames sequence
    {
        name = "idle",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetIdleNinja
    }, 
    {
        name = "run",
        start = 1,
        count = 10,
        time = 1000,
        loopCount = 0,
        sheet = sheetRunningNinja
    },
    {
        name = "throw",
        start = 1,
        count = 10,
        time = 1000,
        loopCount = 1,
        sheet = sheetThrowNinja
    },
    {
        name = "jump",
        start = 1,
        count = 10,
        time = 1000,
        loopCount = 1,
        sheet = sheetJumpingNinja
    } 
}
        ninjaBoy = display.newSprite( sheetIdleNinja, sequence_data_ninja )
        ninjaBoy.x = display.contentWidth * 0.5
        ninjaBoy.y = 0
        ninjaBoy.id = "ninjaBoy"
        ninjaBoy.sequence = "idle"
        -- add physics
        physics.addBody(ninjaBoy, "dynamic", {
            density = 2.5,
            friction = 0.1,
            bounce = 0.2
            })
        ninjaBoy.isFixedRotation = true -- If you apply this property before the physics.addBody() command for the object, it will merely be treated as a property of the object like any other custom property and, in that case, it will not cause any physical change in terms of locking rotation. 

        ninjaBoy:setSequence( "idle" )
        ninjaBoy:play()

        -- add right arrow
        rightArrow = display.newImage("./assets/sprites/rightButton.png")
        rightArrow.x = 268
        rightArrow.y = display.contentHeight - 150
        rightArrow.alpha = 0.5
        rightArrow.id = "right arrow"
 
        jumpButton = display.newImage("./assets/sprites/jumpButton.png")
        jumpButton.x =  display.contentWidth - 250
        jumpButton.y = display.contentHeight - 80
        jumpButton.alpha = 0.5
        jumpButton.id = "jump Button"
 
        shootButton = display.newImage("./assets/sprites/jumpButton.png")
        shootButton.x =  display.contentWidth - 80
        shootButton.y = display.contentHeight - 80
        shootButton.alpha = 0.5
        shootButton.id = "shoot Button"
 
 

        local filename = "assets/maps/level0.json" 
        local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
        map = tiled.new( mapData, "assets/maps" )

        sceneGroup:insert( map )
        sceneGroup:insert( ninjaBoy )
        sceneGroup:insert( rightArrow )
        sceneGroup:insert( jumpButton )
        sceneGroup:insert( shootButton )

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- add in code to check character movement
        rightArrow:addEventListener( "touch", onRightArrowTouch )
        jumpButton:addEventListener( "touch", onJumpButtonTouch )
        shootButton:addEventListener( "touch", onshootButtonTouch )
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener ( "enterFrame", moveNinjaBoy )
        Runtime:addEventListener ( "enterFrame", checkPlayerKunaisOutOfBounds )
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        rightArrow:removeEventListener( "touch", onRightArrowTouch )
        jumpButton:removeEventListener( "touch", onJumpButtonTouch )
        shootButton:removeEventListener( "touch", onshootButtonTouch )
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener ( "enterFrame", moveNinjaBoy )
        Runtime:removeEventListener ( "enterFrame", checkPlayerKunaisOutOfBounds )
 
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
