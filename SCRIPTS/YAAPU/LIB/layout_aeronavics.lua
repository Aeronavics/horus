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


local customSensorXY = {
  { 80, 193, 80, 203},
  { 160, 193, 160, 203},
  { 240, 193, 240, 203},
  { 320, 193, 320, 203},
  { 400, 193, 400, 203},
  { 480, 193, 480, 203},
}

local function tx_batt_percent()
  local perc = 123 - 123/(math.pow(1+math.pow(getValue(getFieldInfo("tx-voltage").id)/7.1, 80), 0.124))
  return perc
end

local function drawTopBar(telemetry, utils)
  lcd.setColor(CUSTOM_COLOR,0x0000)
  -- black bar
  lcd.drawFilledRectangle(0,0, LCD_W, 18, CUSTOM_COLOR)
  -- frametype and model name
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- if status.modelString ~= nil then
  --   lcd.drawText(2, 0, status.modelString, CUSTOM_COLOR)
  -- end
  lcd.drawText(2, 0, "Aeronavics", CUSTOM_COLOR)
  -- flight time
  -- local time = getDateTime()
  -- local strtime = string.format("%02d:%02d:%02d",time.hour,time.min,time.sec)
  -- lcd.drawText(LCD_W, 0, strtime, SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- RSSI
  -- RSSI
  if utils.telemetryEnabled() == false then
    lcd.setColor(CUSTOM_COLOR,0xF800)
    lcd.drawText(323-23, 0, "NO TELEM", 0+CUSTOM_COLOR)
  else
    utils.drawRssi()
  end
  lcd.setColor(CUSTOM_COLOR,0xFFFF)

  -- tx voltage
  local vtx = string.format("%.1fV",getValue(getFieldInfo("tx-voltage").id))
  lcd.drawText(LCD_W-24, 0, vtx, RIGHT+CUSTOM_COLOR+SMLSIZE)
  
  -- display capacity bar %
  local perc = tx_batt_percent()
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255, 255))
  lcd.drawFilledRectangle(LCD_W-24, 4,20,10,CUSTOM_COLOR)
  if perc > 40 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(0, 255, 0)) --green
  elseif perc <= 40 and perc > 10 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(255, 204, 0)) -- yellow
  else
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,0, 0)) --red
  end
  lcd.drawGauge(LCD_W-24, 4,20,10,perc,100,CUSTOM_COLOR)
  lcd.drawFilledRectangle(LCD_W-4, 7, 2, 4, CUSTOM_COLOR) --Head of battery
end

