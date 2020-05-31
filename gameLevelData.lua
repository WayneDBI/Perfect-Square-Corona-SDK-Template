----------------------------------------------------------------------------------- Data for the Levels---------------------------------------------------------------------------------local t = {}----------------------------------------------------------------------------------- Convert RGB Values to Coronas method---------------------------------------------------------------------------------local function getRGB(value)    return value/255end----------------------------------------------------------------------------------- Convert HEX Colour Values to Coronas method---------------------------------------------------------------------------------local function hex2rgb (hex)    local hex = hex:gsub("#","")    local r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))    return r/255, g/255, b/255end----------------------------------------------------------------------------------- 2 x Colour Gradient for the Background FAIL SCREEN---------------------------------------------------------------------------------t.backgroundFailColour_Top = { 	hex2rgb("#E30B0B")  } -- Mid Redt.backgroundFailColour_Bot = { 	hex2rgb("#960A00")  } -- Deep Red----------------------------------------------------------------------------------- 2 x Colour Gradient for the Background COMPLETE GAME SCREEN---------------------------------------------------------------------------------t.backgroundCompleteColour_Top = { 	hex2rgb("#8accff")  }t.backgroundCompleteColour_Bot = { 	hex2rgb("#6670FF")  }----------------------------------------------------------------------------------- TOP Colour Gradient for the Background Screen---------------------------------------------------------------------------------t.levelBackground_Top = {	{ hex2rgb("#8accff") }, -- 1	{ hex2rgb("#ff9500") }, -- 2	{ hex2rgb("#ffdb4c") }, -- 3	{ hex2rgb("#87fc70") }, -- 4	{ hex2rgb("#52edc7") }, -- 5	{ hex2rgb("#1ad6fd") }, -- 6	{ hex2rgb("#c644fc") }, -- 7	{ hex2rgb("#ef4db6") }, -- 8	{ hex2rgb("#4a4a4a") }, -- 9	{ hex2rgb("#dbddde") }, -- 10	{ hex2rgb("#ff3b30") }, -- 11	{ hex2rgb("#ff9500") }, -- 12	{ hex2rgb("#ffcc00") }, -- 13	{ hex2rgb("#4cd964") }, -- 14	{ hex2rgb("#34aadc") }, -- 15	{ hex2rgb("#007aff") }, -- 16	{ hex2rgb("#5856d6") }, -- 17	{ hex2rgb("#ff2d55") }, -- 18	{ hex2rgb("#8e8e93") }, -- 19	{ hex2rgb("#c7c7cc") }, -- 20	{ hex2rgb("#5ad427") }, -- 21	{ hex2rgb("#c86edf") }, -- 22	{ hex2rgb("#D1EEFC") }, -- 23	{ hex2rgb("#b9e0ad") }, -- 24	{ hex2rgb("#fb2b69") }, -- 25	{ hex2rgb("#898c90") }, -- 26	{ hex2rgb("#1d77ef") }, -- 27	{ hex2rgb("#d6cec3") }, -- 28	{ hex2rgb("#55efcb") }, -- 29	{ hex2rgb("#FF4981") }, -- 30	{ hex2rgb("#FFD3E0") }, -- 31	{ hex2rgb("#1ad6fd") }, -- 32	{ hex2rgb("#FF1300") }, -- 33	{ hex2rgb("#87fc70") }, -- 34	{ hex2rgb("#BDBEC2") }, -- 35	{ hex2rgb("#FF3A2D") }, -- 36}----------------------------------------------------------------------------------- BOTTOM Colour Gradient for the Background Screen---------------------------------------------------------------------------------t.levelBackground_Bot = {	{ hex2rgb("#6670FF") }, -- 1	{ hex2rgb("#ff5e3a") }, -- 2	{ hex2rgb("#ffcd02") }, -- 3	{ hex2rgb("#0bd318") }, -- 4	{ hex2rgb("#5ac8fb") }, -- 5	{ hex2rgb("#1d62f0") }, -- 6	{ hex2rgb("#5856d6") }, -- 7	{ hex2rgb("#c643fc") }, -- 8	{ hex2rgb("#2b2b2b") }, -- 9	{ hex2rgb("#898c90") }, -- 10	{ hex2rgb("#ff3b30") }, -- 11	{ hex2rgb("#ff9500") }, -- 12	{ hex2rgb("#ffcc00") }, -- 13	{ hex2rgb("#4cd964") }, -- 14	{ hex2rgb("#34aadc") }, -- 15	{ hex2rgb("#007aff") }, -- 16	{ hex2rgb("#5856d6") }, -- 17	{ hex2rgb("#ff2d55") }, -- 18	{ hex2rgb("#8e8e93") }, -- 19	{ hex2rgb("#c7c7cc") }, -- 20	{ hex2rgb("#a4e786") }, -- 21	{ hex2rgb("#e4b7f0") }, -- 22	{ hex2rgb("#D1EEFC") }, -- 23	{ hex2rgb("#82BF69") }, -- 24	{ hex2rgb("#ff5b37") }, -- 25	{ hex2rgb("#d7d7d7") }, -- 26	{ hex2rgb("#81f3fd") }, -- 27	{ hex2rgb("#e4ddca") }, -- 28	{ hex2rgb("#5bcaff") }, -- 29	{ hex2rgb("#FF4981") }, -- 30	{ hex2rgb("#FFD3E0") }, -- 31	{ hex2rgb("#1d62f0") }, -- 32	{ hex2rgb("#FF1300") }, -- 33	{ hex2rgb("#0bd318") }, -- 34	{ hex2rgb("#BDBEC2") }, -- 35	{ hex2rgb("#FF3A2D") }, -- 36}-- Difficulty increase levels-- the numbers are range of width of the LANDING AREA-- Smaller numbers = Harder !t.levelDifficulty = {	{12,25},	-- 1	{10,25},	-- 2	{8,24},	-- 3	{8,23},	-- 4	{7,23},		-- 5	{7,22},		-- 6	{7,22},	-- 7	{7,21},	-- 8	{7,21},	-- 9	{6,20},	-- 10	{6,20},	-- 11	{6,19},	-- 12	{6,18},	-- 13	{6,18},	-- 14	{5,17},	-- 15	{5,17},	-- 16	{5,17},	-- 17	{5,17},	-- 18	{5,16},	-- 19	{4,15},	-- 20	{4,14},	-- 21	{4,14},	-- 22	{4,14},	-- 23	{4,14},	-- 24	{3,14},	-- 25	{3,20},	-- 26	{3,13},	-- 27	{3,13},	-- 28	{3,13},	-- 29	{2,12},	-- 30	{2,12},	-- 31	{2,11},	-- 32	{2,11},	-- 33	{2,11},	-- 34	{2,11},	-- 35	{2,10},	-- 36}return t