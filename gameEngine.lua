---------------------------------------------------------------------------------
-- gameEngine.lua
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Load external modules as required.
---------------------------------------------------------------------------------
local composer      = require( "composer" )
local scene         = composer.newScene()
local magnet        = require( "lib.magnet" )
local physics       = require( "physics" )
local widget        = require( "widget" )
local myGlobalData  = require( "lib.globalData" )
local loadsave      = require( "lib.loadsave" )
local levelData     = require( "gameLevelData" )
local adsConfig     = require( "adsLibrary" )

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed
-- ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Create a Randomseed value from the os.time()
---------------------------------------------------------------------------------
math.randomseed( os.time() )

---------------------------------------------------------------------------------
-- Game Variables
---------------------------------------------------------------------------------
local v = require( "gameVariables" )    -- Dynamic Game Variables
local c = require( "gameConfig" )       -- Game Specific Variables
---------------------------------------------------------------------------------
-- Note: We store all the game variables in a separate lua file / table.
-- Please see the [ gameVariables.lua ] file to edit the values accordingly
---------------------------------------------------------------------------------

--local playbackgroundMusic
local physicsBodyRemoved        = false

---------------------------------------------------------------------------------
-- Setup scene Groups
---------------------------------------------------------------------------------
local groupScore                = display.newGroup()
local groupEnvironment          = display.newGroup()
local groupBackgounds           = display.newGroup()
local groupNextLevelButtons     = display.newGroup()
local groupStartLevelButton     = display.newGroup()
local groupGameCompleteButton   = display.newGroup()
local groupRateAppButton        = display.newGroup()
local groupShareButton          = display.newGroup()



---------------------------------------------------------------------------------
-- Setup Physics world
---------------------------------------------------------------------------------
--physics.setDrawMode( "hybrid" )  -- Overlays collision outlines on normal display objects
--physics.setDrawMode( "normal" )  -- The default Corona renderer, with no collision outlines
--physics.setDrawMode( "debug" )   -- Shows collision engine outlines only
physics.setScale( 30 )
physics.setVelocityIterations( 16 )
physics.setPositionIterations( 6 )
physics.start()
physics.setGravity( 0, 40 )



---------------------------------------------------------------------------------
-- Convert RGB Values to Coronas method
---------------------------------------------------------------------------------
local function getRGB(value)
    return value/255
end

---------------------------------------------------------------------------------
-- Convert HEX Colour Values to Coronas method
---------------------------------------------------------------------------------
local function hex2rgb (hex)
    local hex = hex:gsub("#","")
    local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    return r/255, g/255, b/255
end


---------------------------------------------------------------------------------
-- Start scene setup
-- "scene:create()"
---------------------------------------------------------------------------------
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

        -- Remove any previous Composer Scenes
        composer.removeScene( "gameMenu" )
        composer.removeScene( "gameReset" )

end