local function draw_batt_info(position_x,position_y,drawLib,conf,battery,telemetry)
  flags = CUSTOM_COLOR
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  lcd.drawText(position_x+97, position_y, "AC Voltage", SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- battery voltage
  local strvolt = string.format("%.1f",battery.AC_voltage)
  lcd.drawText(position_x+97, position_y+12, strvolt .. "V", DBLSIZE+RIGHT+flags)

  if conf.battConf == 1 or (telemetry.hybridconfig and conf.battConf == 3) then --Hybrid Mode
    lcd.drawText(position_x+97, position_y+48, "Generator", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.drawText(position_x+97,position_y+60, battery.Batt2_current .. "A", MIDSIZE+RIGHT+CUSTOM_COLOR)
    
    lcd.drawText(position_x+97, position_y+93, "Battery", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.drawText(position_x+97,position_y+105, battery.Batt1_current .. "A", MIDSIZE+RIGHT+CUSTOM_COLOR)

  else --Battery powered mode
    lcd.drawText(position_x+97, position_y+48, "AC Current", SMLSIZE+RIGHT+CUSTOM_COLOR)
    if (battery.AC_current < 1 and battery.AC_current ~= 0) then --Current sensors unreliable below 1A
      lcd.drawText(position_x+97,position_y+60, "<1A", MIDSIZE+RIGHT+CUSTOM_COLOR)
    else
      lcd.drawText(position_x+97,position_y+60, battery.AC_current .. "A", MIDSIZE+RIGHT+CUSTOM_COLOR)
    end

    
  end

  lcd.drawText(position_x+97, position_y+138, "AC Power", SMLSIZE+CUSTOM_COLOR+RIGHT)
  if (battery.AC_current < 1 and battery.AC_current ~= 0) then --Current sensors unreliable below 1A
    lcd.drawText(position_x+97, position_y+150, "<50W", MIDSIZE+RIGHT+CUSTOM_COLOR)
  else
    lcd.drawText(position_x+97, position_y+150, battery.AC_power_draw.."W", MIDSIZE+RIGHT+CUSTOM_COLOR)
  end

end

local function draw_sid_info(position_x,position_y,telemetry)
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  lcd.drawText(position_x + 3, position_y, "AC SID", SMLSIZE+CUSTOM_COLOR)
  lcd.drawNumber(position_x + 3, position_y+12, telemetry.sid , DBLSIZE)
  
end


local function draw_gps_info(position_x,position_y,drawLib,telemetry,utils)
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white

  lcd.drawText(position_x + 3, position_y, "Alt(AMSL, "..unitLabel..")", SMLSIZE+CUSTOM_COLOR)
  if telemetry.gpsStatus > 2 then 
    local stralt = string.format("%.1f",telemetry.gpsAlt*unitScale)
    lcd.drawText(position_x + 3, position_y+12, stralt, MIDSIZE+CUSTOM_COLOR)
  else
    lcd.drawText(position_x + 3, position_y+12, "---", MIDSIZE+CUSTOM_COLOR)
  end
  
  if (telemetry.range ~= 0) then
    lcd.drawText(position_x + 3, position_y+45, "RngAlt("..unitLabel..")", SMLSIZE+CUSTOM_COLOR)
    local stralt = string.format("%.1f",telemetry.range*unitScale)
    lcd.drawText(position_x+ 3, position_y+57, stralt, MIDSIZE+CUSTOM_COLOR)
  end

  lcd.drawText(position_x + 3, position_y+90, "Travel("..unitLongLabel..")", SMLSIZE+CUSTOM_COLOR)
  -- total distance
  local strtravel = string.format("%.2f",telemetry.totalDist*unitLongScale)
  lcd.drawText(position_x + 3, position_y+102, strtravel, MIDSIZE+CUSTOM_COLOR)

  drawLib.drawHomeIcon(LCD_W/2-70, position_y+92,utils)
  lcd.drawText(LCD_W/2, position_y+90, "Dist("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  local strdist = string.format("%d",telemetry.homeDist*unitScale)
  lcd.drawText(LCD_W/2, position_y+102, strdist, MIDSIZE+RIGHT+CUSTOM_COLOR)
  
  drawLib.drawRArrow(LCD_W/2+25,position_y+110,20,math.floor(telemetry.homeAngle - telemetry.yaw),CUSTOM_COLOR)--HomeDirection(telemetry)

end

local function draw(myWidget,drawLib,conf,telemetry,status,battery,alarms,frame,utils,customSensors,centerPanel)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)

  --Draw centre HUD
  centerPanel.drawHud(myWidget,drawLib,conf,telemetry,status,battery,utils)

  --Draw battery info to right of HUD
  draw_batt_info(380, 16, drawLib,conf,battery,telemetry)
  --Draw SID info to left of HUD
  draw_sid_info(0, 16, telemetry)
  --Draw GPS info below HUD
  draw_gps_info(0, 64, drawLib,telemetry,utils)

  drawTopBar(telemetry, utils)
  local msgRows = 4
  if customSensors ~= nil then
    msgRows = 1
    -- draw custom sensors
    drawLib.drawCustomSensors(0,customSensors,customSensorXY,utils,status,0x8C71)
  end
  drawLib.drawStatusBar(msgRows,conf,telemetry,status,battery,alarms,frame,utils)
  drawLib.drawFailsafe(telemetry,utils)
  drawLib.drawArmStatus(status,telemetry,utils)
  local nextX = drawLib.drawTerrainStatus(utils,status,telemetry,101,19)
  drawLib.drawFenceStatus(utils,status,telemetry,nextX,19)

  -- no telemetry/minmax outer box
  if utils.telemetryEnabled() == false then
    -- no telemetry inner box
    -- if not status.hideNoTelemetry then
    drawLib.drawNoTelemetryData(status,telemetry,utils)
    -- end
    utils.drawBlinkBitmap("warn",0,0)
  else
    if status.showMinMaxValues == true then
      utils.drawBlinkBitmap("minmax",0,0)
    end
  end
end

return {draw=draw}

