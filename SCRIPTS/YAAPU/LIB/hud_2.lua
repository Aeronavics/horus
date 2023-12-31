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

-- model and opentx version
local ver, radio, maj, minor, rev = getVersion()

local function drawHud(myWidget,drawLib,conf,telemetry,status,battery,utils)

  local r = -telemetry.roll
  local cx,cy,dx,dy--,ccx,ccy,cccx,cccy
  local yPos = 0 + 20 + 8
  -----------------------
  -- artificial horizon
  -----------------------
  -- no roll ==> segments are vertical, offsets are multiples of 12
  if ( telemetry.roll == 0) then
    dx=0
    dy=telemetry.pitch
    cx=0
    cy=12
    --ccx=0
    --ccy=2*12
    --cccx=0
    --cccy=3*12
  else
    -- center line offsets
    dx = math.cos(math.rad(90 - r)) * -telemetry.pitch
    dy = math.sin(math.rad(90 - r)) * telemetry.pitch
    -- 1st line offsets
    cx = math.cos(math.rad(90 - r)) * 12
    cy = math.sin(math.rad(90 - r)) * 12
    -- 2nd line offsets
    --ccx = math.cos(math.rad(90 - r)) * 2 * 12
    --ccy = math.sin(math.rad(90 - r)) * 2 * 12
    -- 3rd line offsets
    --cccx = math.cos(math.rad(90 - r)) * 3 * 12
    --cccy = math.sin(math.rad(90 - r)) * 3 * 12
  end
  local rollX = math.floor((LCD_W-160)/2 + 160/2)
  -----------------------
  -- dark color for "ground"
  -----------------------
  -- 140x90
  local minY = 24
  local maxY = 24 + 90

  local minX = (LCD_W-160)/2
  local maxX = (LCD_W-160)/2 + 160

  local ox = (LCD_W-160)/2 + 160/2 + dx
  local oy = 69 + dy
  local yy = 0

  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x0d, 0x68, 0xb1)) -- bighud blue
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x7b, 0x9d, 0xff)) -- default blue
  lcd.drawFilledRectangle(minX,minY,maxX-minX,maxY - minY,CUSTOM_COLOR)
  -- HUD
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(77, 153, 0))
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x90, 0x63, 0x20)) --906320 bighud brown
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x63, 0x30, 0x00)) --623000 old brown
  
  -- angle of the line passing on point(ox,oy)
  local angle = math.tan(math.rad(-telemetry.roll))
  -- prevent divide by zero
  if telemetry.roll == 0 then
    drawLib.drawFilledRectangle(minX,math.max(minY,dy+minY+(maxY-minY)/2),maxX-minX,math.min(maxY-minY,(maxY-minY)/2-dy+(math.abs(dy) > 0 and 1 or 0)),CUSTOM_COLOR)
  elseif math.abs(telemetry.roll) >= 180 then
    drawLib.drawFilledRectangle(minX,minY,maxX-minX,math.min(maxY-minY,(maxY-minY)/2+dy),CUSTOM_COLOR)
  else
    -- HUD drawn using horizontal bars of height 2
    -- true if flying inverted
    local inverted = math.abs(telemetry.roll) > 90
    -- true if part of the hud can be filled in one pass with a rectangle
    local fillNeeded = false
    local yRect = inverted and 0 or LCD_H
    
    local step = 2
    local steps = (maxY - minY)/step - 1
    local yy = 0
    
    if 0 < telemetry.roll and telemetry.roll < 180 then
      for s=0,steps
      do
        yy = minY + s*step
        xx = ox + (yy-oy)/angle
        if xx >= minX and xx <= maxX then
          lcd.drawFilledRectangle(xx, yy, maxX-xx+1, step,CUSTOM_COLOR)
        elseif xx < minX then
          yRect = inverted and math.max(yy,yRect)+step or math.min(yy,yRect)
          fillNeeded = true
        end
      end
    elseif -180 < telemetry.roll and telemetry.roll < 0 then
      for s=0,steps
      do
        yy = minY + s*step
        xx = ox + (yy-oy)/angle
        if xx >= minX and xx <= maxX then
          lcd.drawFilledRectangle(minX, yy, xx-minX, step,CUSTOM_COLOR)
        elseif xx > maxX then
          yRect = inverted and math.max(yy,yRect)+step or math.min(yy,yRect)
          fillNeeded = true
        end
      end
    end
    
    if fillNeeded then
      local yMin = inverted and minY or yRect
      local height = inverted and yRect - minY or maxY-yRect
      --lcd.setColor(CUSTOM_COLOR,0xF800) --623000 old brown
      lcd.drawFilledRectangle(minX, yMin, maxX-minX, height ,CUSTOM_COLOR)
    end
  end


  -- parallel lines above and below horizon
  local linesMaxY = maxY-1
  local linesMinY = minY+1
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- +/- 90 deg
  for dist=1,8
  do
    drawLib.drawLineWithClipping(rollX + dx - dist*cx,dy + 69 + dist*cy,r,(dist%2==0 and 40 or 20),DOTTED,(LCD_W-160)/2+2,(LCD_W-160)/2+160-2,linesMinY,linesMaxY,CUSTOM_COLOR,radio,rev)
    drawLib.drawLineWithClipping(rollX + dx + dist*cx,dy + 69 - dist*cy,r,(dist%2==0 and 40 or 20),DOTTED,(LCD_W-160)/2+2,(LCD_W-160)/2+160-2,linesMinY,linesMaxY,CUSTOM_COLOR,radio,rev)
  end
