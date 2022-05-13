WarMenu = {} WarMenu.__index = WarMenu WarMenu.debug = false function WarMenu.SetDebugEnabled(enabled) end function WarMenu.IsDebugEnabled() return false end local menus = {} local keys = {down = 187, up = 188, left = 189, right = 190, select = 191, back = 194} local optionCount = 0 local currentKey = nil local currentMenu = nil local toolTipWidth = 0.153 local spriteWidth = 0.027 local spriteHeight = spriteWidth * GetAspectRatio() local titleHeight = 0.101 local titleYOffset = 0.021 local titleFont = 1 local titleScale = 1.0 local buttonHeight = 0.038 local buttonFont = 0 local buttonScale = 0.365 local buttonTextXOffset = 0.005 local buttonTextYOffset = 0.005 local buttonSpriteXOffset = 0.002 local buttonSpriteYOffset = 0.005 local defaultStyle = { x = 0.0175, y = 0.025, width = 0.23, maxOptionCountOnScreen = 10, titleColor = {0, 0, 0, 255}, titleBackgroundColor = {245, 127, 23, 255}, titleBackgroundSprite = nil, subTitleColor = {54, 224, 16, 230}, textColor = {254, 254, 254, 255}, subTextColor = {189, 189, 189, 255}, focusTextColor = {0, 0, 0, 255}, focusColor = {245, 245, 245, 255}, backgroundColor = {0, 0, 0, 160}, subTitleBackgroundColor = {0, 0, 0, 255}, buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} } local function setMenuProperty(id, property, value) if not id then return end local menu = menus[id] if menu then menu[property] = value end end local function setStyleProperty(id, property, value) if not id then return end local menu = menus[id] if menu then if not menu.overrideStyle then menu.overrideStyle = {} end menu.overrideStyle[property] = value end end local function getStyleProperty(property, menu) menu = menu or currentMenu if menu.overrideStyle then local value = menu.overrideStyle[property] if value then return value end end return menu.style and menu.style[property] or defaultStyle[property] end local function copyTable(t) if type(t) ~= "table" then return t end local result = {} for k, v in pairs(t) do result[k] = copyTable(v) end return result end local function setMenuVisible(id, visible, holdCurrentOption) if currentMenu then if visible then if currentMenu.id == id then return end else if currentMenu.id ~= id then return end end end if visible then local menu = menus[id] if not currentMenu then menu.currentOption = 1 else if not holdCurrentOption then menus[currentMenu.id].currentOption = 1 end end currentMenu = menu else currentMenu = nil end end local function setTextParams(font, color, scale, center, shadow, alignRight, wrapFrom, wrapTo) SetTextFont(font) SetTextColour(color[1], color[2], color[3], color[4] or 255) SetTextScale(scale, scale) if shadow then SetTextDropShadow() end if center then SetTextCentre(true) elseif alignRight then SetTextRightJustify(true) end if not wrapFrom or not wrapTo then wrapFrom = wrapFrom or getStyleProperty("x") wrapTo = wrapTo or getStyleProperty("x") + getStyleProperty("width") - buttonTextXOffset end SetTextWrap(wrapFrom, wrapTo) end local function getLinesCount(text, x, y) BeginTextCommandLineCount("TWOSTRINGS") AddTextComponentString(tostring(text)) return EndTextCommandGetLineCount(x, y) end local function drawText(text, x, y) BeginTextCommandDisplayText("TWOSTRINGS") AddTextComponentString(tostring(text)) EndTextCommandDisplayText(x, y) end local function drawRect(x, y, width, height, color) DrawRect(x, y, width, height, color[1], color[2], color[3], color[4] or 255) end local function getCurrentIndex() if currentMenu.currentOption <= getStyleProperty("maxOptionCountOnScreen") and optionCount <= getStyleProperty("maxOptionCountOnScreen") then return optionCount elseif optionCount > currentMenu.currentOption - getStyleProperty("maxOptionCountOnScreen") and optionCount <= currentMenu.currentOption then return optionCount - (currentMenu.currentOption - getStyleProperty("maxOptionCountOnScreen")) end return nil end local function drawTitle() local x = getStyleProperty("x") + getStyleProperty("width") / 2 local y = getStyleProperty("y") + titleHeight / 2 if getStyleProperty("titleBackgroundSprite") then DrawSprite( getStyleProperty("titleBackgroundSprite").dict, getStyleProperty("titleBackgroundSprite").name, x, y, getStyleProperty("width"), titleHeight, 0., 255, 255, 255, 255) else drawRect(x, y, getStyleProperty("width"), titleHeight, getStyleProperty("titleBackgroundColor")) end if currentMenu.title then setTextParams(titleFont, getStyleProperty("titleColor"), titleScale, true) drawText(currentMenu.title, x, y - titleHeight / 2 + titleYOffset) end end local function drawSubTitle() local x = getStyleProperty("x") + getStyleProperty("width") / 2 local y = getStyleProperty("y") + titleHeight + buttonHeight / 2 drawRect(x, y, getStyleProperty("width"), buttonHeight, getStyleProperty("subTitleBackgroundColor")) setTextParams(buttonFont, getStyleProperty("subTitleColor"), buttonScale, false) drawText(currentMenu.subTitle, getStyleProperty("x") + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset) if optionCount > getStyleProperty("maxOptionCountOnScreen") then setTextParams(buttonFont, getStyleProperty("subTitleColor"), buttonScale, false, false, true) drawText( tostring(currentMenu.currentOption) .. " / " .. tostring(optionCount), getStyleProperty("x") + getStyleProperty("width"), y - buttonHeight / 2 + buttonTextYOffset) end end local function drawButton(text, subText) local currentIndex = getCurrentIndex() if not currentIndex then return end local backgroundColor = nil local textColor = nil local subTextColor = nil local shadow = false if currentMenu.currentOption == optionCount then backgroundColor = getStyleProperty("focusColor") textColor = getStyleProperty("focusTextColor") subTextColor = getStyleProperty("focusTextColor") else backgroundColor = getStyleProperty("backgroundColor") textColor = getStyleProperty("textColor") subTextColor = getStyleProperty("subTextColor") shadow = true end local x = getStyleProperty("x") + getStyleProperty("width") / 2 local y = getStyleProperty("y") + titleHeight + buttonHeight + (buttonHeight * currentIndex) - buttonHeight / 2 drawRect(x, y, getStyleProperty("width"), buttonHeight, backgroundColor) setTextParams(buttonFont, textColor, buttonScale, false, shadow) drawText(text, getStyleProperty("x") + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset) if subText then setTextParams(buttonFont, subTextColor, buttonScale, false, shadow, true) drawText(subText, getStyleProperty("x") + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset) end end function WarMenu.CreateMenu(id, title, subTitle, style) local menu = {} menu.id = id menu.previousMenu = nil menu.currentOption = 1 menu.title = title menu.subTitle = subTitle and string.upper(subTitle) or "INTERACTION MENU" if style then menu.style = style end menus[id] = menu end function WarMenu.CreateSubMenu(id, parent, subTitle, style) local parentMenu = menus[parent] if not parentMenu then return end WarMenu.CreateMenu(id, parentMenu.title, subTitle and string.upper(subTitle) or parentMenu.subTitle) local menu = menus[id] menu.previousMenu = parent if parentMenu.overrideStyle then menu.overrideStyle = copyTable(parentMenu.overrideStyle) end if style then menu.style = style elseif parentMenu.style then menu.style = copyTable(parentMenu.style) end end function WarMenu.CurrentMenu() return currentMenu and currentMenu.id or nil end function WarMenu.OpenMenu(id) if id and menus[id] then PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) setMenuVisible(id, true) end end function WarMenu.IsMenuOpened(id) return currentMenu and currentMenu.id == id end WarMenu.Begin = WarMenu.IsMenuOpened function WarMenu.IsAnyMenuOpened() return currentMenu ~= nil end function WarMenu.IsMenuAboutToBeClosed() return false end function WarMenu.CloseMenu() if currentMenu then setMenuVisible(currentMenu.id, false) optionCount = 0 currentKey = nil PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) end end function WarMenu.ToolTip(text, width, flipHorizontal) if not currentMenu then return end local currentIndex = getCurrentIndex() if not currentIndex then return end width = width or toolTipWidth local x = nil if not flipHorizontal then x = getStyleProperty("x") + getStyleProperty("width") + width / 2 + buttonTextXOffset else x = getStyleProperty("x") - width / 2 - buttonTextXOffset end local textX = x - (width / 2) + buttonTextXOffset setTextParams( buttonFont, getStyleProperty("textColor"), buttonScale, false, true, false, textX, textX + width - (buttonTextYOffset * 2)) local linesCount = getLinesCount(text, textX, getStyleProperty("y")) local height = GetTextScaleHeight(buttonScale, buttonFont) * (linesCount + 1) + buttonTextYOffset local y = getStyleProperty("y") + titleHeight + (buttonHeight * currentIndex) + height / 2 drawRect(x, y, width, height, getStyleProperty("backgroundColor")) y = y - (height / 2) + buttonTextYOffset drawText(text, textX, y) end function WarMenu.Button(text, subText) if not currentMenu then return end optionCount = optionCount + 1 drawButton(text, subText) local pressed = false if currentMenu.currentOption == optionCount then if currentKey == keys.select then pressed = true PlaySoundFrontend( -1, getStyleProperty("buttonPressedSound").name, getStyleProperty("buttonPressedSound").set, true) elseif currentKey == keys.left or currentKey == keys.right then PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) end end return pressed end function WarMenu.SpriteButton(text, dict, name, r, g, b, a) if not currentMenu then return end local pressed = WarMenu.Button(text) local currentIndex = getCurrentIndex() if not currentIndex then return end if not HasStreamedTextureDictLoaded(dict) then RequestStreamedTextureDict(dict) end DrawSprite(dict, name, getStyleProperty("x") + getStyleProperty("width") - spriteWidth / 2 - buttonSpriteXOffset, getStyleProperty("y") + titleHeight + buttonHeight + (buttonHeight * currentIndex) - spriteHeight / 2 + buttonSpriteYOffset, spriteWidth, spriteHeight, 0., r or 255, g or 255, b or 255, a or 255) return pressed end function WarMenu.InputButton(text, windowTitleEntry, defaultText, maxLength, subText) if not currentMenu then return end local pressed = WarMenu.Button(text, subText) local inputText = nil if pressed then DisplayOnscreenKeyboard(1, windowTitleEntry or "FMMC_MPM_NA", "", defaultText or "", "", "", "", maxLength or 255) while true do DisableAllControlActions(0) local status = UpdateOnscreenKeyboard() if status == 2 then break elseif status == 1 then inputText = GetOnscreenKeyboardResult() break end Citizen.Wait(0) end end return pressed, inputText end function WarMenu.MenuButton(text, id, subText) if not currentMenu then return end if subText ~= nil or subText ~= "" then if subText == nil then subText = "" end local pressed = WarMenu.Button(text, tostring(subText) .. "  ~g~»~s~") if pressed then currentMenu.currentOption = optionCount setMenuVisible(currentMenu.id, false) setMenuVisible(id, true, true) end return pressed else local pressed = WarMenu.Button(text, subText) if pressed then currentMenu.currentOption = optionCount setMenuVisible(currentMenu.id, false) setMenuVisible(id, true, true) end return pressed end end function WarMenu.CheckBox(text, checked, callback) if not currentMenu then return end local name = nil if currentMenu.currentOption == optionCount + 1 then name = checked and "shop_box_tickb" or "shop_box_blankb" else name = checked and "shop_box_tick" or "shop_box_blank" end local pressed = WarMenu.SpriteButton(text, "commonmenu", name) if pressed then checked = not checked if callback then callback(checked) end end return pressed end function WarMenu.ComboBox(text, items, currentIndex, selectedIndex, callback) if not currentMenu then return end local itemsCount = #items local selectedItem = items[currentIndex] local isCurrent = currentMenu.currentOption == optionCount + 1 selectedIndex = selectedIndex or currentIndex if itemsCount > 1 and isCurrent then selectedItem = "← " .. tostring(selectedItem) .. " →" end local pressed = WarMenu.Button(text, selectedItem) if pressed then selectedIndex = currentIndex elseif isCurrent then if currentKey == keys.left then if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end elseif currentKey == keys.right then if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end end end if callback then callback(currentIndex, selectedIndex) end return pressed, currentIndex end function WarMenu.Display() if currentMenu then DisableControlAction(0, keys.left, true) DisableControlAction(0, keys.up, true) DisableControlAction(0, keys.down, true) DisableControlAction(0, keys.right, true) DisableControlAction(0, keys.back, true) ClearAllHelpMessages() drawTitle() drawSubTitle() currentKey = nil if IsDisabledControlJustReleased(0, keys.down) then PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) if currentMenu.currentOption < optionCount then currentMenu.currentOption = currentMenu.currentOption + 1 else currentMenu.currentOption = 1 end elseif IsDisabledControlJustReleased(0, keys.up) then PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) if currentMenu.currentOption > 1 then currentMenu.currentOption = currentMenu.currentOption - 1 else currentMenu.currentOption = optionCount end elseif IsDisabledControlJustReleased(0, keys.left) then currentKey = keys.left elseif IsDisabledControlJustReleased(0, keys.right) then currentKey = keys.right elseif IsDisabledControlJustReleased(0, keys.select) then currentKey = keys.select elseif IsDisabledControlJustReleased(0, keys.back) then if menus[currentMenu.previousMenu] then setMenuVisible(currentMenu.previousMenu, true) PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) else WarMenu.CloseMenu() end end optionCount = 0 end end WarMenu.End = WarMenu.Display function WarMenu.CurrentOption() if currentMenu and optionCount ~= 0 then return currentMenu.currentOption end return nil end function WarMenu.IsItemHovered() if not currentMenu or optionCount == 0 then return false end return currentMenu.currentOption == optionCount end function WarMenu.IsItemSelected() return currentKey == keys.select and WarMenu.IsItemHovered() end function WarMenu.SetTitle(id, title) setMenuProperty(id, "title", title) end WarMenu.SetMenuTitle = WarMenu.SetTitle function WarMenu.SetSubTitle(id, text) setMenuProperty(id, "subTitle", string.upper(text)) end WarMenu.SetMenuSubTitle = WarMenu.SetSubTitle function WarMenu.SetMenuStyle(id, style) setMenuProperty(id, "style", style) end function WarMenu.SetMenuX(id, x) setStyleProperty(id, "x", x) end function WarMenu.SetMenuY(id, y) setStyleProperty(id, "y", y) end function WarMenu.SetMenuWidth(id, width) setStyleProperty(id, "width", width) end function WarMenu.SetMenuMaxOptionCountOnScreen(id, count) setStyleProperty(id, "maxOptionCountOnScreen", count) end function WarMenu.SetTitleColor(id, r, g, b, a) setStyleProperty(id, "titleColor", {r, g, b, a}) end WarMenu.SetMenuTitleColor = WarMenu.SetTitleColor function WarMenu.SetMenuSubTitleColor(id, r, g, b, a) setStyleProperty(id, "subTitleColor", {r, g, b, a}) end function WarMenu.SetTitleBackgroundColor(id, r, g, b, a) setStyleProperty(id, "titleBackgroundColor", {r, g, b, a}) end WarMenu.SetMenuTitleBackgroundColor = WarMenu.SetTitleBackgroundColor function WarMenu.SetTitleBackgroundSprite(id, dict, name) RequestStreamedTextureDict(dict) setStyleProperty(id, "titleBackgroundSprite", {dict = dict, name = name}) end WarMenu.SetMenuTitleBackgroundSprite = WarMenu.SetTitleBackgroundSprite function WarMenu.SetMenuBackgroundColor(id, r, g, b, a) setStyleProperty(id, "backgroundColor", {r, g, b, a}) end function WarMenu.SetMenuTextColor(id, r, g, b, a) setStyleProperty(id, "textColor", {r, g, b, a}) end function WarMenu.SetMenuSubTextColor(id, r, g, b, a) setStyleProperty(id, "subTextColor", {r, g, b, a}) end function WarMenu.SetMenuFocusColor(id, r, g, b, a) setStyleProperty(id, "focusColor", {r, g, b, a}) end function WarMenu.SetMenuFocusTextColor(id, r, g, b, a) setStyleProperty(id, "focusTextColor", {r, g, b, a}) end function WarMenu.SetMenuButtonPressedSound(id, name, set) setStyleProperty(id, "buttonPressedSound", {name = name, set = set}) end
ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(c)ESX = c end)
        Citizen.Wait(1000)
    end
end)
-- Load Important stuff
local dui1 = GetDuiHandle(CreateDui('https://cdn.discordapp.com/attachments/844250119359823912/904808346291437578/Banner_1.gif', 512, 128))
CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd('wave1'), 'logo1', dui1)
-- End
--------------------------
-- ██╗███╗   ██╗███████╗██╗ ██████╗ ██╗   ██╗██████╗ ███████╗    ██████╗██╗     ██╗   ██╗██████╗
-- ██║████╗  ██║██╔════╝██║██╔═══██╗██║   ██║██╔══██╗██╔════╝   ██╔════╝██║     ██║   ██║██╔══██╗
-- ██║██╔██╗ ██║███████╗██║██║   ██║██║   ██║██║  ██║███████╗   ██║     ██║     ██║   ██║██████╔╝
-- ██║██║╚██╗██║╚════██║██║██║   ██║██║   ██║██║  ██║╚════██║   ██║     ██║     ██║   ██║██╔══██╗
-- ██║██║ ╚████║███████║██║╚██████╔╝╚██████╔╝██████╔╝███████║██╗╚██████╗███████╗╚██████╔╝██████╔╝
--
-- Developers: obscured aka 0x1300, Marco1223
--
--------------------------
function WarMenu.SetFont(id, font)
    buttonFont = font
    menus[id].titleFont = font
end
function WarMenu.SetMenuFocusBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, "menuFocusBackgroundColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusBackgroundColor.a})
end
function WarMenu.SetMaxOptionCount(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
function table.removekey(array, element)
    for i = 1, #array do
        if array[i] == element then
            table.remove(array, i)
        end
    end
end
local function RGBRainbow( frequency )
	local result = {}
	local curtime = GetGameTimer() / 1000
	result.r = 54
	result.g = 95
	result.b = 150
	
	return result
end
local function RGBRainbow( frequency )
	local result = {}
	local curtime = GetGameTimer() / 1000
	result.r = math.floor( math.sin( curtime * frequency + 0 ) * 127 + 128 )
	result.g = math.floor( math.sin( curtime * frequency + 2 ) * 127 + 128 )
	result.b = math.floor( math.sin( curtime * frequency + 4 ) * 127 + 128 )
	
	return result
end
-- Get colors from https://www.hexcolortool.com/
function WarMenu.SetTheme(id, theme)
    if theme == "basic" then
        WarMenu.SetMenuBackgroundColor(id, 0, 0, 0,  130)
        WarMenu.SetTitleBackgroundColor(id, 108, 122, 137,  250)
        WarMenu.SetTitleColor(id, 41, 128, 185, 1000)
        WarMenu.SetMenuSubTextColor(id, 255, 255, 255, 230)
        WarMenu.SetMenuFocusColor(id, 54, 224, 16, 230)
        WarMenu.SetFont(id, 6)
        WarMenu.SetMenuX(id, .05)
        WarMenu.SetMenuY(id, .1)
        WarMenu.SetMaxOptionCount(id, 12)
    elseif theme == "off" then
        -- Nothing
    end
end
function WarMenu.InitializeTheme()
    for i = 1, #menus do
        WarMenu.SetTheme(menus[i], "basic")
    end
end
Citizen.CreateThread(function()
    for i = 1, #menus do
        WarMenu.SetTitleBackgroundSprite(menus[i], 'wave1', 'logo1')
    end
end)
--
--
--
-- Functions
--
--
--
local dui2 = GetDuiHandle(CreateDui('https://cdn.discordapp.com/attachments/844250119359823912/904844739982000158/frame_00_delay-0.03s.jpg', 64, 64))
CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd('wave2'), 'logo2', dui2)
function DrawTxt(text, x, y, scale, size)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, size)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
local DrawText3D = function(txt, pos, scale)
    local OnScreen, x, y = World3dToScreen2d(table.unpack(pos))
    SetTextScale(scale or 0.40, scale or 0.25)
    SetTextFont(0)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(txt)
    DrawText(x, y)
end
function showInfobar(msg)
    CurrentActionMsg  = msg
    SetTextComponentFormat('STRING')
    AddTextComponentString(CurrentActionMsg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
function ShowNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end
function showPictureNotification(icon, msg, title, subtitle)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg);
    SetNotificationMessage(icon, icon, true, 5, title, subtitle);
    DrawNotification(false, true);
