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
  local cx,cy,dx,dy
  local yPos = 0 + 20 + 8
  -----------------------
  -- artificial horizon
  -----------------------
  -- no roll ==> segments are vertical, offsets are multiples of 25
  if ( telemetry.roll == 0) then
    dx=0
    dy=telemetry.pitch
  else
    -- center line offsets
    dx = math.cos(math.rad(90 - r)) * -telemetry.pitch
    dy = math.sin(math.rad(90 - r)) * telemetry.pitch
  end
  local rollX = math.floor((LCD_W-158)/2 + 158/2)
  -----------------------
  -- dark color for "ground"
  -----------------------
  -- 140x110
  local minY = 24
  local maxY = 24 + 90

  local minX = (LCD_W-158)/2 + 1
  local maxX = (LCD_W-158)/2 + 158

  local ox = (LCD_W-158)/2 + 158/2 + dx + 5
  local oy = 69 + dy
  local yy = 0

  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(179, 204, 255))
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x7b, 0x9d, 0xff)) -- default blue
  lcd.drawFilledRectangle(minX,minY,158,maxY-minY,CUSTOM_COLOR)
  -- angle of the line passing on point(ox,oy)
  local angle = math.tan(math.rad(-telemetry.roll))
  -- for each pixel of the hud base/top draw vertical black
  -- lines from hud border to horizon line
  -- horizon line moves with pitch/roll
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(77, 153, 0))
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(102, 51, 0))
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x63, 0x30, 0x00)) --623000 old brown
  if math.abs(telemetry.roll) < 90 then
    if oy > minY and oy < maxY then
      lcd.drawFilledRectangle(minX,oy,158,maxY-oy + 1,CUSTOM_COLOR)
    elseif oy <= minY then
      lcd.drawFilledRectangle(minX,minY,158,maxY-minY,CUSTOM_COLOR)
    end
  else
    --inverted
    if oy > minY and oy < maxY then
      lcd.drawFilledRectangle(minX,minY,158,oy-minY + 1,CUSTOM_COLOR)
    elseif oy >= maxY then
      lcd.drawFilledRectangle(minX,minY,158,maxY-minY,CUSTOM_COLOR)
    end
  end
  --
-- parallel lines above and below horizon
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255, 255, 255))
  --
  local hx = math.cos(math.rad(90 - r)) * -(telemetry.pitch%45)
  local hy = math.sin(math.rad(90 - r)) * (telemetry.pitch%45)

  --drawLineWithClipping(rollX - hx, 69 + hy,r,50,SOLID,(LCD_W-158)/2,(LCD_W-158)/2 + 158,minY,maxY,CUSTOM_COLOR)

  for line=0,4
  do
    --
    local deltax = math.cos(math.rad(90 - r)) * 20 * line
    local deltay = math.sin(math.rad(90 - r)) * 20 * line
    --
    drawLib.drawLineWithClipping(rollX - deltax + hx, 69 + deltay + hy,r,50,DOTTED,(LCD_W-158)/2,(LCD_W-158)/2 + 158,minY,maxY,CUSTOM_COLOR,radio,rev)
    drawLib.drawLineWithClipping(rollX + deltax + hx, 69 - deltay + hy,r,50,DOTTED,(LCD_W-158)/2,(LCD_W-158)/2 + 158,minY,maxY,CUSTOM_COLOR,radio,rev)
  end

  local xx = math.cos(math.rad(r)) * 70 * 0.5
  local yy = math.sin(math.rad(r)) * 70 * 0.5
  --
  local x0 = rollX - xx
  local y0 = 69 - yy
  --
  local x1 = rollX + xx
  local y1 = 69 + yy
  --
  drawLib.drawLineWithClipping(x0,y0,r + 90,70,SOLID,(LCD_W-158)/2,(LCD_W-158)/2 + 158,minY,maxY,CUSTOM_COLOR,radio,rev)
  drawLib.drawLineWithClipping(x1,y1,r + 90,70,SOLID,(LCD_W-158)/2,(LCD_W-158)/2 + 158,minY,maxY,CUSTOM_COLOR,radio,rev)
  -------------------------------------
  -- hud bitmap
  -------------------------------------
  lcd.drawBitmap(utils.getBitmap("hud_160x90_rus"),(LCD_W-158)/2,24) --160x90
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
  -- altitude
  local alt = utils.getMaxValue(telemetry.homeAlt,11) * unitScale
  if math.abs(alt) > 999 then
    lcd.setColor(CUSTOM_COLOR,0x1FEA)
    lcd.drawNumber((LCD_W-158)/2+158 - 42,69-10,alt,CUSTOM_COLOR)
  elseif math.abs(alt) >= 10 then
    lcd.setColor(CUSTOM_COLOR,0x1FEA)
    lcd.drawNumber((LCD_W-158)/2+158 - 42,69-14,alt,MIDSIZE+CUSTOM_COLOR)
  else
    lcd.setColor(CUSTOM_COLOR,0x1FEA)
    lcd.drawNumber((LCD_W-158)/2+158 - 42,69-14,alt*10,MIDSIZE+PREC1+CUSTOM_COLOR)
  end
  lcd.setColor(CUSTOM_COLOR,0x1FEA)
  -- telemetry.hSpeed is in dm/s
  local hSpeed = utils.getMaxValue(telemetry.hSpeed,14) * 0.1 * conf.horSpeedMultiplier
  if (math.abs(hSpeed) >= 10) then
    lcd.drawNumber((LCD_W-158)/2+44,69-14,hSpeed,MIDSIZE+RIGHT+CUSTOM_COLOR)
  else
    lcd.drawNumber((LCD_W-158)/2+44,69-14,hSpeed*10,MIDSIZE+RIGHT+CUSTOM_COLOR+PREC1)
  end
  -- min/max arrows
  if status.showMinMaxValues == true then
    drawLib.drawVArrow((LCD_W-158)/2+50, 69-9,true,false,utils)
    drawLib.drawVArrow((LCD_W-158)/2+158-57, 69-9,true,false,utils)
  end
    -- compass ribbon
  drawLib.drawCompassRibbon(120,myWidget,conf,telemetry,status,battery,utils,140,(LCD_W-140)/2,(LCD_W+140)/2,15)
end

local function background(myWidget,conf,telemetry,status,utils)
end

return {drawHud=drawHud,background=background}

