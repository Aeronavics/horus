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

local function drawPane(x,drawLib,conf,telemetry,status,alarms,battery,battId,utils)--,getMaxValue,getBitmap,drawBlinkBitmap,lcdBacklightOn)
  if conf.rangeFinderMax > 0 then
    local rng = telemetry.range
    rng = utils.getMaxValue(rng,16)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(8, 20, "Range("..unitLabel..")", SMLSIZE+CUSTOM_COLOR)
    if rng > conf.rangeFinderMax and status.showMinMaxValues == false then
      lcd.setColor(CUSTOM_COLOR,0xF800)
      lcd.drawFilledRectangle(68-65, 31+4,65,21,CUSTOM_COLOR)
    end
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawText(68, 31, string.format("%.1f",rng*0.01*unitScale), MIDSIZE+RIGHT+CUSTOM_COLOR)
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
    lcd.drawText(8, 20, "AltAsl("..unitLabel..")", SMLSIZE+CUSTOM_COLOR)
    local stralt = string.format("%d",alt*unitScale)
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    lcd.drawText(68, 31, stralt, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
  end
  -- LABELS
  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(153, 20, "Dist("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(69, 122, "AS("..conf.horSpeedLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(69, 76, "WPN", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(153, 76, "WPD("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  lcd.drawText(153, 122, "THR(%)", SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- VALUES
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- home distance
  drawLib.drawHomeIcon(69 + 15, 20 + 2,utils)
  flags = 0
  if telemetry.homeAngle == -1 then
    flags = BLINK
  end
  local dist = utils.getMaxValue(telemetry.homeDist,15)
  if status.showMinMaxValues == true then
    flags = 0
  end
  local strdist = string.format("%d",dist*unitScale)
  lcd.drawText(153, 31, strdist, MIDSIZE+flags+RIGHT+CUSTOM_COLOR)
  -- total distance
  strdist = string.format("%.02f%s", telemetry.totalDist*unitLongScale,unitLongLabel)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(152, 54, strdist, SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- airspeed
  lcd.drawNumber(68,134,telemetry.airspeed * conf.horSpeedMultiplier,MIDSIZE+RIGHT+PREC1+CUSTOM_COLOR)
  -- wp number
  lcd.drawNumber(57, 87, telemetry.wpNumber,MIDSIZE+RIGHT+CUSTOM_COLOR)
  -- wp distance
  lcd.drawNumber(153, 87, telemetry.wpDistance * unitScale,MIDSIZE+RIGHT+CUSTOM_COLOR)
  -- throttle %
  lcd.drawNumber(153,134,telemetry.throttle,MIDSIZE+RIGHT+CUSTOM_COLOR)
  -- LINES
  lcd.setColor(CUSTOM_COLOR,0xFFFF) --yellow
  -- wp bearing
  drawLib.drawRArrow(67,100,10,telemetry.wpBearing*45,CUSTOM_COLOR)
  --
  if status.showMinMaxValues == true then
    drawLib.drawVArrow(68-70, 31+4,true,false,utils)
    drawLib.drawVArrow(153-78, 31+4 ,true,false,utils)
  end
end

local function background(myWidget,conf,telemetry,status,utils)
  -- RC CHANNELS
  --[[
  if conf.enableRCChannels == true then
    for i=1,#telemetry.rcchannels do
      setTelemetryValue(Thr_ID, Thr_SUBID, Thr_INSTANCE + i, telemetry.rcchannels[i], 13 , Thr_PRECISION , "RC"..i)
    end
  end
  --]]

  -- VFR
  setTelemetryValue(0x0AF, 0, 0, telemetry.airspeed*0.1, 4 , 0 , "ASpd")
  setTelemetryValue(0x010F, 0, 1, telemetry.baroAlt*10, 9 , 1 , "BAlt")
  setTelemetryValue(0x050D, 0, 0, telemetry.throttle, 13 , 0 , "Thr")

  -- WP
  setTelemetryValue(0x050F, 0, 10, telemetry.wpNumber, 0 , 0 , "WPN")
  setTelemetryValue(0x082F, 0, 10, telemetry.wpDistance, 9 , 0 , "WPD")

  -- crosstrack error and wp bearing not exposed as OpenTX variables by default
  --[[
  setTelemetryValue(WPX_ID, WPX_SUBID, WPX_INSTANCE, telemetry.wpXTError, 9 , WPX_PRECISION , WPX_NAME)
  setTelemetryValue(WPB_ID, WPB_SUBID, WPB_INSTANCE, telemetry.wpBearing, 20 , WPB_PRECISION , WPB_NAME)
  --]]
end

return {drawPane=drawPane,background=background}
