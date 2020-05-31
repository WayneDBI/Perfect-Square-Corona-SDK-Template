---------------------------------------------------------------------------------
-- gameMenu.lua
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Load external modules as required.
---------------------------------------------------------------------------------
local composer      = require( "composer" )
local scene         = composer.newScene()
local magnet        = require( "lib.magnet" )
local widget        = require( "widget" )
local myGlobalData  = require( "lib.globalData" )
local loadsave      = require( "lib.loadsave" )
local levelData     = require( "gameLevelData" )
local v             = require( "gameVariables" )
local adsConfig     = require( "adsLibrary" )


---------------------------------------------------------------------------------
-- Load in the latest Data from the users devcie
---------------------------------------------------------------------------------
saveDataTable = loadsave.loadTable(myGlobalData.saveDataFileName..".json")
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Assign the Level and other variables to the game variables.
---------------------------------------------------------------------------------
myGlobalData.currentLevel               = saveDataTable.currentLevel    -- Saved Level value
myGlobalData.highesetLevel              = saveDataTable.highesetLevel   -- Saved Highest level reached
myGlobalData.currentDrop                = saveDataTable.currentDrop     -- Saved Drop Number for the Level
myGlobalData.adsDisabled                = saveDataTable.adsDisabled     -- Do we show/hide the ads ?
myGlobalData.totalAttempts              = saveDataTable.totalAttempts   -- Total attempts
myGlobalData.perfectSquares             = saveDataTable.perfectSquares  -- Number pf perfect Squares achieved.



-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed
-- ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------
--local fontTitles            = "Jura-Light.ttf"
--local fontNumbers           = "Play-Regular.ttf"
local anchorXOffset         = myGlobalData._cdw - 98  -- Alignment to the LEFT for the objects


local showVisual            = false
local studioLogo            = nil
local selectedLevel         = myGlobalData.highesetLevel
local displayLevelNumber    = selectedLevel
local logoSquare            = nil
local logoText              = nil
local playButton            = nil
local highestLevelAvaiable  = myGlobalData.highesetLevel -- Get the MAX level the user can play
local levelAvailable        = false
local levelNumber           = highestLevelAvaiable
local buttonClicked         = false
local audioSFXHandeButtonTap = nil
local transitionLogo        = nil
local transitionStudioLogo  = nil
local transitionLevelSelect = nil
local transitionTotalDrops  = nil
local transitionPerfect     = nil
local playButtonPosY        = 0
local backgroundBlock       = nil

local buttonSFX             = nil
local buttonMusic           = nil
local buttonSFXOff          = nil
local buttonMusicOff        = nil
local buttonInfo            = nil
local buttonSFX_x           = 0
local buttonSFX_y           = 0
local buttonMusic_x         = 0
local buttonMusic_y         = 0
local playbackgroundMusic

---------------------------------------------------------------------------------
-- Create a Randomseed value from the os.time()
---------------------------------------------------------------------------------
math.randomseed( os.time() )

---------------------------------------------------------------------------------
-- Setup scene Groups
---------------------------------------------------------------------------------
local groupBackground       = display.newGroup()
local groupLogo             = display.newGroup()
local groupStudioLogo       = display.newGroup()
local groupLevelSelect      = display.newGroup()
local groupTotalDrops       = display.newGroup()
local groupPerfectSquares   = display.newGroup()


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
-- Format number
---------------------------------------------------------------------------------
local function numberFormat(num, places)
    
    local isNegative = false; if num < 0 then isNegative = true end
    local num = math.abs(num)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. " TRIL" -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. " BIL" -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. " MIL" -- million
    elseif num >= 1000 then
        ret = string.gsub(num, "^(-?%d+)(%d%d%d)", '%1,%2')
        -- ret = placeValue:format(num / 1000) .. "k" -- thousand
    else
        ret = num -- hundreds
    end
    
    --local currency = "£"
    --if isNegative then currency = "-£" end  
    --return currency .. ret
    
    return ret
end



---------------------------------------------------------------------------------
-- Scene setup
-- "scene:create()"
---------------------------------------------------------------------------------
function scene:create( event )

    local sceneGroup = self.view

        -- Remove any previous Composer Scenes
        composer.removeScene( "gameEngine" )

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end



