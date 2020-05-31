---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- hide the status bar
---------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )

---------------------------------------------------------------------------------
-- require the composer library
---------------------------------------------------------------------------------
local composer 			= require "composer"
local myGlobalData 		= require( "lib.globalData" )
local loadsave 			= require( "lib.loadsave" )
local device 			= require( "lib.device" )
local v 				= require( "gameVariables" )    -- Dynamic Game Variables

---------------------------------------------------------------------------------
-- Setup Ads integration
-- Note: For the purposes of this template only Ad-Mob V2 has been integrated
-- Add Apple iAds, Vungle, RevMob etc as required.
---------------------------------------------------------------------------------
myGlobalData.adsShow					= v.adsShow
myGlobalData.ads_AdMobEnabled			= v.ads_AdMobEnabled  -- Are we showing ads in the app?
myGlobalData.ads_VungleEnabled			= v.ads_VungleEnabled
myGlobalData.adBannersRequired			= v.adBannersRequired
myGlobalData.adIntersRequired			= v.adIntersRequired
---------------------------------------------------------------------------------
myGlobalData.bannerAppID                = ""  --leave as is - configure variables below
myGlobalData.interstitialAppID          = ""  --leave as is - configure variables below
myGlobalData.vungleAd 					= ""  --leave as is - configure variables below
myGlobalData.bannerAd_Menu_Position     = v.bannerAd_Menu_Position
myGlobalData.bannerAd_Game_Position     = v.bannerAd_Game_Position
myGlobalData.bannerAd_Menu_Adjustment	= 0
myGlobalData.bannerAd_Game_Adjustment	= 0
myGlobalData.bannerAd_Menu_Adjust_Top 	= false
myGlobalData.bannerAd_Menu_Adjust_Bot 	= false
myGlobalData.bannerAd_Game_Adjust_Top 	= false
myGlobalData.bannerAd_Game_Adjust_Bot 	= false
---------------------------------------------------------------------------------
myGlobalData.adMob_Banner_iOS           = v.adMob_Banner_iOS  --for your iOS banner
myGlobalData.adMob_Interstitial_iOS     = v.adMob_Interstitial_iOS  --for your iOS interstitial
myGlobalData.adMob_RewardVideo_iOS     	= v.adMob_RewardVideo_iOS  --for your iOS interstitial
---------------------------------------------------------------------------------
myGlobalData.adMob_Banner_Android       = v.adMob_Banner_Android  --for your Android banner
myGlobalData.adMob_Interstitial_Android = v.adMob_Interstitial_Android  --for your Android interstitial
myGlobalData.adMob_RewardVideo_Android 	= v.adMob_RewardVideo_Android  --for your Android interstitial
---------------------------------------------------------------------------------
myGlobalData.vungleAd_iOS               = v.vungleAd_iOS
myGlobalData.vungleAd_Android           = v.vungleAd_Android
---------------------------------------------------------------------------------
local adsConfig  						= require( "adsLibrary" )

--myGlobalData.bannerAd_Menu_Adjustment = 30
--myGlobalData.bannerAd_Game_Adjustment = 40

---------------------------------------------------------------------------------
--<< Start Ads initialisation----------------------------------------------------
---------------------------------------------------------------------------------
-- If Ads are enabled - AND AdMob adverts are enabled - setup here.
---------------------------------------------------------------------------------
if ( myGlobalData.adsShow == true ) then
   
	------------------------------------------------------------------------------
	--Initialise Ad Mob ads if enabled.
	------------------------------------------------------------------------------
    if ( myGlobalData.ads_AdMobEnabled ) then
		
		--------------------------------------------------------------------------
	    --Pre load the AdMob Interstitial ads
		--------------------------------------------------------------------------
		if (myGlobalData.adIntersRequired ) then
			adsConfig.initAdmobInterstitialAd()
	        adsConfig.loadAdmobInterstitialAd()
	    end
		--------------------------------------------------------------------------

		--------------------------------------------------------------------------
		--Initialise Banner Ads - if enabled.
		--------------------------------------------------------------------------
	    if ( myGlobalData.adBannersRequired ) then
	        --Pre load the AdMob Banner ads
			adsConfig.initAdmobBannerAd()

			------------------------------------------------------------------------
			--Adjust game sprite positioning depending on the banner ad placement
			------------------------------------------------------------------------
			--[[
			if ( myGlobalData.bannerAd_Menu_Position == "top" and device.isTall==false ) then
				myGlobalData.bannerAd_Menu_Adjustment = 30
				print("Banner AD - positioned at top: Adjusting Menu Y elements by: "..myGlobalData.bannerAd_Menu_Adjustment.." pixels.")
			elseif ( myGlobalData.bannerAd_Menu_Position == "bottom" and device.isTall==false ) then
				myGlobalData.bannerAd_Menu_Adjustment = -18
			end
			if ( myGlobalData.bannerAd_Game_Position == "top" and device.isTall==false) then
				myGlobalData.bannerAd_Game_Adjustment = 40
			elseif ( myGlobalData.bannerAd_Menu_Position == "bottom" and device.isTall==false ) then
				myGlobalData.bannerAd_Game_Adjustment = 0
			end
			--]]
			--[[
			if ( myGlobalData.bannerAd_Menu_Position == "top" ) then
				myGlobalData.bannerAd_Menu_Adjustment = 45
				myGlobalData.bannerAd_Menu_Adjust_Top = true
				myGlobalData.bannerAd_Menu_Adjust_Bot = false
			elseif ( myGlobalData.bannerAd_Menu_Position == "bottom" ) then
				myGlobalData.bannerAd_Menu_Adjustment = -20
				myGlobalData.bannerAd_Menu_Adjust_Top = false
				myGlobalData.bannerAd_Menu_Adjust_Bot = true
			end
			--]]
			if ( myGlobalData.bannerAd_Game_Position == "top") then
				myGlobalData.bannerAd_Game_Adjustment = 50
				myGlobalData.bannerAd_Game_Adjust_Top = true
				myGlobalData.bannerAd_Game_Adjust_Bot = false
			elseif ( myGlobalData.bannerAd_Menu_Position == "bottom" ) then
				myGlobalData.bannerAd_Game_Adjustment = 0
				myGlobalData.bannerAd_Game_Adjust_Top = false
				myGlobalData.bannerAd_Game_Adjust_Bot = true
			end
			------------------------------------------------------------------------
	    
	    end
		--------------------------------------------------------------------------

	end

	--------------------------------------------------------------------------
	--Initialise Vungle ads if enabled.
 	--------------------------------------------------------------------------
	if ( myGlobalData.ads_VungleEnabled) then
    	adsConfig.initVungleInterstitialAd()
    end
 	--------------------------------------------------------------------------