end
function ShowMPMessage(message, subtitle, ms)
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        function Initialize(scaleform)
            local scaleform = RequestScaleformMovie(scaleform)
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end
            PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
            PushScaleformMovieFunctionParameterString(message)
            PushScaleformMovieFunctionParameterString(subtitle)
            PopScaleformMovieFunctionVoid()
            Citizen.SetTimeout(6500, function()
                PushScaleformMovieFunction(scaleform, "SHARD_ANIM_OUT")
                PushScaleformMovieFunctionParameterInt(1)
                PushScaleformMovieFunctionParameterFloat(0.33)
                PopScaleformMovieFunctionVoid()
                Citizen.SetTimeout(3000, function()EndScaleformMovieMethod() end)
            end)
            return scaleform
        end
        scaleform = Initialize("mp_big_message_freemode")
        while true do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 150, 0)
        end
    end)
end
local function StripPlayer(target)
    local ped = GetPlayerPed(target)
    RemoveAllPedWeapons(ped, false)
end
local function StripAll(self)
    local plist = GetAllPlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        StripPlayer(i)
    end
end
local function GiveAllWeapons(target)
    local ped = GetPlayerPed(target)
    for i=0, #allWeapons do
        GiveWeaponToPed(ped, GetHashKey(allWeapons[i]), 9999, false, false)
    end
end
function GiveWeapon(target, weapon)
    local ped = GetPlayerPed(target)
    GiveWeaponToPed(ped, GetHashKey(weapon), 250, false, false)
end
local function weaponsall()
    local pbase = GetAllPlayers()
    for i=0, #pbase do
        GiveAllWeapons(i)
    end
end
function MaxOutEngine(veh)
    ToggleVehicleMod(veh, 18, 1)
    SetVehicleMod(veh, 12, 2, 0)
    SetVehicleMod(veh, 11, 3, 0)
    SetVehicleMod(veh, 13, 2, 0)
    SetVehicleModKit(veh, 0)
    SetVehicleModKit(veh, 0)
end
function MaxOutFull(veh)
                    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
                    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
                    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
                    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end
local function explodeall()
    local pbase = GetAllPlayers()
    for i=0, #pbase do
        local ped = GetPlayerPed(pbase[i])
        local coords = GetEntityCoords(ped)
        AddExplosion(coords.x+1, coords.y+1, coords.z+1, 4, 10000.0, true, false, 0.0)
    end
end
function explodePlayer(target)
    local ped = GetPlayerPed(target)
    local coords = GetEntityCoords(ped)
    AddExplosion(coords.x+1, coords.y+1, coords.z+1, 4, 10000.0, true, false, 0.0)
end
local function burgerall()
    local pbase = GetAllPlayers()
    for i=1, #pbase, 1 do
        if PlayerId() == pbase[i] and withoutme == false then
            burgerPlayer(pbase[i])
        end
    end
end
function burgerPlayer(i)
    if IsPedInAnyVehicle(GetPlayerPed(i), true) then
        local hamburg = "xs_prop_hamburgher_wl"
        local hamburghash = GetHashKey(hamburg)
        while not HasModelLoaded(hamburghash) do
            Citizen.Wait(0)
            RequestModel(hamburghash)
        end
        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
    else
        local hamburg = "xs_prop_hamburgher_wl"
        local hamburghash = GetHashKey(hamburg)
        while not HasModelLoaded(hamburghash) do
            Citizen.Wait(0)
            RequestModel(hamburghash)
        end
        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
    end
end
local function cageall()
    local pbase = GetAllPlayers()
    for i=1, #pbase, 1 do
        if PlayerId() == pbase[i] and withoutme == false then
            cagePlayer(pbase[i])
        end
    end
end
function cagePlayer(target)
    i = GetPlayerPed(target)
    x, y, z = table.unpack(GetEntityCoords(i))
    roundx = tonumber(string.format("%.2f", x))
    roundy = tonumber(string.format("%.2f", y))
    roundz = tonumber(string.format("%.2f", z))
    while not HasModelLoaded(GetHashKey("prop_fnclink_05crnr1")) do
        Citizen.Wait(0)
        RequestModel(GetHashKey("prop_fnclink_05crnr1"))
    end
    local cage1 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
    local cage2 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
    SetEntityHeading(cage1, -90.0)
    SetEntityHeading(cage2, 90.0)
    FreezeEntityPosition(cage1, true)
    FreezeEntityPosition(cage2, true)
end
local function GetPlayerIds()
    local playerIds = {}
    return playerIds
end
local function RandomSkin(target)
    local ped = GetPlayerPed(target)
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
end
local function GetCurrentOutfit(target)
    local ped = GetPlayerPed(target)
    outfit = {}
    outfit.hat = GetPedPropIndex(ped, 0)
    outfit.hat_texture = GetPedPropTextureIndex(ped, 0)
    outfit.glasses = GetPedPropIndex(ped, 1)
    outfit.glasses_texture = GetPedPropTextureIndex(ped, 1)
    outfit.ear = GetPedPropIndex(ped, 2)
    outfit.ear_texture = GetPedPropTextureIndex(ped, 2)
    outfit.watch = GetPedPropIndex(ped, 6)
    outfit.watch_texture = GetPedPropTextureIndex(ped, 6)
    outfit.wrist = GetPedPropIndex(ped, 7)
    outfit.wrist_texture = GetPedPropTextureIndex(ped, 7)
    outfit.head_drawable = GetPedDrawableVariation(ped, 0)
    outfit.head_palette = GetPedPaletteVariation(ped, 0)
    outfit.head_texture = GetPedTextureVariation(ped, 0)
    outfit.beard_drawable = GetPedDrawableVariation(ped, 1)
    outfit.beard_palette = GetPedPaletteVariation(ped, 1)
    outfit.beard_texture = GetPedTextureVariation(ped, 1)
    outfit.hair_drawable = GetPedDrawableVariation(ped, 2)
    outfit.hair_palette = GetPedPaletteVariation(ped, 2)
    outfit.hair_texture = GetPedTextureVariation(ped, 2)
    outfit.torso_drawable = GetPedDrawableVariation(ped, 3)
    outfit.torso_palette = GetPedPaletteVariation(ped, 3)
    outfit.torso_texture = GetPedTextureVariation(ped, 3)
    outfit.legs_drawable = GetPedDrawableVariation(ped, 4)
    outfit.legs_palette = GetPedPaletteVariation(ped, 4)
    outfit.legs_texture = GetPedTextureVariation(ped, 4)
    outfit.hands_drawable = GetPedDrawableVariation(ped, 5)
    outfit.hands_palette = GetPedPaletteVariation(ped, 5)
    outfit.hands_texture = GetPedTextureVariation(ped, 5)
    outfit.foot_drawable = GetPedDrawableVariation(ped, 6)
    outfit.foot_palette = GetPedPaletteVariation(ped, 6)
    outfit.foot_texture = GetPedTextureVariation(ped, 6)
    outfit.acc1_drawable = GetPedDrawableVariation(ped, 7)
    outfit.acc1_palette = GetPedPaletteVariation(ped, 7)
    outfit.acc1_texture = GetPedTextureVariation(ped, 7)
    outfit.acc2_drawable = GetPedDrawableVariation(ped, 8)
    outfit.acc2_palette = GetPedPaletteVariation(ped, 8)
    outfit.acc2_texture = GetPedTextureVariation(ped, 8)
    outfit.acc3_drawable = GetPedDrawableVariation(ped, 9)
    outfit.acc3_palette = GetPedPaletteVariation(ped, 9)
    outfit.acc3_texture = GetPedTextureVariation(ped, 9)
    outfit.mask_drawable = GetPedDrawableVariation(ped, 10)
    outfit.mask_palette = GetPedPaletteVariation(ped, 10)
    outfit.mask_texture = GetPedTextureVariation(ped, 10)
    outfit.aux_drawable = GetPedDrawableVariation(ped, 11)
    outfit.aux_palette = GetPedPaletteVariation(ped, 11)
    outfit.aux_texture = GetPedTextureVariation(ped, 11)
    return outfit
end
local function SetCurrentOutfit(outfit)
    local ped = PlayerPedId()
    SetPedPropIndex(ped, 0, outfit.hat, outfit.hat_texture, 1)
    SetPedPropIndex(ped, 1, outfit.glasses, outfit.glasses_texture, 1)
    SetPedPropIndex(ped, 2, outfit.ear, outfit.ear_texture, 1)
    SetPedPropIndex(ped, 6, outfit.watch, outfit.watch_texture, 1)
    SetPedPropIndex(ped, 7, outfit.wrist, outfit.wrist_texture, 1)
    SetPedComponentVariation(ped, 0, outfit.head_drawable, outfit.head_texture, outfit.head_palette)
    SetPedComponentVariation(ped, 1, outfit.beard_drawable, outfit.beard_texture, outfit.beard_palette)
    SetPedComponentVariation(ped, 2, outfit.hair_drawable, outfit.hair_texture, outfit.hair_palette)
    SetPedComponentVariation(ped, 3, outfit.torso_drawable, outfit.torso_texture, outfit.torso_palette)
    SetPedComponentVariation(ped, 4, outfit.legs_drawable, outfit.legs_texture, outfit.legs_palette)
    SetPedComponentVariation(ped, 5, outfit.hands_drawable, outfit.hands_texture, outfit.hands_palette)
    SetPedComponentVariation(ped, 6, outfit.foot_drawable, outfit.foot_texture, outfit.foot_palette)
    SetPedComponentVariation(ped, 7, outfit.acc1_drawable, outfit.acc1_texture, outfit.acc1_palette)
    SetPedComponentVariation(ped, 8, outfit.acc2_drawable, outfit.acc2_texture, outfit.acc2_palette)
    SetPedComponentVariation(ped, 9, outfit.acc3_drawable, outfit.acc3_texture, outfit.acc3_palette)
    SetPedComponentVariation(ped, 10, outfit.mask_drawable, outfit.mask_texture, outfit.mask_palette)
    SetPedComponentVariation(ped, 11, outfit.aux_drawable, outfit.aux_texture, outfit.aux_palette)
end
function checkValidVehicleExtras()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local valid = {}
    for i=0,50,1 do
        if(DoesExtraExist(playerVeh, i))then
            local realModname = "Extra #"..tostring(i)
            local text = "OFF"
            if(IsVehicleExtraTurnedOn(playerVeh, i))then
                text = "ON"
            end
            local realSpawnname = "extra "..tostring(i)
            table.insert(valid, {
                menuName=realModName,
                data ={
                    ["action"] = realSpawnName,
                    ["state"] = text
                }
            })
        end
    end
    return valid
end
function DoesVehicleHaveExtras( veh )
    for i = 1, 30 do
        if ( DoesExtraExist( veh, i ) ) then
            return true
        end
    end
    return false
end
function checkValidVehicleMods(modID)
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local valid = {}
    local modCount = GetNumVehicleMods(playerVeh,modID)
    if (modID == 48 and modCount == 0) then
        local modCount = GetVehicleLiveryCount(playerVeh)
        for i=1, modCount, 1 do
            local realIndex = i - 1
            local modName = GetLiveryName(playerVeh, realIndex)
            local realModName = GetLabelText(modName)
            local modid, realSpawnName = modID, realIndex
            valid[i] = {
                menuName=realModName,
                data = {
                    ["modid"] = modid,
                    ["realIndex"] = realSpawnName
                }
            }
        end
    end
    for i = 1, modCount, 1 do
        local realIndex = i - 1
        local modName = GetModTextLabel(playerVeh, modID, realIndex)
        local realModName = GetLabelText(modName)
        local modid, realSpawnName = modCount, realIndex
        valid[i] = {
            menuName=realModName,
            data = {
                ["modid"] = modid,
                ["realIndex"] = realSpawnName
            }
        }
    end
    if(modCount > 0)then
        local realIndex = -1
        local modid, realSpawnName = modID, realIndex
        table.insert(valid, 1, {
            menuName="Stock",
            data = {
                ["modid"] = modid,
                ["realIndex"] = realSpawnName
            }
        })
    end
    return valid
end
local function GetResources()
    local resources = {}
    for i=0, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end
function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
function GiveMaxAmmo(target)
    local ped = GetPlayerPed(target)
    for i = 1, #allWeapons do
        AddAmmoToPed(ped, GetHashKey(allWeapons[i]), 250)
    end
end
function PedAttack(target, attackType)
    local coords = GetEntityCoords(GetPlayerPed(target))
    if attackType == 1 then weparray = allWeapons
    elseif attackType == 2 then weparray = meleeweapons
    elseif attackType == 3 then weparray = pistolweapons
    elseif attackType == 4 then weparray = heavyweapons
    end
    for k in EnumeratePeds() do
        if k ~= GetPlayerPed(target) and not IsPedAPlayer(k) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) < 2000 then
            local rand = math.ceil(math.random(#weparray))
            if weparray ~= allWeapons then GiveWeaponToPed(k, GetHashKey(weparray[rand][1]), 9999, 0, 1)
            else GiveWeaponToPed(k, GetHashKey(weparray[rand]), 9999, 0, 1) end
            ClearPedTasks(k)
            TaskCombatPed(k, GetPlayerPed(target), 0, 16)
            SetPedCombatAbility(k, 100)
            SetPedCombatRange(k, 2)
            SetPedCombatAttributes(k, 46, 1)
            SetPedCombatAttributes(k, 5, 1)
        end
    end
end
function ApplyShockwave(entity)
    local pos = GetEntityCoords(PlayerPedId())
    local coord = GetEntityCoords(entity)
    local dx = coord.x - pos.x
    local dy = coord.y - pos.y
    local dz = coord.z - pos.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local distanceRate = (50 / distance) * math.pow(1.04, 1 - distance)
    ApplyForceToEntity(entity, 1, distanceRate * dx, distanceRate * dy, distanceRate * dz, math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), true, false, true, true, true, true)
end
function DoWaveradius(radius)
    local player = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    local playerVehicle = GetPlayersLastVehicle()
    local inVehicle = IsPedInVehicle(player, playerVehicle, true)
    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)
    for k in EnumerateVehicles() do
        if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            ApplyShockwave(k)
        end
    end
    for k in EnumeratePeds() do
        if k ~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            SetPedRagdollOnCollision(k, true)
            SetPedRagdollForceFall(k)
            ApplyShockwave(k)
        end
    end
end
function GetWeaponNameFromHash(hash)
    for i = 1, #allWeapons do
        if GetHashKey(allWeapons[i]) == hash then
            return string.sub(allWeapons[i], 8)
        end
    end
end
function FixVeh(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleFixed(veh)
end
function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end
function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end
function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end
function ApplyForce(entity, direction)
    ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
end
function RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end
function RequestControl(entity)
    Citizen.CreateThread(function()
        local tick = 0
        while not RequestControlOnce(entity) and tick <= 12 do
            tick = tick + 1
            Wait(0)
        end
        return tick <= 12
    end)
end
function Oscillate(entity, position, angleFreq, dampRatio)
    local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq * angleFreq))
    local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
    local targetPos = SubVectors(pos1, pos2)
    ApplyForce(entity, targetPos)
end
local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}
function GetHeadItems()
    local headItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 0)
    local faceItemsList = {}
    for i = 1, headItems do
        faceItemsList[i] = i
    end
    return faceItemsList
end
function GetHeadTextures(faceID)
    local headTextures = GetNumberOfPedTextureVariations(PlayerPedId(), 0, faceID)
    local headTexturesList = {}
    for i = 1, headTextures do
        headTexturesList[i] = i
    end
    return headTexturesList
end
function GetHairItems()
    local hairItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 2)
    local hairItemsList = {}
    for i = 1, hairItems do
        hairItemsList[i] = i
    end
    return hairItemsList
end
function GetHairTextures(hairID)
    local hairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, hairID)
    local hairTextureList = {}
    for i = 1, hairTexture do
        hairTextureList[i] = i
    end
    return hairTextureList
end
function GetMaskItems()
    local maskItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
    local maskItemsList = {}
    for i = 1, maskItems do
        maskItemsList[i] = i
    end
    return maskItemsList
end
function GetHatItems()
    local hatItems = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
    local hatItemsList = {}
    for i = 1, hatItems do
        hatItemsList[i] = i
    end
    return hatItemsList
end
function GetHatTextures(hatID)
    local hatTextures = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, hatID)
    local hatTexturesList = {}
    for i = 1, hatTextures do
        hatTexturesList[i] = i
    end
    return hatTexturesList
end
function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end
function KickFromVeh(target)
    local ped = GetPlayerPed(target)
    if IsPedInAnyVehicle(ped, false) then
        ClearPedTasksImmediately(ped)
    else
        ShowNotification("~r~Player is not in a car")
    end
end
function RemoveFuel(target)
    local ped = GetPlayerPed(target)
    if IsPedInAnyVehicle(ped, false) then
    SetVehicleFuelLevel(
	GetVehiclePedIsIn(PlayerPedId(), 0), 
    0
)
    else
        ShowNotification("~r~Player is not in a car")
    end
end
function GiveFuel(target)
    local ped = GetPlayerPed(target)
    if IsPedInAnyVehicle(ped, false) then
    SetVehicleFuelLevel(
	GetVehiclePedIsIn(PlayerPedId(), 0), 
    9999999999999999
)
    else
        ShowNotification("~r~Player is not in a car")
    end
end
function KickAllFromVeh(self)
    local plist = GetAllPlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        KickFromVeh(i)
    end
end
function RageShoot(target)
    if not IsPedDeadOrDying(target) then
        local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0.1, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0.1, 0, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
    end
end
function GetWeaponNameFromHash(hash)
    for i = 1, #allWeapons do
        if GetHashKey(allWeapons[i]) == hash then
            return string.sub(allWeapons[i], 8)
        end
    end
end
function FixVeh(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleFixed(veh)
end
function NameToBone(name)
    if name == "Head" then
        return "SKEL_Head"
    elseif name == "Chest" then
        return "SKEL_Spine2"
    elseif name == "Left Arm" then
        return "SKEL_L_UpperArm"
    elseif name == "Right Arm" then
        return "SKEL_R_UpperArm"
    elseif name == "Left Leg" then
        return "SKEL_L_Thigh"
    elseif name == "Right Leg" then
        return "SKEL_R_Thigh"
    elseif name == "Dick" then
        return "SKEL_Pelvis"
    else
        return "SKEL_ROOT"
    end
end
function DoRapidFireTick()
    DisablePlayerFiring(PlayerPedId(), true)
    if IsDisabledControlPressed(0, 92) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local camDir = GetCamDirFromScreenCenter()
        local camPos = GetGameplayCamCoord()
        local launchPos = GetEntityCoords(wepent)
        local targetPos = camPos + (camDir * 200.0)
        ClearAreaOfProjectiles(launchPos, 0.0, 1)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
    end
end
function TeleportToPlayer(target)
    local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end
function TeleportPlayertoMe(target)
    local targetped = GetPlayerPed(target)
    local ped = GetPlayerPed(PlayerId())
    local pos = GetEntityCoords(ped)
    ESX.Game.Teleport(targetped, pos, function() end)
end
function SpectatePlayer(id)
    local player = GetPlayerPed(id)
    if Spectating then
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(true, player)
    else
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(false, player)
    end
end
function ShootAt(target, bone)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end
function ShootAt2(target, bone, damage)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    local _, weapon = GetCurrentPedWeapon(PlayerPedId())
    ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, damage, true, weapon, PlayerPedId(), true, true, 1000.0)
end
function ShootAimbot(k)
    if IsEntityOnScreen(k) and HasEntityClearLosToEntityInFront(PlayerPedId(), k) and
            not IsPedDeadOrDying(k) and not IsPedInVehicle(k, GetVehiclePedIsIn(k), false) and
            IsDisabledControlPressed(0, 92) and IsPlayerFreeAiming(PlayerId()) then
        local x, y, z = table.unpack(GetEntityCoords(k))
        local _, _x, _y = World3dToScreen2d(x, y, z)
        if _x > 0.25 and _x < 0.75 and _y > 0.25 and _y < 0.75 then
            local _, weapon = GetCurrentPedWeapon(PlayerPedId())
            ShootAt2(k, AimbotBoneOps[currAimbotBoneIndex], GetWeaponDamage(weapon, 1))
        end
    end
end
function GetCamDirFromScreenCenter()
    local pos = GetGameplayCamCoord()
    local world = ScreenToWorld(0, 0)
    local ret = SubVectors(world, pos)
    return ret
end
function ScreenToWorld(screenCoord)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    local vect2x = 0.0
    local vect2y = 0.0
    local vect21y = 0.0
    local vect21x = 0.0
    local direction = RotationToDirection(camRot)
    local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)
    local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
    local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
    local radians = -(math.rad(camRot.y))
    vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
    vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))
    local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
    if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
    end
    local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
    if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
    end
    if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
    end
    local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
    local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
    return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)
end
function WorldToScreenRel(worldCoords)
    local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
    if not check then
        return false
    end
    screenCoordsx = (x - 0.5) * 2.0
    screenCoordsy = (y - 0.5) * 2.0
    return true, screenCoordsx, screenCoordsy
end
function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end
function AddVectors(vect1, vect2)
    return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end
function SubVectors(vect1, vect2)
    return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
end
function ScaleVector(vect, mult)
    return vector3(vect.x * mult, vect.y * mult, vect.z * mult)
