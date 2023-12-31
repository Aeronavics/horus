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

local function drawPane(x,drawLib,conf,telemetry,status,alarms,battery,battId,utils)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  if conf.rangeFinderMax > 0 then
    local rng = telemetry.range
    rng = utils.getMaxValue(rng,16)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(73, 21+8, "Rng("..unitLabel..")", SMLSIZE+CUSTOM_COLOR+RIGHT)
    if rng > conf.rangeFinderMax and status.showMinMaxValues == false then
      lcd.setColor(CUSTOM_COLOR,0xF800)
      lcd.drawFilledRectangle(73-65, 33+8+4,65,21,CUSTOM_COLOR)
    end
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawText(73, 33+8, string.format("%.1f",rng*0.01*unitScale), MIDSIZE+RIGHT+CUSTOM_COLOR)
  else
    flags = BLINK
    -- always display gps altitude even without 3d lock
    local alt = telemetry.gpsAlt/10
    if telemetry.gpsStatus  > 2 then
      flags = 0
      -- update max only with 3d or better lock
      alt = utils.getMaxValue(alt,12)
    end
    if status.showMinMaxValues == true then
      flags = 0
    end
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(73, 21+8, "AltAsl("..unitLabel..")", SMLSIZE+CUSTOM_COLOR+RIGHT)
    local stralt = string.format("%d",alt*unitScale)
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawText(73, 33+8, stralt, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
  end
  -- LABELS
  lcd.setColor(CUSTOM_COLOR,0x0000)
  drawLib.drawHomeIcon(155 - 68, 29,utils)
  lcd.drawText(155, 29, "Dist("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(73, 95, "Spd("..conf.horSpeedLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(155, 95, "Travel("..unitLongLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
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
  lcd.drawText(155, 41, strdist, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
  -- total distance
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawNumber(155, 107, telemetry.totalDist*unitLongScale*100, PREC2+MIDSIZE+RIGHT+CUSTOM_COLOR)
  -- hspeed
  local speed = utils.getMaxValue(telemetry.hSpeed,14)

  lcd.drawNumber(73,107,speed * conf.horSpeedMultiplier,MIDSIZE+RIGHT+PREC1+CUSTOM_COLOR)

  if status.showMinMaxValues == true then
    drawLib.drawVArrow(4, 33+8 + 4,true,false,utils)
    drawLib.drawVArrow(155-70, 41 + 4 ,true,false,utils)
    drawLib.drawVArrow(4,107+4,true,false,utils)
  end
end

local function background(myWidget,conf,telemetry,status,utils)
end

return {drawPane=drawPane,background=background}
