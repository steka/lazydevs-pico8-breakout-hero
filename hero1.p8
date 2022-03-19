pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--goals
-- 7. juicyness
--     particles
--      - death particles
--      - brick particles
--      - collision particles\
--      - pickup particles
--      - explosions
-- 8. high score
-- 9. ui
--    - powerup messages
--    - powerup percentage bar
-- 10. better collision
-- 11. gameplay tweaks
--     - smaller paddle

function _init()
 cls()
 mode="start"
 level=""
 debug=""
 levelnum = 1
 levels={}
 --levels[1] = "x5b"
 --levels[1] = "b9b/p9p/sbsbsbsbsb"
 --levels[1] = "hxixsxpxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxb"
 --levels[1] = "////x4b/s9s"
 levels[1] = "b9bb9bb9bb9bb9bb9b"

 shake=0

 blink_g=7
 blink_g_i=1

 blink_w=7
 blink_w_i=1

 blinkframe=0
 blinkspeed=8

 fadeperc=0

 startcountdown=-1
 govercountdown=-1

 arrm=1
 arrm2=1
 arrmframe=0

 --particles
 part={}

 lasthitx=0
 lasthity=0
end

function startgame()
 mode="game"
 ball_r=2
 ball_dr=0.5

 pad_x=52
 pad_y=120
 pad_dx=0
 pad_wo=24--original pad width
 pad_w=24 --current pad with
 pad_h=3
 pad_c=7

 brick_w=9
 brick_h=4

 levelnum = 1
 level = levels[levelnum]
 buildbricks(level)
 --brick_y=20

 lives=0
 points=0
 sticky = false

 chain=1 --combo chain multiplier

 timer_mega=0
 timer_slow=0
 timer_expand=0
 timer_reduce=0

 serveball()
end

function nextlevel()
 mode="game"
 pad_x=52
 pad_y=120
 pad_dx=0

 levelnum+=1
 if levelnum > #levels then
  -- we've beaten the gane
  -- we need some kind of special
  -- screen here
  mode="start"
  return
 end
 level=levels[levelnum]
 buildbricks(level)

 chain=1
 sticky = false

 serveball()
end

function buildbricks(lvl)
 local i,j,o,chr,last
 bricks={}

 j=0
 -- b = normal brick
 -- x = empty space
 -- i = indestructable brick
 -- h = hardened brick
 -- s = sploding brick
 -- p = powerup brick

 for i=1,#lvl do
  j+=1
  chr=sub(lvl,i,i)
  if chr=="b"
  or chr=="i"
  or chr=="h"
  or chr=="s"
  or chr=="p" then
   last=chr
   addbrick(j,chr)
  elseif chr=="x" then
   last="x"
  elseif chr=="/" then
   j=(flr((j-1)/11)+1)*11
  elseif chr>="1" and chr<="9" then
   for o=1,chr+0 do
    if last=="b"
    or last=="i"
    or last=="h"
    or last=="s"
    or last=="p" then
     addbrick(j,last)
    elseif last=="x" then
     --nothing
    end
    j+=1
   end
   j-=1
  end
 end
end

function resetpills()
 pill={}
end

function addbrick(_i,_t)
 local _b
 _b = {}
 _b.x=4+((_i-1)%11)*(brick_w+2)
 _b.y=20+flr((_i-1)/11)*(brick_h+2)
 _b.v=true
 _b.t=_t
 _b.fsh=0
 _b.ox=0
 _b.oy=-(128+rnd(128))
 _b.dx=0
 _b.dy=rnd(64)

 add(bricks,_b)
end

function levelfinished()
 if #bricks == 0 then return true end

 for i=1,#bricks do
  if bricks[i].v == true and bricks[i].t != "i" then
   return false
  end
 end
 return true
end

function serveball()
 ball={}
 ball[1] = newball()

 ball[1].x=pad_x+flr(pad_w/2)
 ball[1].y=pad_y-ball_r
 ball[1].dx=1
 ball[1].dy=-1
 ball[1].ang=1
 ball[1].stuck=true

 pointsmult=1
 chain=1
 timer_mega=0
 timer_slow=0
 timer_expand=0
 timer_reduce=0

 resetpills()

 sticky_x=flr(pad_w/2)

 --0.50
 --1.30
end

function newball()
 b = {}
 b.x = 0
 b.y = 0
 b.dx = 0
 b.dy = 0
 b.ang = 1
 b.stuck = false
 return b
end