---------------------------------------------------------------------------------
-- Start scene setup
-- "scene:show()"
---------------------------------------------------------------------------------
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase


    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    

        ---------------------------------------------------------------------------------
        -- Insert the various game groups into the core SCENE GROUP (Ordered)
        ---------------------------------------------------------------------------------
        sceneGroup:insert( groupBackgounds )
        sceneGroup:insert( groupScore )
        sceneGroup:insert( groupEnvironment )
        sceneGroup:insert( groupNextLevelButtons )

        --Sub GUI Groups for buttons etc
        groupNextLevelButtons:insert( groupStartLevelButton )
        groupNextLevelButtons:insert( groupRateAppButton )
        groupNextLevelButtons:insert( groupShareButton )
        groupNextLevelButtons:insert( groupGameCompleteButton )



        ---------------------------------------------------------------------------------
        -- Drop player
        ---------------------------------------------------------------------------------
        local function dropPlayer()

            --Increment the [ totalAttempts ] variable
            myGlobalData.totalAttempts = myGlobalData.totalAttempts + 1  --Increment the total Drop counter by 1

            --Clean up audio
            if(c.audioSFXHandeButtonTap ~= nil) then
                audio.stop(c.audioSFXHandeButtonTap)
                c.audioSFXHandeButtonTap = nil
            end
            if(c.audioSFXHandeLevelUp ~= nil) then
                audio.stop(c.audioSFXHandeLevelUp)
                c.audioSFXHandeLevelUp = nil
            end
            if(c.audioSFXHandePerfect ~= nil) then
                audio.stop(c.audioSFXHandePerfect)
                c.audioSFXHandePerfect = nil
            end


            ---------------------------------------------------------------------------------
            -- Add Physics body and collision listeners to the player.
            ---------------------------------------------------------------------------------
            function AddPhysicsBody()

                -- Set player angle to ZERO - ready for the drop
                c.playerSquare.rotation = 0

                --Remove the touch event from the background to stop player growing again
                c.backgroundBlock:removeEventListener( "touch", handleGrow)

                --If cheat mode enabled, the square will automatically be perfect!
                if(c.enableCheatMode==true) then
                    c.playerSquare.width      = c.perfectSize
                    c.playerSquare.height     = c.perfectSize
                end

                -- Fix the square if it's 1 pixel too big to be perfect (Very important!)
                if( c.playerSquare.width == c.perfectSize+1) then
                    c.playerSquare.width = c.playerSquare.width+1
                    c.playerSquare.height = c.playerSquare.height+1
                    c.playerSquare.x      = myGlobalData._cdw
                end

                -- Fix the square if it's Exactly the same size as the Fall through Gap
                -- If it is, we'll make it a safe landing.
                if (c.playerSquare.width == c.fallThroughSize) or
                    (c.playerSquare.width-1 == c.fallThroughSize) or
                    (c.playerSquare.width+1 == c.fallThroughSize) then

                    c.playerSquare.width = c.fallThroughSize+2
                    c.playerSquare.height = c.fallThroughSize+2
                    c.playerSquare.x      = myGlobalData._cdw
                end



                physics.addBody( c.playerSquare, "dynamic", { density=100.0, friction=0.0, bounce=0.0 } )
                c.playerSquare.myName = "Player"
                c.playerSquare.isFixedRotation = true
                c.playerSquare.x = myGlobalData._cw

                --Play Drop Sound
                c.audioSFXHandeDrop = audio.play(myGlobalData.sfx_Drop)

                print("Users Block Size = "..c.playerSquare.width)
                if (c.playerSquare.width == c.perfectSize) then
                    c.playerSizePerfect = true
                    print("Users Block Size IS Perfect!")
                else
                    c.playerSizePerfect = false
                    print("Users Block Size is NOT Perfect..")
                end


            end


            c.playerAngle = c.playerSquare.rotation
            print("player dropped: "..c.playerAngle )
            c.playerIsDropping = true
            transition.cancel( "rotatePlayer")
            timer.cancel( c.rotateTimer )
            local backToZeroTime = c.RotateNormalise + math.abs(c.playerAngle)
            transition.to( c.playerSquare, { tag="rotateToZero", time=backToZeroTime, rotation=0, transition=easing.inOutSine, onComplete=AddPhysicsBody } )
            transition.to( c.dropCounterText, { tag="rotateToZero", time=backToZeroTime, rotation=0, transition=easing.inOutSine } )
        end

        ---------------------------------------------------------------------------------
        -- Rotate the player
        ---------------------------------------------------------------------------------
        local function rotatePlayer()
            --Rotate the Player (Block)
            transition.to( c.playerSquare, { tag="rotatePlayer", time=v.playerRotateSpeed, rotation=-v.playerRotateMax, transition=easing.inOutSine } )
            transition.to( c.playerSquare, { tag="rotatePlayer", delay=v.playerRotateSpeed, time=v.playerRotateSpeed, rotation=v.playerRotateMax, transition = easing.inOutSine } )
            
            --Rotate the Drop Number inline with the Player (Block)
            transition.to( c.dropCounterText, { tag="rotatePlayer", time=v.playerRotateSpeed, rotation=-v.playerRotateMax, transition=easing.inOutSine } )
            transition.to( c.dropCounterText, { tag="rotatePlayer", delay=v.playerRotateSpeed, time=v.playerRotateSpeed, rotation=v.playerRotateMax, transition = easing.inOutSine } )
        end

        ---------------------------------------------------------------------------------
        -- Grow the player on Touch
        ---------------------------------------------------------------------------------
        function handleGrow( event )

            if( c.playerLanded == false ) then

                if (c.playerIsDropping==false) then
                    if ( event.phase == "began" ) then
                        
                        -- Start growing
                        c.playerGrow = true

                        --If this is the 1st touch - then hide the initial guide box.
                        if (c.guideBoxShow == true) then
                            c.guideBoxShow = false
                            transition.to( c.guideBox, { delay=10, tag="fadeInfoBox", time=450, alpha=0.0 } )
                            transition.to( c.guideText, { delay=10, tag="fadeInfoBox", time=450, alpha=0.0 } )
                            transition.to( c.info1, { delay=10, tag="fadeInfoBox", time=450, y=-20, alpha=0.0 } )
                            transition.to( c.info2, { delay=10, tag="fadeInfoBox", time=450, y=-20, alpha=0.0 } )
                        end

                    elseif ( event.phase == "ended" and c.playerGrow == true ) then
                        -- Stop growing
                        c.playerGrow = false
                        dropPlayer()

                    --elseif ( event.phase == "moved" and c.playerGrow == true ) then
                        -- Stop growing
                        --c.playerGrow = false

                    end
                end
                return true
            end
        end


        ---------------------------------------------------------------------------------
        -- Create Background Block / Colour
        ---------------------------------------------------------------------------------
         local backgroundPaint = {
            type = "gradient",
                color1 = levelData.levelBackground_Top[c.currentLevel],
                color2 = levelData.levelBackground_Bot[c.currentLevel],
            direction = "down"
        }

        c.backgroundBlock = display.newRect( 0, 0, myGlobalData._w, myGlobalData._h)
        c.backgroundBlock.fill = backgroundPaint
        c.backgroundBlock.x = myGlobalData._cdw
        c.backgroundBlock.y = myGlobalData._cdh
        c.backgroundBlock.alpha = 1.0
        groupBackgounds:insert( c.backgroundBlock )

        ---------------------------------------------------------------------------------
        -- Create Background Fail Colour (Hidden until needed)
        ---------------------------------------------------------------------------------
        local backgroundPaintFail = {
            type = "gradient",
            color1 = levelData.backgroundFailColour_Top,
            color2 = levelData.backgroundFailColour_Bot,
            direction = "down"
        }
        c.backgroundBlockFail = display.newRect( 0, 0, myGlobalData._w, myGlobalData._h)
        c.backgroundBlockFail.fill = backgroundPaintFail
        c.backgroundBlockFail.x = myGlobalData._cdw
        c.backgroundBlockFail.y = myGlobalData._cdh
        c.backgroundBlockFail.alpha = 0.0
        groupBackgounds:insert( c.backgroundBlockFail )

        ---------------------------------------------------------------------------------
        -- Apply te background overlay effect
        ---------------------------------------------------------------------------------
        if ( v.backgroundGameEffect ) then
            local bgEffect     = display.newImageRect( myGlobalData.imagePath..v.backgroundGameEffectFile, 384,568 )
            bgEffect.x         = myGlobalData._cdw
            bgEffect.y         = myGlobalData._cdh
            bgEffect.alpha     = v.backgroundGameEffectAlpha
            groupBackgounds:insert( bgEffect )
        end



        local function cleanEngineStop()
            transition.cancel()
            transition.cancel( "rotatePlayer")
            timer.cancel( c.rotateTimer )

            c.playerLanded        = true
            c.levelComplete       = false
            c.backgroundBlock:removeEventListener( "touch", handleGrow) --Remove touch listener to the play background
            c.playerGrow          = false  -- Reset Game Params
            c.playerIsDropping    = false  -- Reset Game Params
            c.hazardHit           = false  -- Reset Game Params
            c.guideBoxShow        = false  -- Reset Game Params

             -- Remove the physics shape from the Player
            if not ( physicsBodyRemoved ) then
                physics.removeBody( c.playerSquare )
                physicsBodyRemoved = true 
            end

        end

        ---------------------------------------------------------------------------------
        -- Handle the BACK TO MENU button
        ---------------------------------------------------------------------------------
        local function backToMenu()

            -- Clean up the engine before a full stop/reset
            cleanEngineStop()


            ---------------------------------------------------------------------------------
            -- If Ads are enabled - Play a VUNGLE or ADMOB Interstitial Ad
            ---------------------------------------------------------------------------------
            if ( myGlobalData.adsShow ) then
                local randomAd = math.random( 1,6 )
                if ( randomAd > 5 ) then -- If Greater than 4 we show the Vungle Ad
                    print("Ad Numer > 5 - Preparing Vungle Ad")
                    -- Show the Vungle Interstitial Ad
                    if ( myGlobalData.ads_VungleEnabled ) then
                        adsConfig.showVungleInterstitialAd()
                    end
                else
                    print("Ad Numer < 5 - Preparing Admob Ad")
                    -- Show the AdMob Interstitial Ad
                    if ( myGlobalData.ads_AdMobEnabled ) then
                        if ( myGlobalData.adIntersRequired ) then
                            adsConfig.showAdmobInterstitialAd()
                        end
                    end
                end
            end
            

            local function backToMenuFunction()
                composer.gotoScene( "gameMenu") --This is our main menu
            end
            -- Start game engine after short delay
            local endGameTimer = timer.performWithDelay(400, backToMenuFunction )

        end


        local function userLevelReset()

            -- Clean up the engine before a full stop/reset
            cleanEngineStop()

            local function resetCurrentLevelFunction()
                composer.gotoScene( "gameReset") --This is our main menu
            end
            -- Start game engine after short delay
            local endGameTimer = timer.performWithDelay(200, resetCurrentLevelFunction )

        end

       -- Handler that gets notified when the alert closes
        local function onComplete( event )
            if ( event.action == "clicked" ) then
                local i = event.index
                if ( i == 1 ) then
                    -- Quit back to Menu
                    backToMenu()
                elseif ( i == 2 ) then
                    -- Reset the Level
                    userLevelReset()
                elseif ( i == 3 ) then
                    -- Do nothing; dialog will simply dismiss
                end
            end
        end

        ---------------------------------------------------------------------------------
        -- Level select and start Events
        ---------------------------------------------------------------------------------
        local function configButton( event )
            local buttonName = event.target.id
            if ( event.phase == "began" and buttonClicked == false ) then
                print( "Touch event began on: " .. buttonName )
                --buttonClicked = true -- disable the button for fast clicky users !

            elseif ( event.phase == "ended" ) then

                print( "Touch event ended on: " .. buttonName )
                audioSFXHandeButtonTap = audio.play(myGlobalData.sfx_Click)

                if ( buttonName == "config" ) then
                    -- Show alert with 3 buttons
                    local alert = native.showAlert( v.buttonCongigMessageTitle, v.buttonCongigMessage, { v.buttonCongigMessageQuit, v.buttonCongigMessageReset, v.buttonCongigMessageCancel }, onComplete )
                end

            end
            return true
        end

        ---------------------------------------------------------------------------------
        -- Config / Options button
        ---------------------------------------------------------------------------------
        c.buttonConfigure = widget.newButton(
            {
                --label         = "button",
                onEvent         = configButton,
                defaultFile     = myGlobalData.imagePath..v.buttonConfigOffImageFile,
                overFile        = myGlobalData.imagePath..v.buttonConfigOnImageFile,
                width           = v.buttonConfigWidth,
                height          = v.buttonConfigHeight,
                id              = "config"
            }
        )
        c.buttonConfigure.anchorX  = 1
        c.buttonConfigure.anchorY  = 0
        c.buttonConfigure.x        = myGlobalData._w - 10
        c.buttonConfigure.y        = 8
        if ( myGlobalData.bannerAd_Game_Adjustment > 1 ) then
            c.buttonConfigure.y    = myGlobalData.bannerAd_Game_Adjustment
        end
        c.buttonConfigure.alpha    = v.buttonConfigAlpha
        groupBackgounds:insert( c.buttonConfigure )




        ---------------------------------------------------------------------------------
        -- Info, Music on/off, SFX On/Off button Handler
        ---------------------------------------------------------------------------------
        local offsetButtonsX    = 5000  -- How far to push the buttons off screen when hidden
        local triggerDelay      = 50    -- Delay before triggering button events
        local function showInfoPanel()
            local alert = native.showAlert( v.gameTitleText, v.aboutAppDescription, { v.aboutAppCloseButton } )
        end

        local function updateMusicStatus()
            ------------------------------------------------------------------------------
            -- Music listener only triggered if music enabled for this scene.
            ------------------------------------------------------------------------------
            print(" ***** updateMusicStatus" )
            if ( v.musicPlayGameScreen ) then
              print(" ***** musicPlayGameScreen" )

                local isChannel2Paused  = audio.isChannelPaused( 2 )
                local isChannel2Playing = audio.isChannelPlaying( 2 )

                if ( myGlobalData.soundMusicOn == false ) then
                    print(" ***** myGlobalData.soundMusicOn == false" )
                    c.buttonMusic.x       = offsetButtonsX    -- Move off screen
                    c.buttonMusicOff.x    = c.buttonMusic_x     -- Restore position
                    if ( isChannel2Playing ) then
                        audio.pause( c.playbackgroundMusic )
                        print(" ***** audio.pause( c.playbackgroundMusic )" )
                    end

                else
                    print(" ***** myGlobalData.soundMusicOn == true" )
                    c.buttonMusic.x       = c.buttonMusic_x     -- Restore position                
                    c.buttonMusicOff.x    = offsetButtonsX    -- Move off screen
                    if ( isChannel2Paused ) then
                        audio.resume( c.playbackgroundMusic )
                        print(" ***** audio.resume( c.playbackgroundMusic )" )
                    end
                end
            end

        end

        local function updateSFXStatus()
            if ( myGlobalData.soundSFXOn == false ) then
                c.buttonSFX.x       = offsetButtonsX    -- Move off screen
                c.buttonSFXOff.x    = c.buttonSFX_x     -- Restore position

                for i = 4, 32 do
                    audio.setVolume( 0, { channel=i } )
                end                 
                myGlobalData.volumeSFX = 0

                print("SFX Volumes at 0")
            else
                c.buttonSFX.x       = c.buttonSFX_x     -- Restore position                
                c.buttonSFXOff.x    = offsetButtonsX    -- Move off screen

                for i = 4, 32 do
                    audio.setVolume( myGlobalData.resetVolumeSFX, { channel=i } )
                end                 
                print("SFX Volumes at "..myGlobalData.resetVolumeSFX)

            end
            print("soundSFXOn = "..tostring(myGlobalData.soundSFXOn) )

        end


        local function onGUIGameButtonsTouch( event )
            local buttonName = event.target.id
            if ( event.phase == "began"  ) then
                print("Button: "..buttonName.."  |  Event: "..event.phase)

            elseif ( event.phase == "ended" ) then
                print("Button: "..buttonName.."  |  Event: "..event.phase)

                audioSFXHandeButtonTap = audio.play(myGlobalData.sfx_Click)

                if ( buttonName == "info" ) then
                    showInfoPanel()
                end

                if ( buttonName == "musicOn" ) then
                    myGlobalData.soundMusicOn = false
                    local timer = timer.performWithDelay( triggerDelay, updateMusicStatus )
                end
                if ( buttonName == "musicOff" ) then
                    myGlobalData.soundMusicOn = true
                    local timer = timer.performWithDelay( triggerDelay, updateMusicStatus )
                end

                if ( buttonName == "sfxOn" ) then
                    myGlobalData.soundSFXOn = false
                    local timer = timer.performWithDelay( triggerDelay, updateSFXStatus )
                end
                if ( buttonName == "sfxOff" ) then
                    myGlobalData.soundSFXOn = true
                    local timer = timer.performWithDelay( triggerDelay, updateSFXStatus )
                end

            end
            return true
        end
        ---------------------------------------------------------------------------------

        ---------------------------------------------------------------------------------
        -- SFX ON/OFF Button (Create the ON and OFF state x 2)
        ---------------------------------------------------------------------------------
        c.buttonSFX = widget.newButton( { onEvent  = onGUIGameButtonsTouch,
              defaultFile   = myGlobalData.imagePath..v.buttonSFXPlayOffImageFile,
              overFile      = myGlobalData.imagePath..v.buttonSFXPlayOnImageFile,
              width         = v.buttonSFXPlayWidth, height = v.buttonSFXPlayHeight, id  = "sfxOn" } )
        c.buttonSFX.anchorY   = 0
        c.buttonSFX.x         = v.buttonSFXPlayWidth
        c.buttonSFX.y         = c.buttonConfigure.y-- myGlobalData._cdh - 230
        c.buttonSFX.alpha     = v.buttonSFXPlayAlpha
        c.buttonSFX_x         = c.buttonSFX.x ; c.buttonSFX_y = c.buttonSFX.y
        groupBackgounds:insert( c.buttonSFX )
        ---------------------------------------------------------------------------------
        c.buttonSFXOff = widget.newButton( { onEvent  = onGUIGameButtonsTouch,
              defaultFile       = myGlobalData.imagePath..v.buttonSFXStopOffImageFile,
              overFile          = myGlobalData.imagePath..v.buttonSFXStopOnImageFile,
              width             = v.buttonSFXStopWidth, height = v.buttonSFXStopHeight, id  = "sfxOff" } )
        c.buttonSFXOff.anchorY    = 0
        c.buttonSFXOff.x          = offsetButtonsX
        c.buttonSFXOff.y          = c.buttonSFX.y
        c.buttonSFXOff.alpha      = v.buttonSFXStopAlpha
        groupBackgounds:insert( c.buttonSFXOff )
        ---------------------------------------------------------------------------------
        -- MUSIC ON/OFF Button (Create the ON and OFF state x 2)
        ---------------------------------------------------------------------------------
        if ( v.musicPlayGameScreen ) then
            c.buttonMusic = widget.newButton( { onEvent = onGUIGameButtonsTouch,
                  defaultFile     = myGlobalData.imagePath..v.buttonMusicPlayOffImageFile,
                  overFile        = myGlobalData.imagePath..v.buttonMusicPlayOnImageFile,
                  width           = v.buttonMusicPlayWidth, height = v.buttonMusicPlayHeight, id  = "musicOn" } )
            c.buttonMusic.anchorY   = 0
            c.buttonMusic.x         = c.buttonSFX.x
            c.buttonMusic.y         = c.buttonSFX.y + v.buttonMusicPlayHeight + 10
            c.buttonMusic.alpha     = v.buttonMusicPlayAlpha
            c.buttonMusic_x         = c.buttonMusic.x ; c.buttonMusic_y = c.buttonMusic.y
            groupBackgounds:insert( c.buttonMusic )
            ---------------------------------------------------------------------------------
            c.buttonMusicOff = widget.newButton( { onEvent = onGUIGameButtonsTouch,
                  defaultFile      = myGlobalData.imagePath..v.buttonMusicStopOffImageFile,
                  overFile         = myGlobalData.imagePath..v.buttonMusicStopOnImageFile,
                  width            = v.buttonMusicStopWidth, height = v.buttonMusicStopHeight, id  = "musicOff" } )
            c.buttonMusicOff.anchorY = 0
            c.buttonMusicOff.x       = offsetButtonsX
            c.buttonMusicOff.y       = c.buttonMusic.y
            c.buttonMusicOff.alpha   = v.buttonMusicStopAlpha
            groupBackgounds:insert( c.buttonMusicOff )
        end
        ---------------------------------------------------------------------------------



        ---------------------------------------------------------------------------------
        -- Start Game Screen MUSIC playing if enabled.
        ---------------------------------------------------------------------------------
        if ( v.musicPlayGameScreen) then
                c.playbackgroundMusic = audio.play( myGlobalData.music_Game, { channel=2, loops=-1, fadein=v.musicFadeinGameScreen } )            
            if ( myGlobalData.soundMusicOn == false ) then
                audio.pause( c.playbackgroundMusic ) -- instantly pause the music if the user has turned it off.
            end
        end

        ---------------------------------------------------------------------------------
        -- Manually trigger the buttons refresh status based on the globally stored data
        ---------------------------------------------------------------------------------
        updateMusicStatus()
        updateSFXStatus()
        print("Dione....")





        ---------------------------------------------------------------------------------
        -- Add GUI  |  Perfect Squares Info, Level etc..
        ---------------------------------------------------------------------------------
        c.info1 = display.newText( v.instructionsTextLine1, 0,0, v.instructionsFontLine1, v.instructionsFontSizeLine1 )
        c.info1.x = myGlobalData._cdw
        c.info1.y = myGlobalData._cdh - 30 + (-myGlobalData.bannerAd_Game_Adjustment/3)
        c.info1.align = "center"
        if(c.levelFirstPlay==true) then
            c.info1.fill    = v.instructionsFontColourLine1
        else
            c.info1.fill    = v.instructionsFontColourLine1
            c.info1.alpha   = 0.0
        end

        groupBackgounds:insert( c.info1 )

        c.info2 = display.newText( v.instructionsTextLine2, 0,0, v.instructionsFontLine2, v.instructionsFontSizeLine2 )
        c.info2.x = myGlobalData._cdw
        c.info2.y = myGlobalData._cdh - 6 + (-myGlobalData.bannerAd_Game_Adjustment/3)
        c.info2.align = "center"
        if(c.levelFirstPlay==true) then
            c.info2.fill    = v.instructionsFontColourLine2
        else
            c.info2.fill    = v.instructionsFontColourLine2
            c.info2.alpha   = 0.0
        end
        groupBackgounds:insert( c.info2 )



        ---------------------------------------------------------------------------------
        -- Add GUI  |  Perfect Squares Info, Level etc..
        ---------------------------------------------------------------------------------
        c.infoPerfectSquares            = display.newText( v.perfectDropsText.." ".. c.perfectSquaresReached, 0,0, v.perfectDropsTextFont, v.perfectDropsTextFontSize )
        c.infoPerfectSquares.x          = myGlobalData._cdw
        c.infoPerfectSquares.y          = 10 + myGlobalData.bannerAd_Game_Adjustment
        c.infoPerfectSquares.align      = "center"
        c.infoPerfectSquares.fill       = v.perfectDropsTextColour

        groupBackgounds:insert( c.infoPerfectSquares )

        c.levelWord                     = display.newText( v.levelInfoText, 0,0, v.levelInfoTextFont, v.levelInfoTextFontSize )
        c.levelWord.x                   = myGlobalData._cdw
        c.levelWord.y                   = c.infoPerfectSquares.y+20
        c.levelWord.align               = "center"
        c.levelWord.fill                = v.levelInfoTextColour
        groupBackgounds:insert( c.levelWord )

        c.infoCurrentLevel              = display.newText( c.currentLevel, 0,0, v.levelCurrentTextFont, v.levelCurrentTextFontSize )
        c.infoCurrentLevel.x            = myGlobalData._cdw
        c.infoCurrentLevel.y            = c.levelWord.y + 50
        c.infoCurrentLevel.align        = "center"
        c.infoCurrentLevel.fill         = v.levelCurrentTextColour
        c.infoCurrentLevel.alpha        = v.levelCurrentTextFontAlpha
        groupBackgounds:insert( c.infoCurrentLevel )


        ---------------------------------------------------------------------------------
        -- Add GUI  |  Level Completed Display
        ---------------------------------------------------------------------------------
        c.levelCompletedMessage         = display.newText( v.levelCompletedText, 0,0, v.levelCompletedTextFont, v.levelCompletedTextFontSize )
        c.levelCompletedMessage.x       = myGlobalData._cdw
        c.levelCompletedMessage.y       = -50
        c.levelCompletedMessage.align   = "center"
        c.levelCompletedMessage.fill    = v.levelCompletedTextColour
        sceneGroup:insert( c.levelCompletedMessage )


        ---------------------------------------------------------------------------------
        -- Add GUI  |  Start Level, Rate, Share Buttons etc
        ---------------------------------------------------------------------------------
        local function startNextLevel()
           
             --Move Screen GUI objects back to their starting positions
            transition.to( c.infoCurrentLevel, { tag="levelSlide", time=500, y=c.infoCurrentLevel.y-60, xScale=1.0, yScale=1.0, onComplete=celebrate } )
            transition.to( c.levelWord, { tag="levelSlide", time=500, y=c.levelWord.y-45, xScale=1.0, yScale=1.0 } )
            transition.to( c.levelCompletedMessage, { tag="levelSlide", time=350, y=-myGlobalData._h - 40 } )
            transition.to( groupStartLevelButton, { tag="levelSlide", time=850, y=myGlobalData._h + 100, transition=easing.inOutBack } )

            c.infoCurrentLevel.fill         = v.levelCurrentTextColour
            c.infoCurrentLevel.alpha        = v.levelCurrentTextFontAlpha
            c.levelWord.fill                = v.levelInfoTextColour

            c.levelComplete = false
            c.playerLanded = false
            c.playerIsDropping = false
            c.guideBoxShow = true

            ---------------------------------------------------------------------------------
            -- Update the Background colour for the next level
            ---------------------------------------------------------------------------------
             local backgroundPaint = {
                type = "gradient",
                color1 = levelData.levelBackground_Top[c.currentLevel],
                color2 = levelData.levelBackground_Bot[c.currentLevel],
                direction = "down"
            }
            c.backgroundBlock.fill = backgroundPaint


            resetLevel()

        end

        ---------------------------------------------------------------------------------
        -- Add GUI  |  Start Level, Rate, Share Buttons etc
        ---------------------------------------------------------------------------------
        local function onButtonTouch( event )
            local buttonName = event.target.id
            if ( event.phase == "began" ) then
                print( "Touch event began on: " .. buttonName )
            elseif ( event.phase == "ended" ) then
                print( "Touch event ended on: " .. buttonName )

                if ( buttonName == "nextLevel" and c.levelComplete==true) then
                    print("Next level starting")
                    c.levelComplete = false
                    --Start the next level playing
                    startNextLevel()
                    --Play button click sound
                    c.audioSFXHandeButtonTap = audio.play(myGlobalData.sfx_Click)
                end

                if ( buttonName == "completedGame" and c.levelComplete==true) then
                    print("Game Completed button pressed: Back to menu..")
                    c.levelComplete = false
                    --Go back to the menu screen - game is completed !
                    backToMenu()
                    --Play button click sound
                    c.audioSFXHandeButtonTap = audio.play(myGlobalData.sfx_Click)
                end

            end
            return true
        end


        ---------------------------------------------------------------------------------
        -- Start next level
        ---------------------------------------------------------------------------------
        local buttonBaseStartLevel = widget.newButton(
            {
                --label         = "button",
                onEvent         = onButtonTouch,
                emboss          = v.buttonNewLevelShapeEmboss,
                shape           = v.buttonNewLevelShape,
                width           = v.buttonNewLevelShapeWidth,
                height          = v.buttonNewLevelShapeHeight,
                cornerRadius    = v.buttonNewLevelShapeCornerRadius,
                id              = "nextLevel",
                fillColor       = { default = v.buttonNewLevelFillColour,   over=v.buttonNewLevelFillColourOver },
                strokeColor     = { default = v.buttonNewLevelStrokeColour, over=v.buttonNewLevelStrokeColourOver },
                strokeWidth     = v.buttonNewLevelStrokeWidth
            }
        )
        buttonBaseStartLevel.x              = myGlobalData._cdw
        buttonBaseStartLevel.y              = myGlobalData._cdh + 50
        groupStartLevelButton:insert( buttonBaseStartLevel )

        local buttonArtStartLevelVertices   = { 0,0, 20,12, 0,24 }
        local buttonArtStartLevel           = display.newPolygon( buttonBaseStartLevel.x, buttonBaseStartLevel.y, buttonArtStartLevelVertices )
        buttonArtStartLevel.fill            = v.buttonNewLevelIconColour
        groupStartLevelButton:insert( buttonArtStartLevel )

        --Move the groupStartLevelButton GROUP offscreen
        groupStartLevelButton.y = myGlobalData._h + 100
        ---------------------------------------------------------------------------------


        ---------------------------------------------------------------------------------
        -- Game Completed Button setup
        ---------------------------------------------------------------------------------
        local buttonBaseCompleteLevel = widget.newButton(
            {
                --label         = "button",
                onEvent         = onButtonTouch,
                emboss          = v.buttonNewLevelShapeEmboss,
                shape           = v.buttonNewLevelShape,
                width           = v.buttonNewLevelShapeWidth,
                height          = v.buttonNewLevelShapeHeight,
                cornerRadius    = v.buttonNewLevelShapeCornerRadius,
                id              = "completedGame",
                fillColor       = { default = v.buttonNewLevelFillColour,   over=v.buttonNewLevelFillColourOver },
                strokeColor     = { default = v.buttonNewLevelStrokeColour, over=v.buttonNewLevelStrokeColourOver },
                strokeWidth     = v.buttonNewLevelStrokeWidth
            }
        )
        buttonBaseCompleteLevel.x              = myGlobalData._cdw
        buttonBaseCompleteLevel.y              = myGlobalData._cdh + 50
        groupGameCompleteButton:insert( buttonBaseCompleteLevel )

        local buttonArtStartLevelVertices   = { 0,0, 20,12, 0,24 }
        local buttonArtStartLevel           = display.newPolygon( buttonBaseStartLevel.x, buttonBaseStartLevel.y, buttonArtStartLevelVertices )
        buttonArtStartLevel.fill            = v.buttonNewLevelIconColour
        groupGameCompleteButton:insert( buttonArtStartLevel )

        --Move the groupStartLevelButton GROUP offscreen
        groupGameCompleteButton.y = myGlobalData._h + 100
        ---------------------------------------------------------------------------------



        ---------------------------------------------------------------------------------
        -- Game Level area setup
        ---------------------------------------------------------------------------------
        local function levelSetup(getLevel, getCounter, getIsReset)


            --Drop cheat code. Sets the drop counter to ONE for every level
            if (c.enableCheatDrops==true) then
                getCounter = 1
                c.currentDrop = 1
            end


            ---------------------------------------------------------------------------------
            -- Create Reset Button (Note: it's an image only with no function - just visual)
            ---------------------------------------------------------------------------------
            c.resetButton           = display.newImageRect( myGlobalData.imagePath..v.buttonResetImageFile, v.buttonResetWidth, v.buttonResetHeight )
            c.resetButton.x         = myGlobalData._cdw
            c.resetButton.y         = myGlobalData._cdh
            c.resetButton.alpha     = 0.0
            c.resetButton.xScale    = 1.0
            c.resetButton.yScale    = 1.0
            groupBackgounds:insert( c.resetButton )


            ---------------------------------------------------------------------------------
            -- Calculate a NEW perfect Size for the dropped Block
            ---------------------------------------------------------------------------------
            c.perfectSize = math.random( v.randomSizeMin, v.randomSizeMax )
            print("Perfect Size = "..c.perfectSize)

            ---------------------------------------------------------------------------------
            -- Create the Player (Square) at the top of screen
            ---------------------------------------------------------------------------------
            c.playerSquare              = display.newRect( 0, 0, v.playerSize, v.playerSize )
            c.playerSquare.x            = myGlobalData._cdw
            c.playerSquare.y            = v.playerSquareStartY + (myGlobalData.bannerAd_Game_Adjustment*0.33)
            c.playerSquare.rotation     = v.playerRotateMax
            c.playerSquare.fill         = v.playerSquareColour

            groupEnvironment:insert( c.playerSquare )



            ---------------------------------------------------------------------------------
            -- Create the Player Drop number (locked to the blocks X, Y, Angle)
            ---------------------------------------------------------------------------------
            c.dropCounterText           = display.newText( getCounter, c.playerSquare.x, c.playerSquare.y, v.dropCounterTextFont, v.dropCounterStartSize )
            c.dropCounterText.x         = c.playerSquare.x
            c.dropCounterText.y         = c.playerSquare.y
            c.dropCounterText.align     = "center"
            c.dropCounterText.rotation  = c.playerSquare.rotation
            c.dropCounterText.fill      = levelData.levelBackground_Top[c.currentLevel]
            groupEnvironment:insert( c.dropCounterText )

            ---------------------------------------------------------------------------------
            -- Start the Player rotating
            ---------------------------------------------------------------------------------
            c.rotateTimer = timer.performWithDelay( v.playerRotateSpeed*2, rotatePlayer, 0 )
            rotatePlayer()



            ---------------------------------------------------------------------------------
            -- Create the Hazard Areas to avoid (ie, not drop on to)
            ---------------------------------------------------------------------------------
            local hazardWidthCalc           = (myGlobalData._cw) - (c.perfectSize/2)
            c.hazardLeft                    = display.newRect( 0, 0, hazardWidthCalc, v.hazardHeight)
            c.hazardLeft.fill               = v.hazardLeftFillColour
            local hazardLeftPosX            = hazardWidthCalc - (hazardWidthCalc/2)
            c.hazardLeft.x                  = -400 --hazardLeftPosX
            c.hazardLeft.y                  = (myGlobalData._h - v.targetHeight) - (v.hazardHeight * 0.5)
            local hazardShape               = { -(hazardWidthCalc*0.5), -v.hazardHeight*0.5,  (hazardWidthCalc*0.5)-1, -v.hazardHeight*0.5, (hazardWidthCalc*0.5)-1, v.hazardHeight*0.5, -(hazardWidthCalc*0.5), v.hazardHeight*0.5 }
            physics.addBody( c.hazardLeft, "static", { density=100.0, friction=0.0, bounce=0.0, shape=hazardShape } )
            c.hazardLeft.myName             = "Hazard"
            c.hazardLeft.isFixedRotation    = true
            groupEnvironment:insert( c.hazardLeft )
            transition.to( c.hazardLeft, { tag="moveHazard", time=300, x=hazardLeftPosX } )

            c.hazardRight                   = display.newRect( 0, 0, hazardWidthCalc, v.hazardHeight)
            c.hazardRight.fill              = v.hazardRightFillColour
            local hazardRightPosX           = myGlobalData._w - (hazardWidthCalc - (hazardWidthCalc/2))
            c.hazardRight.x                 = 400
            c.hazardRight.y                 = (myGlobalData._h - v.targetHeight) - (v.hazardHeight * 0.5)
            local hazardShape               = { -(hazardWidthCalc*0.5)+1, -v.hazardHeight*0.5,  (hazardWidthCalc*0.5), -v.hazardHeight*0.5, (hazardWidthCalc*0.5)-1, v.hazardHeight*0.5, -(hazardWidthCalc*0.5)+1, v.hazardHeight*0.5 }
            physics.addBody( c.hazardRight, "static", { density=100.0, friction=0.0, bounce=0.0, shape=hazardShape } )
            c.hazardRight.myName            = "Hazard"
            c.hazardRight.isFixedRotation   = true
            groupEnvironment:insert( c.hazardRight )
            transition.to( c.hazardRight, { tag="moveHazard", time=300, x=hazardRightPosX } )

            ---------------------------------------------------------------------------------
            -- Create the Target Areas to land on
            ---------------------------------------------------------------------------------
            math.randomseed( os.time() )
            local minDeductioncalc          = levelData.levelDifficulty[c.currentLevel][1]
            local maxDeductioncalc          = levelData.levelDifficulty[c.currentLevel][2]
            local randomDistance            = math.random( minDeductioncalc, maxDeductioncalc )
            --local randomDistance            = math.random( 8,20 )
            local targetWidthCalc           = hazardWidthCalc + randomDistance
            c.targetLeft                    = display.newRect( 0, 0, targetWidthCalc, v.targetHeight)
            c.targetLeft.fill               = v.targetLeftFillColour
            local targetLeftPosX            = c.targetLeft.width - (c.targetLeft.width/2)
            c.targetLeft.x                  = -400
            c.targetLeft.y                  = (myGlobalData._h - v.targetHeight*0.5)
            physics.addBody( c.targetLeft, "static", { density=100.0, friction=0.0, bounce=0.0 } )
            c.targetLeft.myName             = "Target"
            c.targetLeft.isFixedRotation    = true
            groupEnvironment:insert( c.targetLeft )
            transition.to( c.targetLeft, { tag="moveHazard", time=350, x=targetLeftPosX } )

            c.targetRight                   = display.newRect( 0, 0, targetWidthCalc, v.targetHeight)
            c.targetRight.fill              = v.targetRightFillColour
            local targetRightPosX           = myGlobalData._w - (c.targetRight.width - (c.targetRight.width/2))
            c.targetRight.x                 = 400
            c.targetRight.y                 = (myGlobalData._h - v.targetHeight*0.5)
            physics.addBody( c.targetRight, "static", { density=100.0, friction=0.0, bounce=0.0 } )
            c.targetLeft.myName             = "Target"
            c.targetRight.isFixedRotation   = true
            groupEnvironment:insert( c.targetRight )
            transition.to( c.targetRight, { tag="moveHazard", time=250, x=targetRightPosX } )

            -- Store the gap size for later use
            c.fallThroughSize            = math.abs((targetLeftPosX  + (c.targetLeft.width/2)) -
                                        (targetRightPosX  - (c.targetRight.width/2)))

            ---------------------------------------------------------------------------------
            -- Create an area invisible area to catch the player if they 'fall through';' the gap..
            ---------------------------------------------------------------------------------
            c.fallThroughHazard         = display.newRect( 0, 0, c.fallThroughSize, c.fallThroughSize )
            c.fallThroughHazard.x       = myGlobalData._cw
            c.fallThroughHazard.y       = myGlobalData._h + (c.fallThroughSize*2)
            c.fallThroughHazard.alpha   = 0.5
            physics.addBody( c.fallThroughHazard, "static", { density=100.0, friction=0.0, bounce=0.0 } )
            --Make the object a sensor
            --c.fallThroughHazard.isSensor = true
            c.fallThroughHazard.myName = "Hazard"
            groupEnvironment:insert( c.fallThroughHazard )

            print("GAP WIDTH = "..c.fallThroughSize)

            ---------------------------------------------------------------------------------
            -- Draw the guide box, on level start
            ---------------------------------------------------------------------------------
            c.guideBox          = display.newRect( 0, 0, c.perfectSize-randomDistance, c.perfectSize-randomDistance )
            c.guideBox.x        = myGlobalData._cw
            c.guideBox.y        = c.hazardRight.y  - (c.guideBox.height*0.5) + (v.hazardHeight*0.5)
            c.guideBox.fill     = v.guideBoxFillColour
            groupEnvironment:insert( c.guideBox )

            local textOptions = 
            {
                text        = v.guideTextInfo,     
                x           = c.guideBox.x,
                y           = c.guideBox.y,
                width       = c.guideBox.width-20,     --required for multi-line and alignment
                font        = v.guideTextInfoFont,   
                fontSize    = c.guideBox.width / 5,
                align       = "center"  --new alignment parameter
            }


            c.guideText         = display.newText( textOptions )
            c.guideText.fill    = levelData.levelBackground_Bot[c.currentLevel]
            groupEnvironment:insert( c.guideText )


            ---------------------------------------------------------------------------------
            -- Bring the Player box and drop number to the Front.
            ---------------------------------------------------------------------------------
            --c.playerSquare:toFront( )
            --c.dropCounterText:toFront( )

            c.backgroundBlock:addEventListener( "touch", handleGrow)

            if (myGlobalData.doDebug) then
                print("----------------------------------------")
                print("After Level Rebuild: Objects on Layer[ groupEnvironment ] = "..groupEnvironment.numChildren)
                print("----------------------------------------")
            end

            ---------------------------------------------------------------------------------
            -- If Ads are enabled - AND AdMob adverts are enabled - setup here.
            ---------------------------------------------------------------------------------
            if ( myGlobalData.adsShow ) then
                if ( myGlobalData.ads_AdMobEnabled ) then
                    if ( myGlobalData.adIntersRequired ) then
                        --adsConfig.showAdmobInterstitialAd()
                    end

                    if ( myGlobalData.adBannersRequired ) then
                        adsConfig.showAdmobBannerAd( myGlobalData.bannerAd_Game_Position )
                    end
                end
            end

        end


        ---------------------------------------------------------------------------------
        -- Start Level   |   Level, DropCounter, isReset?
        ---------------------------------------------------------------------------------
        levelSetup(c.currentLevel, c.currentDrop, false)



        ---------------------------------------------------------------------------------
        -- Reset Level   |   Level, DropCounter, isReset?
        ---------------------------------------------------------------------------------
        function resetLevel()

     

            if (myGlobalData.doDebug) then
                print("----------------------------------------")
                print("After Clearing: Objects on Layer[ groupEnvironment ] = "..groupEnvironment.numChildren)
                print("----------------------------------------")
                print("Resetting level...")
            end

            transition.to( c.backgroundBlockFail, { tag="changeToRed", time=300, alpha=0.0 } )
            transition.to( groupEnvironment, { tag="levelSlide", delay=100, time=200, y=0 } )

            c.playerLanded    = false

            -- SHow the config button if hidden
            c.buttonConfigure.alpha    = 0.3


            --Clean up audio
            --if(c.audioSFXHandeButtonTap ~= nil) then
            --    audio.stop(c.audioSFXHandeButtonTap)
            --    c.audioSFXHandeButtonTap = nil
            --end
            if(c.audioSFXHandeDrop ~= nil) then
                audio.stop(c.audioSFXHandeDrop)
               c.audioSFXHandeDrop = nil
            end
            if(c.audioSFXHandeLandBad ~= nil) then
                audio.stop(c.audioSFXHandeLandBad)
                c.audioSFXHandeLandBad = nil
            end
            if(c.audioSFXHandeLandGood ~= nil) then
                audio.stop(c.audioSFXHandeLandGood)
                c.audioSFXHandeLandGood = nil
            end
            if(c.audioSFXHandeLevelUp ~= nil) then
                audio.stop(c.audioSFXHandeLevelUp)
                c.audioSFXHandeLevelUp = nil
            end
            if(c.audioSFXHandePerfect ~= nil) then
                audio.stop(c.audioSFXHandePerfect)
                c.audioSFXHandePerfect = nil
            end






            levelSetup(c.currentLevel, c.currentDrop, false)

        end






        ---------------------------------------------------------------------------------
        -- Move the Target and Hazard Blocks into view.
        ---------------------------------------------------------------------------------



    elseif ( phase == "did" ) then

        ---------------------------------------------------------------------------------
        -- Grow the player function
        ---------------------------------------------------------------------------------
        local function growPlayer()
            if( c.playerLanded == false ) then
                if (c.playerSquare.width < v.playerMaxSize) then
                    c.playerSquare.width = c.playerSquare.width + v.playerGrowthRate
                    c.playerSquare.height = c.playerSquare.height + v.playerGrowthRate
                    c.dropCounterText.size = c.dropCounterText.size + (v.playerGrowthRate*0.3)
                end
            end
        end

        ---------------------------------------------------------------------------------
        -- Add runtime event to check for touch on the player
        ---------------------------------------------------------------------------------
        function handleEnterFrame( event )

            if( c.levelComplete == false ) then
                if ( c.playerGrow == true ) then
                    growPlayer()
                end

                -- Lock the current drop number to the player positoin (block)
                if ( c.playerIsDropping == true ) then
                    c.dropCounterText.x = c.playerSquare.x
                    c.dropCounterText.y = c.playerSquare.y
                    c.playerPosY = c.playerSquare.y
                end
            end

        end

        ---------------------------------------------------------------------------------
        -- Add a runtime listner to constanly update the grow status and sizes etc..
        ---------------------------------------------------------------------------------
        Runtime:addEventListener( "enterFrame", handleEnterFrame )

        ---------------------------------------------------------------------------------
        -- Collision event listeners.
        ---------------------------------------------------------------------------------
       local function onGlobalCollision( event )

            if ( event.phase == "began" and c.playerLanded == false ) then

                --print( "began: " .. event.object1.myName .. " and " .. event.object2.myName )

                ---------------------------------------------------------------------------------
                --Player has hit a Hazard
                ---------------------------------------------------------------------------------
                if(event.object1.myName == "Hazard" and  event.object2.myName == "Player" and c.playerLanded == false) then
                    c.hazardHit       = true  -- Set flag to inform engine player has hit a hazard
                    c.playerLanded    = true  -- Set flag to inform engine the player has landed.
                    timer.performWithDelay( 10, levelFail ) -- Start the Level Reset Code
                elseif(event.object1.myName == "Player" and  event.object2.myName == "Hazard" and c.playerLanded == false) then
                    --trigger the hazard hit boolean to signal fail
                    c.hazardHit       = true  -- Set flag to inform engine player has hit a hazard
                    c.playerLanded    = true  -- Set flag to inform engine the player has landed.
                    timer.performWithDelay( 10, levelFail ) -- Start the Level Reset Code

                ---------------------------------------------------------------------------------
                --Player has Landed Safely
                ---------------------------------------------------------------------------------
                elseif(event.object1.myName == "Target" and  event.object2.myName == "Player" and c.playerLanded == false) then
                    print("Target & Player")
                    c.playerLanded    = true  -- Set flag to inform engine the player has landed.
                    timer.performWithDelay( 10, checkLevelComplete ) -- The player has landed safely, check if they have completed the level
                    
                elseif(event.object1.myName == "Player" and  event.object2.myName == "Target" and c.playerLanded == false) then
                    print("Player & Target")
                    c.playerLanded    = true  -- Set flag to inform engine the player has landed.
                    timer.performWithDelay( 10, checkLevelComplete ) -- The player has landed safely, check if they have completed the level

                end

            elseif ( event.phase == "ended" and c.playerLanded == false  ) then
               --print( "ended: " .. event.object1.myName .. " and " .. event.object2.myName )
            end
        end

   
        ---------------------------------------------------------------------------------
        -- Add the Global Collision event listner to the runtime.
        ---------------------------------------------------------------------------------
        Runtime:addEventListener( "collision", onGlobalCollision )



        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
    end
end


---------------------------------------------------------------------------------
-- Save the game status to the device.
---------------------------------------------------------------------------------
function saveGameData()

    local newHighestLevelReached    = false
    local highestLevelReached       = myGlobalData.highesetLevel

    print("c.currentLevel: "..c.currentLevel.."  |  highestLevelReached: "..highestLevelReached)

    if ( c.currentLevel > highestLevelReached ) then
        myGlobalData.highesetLevel  = c.currentLevel
        highestLevelReached         = c.currentLevel
    end

    myGlobalData.currentLevel               = c.currentLevel
    myGlobalData.highesetLevel              = highestLevelReached
    myGlobalData.currentDrop                = c.currentDrop
    myGlobalData.currentLevelDrop           = c.currentDrop

    local i = myGlobalData.currentLevel

    saveDataTable.currentLevel          = myGlobalData.currentLevel
    saveDataTable.highesetLevel         = myGlobalData.highesetLevel
    saveDataTable.currentDrop           = myGlobalData.currentDrop
    saveDataTable.totalAttempts         = myGlobalData.totalAttempts
    saveDataTable.perfectSquares        = myGlobalData.perfectSquares
    saveDataTable.currentLevelDrops[i]  = myGlobalData.currentDrop

    loadsave.saveTable(saveDataTable, myGlobalData.saveDataFileName..".json")

end

---------------------------------------------------------------------------------
-- Create Particles of squares to celebrate.
---------------------------------------------------------------------------------
local function createParty(posX, posY)

    local i
    for  i = 0, v.numOfPartyParticles do
        local randomParticleSize = math.random(v.minPartyRadius, v.maxPartyRadius)
        local party             = display.newRect( posX, posY, randomParticleSize, randomParticleSize )
        party.fill              = v.partyFillColour
        physics.addBody(party, "dynamic", v.partyProp)
        groupEnvironment:insert( party )

        local xVelocity = math.random(v.minPartyVelocityX, v.maxPartyVelocityX)
        local yVelocity = math.random(v.minPartyVelocityY, v.maxPartyVelocityY)

        party:setLinearVelocity(xVelocity, yVelocity)
        
        transition.to(party, {  time = v.partyFadeTime, delay = v.partyFadeDelay, width = 0, height = 0, alpha = 0 ,
                                onComplete = function(party) display.remove( party ) party=nil end}
                        )     
    end

end


---------------------------------------------------------------------------------
-- Function to manage the level failed procedure.
---------------------------------------------------------------------------------
function levelFail()
    print("Level Failed...")
    c.backgroundBlock:removeEventListener( "touch", handleGrow) --Remove touch listener to the play background
    createParty(c.playerSquare.x, c.playerSquare.y+(c.playerSquare.height*0.5))
    c.levelFirstPlay = false

    c.dropCounterText.fill = levelData.backgroundFailColour_Bot
    
    physicsBodyRemoved = false 

    --Show the Reset level graphics
    c.resetButton.alpha = 1.0


    -- Remove the physics shape from the Player
    if not ( physicsBodyRemoved ) then
        physics.removeBody( c.playerSquare )
        physicsBodyRemoved = true 
    end



    --Play Failed Sound
    c.audioSFXHandeLandBad = audio.play(myGlobalData.sfx_LandBad)



    ---------------------------------------------------------------------------------
    -- If Ads are enabled - Play a VUNGLE or ADMOB Interstitial Ad
    ---------------------------------------------------------------------------------
    if ( myGlobalData.adsShow ) then
        local randomAd = math.random( 1,6 )
        if ( randomAd > 5 ) then -- If Greater than 4 we show the Vungle Ad
            print("Ad Numer > 5 - Preparing Vungle Ad")
            -- Show the Vungle Interstitial Ad
            if ( myGlobalData.ads_VungleEnabled ) then
                adsConfig.showVungleInterstitialAd()
            end
        else
            print("Ad Numer < 5 - Preparing Admob Ad")
            -- Show the AdMob Interstitial Ad
            if ( myGlobalData.ads_AdMobEnabled ) then
                if ( myGlobalData.adIntersRequired ) then
                    adsConfig.showAdmobInterstitialAd()
                end
            end
        end
    end





    local function startLevelReset()

        local function touchResetLevel( event )
            
            if ( event.phase == "began" ) then
                --
            elseif ( event.phase == "ended" ) then

                event.target:removeEventListener( "touch", touchResetLevel ) --Remove touch listener to the fail background
                c.playerGrow          = false  -- Reset Game Params
                c.playerIsDropping    = false  -- Reset Game Params
                c.hazardHit           = false  -- Reset Game Params
                c.guideBoxShow        = true   -- Reset Game Params

                --Move & hide the rest button (graphic)
                transition.to( c.resetButton, { tag="changeToRed", time=300, alpha=0.0, xScale=3.0, yScale=3.0,y=-200 } )

                local function clearOutLevelObjects()
                    for i=groupEnvironment.numChildren,1,-1 do
                        local child = groupEnvironment[i]
                        child:removeSelf()
                        display.remove( child ) -- or display.remove( child )
                        child = nil
                    end
                    groupEnvironment.y = -myGlobalData._h
                    math.randomseed( os.time() )
                    resetLevel()
                end

                transition.to( groupEnvironment, { tag="levelSlide", time=500, y=myGlobalData._h, transition=easing.inOutBack, onComplete=clearOutLevelObjects } )

            end
            return true
        end

        c.backgroundBlockFail:addEventListener( "touch", touchResetLevel ) --Add a touch listener to the background - to reset level
    end

    c.currentDrop = c.currentLevel -- Reset the Drop Number to the Level Number
    saveGameData() --Save the Game Progress details

    --Move the player down 1 pixel - hide any gaps on larger screens
    c.playerSquare.y = c.playerSquare.y + 1

    transition.to( c.backgroundBlockFail, { tag="changeToRed", time=300, alpha=1.0, onComplete=startLevelReset } ) -- Show the level failed background
end



---------------------------------------------------------------------------------
-- Function to manage the safely landed. Is it level completed or continue?
---------------------------------------------------------------------------------
function checkLevelComplete()
    print("Player landed: checking level status...")
    c.backgroundBlock:removeEventListener( "touch", handleGrow) --Remove touch listener to the play background
    createParty(c.playerSquare.x, c.playerSquare.y+(c.playerSquare.height*0.5))
    c.levelFirstPlay = false

    saveGameData() --Save the Game Progress details

    c.dropCounterText.fill = levelData.levelBackground_Bot[c.currentLevel]

    --Play Good Landing Sound
    c.audioSFXHandeLandGood = audio.play(myGlobalData.sfx_LandGood)

    --Check if the user got a Perfect Square
    if (c.playerSizePerfect == true) then
        c.perfectSquaresReached = c.perfectSquaresReached + 1
        myGlobalData.perfectSquares = myGlobalData.perfectSquares + 1

        c.infoPerfectSquares.text = v.perfectDropsText.." ".. c.perfectSquaresReached
        c.infoPerfectSquares.x = myGlobalData._cdw
        createParty(c.infoPerfectSquares.x, c.infoPerfectSquares.y)

        --Play Good Landing Sound
        c.audioSFXHandePerfect = audio.play(myGlobalData.sfx_Perfect)
    end

    physicsBodyRemoved = false 

     -- Remove the physics shape from the Player
    if not ( physicsBodyRemoved ) then
        physics.removeBody( c.playerSquare )
        physicsBodyRemoved = true 
    end


    --Move the player down 1 pixel - hide any gaps on larger screens
    c.playerSquare.y = c.playerSquare.y + 1

    local function clearOutLevelObjects()

        for i=groupEnvironment.numChildren,1,-1 do
            local child = groupEnvironment[i]
            display.remove( child ) -- or display.remove( child )
            child = nil
        end

        groupEnvironment.y = -myGlobalData._h
        math.randomseed( os.time() )

        if(c.levelComplete==false) then
            print("Drop Counter not resetting...")
            resetLevel()

        else

            ---------------------------------------------------------------------------------
            -- If Ads are enabled - Play a VUNGLE or ADMOB Interstitial Ad
            ---------------------------------------------------------------------------------
            if ( myGlobalData.adsShow ) then
                local randomAd = math.random( 1,6 )
                if ( randomAd > 5 ) then -- If Greater than 4 we show the Vungle Ad
                    print("Ad Numer > 5 - Preparing Vungle Ad")
                    -- Show the Vungle Interstitial Ad
                    if ( myGlobalData.ads_VungleEnabled ) then
                        adsConfig.showVungleInterstitialAd()
                    end
                else
                    print("Ad Numer < 5 - Preparing Admob Ad")
                    -- Show the AdMob Interstitial Ad
                    if ( myGlobalData.ads_AdMobEnabled ) then
                        if ( myGlobalData.adIntersRequired ) then
                            adsConfig.showAdmobInterstitialAd()
                        end
                    end
                end
            end


        end

    end


    local function autoStartNewDrop()
                    --
        --c.backgroundBlock:removeEventListener( "touch", touchStartNewDrop ) --Remove touch listener to the fail background
        c.playerGrow          = false  -- Reset Game Params
        c.playerIsDropping    = false  -- Reset Game Params
        c.hazardHit           = false  -- Reset Game Params
        c.guideBoxShow        = true   -- Reset Game Params
        
        transition.to( groupEnvironment, { tag="levelSlide", time=500, y=myGlobalData._h, transition=easing.inOutBack, onComplete=clearOutLevelObjects } )

    end



    local function touchStartNewDrop( event )
        
        if ( event.phase == "began" ) then
            --
        elseif ( event.phase == "ended" ) then

            event.target:removeEventListener( "touch", touchStartNewDrop ) --Remove touch listener to the fail background
            c.playerGrow          = false  -- Reset Game Params
            c.playerIsDropping    = false  -- Reset Game Params
            c.hazardHit           = false  -- Reset Game Params
            c.guideBoxShow        = true   -- Reset Game Params
            
            transition.to( groupEnvironment, { tag="levelSlide", time=500, y=myGlobalData._h, transition=easing.inOutBack, onComplete=clearOutLevelObjects } )

        end
        return true
    end




        --------------------------------------------------------
        -- Reduce the drop counter {Check if we are at ZERO}
        --------------------------------------------------------
        c.currentDrop = c.currentDrop - 1 
        --------------------------------------------------------

        if( c.currentDrop <= 0) then
            c.currentLevel        = c.currentLevel + 1

            --Check if the user has completed all the levels
            if( c.currentLevel > v.maxLevels ) then
                c.currentLevel = v.maxLevels

                -- Game COMPLETED !!! All levels completed.
                c.gameComplete        = true
                c.levelComplete       = true
                c.playerGrow          = false  -- Reset Game Params
                c.playerIsDropping    = false  -- Reset Game Params
                c.backgroundBlock:removeEventListener( "touch", touchStartNewDrop ) --Remove touch listener to the fail background

                -- hide the config button on game complete...
                c.buttonConfigure.alpha         = 0.0

                createParty(myGlobalData._w * 0.5, myGlobalData._h * 0.5)


                local backgroundPaint = {
                    type = "gradient",
                        color1 = levelData.backgroundCompleteColour_Top,
                        color2 = levelData.backgroundCompleteColour_Bot,
                    direction = "down"
                }

                c.backgroundBlock.fill = backgroundPaint
                c.backgroundBlock.alpha = 1.0

                c.infoCurrentLevel.text         = v.minLevels.."-"..v.maxLevels --c.currentLevel
                c.infoCurrentLevel.x            = myGlobalData._cw
                c.infoCurrentLevel.alpha        = 1.0
                c.infoCurrentLevel.fill         = v.completedGameTextColour

                c.levelWord.text                = v.completedGameText1
                c.levelWord.x                   = myGlobalData._cw
                c.levelWord.alpha               = 1.0
                c.levelWord.fill                = v.completedGameTextColour

                c.levelCompletedMessage.text    = v.completedGameText2
                c.levelCompletedMessage.size    = v.completedGameText2FontSize
                c.levelCompletedMessage.x       = myGlobalData._cw
                c.levelCompletedMessage.alpha   = 1.0
                c.levelCompletedMessage.fill    = v.completedGameTextColour

                c.infoPerfectSquares.alpha      = 1.0
                c.infoPerfectSquares.fill       = v.completedGameTextColour

                --c.infoCurrentLevel.fill         = v.levelCurrentTextColourWin
                --c.infoCurrentLevel.alpha        = v.levelCurrentTextFontAlphaWin

                local function celebrate()
                    createParty(c.infoCurrentLevel.x, c.infoCurrentLevel.y)
                    transition.to( groupEnvironment, { tag="levelSlide", time=500, y=myGlobalData._h, transition=easing.inOutBack, onComplete=clearOutLevelObjects } )
                    
                    --Play Good Landing Sound
                    c.audioSFXHandeLevelUp = audio.play(myGlobalData.sfx_LevelUp)
                end


                transition.to( c.infoCurrentLevel,          { tag="levelSlide", time=500, y=c.infoCurrentLevel.y+80, size=v.completedGameAllLevelsFontSize, onComplete=celebrate } )
                transition.to( c.levelWord,                 { tag="levelSlide", time=500, y=c.levelWord.y+45, size=v.completedGameText1FontSize } )
                transition.to( c.levelCompletedMessage,     { tag="levelSlide", time=350, y=myGlobalData._ch - 30 } )
                transition.to( groupGameCompleteButton,     { tag="levelSlide", delay=400, time=350, y=0 } )
                transition.to( c.infoPerfectSquares,        { tag="levelSlide", delay=300, time=350, size=v.completedGamePerfectFontSize, y=myGlobalData._ch+120 } )

                --Set the drop counter to [ 1 ] for the last level....
                c.currentDrop       = 1
                startNextLevelFlag  = false


            else

                -- Game not complete - but LEVEL Completed.
                c.gameComplete        = false
                c.levelComplete       = true
                c.playerGrow          = false  -- Reset Game Params
                c.playerIsDropping    = false  -- Reset Game Params
                c.backgroundBlock:removeEventListener( "touch", touchStartNewDrop ) --Remove touch listener to the fail background

                -- hide the config button on level complete
                c.buttonConfigure.alpha    = 0.0

                createParty(myGlobalData._w*0.5, myGlobalData._h*0.5)
               
                c.infoCurrentLevel.text         = c.currentLevel
                c.infoCurrentLevel.x            = myGlobalData._cw

                c.infoCurrentLevel.fill         = v.levelCurrentTextColourWin
                c.infoCurrentLevel.alpha        = v.levelCurrentTextFontAlphaWin
                c.levelWord.fill                = v.levelInfoTextColourWin

                local function celebrate()
                    createParty(c.infoCurrentLevel.x, c.infoCurrentLevel.y)
                    transition.to( groupEnvironment, { tag="levelSlide", time=500, y=myGlobalData._h, transition=easing.inOutBack, onComplete=clearOutLevelObjects } )
                    
                    --Play Good Landing Sound
                    c.audioSFXHandeLevelUp = audio.play(myGlobalData.sfx_LevelUp)
                end

                transition.to( c.infoCurrentLevel,          { tag="levelSlide", time=500, y=c.infoCurrentLevel.y+60, xScale=1.3, yScale=1.3, onComplete=celebrate } )
                transition.to( c.levelWord,                 { tag="levelSlide", time=500, y=c.levelWord.y+45, xScale=1.3, yScale=1.3 } )
                transition.to( c.levelCompletedMessage,     { tag="levelSlide", time=350, y=myGlobalData._ch - 30 } )
                transition.to( groupStartLevelButton,       { tag="levelSlide", delay=700, time=350, y=0 } )

                --Get the drop counter ready for the next level
                c.currentDrop = c.currentLevel
                startNextLevelFlag = true

            end





        else

            c.levelComplete = false
            -- Restart by clicking the backgaound?
            --c.backgroundBlock:addEventListener( "touch", touchStartNewDrop ) --Add a touch listener to the background - to reset level
            -- or, automatically after a set amount of time?
            -- Start new drop after delay
            local delayTime = v.autoStartLevelTimer
            local endGameTimer = timer.performWithDelay(delayTime, autoStartNewDrop )


        end

        saveGameData() --Save the Game Progress details


      


end



---------------------------------------------------------------------------------
-- Function "scene:hide()"
---------------------------------------------------------------------------------
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.

        physics.stop( )

        print("Release: Cleaning Audio Channels...")
        --Clean up audio
        if(c.audioSFXHandeButtonTap ~= nil) then
            audio.stop(c.audioSFXHandeButtonTap)
            c.audioSFXHandeButtonTap = nil
            print("Release: Audio: c.audioSFXHandeButtonTap  |  Released")
        end
        if(c.audioSFXHandeDrop ~= nil) then
            audio.stop(c.audioSFXHandeDrop)
           c.audioSFXHandeDrop = nil
            print("Release: Audio: c.audioSFXHandeDrop  |  Released")
        end
        if(c.audioSFXHandeLandBad ~= nil) then
            audio.stop(c.audioSFXHandeLandBad)
            c.audioSFXHandeLandBad = nil
            print("Release: Audio: c.audioSFXHandeLandBad  |  Released")
        end
        if(c.audioSFXHandeLandGood ~= nil) then
            audio.stop(c.audioSFXHandeLandGood)
            c.audioSFXHandeLandGood = nil
            print("Release: Audio: c.audioSFXHandeLandGood  |  Released")
        end
        if(c.audioSFXHandeLevelUp ~= nil) then
            audio.stop(c.audioSFXHandeLevelUp)
            c.audioSFXHandeLevelUp = nil
            print("Release: Audio: c.audioSFXHandeLevelUp  |  Released")
        end
        if(c.audioSFXHandePerfect ~= nil) then
            audio.stop(c.audioSFXHandePerfect)
            c.audioSFXHandePerfect = nil
            print("Release: Audio: c.audioSFXHandePerfect  |  Released")
        end


    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


---------------------------------------------------------------------------------
-- Function "scene:destroy()"
---------------------------------------------------------------------------------
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
    
        -- Stop / nil the music channel if not set to continuous.
        if (v.musicContinueThroughScenes == false ) then
            audio.stop( c.playbackgroundMusic )
            c.playbackgroundMusic = nil
        end

        -- Stop / nil the music channel if the GAME music is different from the MENU music!
        if (v.musicMenuScreen ~= v.musicGameScreen ) then
            audio.stop( c.playbackgroundMusic )
            c.playbackgroundMusic = nil
        end


        local function clearOutLevelObjects()
            
            for i=groupEnvironment.numChildren,1,-1 do
                local child = groupEnvironment[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end


            for i=groupScore.numChildren,1,-1 do
                local child = groupScore[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end

            for i=groupBackgounds.numChildren,1,-1 do
                local child = groupBackgounds[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end

            for i=groupNextLevelButtons.numChildren,1,-1 do
                local child = groupNextLevelButtons[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end


            for i=groupStartLevelButton.numChildren,1,-1 do
                local child = groupStartLevelButton[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end

            for i=groupRateAppButton.numChildren,1,-1 do
                local child = groupRateAppButton[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end


            for i=groupShareButton.numChildren,1,-1 do
                local child = groupShareButton[i]
                print("Release: Scene Objects and Nulling: ".. i)
                child:removeSelf()
                display.remove( child ) -- or display.remove( child )
                child = nil
            end
            --groupEnvironment.y = -myGlobalData._h
        
        print("Release: removing external Variable file [gameVariables] |  Released")

        
        end

        clearOutLevelObjects()

        print("Release: Runtime:removeEventListener  |  enterFrame  |  handleEnterFrame  |  Released")
        Runtime:removeEventListener( "enterFrame", handleEnterFrame)

        print("Release: Runtime:removeEventListener  |  collision  |  onGlobalCollision  |  Released")
        Runtime:removeEventListener( "collision", onGlobalCollision )

        c.backgroundBlock:removeEventListener( "touch", handleGrow) --Remove touch listener to the play background

        print("Release: Canceling rotateTimer on main player")
        transition.cancel( "rotatePlayer")
        timer.cancel( c.rotateTimer )
        transition.cancel()

        print("Release: Nilling all variable references from the external v.Table")
        -- Release variables from external source

        for j = #v,1,-1 do 
            print("Release: v["..j.."]")
            v[j] = nil
        end

        -- unload the external game engine variables from memory
        package.loaded["gameConfig"] = nil
        _G["gameConfig"] = nil
        -- package.loaded["gameVariables"] = nil
        -- _G["gameVariables"] = nil



end




---------------------------------------------------------------------------------
-- Listener setup
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------
-- Return the Scene
---------------------------------------------------------------------------------
return scene