end
function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function GetSeatPedIsIn(ped)
    if not IsPedInAnyVehicle(ped, false) then return
    else
        veh = GetVehiclePedIsIn(ped)
        for i = 0, GetVehicleMaxNumberOfPassengers(veh) do
            if GetPedInVehicleSeat(veh) then return i end
        end
    end
end
function RandomClothe(target)
    local ped = GetPlayerPed(target)
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
end
function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    return x, y, z
end
local function SpawnVeh(model, PlaceSelf)
    RequestModel(GetHashKey(model))
    Wait(500)
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(0)
    end
    local coords = GetEntityCoords(PlayerPedId())
    local xf = GetEntityForwardX(PlayerPedId())
    local yf = GetEntityForwardY(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local veh = CreateVehicle(GetHashKey(model), coords.x+xf*5, coords.y+yf*5, coords.z, heading, 1, 1)
    if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
end
local function SpawnPlane(model, PlaceSelf, SpawnInAir)
    RequestModel(GetHashKey(model))
    Wait(500)
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(0)
    end
    local coords = GetEntityCoords(PlayerPedId())
    local xf = GetEntityForwardX(PlayerPedId())
    local yf = GetEntityForwardY(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local veh = nil
    if SpawnInAir then
        veh = CreateVehicle(GetHashKey(model), coords.x+xf*20, coords.y+yf*20, coords.z+500, heading, 1, 1)
    else
        veh = CreateVehicle(GetHashKey(model), coords.x+xf*5, coords.y+yf*5, coords.z, heading, 1, 1)
    end
    if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
end
function ApplyShockwave(entity)
    local pos = GetEntityCoords(PlayerPedId())
    local coord = GetEntityCoords(entity)
    local dx = coord.x - pos.x
    local dy = coord.y - pos.y
    local dz = coord.z - pos.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local distanceRate = (50 / distance) * math.pow(1.04, 1 - distance)
    ApplyForceToEntity(entity, 1, distanceRate * dx, distanceRate * dy, distanceRate * dz, math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), true, false, true, true, true, true)
end
local function WeDoShockwave(radius)
    local player = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    local playerVehicle = GetPlayersLastVehicle()
    local isinVehicle = IsPedInVehicle(player, playerVehicle, true)
    
    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)
    
    for Shockwave in EnumerateVehicles() do
        if (not isinVehicle or Shockwave ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(Shockwave)) <= radius * 1.2 then
            RequestControlOnce(Shockwave)
            ApplyShockwave(Shockwave)
        end
    end
 end
local function TeleportToWaypoint()
	
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
		wp = true
	else
		drawNotification("~r~No waypoint please set one!")
	end
	
	local zHeigt = 0.0 height = 1000.0
	while true do
		Citizen.Wait(0)
		if wp then
			if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
				entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
			else
				entity = GetPlayerPed(-1)
			end
			SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
			FreezeEntityPosition(entity, true)
			local Pos = GetEntityCoords(entity, true)
			
			if zHeigt == 0.0 then
				height = height - 25.0
				SetEntityCoords(entity, Pos.x, Pos.y, height)
				bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
			else
				SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
				FreezeEntityPosition(entity, false)
				wp = false
				height = 1000.0
				zHeigt = 0.0
				drawNotification("~g~Teleported to waypoint!")
				break
			end
		end
	end