---------------------------------------------------------------------------------
-- Scene setup
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
        sceneGroup:insert( groupBackground )
        sceneGroup:insert( groupLogo )
        sceneGroup:insert( groupStudioLogo )
        sceneGroup:insert( groupLevelSelect )
        sceneGroup:insert( groupTotalDrops )
        sceneGroup:insert( groupPerfectSquares )

        --Show / Hide total drops and/or perfect drops panels
        if ( v.perfectSquaresShowBlock == false ) then
            groupPerfectSquares.alpha = 0.0
        else
            groupPerfectSquares.alpha = 1.0
        end

        --Show / Hide total drops and/or perfect drops panels
        if ( v.totalDropsShowBlock == false ) then
            groupTotalDrops.alpha = 0.0
        else
            groupTotalDrops.alpha = 1.0
        end

        ---------------------------------------------------------------------------------

        ---------------------------------------------------------------------------------
        -- Move all the Groups offscreen - we'll animate them into position
        ---------------------------------------------------------------------------------
        groupLogo.y             = -myGlobalData._h
        groupLevelSelect.y      = -myGlobalData._h
        groupTotalDrops.y       = myGlobalData._h
        groupPerfectSquares.y   = myGlobalData._h


        ---------------------------------------------------------------------------------
        -- Create Background Block / Colour (Based on the level selected by the user)
        ---------------------------------------------------------------------------------
        
        if ( v.backgroundSelect1 == true ) then
            --Backgrounds as per the level selected....
            local mySelectedLevel = selectedLevel
            
            if( mySelectedLevel > v.maxLevels ) then
                mySelectedLevel = v.maxLevels
            end

            local backgroundPaint = {
                type = "gradient",
                    color1 = levelData.levelBackground_Top[mySelectedLevel],
                    color2 = levelData.levelBackground_Bot[mySelectedLevel],
                direction = "down"
            }

            backgroundBlock = display.newRect( 0, 0, myGlobalData._w, myGlobalData._h)
            backgroundBlock.fill = backgroundPaint
            backgroundBlock.x = myGlobalData._cdw
            backgroundBlock.y = myGlobalData._cdh
            groupBackground:insert( backgroundBlock )

        elseif ( v.backgroundSelect2 == true ) then
            -- Background set colour
            local backgroundPaint = {
                type = "gradient",
                    color1 = v.backgroundSelect2Top,
                    color2 = v.backgroundSelect2Bottom,
                direction = "down"
            }

            backgroundBlock = display.newRect( 0, 0, myGlobalData._w, myGlobalData._h)
            backgroundBlock.fill = backgroundPaint
            backgroundBlock.x = myGlobalData._cdw
            backgroundBlock.y = myGlobalData._cdh
            groupBackground:insert( backgroundBlock )

        elseif ( v.backgroundSelect3 == true ) then
            -- Background Image
            backgroundBlock = display.newImageRect( myGlobalData.imagePath..v.backgroundSelect3ImageName, v.backgroundSelect3ImageWidth, v.backgroundSelect3ImageHeight )
            backgroundBlock.x = myGlobalData._cdw
            backgroundBlock.y = myGlobalData._cdh
            groupBackground:insert( backgroundBlock )            

        end
        ---------------------------------------------------------------------------------

        ---------------------------------------------------------------------------------
        -- Apply te background overlay effect
        ---------------------------------------------------------------------------------
        if ( v.backgroundEffect ) then
            local bgEffect     = display.newImageRect( myGlobalData.imagePath..v.backgroundEffectFile, 384,568 )
            bgEffect.x         = myGlobalData._cdw
            bgEffect.y         = myGlobalData._cdh
            bgEffect.alpha     = v.backgroundEffectAlpha
            groupBackground:insert( bgEffect )
        end

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
            if ( v.musicPlayMenuScreen ) then

                local isChannel1Paused  = audio.isChannelPaused( 1 )
                local isChannel1Playing = audio.isChannelPlaying( 1 )

                if ( myGlobalData.soundMusicOn == false ) then
                    buttonMusic.x       = offsetButtonsX    -- Move off screen
                    buttonMusicOff.x    = buttonMusic_x     -- Restore position
                    if ( isChannel1Playing ) then
                        audio.pause( playbackgroundMusic )
                    end

                else
                    buttonMusic.x       = buttonMusic_x     -- Restore position                
                    buttonMusicOff.x    = offsetButtonsX    -- Move off screen
                    if ( isChannel1Paused ) then
                        audio.resume( playbackgroundMusic )
                    end
                end
            end

        end

        local function updateSFXStatus()
            if ( myGlobalData.soundSFXOn == false ) then
                buttonSFX.x       = offsetButtonsX    -- Move off screen
                buttonSFXOff.x    = buttonSFX_x     -- Restore position

                for i = 4, 32 do
                    audio.setVolume( 0, { channel=i } )
                end                 
                myGlobalData.volumeSFX = 0

                print("SFX Volumes at 0")
            else
                buttonSFX.x       = buttonSFX_x     -- Restore position                
                buttonSFXOff.x    = offsetButtonsX    -- Move off screen

                for i = 4, 32 do
                    audio.setVolume( myGlobalData.resetVolumeSFX, { channel=i } )
                end                 
                print("SFX Volumes at "..myGlobalData.resetVolumeSFX)

            end
            print("soundSFXOn = "..tostring(myGlobalData.soundSFXOn) )

        end



        local function onGUIButtonsTouch( event )
            local buttonName = event.target.id
            if ( event.phase == "began" and buttonClicked == false ) then

            elseif ( event.phase == "ended" and buttonClicked == false) then
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
        -- MUSIC ON/OFF Button (Create the ON and OFF state x 2)
        ---------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------
        -- SFX ON/OFF Button (Create the ON and OFF state x 2)
        ---------------------------------------------------------------------------------
        buttonSFX = widget.newButton( { onEvent  = onGUIButtonsTouch,
              defaultFile   = myGlobalData.imagePath..v.buttonSFXPlayOffImageFile,
              overFile      = myGlobalData.imagePath..v.buttonSFXPlayOnImageFile,
              width         = v.buttonSFXPlayWidth, height = v.buttonSFXPlayHeight, id  = "sfxOn" } )
        buttonSFX.anchorX   = 0.5; buttonSFX.anchorY  = 0.5
        buttonSFX.x         = v.buttonSFXPlayWidth
        buttonSFX.y = myGlobalData._cdh - 230
        if ( myGlobalData.bannerAd_Menu_Adjust_Top ) then
            buttonSFX.y = v.buttonSFXPlayHeight + myGlobalData.bannerAd_Menu_Adjustment
        end
        buttonSFX.y         = myGlobalData._cdh - 230 + v.buttonMusicPlayHeight
        buttonSFX.alpha     = v.buttonSFXPlayAlpha
        buttonSFX_x         = buttonSFX.x ; buttonSFX_y = buttonSFX.y
        groupBackground:insert( buttonSFX )
        ---------------------------------------------------------------------------------
        buttonSFXOff = widget.newButton( { onEvent  = onGUIButtonsTouch,
              defaultFile   = myGlobalData.imagePath..v.buttonSFXStopOffImageFile,
              overFile      = myGlobalData.imagePath..v.buttonSFXStopOnImageFile,
              width         = v.buttonSFXStopWidth, height = v.buttonSFXStopHeight, id  = "sfxOff" } )
        buttonSFXOff.anchorX   = 0.5; buttonSFXOff.anchorY  = 0.5
        buttonSFXOff.x         = offsetButtonsX
        buttonSFXOff.y         = buttonSFX.y
        buttonSFXOff.alpha     = v.buttonSFXStopAlpha
        groupBackground:insert( buttonSFXOff )
        ---------------------------------------------------------------------------------
        if ( v.musicPlayMenuScreen ) then
            buttonMusic = widget.newButton( { onEvent = onGUIButtonsTouch,
                  defaultFile     = myGlobalData.imagePath..v.buttonMusicPlayOffImageFile,
                  overFile        = myGlobalData.imagePath..v.buttonMusicPlayOnImageFile,
                  width           = v.buttonMusicPlayWidth, height = v.buttonMusicPlayHeight, id  = "musicOn" } )
            buttonMusic.anchorX     = 0.5; buttonMusic.anchorY  = 0.5
            buttonMusic.x           = buttonSFX.x
            buttonMusic.y           = buttonSFX.y + v.buttonMusicPlayHeight + 10
            buttonMusic.alpha       = v.buttonMusicPlayAlpha
            buttonMusic_x           = buttonMusic.x ; buttonMusic_y = buttonMusic.y
            groupBackground:insert( buttonMusic )
            ---------------------------------------------------------------------------------
            buttonMusicOff = widget.newButton( { onEvent = onGUIButtonsTouch,
                  defaultFile       = myGlobalData.imagePath..v.buttonMusicStopOffImageFile,
                  overFile          = myGlobalData.imagePath..v.buttonMusicStopOnImageFile,
                  width             = v.buttonMusicStopWidth, height = v.buttonMusicStopHeight, id  = "musicOff" } )
            buttonMusicOff.anchorX  = 0.5; buttonMusicOff.anchorY  = 0.5
            buttonMusicOff.x        = offsetButtonsX
            buttonMusicOff.y        = buttonMusic.y
            buttonMusicOff.alpha    = v.buttonMusicStopAlpha
            groupBackground:insert( buttonMusicOff )
        end
        ---------------------------------------------------------------------------------



        ---------------------------------------------------------------------------------
        -- Start Menu Screen MUSIC playing if enabled.
        ---------------------------------------------------------------------------------
        if ( v.musicPlayMenuScreen) then
            playbackgroundMusic = audio.play( myGlobalData.music_Menu, { channel=1, loops=-1, fadein=v.musicFadeinMenuScreen } )
            if ( myGlobalData.soundMusicOn == false ) then
                audio.pause( playbackgroundMusic ) -- instantly pause the music if the user has turned it off.
            end
        end

        ---------------------------------------------------------------------------------
        -- Manually trigger the buttons refresh status based on the globally stored data
        ---------------------------------------------------------------------------------
        updateMusicStatus()
        updateSFXStatus()


        ---------------------------------------------------------------------------------
        -- Developers logo
        ---------------------------------------------------------------------------------
        studioLogo          = display.newImageRect( myGlobalData.imagePath..v.studioLogoImage, v.studioLogoImageWidth, v.studioLogoImageHeight )
        studioLogo.x        = myGlobalData._cdw
        studioLogo.y        = myGlobalData._cdh + 178 + myGlobalData.bannerAd_Menu_Adjustment + v.studioLogoExtraYOffset
        studioLogo.alpha    = 1.0
        studioLogo.xScale   = 0.01
        studioLogo.yScale   = 0.01
        groupStudioLogo:insert( studioLogo )
        ---------------------------------------------------------------------------------


        ---------------------------------------------------------------------------------
        -- INFO Button
        ---------------------------------------------------------------------------------
        if( v.aboutAppButtonShow ) then
            buttonInfo = widget.newButton( { onEvent = onGUIButtonsTouch,
                  defaultFile     = myGlobalData.imagePath..v.buttonInfoOffImageFile,
                  overFile        = myGlobalData.imagePath..v.buttonInfoOnImageFile,
                  width           = v.buttonInfoWidth, height = v.buttonInfoHeight, id  = "info" } )
            buttonInfo.anchorX  = 0.5; buttonInfo.anchorY  = 0.5
            buttonInfo.x        = myGlobalData._w - v.buttonInfoWidth
            buttonInfo.y = studioLogo.y
            buttonInfo.alpha    = v.buttonInfoAlpha
            groupBackground:insert( buttonInfo )
       end
        ---------------------------------------------------------------------------------


        ---------------------------------------------------------------------------------
        -- Create the Game Logo (Shape and wording)- replace with image as required.
        ---------------------------------------------------------------------------------
        logoText                = display.newText( v.gameTitleText, 0,0, v.gameTitleTextFont, v.gameTitleTextFontSize )
        logoText.anchorX        = 0
        logoText.x              = anchorXOffset
        logoText.y              = myGlobalData._cdh - 100
        logoText.align          = "left"
        logoText.fill           = v.gameTitleTextColour

        logoSquare              = display.newRect( 0, 0, v.squareLogoSize, v.squareLogoSize )
        logoSquare.anchorX      = 0
        logoSquare.anchorY      = 1        
        logoSquare.x            = anchorXOffset
        logoSquare.y            = logoText.y - (logoText.height/2) - 3
        logoSquare.fill         = v.squareLogoSizeColour
        groupLogo:insert( logoSquare )


        groupLogo:insert( logoText )

        ---------------------------------------------------------------------------------
        -- Are we hiding the logos?
        ---------------------------------------------------------------------------------
        if ( v.studioLogoShow == true ) then
            studioLogo.alpha    = 1.0
        else
            studioLogo.alpha    = 0.0
        end

        if ( v.gameTitleShow == true ) then
            logoText.alpha    = 1.0
        else
            logoText.alpha    = 0.0
        end

        if ( v.squareLogoShow == true ) then
            logoSquare.alpha    = 1.0
        else
            logoSquare.alpha    = 0.0
        end
        ---------------------------------------------------------------------------------



        local function playLevel()
           
           -- Configure the level details to play

            myGlobalData.currentLevelDrop = saveDataTable.currentLevelDrops[selectedLevel]    -- Saved Drop Number for the Level
            myGlobalData.currentLevel   = selectedLevel
            myGlobalData.currentDrop    = currentLevelDrop
            
            composer.removeScene( "gameEngine" )

            local function startGame()
                composer.gotoScene( "gameEngine") --This is our main menu
                --buttonClicked = false
            end

            -- Start game engine after short delay
            timer.performWithDelay(200, startGame )

        end

        function updateLevelBox()

            if ( v.backgroundSelect1 == true ) then
                -- Update the Background colour / effect to the level is option set to true
                local backgroundPaint = {
                type = "gradient",
                    color1      = levelData.levelBackground_Top[selectedLevel],
                    color2      = levelData.levelBackground_Bot[selectedLevel],
                    direction   = "down"
                }

                backgroundBlock.fill = backgroundPaint
            end

            -- Update the level select visual on screen
            displayLevelNumber.text = selectedLevel

            --Hide the PLAY button, if the user has not unlocked that level yet
            if(selectedLevel <= highestLevelAvaiable) then
                playButton.y = playButtonPosY + v.buttonStartImageOffsetY
            else
                playButton.y = myGlobalData._cdh + 2000
            end

            local function resetButton()
                buttonClicked = false
            end
            timer.performWithDelay(100, resetButton )


        end

        ---------------------------------------------------------------------------------
        -- Level select and start Events
        ---------------------------------------------------------------------------------
        local function onButtonTouch( event )
            local buttonName = event.target.id
            if ( event.phase == "began" and buttonClicked == false ) then
                print( "Touch event began on: " .. buttonName )
                
                --buttonClicked = true -- disable the button for fast clicky users !

            elseif ( event.phase == "ended" and buttonClicked == false) then
                buttonClicked = true -- disable the button for fast clicky users !

                print( "Touch event ended on: " .. buttonName )

                audioSFXHandeButtonTap = audio.play(myGlobalData.sfx_Click)

                if ( buttonName == "previous" and selectedLevel >= myGlobalData.minLevels) then
                    if( selectedLevel > myGlobalData.minLevels ) then
                        selectedLevel = selectedLevel - 1
                    end
                    updateLevelBox()
                end

                if ( buttonName == "next" and selectedLevel <= myGlobalData.maxLevels) then
                     if( selectedLevel < myGlobalData.maxLevels ) then
                        selectedLevel = selectedLevel + 1
                    end
                   updateLevelBox()
                end

                if ( buttonName == "play" and selectedLevel <= myGlobalData.highesetLevel) then
                    playLevel()
                end

            end
            return true
        end



        ---------------------------------------------------------------------------------
        -- Create the Level Select Panel.
        ---------------------------------------------------------------------------------
        local panelWording          = display.newText( v.wordingLevelSelect, 0,0, v.wordingTitleFont, v.wordingTitleFontSize )
        panelWording.anchorX        = 0
        panelWording.x              = anchorXOffset
        panelWording.y              = myGlobalData._cdh - 70
        panelWording.fill           = v.wordingTitleColour
        groupLevelSelect:insert( panelWording )

        local underline             = display.newLine( 0, 0, 200,0 )
        underline.anchorX           = 0
        underline.x                 = anchorXOffset
        underline.y                 = panelWording.y + 10
        underline.stroke            = v.lineColour
        underline.strokeWidth       = v.lineWidth
        groupLevelSelect:insert( underline )

        local panelTitle            = display.newText( v.wordingLevelTitle, 0,0, v.wordingLevelWordingFont, v.wordingLevelWordingFontSize )
        panelTitle.anchorX          = 0
        panelTitle.x                = anchorXOffset + 36
        panelTitle.y                = panelWording.y + 29
        panelTitle.fill             = v.wordingLevelWordingColour
        groupLevelSelect:insert( panelTitle )

        local numberPanel = nil
        if ( v.levelPanelShape == "Square") then
            numberPanel           = display.newRect( 0, 0, 54,34 )
        else
            numberPanel           = display.newRoundedRect( 0, 0, 54,34, v.levelPanelShapeCorners )
        end

        numberPanel.anchorX         = 0
        numberPanel.x               = anchorXOffset + 106
        numberPanel.y               = panelTitle.y +2
        numberPanel.fill            = v.levelPanelFillColour
        numberPanel.strokeWidth     = v.levelPanelStrokeWidth
        numberPanel.stroke          = v.levelPanelStrokeColour
        groupLevelSelect:insert( numberPanel )

        displayLevelNumber          = display.newText( selectedLevel, 0,0, v.displayLevelNumberFont, v.displayLevelNumberFontSize )
        --panelContents.anchorX     = 0.5
        displayLevelNumber.x        = numberPanel.x + (numberPanel.width * 0.5)
        displayLevelNumber.y        = numberPanel.y - 1
        displayLevelNumber.fill     = v.displayLevelNumberColour
        groupLevelSelect:insert( displayLevelNumber )

        ---------------------------------------------------------------------------------
        -- Previous Level Button
        ---------------------------------------------------------------------------------
        local buttonPrevious = widget.newButton(
            {
                --label         = "button",
                onEvent         = onButtonTouch,
                emboss          = false,
                defaultFile     = myGlobalData.imagePath..v.buttonLevelsImageOff,
                overFile        = myGlobalData.imagePath..v.buttonLevelsImageOn,
                width           = v.buttonLevelsImageWidth,
                height          = v.buttonLevelsImageHeight,
                id              = "previous"
            }
        )
        buttonPrevious.anchorX  = 0.5
        buttonPrevious.anchorY  = 0.5
        buttonPrevious.x        = anchorXOffset + (buttonPrevious.width/2) - 4
        buttonPrevious.y        = numberPanel.y + v.buttonLevelsImageOffsetY
        buttonPrevious.alpha    = v.buttonLevelsImageAlpha
        buttonPrevious.xScale   = - 1.0
        groupLevelSelect:insert( buttonPrevious )

        ---------------------------------------------------------------------------------
        -- Next Level Button
        ---------------------------------------------------------------------------------
        local buttonNext = widget.newButton(
            {
                --label         = "button",
                onEvent         = onButtonTouch,
                emboss          = false,
                defaultFile     = myGlobalData.imagePath..v.buttonLevelsImageOff,
                overFile        = myGlobalData.imagePath..v.buttonLevelsImageOn,
                width           = v.buttonLevelsImageWidth,
                height          = v.buttonLevelsImageHeight,
                id              = "next"
            }
        )
        buttonNext.anchorX  = 0.5
        buttonNext.anchorY  = 0.5
        buttonNext.x        = anchorXOffset + 220 - (buttonPrevious.width)
        buttonNext.y        = numberPanel.y + v.buttonLevelsImageOffsetY
        buttonNext.rotation = 0
        buttonNext.alpha    = v.buttonLevelsImageAlpha
        groupLevelSelect:insert( buttonNext )

        ---------------------------------------------------------------------------------
        -- Play Level Button
        ---------------------------------------------------------------------------------
        playButton = widget.newButton(
            {
                --label         = "button",
                onEvent         = onButtonTouch,
                emboss          = false,
                defaultFile     = myGlobalData.imagePath..v.buttonStartImageOff,
                overFile        = myGlobalData.imagePath..v.buttonStartImageOn,
                width           = v.buttonStartImageWidth,
                height          = v.buttonStartImageHeight,
                id              = "play"
            }
        )
        playButtonPosY      = numberPanel.y + 30 -- we store this so we can move it later if required.
        playButton.anchorX  = 0.5
        playButton.anchorY  = 0.5
        playButton.x        = myGlobalData._cdw
        playButton.y        = playButtonPosY + v.buttonStartImageOffsetY
        playButton.alpha    = v.buttonStartImageAlpha
        groupLevelSelect:insert( playButton )






        ---------------------------------------------------------------------------------
        -- Create the Total Drops Panel.
        ---------------------------------------------------------------------------------
        local shufflePositionTop    = 30
        local shufflePositionMid    = 65
        local shufflePositionBot    = 105
        local shufflePositionStart  = 0
        local shuffleRequired       = false

        if ( v.perfectSquaresShowBlock == false or v.totalDropsShowBlock == false ) then
            shuffleRequired = true
            if ( v.shuffleBlocks == "Top" ) then
                shufflePositionStart = shufflePositionTop
            elseif ( v.shuffleBlocks == "Middle" ) then
                shufflePositionStart = shufflePositionMid
            elseif ( v.shuffleBlocks == "Bottom" ) then
                shufflePositionStart = shufflePositionBot
            else
                shufflePositionStart = shufflePositionTop
            end
        end


        local panelWording          = display.newText( v.wordingTotalDrops, 0,0, v.wordingTitleFont, v.wordingTitleFontSize )
        panelWording.anchorX        = 0
        panelWording.x              = anchorXOffset

        if( shuffleRequired ) then
            panelWording.y              = myGlobalData._cdh + shufflePositionStart
        else
            panelWording.y              = myGlobalData._cdh + shufflePositionTop
        end    

        panelWording.fill           = v.wordingTitleColour
        groupTotalDrops:insert( panelWording )

        local underline             = display.newLine( 0, 0, 200,0 )
        underline.anchorX           = 0
        underline.x                 = anchorXOffset
        underline.y                 = panelWording.y + 10
        underline.stroke            = v.lineColour
        underline.strokeWidth       = v.lineWidth
        groupTotalDrops:insert( underline )

        local panelTitle            = display.newText( v.wordingDropsTitle, 0,0, v.wordingSubTitleFont, v.wordingSubTitleFontSize )
        panelTitle.anchorX          = 0
        panelTitle.x                = anchorXOffset
        panelTitle.y                = panelWording.y + 29
        panelTitle.fill             = v.wordingSubTitleColour
        groupTotalDrops:insert( panelTitle )

        local numberPanel = nil
        if ( v.levelPanelShape == "Square") then
            numberPanel           = display.newRect( 0, 0, 132,27 )
        else
            numberPanel           = display.newRoundedRect( 0, 0, 132,27, v.levelPanelShapeCorners )
        end

        numberPanel.anchorX         = 0
        numberPanel.x               = anchorXOffset + 68
        numberPanel.y               = panelTitle.y
        numberPanel.fill            = v.levelPanelFillColour
        numberPanel.strokeWidth     = v.levelPanelStrokeWidth
        numberPanel.stroke          = v.levelPanelStrokeColour
        groupTotalDrops:insert( numberPanel )

        local panelContents         = display.newText( numberFormat(myGlobalData.totalAttempts), 0,0, v.displayProgressFont, v.displayProgressFontSize )
        panelContents.anchorX       = 0
        panelContents.x             = anchorXOffset + 75
        panelContents.y             = panelTitle.y - 1
        panelContents.fill          = v.displayProgressColour

        groupTotalDrops:insert( panelContents )
        ---------------------------------------------------------------------------------


        ---------------------------------------------------------------------------------
        -- Create the Perfect Drops Panel.
        ---------------------------------------------------------------------------------
        local panelWording          = display.newText( v.wordingPerfectDrops, 0,0, v.wordingTitleFont, v.wordingTitleFontSize )
        panelWording.anchorX        = 0
        panelWording.x              = anchorXOffset

        if( shuffleRequired ) then
            panelWording.y              = myGlobalData._cdh + shufflePositionStart
        else
            panelWording.y              = myGlobalData._cdh + shufflePositionBot
        end    

        panelWording.fill           = v.wordingTitleColour
        groupPerfectSquares:insert( panelWording )

        local underline             = display.newLine( 0, 0, 200,0 )
        underline.anchorX           = 0
        underline.x                 = anchorXOffset
        underline.y                 = panelWording.y + 10
        underline.stroke            = v.lineColour
        underline.strokeWidth       = v.lineWidth
        groupPerfectSquares:insert( underline )

        local panelTitle            = display.newText( v.wordingperfectTitle, 0,0, v.wordingSubTitleFont, v.wordingSubTitleFontSize )
        panelTitle.anchorX          = 0
        panelTitle.x                = anchorXOffset
        panelTitle.y                = panelWording.y + 29
        panelTitle.fill             = v.wordingSubTitleColour
        groupPerfectSquares:insert( panelTitle )

        if ( v.levelPanelShape == "Square") then
            numberPanel           = display.newRect( 0, 0, 132,27 )
        else
            numberPanel           = display.newRoundedRect( 0, 0, 132,27, v.levelPanelShapeCorners )
        end

        numberPanel.anchorX         = 0
        numberPanel.x               = anchorXOffset + 68
        numberPanel.y               = panelTitle.y
        numberPanel.fill            = v.levelPanelFillColour
        numberPanel.strokeWidth     = v.levelPanelStrokeWidth
        numberPanel.stroke          = v.levelPanelStrokeColour
        groupPerfectSquares:insert( numberPanel )

        local panelContents         = display.newText( numberFormat(myGlobalData.perfectSquares), 0,0, v.displayProgressFont, v.displayProgressFontSize )
        panelContents.anchorX       = 0
        panelContents.x             = anchorXOffset + 75
        panelContents.y             = panelTitle.y - 1
        panelContents.fill          = v.displayProgressColour
        groupPerfectSquares:insert( panelContents )
        ---------------------------------------------------------------------------------




    elseif ( phase == "did" ) then

        ---------------------------------------------------------------------------------
        -- Animate all the scene elements into position
        ---------------------------------------------------------------------------------
        local adjY              = myGlobalData.bannerAd_Menu_Adjustment
        transitionLevelSelect   = transition.to( groupLevelSelect, { tag="sceneAnimate", delay=400, time=300, y=adjY, transition=easing.outElastic } )
        

        --Show / hide the blocks - shuffle into the correct position as required.
        if( v.totalDropsShowBlock ) then
            transitionTotalDrops    = transition.to( groupTotalDrops, { tag="sceneAnimate", delay=200, time=400, y=adjY, transition=easing.outBounce } )
        end

        if( v.perfectSquaresShowBlock ) then
            transitionPerfect       = transition.to( groupPerfectSquares, { tag="sceneAnimate", delay=400, time=500, y=adjY, transition=easing.outBounce } )
        end

        ---------------------------------------------------------------------------------
        -- Are we Showing the menu screen logos?
        ---------------------------------------------------------------------------------
        if ( v.gameTitleShow == true or v.squareLogoShow==true ) then
            transitionLogo          = transition.to( groupLogo, { tag="sceneAnimate", time=400, y=adjY, transition=easing.outElastic } )
        end

        if ( v.studioLogoShow == true ) then
            transitionStudioLogo    = transition.to( studioLogo, { tag="sceneAnimate", delay=300, time=600, alpha=1.0, xScale=v.studioLogoMaxScale, yScale=v.studioLogoMaxScale, transition=easing.outBounce } )
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
                    adsConfig.showAdmobBannerAd( myGlobalData.bannerAd_Menu_Position )
                end
            end
        end

        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
    end
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
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


---------------------------------------------------------------------------------
-- Function "scene:destroy()"
---------------------------------------------------------------------------------
function scene:destroy( event )

    local sceneGroup = self.view

    --Clean up audio
    if(audioSFXHandeButtonTap ~= nil) then
        audio.stop(audioSFXHandeButtonTap)
        audioSFXHandeButtonTap = nil
    end

    -- Stop / nil the music channel if not set to continuous.
    if (v.musicContinueThroughScenes == false ) then
        audio.stop( playbackgroundMusic )
        playbackgroundMusic = nil
    end

    -- Stop / nil the music channel if the GAME music is different from the MENU music!
    if (v.musicMenuScreen ~= v.musicGameScreen ) then
        audio.stop( playbackgroundMusic )
        playbackgroundMusic = nil
    end



    --Runtime:removeEventListener( "enterFrame", handleEnterFrame)

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
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