function copyball(ob)
 b={}
 b.x = ob.x
 b.y = ob.y
 b.dx = ob.dx
 b.dy = ob.dy
 b.ang = ob.ang
 b.stuck = ob.stuck
 return b
end

function setang(bl,ang)
 bl.ang=ang
 if ang==2 then
  bl.dx=0.50*sign(bl.dx)
  bl.dy=1.30*sign(bl.dy)
 elseif ang==0 then
  bl.dx=1.30*sign(bl.dx)
  bl.dy=0.50*sign(bl.dy)
 else
  bl.dx=1*sign(bl.dx)
  bl.dy=1*sign(bl.dy)
 end
end

function multiball()
 local ballnum = flr(rnd(#ball))+1
 local ogball = ball[ballnum]

 ball2 = copyball(ogball)
 --ball3 = copyball(ball[1])

 if ogball.ang==0 then
  setang(ball2,2)
  --setang(ball3,2)
 elseif ogball.ang==1 then
  setang(ogball,0)
  setang(ball2,2)
  --ball[1].ang==1
  --setang(ball3,2)
 else
  setang(ball2,0)
  --setang(ball3,1)
 end

 ball2.stuck=false
 ball[#ball+1]=ball2
 --ball[#ball+1]=ball3
end

function sign(n)
 if n<0 then
  return -1
 elseif n>0 then
  return 1
 else
  return 0
 end
end

function gameover()
 mode="gameoverwait"
 govercountdown=60
 blinkspeed=16
end

function levelover()
 mode="levelover"
end

function releasestuck()
 for i=1,#ball do
  if ball[i].stuck then
   ball[i].x=mid(3,ball[i].x,124)
   ball[i].stuck=false
  end
 end
end

function pointstuck(sign)
 for i=1,#ball do
  if ball[i].stuck then
   ball[i].dx=abs(ball[i].dx)*sign
  end
 end
end

function powerupget(_p)
 if _p == 1 then
  -- slowdown
  timer_slow = 900
 elseif _p == 2 then
  -- life
  lives+=1
 elseif _p == 3 then
  -- catch
  -- check if there are stuck balls
  hasstuck=false
  for i=1,#ball do
   if ball[i].stuck then
    hasstuck=true
   end
  end
  if hasstuck==false then
   sticky = true
  end
 elseif _p == 4 then
  -- expand
  timer_expand = 900
  timer_reduce = 0
 elseif _p == 5 then
  -- reduce
  timer_reduce = 900
  timer_expand = 0
 elseif _p == 6 then
  -- megaball
  timer_mega = 900
 elseif _p == 7 then
  -- multiball
  multiball()
 end
end

function hitbrick(_i,_combo)
 local fshtime=10

 if bricks[_i].t=="b" then
  -- regular brick
  sfx(2+chain)
  --spawn particles
  shatterbrick(bricks[_i],lasthitx,lasthity)
  bricks[_i].fsh=fshtime
  bricks[_i].v=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
 elseif bricks[_i].t=="i" then
  --invincible brick
  sfx(10)
 elseif bricks[_i].t=="h" then
  -- hardened brick
  if timer_mega > 0 then
   sfx(2+chain)
   bricks[_i].fsh=fshtime
   bricks[_i].v=false
   if _combo then
    points+=10*chain*pointsmult
    chain+=1
    chain=mid(1,chain,7)
   end
  else
   sfx(10)
   bricks[_i].t="b"
  end
 elseif bricks[_i].t=="p" then
  -- powerup brick
  sfx(2+chain)
  --spawn particles
  shatterbrick(bricks[_i],lasthitx,lasthity)
  bricks[_i].fsh=fshtime
  bricks[_i].v=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
  spawnpill(bricks[_i].x,bricks[_i].y)
 elseif bricks[_i].t=="s" then
  -- sposion brick
  sfx(2+chain)
  bricks[_i].t="zz"
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
 end
end

function spawnpill(_x,_y)
 local _t
 local _pill

 _t = flr(rnd(7))+1
 --_t = flr(rnd(2))
 --if _t== 0 then
 -- _t = 7
 --else
 -- _t = 3
 --end


 _pill={}
 _pill.x = _x
 _pill.y = _y
 _pill.t = _t
 add(pill,_pill)
end

function checkexplosions()
 for i=1,#bricks do
  if bricks[i].t == "zz" and bricks[i].v then
   bricks[i].t="z"
  end
 end

 for i=1,#bricks do
  if bricks[i].t == "z" and bricks[i].v then
   explodebrick(i)
   shake+=0.4
   if shake>1 then
    shake=1
   end
  end
 end

 for i=1,#bricks do
  if bricks[i].t == "zz" then
   bricks[i].t="z"
  end
 end
end

function explodebrick(_i)
 bricks[_i].v=false
 for j=1,#bricks do
  if j!=_i
  and bricks[j].v
  and abs(bricks[j].x-bricks[_i].x) <= (brick_w+2)
  and abs(bricks[j].y-bricks[_i].y) <= (brick_h+2)
  then
   hitbrick(j,false)
  end
 end
end

function ball_box(bx,by,box_x,box_y,box_w,box_h)
 -- checks for a collion of the ball with a rectangle
 if by-ball_r > box_y+box_h then return false end
 if by+ball_r < box_y then return false end
 if bx-ball_r > box_x+box_w then return false end
 if bx+ball_r < box_x then return false end
 return true
end

function box_box(box1_x,box1_y,box1_w,box1_h,box2_x,box2_y,box2_w,box2_h)
 -- checks for a collion of the two boxes
 if box1_y > box2_y+box2_h then return false end
 if box1_y+box1_h < box2_y then return false end
 if box1_x > box2_x+box2_w then return false end
 if box1_x+box1_w < box2_x then return false end
 return true
end

function deflx_ball_box(bx,by,bdx,bdy,tx,ty,tw,th)
 local slp = bdy / bdx
 local cx, cy
 if bdx == 0 then
  return false
 elseif bdy == 0 then
  return true
 elseif slp > 0 and bdx > 0 then
  cx = tx - bx
  cy = ty - by
  return cx > 0 and cy/cx < slp
 elseif slp < 0 and bdx > 0 then
  cx = tx - bx
  cy = ty + th - by
  return cx > 0 and cy/cx >= slp
 elseif slp > 0 and bdx < 0 then
  cx = tx + tw - bx
  cy = ty + th - by
  return cx < 0 and cy/cx <= slp
 else
  cx = tx + tw - bx
  cy = ty - by
  return cx < 0 and cy/cx >= slp
 end
end

-->8
-- juicy stuff --

function doshake()
 -- -16 +16
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)

 shakex=shakex*shake
 shakey=shakey*shake

 camera(shakex,shakey)

 shake=shake*0.95
 if shake<0.05 then
  shake=0
 end
end

-- do the blinking
function doblink()
 local g_seq = {3,11,7,11}
 local w_seq = {5,6,7,6}

 -- text blinking
 blinkframe+=1
 if blinkframe>blinkspeed then
  blinkframe=0

  blink_g_i+=1
  if blink_g_i > #g_seq then
   blink_g_i=1
  end
  blink_g=g_seq[blink_g_i]

  blink_w_i+=1
  if blink_w_i > #w_seq then
   blink_w_i=1
  end
  blink_w=w_seq[blink_w_i]
 end

 -- trajectory preview anim
 -- first dot
 arrmframe+=1
 if arrmframe>30 then
  arrmframe=0
 end
 arrm=1+(2*(arrmframe/30))
 -- second dot
 local af2=arrmframe+15
 if af2>30 then
  af2 = af2-30
 end
 arrm2=1+(2*(af2/30))

end

-- fading
function fadepal(_perc)
 -- 0 means normal
 -- 1 is completely black

 local p=flr(mid(0,_perc,1)*100)

 -- these are helper variables
 local kmax,col,dpal,j,k
 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}

 -- now we go trough all colors
 for j=1,15 do
  --grab the current color
  col = j

  --now calculate how many
  --times we want to fade the
  --color.
  kmax=(p+(j*1.46))/22
  for k=1,kmax do
   col=dpal[col]
  end

  --finally, we change the
  --palette
  pal(j,col,1)
 end
end

-- particle stuff

-- add a particle
function addpart(_x,_y,_dx,_dy,_type,_maxage,_col)
 local _p = {}
 _p.x=_x
 _p.y=_y
 _p.dx=_dx
 _p.dy=_dy
 _p.tpe=_type
 _p.mage=_maxage
 _p.age=0
 _p.col=0
 _p.colarr=_col
 add(part,_p)
end

-- spawn a trail particle
function spawntrail(_x,_y)
 if rnd()<0.5 then
  local _ang = rnd()
  local _ox = sin(_ang)*ball_r*0.3
  local _oy = cos(_ang)*ball_r*0.3

  addpart(_x+_ox,_y+_oy,0,0,0,15+rnd(15),{10,9})
 end
end

-- shatter brick
function shatterbrick(_b,_vx,_vy)
 --bump the brick
 _b.dx = _vx*1
 _b.dy = _vy*1
 for _x= 0,brick_w do
  for _y= 0,brick_h do
   if rnd()<0.5 then
    local _ang = rnd()
    local _dx = sin(_ang)*rnd(2)+(_vx/2)
    local _dy = cos(_ang)*rnd(2)+(_vy/2)

    addpart(_b.x+_x,_b.y+_y,_dx,_dy,1,80,{7,6,5})
   end
  end
 end
end

-- big particle updater
function updateparts()
 local _p
 for i=#part,1,-1 do
  _p=part[i]
  _p.age+=1
  if _p.age>_p.mage then
   del(part,part[i])
  elseif _p.x < -20 or _p.x > 148 then
   del(part,part[i])
  elseif _p.y < -20 or _p.y > 148 then
   del(part,part[i])
  else
   -- change colors
   if #_p.colarr==1 then
    _p.col = _p.colarr[1]
   else
    local _ci=_p.age/_p.mage
    _ci=1+flr(_ci*#_p.colarr)
    _p.col = _p.colarr[_ci]
   end

   --appy gravity
   if _p.tpe == 1 then
    _p.dy+=0.05
   end

   --move particle
   _p.x+=_p.dx
   _p.y+=_p.dy
  end
 end
end

-- big particle drawer
function drawparts()
 for i=1,#part do
  _p=part[i]
  -- pixel particle
  if _p.tpe == 0 or _p.tpe == 1 then
   pset(_p.x,_p.y,_p.col)
  end
 end
end

--rebound bumped bricks
function animatebricks()
 for i=1,#bricks do
  local _b=bricks[i]
  if _b.v or _b.fsh>0 then
   -- see if brick is moving
   if _b.dx~=0 or _b.dy~=0 or _b.ox~=0 or _b.oy~=0 then
    --apply the speed
    _b.ox+=_b.dx
    _b.oy+=_b.dy

    --change the speed
    --brick wants to go to zero
    _b.dx-=_b.ox/10
    _b.dy-=_b.oy/10

    -- dampening
    if abs(_b.dx)>(_b.ox) then
     _b.dx=_b.dx/1.3
    end
    if abs(_b.dy)>(_b.oy) then
     _b.dy=_b.dy/1.3
    end

    -- snap to zero if close
    if abs(_b.ox)<0.2 and abs(_b.dx)<0.25 then
     _b.ox=0
     _b.dx=0
    end
    if abs(_b.oy)<0.2 and abs(_b.dy)<0.25 then
     _b.oy=0
     _b.dy=0
    end

   end
  end
 end
end
-->8
-- update functions

function _update60()
 doblink()
 doshake()
 updateparts()
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="gameover" then
  update_gameover()
 elseif mode=="gameoverwait" then
  update_gameoverwait()
 elseif mode=="levelover" then
  update_levelover()
 end
end


function update_start()
 if startcountdown<0 then
  if btnp(4) then
   startcountdown=80
   blinkspeed=1
   sfx(12)
  end
 else
  startcountdown-=1
  fadeperc=(80-startcountdown)/80
  if startcountdown<=0 then
   startcountdown= -1
   blinkspeed=8
   startgame()
  end
 end
end

function update_gameover()
 if govercountdown<0 then
  if btnp(4) then
   govercountdown=80
   blinkspeed=1
   sfx(12)
  end
 else
  govercountdown-=1
  fadeperc=(80-govercountdown)/80
  if govercountdown<=0 then
   govercountdown= -1
   blinkspeed=8
   startgame()
  end
 end
end

function update_gameoverwait()
 govercountdown-=1
 if govercountdown<=0 then
  govercountdown= -1
  mode="gameover"
 end
end

function update_levelover()
 if btnp(4) then
  nextlevel()
 end
end

function update_game()
 local buttpress=false
 local nextx,nexty,brickhit

 -- fade in game
 if fadeperc~=0 then
  fadeperc-=0.05
  if fadeperc<0 then
   fadeperc=0
  end
 end

 if timer_expand > 0 then
  -- check if pad should grow
  pad_w = flr(pad_wo * 1.5)
 elseif timer_reduce > 0 then
  -- check if pad should shrink
  pad_w = flr(pad_wo / 2)
  pointsmult=2
 else
  pad_w = pad_wo
  pointsmult=1
 end

 if btn(0) then
  --left
  pad_dx=-2.5
  buttpress=true
  --pad_x-=5
  pointstuck(-1)
 end
 if btn(1) then
  --right
  pad_dx=2.5
  buttpress=true
  --pad_x+=5
  pointstuck(1)
 end
 if btnp(4) then
  releasestuck()
 end

 if not(buttpress) then
  pad_dx=pad_dx/1.3
 end
 pad_x+=pad_dx
 pad_x=mid(0,pad_x,127-pad_w)

 -- big ball loop
 for bi=#ball,1,-1 do
  updateball(bi)
 end

 -- move pills
 -- check collision for pills
 for i=#pill,1,-1 do
  pill[i].y+=0.7
  if pill[i].y > 128 then
   -- remove pill
   del(pill,pill[i])
  elseif box_box(pill[i].x,pill[i].y,8,6,pad_x,pad_y,pad_w,pad_h) then
   powerupget(pill[i].t)
   -- remove pill
   del(pill,pill[i])
   sfx(11)
  end
 end

 checkexplosions()

 if levelfinished() then
  _draw()
  levelover()
 end

 -- powerup timers
 if timer_mega > 0 then
  timer_mega-=1
 end
 if timer_slow > 0 then
  timer_slow-=1
 end
 if timer_expand > 0 then
  timer_expand-=1
 end
 if timer_reduce > 0 then
  timer_reduce-=1
 end

 --animate bricks
 animatebricks()

end

function updateball(bi)
 myball = ball[bi]
 if myball.stuck then
  --ball_x=pad_x+flr(pad_w/2)
  myball.x=pad_x+sticky_x
  myball.y=pad_y-ball_r-1
 else
  --regular ball physics
  if timer_slow > 0 then
   nextx=myball.x+(myball.dx/2)
   nexty=myball.y+(myball.dy/2)
  else
   nextx=myball.x+myball.dx
   nexty=myball.y+myball.dy
  end

  --check if ball hit wall
  if nextx > 124 or nextx < 3 then
   nextx=mid(0,nextx,127)
   myball.dx = -myball.dx
   sfx(0)
  end
  if nexty < 10 then
   nexty=mid(0,nexty,127)
   myball.dy = -myball.dy
   sfx(0)
  end

  -- check if ball hit pad
  if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
   -- deal with collision
   if deflx_ball_box(myball.x,myball.y,myball.dx,myball.dy,pad_x,pad_y,pad_w,pad_h) then
    --ball hit paddle on the side
    myball.dx = -myball.dx
    if myball.x < pad_x+pad_w/2 then
     nextx=pad_x-ball_r
    else
     nextx=pad_x+pad_w+ball_r
    end
   else
    --ball hit paddle on the top/bottom
    myball.dy = -myball.dy
    if myball.y > pad_y then
     --bottom
     nexty=pad_y+pad_h+ball_r
    else
     --top
     nexty=pad_y-ball_r
     if abs(pad_dx)>2 then
      --change angle
      if sign(pad_dx)==sign(myball.dx) then
       --flatten angle
       setang(myball,mid(0,myball.ang-1,2))
      else
       --raise angle
       if myball.ang==2 then
        myball.dx=-myball.dx
       else
        setang(myball,mid(0,myball.ang+1,2))
       end
      end
     end
    end
   end
   sfx(1)
   chain=1

   --catch powerup
   if sticky and myball.dy < 0 then
    releasestuck()
    sticky = false
    myball.stuck = true
    sticky_x = myball.x-pad_x
   end
  end

  brickhit=false
  for i=1,#bricks do
   -- check if ball hit brick
   if bricks[i].v and ball_box(nextx,nexty,bricks[i].x,bricks[i].y,brick_w,brick_h) then
    -- deal with collision
    if not(brickhit) then
     if (timer_mega > 0 and bricks[i].t=="i")
     or timer_mega <= 0 then
      lasthitx=myball.dx
      lasthity=myball.dy
      if deflx_ball_box(myball.x,myball.y,myball.dx,myball.dy,bricks[i].x,bricks[i].y,brick_w,brick_h) then
       myball.dx = -myball.dx
      else
       myball.dy = -myball.dy
      end
     end
    end
    brickhit=true
    hitbrick(i,true)
   end
  end
  myball.x=nextx
  myball.y=nexty

  --trail particles
  spawntrail(nextx,nexty)

  -- check if ball left screen
  if nexty > 127 then
   sfx(2)
   if #ball > 1 then
    shake+=0.15
    del(ball,myball)
   else
    shake+=0.4
    lives-=1
    if lives<0 then
     gameover()
    else
     serveball()
    end
   end
  end

 end -- end of sticky if
end
-->8
-- draw functions

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="gameoverwait" then
  draw_game()
 elseif mode=="gameover" then
  draw_gameover()
 elseif mode=="levelover" then
  draw_levelover()
 end

 -- fade the screen
 pal()
 if fadeperc ~= 0 then
  fadepal(fadeperc)
 end
end

function draw_start()
 cls()
 print("pico hero breakout",30,40,7)
 print("press ❎ to start",32,80,blink_g)
end

function draw_gameover()
 rectfill(0,60,128,75,0)
 print("game over",46,62,7)
 print("press ❎ to restart",27,68,blink_w)
end

function draw_levelover()
 rectfill(0,60,128,75,0)
 print("stage clear!",46,62,7)
 print("press ❎ to continue",27,68,6)
end

function draw_game()
 local i
 cls()
 --cls(1)
 rectfill(0,0,127,127,1)

 --draw bricks
 for i=1,#bricks do
  local _b=bricks[i]
  if _b.v or _b.fsh>0 then
   if _b.fsh>0 then
    brickcol = 7
    _b.fsh-=1
   elseif _b.t == "b" then
    brickcol = 14
   elseif _b.t == "i" then
    brickcol = 6
   elseif _b.t == "h" then
    brickcol = 15
   elseif _b.t == "s" then
    brickcol = 9
   elseif _b.t == "p" then
    brickcol = 12
   elseif _b.t == "z" or bricks[i].t == "zz" then
    brickcol = 8
   end
   local _bx = _b.x+_b.ox
   local _by = _b.y+_b.oy
   rectfill(_bx,_by,_bx+brick_w,_by+brick_h,brickcol)
  end
 end

 -- particles
 drawparts()

 -- pills
 for i=1,#pill do
  if pill[i].t==5 then
   palt(0,false)
   palt(15,true)
  end
  spr(pill[i].t,pill[i].x,pill[i].y)
  palt()
 end

 -- balls
 for i=1,#ball do
  circfill(ball[i].x,ball[i].y,ball_r, 10)
  if ball[i].stuck then
   -- draw trajectory preview dots
   pset(ball[i].x+ball[i].dx*4*arrm,
        ball[i].y+ball[i].dy*4*arrm,
        10)
   pset(ball[i].x+ball[i].dx*4*arrm2,
        ball[i].y+ball[i].dy*4*arrm2,
        10)

  -- line(ball[i].x+ball[i].dx*4*arrm,
  --      ball[i].y+ball[i].dy*4*arrm,
  --     ball[i].x+ball[i].dx*6*arrm,
  --      ball[i].y+ball[i].dy*6*arrm,10)
  end
 end

 --pad
 rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)

 --ui
 rectfill(0,0,128,6,0)
 if debug!="" then
  print(debug,1,1,7)
 else
  print("lives:"..lives,1,1,7)
  print("score:"..points,40,1,7)
  print("chain:"..chain.."x",100,1,7)
 end
end

__gfx__
0000000006777760067777600677776006777760f677776f06777760067777600000000000000000000000000000000000000000000000000000000000000000
00000000559949955576777555b33bb555c1c1c55508800555e222e5558288850000000000000000000000000000000000000000000000000000000000000000
00700700559499955576777555b3bbb555cc1cc55508080555e222e5558288850000000000000000000000000000000000000000000000000000000000000000
00077000559949955576777555b3bbb555cc1cc55508800555e2e2e5558228850000000000000000000000000000000000000000000000000000000000000000
00077000559499955576677555b33bb555c1c1c55508080555e2e2e5558228850000000000000000000000000000000000000000000000000000000000000000
00700700059999500577775005bbbb5005cccc50f500005f05eeee50058888500000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001836018360183501833018320183100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002436024360243502433024320243100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000204501e4501b450184501645013450104500d4500a4500745003450014500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a36030360303503033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c36032360323503233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002e36034360343503433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003036036360363503633000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003236038360383503833000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000343603a3603a3503a33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000363603c3603c3503c33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003946035460354503543000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003a0503505030050290403b0503b0503b0501f0401d0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002a0502a0503203032030290202902032020320202a0102a01032010320102a0102a01032010320102a0102a0100000000000000000000000000000000000000000000000000000000000000000000000