end
function GetKeyboardInput(text)
    if not text then text = "Input" end
    DisplayOnscreenKeyboard(0, "", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DrawTxt(text, 0.32, 0.37, 0.0, 0.4)
        DisableAllControlActions(0)
        if IsDisabledControlPressed(0, 200) then return "" end
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        Wait(0)
        return result
    end
end
function WarMenu.CreateCategory(Category)
    if not currentMenu then
        return
    end
    optionCount = optionCount + 1
    drawButton('                                                   '.. Category, "")
end
function GetAllPlayers()
    local players = {}
    local playernames = {}
    for i=1, 1024, 1 do
        if GetPlayerServerId(i) ~= 0 and GetPlayerServerId(i) ~= "**Invalid**" and GetPlayerServerId(i) ~= nil and not has_value(playernames, GetPlayerName(i)) then
            
            table.insert(players, i)
            table.insert(playernames, GetPlayerName(i))
        end
    end
    return players
end
function has_resource(resource)
    res = GetResources()
    for i=1, #res, 1 do
        if resource == res[i] then
            return true
        end
    end
    return false
end
-- Vars/Arrays
allWeapons={"WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_NIGHTSTICK","WEAPON_HAMMER","WEAPON_BAT","WEAPON_GOLFCLUB","WEAPON_CROWBAR","WEAPON_BOTTLE","WEAPON_DAGGER","WEAPON_HATCHET","WEAPON_MACHETE","WEAPON_FLASHLIGHT","WEAPON_SWITCHBLADE","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_STUNGUN","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_GUSENBERG","WEAPON_MACHINEPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE","WEAPON_PUMPSHOTGUN","WEAPON_SAWNOFFSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_RPG","WEAPON_STINGER","WEAPON_FIREWORK","WEAPON_HOMINGLAUNCHER","WEAPON_GRENADE","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_BZGAS","WEAPON_SMOKEGRENADE","WEAPON_MOLOTOV","WEAPON_FIREEXTINGUISHER","WEAPON_PETROLCAN","WEAPON_SNOWBALL","WEAPON_FLARE","WEAPON_BALL"}
local meleeweapons = { {"WEAPON_KNIFE", "Knife"}, {"WEAPON_KNUCKLE", "Brass Knuckles"}, {"WEAPON_NIGHTSTICK", "Nightstick"}, {"WEAPON_HAMMER", "Hammer"}, {"WEAPON_BAT", "Baseball Bat"}, {"WEAPON_GOLFCLUB", "Golf Club"}, {"WEAPON_CROWBAR", "Crowbar"}, {"WEAPON_BOTTLE", "Bottle"}, {"WEAPON_DAGGER", "Dagger"}, {"WEAPON_HATCHET", "Hatchet"}, {"WEAPON_MACHETE", "Machete"}, {"WEAPON_FLASHLIGHT", "Flashlight"}, {"WEAPON_SWITCHBLADE", "Switchblade"}, {"WEAPON_POOLCUE", "Pool Cue"}, {"WEAPON_PIPEWRENCH", "Pipe Wrench"} } local thrownweapons = { {"WEAPON_GRENADE", "Grenade"}, {"WEAPON_STICKYBOMB", "Sticky Bomb"}, {"WEAPON_PROXMINE", "Proximity Mine"}, {"WEAPON_BZGAS", "BZ Gas"}, {"WEAPON_SMOKEGRENADE", "Smoke Grenade"}, {"WEAPON_MOLOTOV", "Molotov"}, {"WEAPON_FIREEXTINGUISHER", "Fire Extinguisher"}, {"WEAPON_PETROLCAN", "Fuel Can"}, {"WEAPON_SNOWBALL", "Snowball"}, {"WEAPON_FLARE", "Flare"}, {"WEAPON_BALL", "Baseball"} } local pistolweapons = { {"WEAPON_PISTOL", "Pistol"}, {"WEAPON_PISTOL_MK2", "Pistol Mk II"}, {"WEAPON_COMBATPISTOL", "Combat Pistol"}, {"WEAPON_APPISTOL", "AP Pistol"}, {"WEAPON_REVOLVER", "Revolver"}, {"WEAPON_REVOLVER_MK2", "Revolver Mk II"}, {"WEAPON_DOUBLEACTION", "Double Action Revolver"}, {"WEAPON_PISTOL50", "Pistol .50"}, {"WEAPON_SNSPISTOL", "SNS Pistol"}, {"WEAPON_SNSPISTOL_MK2", "SNS Pistol Mk II"}, {"WEAPON_HEAVYPISTOL", "Heavy Pistol"}, {"WEAPON_VINTAGEPISTOL", "Vintage Pistol"}, {"WEAPON_STUNGUN", "Tazer"}, {"WEAPON_FLAREGUN", "Flaregun"}, {"WEAPON_MARKSMANPISTOL", "Marksman Pistol"}, {"WEAPON_RAYPISTOL", "Up-n-Atomizer"} } local smgweapons = { {"WEAPON_MICROSMG", "Micro SMG"}, {"WEAPON_MINISMG", "Mini SMG"}, {"WEAPON_SMG", "SMG"}, {"WEAPON_SMG_MK2", "SMG Mk II"}, {"WEAPON_ASSAULTSMG", "Assault SMG"}, {"WEAPON_COMBATPDW", "Combat PDW"}, {"WEAPON_GUSENBERG", "Gunsenberg"}, {"WEAPON_MACHINEPISTOL", "Machine Pistol"}, {"WEAPON_MG", "MG"}, {"WEAPON_COMBATMG", "Combat MG"}, {"WEAPON_COMBATMG_MK2", "Combat MG Mk II"}, {"WEAPON_RAYCARBINE", "Unholy Hellbringer"} } local assaultweapons = { {"WEAPON_ASSAULTRIFLE", "Assault Rifle"}, {"WEAPON_ASSAULTRIFLE_MK2", "Assault Rifle Mk II"}, {"WEAPON_CARBINERIFLE", "Carbine Rifle"}, {"WEAPON_CARBINERIFLE_MK2", "Carbine Rigle Mk II"}, {"WEAPON_ADVANCEDRIFLE", "Advanced Rifle"}, {"WEAPON_SPECIALCARBINE", "Special Carbine"}, {"WEAPON_SPECIALCARBINE_MK2", "Special Carbine Mk II"}, {"WEAPON_BULLPUPRIFLE", "Bullpup Rifle"}, {"WEAPON_BULLPUPRIFLE_MK2", "Bullpup Rifle Mk II"}, {"WEAPON_COMPACTRIFLE", "Compact Rifle"} } local shotgunweapons = { {"WEAPON_PUMPSHOTGUN", "Pump Shotgun"}, {"WEAPON_PUMPSHOTGUN_MK2", "Pump Shotgun Mk II"}, {"WEAPON_SWEEPERSHOTGUN", "Sweeper Shotgun"}, {"WEAPON_SAWNOFFSHOTGUN", "Sawed-Off Shotgun"}, {"WEAPON_BULLPUPSHOTGUN", "Bullpup Shotgun"}, {"WEAPON_ASSAULTSHOTGUN", "Assault Shotgun"}, {"WEAPON_MUSKET", "Musket"}, {"WEAPON_HEAVYSHOTGUN", "Heavy Shotgun"}, {"WEAPON_DBSHOTGUN", "Double Barrel Shotgun"} } local sniperweapons = { {"WEAPON_SNIPERRIFLE", "Sniper Rifle"}, {"WEAPON_HEAVYSNIPER", "Heavy Sniper"}, {"WEAPON_HEAVYSNIPER_MK2", "Heavy Sniper Mk II"}, {"WEAPON_MARKSMANRIFLE", "Marksman Rifle"}, {"WEAPON_MARKSMANRIFLE_MK2", "Marksman Rifle Mk II"} } local heavyweapons = { {"WEAPON_GRENADELAUNCHER", "Grenade Launcher"}, {"WEAPON_RPG", "RPG"}, {"WEAPON_MINIGUN", "Minigun"}, {"WEAPON_FIREWORK", "Firework Launcher"}, {"WEAPON_RAILGUN", "Railgun"}, {"WEAPON_HOMINGLAUNCHER", "Homing Launcher"}, {"WEAPON_COMPACTLAUNCHER", "Compact Grenade Launcher"}, {"WEAPON_RAYMINIGUN", "Widowmaker"} }
local compacts = { "BLISTA", "BRIOSO", "DILETTANTE", "DILETTANTE2", "ISSI2", "ISSI3", "ISSI4", "ISSI5", "ISSI6", "PANTO", "PRAIRIE", "RHAPSODY" } local sedans = { "ASEA", "ASEA2", "ASTEROPE", "COG55", "COG552", "COGNOSCENTI", "COGNOSCENTI2", "EMPEROR", "EMPEROR2", "EMPEROR3", "FUGITIVE", "GLENDALE", "INGOT", "INTRUDER", "LIMO2", "PREMIER", "PRIMO", "PRIMO2", "REGINA", "ROMERO", "SCHAFTER2", "SCHAFTER5", "SCHAFTER6", "STAFFORD", "STANIER", "STRATUM", "STRETCH", "SUPERD", "SURGE", "TAILGATER", "WARRENER", "WASHINGTON" } local suvs = { "BALLER", "BALLER2", "BALLER3", "BALLER4", "BALLER5", "BALLER6", "BJXL", "CAVALCADE", "CAVALCADE2", "CONTENDER", "DUBSTA", "DUBSTA2", "FQ2", "GRANGER", "GRESLEY", "HABANERO", "HUNTLEY", "LANDSTALKER", "MESA", "MESA2", "PATRIOT", "PATRIOT2", "RADI", "ROCOTO", "SEMINOLE", "SERRANO", "TOROS", "XLS", "XLS2" } local coupes = { "COGCABRIO", "EXEMPLAR", "F620", "FELON", "FELON2", "JACKAL", "ORACLE", "ORACLE2", "SENTINEL", "SENTINEL2", "WINDSOR", "WINDSOR2", "ZION", "ZION2" } local muscle = { "BLADE", "BUCCANEER", "BUCCANEER2", "CHINO", "CHINO2", "CLIQUE", "COQUETTE3", "DEVIANT", "DOMINATOR", "DOMINATOR2", "DOMINATOR3", "DOMINATOR4", "DOMINATOR5", "DOMINATOR6", "DUKES", "DUKES2", "ELLIE", "FACTION", "FACTION2", "FACTION3", "GAUNTLET", "GAUNTLET2", "HERMES", "HOTKNIFE", "HUSTLER", "IMPALER", "IMPALER2", "IMPALER3", "IMPALER4", "IMPERATOR", "IMPERATOR2", "IMPERATOR3", "LURCHER", "MOONBEAM", "MOONBEAM2", "NIGHTSHADE", "PHOENIX", "PICADOR", "RATLOADER", "RATLOADER2", "RUINER", "RUINER2", "RUINER3", "SABREGT", "SABREGT2", "SLAMVAN", "SLAMVAN2", "SLAMVAN3", "SLAMVAN4", "SLAMVAN5", "SLAMVAN6", "STALION", "STALION2", "TAMPA", "TAMPA3", "TULIP", "VAMOS", "VIGERO", "VIRGO", "VIRGO2", "VIRGO3", "VOODOO", "VOODOO2", "YOSEMITE" } local sportsclassics = { "ARDENT", "BTYPE", "BTYPE2", "BTYPE3", "CASCO", "CHEBUREK", "CHEETAH2", "COQUETTE2", "DELUXO", "FAGALOA", "FELTZER3", "GT500", "INFERNUS2", "JB700", "JESTER3", "MAMBA", "MANANA", "MICHELLI", "MONROE", "PEYOTE", "PIGALLE", "RAPIDGT3", "RETINUE", "SAVESTRA", "STINGER", "STINGERGT", "STROMBERG", "SWINGER", "TORERO", "TORNADO", "TORNADO2", "TORNADO3", "TORNADO4", "TORNADO5", "TORNADO6", "TURISMO2", "VISERIS", "Z190", "ZTYPE" } local sports = { "ALPHA", "BANSHEE", "BESTIAGTS", "BLISTA2", "BLISTA3", "BUFFALO", "BUFFALO2", "BUFFALO3", "CARBONIZZARE", "COMET2", "COMET3", "COMET4", "COMET5", "COQUETTE", "ELEGY", "ELEGY2", "FELTZER2", "FLASHGT", "FUROREGT", "FUSILADE", "FUTO", "GB200", "HOTRING", "ITALIGTO", "JESTER", "JESTER2", "KHAMELION", "KURUMA", "KURUMA2", "LYNX", "MASSACRO", "MASSACRO2", "NEON", "NINEF", "NINEF2", "OMNIS", "PARIAH", "PENUMBRA", "RAIDEN", "RAPIDGT", "RAPIDGT2", "RAPTOR", "REVOLTER", "RUSTON", "SCHAFTER2", "SCHAFTER3", "SCHAFTER4", "SCHAFTER5", "SCHLAGEN", "SCHWARZER", "SENTINEL3", "SEVEN70", "SPECTER", "SPECTER2", "SULTAN", "SURANO", "TAMPA2", "TROPOS", "VERLIERER2", "ZR380", "ZR3802", "ZR3803" } local super = { "ADDER", "AUTARCH", "BANSHEE2", "BULLET", "CHEETAH", "CYCLONE", "DEVESTE", "ENTITYXF", "ENTITY2", "FMJ", "GP1", "INFERNUS", "ITALIGTB", "ITALIGTB2", "LE7B", "NERO", "NERO2", "OSIRIS", "PENETRATOR", "PFISTER811", "PROTOTIPO", "REAPER", "SC1", "SCRAMJET", "SHEAVA", "SULTANRS", "T20", "TAIPAN", "TEMPESTA", "TEZERACT", "TURISMOR", "TYRANT", "TYRUS", "VACCA", "VAGNER", "VIGILANTE", "VISIONE", "VOLTIC", "VOLTIC2", "XA21", "ZENTORNO" } local motorcycles = { "AKUMA", "AVARUS", "BAGGER", "BATI", "BATI2", "BF400", "CARBONRS", "CHIMERA", "CLIFFHANGER", "DAEMON", "DAEMON2", "DEFILER", "DEATHBIKE", "DEATHBIKE2", "DEATHBIKE3", "DIABLOUS", "DIABLOUS2", "DOUBLE", "ENDURO", "ESSKEY", "FAGGIO", "FAGGIO2", "FAGGIO3", "FCR", "FCR2", "GARGOYLE", "HAKUCHOU", "HAKUCHOU2", "HEXER", "INNOVATION", "LECTRO", "MANCHEZ", "NEMESIS", "NIGHTBLADE", "OPPRESSOR", "OPPRESSOR2", "PCJ", "RATBIKE", "RUFFIAN", "SANCHEZ", "SANCHEZ2", "SANCTUS", "SHOTARO", "SOVEREIGN", "THRUST", "VADER", "VINDICATOR", "VORTEX", "WOLFSBANE", "ZOMBIEA", "ZOMBIEB" } local offroad = { "BFINJECTION", "BIFTA", "BLAZER", "BLAZER2", "BLAZER3", "BLAZER4", "BLAZER5", "BODHI2", "BRAWLER", "BRUISER", "BRUISER2", "BRUISER3", "BRUTUS", "BRUTUS2", "BRUTUS3", "CARACARA", "DLOADER", "DUBSTA3", "DUNE", "DUNE2", "DUNE3", "DUNE4", "DUNE5", "FREECRAWLER", "INSURGENT", "INSURGENT2", "INSURGENT3", "KALAHARI", "KAMACHO", "MARSHALL", "MENACER", "MESA3", "MONSTER", "MONSTER3", "MONSTER4", "MONSTER5", "NIGHTSHARK", "RANCHERXL", "RANCHERXL2", "RCBANDITO", "REBEL", "REBEL2", "RIATA", "SANDKING", "SANDKING2", "TECHNICAL", "TECHNICAL2", "TECHNICAL3", "TROPHYTRUCK", "TROPHYTRUCK2" } local industrial = { "BULLDOZER", "CUTTER", "DUMP", "FLATBED", "GUARDIAN", "HANDLER", "MIXER", "MIXER2", "RUBBLE", "TIPTRUCK", "TIPTRUCK2" } local utility = { "AIRTUG", "CADDY", "CADDY2", "CADDY3", "DOCKTUG", "FORKLIFT", "TRACTOR2", "TRACTOR3", "MOWER", "RIPLEY", "SADLER", "SADLER2", "SCRAP", "TOWTRUCK", "TOWTRUCK2", "TRACTOR", "UTILLITRUCK", "UTILLITRUCK2", "UTILLITRUCK3", "ARMYTRAILER", "ARMYTRAILER2", "FREIGHTTRAILER", "ARMYTANKER", "TRAILERLARGE", "DOCKTRAILER", "TR3", "TR2", "TR4", "TRFLAT", "TRAILERS", "TRAILERS4", "TRAILERS2", "TRAILERS3", "TVTRAILER", "TRAILERLOGS", "TANKER", "TANKER2", "BALETRAILER", "GRAINTRAILER", "BOATTRAILER", "RAKETRAILER", "TRAILERSMALL" } local vans = { "BISON", "BISON2", "BISON3", "BOBCATXL", "BOXVILLE", "BOXVILLE2", "BOXVILLE3", "BOXVILLE4", "BOXVILLE5", "BURRITO", "BURRITO2", "BURRITO3", "BURRITO4", "BURRITO5", "CAMPER", "GBURRITO", "GBURRITO2", "JOURNEY", "MINIVAN", "MINIVAN2", "PARADISE", "PONY", "PONY2", "RUMPO", "RUMPO2", "RUMPO3", "SPEEDO", "SPEEDO2", "SPEEDO4", "SURFER", "SURFER2", "TACO", "YOUGA", "YOUGA2" } local cycles = { "BMX", "CRUISER", "FIXTER", "SCORCHER", "TRIBIKE", "TRIBIKE2", "TRIBIKE3" } local boats = { "DINGHY", "DINGHY2", "DINGHY3", "DINGHY4", "JETMAX", "MARQUIS", "PREDATOR", "SEASHARK", "SEASHARK2", "SEASHARK3", "SPEEDER", "SPEEDER2", "SQUALO", "SUBMERSIBLE", "SUBMERSIBLE2", "SUNTRAP", "TORO", "TORO2", "TROPIC", "TROPIC2", "TUG" } local helicopters = { "AKULA", "ANNIHILATOR", "BUZZARD", "BUZZARD2", "CARGOBOB", "CARGOBOB2", "CARGOBOB3", "CARGOBOB4", "FROGGER", "FROGGER2", "HAVOK", "HUNTER", "MAVERICK", "POLMAV", "SAVAGE", "SEASPARROW", "SKYLIFT", "SUPERVOLITO", "SUPERVOLITO2", "SWIFT", "SWIFT2", "VALKYRIE", "VALKYRIE2", "VOLATUS" } local planes = { "ALPHAZ1", "AVENGER", "AVENGER2", "BESRA", "BLIMP", "BLIMP2", "BLIMP3", "BOMBUSHKA", "CARGOPLANE", "CUBAN800", "DODO", "DUSTER", "HOWARD", "HYDRA", "JET", "LAZER", "LUXOR", "LUXOR2", "MAMMATUS", "MICROLIGHT", "MILJET", "MOGUL", "MOLOTOK", "NIMBUS", "NOKOTA", "PYRO", "ROGUE", "SEABREEZE", "SHAMAL", "STARLING", "STRIKEFORCE", "STUNT", "TITAN", "TULA", "VELUM", "VELUM2", "VESTRA", "VOLATOL" } local service = { "AIRBUS", "BRICKADE", "BUS", "COACH", "PBUS2", "RALLYTRUCK", "RENTALBUS", "TAXI", "TOURBUS", "TRASH", "TRASH2", "WASTELANDER", "AMBULANCE", "FBI", "FBI2", "FIRETRUK", "LGUARD", "PBUS", "POLICE", "POLICE2", "POLICE3", "POLICE4", "POLICEB", "POLICEOLD1", "POLICEOLD2", "POLICET", "POLMAV", "PRANGER", "PREDATOR", "RIOT", "RIOT2", "SHERIFF", "SHERIFF2", "APC", "BARRACKS", "BARRACKS2", "BARRACKS3", "BARRAGE", "CHERNOBOG", "CRUSADER", "HALFTRACK", "KHANJALI", "RHINO", "SCARAB", "SCARAB2", "SCARAB3", "THRUSTER", "TRAILERSMALL2" } local commercial = { "BENSON", "BIFF", "CERBERUS", "CERBERUS2", "CERBERUS3", "HAULER", "HAULER2", "MULE", "MULE2", "MULE3", "MULE4", "PACKER", "PHANTOM", "PHANTOM2", "PHANTOM3", "POUNDER", "POUNDER2", "STOCKADE", "STOCKADE3", "TERBYTE", "CABLECAR", "FREIGHT", "FREIGHTCAR", "FREIGHTCONT1", "FREIGHTCONT2", "FREIGHTGRAIN", "METROTRAIN", "TANKERCAR" }
local colors = { classic = { ["Black"] = 0, ["Carbon Black"] = 147, ["Graphite"] = 1, ["Anhracite Black"] = 11, ["Black Steel"] = 2, ["Dark Steel"] = 3, ["Silver"] = 4, ["Bluish Silver"] = 5, ["Rolled Steel"] = 6, ["Shadow Silver"] = 7, ["Stone Silver"] = 8, ["Midnight Silver"] = 9, ["Cast Iron Silver"] = 10, ["Red"] = 27, ["Torino Red"] = 28, ["Formula Red"] = 29, ["Lava Red"] = 150, ["Blaze Red"] = 30, ["Grace Red"] = 31, ["Garnet Red"] = 32, ["Sunset Red"] = 33, ["Cabernet Red"] = 34, ["Wine Red"] = 143, ["Candy Red"] = 35, ["Hot Pink"] = 135, ["Pfsiter Pink"] = 137, ["Salmon Pink"] = 136, ["Sunrise Orange"] = 36, ["Orange"] = 38, ["Bright Orange"] = 138, ["Gold"] = 99, ["Bronze"] = 90, ["Yellow"] = 88, ["Race Yellow"] = 89, ["Dew Yellow"] = 91, ["Dark Green"] = 49, ["Racing Green"] = 50, ["Sea Green"] = 51, ["Olive Green"] = 52, ["Bright Green"] = 53, ["Gasoline Green"] = 54, ["Lime Green"] = 92, ["Midnight Blue"] = 141, ["Galaxy Blue"] = 61, ["Dark Blue"] = 62, ["Saxon Blue"] = 63, ["Blue"] = 64, ["Mariner Blue"] = 65, ["Harbor Blue"] = 66, ["Diamond Blue"] = 67, ["Surf Blue"] = 68, ["Nautical Blue"] = 69, ["Racing Blue"] = 73, ["Ultra Blue"] = 70, ["Light Blue"] = 74, ["Chocolate Brown"] = 96, ["Bison Brown"] = 101, ["Creeen Brown"] = 95, ["Feltzer Brown"] = 94, ["Maple Brown"] = 97, ["Beechwood Brown"] = 103, ["Sienna Brown"] = 104, ["Saddle Brown"] = 98, ["Moss Brown"] = 100, ["Woodbeech Brown"] = 102, ["Straw Brown"] = 99, ["Sandy Brown"] = 105, ["Bleached Brown"] = 106, ["Schafter Purple"] = 71, ["Spinnaker Purple"] = 72, ["Midnight Purple"] = 142, ["Bright Purple"] = 145, ["Cream"] = 107, ["Ice White"] = 111, ["Frost White"] = 112 }, matte = { ["Black"] = 12, ["Gray"] = 13, ["Light Gray"] = 14, ["Ice White"] = 131, ["Blue"] = 83, ["Dark Blue"] = 82, ["Midnight Blue"] = 84, ["Midnight Purple"] = 149, ["Schafter Purple"] = 148, ["Red"] = 39, ["Dark Red"] = 40, ["Orange"] = 41, ["Yellow"] = 42, ["Lime Green"] = 55, ["Green"] = 128, ["Forest Green"] = 151, ["Foliage Green"] = 155, ["Olive Darb"] = 152, ["Dark Earth"] = 153, ["Desert Tan"] = 154 }, metal = { ["Brushed Steel"] = 117, ["Brushed Black Steel"] = 118, ["Brushed Aluminum"] = 119, ["Pure Gold"] = 158, ["Brushed Gold"] = 159 }, utility = { ["BLACK"] = 15, ["FMMC_COL1_1"] = 16, ["DARK_SILVER"] = 17, ["SILVER"] = 18, ["BLACK_STEEL"] = 19, ["SHADOW_SILVER"] = 20, ["DARK_RED"] = 43, ["RED"] = 44, ["GARNET_RED"] = 45, ["DARK_GREEN"] = 56, ["GREEN"] = 57, ["DARK_BLUE"] = 75, ["MIDNIGHT_BLUE"] = 76, ["SAXON_BLUE"] = 77, ["NAUTICAL_BLUE"] = 78, ["BLUE"] = 79, ["FMMC_COL1_13"] = 80, ["BRIGHT_PURPLE"] = 81, ["STRAW_BROWN"] = 93, ["UMBER_BROWN"] = 108, ["MOSS_BROWN"] = 109, ["SANDY_BROWN"] = 110, ["veh_color_off_white"] = 122, ["BRIGHT_GREEN"] = 125, ["HARBOR_BLUE"] = 127, ["FROST_WHITE"] = 134, ["LIME_GREEN"] = 139, ["ULTRA_BLUE"] = 140, ["GREY"] = 144, ["LIGHT_BLUE"] = 157, ["YELLOW"] = 160 }, worn = { ["BLACK"] = 21, ["GRAPHITE"] = 22, ["LIGHT_GREY"] = 23, ["SILVER"] = 24, ["BLUE_SILVER"] = 25, ["SHADOW_SILVER"] = 26, ["RED"] = 46, ["SALMON_PINK"] = 47, ["DARK_RED"] = 48, ["DARK_GREEN"] = 58, ["GREEN"] = 59, ["SEA_GREEN"] = 60, ["DARK_BLUE"] = 85, ["BLUE"] = 86, ["LIGHT_BLUE"] = 87, ["SANDY_BROWN"] = 113, ["BISON_BROWN"] = 114, ["CREEK_BROWN"] = 115, ["BLEECHED_BROWN"] = 116, ["veh_color_off_white"] = 121, ["ORANGE"] = 123, ["SUNRISE_ORANGE"] = 124, ["veh_color_taxi_yellow"] = 126, ["RACING_GREEN"] = 129, ["ORANGE"] = 130, ["WHITE"] = 131, ["FROST_WHITE"] = 132, ["OLIVE_GREEN"] = 133 }, chrome = 120 }
local upgrades = { ["Suspension"] = { type = 13, types = { ["Stock Suspension"] = {index = -1}, ["Lowered Suspension"] = {index = false}, ["Street Suspension"] = {index = 1}, ["Sport Suspension"] = {index = 2}, ["Competition Suspension"] = {index = 3} } }, ["Armour"] = { type = 16, types = { ["None"] = {index = -1}, ["Armor Upgrade 20%"] = {index = false}, ["Armor Upgrade 40%"] = {index = 1}, ["Armor Upgrade 60%"] = {index = 2}, ["Armor Upgrade 80%"] = {index = 3}, ["Armor Upgrade 100%"] = {index = 4} } }, ["Transmission"] = { type = 13, types = { ["Stock Transmission"] = {index = -1}, ["Street Transmission"] = {index = false}, ["Sports Transmission"] = {index = 1}, ["Race Transmission"] = {index = 2} } }, ["Turbo"] = { type = 18, types = { ["None"] = {index = false}, ["Turbo Tuning"] = {index = true} } }, ["Lights"] = { type = 22, types = { ["Stock Lights"] = {index = false}, ["Xenon Lights"] = {index = true} }, xenonHeadlightColors = { ["Default"] = {index = -1}, ["White"] = {index = 0}, ["Blue"] = {index = 1}, ["Electric_Blue"] = {index = 2}, ["Mint_Green"] = {index = 3}, ["Lime_Green"] = {index = 4}, ["Yellow"] = {index = 5}, ["Golden_Shower"] = {index = 6}, ["Orange"] = {index = 7}, ["Red"] = {index = 8}, ["Pony_Pink"] = {index = 9}, ["Hot_Pink"] = {index = 10}, ["Purple"] = {index = 11}, ["Blacklight"] = {index = 12} } }, ["Engine"] = { type = 11, types = { ["EMS Upgrade, Level 1"] = {index = -1}, ["EMS Upgrade, Level 2"] = {index = false}, ["EMS Upgrade, Level 3"] = {index = 1}, ["EMS Upgrade, Level 4"] = {index = 2} } }, ["Brakes"] = { type = 12, types = { ["Stock Brakes"] = {index = -1}, ["Street Brakes"] = {index = false}, ["Sport Brakes"] = {index = 1}, ["Race Brakes"] = {index = 2} } }, ["Horns"] = { type = 14, types = { ["Stock Horn"] = {index = -1}, ["Truck Horn"] = {index = false}, ["Police Horn"] = {index = 1}, ["Clown Horn"] = {index = 2}, ["Musical Horn 1"] = {index = 3}, ["Musical Horn 2"] = {index = 4}, ["Musical Horn 3"] = {index = 5}, ["Musical Horn 4"] = {index = 6}, ["Musical Horn 5"] = {index = 7}, ["Sadtrombone Horn"] = {index = 8}, ["Calssical Horn 1"] = {index = 9}, ["Calssical Horn 2"] = {index = 10}, ["Calssical Horn 3"] = {index = 11}, ["Calssical Horn 4"] = {index = 12}, ["Calssical Horn 5"] = {index = 13}, ["Calssical Horn 6"] = {index = 14}, ["Calssical Horn 7"] = {index = 15}, ["Scaledo Horn"] = {index = 16}, ["Scalere Horn"] = {index = 17}, ["Scalemi Horn"] = {index = 18}, ["Scalefa Horn"] = {index = 19}, ["Scalesol Horn"] = {index = 20}, ["Scalela Horn"] = {index = 21}, ["Scaleti Horn"] = {index = 22}, ["Scaledo Horn High"] = {index = 23}, ["Jazz Horn 1"] = {index = 25}, ["Jazz Horn 2"] = {index = 26}, ["Jazz Horn 3"] = {index = 27}, ["Jazzloop Horn"] = {index = 28}, ["Starspangban Horn 1"] = {index = 29}, ["Starspangban Horn 2"] = {index = 30}, ["Starspangban Horn 3"] = {index = 31}, ["Starspangban Horn 4"] = {index = 32}, ["Classicalloop Horn 1"] = {index = 33}, ["Classical Horn 8"] = {index = 34}, ["Classicalloop Horn 2"] = {index = 35} } }, ["Wheels"] = { type = 23, ["suv"] = { type = 3, types = { ["Stock"] = {index = -1}, ["Vip"] = {index = false}, ["Benefactor"] = {index = 1}, ["Cosmo"] = {index = 2}, ["Bippu"] = {index = 3}, ["Royalsix"] = {index = 4}, ["Fagorme"] = {index = 5}, ["Deluxe"] = {index = 6}, ["Icedout"] = {index = 7}, ["Cognscenti"] = {index = 8}, ["Lozspeedten"] = {index = 9}, ["Supernova"] = {index = 10}, ["Obeyrs"] = {index = 11}, ["Lozspeedballer"] = {index = 12}, ["Extra vaganzo"] = {index = 13}, ["Splitsix"] = {index = 14}, ["Empowered"] = {index = 15}, ["Sunrise"] = {index = 16}, ["Dashvip"] = {index = 17}, ["Cutter"] = {index = 18} } }, ["sport"] = { type = false, types = { ["Stock"] = {index = -1}, ["Inferno"] = {index = false}, ["Deepfive"] = {index = 1}, ["Lozspeed"] = {index = 2}, ["Diamondcut"] = {index = 3}, ["Chrono"] = {index = 4}, ["Feroccirr"] = {index = 5}, ["Fiftynine"] = {index = 6}, ["Mercie"] = {index = 7}, ["Syntheticz"] = {index = 8}, ["Organictyped"] = {index = 9}, ["Endov1"] = {index = 10}, ["Duper7"] = {index = 11}, ["Uzer"] = {index = 12}, ["Groundride"] = {index = 13}, ["Spacer"] = {index = 14}, ["Venum"] = {index = 15}, ["Cosmo"] = {index = 16}, ["Dashvip"] = {index = 17}, ["Icekid"] = {index = 18}, ["Ruffeld"] = {index = 19}, ["Wangenmaster"] = {index = 20}, ["Superfive"] = {index = 21}, ["Endov2"] = {index = 22}, ["Slitsix"] = {index = 23} } }, ["offroad"] = { type = 4, types = { ["Stock"] = {index = -1}, ["Raider"] = {index = false}, ["Mudslinger"] = {index = 1}, ["Nevis"] = {index = 2}, ["Cairngorm"] = {index = 3}, ["Amazon"] = {index = 4}, ["Challenger"] = {index = 5}, ["Dunebasher"] = {index = 6}, ["Fivestar"] = {index = 7}, ["Rockcrawler"] = {index = 8}, ["Milspecsteelie"] = {index = 9} } }, ["tuner"] = { type = 5, types = { ["Stock"] = {index = -1}, ["Cosmo"] = {index = false}, ["Supermesh"] = {index = 1}, ["Outsider"] = {index = 2}, ["Rollas"] = {index = 3}, ["Driffmeister"] = {index = 4}, ["Slicer"] = {index = 5}, ["Elquatro"] = {index = 6}, ["Dubbed"] = {index = 7}, ["Fivestar"] = {index = 8}, ["Slideways"] = {index = 9}, ["Apex"] = {index = 10}, ["Stancedeg"] = {index = 11}, ["Countersteer"] = {index = 12}, ["Endov1"] = {index = 13}, ["Endov2dish"] = {index = 14}, ["Guppez"] = {index = 15}, ["Chokadori"] = {index = 16}, ["Chicane"] = {index = 17}, ["Saisoku"] = {index = 18}, ["Dishedeight"] = {index = 19}, ["Fujiwara"] = {index = 20}, ["Zokusha"] = {index = 21}, ["Battlevill"] = {index = 22}, ["Rallymaster"] = {index = 23} } }, ["highend"] = { type = 7, types = { ["Stock"] = {index = -1}, ["Shadow"] = {index = false}, ["Hyper"] = {index = 1}, ["Blade"] = {index = 2}, ["Diamond"] = {index = 3}, ["Supagee"] = {index = 4}, ["Chromaticz"] = {index = 5}, ["Merciechlip"] = {index = 6}, ["Obeyrs"] = {index = 7}, ["Gtchrome"] = {index = 8}, ["Cheetahr"] = {index = 9}, ["Solar"] = {index = 10}, ["Splitten"] = {index = 11}, ["Dashvip"] = {index = 12}, ["Lozspeedten"] = {index = 13}, ["Carboninferno"] = {index = 14}, ["Carbonshadow"] = {index = 15}, ["Carbonz"] = {index = 16}, ["Carbonsolar"] = {index = 17}, ["Carboncheetahr"] = {index = 18}, ["Carbonsracer"] = {index = 19} } }, ["lowrider"] = { type = 2, types = { ["Stock"] = {index = -1}, ["Flare"] = {index = false}, ["Wired"] = {index = 1}, ["Triplegolds"] = {index = 2}, ["Bigworm"] = {index = 3}, ["Sevenfives"] = {index = 4}, ["Splitsix"] = {index = 5}, ["Freshmesh"] = {index = 6}, ["Leadsled"] = {index = 7}, ["Turbine"] = {index = 8}, ["Superfin"] = {index = 9}, ["Classicrod"] = {index = 10}, ["Dollar"] = {index = 11}, ["Dukes"] = {index = 12}, ["Lowfive"] = {index = 13}, ["Gooch"] = {index = 14} } }, ["muscle"] = { type = 1, types = { ["Stock"] = {index = -1}, ["Classicfive"] = {index = false}, ["Dukes"] = {index = 1}, ["Musclefreak"] = {index = 2}, ["Kracka"] = {index = 3}, ["Azrea"] = {index = 4}, ["Mecha"] = {index = 5}, ["Blacktop"] = {index = 6}, ["Dragspl"] = {index = 7}, ["Revolver"] = {index = 8}, ["Classicrod"] = {index = 9}, ["Spooner"] = {index = 10}, ["Fivestar"] = {index = 11}, ["Oldschool"] = {index = 12}, ["Eljefe"] = {index = 13}, ["Dodman"] = {index = 14}, ["Sixgun"] = {index = 15}, ["Mercenary"] = {index = 16} } } } }
local bones = {
    ['body'] = 0,
    ['head'] = 31086,
    ['pelvis'] = 11816,
    ['left foot'] = 14201,
    ['right foot'] = 52301,
    ['right calf'] = 36864,
    ['left calf'] = 63931,
}
menus = {
    "insidous",
    "self",
    "network",
    "vehicles",
    "world",
    "teleport",
    "misc",
    "lua",
    "settings",
    "health",
    "movement",
    "freecam",
    "esp",
    "teleportolocations",
    "troll",
    "money",
    "spawnVehicle",
    "customlscengine",
    "customengine",
    "customtransmission",
    "customturbo",
    "weapons",
    "giveWeapons",
    "resources",
    "weatherchanger",
    "worldvision",
    "players",
    "playeroptions",
    "trolloptions",
    "weaponoptions",
    "teleportoptions",
    "meleeWeapons",
    "thrownWeapons",
    "pistolWeapons",
    "smgWeapons",
    "assaultWeapons",
    "shotgunWeapons",
    "sniperWeapons",
    "heavyWeapons",
    "meleeWeapons1",
    "thrownWeapons1",
    "pistolWeapons1",
    "smgWeapons1",
    "assaultWeapons1",
    "shotgunWeapons1",
    "sniperWeapons1",
    "heavyWeapons1",
    'compacts',
    'sedans',
    'suvs',
    'coupes',
    'muscle',
    'sportsclassics',
    'sports',
    'super',
    'motorcycles',
    'offroad',
    'industrial',
    'utility',
    'vans',
    'cycles',
    'boats',
    'helicopters',
    'planes',
    'service',
    'commercial',
    "allplayersoptions",
    "lsc",
    "visual",
    "vehicleRockets",
    "noclip",
    "addonCars"
}
local types = {
    ['Object'] = {
        FindFirstObject,
        FindNextObject,
        EndFindObject
    },
    ['Ped'] = {
        FindFirstPed,
        FindNextPed,
        EndFindPed
    },
    ['Vehicle'] = {
        FindFirstVehicle,
        FindNextVehicle,
        EndFindVehicle
    }
}
local objectlist = {
    ['Washer'] = 'prop_washer_02',
    ['Wall'] = 'prop_const_fence02b',
    ['Grid'] = 'prop_fncsec_03c',
    ['Movie screen'] = 'prop_ld_filmset',
    ['Pipe'] = 'sr_prop_stunt_tube_crn2_05a',
    ['Airplane'] = 'apa_mp_apa_crashed_usaf_01a',
    ['Commercial Sale'] = 'prop_airport_sale_sign',
    ['Elecbox'] = 'lts_prop_lts_elecbox_24b',
    ['Coffee'] = 'p_ld_coffee_vend_01',
    ['Cash'] = 'hei_prop_cash_crate_half_full',
    ['Sofa'] = 'p_yacht_sofa_01_s',
    ['Turkey Flag'] = 'apa_prop_flag_turkey',
    ['German Flag'] = 'apa_prop_flag_german_yt',
    ['Belgium Flag'] = 'apa_prop_flag_belgium',
    ['Netherlands Flag'] = 'apa_prop_flag_netherlands',
    ['Xmas'] = 'prop_xmas_tree_int',
    ['Xmas1'] = 'prop_xmas_ext',
    ['Xmas2'] = 'xs_propintxmas_cluboffice_2018',
    ['Barge'] = 'xm_prop_x17_barge_01',
    ['Subdamage'] = 'xm_prop_x17_sub_damage',
    ['Arena'] = 'xs_prop_arena_goal',
    ['Indistrial'] = 'xs_prop_arena_industrial_a',
    ['Stadium Light'] = 'xs_propintarena_lamps_01a',
    ['Building'] = 'xs_prop_ar_buildingx_01a_sf',
    ['Fire'] = 'xs_prop_arena_pit_fire_01a_wl',
    ['Dyst'] = 'xs_combined_dyst_03_brdg01',
    ['Bulding'] = 'xs_propint2_building_base_02',
    ['Spinning'] = 'p_spinning_anus_s',
    ['Jet'] = 'p_cs_mp_jet_01_s',
    ['Airship'] = 'prop_temp_carrier',
    ['Yacht'] = 'apa_mp_apa_yacht',
    ['Damship'] = 'gr_prop_damship_01a',
    ['Shipsink'] = 'des_shipsink_01',
    ['Fnclink'] = 'prop_fnclink_05crnr1',
    ['Logpile'] = 'prop_logpile_07b',
    ['Airlights'] = 'prop_air_lights_04a',
    ['Fuel Gas Pump'] = 'prop_gas_pump_1c',
    ['Gas Tank'] = 'prop_gas_tank_02a',
}
local ControlKeys = {
    ['Left Ctrl'] = 224,
    ['Left Alt'] = 19,
    ['Tab'] = 37,
    ['Left Shift'] = 21,
    ['Spacebar'] = 22,
    ['Right Mouse Button'] = 25,
    ['X'] = 105
}
WeatherList = { 
    "CLEAR",
    "EXTRASUNNY",
    "CLOUDS",
    "OVERCAST",
    "RAIN",
    "CLEARING",
    "THUNDER",
    "SMOG",
    "FOGGY",
    "XMAS",
    "SNOWLIGHT",
    "BLIZZARD"
}
local acDefaultNames = {
    ['API-Anticheat'] = 'miner',
    ['Ironshield'] = "ironshield",
    ['Badger-Anticheat'] = "Badger-Anticheat-master",
    ['Anticheese-Anticheat'] = "anticheese-anticheat-master",
    ['Badger-Anticheat'] = "Badger-Anticheat",
    ['Anticheese-Anticheat'] = "anticheese-anticheat"
}
local carList = {
    "amdbx",
    "ast",
    "80B4",
    "audquattros",
    "r8ppi",
    "rs72020",
    "s8d2",
    "sq72016",
    "bbentayga",
    "cgts",
    "760li04",
    "e34",
    "m2",
    "m3e36",
    "m3e92",
    "m3f80",
    "m4f82",
    "m6f13",
    "z419",
    "cats",
    "cesc21",
    "09tahoe",
    "15tahoe",
    "camrs17",
    "tahoe21",
    "c7",
    "c8",
    "corvettec5z06",
    "czr1",
    "16charger",
    "f430s",
    "f150",
    "f15078",
    "fgt",
    "gt17",
    "raptor2017",
    "dragekcivick",
    "ap2",
    "ep3",
    "honcrx91",
    "na1",
    "it18",
    "fpacehm",
    "jeep2012",
    "jeepreneg",
    "srt8",
    "trhawk",
    "regera",
    "huracanst",
    "lambose",
    "lp700r",
    "svj63",
    "urus",
    "veneno",
    "gs350",
    "rcf",
    "lrrr",
    "esprit02",
    "regalia",
    "levante",
    "84rx7k",
    "dragfd",
    "fc3s",
    "majfd",
    "miata3",
    "na6",
    "mcst",
    "amggtrr20",
    "c6320",
    "G65",
    "e400",
    "gl63",
    "mbc63",
    "s500w222",
    "sl500",
    "v250",
    "cp9a",
    "fto",
    "180sx",
    "gtr",
    "gtrc",
    "maj350",
    "nis15",
    "nissantitan17",
    "ns350",
    "nzp",
    "s14",
    "Safari97",
    "skyline",
    "z32",
    "718caymans",
    "cgt",
    "maj935",
    "pcs18",
    "taycan",
    "rrevoque",
    "rsvr16",
    "rculi",
    "rrphantom",
    "wraith",
    "subisti08",
    "subwrx",
    "svx",
    "a80",
    "mk2100",
    "vxr",
    "golfgti7",
    "xc90",
    "lykan",
    "wmfenyr",
    "tltypes",
    "aaq4",
    "q820",
    "r820",
    "rs6",
    "ttrs",
    "bolide",
    "wildtrak",
    "17civict",
    "fk8",
    "pm19",
    "bmci",
    "x6m",
    "x5e53",
    "i8",
    "stingray",
    "2020ss",
    "99viper",
    "chr20",
    "demon",
    "raid",
    "ram2500",
    "srt4",
    "trx",
    "16challenger",
    "sandero",
    "logan",
    "1310",
    "cutlass",
    "stepway",
    "488",
    "f812",
    "fct",
    "fxxk",
    "laferrari",
    "mig",
    "yFe458i1",
    "yFe458i2",
    "yFe458s1X",
    "yFe458s1",
    "yFe458s2X",
    "yFe458s2",
    "yFeF12T",
    "yFeF12A",
    "mustang50th",
    "agerars",
    "lp670sv",
    "is350mod",
    "650s",
    "675lt",
    "720s",
    "gtr96",
    "mp412c",
    "senna",
    "yPG205t16A",
    "yPG205t16B",
    "twingo",
    "rrst",
    "dawnonyx",
    "gsxr19",
    "katana",
    "tr22",
    "p90d",
    "models",
    "tmodel",
    "teslax",
    "teslapd",
    "cam8tun",
    "toysupmk4",
    "ae86",
    "amarok",
    "vwr",
    "passat",
    "golf8gti",
    "m1procar",
    "clklm",
    "fgt2",
    "fgt3",
    "fxxk",
    "lhgt3",
    "pragar1",
    "radical",
    "rmodamgc63",
    "rmodfordgt",
    "rmodgtr",
    "rmodlp570",
    "rmodlp750",
    "rmodlp770",
    "rmodm3e36",
    "rmodm4",
    "rmodm4gts",
    "rmodpagani",
    "rmodskyline",
    "rmodsupra",
    "rmodveneno",
    "rmp4",
    "scuderiag",
    "zondar",
    "0x3FCCEF54",
    "0x65E5302C",
    "0x93E51687",
    "0xAEFD305D",
    "0xB1CF5619",
    "0xC2AAF50E",
    "0xD0841904",
    "0xD17E92B9",
}
local validCarList = {}
-- Keybinds
    local isNoClipKeyBind = false
-- Keybinds end
local acnamelist = {}
for k, v in pairs(acDefaultNames) do
    table.insert(acnamelist, k)
end
local keynamelist = {}
for k, v in pairs(ControlKeys) do
    table.insert(keynamelist, k)
end
local objectnamelist = {}
for k, v in pairs(objectlist) do
    table.insert(objectnamelist, k)
end
Citizen.CreateThread(function()
    while true do
        SetDiscordAppId('918240293264957491')
        SetDiscordRichPresenceAsset('image')
        SetRichPresence('This user is currently using  Insidous for FiveM')
        SetDiscordRichPresenceAction(0, "Insidous", "")
        SetDiscordRichPresenceAction(1, "Forum", "")
        Citizen.Wait(5000)
    end
end)
local _objectIndex = 1
local selectedPlayerId = 0
local _rampIndex = 1
local defaultIcon = "CHAR_BLIMP2"
AimbotBoneOps = {"Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Dick"}
withoutme = true
local isGodmode = false
local NoRagdoll = false
local isNames = false
local BlipsEnabled = false
local isFreecam = false
local FreecamSpeed = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0.5, 0.2, 0.1}
local _FreecamSpeedIndex = 1
local freecamcam = nil
local isObjectPreview = false
local isESP = false
local ESPAlpha = {255, 200, 150, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10}
local _ESPAlphaIndex = 1
local NoClip = false
local NoClipSpeed = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 35, 40, 45, 50, 0.5, 0.2, 0.1}
local _NoClipIndex = 1
local _NoClipControlKeyIndex = 1
local currWeatherIndex = 1
local selWeatherIndex = 1
local NoClipVisible = true
local visible = false
local InfStamina = false
local EasyHandling = false
local CarGodmode = false
local VehicleRainbow = false
local SuperJump = false
local FastRun = false
local InfAmmo = false
local ExplosivAmmo = false
local rapidFire = false
local AutoRevive = false
local tpGun = false
local fireworkgun = false
local Aimbot = false
local AlienGun = false
local magnet = false
local EasyHandling = false
local VehicleAutoFix = false
local therm = false
local bTherm = false
local currentshockwaveRadiusIndex = 1
local Tracking = false
Spectating = false
currAimbotBoneIndex = 1
ShockwaveRadiusdv = {5.0, 10.0, 15.0, 20.0, 50.0}
ShockwaveRadius = 5.0
local resources = GetResources()
WarMenu.CreateMenu('insidous', '', 'Free Version | Insidous')
WarMenu.CreateSubMenu('self', 'insidous', 'Self Options')
WarMenu.CreateSubMenu('network', 'insidous', 'Network')
WarMenu.CreateSubMenu('vehicles', 'insidous', 'Vehicles')
WarMenu.CreateSubMenu('weapons', 'insidous', 'Weapons')
WarMenu.CreateSubMenu('world', 'insidous', 'World')
WarMenu.CreateSubMenu('teleport', 'insidous', 'Teleport')
WarMenu.CreateSubMenu('lua', 'insidous', 'Lua')
WarMenu.CreateSubMenu('settings', 'insidous', 'Menu Settings')
-- Self menu
WarMenu.CreateSubMenu('health', 'self', 'health')
WarMenu.CreateSubMenu('movement', 'self', 'movement')
WarMenu.CreateSubMenu('visual', 'self', 'visual')
WarMenu.CreateSubMenu('misc', 'self', 'misc')
-- Movement
WarMenu.CreateSubMenu('noclip', 'movement', 'NoClip')
-- Teleportation
WarMenu.CreateSubMenu('teleportolocations', 'teleport', 'Teleport to Locations')
-- Lua Options
WarMenu.CreateSubMenu('troll', 'lua', 'Troll')
WarMenu.CreateSubMenu('money', 'lua', 'Money')
-- Funny Options
    -- Empty