end
--<< End Ads initialisation----------------------------------------------------------

myGlobalData.audioPath	= v.audioPath
myGlobalData.imagePath	= v.imagePath

myGlobalData.minLevels	= v.minLevels 	-- Minimum number of levels
myGlobalData.maxLevels	= v.maxLevels 	-- Maximum Number of levels

---------------------------------------------------------------------------------
-- Setup Game Global variables to share thoughout the game engine
---------------------------------------------------------------------------------
myGlobalData._w 					= display.actualContentWidth  	-- Get the devices Width
myGlobalData._h 					= display.actualContentHeight 					-- Get the devices Height
myGlobalData._cw 					= display.actualContentWidth * 0.5 	-- Get the devices Width
myGlobalData._ch 					= display.actualContentHeight * 0.5					-- Get the devices Height
myGlobalData._dw 					= display.contentWidth  	-- Get the devices Width
myGlobalData._dh 					= display.contentHeight 					-- Get the devices Height
myGlobalData._cdw 					= display.contentWidth * 0.5   	-- Get the devices Width
myGlobalData._cdh 					= display.contentHeight * 0.5  					-- Get the devices Height

---------------------------------------------------------------------------------
-- Setup Audio Volumes and variables
--------------------------------------------------------------------------------
myGlobalData.volumeSFX				= v.volumeSFX							-- Define the SFX Volume
myGlobalData.volumeMusic			= v.volumeMusic							-- Define the Music Volume
myGlobalData.resetVolumeSFX			= myGlobalData.volumeSFX		-- Define the SFX Volume Reset Value
myGlobalData.resetVolumeMusic		= myGlobalData.volumeMusic		-- Define the Music Volume Reset Value
myGlobalData.soundON				= true							-- Is the sound ON or Off?
myGlobalData.musicON				= true							-- Is the sound ON or Off?
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=0 } ) -- set the volume on channel 1
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=1 } ) -- set the volume on channel 1
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=2 } ) -- set the volume on channel 2
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=3 } ) -- set the volume on channel 3

for i = 4, 32 do
	audio.setVolume( myGlobalData.volumeSFX, { channel=i } )
end 
-- Reserve channels 1 - 4 for the Music. All Other channels can be used for SFX Audio
audio.reserveChannels( 4 )

---------------------------------------------------------------------------------
-- Setup Scaling factors if required.
--------------------------------------------------------------------------------
myGlobalData.factorX				= 0.4166	
myGlobalData.factorY				= 0.46875	

---------------------------------------------------------------------------------
-- Save / Load game data
--------------------------------------------------------------------------------
_G.saveDataTable					= {}							-- Define the Save/Load base Table to hold our data
myGlobalData.saveDataFileName		= v.saveDataFileName		 	-- Save file name in JSON format on the device
---------------------------------------------------------------------------------
-- Load in the saved data to our game table
-- Check the files exists before !
---------------------------------------------------------------------------------
if loadsave.fileExists(myGlobalData.saveDataFileName..".json", system.DocumentsDirectory) then
	saveDataTable = loadsave.loadTable(myGlobalData.saveDataFileName..".json")