-- hashmarks
  local startY = minY + 1
  local endY = maxY - 10
  local step = 18
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(120,120,120))
  -- hSpeed
  local roundHSpeed = math.floor((telemetry.hSpeed*conf.horSpeedMultiplier*0.1/5)+0.5)*5;
  local offset = math.floor((telemetry.hSpeed*conf.horSpeedMultiplier*0.1-roundHSpeed)*0.2*step);
  local ii = 0;
  local yy = 0
  for j=roundHSpeed+10,roundHSpeed-10,-5
  do
      yy = startY + (ii*step) + offset
      if yy >= startY and yy < endY then
        lcd.drawLine((LCD_W-160)/2 + 1, yy+9, (LCD_W-160)/2 + 5, yy+9, SOLID, CUSTOM_COLOR)
        lcd.drawNumber((LCD_W-160)/2 + 8,  yy, j, SMLSIZE+CUSTOM_COLOR)
      end
      ii=ii+1;
  end
  -- altitude
  local roundAlt = math.floor((telemetry.homeAlt*unitScale/5)+0.5)*5;
  offset = math.floor((telemetry.homeAlt*unitScale-roundAlt)*0.2*step);
  ii = 0;
  yy = 0
  for j=roundAlt+10,roundAlt-10,-5
  do
      yy = startY + (ii*step) + offset
      if yy >= startY and yy < endY then
        lcd.drawLine((LCD_W-160)/2 + 160 - 15, yy+8, (LCD_W-160)/2 + 160 -10, yy+8, SOLID, CUSTOM_COLOR)
        lcd.drawNumber((LCD_W-160)/2 + 160 - 16,  yy, j, SMLSIZE+RIGHT+CUSTOM_COLOR)
      end
      ii=ii+1;
  end
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -------------------------------------
  -- hud bitmap
  -------------------------------------
  lcd.drawBitmap(utils.getBitmap("hud_160x90c"),(LCD_W-160)/2,24) --160x90
  -------------------------------------
  -- vario bitmap
  -------------------------------------
  local varioMax = 5
  local varioSpeed = math.min(math.abs(0.1*telemetry.vSpeed),5)
  local varioH = varioSpeed/varioMax*35
  if telemetry.vSpeed > 0 then
    varioY = 24 + 35 - varioH
  else
    varioY = 24 + 55
  end
  --00ae10
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255, 0xce, 0)) --yellow
  -- lcd.setColor(CUSTOM_COLOR,lcd.RGB(00, 0xED, 0x32)) --green
  -- lcd.setColor(CUSTOM_COLOR,lcd.RGB(50, 50, 50)) --dark grey
  lcd.drawFilledRectangle(310, varioY, 10, varioH, CUSTOM_COLOR, 0)

  -------------------------------------
  -- left and right indicators on HUD
  -------------------------------------
  -- DATA
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  -- altitude
  local alt = utils.getMaxValue(telemetry.homeAlt,11) * unitScale
  if math.abs(alt) > 999 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(00, 0xED, 0x32)) --green
    lcd.drawNumber((LCD_W-160)/2+160+1,69-10,alt,CUSTOM_COLOR+RIGHT)
  elseif math.abs(alt) >= 10 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(00, 0xED, 0x32)) --green
    lcd.drawNumber((LCD_W-160)/2+160+1,69-14,alt,MIDSIZE+CUSTOM_COLOR+RIGHT)
  else
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(00, 0xED, 0x32)) --green
    lcd.drawNumber((LCD_W-160)/2+160+1,69-14,alt*10,MIDSIZE+PREC1+CUSTOM_COLOR+RIGHT)
  end
  -- telemetry.hSpeed is in dm/s
  local hSpeed = utils.getMaxValue(telemetry.hSpeed,14) * 0.1 * conf.horSpeedMultiplier
  if (math.abs(hSpeed) >= 10) then
    lcd.drawNumber((LCD_W-160)/2+2,69-14,hSpeed,MIDSIZE+CUSTOM_COLOR)
  else
    lcd.drawNumber((LCD_W-160)/2+2,69-14,hSpeed*10,MIDSIZE+CUSTOM_COLOR+PREC1)
  end
  -- min/max arrows
  if status.showMinMaxValues == true then
    drawLib.drawVArrow((LCD_W-160)/2+50, 69-9,true,false,utils)
    drawLib.drawVArrow((LCD_W-160)/2+160-57, 69-9,true,false,utils)
  end
  -- compass ribbon
  drawLib.drawCompassRibbon(120,myWidget,conf,telemetry,status,battery,utils,140,(LCD_W-140)/2,(LCD_W+140)/2,15,false)
end

local function background(myWidget,conf,telemetry,status,utils)
end

return {drawHud=drawHud,background=background}