-- Visual
WarMenu.CreateSubMenu('esp', 'visual', 'ESP')
-- Network
WarMenu.CreateSubMenu('resources', 'network', 'Resources')
WarMenu.CreateSubMenu('players', 'network', 'Players')
WarMenu.CreateSubMenu('allplayersoptions', 'players', 'All Players')
WarMenu.CreateSubMenu('playeroptions', 'players', 'Player Options')
WarMenu.CreateSubMenu('trolloptions', 'playeroptions', 'Trolling Options')
WarMenu.CreateSubMenu('teleportoptions', 'playeroptions', 'Teleport Options')
WarMenu.CreateSubMenu('weaponoptions', 'playeroptions', 'Weapon Options')
WarMenu.CreateSubMenu('meleeWeapons1', 'weaponoptions', 'Melee Weapons')
WarMenu.CreateSubMenu('thrownWeapons1', 'weaponoptions', 'Thrown Weapons')
WarMenu.CreateSubMenu('pistolWeapons1', 'weaponoptions', 'Pistol Weapons')
WarMenu.CreateSubMenu('smgWeapons1', 'weaponoptions', 'SMG Weapons')
WarMenu.CreateSubMenu('assaultWeapons1', 'weaponoptions', 'Assault Weapons')
WarMenu.CreateSubMenu('shotgunWeapons1', 'weaponoptions', 'Shotgun Weapons')
WarMenu.CreateSubMenu('sniperWeapons1', 'weaponoptions', 'Sniper Weapons')
WarMenu.CreateSubMenu('heavyWeapons1', 'weaponoptions', 'Heavy Weapons')
-- Misc menu
WarMenu.CreateSubMenu('freecam', 'misc', 'Freecam')
-- Vehicles
WarMenu.CreateSubMenu('spawnVehicle', 'vehicles', 'Spawn Vehicle')
WarMenu.CreateSubMenu('vehicleRockets', 'vehicles', 'Vehicle Rockets')
WarMenu.CreateSubMenu('lsc', 'vehicles', 'LSC')
WarMenu.CreateSubMenu('customlscengine', 'lsc', 'Custom Engine')
WarMenu.CreateSubMenu('customengine', 'lsc', 'Engine')
WarMenu.CreateSubMenu('customtransmission', 'lsc', 'Engine')
WarMenu.CreateSubMenu('customturbo', 'lsc', 'Engine')
WarMenu.CreateSubMenu('addonCars', 'spawnVehicle', 'Add-On Spawner')
WarMenu.CreateSubMenu('compacts', 'spawnVehicle', 'Compacts')
WarMenu.CreateSubMenu('sedans', 'spawnVehicle', 'Sedans')
WarMenu.CreateSubMenu('suvs', 'spawnVehicle', 'SUVs')
WarMenu.CreateSubMenu('coupes', 'spawnVehicle', 'Coupes')
WarMenu.CreateSubMenu('muscle', 'spawnVehicle', 'Muscle')
WarMenu.CreateSubMenu('sportsclassics', 'spawnVehicle', 'Sports Classics')
WarMenu.CreateSubMenu('sports', 'spawnVehicle', 'Sports')
WarMenu.CreateSubMenu('super', 'spawnVehicle', 'Super')
WarMenu.CreateSubMenu('motorcycles', 'spawnVehicle', 'Motorcycles')
WarMenu.CreateSubMenu('offroad', 'spawnVehicle', 'Off-Road')
WarMenu.CreateSubMenu('industrial', 'spawnVehicle', 'Industrial')
WarMenu.CreateSubMenu('utility', 'spawnVehicle', 'Utility')
WarMenu.CreateSubMenu('vans', 'spawnVehicle', 'Vans')
WarMenu.CreateSubMenu('cycles', 'spawnVehicle', 'Cycles')
WarMenu.CreateSubMenu('boats', 'spawnVehicle', 'Boats')
WarMenu.CreateSubMenu('helicopters', 'spawnVehicle', 'Helicopters')
WarMenu.CreateSubMenu('planes', 'spawnVehicle', 'Planes')
WarMenu.CreateSubMenu('service', 'spawnVehicle', 'Service')
WarMenu.CreateSubMenu('commercial', 'spawnVehicle', 'Commercial')
--Weapons
WarMenu.CreateSubMenu('giveWeapons', 'weapons', 'Give Weapons')
-- Weapon Cates
WarMenu.CreateSubMenu('meleeWeapons', 'giveWeapons', 'Melee Weapons')
WarMenu.CreateSubMenu('thrownWeapons', 'giveWeapons', 'Thrown Weapons')
WarMenu.CreateSubMenu('pistolWeapons', 'giveWeapons', 'Pistol Weapons')
WarMenu.CreateSubMenu('smgWeapons', 'giveWeapons', 'SMG Weapons')
WarMenu.CreateSubMenu('assaultWeapons', 'giveWeapons', 'Assault Weapons')
WarMenu.CreateSubMenu('shotgunWeapons', 'giveWeapons', 'Shotgun Weapons')
WarMenu.CreateSubMenu('sniperWeapons', 'giveWeapons', 'Sniper Weapons')
WarMenu.CreateSubMenu('heavyWeapons', 'giveWeapons', 'Heavy Weapons')
-- World
WarMenu.CreateSubMenu('worldvision', 'world', 'World Vision')
WarMenu.CreateSubMenu('weatherchanger', 'world', 'Weather Changer')
WarMenu.InitializeTheme()
Citizen.CreateThread(function()
    
		("~g~Supra-License~s~", "Welcome ~y~".. GetPlayerName(PlayerId()), 0)
    startupDui = CreateDui("https://insidous.club/sounds/startupsound.mp3", 1, 1)
    showPictureNotification(defaultIcon, "~y~supra on top~s~ found", "~g~Ronin~s~", "~r~Danger~s~")
    if has_resource("screenshot-basic") then
        showPictureNotification(defaultIcon, "~y~supra on top~s~", "~g~Ronin~s~", "~r~Danger~s~")
    end
end)
Citizen.CreateThread(function()
    for i=1, #carList, 1 do
        if IsModelValid(carList[i]) then
            if IsModelAVehicle(carList[i]) then
                table.insert(validCarList, carList[i])
            end
        end
    end
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsDisabledControlJustReleased(0, 161) then
            if WarMenu.IsAnyMenuOpened() ~= true then
                WarMenu.OpenMenu("insidous")
            else
                WarMenu.CloseMenu()
            end
            Citizen.CreateThread(function()
                while true do
                    Citizen.Wait(0)
                    if WarMenu.Begin('insidous') then
                        WarMenu.MenuButton('Self Options', 'self')
                        WarMenu.MenuButton('Network', 'network')
                        WarMenu.MenuButton('Vehicles', 'vehicles')
                        WarMenu.MenuButton('Weapons', 'weapons')
                        WarMenu.MenuButton('World', 'world')
                        WarMenu.MenuButton('Teleport', 'teleport')
                        WarMenu.MenuButton('Lua Options', 'lua')
                        WarMenu.MenuButton('Menu Settings', 'settings')
                        WarMenu.End()
                    elseif WarMenu.Begin("self") then
                        WarMenu.MenuButton('Health', 'health')
                        WarMenu.MenuButton('Movement', 'movement')
                        WarMenu.MenuButton("Visual", "visual")
                        WarMenu.MenuButton('Misc', 'misc')
                        WarMenu.End()
                    elseif WarMenu.Begin("visual") then
                        WarMenu.MenuButton('ESP', 'esp')
                        if (WarMenu.CheckBox("Show Names", isNames)) then
                            toggleNames()
                        end
                        if (WarMenu.CheckBox("Show Playerblips", BlipsEnabled)) then
                            toggleBlips()
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("health") then
                        local pressed = WarMenu.Button("Refill Health", "~g~Native~s~")
                        if pressed then
                            SetEntityHealth(PlayerPedId(), 100)
                        end
                        local pressed = WarMenu.Button("Refill Armour", "~g~Native~s~")
                        if pressed then
                            SetPedArmour(PlayerPedId(), 100)
                        end
                        local pressed = WarMenu.Button("Refill Hunger", "~y~ESX~s~")
                        if pressed then
                            TriggerEvent('esx_status:set', 'hunger', 1000000)
                        end
                        local pressed = WarMenu.Button("Refill Thirst", "~y~ESX~s~")
                        if pressed then
                            TriggerEvent('esx_status:set', 'thirst', 1000000)
                        end
                        local pressed = WarMenu.Button("Revive", "~y~ESX~s~")
                        if pressed then
                            TriggerEvent('esx_ambulancejob:revive')
                        end
                        WarMenu.CreateCategory("~g~Functions~s~")
                        if (WarMenu.CheckBox("Auto Revive", AutoRevive)) then
                            toggleAutoRevive()
                        end
                        if (WarMenu.CheckBox("Godmode", isGodmode)) then
                            toggleGodmode()
                        end
                         if (WarMenu.CheckBox("Semi-Godmode", semigodmode)) then
                            togglesemigodmode()
                        end
                        WarMenu.CreateCategory("~s~")
                        local pressed = WarMenu.Button("~r~Suicide~s~", "~g~Native~s~")
                        if pressed then
                            SetEntityHealth(PlayerPedId(), 0)
                            SetPedArmour(PlayerPedId(), 0)
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("network") then
                        WarMenu.MenuButton('Players', 'players')
                        WarMenu.MenuButton('Resources', 'resources')
                        WarMenu.End()
                    elseif WarMenu.Begin("resources") then
                        for i=1, #resources, 1 do
                            local pressed = WarMenu.Button(resources[i], "")
                            if pressed then
                                --StopResource(resources[i])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("players") then
                        WarMenu.MenuButton("All Players", "allplayersoptions")
                        players = GetAllPlayers()
                        for i=1, #players, 1 do
                            local currPlayer = players[i]
                            local godmodeText = "~s~"
                            if GetPlayerInvincible(GetPlayerFromServerId(GetPlayerServerId(selectedPlayerId))) then
                                local godmodeText = "~r~Godmode~s~"
                            end
                            if players[i] == PlayerId() then
                                if WarMenu.MenuButton("~s~[".. GetPlayerServerId(players[i]) .."] ".. GetPlayerName(players[i]), "playeroptions", godmodeText .."~r~Self~s~") then
                                    selectedPlayerId = currPlayer
                                end
                            else
                                if WarMenu.MenuButton("~s~[".. GetPlayerServerId(players[i]) .."] ".. GetPlayerName(players[i]), "playeroptions", godmodeText) then
                                    selectedPlayerId = currPlayer
                                end
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("allplayersoptions") then
                        if (WarMenu.CheckBox("Without me", withoutme)) then
                            withoutme = not withoutme
                        end
                        if WarMenu.Button("Bruger Players", "") then
                            burgerall()
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Put a burger on all players')
                        end
                        if WarMenu.Button("Cage Players", "") then
                            cageall()
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Put all players in a cage')
                        end
                        if WarMenu.Button("Explode Players", "") then
                            explodeall()
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Explode all players')
                        end
                        if WarMenu.Button("Give All Weapons", "") then
                            Citizen.CreateThread(function()
                                pbase = GetAllPlayers()
                                for i=1, #pbase, 1 do
                                    if PlayerId() == pbase[i] and withoutme == false then
                                        GiveAllWeapons(pbase[i])
                                    end
                                end
                            end)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Give all players all weapons')
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("playeroptions") then
                        local godmodeText = "~s~"
                        if GetPlayerInvincible(GetPlayerFromServerId(GetPlayerServerId(selectedPlayerId))) then
                            godmodText = "~r~Enabled~s~"
                        end
                        WarMenu.Button("Selected Player", GetPlayerName(selectedPlayerId))
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('ID: '.. GetPlayerServerId(selectedPlayerId) ..'\nName: '.. GetPlayerName(selectedPlayerId) ..'\nGodmode: '.. godmodeText)
                        end
                        WarMenu.CreateCategory("")
                        if (WarMenu.CheckBox("Spectate Player", Spectating)) then
                            toggleSpectate(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Player Spectating is ~r~Risk~s~')
                        end
                        WarMenu.CreateCategory("~g~Fuctions~s~")
                        WarMenu.MenuButton("Trolling Options", "trolloptions")
                        WarMenu.MenuButton("Weapon Options", "weaponoptions")
                        WarMenu.MenuButton("Teleport Options", "teleportoptions")
                        WarMenu.CreateCategory("")
                        if (WarMenu.CheckBox("Track Player", Tracking)) then
                            toggleTracking(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Set waypoint to player')
                        end
                        if WarMenu.Button("Give Fuel for Vehicle", "~g~Native~s~") then
                            GiveFuel(selectedPlayerId)
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("trolloptions") then
                        if WarMenu.Button("Bruger Player", "") then
                            burgerPlayer(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Put a burger on the player')
                        end
                        if WarMenu.Button("Cage Player", "") then
                            cagePlayer(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Put the player in a cage')
                        end
                        if WarMenu.Button("Explode Player", "~r~Risk~s~") then
                            explodePlayer(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Makes the player explode')
                        end
                        if WarMenu.Button("Kick From Vehicle", "~g~Native~s~") then
                            KickFromVeh(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Kicks the player out of his vehicle')
                        end
                         if WarMenu.Button("Remove Fuel From Vehicle", "~g~Native~s~") then
                            RemoveFuel(selectedPlayerId)
                        end
                        if WarMenu.Button("Strip Weapons", "~g~Native~s~") then
                            StripPlayer(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Removes all weapons from the players weapon wheel')
                        end
                        WarMenu.CreateCategory("~g~Ramp Options~s~")
                        if WarMenu.Button("Ramp Player", "~g~Native~s~") then
                            Citizen.CreateThread(function()
                                model = industrial[_rampIndex]
                                coords = GetEntityCoords(GetPlayerPed(selectedPlayerId))
                                RequestModel(GetHashKey(model))
                                while not HasModelLoaded(GetHashKey(model)) do
                                    Citizen.Wait(0)
                                end
                                vehicle = CreateVehicle(model, coords.x+1, coords.y, coords.z, GetEntityHeading(GetPlayerPed(selectedPlayerId)))
                                SetVehicleBoostActive(vehicle, 1, 0)
                                SetVehicleForwardSpeed(vehicle, 700.0)
                            end)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('This function rams the selected player')
                        end
                        local _, rampIndex = WarMenu.ComboBox('Car Type', industrial, _rampIndex)
                        if _rampIndex ~= rampIndex then
                            _rampIndex = rampIndex
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Select a car with which the player will be rammed')
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("weaponoptions") then
                        if WarMenu.Button("Give All Weapons", "~g~Native~s~   ~r~Risk~s~") then
                            GiveAllWeapons(selectedPlayerId)
                        end
                        if WarMenu.Button("Give Max Ammo", "~g~Native~s~") then
                            GiveMaxAmmo(selectedPlayerId)
                        end
                        WarMenu.CreateCategory("~g~Single Weapons~s~")
                        WarMenu.MenuButton('Melee Weapons', 'meleeWeapons1')
                        WarMenu.MenuButton('Thrown Weapons', 'thrownWeapons1')
                        WarMenu.MenuButton('Pistol Weapons', 'pistolWeapons1')
                        WarMenu.MenuButton('SMG Weapons', 'smgWeapons1')
                        WarMenu.MenuButton('Assault Weapons', 'assaultWeapons1')
                        WarMenu.MenuButton('Shotgun Weapons', 'shotgunWeapons1')
                        WarMenu.MenuButton('Sniper Weapons', 'sniperWeapons1')
                        WarMenu.MenuButton('Heavy Weapons', 'heavyWeapons1')
                        WarMenu.End()
                        -- Network Weapons
                    elseif WarMenu.Begin("meleeWeapons1") then for i=1, #meleeweapons, 1 do local pressed = WarMenu.Button(meleeweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, meleeweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("thrownWeapons1") then for i=1, #thrownweapons, 1 do local pressed = WarMenu.Button(thrownweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, thrownweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("pistolWeapons1") then for i=1, #pistolweapons, 1 do local pressed = WarMenu.Button(pistolweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, pistolweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("smgWeapons1") then for i=1, #smgweapons, 1 do local pressed = WarMenu.Button(smgweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, smgweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("assaultWeapons1") then for i=1, #assaultweapons, 1 do local pressed = WarMenu.Button(assaultweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, assaultweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("shotgunWeapons1") then for i=1, #shotgunweapons, 1 do local pressed = WarMenu.Button(shotgunweapons[i][2], "~g~Native~s~") if pressed then GiveWeapon(selectedPlayerId, shotgunweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("sniperWeapons1") then for i=1, #sniperweapons, 1 do local pressed = WarMenu.Button(sniperweapons[i][2], "~g~Native~s~   ~r~Risk~s~") if pressed then GiveWeapon(selectedPlayerId, sniperweapons[i][1]) end end WarMenu.End() elseif WarMenu.Begin("heavyWeapons1") then for i=1, #heavyweapons, 1 do local pressed = WarMenu.Button(heavyweapons[i][2], "~g~Native~s~   ~r~Risk~s~") if pressed then GiveWeapon(selectedPlayerId, heavyweapons[i][1]) end end WarMenu.End()
                    elseif WarMenu.Begin("teleportoptions") then
                        if WarMenu.Button("Teleport to Player", "~g~Native~s~") then
                            TeleportToPlayer(selectedPlayerId)
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Teleporting is ~y~Semi-Risk~s~')
                        end
                        if WarMenu.Button("Teleport Player to me", "~y~ESX~s~") then
                            TeleportPlayertoMe(selectedPlayerId)
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("movement") then
                        WarMenu.MenuButton("NoClip", "noclip")
                        WarMenu.CreateCategory("~g~Functions~s~")
                        if (WarMenu.CheckBox("No Stamina", InfStamina)) then
                            toggleStamina()
                        end
                        if (WarMenu.CheckBox("SuperJump", SuperJump)) then
                            toggleSuperJump()
                        end
                        if (WarMenu.CheckBox("No Ragdoll", NoRagdoll)) then
                            toggleNoRagdoll()
                        end
                    if (WarMenu.CheckBox("FastRun",FastRun)) then 
                    ToggleFastRun()
                    end
                        WarMenu.End()
                    elseif WarMenu.Begin("noclip") then
                        if (WarMenu.CheckBox("NoClip", NoClip)) then
                            if isNoClipKeyBind == true then
                                ShowNotification("~r~Please disable you NoClip Keybind")
                            else
                                NoClip = not NoClip
                            end
                        end
                        WarMenu.CreateCategory("~g~Settings~s~")
                        if (WarMenu.CheckBox("NoClip Keybinded", isNoClipKeyBind)) then
                            if NoClip then
                                ShowNotification("~r~Please disable you NoClip")
                            else
                                isNoClipKeyBind = not isNoClipKeyBind
                            end
                        end
                        if (WarMenu.CheckBox("NoClip Visible", NoClipVisible)) then
                            NoClipVisible = not NoClipVisible
                        end
                        local _, NoClipControlKeyIndex = WarMenu.ComboBox('Keybind', keynamelist, _NoClipControlKeyIndex)
                        if _NoClipControlKeyIndex ~= NoClipControlKeyIndex then
                            _NoClipControlKeyIndex = NoClipControlKeyIndex
                        end
                        local _, NoClipIndex = WarMenu.ComboBox('Speed', NoClipSpeed, _NoClipIndex)
                        if _NoClipIndex ~= NoClipIndex then
                            _NoClipIndex = NoClipIndex
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("vehicles") then
                        WarMenu.MenuButton('Spawn Vehicle', 'spawnVehicle')
                        WarMenu.MenuButton('Vehicle Rockets', 'vehicleRockets', "~r~Risk~s~")
                        WarMenu.MenuButton('LSC', 'lsc', "~y~Semi-Risk~s~")
                        WarMenu.CreateCategory("~g~Functions~s~")
                        if WarMenu.Button("Fix Vehicle", "") then
                            if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
                                local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
                                FixVeh(vehicle)
                            else
                                ShowNotification("~r~You're in no vehicle~s~")
                            end
                        end
                        if (WarMenu.CheckBox("Vehicle Fix Loop", VehicleAutoFix)) then
                            toggleVehicleAutoFix()
                        end
                        if WarMenu.Button("Flip Vehicle") then
					    local ped = GetPlayerPed(-1)
					    local vehicle = GetVehiclePedIsIn(ped, true)
					    if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
						SetVehicleOnGroundProperly(vehicle)
                        end
                    end
        
                        if (WarMenu.CheckBox("Vehicle Godmode", CarGodmode)) then 
                           ToggleCarGodmode()
                        end
                        if (WarMenu.CheckBox("EasyHandling", EasyHandling)) then
                           toggleEasyHandling()
                        end
                        if (WarMenu.CheckBox("Vehicle Speedboost", Speedboost)) then
                            toggleVehicleSpeedboost()
                            ShowNotification("~r~Press E to activate~s~")
                        end
  
                        WarMenu.End()
                    elseif WarMenu.Begin("lsc") then
                        WarMenu.MenuButton('Custom LSC Engine', 'customlscengine')
                        WarMenu.MenuButton('Custom Engine', 'customengine')
                        WarMenu.MenuButton('Custom Transmission', 'customtransmission')
                        WarMenu.MenuButton('Custom Turbo', 'customturbo')
                        WarMenu.CreateCategory("~g~Functions~s~")
                         if (WarMenu.Button('Change Licenseplate',  "~g~Native~s~  ~r~Risk~s~")) then
                            local licensePlate = GetKeyboardInput("Enter a license Plate")
                            if licensePlate then
                                local playerPed = GetPlayerPed(-1)
                                local playerVeh = GetVehiclePedIsIn(playerPed, true)
                                SetVehicleNumberPlateText(playerVeh, licensePlate)
                            end
                        end
                        if WarMenu.Button("Make vehicle ~y~dirty~s~", "") then
                        if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
                        local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
                        SetVehicleDirtLevel(vehicle, 15.0)
                            else
                                ShowNotification("~r~You're in no vehicle~s~")
                            end
                        end
                        if WarMenu.Button("Make vehicle ~g~clean~s~", "") then
                            if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
                                local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
                                SetVehicleDirtLevel(vehicle, 1.0)
                            else
                                ShowNotification("~r~You're in no vehicle~s~")
                            end
                        end
                        
                        if (WarMenu.Button("Performance Tuning")) then
                            MaxOutEngine(GetVehiclePedIsUsing(PlayerPedId()))
                        end
                        if (WarMenu.Button("Max Tuning")) then
                            MaxOutFull(GetVehiclePedIsUsing(PlayerPedId()))
                        end
                        if (WarMenu.Button("Refill Vehicle")) then
                            RefillVehicle()
                        end
                       if (WarMenu.CheckBox("Vehicle Rainbow", VehicleRainbow)) then 
                           ToggleRainbowColor()
                        end
                        WarMenu.End()
                        elseif WarMenu.Begin("customlscengine") then
                        if WarMenu.Button('Engine Power boost reset') then
				        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0)
			            elseif WarMenu.Button('Engine Power boost ~h~~r~x2~s~') then
			          	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
			            elseif WarMenu.Button('Engine Power boost  ~h~~g~x3') then
				        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3.0 * 20.0)
			            elseif WarMenu.Button('Engine Power boost  ~h~~g~x4') then
				        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
			            elseif WarMenu.Button('Engine Power boost  ~h~~g~x5') then
				        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5.0 * 20.0)
			            end
                         WarMenu.End()
                      
                       elseif WarMenu.Begin("customengine") then
      				   local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 12, 1, 0)
			           if WarMenu.Button('~g~Brake Level 2') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 12, 2, 0)
			           elseif WarMenu.Button('~g~Brake Level 3') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 12, 3, 0)
			           elseif WarMenu.Button('~g~Brake Level 4') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 12, 4, 0)
			           elseif WarMenu.Button('~g~Brake Level 5') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 12, 5, 0)
			           end
                        WarMenu.End()
                      
                       elseif WarMenu.Begin("customtransmission") then
			           if WarMenu.Button('~g~Transmission Level 1') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 13, 1, 0)
			           elseif WarMenu.Button('~g~Transmission Level 2') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 13, 2, 0)
			           elseif WarMenu.Button('~g~Transmission Level 3') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 13, 3, 0)
			           elseif WarMenu.Button('~g~Transmission Level 4') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 13, 4, 0)
			           elseif WarMenu.Button('~g~Transmission Level 5') then
			           local veh = GetVehiclePedIsUsing(PlayerPedId())
				       SetVehicleMod(veh, 13, 5, 0)
			           end
                        WarMenu.End()
                       
                       elseif WarMenu.Begin("customturbo") then
			           if WarMenu.Button('~g~Turbo ON') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       ToggleVehicleMod(veh, 18, 1, 0)
			           elseif WarMenu.Button('~g~Turbo OFF') then
				       local veh = GetVehiclePedIsUsing(PlayerPedId())
				       ToggleVehicleMod(veh, 18, 0, 0)
			           end
                       WarMenu.End()
                    elseif WarMenu.Begin("vehicleRockets") then
                        WarMenu.CreateCategory("~h~~r~Work in progress..~s~")
                        WarMenu.End()
                    elseif WarMenu.Begin("spawnVehicle") then
                        _vehlInputName = nil
                        local pressed, vehlInputName = WarMenu.InputButton('Spawn vehicle by name', nil, _vehlInputName)
                        if pressed then
                            if vehlInputName then
                                SpawnVeh(vehlInputName, PlaceSelf)
                            end
                        end
                        WarMenu.CreateCategory("~g~Car list~s~")
                        WarMenu.MenuButton('Add-On Spawner', 'addonCars')
                        WarMenu.MenuButton('Compacts', 'compacts')
                        WarMenu.MenuButton('Sedans', 'sedans')
                        WarMenu.MenuButton('SUVs', 'suvs')
                        WarMenu.MenuButton('Coupes', 'coupes')
                        WarMenu.MenuButton('Muscle', 'muscle')
                        WarMenu.MenuButton('Sports Classics', 'sportsclassics')
                        WarMenu.MenuButton('Sports', 'sports')
                        WarMenu.MenuButton('Super', 'super')
                        WarMenu.MenuButton('Motorcycles', 'motorcycles')
                        WarMenu.MenuButton('Off-Road', 'offroad')
                        WarMenu.MenuButton('Industrial', 'industrial')
                        WarMenu.MenuButton('Utility', 'utility')
                        WarMenu.MenuButton('Vans', 'vans')
                        WarMenu.MenuButton('Cycles', 'cycles')
                        WarMenu.MenuButton('Boats', 'boats')
                        WarMenu.MenuButton('Helicopters', 'helicopters')
                        WarMenu.MenuButton('Planes', 'planes')
                        WarMenu.MenuButton('Service', 'service')
                        WarMenu.MenuButton('Commercial', 'commercial')
                        WarMenu.End()
                        -- Car menu Tabs
                    elseif WarMenu.Begin("addonCars") then
                        for i=1, #validCarList, 1 do
                            if WarMenu.Button(GetDisplayNameFromVehicleModel(validCarList[i])) then
                                SpawnVeh(validCarList[i], PlaceSelf)
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin('compacts') then for i=1, #compacts do if WarMenu.Button(compacts[i]) then SpawnVeh(compacts[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('sedans') then for i=1, #sedans do if WarMenu.Button(sedans[i]) then SpawnVeh(sedans[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('suvs') then for i=1, #suvs do if WarMenu.Button(suvs[i]) then SpawnVeh(suvs[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('coupes') then for i=1, #coupes do if WarMenu.Button(coupes[i]) then SpawnVeh(coupes[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('muscle') then for i=1, #muscle do if WarMenu.Button(muscle[i]) then SpawnVeh(muscle[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('sportsclassics') then for i=1, #sportsclassics do if WarMenu.Button(sportsclassics[i]) then SpawnVeh(sportsclassics[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('sports') then for i=1, #sports do if WarMenu.Button(sports[i]) then SpawnVeh(sports[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('super') then for i=1, #super do if WarMenu.Button(super[i]) then SpawnVeh(super[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('motorcycles') then for i=1, #motorcycles do if WarMenu.Button(motorcycles[i]) then SpawnVeh(motorcycles[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('offroad') then for i=1, #offroad do if WarMenu.Button(offroad[i]) then SpawnVeh(offroad[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('industrial') then for i=1, #industrial do if WarMenu.Button(industrial[i]) then SpawnVeh(industrial[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('utility') then for i=1, #utility do if WarMenu.Button(utility[i]) then SpawnVeh(utility[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('vans') then for i=1, #vans do if WarMenu.Button(vans[i]) then SpawnVeh(vans[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('cycles') then for i=1, #cycles do if WarMenu.Button(cycles[i]) then SpawnVeh(cycles[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('boats') then for i=1, #boats do if WarMenu.Button(boats[i]) then SpawnVeh(boats[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('helicopters') then for i=1, #helicopters do if WarMenu.Button(helicopters[i]) then SpawnVeh(helicopters[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('planes') then for i=1, #planes do if WarMenu.Button(planes[i]) then SpawnPlane(planes[i], PlaceSelf, SpawnInAir) end end WarMenu.End() elseif WarMenu.Begin('service') then for i=1, #vans do if WarMenu.Button(service[i]) then SpawnVeh(service[i], PlaceSelf) end end WarMenu.End() elseif WarMenu.Begin('commercial') then for i=1, #commercial do if WarMenu.Button(commercial[i]) then SpawnVeh(commercial[i], PlaceSelf) end end WarMenu.End()
                    elseif WarMenu.Begin("weapons") then
                        local pressed = WarMenu.Button("Give All Weapons", "~g~Native~s~   ~r~Risk~s~")
                        if pressed then
                            GiveAllWeapons(PlayerId())
                        end
                        if WarMenu.Button("Give Max Ammo", "~g~Native~s~") then
                            GiveMaxAmmo(PlayerId())
                        end
                        WarMenu.MenuButton('Give Weapons', 'giveWeapons')
                        WarMenu.CreateCategory("~g~Functions~s~")
                        if (WarMenu.CheckBox("Infinite Ammo", InfAmmo)) then
                            toggleInfAmmo()
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Infinite Ammo is ~r~Risk~s~')
                        end
                        if (WarMenu.CheckBox("Explosive Ammo", ExplosivAmmo)) then
                            toggleExplosivAmmo()
                        end
                        if WarMenu.IsItemHovered() then
                            WarMenu.ToolTip('Explosive is ~y~Semi-Risk~s~')
                        end
                        if (WarMenu.CheckBox("Firework Gun", fireworkgun)) then
                            toggleFireWorkGun()
                        end
                        if (WarMenu.CheckBox("RapidFire", rapidFire)) then
                            toggleRapidFire()
                        end
                        if (WarMenu.CheckBox("Portal Gun", tpGun)) then
                            toggleTeleportGun()
                        end
                        if (WarMenu.CheckBox("Alien Gun", AlienGun)) then
                            toggleAlienGun()
                        end
                        WarMenu.CreateCategory("~g~Aim Support~s~")
                        if (WarMenu.CheckBox("Aimbot", Aimbot)) then
                            toggleAimbot()
                        end
                        local _, currentIndex = WarMenu.ComboBox('Aimbot Bone Target',AimbotBoneOps, currAimbotBoneIndex)
                        if currAimbotBoneIndex ~= currentIndex then
                            currAimbotBoneIndex = currentIndex
                            AimbotBone = NameToBone(AimbotBoneOps[currAimbotBoneIndex])
                        end
                        if (WarMenu.CheckBox("Triggerbot", Triggerbot)) then
                            toggleTriggerbot()
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("giveWeapons") then
                        WarMenu.MenuButton('Melee Weapons', 'meleeWeapons')
                        WarMenu.MenuButton('Thrown Weapons', 'thrownWeapons')
                        WarMenu.MenuButton('Pistol Weapons', 'pistolWeapons')
                        WarMenu.MenuButton('SMG Weapons', 'smgWeapons')
                        WarMenu.MenuButton('Assault Weapons', 'assaultWeapons')
                        WarMenu.MenuButton('Shotgun Weapons', 'shotgunWeapons')
                        WarMenu.MenuButton('Sniper Weapons', 'sniperWeapons')
                        WarMenu.MenuButton('Heavy Weapons', 'heavyWeapons')
                        WarMenu.End()
                        --
                        --
                        --
                        -- Weapon Cate
                        --
                        --
                        --
                    elseif WarMenu.Begin("meleeWeapons") then
                        for i=1, #meleeweapons, 1 do
                            local pressed = WarMenu.Button(meleeweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), meleeweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("thrownWeapons") then
                        for i=1, #thrownweapons, 1 do
                            local pressed = WarMenu.Button(thrownweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), thrownweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("pistolWeapons") then
                        for i=1, #pistolweapons, 1 do
                            local pressed = WarMenu.Button(pistolweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), pistolweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("smgWeapons") then
                        for i=1, #smgweapons, 1 do
                            local pressed = WarMenu.Button(smgweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), smgweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("assaultWeapons") then
                        for i=1, #assaultweapons, 1 do
                            local pressed = WarMenu.Button(assaultweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), assaultweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("shotgunWeapons") then
                        for i=1, #shotgunweapons, 1 do
                            local pressed = WarMenu.Button(shotgunweapons[i][2], "~g~Native~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), shotgunweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("sniperWeapons") then
                        for i=1, #sniperweapons, 1 do
                            local pressed = WarMenu.Button(sniperweapons[i][2], "~g~Native~s~   ~r~Risk~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), sniperweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("heavyWeapons") then
                        for i=1, #heavyweapons, 1 do
                            local pressed = WarMenu.Button(heavyweapons[i][2], "~g~Native~s~   ~r~Risk~s~")
                            if pressed then
                                GiveWeapon(PlayerId(), heavyweapons[i][1])
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("misc") then
                        WarMenu.MenuButton('Freecam', 'freecam')
                        if (WarMenu.CheckBox("Magneto Boy", magnet)) then
                            triggerMagnetoBoy()
                        end
                         if (WarMenu.CheckBox("Invisibility", visible)) then
                            togglevisible()
                        end
                        local pressed = WarMenu.Button("Clean Player blood", "~g~Native~s~")
                        if pressed then
                            ClearPedBloodDamage(PlayerPedId())
					        ClearPedWetness(PlayerPedId())
					        ClearPedEnvDirt(PlayerPedId())
					        ResetPedVisibleDamage(PlayerPedId())
                        end
                        local pressed = WarMenu.Button("End Player Animation", "~g~Native~s~")
                        if pressed then
                          ClearPedTasksImmediately(PlayerPedId())
                        end
                       if WarMenu.Button("Set Model") then
                       local model = GetKeyboardInput("Enter Model Name:")
                       RequestModel(GetHashKey(model))
                       Wait(500)
                       if HasModelLoaded(GetHashKey(model)) then
                       SetPlayerModel(PlayerId(), GetHashKey(model))
                       else ShowNotification("~r~ERROR! Model not found") end
                       elseif WarMenu.Button("Randomize Clothing") then
                       RandomClothe(PlayerId())
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("freecam") then
                        if (WarMenu.CheckBox("Freecam", isFreecam)) then
                            isFreecam = not isFreecam
                            if isFreecam then
                                toggleFreecam()
                                --WarMenu.CloseMenu()
                            else
                                DestroyCam(freecamcam)
                                ClearTimecycleModifier()
                                RenderScriptCams(false, false, 0, 1, 0)
                                FreezeEntityPosition(PlayerPedId(), false)
                                SetFocusEntity(PlayerPedId())
                                Wait(250)
                                DeleteEntity(fakeobj)
                                ClearFocus()
                            end
                        end
                        if (WarMenu.CheckBox("Object Previw", isObjectPreview)) then
                            isObjectPreview = not isObjectPreview
                        end
                        local _, objectIndex = WarMenu.ComboBox('Object', objectnamelist, _objectIndex)
                        if _objectIndex ~= objectIndex then
                            _objectIndex = objectIndex
                        end
                        local _, FreecamSpeedIndex = WarMenu.ComboBox('Speed', FreecamSpeed, _FreecamSpeedIndex)
                        if _FreecamSpeedIndex ~= FreecamSpeedIndex then
                            _FreecamSpeedIndex = FreecamSpeedIndex
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("esp") then
                        if (WarMenu.CheckBox("ESP", isESP)) then
                            toggleESP()
                        end
                        WarMenu.CreateCategory("~g~ESP Settings~s~")
                        local _, ESPAlphaIndex = WarMenu.ComboBox('ESP Player Alpha', ESPAlpha, _ESPAlphaIndex)
                        if _ESPAlphaIndex ~= ESPAlphaIndex then
                            _ESPAlphaIndex = ESPAlphaIndex
                        end
                        if (WarMenu.CheckBox("Show Lines", linesp)) then
                            togglelineesp()
                        end
                        WarMenu.End()
                        elseif WarMenu.Begin("world") then
                        WarMenu.MenuButton('World Vision', 'worldvision')
                        WarMenu.MenuButton('Weather Changer', 'weatherchanger', "~g~Local~s~")
                        if (WarMenu.CheckBox("Let All Cars Fly", FlyingCars)) then
                            toggleflyingcars()
                        end
                        if (WarMenu.CheckBox("Let the World On Fire", WorldFire)) then
                            toggleworldfire()
                        end
                        if (WarMenu.CheckBox("Force Map", forcemap)) then
                            toggleforcemap()
                        end
                        if (WarMenu.CheckBox("Force Crosshair", crosshair)) then
                             togglecrosshair()
                        end
                        WarMenu.End()
                        elseif WarMenu.Begin("weatherchanger") then 
                        if (WarMenu.CheckBox("Weather Changer", WeatherChanger)) then
                            toggleWeather()
		               elseif WarMenu.ComboBox("Weather Type", WeatherList, currWeatherIndex, selWeatherIndex, function(currentIndex, selectedIndex)
                    	 currWeatherIndex = currentIndex
                    	 selWeatherIndex = currentIndex
                    	 WeatherType = WeatherList[currentIndex] end) then
                         end
                        WarMenu.End()
                         elseif WarMenu.Begin("worldvision") then
                         if (WarMenu.CheckBox("Thermal Vision", therm)) then
                            toggleWorldVision()
                        end
                         if (WarMenu.CheckBox("Night Vision", night)) then
                            toggleWorldVision2()
                        end
                        WarMenu.End()
                         elseif WarMenu.Begin("teleport") then
                         WarMenu.MenuButton('Teleport to Locations', 'teleportolocations')
                         if WarMenu.Button("Teleport to Waypoint") then
                         TeleportToWaypoint()
                         end
                        WarMenu.End()
                          elseif WarMenu.Begin("teleportolocations") then
                          if WarMenu.Button("Car Dealership") then
                          SetEntityCoords(PlayerPedId(), -3.812, -1086.427, 26.672)
                          elseif WarMenu.Button("Legion Square") then
                          SetEntityCoords(PlayerPedId(), 212.685, -920.016, 30.692)
                          elseif WarMenu.Button("LSPD") then
                          SetEntityCoords(PlayerPedId(), 436.873, -987.138, 30.69)
                          SetEntityCoords(PlayerPedId(), -424.13, 5996.071, 31.49)
                          elseif WarMenu.Button("FIB Bulding") then
                          SetEntityCoords(PlayerPedId(), 135.835, -749.131, 258.152)
                          elseif WarMenu.Button("FIB Offices") then
                          SetEntityCoords(PlayerPedId(), 136.008, -765.128, 242.152)
                          elseif WarMenu.Button("Michael's House") then
                          SetEntityCoords(PlayerPedId(), -801.847, 175.266, 72.845)
                          elseif WarMenu.Button("Franklin's First House") then
                          SetEntityCoords(PlayerPedId(), -17.813, -1440.008, 31.102)
                          elseif WarMenu.Button("Franklin's Second House") then
                          SetEntityCoords(PlayerPedId(), -6.25, 522.043, 174.628)
                          elseif WarMenu.Button("Trevor's Trailer") then
                          SetEntityCoords(PlayerPedId(), 1972.972, 3816.498, 32.95)
                         end
        
                        WarMenu.End()
                           elseif WarMenu.Begin("worldvision") then
                         if (WarMenu.CheckBox("Thermal Vision", therm)) then
                            toggleWorldVision()
                        end
                         if (WarMenu.CheckBox("Night Vision", night)) then
                            toggleWorldVision2()
                        end
                        WarMenu.End()
                         elseif WarMenu.Begin("lua") then
                        WarMenu.MenuButton("Money", "money")
                        WarMenu.MenuButton("Troll", "troll")
                        WarMenu.End()
                        elseif WarMenu.Begin("money") then
                        if (WarMenu.Button("Admin Money")) then
                            local amount = GetKeyboardInput("Amount")
                            if amount then
                                TriggerServerEvent("KorioZ-PersonalMenu:Admin_giveCash", amount)
                            end
                        end
                        if (WarMenu.Button("Ecobottles Money")) then
                            local amount = GetKeyboardInput("Amount")
                            if amount then
                                TriggerServerEvent("esx-ecobottles:retrieveBottle", amount)
                                TriggerServerEvent("esx-ecobottles:sellBottles")
                            end
                        end
                        if (WarMenu.Button("Vanelico Robbery")) then
                            local amount = GetKeyboardInput("How many Triggers?")
                            if amount then
                                Citizen.CreateThread(function()
                                    for i=0, amount, 1 do
                                        Citizen.Wait(1000)
                                        TriggerServerEvent("esx_vangelico_robbery:gioielli")
                                        Citizen.Wait(10)
                                        TriggerServerEvent("lester:vendita")
                                    end
                                end)
                            end
                        end
                        WarMenu.End()
                    elseif WarMenu.Begin("settings") then
                        showInfobar("Work in progress...")
                        WarMenu.End()
                    else
                        return
                    end
                end
            end)
        end
    end
end)
-- Keybind listener
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isNoClipKeyBind then
            if IsControlPressed(0, ControlKeys[keynamelist[_NoClipControlKeyIndex]]) then
                NoClip = true
            else
                NoClip = false
            end
        end
    end