else
	saveDataTable.currentLevel 			= 1
	saveDataTable.highesetLevel			= 1
	saveDataTable.currentDrop 			= 1
	saveDataTable.adsShow 				= myGlobalData.adsShow
	saveDataTable.totalAttempts 		= 0
    saveDataTable.perfectSquares        = 0
    saveDataTable.currentLevelDrops     = v.setupCurrentLevelDrops


	---------------------------------------------------------------------------------
	-- Save the new json file, for referencing later..
	---------------------------------------------------------------------------------
	loadsave.saveTable(saveDataTable, myGlobalData.saveDataFileName..".json")
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Load in the Data
---------------------------------------------------------------------------------
saveDataTable = loadsave.loadTable(myGlobalData.saveDataFileName..".json")
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Assign the Level and other variables to the game variables.
---------------------------------------------------------------------------------
myGlobalData.currentLevel				= saveDataTable.currentLevel 	-- Saved Level value
myGlobalData.highesetLevel				= saveDataTable.highesetLevel 	-- Saved Highest level reached
myGlobalData.adsShow					= saveDataTable.adsShow			-- Do we show/hide the ads ?
myGlobalData.totalAttempts				= saveDataTable.totalAttempts	-- Total attempts
myGlobalData.perfectSquares				= saveDataTable.perfectSquares	-- Number pf perfect Squares achieved.
myGlobalData.currentDrop				= saveDataTable.currentDrop 	-- Saved Drop Number for the Level
myGlobalData.currentLevelDrop			= saveDataTable.currentLevelDrops[myGlobalData.currentLevel] 	-- Saved Drop Number for the Level




---------------------------------------------------------------------------------
-- Surpress the print statements?
---------------------------------------------------------------------------------
myGlobalData.supressPrint 				= v.supressPrint	-- show the Memory and FPS box?
if (myGlobalData.supressPrint) then
	_G.print = function() end 
end

---------------------------------------------------------------------------------
-- Enable debug by setting to [true] to see FPS and Memory usage.
---------------------------------------------------------------------------------
myGlobalData.doDebug 					= v.doDebug	-- show the Memory and FPS box?

if (myGlobalData.doDebug) then
	composer.isDebug = true
	local fps = require("lib.fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = (display.contentWidth/2)-50,  display.contentWidth/2-70;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


---------------------------------------------------------------------------------
-- Establish which device the game is being run on.
---------------------------------------------------------------------------------
if ( device.isApple ) then
	myGlobalData.Android	= false
	print("Running on iOS")	
	if ( device.is_iPad ) then
		myGlobalData.iPad = true
		print("Device Type: iPad")
	else
		myGlobalData.iPad = false
		if (display.pixelHeight > 960) then
			myGlobalData.iPhone5 = true
			print("Device Type: iPhone 5-6")
		else
			myGlobalData.iPhone5 = false
			print("Device Type: iPhone 3-4")
		end
	end
else
	myGlobalData.Android = true
	myGlobalData.iPad = false
	myGlobalData.iPhone5 = false
	print("Running on Android")
end


------------------------------------------------------------------------------------------------------------------------------------
-- Function to load the initial scene
------------------------------------------------------------------------------------------------------------------------------------
local function startGame()
	composer.gotoScene( "gameMenu")	--This is our main menu
end


------------------------------------------------------------------------------------------------------------------------------------
-- Preload Audio, music, sfx
------------------------------------------------------------------------------------------------------------------------------------
myGlobalData.soundSFXOn     = v.sfxAudioOn
myGlobalData.soundMusicOn   = v.musicAudioOn

myGlobalData.music_Menu		= nil
myGlobalData.music_Game		= nil

if ( v.musicPlayMenuScreen ) then
	myGlobalData.music_Menu	= audio.loadSound( myGlobalData.audioPath..v.musicMenuScreen )
end

if ( v.musicPlayGameScreen ) then
	myGlobalData.music_Game	= audio.loadSound( myGlobalData.audioPath..v.musicGameScreen )
end

myGlobalData.sfx_Click		= audio.loadSound( myGlobalData.audioPath..v.sfx_Click )
myGlobalData.sfx_Drop		= audio.loadSound( myGlobalData.audioPath..v.sfx_Drop )
myGlobalData.sfx_LandBad	= audio.loadSound( myGlobalData.audioPath..v.sfx_LandBad )
myGlobalData.sfx_LandGood	= audio.loadSound( myGlobalData.audioPath..v.sfx_LandGood )
myGlobalData.sfx_LevelUp	= audio.loadSound( myGlobalData.audioPath..v.sfx_LevelUp )
myGlobalData.sfx_Perfect	= audio.loadSound( myGlobalData.audioPath..v.sfx_Perfect )


------------------------------------------------------------------------------------------------------------------------------------
--Start Game after a short delay.
------------------------------------------------------------------------------------------------------------------------------------
timer.performWithDelay(5, startGame )


-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)

