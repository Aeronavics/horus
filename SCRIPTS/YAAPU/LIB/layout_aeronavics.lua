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

local function draw_batt_info(position_x,position_y,drawLib,conf,telemetry,status,alarms,battery,utils)
  flags = CUSTOM_COLOR

  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  -- battery voltage
  lcd.drawNumber(position_x+77, position_y+16, battery[4], PREC1+DBLSIZE+RIGHT+flags)
  lcd.drawText(position_x+77, position_y+16, "V", flags+DBLSIZE)



  if conf.battConf == 1 then --Parellel Mode
    drawLib.drawNumberWithDim(position_x+77,position_y+47,position_x+79,position_y+58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(position_x+95, position_y+75, "Generator", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white

    drawLib.drawNumberWithDim(position_x+77, position_y+95,position_x+79,position_y+106,battery[8],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[20] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(position_x+95, position_y+125, "Battery", SMLSIZE+RIGHT+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  elseif conf.battConf == 2 then --Parellel Combined Mode
    drawLib.drawNumberWithDim(position_x+77,position_y+47,position_x+79,position_y+58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(position_x+95, position_y+75, "Total", SMLSIZE+RIGHT+CUSTOM_COLOR)  
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  else --Single source mode
    drawLib.drawNumberWithDim(position_x+77,position_y+47,position_x+79,position_y+58,battery[7],"A",MIDSIZE+RIGHT+CUSTOM_COLOR+(battery[19] == 0 and PREC1 or 0),SMLSIZE+CUSTOM_COLOR)
    lcd.setColor(CUSTOM_COLOR,0x0000)
    lcd.drawText(position_x+95, position_y+75, "Battery", SMLSIZE+RIGHT+CUSTOM_COLOR)  
    lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white 
  end
  
  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(position_x+15, position_y+154, "Eff(mAh)", SMLSIZE+CUSTOM_COLOR+RIGHT)
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white 
  lcd.drawNumber(position_x+15, position_y+166, battery[10], PREC2+MIDSIZE+RIGHT+CUSTOM_COLOR) 

  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(position_x+95, position_y+154, "Power(W)", SMLSIZE+CUSTOM_COLOR+RIGHT)
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white 
  lcd.drawNumber(position_x+95, position_y+166, battery[4]*battery[7], PREC2+MIDSIZE+RIGHT+CUSTOM_COLOR)


end

local function draw_sid_info(position_x,position_y,drawLib,conf,telemetry,status,alarms,battery,utils)
  lcd.setColor(CUSTOM_COLOR,0xFFFF) -- white
  -- battery voltage
  lcd.drawNumber(position_x+95, 16, telemetry.sid , DBLSIZE+RIGHT)
  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(position_x+95, 47, "AC SID", SMLSIZE+RIGHT+CUSTOM_COLOR)
end


local function draw_gps_info(position_x,position_y,drawLib,conf,telemetry,status,alarms,battery,utils)
  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(position_x+80, position_y+25, "GPSAlt("..unitLabel..")", SMLSIZE+CUSTOM_COLOR+RIGHT)
  local alt = telemetry.gpsAlt/10
  local stralt = string.format("%d",alt*unitScale)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(position_x+80, position_y+37, stralt, MIDSIZE+RIGHT+CUSTOM_COLOR)

  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawText(position_x+160, position_y+25, "Travel("..unitLongLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- total distance
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawNumber(position_x+160, position_y+37, telemetry.totalDist*unitLongScale*100, PREC2+MIDSIZE+RIGHT+CUSTOM_COLOR)

  lcd.setColor(CUSTOM_COLOR,0x0000)
  drawLib.drawHomeIcon(position_x+170, position_y+25,utils)
  lcd.drawText(position_x+240, position_y+25, "Dist("..unitLabel..")", SMLSIZE+RIGHT+CUSTOM_COLOR)
  local strdist = string.format("%d",telemetry.homeDist*unitScale)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(position_x+240, position_y+37, strdist, MIDSIZE+RIGHT+CUSTOM_COLOR)
  
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  drawLib.drawRArrow(position_x+265,position_y+45,20,math.floor(telemetry.homeAngle - telemetry.yaw),CUSTOM_COLOR)--HomeDirection(telemetry)

end

local function draw(myWidget,drawLib,conf,telemetry,status,battery,alarms,frame,utils,customSensors,centerPanel)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)

  --Draw centre HUD
  centerPanel.drawHud(myWidget,drawLib,conf,telemetry,status,battery,utils)

  --Draw battery info to right of HUD
  draw_batt_info(380, 0, drawLib,conf,telemetry,status,alarms,battery,utils)
  --Draw SID info to left of HUD
  draw_sid_info(0, 0, drawLib,conf,telemetry,status,alarms,battery,utils)
  --Draw GPS info below HUD
  draw_gps_info(0, 129, drawLib,conf,telemetry,status,alarms,battery,utils)


  lcd.setColor(CUSTOM_COLOR,0x0000)
  -- RPM 1
  if conf.enableRPM == 2  or conf.enableRPM == 3 then
    lcd.drawText(92, 154, "RPM 1", SMLSIZE+RIGHT+CUSTOM_COLOR)
    drawLib.drawBar("rpm1", 4, 169, 86, 22, 0xFE60, math.abs(telemetry.rpm1), MIDSIZE)
  end
  -- RPM 2
  if conf.enableRPM == 3 then
    lcd.drawText(192, 154, "RPM 2", SMLSIZE+RIGHT+CUSTOM_COLOR)
    drawLib.drawBar("rpm2", 104, 169, 86, 22, 0xFE60, math.abs(telemetry.rpm2), MIDSIZE)
  end

  utils.drawTopBar()
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

  lcd.setColor(CUSTOM_COLOR,0xFFFF)
end

return {draw=draw}