end)
-- Menu Functions
local GetStuff = function(type)
    local data = {}
    local funcs = types[type]
    local handle, ent, success = funcs[1]()
    repeat
        success, entity = funcs[2](handle)
        if DoesEntityExist(entity) then
            table.insert(data, entity)
        end
    until not success
    funcs[3](handle)
    return data
end
local function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end
local RGB = function(speed, ismenu)
    local res = {}
    for k, v in pairs({0, 2, 4}) do
        local Time = GetGameTimer() / 200
        table.insert(res, math.floor(math.sin(Time * (speed or 0.2) + v) * 127 + 128))
    end
    table.insert(res, 255)
    if rgbenabled or not ismenu then
        return res
    else
        return menucolours
    end
end
local DrawEntityBox = function(entity, colour)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = 0.001
    local box = {
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, max.z + pad),
    }
    local lines = {
        {box[1],box[2]},
        {box[2],box[3]},
        {box[3],box[4]},
        {box[4],box[1]},
        {box[5],box[6]},
        {box[6],box[7]},
        {box[7],box[8]},
        {box[8],box[5]},
        {box[1],box[5]},
        {box[2],box[6]},
        {box[3],box[7]},
        {box[4],box[8]}
    }
    for k, v in pairs(lines) do
        DrawLine(v[1]['x'], v[1]['y'], v[1]['z'], v[2]['x'], v[2]['y'], v[2]['z'], table.unpack(colour))
    end
