--
-- A FRSKY SPort/FPort/FPort2 and TBS CRSF telemetry widget for the Horus class radios
-- based on ArduPilot's passthrough telemetry protocol
--
-- Author: Alessandro Apostoli, https://github.com/yaapu
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY, without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see <http://www.gnu.org/licenses>.
--
local unitScale = getGeneralSettings().imperial == 0 and 1 or 3.28084
local unitLabel = getGeneralSettings().imperial == 0 and "m" or "ft"
local unitLongScale = getGeneralSettings().imperial == 0 and 1/1000 or 1/1609.34
local unitLongLabel = getGeneralSettings().imperial == 0 and "km" or "mi"

-- offsets are: 1 celm, 4 batt, 7 curr, 10 mah, 13 cap, indexing starts at 1
--[[
BATT_CELL 1
BATT_VOLT 4
BATT_CURR 7
BATT_MAH 10
BATT_CAP 13

BATT_IDALL 0
BATT_ID1 1
BATT_ID2 2
--]]
local function drawPane(x,drawLib,conf,telemetry,status,alarms,battery,battId,utils)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- local perc = battery[16+battId]
  --  battery min cell
  local flags = 0
  --
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  if status.showMinMaxValues == false then
    if status.battLevel2 == false and alarms[8][2] > 0 then
      utils.drawBlinkBitmap("cell_red_blink_86x30",x+7,20)
      utils.lcdBacklightOn()
    elseif status.battLevel2 == true then
      lcd.drawBitmap(utils.getBitmap("cell_red_86x30"),x+7,20)
    elseif status.battLevel1 == false and alarms[7][2] > 0 then
      --lcd.setColor(CUSTOM_COLOR,0x0000) -- black
      utils.drawBlinkBitmap("cell_orange_blink_86x30",x+7,20)
      utils.lcdBacklightOn()
    elseif status.battLevel1 == true then
      lcd.drawBitmap(utils.getBitmap("cell_orange_86x30"),x+7,20)
      lcd.setColor(CUSTOM_COLOR,0x0000) -- black
    end
  end
  flags = CUSTOM_COLOR
  --PREC2 forces a math.floor() whereas a math.round() is required, math.round(f) = math.floor(f+0.5)
  -- if battery[1+battId] * 0.01 < 10 then
  --   lcd.drawNumber(x+75+2, 16, battery[1+battId] + 0.5, PREC2+DBLSIZE+RIGHT+flags)
  -- else
  --   lcd.drawNumber(x+75+2, 16, (battery[1+battId] + 0.5)*0.1, PREC1+DBLSIZE+RIGHT+flags)
  -- end

  -- local lx = x+77
  -- lcd.drawText(lx, 35, "V", flags+SMLSIZE)
  -- lcd.drawText(lx, 18, status.battsource, flags)

  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  -- battery voltage
  lcd.drawNumber(x+75+2, 16, battery[4] + 0.5, PREC1+DBLSIZE+RIGHT+flags)
  lcd.drawText(x+77, 16, "V", flags+DBLSIZE)
  -- battery voltage
  -- drawLib.drawNumberWithDim(x+77,47,x+77, 58, battery[4+battId],"V",RIGHT+MIDSIZE+PREC1+CUSTOM_COLOR,SMLSIZE+CUSTOM_COLOR)
  -- battery current
  -- local lowAmp = battery[7+battId] < 10
  -- display capacity bar %
  -- local color = lcd.RGB(255,0, 0)
  -- if perc > 50 then
  --   color = lcd.RGB(0, 255, 0) -- red
  -- elseif perc <= 50 and perc > 25 then
  --   color = lcd.RGB(255, 204, 0) -- yellow
  -- end
  -- drawLib.drawMinMaxBar(x+7,75,86,21,color,perc,0,100,MIDSIZE)
  -- -- battery mah
  -- lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- local strmah = string.format("%.02f/%.01f",battery[10+battId]/1000,battery[13+battId]/1000)
  -- --lcd.drawText(x+95, 135+2, "Ah", SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- lcd.drawText(x+95, 109, strmah, 0+RIGHT+CUSTOM_COLOR)

  

  if conf.battConf == 1 then --Parellel Mode
    drawLib.drawNumberWithDim(x+75,47,x+77,58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(x+95, 75, "Generator", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white

    drawLib.drawNumberWithDim(x+75, 95,x+77,58,battery[8],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[20] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(x+95, 125, "Battery", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  elseif conf.battConf == 2 then --Parellel Combined Mode
    drawLib.drawNumberWithDim(x+75,47,x+77,58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(x+95, 75, "Total", SMLSIZE+RIGHT+CUSTOM_COLOR)  
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  else --Single source mode
    drawLib.drawNumberWithDim(x+75,47,x+77,58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(x+95, 75, "Battery", SMLSIZE+RIGHT+CUSTOM_COLOR)  
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white 
  end

  if battId < 2 and x == 380 then
    -- Active AC SID
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
    -- battery voltage
    -- lcd.drawNumber(x+95, 95, telemetry.sid , DBLSIZE+RIGHT)
    -- lcd.setColor(CUSTOM_COLOR,0x0000)
    -- lcd.drawText(x+95, 125, "AC SID", SMLSIZE+RIGHT+CUSTOM_COLOR)

    -- labels
    lcd.drawText(x+15, 154, "Eff(mAh)", SMLSIZE+CUSTOM_COLOR+RIGHT)
    lcd.drawText(x+95, 154, "Power(W)", SMLSIZE+CUSTOM_COLOR+RIGHT)
    -- data
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    local speed = utils.getMaxValue(telemetry.hSpeed,14)
    -- efficiency for indipendent batteries makes sense only for battery 1
    local eff = speed > 2 and (conf.battConf == 3 and battery[7+1] or battery[7])*1000/(speed*conf.horSpeedMultiplier) or 0
    eff = ( conf.battConf == 3 and battId == 2) and 0 or eff
    lcd.drawNumber(x+15,165,eff,(eff > 99999 and 0 or MIDSIZE)+RIGHT+CUSTOM_COLOR)
    -- power
    local power = battery[4+battId]*battery[7+battId]*0.01
    lcd.drawNumber(x+95,165,power,MIDSIZE+RIGHT+CUSTOM_COLOR)
    --lcd.drawText(x+95,165,string.format("%dW",power),MIDSIZE+CUSTOM_COLOR)
  elseif battId < 2 then
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    if conf.rangeFinderMax > 0 then
      flags = 0
      local rng = telemetry.range
      rng = utils.getMaxValue(rng,16)
      lcd.setColor(CUSTOM_COLOR,0x0000)
      lcd.drawText(x+75, 154, "Range("..unitLabel..")", SMLSIZE+CUSTOM_COLOR+RIGHT)
      lcd.setColor(CUSTOM_COLOR,0xFFFF)
      lcd.drawText(x+75, 165, string.format("%.1f",rng*0.01*unitScale), MIDSIZE+RIGHT+CUSTOM_COLOR)
    else
      flags = BLINK
      -- always display gps altitude even without 3d lock
      local alt = telemetry.gpsAlt/10
      if telemetry.gpsStatus  > 2 then
        flags = 0
        -- update max only with 3d or better lock
        alt = utils.getMaxValue(alt,12)
      end
      lcd.setColor(CUSTOM_COLOR,0x0000)
      lcd.drawText(x+75, 154, "GPSAlt("..unitLabel..")", SMLSIZE+CUSTOM_COLOR+RIGHT)
      local stralt = string.format("%d",alt*unitScale)
      lcd.setColor(CUSTOM_COLOR,0xFFFF)
      lcd.drawText(x+75, 165, stralt, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
    end
    -- LABELS
    lcd.setColor(CUSTOM_COLOR,0x0000)
    drawLib.drawHomeIcon(90 - 70, 68,utils)
    lcd.drawText(x+135, 154, "Dist("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.drawText(x+215, 154, "Travel("..unitLongLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
    -- VALUES
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    -- home distance
    flags = 0
    if telemetry.homeAngle == -1 then
      flags = BLINK
    end
    local dist = utils.getMaxValue(telemetry.homeDist,15)
    if status.showMinMaxValues == true then
      flags = 0
    end
    local strdist = string.format("%d",dist*unitScale)
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawText(x+135, 165, strdist, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
    -- total distance
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawNumber(x+215, 165, telemetry.totalDist*unitLongScale*100, PREC2+MIDSIZE+RIGHT+CUSTOM_COLOR)

  elseif battId == 2 then
    -- Active AC SID
    -- lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
    -- -- battery voltage
    -- lcd.drawNumber(x+95, 95, telemetry.sid , DBLSIZE+RIGHT)
    -- lcd.setColor(CUSTOM_COLOR,0x0000)
    -- lcd.drawText(x+95, 125, "AC SID", SMLSIZE+RIGHT+CUSTOM_COLOR)

    -- labels
    lcd.drawText(x+15, 154, "Eff(mAh)", SMLSIZE+CUSTOM_COLOR+RIGHT)
    lcd.drawText(x+95, 154, "Power(W)", SMLSIZE+CUSTOM_COLOR+RIGHT)
    -- data
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    local speed = utils.getMaxValue(telemetry.hSpeed,14)
    -- efficiency for indipendent batteries makes sense only for battery 1
    local eff = speed > 2 and (conf.battConf == 3 and battery[7+1] or battery[7])*1000/(speed*conf.horSpeedMultiplier) or 0
    eff = ( conf.battConf == 3 and battId == 1) and 0 or eff
    lcd.drawNumber(x+15,165,eff,(eff > 99999 and 0 or MIDSIZE)+RIGHT+CUSTOM_COLOR)
    -- power
    local power = battery[4+battId]*battery[7+battId]*0.01
    lcd.drawNumber(x+95,165,power,MIDSIZE+RIGHT+CUSTOM_COLOR)
    --lcd.drawText(x+95,165,string.format("%dW",power),MIDSIZE+CUSTOM_COLOR)
  end
  if status.showMinMaxValues == true then
    drawLib.drawVArrow(x+75+11, 16 + 8,false,true,utils)
    -- drawLib.drawVArrow(x+77+11,47 + 3, false,true,utils)
    -- drawLib.drawVArrow(x+77+11,70 + 10,true,false,utils)
    drawLib.drawVArrow(x+75+11,47 + 3,true,false,utils)
  end
end

local function background(myWidget,conf,telemetry,status,utils)
end

return {drawPane=drawPane,background=background}