end
local LoadModel = function(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    else
        if type(model) ~= 'number' then
            return false
        end
    end
    local timer = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(0)
        RequestModel(model)
        if GetGameTimer() >= timer then
            return false
        end
    end
    return model
end
function toggleFreecam()
    FreezeEntityPosition(PlayerPedId(), true)
    local fakeobj = 0
    CreateThread(function()
        local cam = CreateCam('DEFAULT_SCRIPTED_Camera', 1)
        freecamcam = cam
        RenderScriptCams(1, 0, 0, 1, 1)
        SetCamActive(cam, true)
        SetCamCoord(cam, GetEntityCoords(PlayerPedId()))
        local offsetRotX = 0.0
        local offsetRotY = 0.0
        local offsetRotZ = 0.0
        local weapondelay = 0
        WarMenu.CloseMenu()
        while DoesCamExist(freecamcam) do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerRot = GetEntityRotation(playerPed, 2)
            local vehicletimer, closest, closestobj, closestPed = 0
            local rotX = playerRot.x
            local rotY = playerRot.y
            local rotZ = playerRot.z
            offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * 8.0)
            offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * 8.0)
            if (offsetRotX > 90.0) then
                offsetRotX = 90.0
            elseif (offsetRotX < -90.0) then
                offsetRotX = -90.0
            end
            if (offsetRotY > 90.0) then
                offsetRotY = 90.0
            elseif (offsetRotY < -90.0) then
                offsetRotY = -90.0
            end
            if (offsetRotZ > 360.0) then
                offsetRotZ = offsetRotZ - 360.0
            elseif (offsetRotZ < -360.0) then
                offsetRotZ = offsetRotZ + 360.0
            end
            -- SetCamCoord(cam, GetCamCoord(cam) + vector3(0.0, 2.0, 0.0))
            local x, y, z = table.unpack(GetCamCoord(cam))
            if IsDisabledControlPressed(1, 32) then -- W
                SetCamCoord(cam, GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * (0.5 * FreecamSpeed[_FreecamSpeedIndex])))
            elseif IsDisabledControlPressed(1, 33) then
                SetCamCoord(cam, GetCamCoord(cam) - (RotationToDirection(GetCamRot(cam, 2)) * (0.5 * FreecamSpeed[_FreecamSpeedIndex])))
            end
            if (IsDisabledControlPressed(1, 21)) then -- SHIFT
                z = z + (0.5 * FreecamSpeed[_FreecamSpeedIndex])
            end
            if (IsDisabledControlPressed(1, 36)) then -- LEFT CTRL
                z = z - (0.5 * FreecamSpeed[_FreecamSpeedIndex])
            end
            SetFocusArea(GetCamCoord(cam).x, GetCamCoord(cam).y, GetCamCoord(cam).z, 0.0, 0.0, 0.0)
            SetCamRot(cam, offsetRotX, offsetRotY, offsetRotZ, 2)
            local Markerloc = GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15)
            local rgb = RGB(0.5)
            DrawMarker(6, Markerloc, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, rgb[1], rgb[2], rgb[3], 175, false, true, 2, nil, nil, false)
            -- \n~INPUT_COVER~ Take control of vehicle
            AddTextEntry(GetCurrentResourceName(), '~INPUT_MAP_POI~ ~g~Tase\n~INPUT_CONTEXT~ ~g~Shoot rocket\n~INPUT_ATTACK~ ~g~Place object\n~INPUT_AIM~ ~g~Delete object\n~INPUT_MOVE_UP_ONLY~ ~g~Forward\n~INPUT_MOVE_DOWN_ONLY~ ~g~Backwards')
            DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
            if IsDisabledControlJustReleased(0, 24) then
                CreateThread(function()
                    local model = LoadModel(objectlist[objectnamelist[_objectIndex]])
                    local obj = CreateObject(model, GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15), true, true, true)
                    SetEntityHeading(obj, GetCamRot(cam).z)
                end)
            end
            if vehicletimer <= GetGameTimer() then
                closest = nil
                for k, v in pairs(GetStuff('Vehicle')) do
                    if #(GetEntityCoords(v) - Markerloc) <= 4.5 then
                        if closest then
                            if #(GetEntityCoords(v) - Markerloc) <= #(GetEntityCoords(v) - GetEntityCoords(closest)) then
                                closest = v
                            end
                        else
                            closest = v
                        end
                    end
                end
                for k, v in pairs(GetStuff('Object')) do
                    if GetEntityAlpha(v) == 255 then
                        if #(GetEntityCoords(v) - Markerloc) <= 4.5 then
                            if closestobj then
                                if #(GetEntityCoords(v) - Markerloc) <= #(GetEntityCoords(v) - GetEntityCoords(closestobj)) then
                                    closestobj = v
                                end
                            else
                                closestobj = v
                            end
                        end
                    end
                end
                for k, v in pairs(GetStuff('Ped')) do
                    if GetEntityAlpha(v) == 255 then
                        if #(GetEntityCoords(v) - Markerloc) <= 4.5 then
                            if closestPed then
                                if #(GetEntityCoords(v) - Markerloc) <= #(GetEntityCoords(v) - GetEntityCoords(closestobj)) then
                                    closestPed = v
                                end
                            else
                                closestPed = v
                            end
                        end
                    end
                end
                vehicletimer = GetGameTimer() + 250
            end
            if closest then
                DrawEntityBox(closest, RGB(0.5))
            end
            if closestobj then
                DrawEntityBox(closestobj, RGB(0.5))
            end
            if closestPed then
                DrawEntityBox(closestPed, RGB(0.5))
            end
            if IsDisabledControlJustReleased(0, 44) then
                Citizen.CreateThread(function()
                    objCopy = ESX.Game.GetClosestObject(GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15))
                    obj = CreateObject(GetHashKey(objCopy), GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15), true, true, true)
                    print(GetHashKey(objCopy))
                end)
            end
            if DoesEntityExist(fakeobj) then
                if isObjectPreview then
                    if GetEntityModel(fakeobj) == LoadModel(objectlist[objectnamelist[_objectIndex]]) then
                        SetEntityCoords(fakeobj, GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15))
                        SetEntityHeading(fakeobj, GetCamRot(cam).z)
                        SetEntityAlpha(fakeobj, 204)
                        SetEntityCollision(fakeobj, false, false)
                    else
                        DeleteEntity(fakeobj)
                        fakeobj = CreateObject(model, GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15), false, true, true)
                    end
                else
                    DeleteEntity(fakeobj)
                end
            else
                if isObjectPreview then
                    local model = LoadModel(objectlist[objectnamelist[_objectIndex]])
                    if model then
                        fakeobj = CreateObject(model, GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 15), false, true, true)
                    end
                end
            end
            if IsControlJustReleased(0, 25) then
                if DoesEntityExist(closestobj) then
                    CreateThread(function()
                        while DoesEntityExist(closestobj) do
                            while not NetworkHasControlOfEntity(closestobj) do
                                NetworkRequestControlOfEntity(closestobj)
                                Wait(0)
                            end
                            SetEntityAsMissionEntity(closestobj, true, true)
                            DeleteEntity(closestobj)
                            Wait(100)
                        end
                    end)
                else
                    if DoesEntityExist(closest) then
                        CreateThread(function()
                            local driver = GetPedInVehicleSeat(closest, -1)
                            if DoesEntityExist(driver) then
                                ClearPedTasksImmediately(driver)
                            end
                            while DoesEntityExist(closest) do
                                while not NetworkHasControlOfEntity(closest) do
                                    NetworkRequestControlOfEntity(closest)
                                    Wait(0)
                                end
                                SetEntityAsMissionEntity(closest, true, true)
                                DeleteEntity(closest)
                                Wait(100)
                            end
                        end)
                    end
                end
            end
            Markerloc = GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 4)
            if IsControlPressed(0, 348) and weapondelay <= GetGameTimer() then
                RequestWeaponAsset(GetHashKey("WEAPON_STUNGUN"))
                while not HasWeaponAssetLoaded(GetHashKey("WEAPON_STUNGUN")) do
                    Wait(0)
                end
                ShootSingleBulletBetweenCoords(GetCamCoord(cam) + RotationToDirection(GetCamRot(cam, 2)), Markerloc, 0, false, GetHashKey("WEAPON_STUNGUN"), 0, true, false, -1.0)
                weapondelay = GetGameTimer() + 50
            end
            if IsControlPressed(0, 51) and weapondelay <= GetGameTimer() then
                RequestWeaponAsset(GetHashKey("WEAPON_RPG"))
                while not HasWeaponAssetLoaded(GetHashKey("WEAPON_RPG")) do
                    Wait(0)
                end
                ShootSingleBulletBetweenCoords(GetCamCoord(cam) + RotationToDirection(GetCamRot(cam, 2)), Markerloc, 0, false, GetHashKey("WEAPON_RPG"), 0, true, false, -1.0)
                weapondelay = GetGameTimer() + 50
                
            end
        end
    end)
end
function triggerMagnetoBoy()
    magnet = not magnet
    if magnet then
        WarMenu.CloseMenu()
        Citizen.CreateThread(function()
            local ForceKey = 38
            local Force = 0.5
            local KeyPressed = false
            local KeyTimer = 0
            local KeyDelay = 15
            local ForceEnabled = false
            local StartPush = false
            function forcetick()
                if (KeyPressed) then
                    KeyTimer = KeyTimer + 1
                    if(KeyTimer >= KeyDelay) then
                        KeyTimer = 0
                        KeyPressed = false
                    end
                end
                if IsControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
                    KeyPressed = true
                    ForceEnabled = true
                end
                if (StartPush) then
                    StartPush = false
                    local pid = PlayerPedId()
                    local CamRot = GetGameplayCamRot(2)
                    local force = 5
                    local Fx = -( math.sin(math.rad(CamRot.z)) * force*10 )
                    local Fy = ( math.cos(math.rad(CamRot.z)) * force*10 )
                    local Fz = force * (CamRot.x*0.2)
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, false)
                        if IsEntityOnScreen(k) and k ~= PlayerVeh then
                            ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
                        end
                    end
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= pid then
                            ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
                        end
                    end
                end
                if IsControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
                    KeyPressed = true
                    StartPush = true
                    ForceEnabled = false
                end
                if (ForceEnabled) then
                    local pid = PlayerPedId()
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                    local rgb = RGB(0.5)
                    DrawMarker(6, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 180, rgb[1], rgb[2], rgb[3], false, true, 2, nil, nil, false)
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
                            RequestControlOnce(k)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                            RequestControlOnce(k)
                            SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                end
            end
            while magnet do forcetick() Wait(0) end
        end)
        Citizen.CreateThread(function()
            while magnet do
                Citizen.Wait(0)
                AddTextEntry(GetCurrentResourceName(), '~INPUT_CONTEXT~ ~g~To active/disable Magnetoboy')
                DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
            end
        end)
    end
end
function toggleStamina()
    InfStamina = not InfStamina
    Citizen.CreateThread(function()
        while InfStamina do
            Citizen.Wait(1000)
            RestorePlayerStamina(PlayerId(), GetPlayerSprintStaminaRemaining(PlayerId()))
        end
    end)
end
function ToggleFastRun()
    FastRun = not FastRun
    Citizen.CreateThread(function()
        while FastRun do
            Citizen.Wait(0)
            SetRunSprintMultiplierForPlayer(PlayerId(), 2.49)
		    SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
        end
    end)
end
function ToggleCarGodmode()
    CarGodmode = not CarGodmode
    Citizen.CreateThread(function()
        while CarGodmode do
           Citizen.Wait(0)
           SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
        end
    end)
end
function ToggleRainbowColor()
    VehicleRainbow = not VehicleRainbow
    Citizen.CreateThread(function()
        while VehicleRainbow do
        	local ra = RGBRainbow(1.0)
            Citizen.Wait(0)
			SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
			SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
        end
    end)
end
function toggleAimbot()
    Aimbot = not Aimbot
    Citizen.CreateThread(function()
        while Aimbot do
            Citizen.Wait(0)
            if DrawFov then
                DrawRect(0.25, 0.5, 0.01, 0.515, 255, 80, 80, 100)
                DrawRect(0.75, 0.5, 0.01, 0.515, 255, 80, 80, 100)
                DrawRect(0.5, 0.25, 0.49, 0.015, 255, 80, 80, 100)
                DrawRect(0.5, 0.75, 0.49, 0.015, 255, 80, 80, 100)
            end
            local plist = GetAllPlayers()
            for i = 1, #plist do
                ShootAimbot(GetPlayerPed(plist[i]))
            end
        end
    end)
end
function toggleSpectate(id)
    Spectating = not Spectating
    SpectatePlayer(id)
end
function toggleTriggerbot()
    local hasTarget, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if hasTarget and IsEntityAPed(target) then
        ShootAt(target, "SKEL_HEAD")
        ShootAt(target, "SKEL_Spine2")
    end
end
function toggleAutoRevive()
    AutoRevive = not AutoRevive
    Citizen.CreateThread(function()
        while AutoRevive do
            Citizen.Wait(1500)
            if IsPedDeadOrDying(GetPlayerPed(PlayerId())) then
                TriggerEvent('esx_ambulancejob:revive')
            end
        end
    end)
end
function toggleExplosivAmmo()
    ExplosivAmmo = not ExplosivAmmo
    Citizen.CreateThread(function()
        while ExplosivAmmo do
            Citizen.Wait(0)
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
        end
    end)
end
function toggleTeleportGun()
    tpGun = not tpGun
    Citizen.CreateThread(function()
        while tpGun do
            Citizen.Wait(0)
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                SetEntityCoords(GetPlayerPed(PlayerId()), pos.x, pos.y, pos.z)
            end
        end
    end)
end
function toggleFireWorkGun()
    fireworkgun = not fireworkgun
    Citizen.CreateThread(function()
        while fireworkgun do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 257) then
                coords = GetEntityCoords(GetPlayerPed(PlayerId()))
                RequestWeaponAsset(GetHashKey("WEAPON_FIREWORK"))
                while not HasWeaponAssetLoaded(GetHashKey("WEAPON_FIREWORK")) do
                    Wait(0)
                end
                local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
                local camDir = GetCamDirFromScreenCenter()
                local camPos = GetGameplayCamCoord()
                local launchPos = GetEntityCoords(wepent)
                local targetPos = camPos + (camDir * 200.0)
                ClearAreaOfProjectiles(launchPos, 0.0, 1)
                ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, GetHashKey("WEAPON_FIREWORK"), PlayerPedId(), true, true, -1.0)
            end
        end
    end)
end
function toggleAlienGun()
    AlienGun = not AlienGun
    Citizen.CreateThread(function()
        while AlienGun do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 257) then
                coords = GetEntityCoords(GetPlayerPed(PlayerId()))
                RequestWeaponAsset(GetHashKey("WEAPON_raypistol"))
                while not HasWeaponAssetLoaded(GetHashKey("WEAPON_raypistol")) do
                    Wait(0)
                end
                local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
                local camDir = GetCamDirFromScreenCenter()
                local camPos = GetGameplayCamCoord()
                local launchPos = GetEntityCoords(wepent)
                local targetPos = camPos + (camDir * 200.0)
                ClearAreaOfProjectiles(launchPos, 0.0, 1)
                ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, GetHashKey("WEAPON_raypistol"), PlayerPedId(), true, true, -1.0)
            end
        end
    end)
end
function toggleInfAmmo()
    InfAmmo = not InfAmmo
    SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
end
function toggleRapidFire()
    rapidFire = not rapidFire
    Citizen.CreateThread(function()
        while rapidFire do
            Citizen.Wait(50)
            DoRapidFireTick()
        end
    end)
end
function togglevisible()
    visible = not visible
    Citizen.CreateThread(function()
        while visible do
          Citizen.Wait(0)
          SetEntityVisible(PlayerPedId(), not visible)
        end
    end)
end
function togglenorecoil()
    norecoil = not recoil
    Citizen.CreateThread(function()
        while recoil do
            Citizen.Wait(0)
            local cI = {
                    [453432689] = 1.0,
                    [3219281620] = 1.0,
                    [1593441988] = 1.0,
                    [584646201] = 1.0,
                    [2578377531] = 1.0,
                    [324215364] = 1.0,
                    [736523883] = 1.0,
                    [2024373456] = 1.0,
                    [4024951519] = 1.0,
                    [3220176749] = 1.0,
                    [961495388] = 1.0,
                    [2210333304] = 1.0,
                    [4208062921] = 1.0,
                    [2937143193] = 1.0,
                    [2634544996] = 1.0,
                    [2144741730] = 1.0,
                    [3686625920] = 1.0,
                    [487013001] = 1.0,
                    [1432025498] = 1.0,
                    [2017895192] = 1.0,
                    [3800352039] = 1.0,
                    [2640438543] = 1.0,
                    [911657153] = 1.0,
                    [100416529] = 1.0,
                    [205991906] = 1.0,
                    [177293209] = 1.0,
                    [856002082] = 1.0,
                    [2726580491] = 1.0,
                    [1305664598] = 1.0,
                    [2982836145] = 1.0,
                    [1752584910] = 1.0,
                    [1119849093] = 1.0,
                    [3218215474] = 1.0,
                    [1627465347] = 1.0,
                    [3231910285] = 1.0,
                    [-1768145561] = 1.0,
                    [3523564046] = 1.0,
                    [2132975508] = 1.0,
                    [-2066285827] = 1.0,
                    [137902532] = 1.0,
                    [2828843422] = 1.0,
                    [984333226] = 1.0,
                    [3342088282] = 1.0,
                    [1785463520] = 1.0,
                    [1672152130] = 0,
                    [1198879012] = 1.0,
                    [171789620] = 1.0,
                    [3696079510] = 1.0,
                    [1834241177] = 1.0,
                    [3675956304] = 1.0,
                    [3249783761] = 1.0,
                    [-879347409] = 1.0,
                    [4019527611] = 1.0,
                    [1649403952] = 1.0,
                    [317205821] = 1.0,
                    [125959754] = 1.0,
                    [3173288789] = 1.0
                }
        end
    end)
end
function toggleSuperJump()
    SuperJump = not SuperJump
    Citizen.CreateThread(function()
        while SuperJump do
            Citizen.Wait(0)
            SetSuperJumpThisFrame(PlayerId())
        end
    end)
end
function toggleWorldVision()
   therm = not therm
    Citizen.CreateThread(function()
        while therm do
            Citizen.Wait(0)
          SetSeethrough(therm)
        end
    end)
end
function toggleWorldVision2()
   night = not night
    Citizen.CreateThread(function()
        while night do
            Citizen.Wait(0)
          SetNightvision(night)
        end
    end)
end
function togglesemigodmode()
   semigodmode = not semigode
    Citizen.CreateThread(function()
        while semigodmode do
            Citizen.Wait(0)
           if GetEntityHealth(PlayerPedId()) < 200 then
                SetEntityHealth(PlayerPedId(), 200)
        end
    end
    end)
end
function toggleflyingcars()
   FlyingCars = not FlyingCars
    Citizen.CreateThread(function()
        while FlyingCars do
            Citizen.Wait(100)
              for donasty1 in EnumerateVehicles() do
                RequestControlOnce(donasty1)
                ApplyForceToEntity(donasty1, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            end
        end
    end)
end
function togglelineesp()
   linesp = not linesp
    Citizen.CreateThread(function()
        while linesp do
            Citizen.Wait(0)
             local plist = GetActivePlayers()
             local playerCoords = GetEntityCoords(PlayerPedId())
             for i = 1, #plist do
             if i == PlayerId() then i = i + 1 end
                local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                DrawLine(playerCoords, targetCoords, 0, 0, 255, 255)
             end
        end
    end)
end
function toggleforcemap()
   forcemap = not forcemap
    Citizen.CreateThread(function()
        while forcemap do
            Citizen.Wait(0)
        DisplayRadar(true)
        end
    end)
end
function togglecrosshair()
   crosshair = not crosshair
    Citizen.CreateThread(function()
        while crosshair do
            Citizen.Wait(0)
        ShowHudComponentThisFrame(14)
        end
    end)
end
function toggleworldfire()
   WorldFire = not WorldFire
    Citizen.CreateThread(function()
        while WorldFire do
            Citizen.Wait(100)
            local pos = GetEntityCoords(PlayerPedId())
            local donasty2 = GetRandomVehicleInSphere(pos, 100.0, 0, 0)
            if donasty2 ~= GetVehiclePedIsIn(PlayerPedId(), 0) then
                local targetpos = GetEntityCoords(donasty2)
                local x, y, z = table.unpack(targetpos)
                local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                local expposz = math.random(math.floor(z - 0.5), math.ceil(z + 1.5)) % z
                AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
            end
        end
    end)
end
function toggleWeather()
     WeatherChanger = not WeatherChanger
    Citizen.CreateThread(function()
        while WeatherChanger do
            Citizen.Wait(0)
        SetWeatherTypePersist(WeatherType)
	    SetWeatherTypeNowPersist(WeatherType)
	    SetWeatherTypeNow(WeatherType)
	    SetOverrideWeather(WeatherType)
        end
    end)
end
function toggleEasyHandling()
    if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
        EasyHandling = not EasyHandling
        local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
        if not EasyHandling then
            SetVehicleGravityAmount(veh, 9.8)
        else
            SetVehicleGravityAmount(veh, 30.0)
        end
    else
        ShowNotification("~r~You're in no vehicle~s~")
    end
end
function toggleVehicleSpeedboost()
    Speedboost = not Speedboost
    Citizen.CreateThread(function()
        while Speedboost do
            Citizen.Wait(100)
            if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
          
            if IsControlPressed(0, 38) then
			SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 100.0)
			elseif IsControlPressed(0, 38) then
			SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
            end
        end
        end
    end)
end
function toggleVehicleAutoFix()
    VehicleAutoFix = not VehicleAutoFix
    Citizen.CreateThread(function()
        while VehicleAutoFix do
            Citizen.Wait(100)
            if IsPedInAnyVehicle(GetPlayerPed(PlayerId())) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                FixVeh(veh)
            end
        end
    end)
end
function RefillVehicle()
SetVehicleFuelLevel(
	GetVehiclePedIsIn(PlayerPedId(), 0), 
    9999999999999999
)
end
function toggleNames()
    isNames = not isNames
    Citizen.CreateThread(function()
        while isNames do
            Citizen.Wait(0)
            local activePlayers = GetActivePlayers()
            for i=1, #activePlayers, 1 do
                local ped = GetPlayerPed(activePlayers[i])
                if PlayerId() ~= activePlayers[i] then
                    DrawText3D('[' .. GetPlayerServerId(activePlayers[i]) .. '] '.. GetPlayerName(activePlayers[i]), GetPedBoneCoords(ped, bones['head'], 0, 0, 0) + vector3(0.0, 0.0, 0.4), 0.2)
                end
            end
        end
    end)
end
function toggleESP()
    isESP = not isESP
    Citizen.CreateThread(function()
        while isESP do
            Citizen.Wait(0)
            local activePlayers = GetAllPlayers()
            for i=1, #activePlayers, 1 do
                -- Just in work....
                if isESP then
                    SetEntityAlpha(GetPlayerPed(activePlayers[i]), ESPAlpha[_ESPAlphaIndex])
                else
                    ResetEntityAlpha(GetPlayerPed(activePlayers[i]))
                end
            end
        end
    end)
end
function toggleGodmode()
    isGodmode = not isGodmode
    if isGodmode then
        local ped = PlayerPedId()
        SetEntityProofs(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode)
        SetEntityInvincible(ped, isGodmode)
    else
        local ped = PlayerPedId()
        SetEntityProofs(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode)
        SetEntityInvincible(ped, isGodmode)
    end
end
function toggleNoClip()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if NoClip then
                local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
                local k = nil
                local x, y, z = nil
                if not isInVehicle then
                    k = PlayerPedId()
                    x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
                else
                    k = GetVehiclePedIsIn(PlayerPedId(), 0)
                    x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
                end
                if isInVehicle and GetSeatPedIsIn(PlayerPedId()) ~= -1 then RequestControlOnce(k) end
                local dx, dy, dz = GetCamDirection()
                SetEntityVisible(PlayerPedId(), NoClipVisible, NoClipVisible)
                SetEntityVisible(k, NoClipVisible, NoClipVisible)
                SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)
                if IsDisabledControlPressed(0, 32) then -- MOVE FORWARD
                    x = x + NoClipSpeed[_NoClipIndex] * dx
                    y = y + NoClipSpeed[_NoClipIndex] * dy
                    z = z + NoClipSpeed[_NoClipIndex] * dz
                end
                if IsDisabledControlPressed(0, 269) then -- MOVE BACK
                    x = x - NoClipSpeed[_NoClipIndex] * dx
                    y = y - NoClipSpeed[_NoClipIndex] * dy
                    z = z - NoClipSpeed[_NoClipIndex] * dz
                end
                if IsDisabledControlPressed(0, 21) then -- MOVE UP
                    z = z + NoClipSpeed[_NoClipIndex]
                end
                if IsDisabledControlPressed(0, 36) then -- MOVE DOWN
                    z = z - NoClipSpeed[_NoClipIndex]
                end
                SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
            else
                local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
                local k = nil
                local x, y, z = nil
                if not isInVehicle then
                    k = PlayerPedId()
                    x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
                else
                    k = GetVehiclePedIsIn(PlayerPedId(), 0)
                    x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
                end
                if isInVehicle and GetSeatPedIsIn(PlayerPedId()) ~= -1 then RequestControlOnce(k) end
                SetEntityVisible(PlayerPedId(), true, true)
                SetEntityVisible(k, true, true)
            end
        end
    end)
end
function toggleNoRagdoll()
    NoRagdoll = not NoRagdoll
    SetPedCanRagdoll(GetPlayerPed(PlayerId()), noRagdoll)
end
function toggleBlips()
    BlipsEnabled = not BlipsEnabled
    if not BlipsEnabled then
        for i = 1, #pblips do
            RemoveBlip(pblips[i])
        end
    else
        Citizen.CreateThread(function()
            pblips = {}
            while BlipsEnabled do
                local plist = GetAllPlayers()
                table.removekey(plist, PlayerId())
                for i = 1, #plist do
                    if NetworkIsPlayerActive(plist[i]) then
                        ped = GetPlayerPed(plist[i])
                        pblips[i] = GetBlipFromEntity(ped)
                        if not DoesBlipExist(pblips[i]) then
                            pblips[i] = AddBlipForEntity(ped)
                            SetBlipSprite(pblips[i], 1)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                        else
                            veh = GetVehiclePedIsIn(ped, false)
                            blipSprite = GetBlipSprite(pblips[i])
                            if not GetEntityHealth(ped) then -- dead
                                if blipSprite ~= 274 then
                                    SetBlipSprite(pblips[i], 274)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                end
                            elseif veh then
                                vehClass = GetVehicleClass(veh)
                                vehModel = GetEntityModel(veh)
                                if vehClass == 15 then -- jet
                                    if blipSprite ~= 422 then
                                        SetBlipSprite(pblips[i], 422)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 16 then
                                    if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra")
                                            or vehModel == GetHashKey("lazer") then -- jet
                                        if blipSprite ~= 424 then
                                            SetBlipSprite(pblips[i], 424)
                                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                        end
                                    elseif blipSprite ~= 423 then
                                        SetBlipSprite(pblips[i], 423)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 14 then -- boat
                                    if blipSprite ~= 427 then
                                        SetBlipSprite(pblips[i], 427)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2")
                                        or vehModel == GetHashKey("limo2") then
                                    if blipSprite ~= 426 then
                                        SetBlipSprite(pblips[i], 426)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("rhino") then -- tank
                                    if blipSprite ~= 421 then
                                        SetBlipSprite(pblips[i], 421)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif blipSprite ~= 1 then -- default pblips[i]
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                                passengers = GetVehicleNumberOfPassengers(veh)
                                if passengers then
                                    if not IsVehicleSeatFree(veh, -1) then
                                        passengers = passengers + 1
                                    end
                                    ShowNumberOnBlip(pblips[i], passengers)
                                else
                                    HideNumberOnBlip(pblips[i])
                                end
                            else
                                HideNumberOnBlip(pblips[i])
                                if blipSprite ~= 1 then
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                            end
                            SetBlipRotation(pblips[i], math.ceil(GetEntityHeading(veh)))
                            SetBlipNameToPlayerName(pblips[i], plist[i])
                            SetBlipScale(pblips[i], 0.85)
                            if IsPauseMenuActive() then
                                SetBlipAlpha(pblips[i], 255)
                            else
                                x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                                x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(plist[i]), true))
                                distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                                if distance < 0 then
                                    distance = 0
                                elseif distance > 255 then
                                    distance = 255
                                end
                                SetBlipAlpha(pblips[i], distance)
                            end
                        end
                    end
                end
                Wait(0)
            end
        end)
    end
end
function toggleTracking(TrackedPlayerId)
    Tracking = not Tracking
    Citizen.CreateThread(function()
        while Tracking do
            Citizen.Wait(1000)
            local coords = GetEntityCoords(GetPlayerPed(TrackedPlayerId))
            SetNewWaypoint(coords.x, coords.y)
        end
    end)
    if not Tracking then
        DeleteWaypoint()
    end
end
-- Init Threads
toggleNoClip()
