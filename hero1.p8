pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--goals
-- 14 particle deco
-------- textboxes ?

-- 10 level design
-- 11 gameplay tweaks
-------- smaller paddle
-------- powerup timers
-------- reduce gives points

-----------------------
--- good to have    ---
-----------------------
-- 12. sound
--     - level over fanare
--     - start screen music
--     - game won fanfare
-- 13. better collision
-- ?? powerup percentage bar

function _init()
 cartdata("layzdevs_hero1")
 cls()

 mode="start"
 level=""
 debug=""
 levelnum = 1
 levels={}
 levels[1] = "x5b"
 --levels[1] = "b9b/p9p/sbsbsbsbsb"
 --levels[1] = "hxixsxpxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxb"
 --levels[1] = "/i4//x4b/s9s"
 --levels[1] = "b9bh9h"
 --levels[1] = "b9bb9bb9bb9bh9hp9p"
 levels[2] = "b9bb9bb9b/i9"

 shake=0

 blink_g=7
 blink_g_i=1

 blink_w=7
 blink_w_i=1

 blink_b=7
 blink_b_i=1


 blinkframe=0
 blinkspeed=8

 fadeperc=1

 startcountdown=-1
 govercountdown=-1
 goverrestart=false
 arrm=1
 arrm2=1
 arrmframe=0

 --particles
 part={}

 lasthitx=0
 lasthity=0

 --highscrore
 hs={}
 hs1={}
 hs2={}
 hs3={}
 hsb={true,false,false,false,false}
 --reseths()
 loadhs()
 hschars={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
 hs_x=128
 hs_dx=128
 loghs=false
 --typing in intitals
 nitials={1,1,1}
 nit_sel=1
 nit_conf=false
 --sash
 sash_w=0
 sash_dw=0
 sash_tx=0
 sash_tdx=0
 sash_c=8
 sash_tc=7
 sash_text="ohai"
 sash_frames=0
 sash_v=false
 sash_delay_w=0
 sash_delay_t=0

 -- particle patterns
 parttimer=0
 partrow=0
 startparts()
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

 showsash("stage "..levelnum,0,7)

 serveball()
end

function nextlevel()
 mode="game"
 pad_x=52
 pad_y=120
 pad_dx=0

 levelnum+=1
 if levelnum > #levels then
  --error. game about to load
  --a level that doesnt exist
  mode="start"
  return
 end
 level=levels[levelnum]
 buildbricks(level)

 chain=1
 sticky = false

 showsash("stage "..levelnum,0,7)
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
 resethsb()
end

function levelover()
 mode="leveloverwait"
 govercountdown=60
 blinkspeed=16
end

function wingame()
 mode="winnerwait"
 govercountdown=60
 blinkspeed=16

 --find out if pluer is good
 --enough for high score
 if points>hs[5] then
  loghs=true
  nit_sel=1
  nit_conf=false
 else
  loghs=false
  resethsb()
 end
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
  timer_slow = 400
  showsash("slowdown!",9,4)
 elseif _p == 2 then
  -- life
  lives+=1
  showsash("extra life!",7,6)
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
  showsash("sticky paddle!",11,3)
 elseif _p == 4 then
  -- expand
  timer_expand = 900
  timer_reduce = 0
  showsash("expand!",12,1)
 elseif _p == 5 then
  -- reduce
  timer_reduce = 900
  timer_expand = 0
  showsash("reduce!",0,8)
 elseif _p == 6 then
  -- megaball
  timer_mega = 100
  showsash("megaball!",8,2)
 elseif _p == 7 then
  -- multiball
  multiball()
  showsash("multiball!",10,9)
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
   boostchain()
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
    boostchain()
   end
  else
   sfx(10)
   bricks[_i].t="b"
   bricks[_i].fsh=fshtime
   --bump the brick
   bricks[_i].dx = lasthitx*0.25
   bricks[_i].dy = lasthity*0.25
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
   boostchain()
  end
  spawnpill(bricks[_i].x,bricks[_i].y)
 elseif bricks[_i].t=="s" then
  -- sposion brick
  sfx(2+chain)
  shatterbrick(bricks[_i],lasthitx,lasthity)
  bricks[_i].t="zz"
  if _combo then
   points+=10*chain*pointsmult
   boostchain()
  end
 end
end

-- increase chain by one
function boostchain()
 if chain==6 then
  showsash("so sick!!",12,1)
 end
 chain+=1
 chain=mid(1,chain,7)
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
   spawnexplosion(bricks[i].x,bricks[i].y)
   if shake<0.4 then
    shake+=0.1
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

function showsash(_t,_c,_tc)
 sash_w=0
 sash_dw=4
 sash_c=_c
 sash_text=_t
 sash_frames=0
 sash_v=true
 sash_tx=-#sash_text*4
 sash_tdx=64-(#sash_text*2)
 sash_delay_w=0
 sash_delay_t=5
 sash_tc=_tc

end

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
 local b_seq = {9,10,7,10,9}

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

  blink_b_i+=1
  if blink_b_i > #b_seq then
   blink_b_i=1
  end
  blink_b=b_seq[blink_b_i]
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
function addpart(_x,_y,_dx,_dy,_type,_maxage,_col,_s)
 local _p = {}
 _p.x=_x
 _p.y=_y
 _p.dx=_dx
 _p.dy=_dy
 _p.tpe=_type
 _p.mage=_maxage
 _p.age=0
 _p.col=_col[1]
 _p.colarr=_col
 _p.rot=0
 _p.rottimer=0
 _p.s=_s
 _p.os=_s

 add(part,_p)
end

-- spawn a small puft
function spawnpuft(_x,_y)
 for i= 0,5 do
  local _ang = rnd()
  local _dx = sin(_ang)*1
  local _dy = cos(_ang)*1
  addpart(_x,_y,_dx,_dy,2,15+rnd(15),{7,6,5},1+rnd(2))
 end
end

-- spawn a puft in the color of a pill
function spawnpillpuft(_x,_y,_p)
 for i= 0,20 do
  local _ang = rnd()
  local _dx = sin(_ang)*(1+rnd(2))
  local _dy = cos(_ang)*(1+rnd(2))
  local _mycol

  if _p == 1 then
   -- slowdown -- orange
   _mycol={9,9,4,4,0}
  elseif _p == 2 then
   -- life -- white
   _mycol={7,7,6,5,0}
  elseif _p == 3 then
   -- catch -- green
   _mycol={11,11,3,3,0}
  elseif _p == 4 then
   -- expand -- blue
   _mycol={12,12,5,5,0}
  elseif _p == 5 then
   -- reduce -- black
   _mycol={0,0,5,5,6}
  elseif _p == 6 then
   -- megaball -- red
   _mycol={8,8,4,2,0}
  else
   -- multiball -- yellow
   _mycol={10,10,9,4,0}
  end
  addpart(_x,_y,_dx,_dy,2,20+rnd(15),_mycol,1+rnd(4))
 end
end

-- spawn death particles
function spawndeath(_x,_y)
 for i= 0,30 do
  local _ang = rnd()
  local _dx = sin(_ang)*(2+rnd(4))
  local _dy = cos(_ang)*(2+rnd(4))
  local _mycol

  _mycol={10,10,9,4,0}
  addpart(_x,_y,_dx,_dy,2,80+rnd(15),_mycol,3+rnd(6))
 end
end

-- spawn death particles
function spawnexplosion(_x,_y)
 --first smoke
 sfx(14)
 for i= 0,20 do
  local _ang = rnd()
  local _dx = sin(_ang)*(rnd(4))
  local _dy = cos(_ang)*(rnd(4))
  local _mycol
  _mycol={0,0,5,5,6}
  addpart(_x,_y,_dx,_dy,2,80+rnd(15),_mycol,3+rnd(6))
 end
 --fireball
 for i= 0,30 do
  local _ang = rnd()
  local _dx = sin(_ang)*(1+rnd(4))
  local _dy = cos(_ang)*(1+rnd(4))
  local _mycol
  _mycol={7,10,9,8,5}
  addpart(_x,_y,_dx,_dy,2,30+rnd(15),_mycol,2+rnd(4))
 end

end

-- spawn a trail particle
function spawntrail(_x,_y)
 if rnd()<0.5 then
  local _ang = rnd()
  local _ox = sin(_ang)*ball_r*0.3
  local _oy = cos(_ang)*ball_r*0.3

  addpart(_x+_ox,_y+_oy,0,0,0,15+rnd(15),{10,9},0)
 end
end

-- spawn a megatrail particle
function spawnmtrail(_x,_y)
 if rnd() then
  local _ang = rnd()
  local _ox = sin(_ang)*ball_r
  local _oy = cos(_ang)*ball_r

  addpart(_x+_ox,_y+_oy,0,0,2,60+rnd(15),{8,2,0},1+rnd(1))
 end
end

-- shatter brick
function shatterbrick(_b,_vx,_vy)
 --screenshake and sound
 if shake<0.5 then
  shake+=0.07
 end
 sfx(13)

 --bump the brick
 _b.dx = _vx*1
 _b.dy = _vy*1
 for _x= 0,brick_w do
  for _y= 0,brick_h do
   if rnd()<0.5 then
    local _ang = rnd()
    local _dx = sin(_ang)*rnd(2)+(_vx/2)
    local _dy = cos(_ang)*rnd(2)+(_vy/2)

    addpart(_b.x+_x,_b.y+_y,_dx,_dy,1,80,{7,6,5},0)
   end
  end
 end

 local chunks=1+flr(rnd(10))
 if chunks>0 then
  for i=1,chunks do
   local _ang = rnd()
   local _dx = sin(_ang)*rnd(2)+(_vx/2)
   local _dy = cos(_ang)*rnd(2)+(_vy/2)
   local _spr = 16 + flr(rnd(14))
   addpart(_b.x,_b.y,_dx,_dy,3,80,{_spr},0)

  end
 end

end
--particles
-- type 0 - static pixel
-- type 1 - gravity pixel
-- type 2 - ball of smoke
-- type 3 - rotating sprite
-- type 4 - blue rotating sprite
-- type 5 - gravity smoke

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
   if _p.tpe == 1 or _p.tpe == 3 then
    _p.dy+=0.05
   end

   --appy low gravity
   if _p.tpe == 5 then
    if abs(_p.dy)<1 then
     _p.dy+=0.01
    end
   end


   --rotate
   if _p.tpe == 3 or _p.tpe == 4 then
    _p.rottimer+=1
    if _p.rottimer>5 then
     _p.rot+=1
     if _p.rot>=4 then
      _p.rot=0
     end
    end
   end

   --shrink
   if _p.tpe == 2 or _p.tpe == 5 then
    local _ci=1-(_p.age/_p.mage)
    _p.s=_ci*_p.os
   end

   --friction
   if _p.tpe == 2 then
    _p.dx=_p.dx/1.2
    _p.dy=_p.dy/1.2
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
  elseif _p.tpe == 2 or _p.tpe == 5 then
   circfill(_p.x,_p.y,_p.s,_p.col)
  elseif _p.tpe == 3 or _p.tpe == 4 then
   local _fx,_fy
   if _p.tpe == 3 then
    if _p.rot==2 then
     _fx=false
     _fy=true
    elseif _p.rot==3 then
     _fx=true
     _fy=true
    elseif _p.rot==4 then
     _fx=true
     _fy=false
    else
     _fx=false
     _fy=false
    end
   elseif _p.tpe == 4 then
    pal(7,1)
   end
   spr(_p.col,_p.x,_p.y,1,1,_fx,_fy)
   pal()
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

function startparts()
 for i=0,300 do
  spawnbgparts(false,i)
 end
end

function spawnbgparts(_top,_t)
 if _t%30==0 then
  if partrow==0 then
   partrow=1
  else
   partrow=0
  end
  for i=0,8 do
   if _top then
    _y=-8
   else
    _y=-8+0.4*_t
   end
   if (i+partrow)%2==0 then
    addpart(i*16,_y,0,0.4,0,10000,{1},0)
   else
    local _spr = 16 + flr(rnd(14))
    addpart((i*16)-4,_y-4,0,0.4,4,10000,{_spr},0)
   end
  end
 end
 if _t%15==0 then
  if _top then
   _y=-8
  else
   _y=-8+0.8*_t
  end
  for i=0,8 do
   addpart(8+i*16,_y,0,0.8,0,10000,{1},0)
  end
 end
end
-->8
-- update functions

function _update60()
 doblink()
 doshake()
 updateparts()
 update_sash()
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
 elseif mode=="leveloverwait" then
  update_leveloverwait()
 elseif mode=="winner" then
  update_winner()
 elseif mode=="winnerwait" then
  update_winnerwait()
 end
end

function update_sash()
 if sash_v then
  sash_frames+=1
  --animate width
  if sash_delay_w>0 then
   sash_delay_w-=1
  else
   sash_w+=(sash_dw-sash_w)/5
   if abs(sash_dw-sash_w)<0.3 then
    sash_w=sash_dw
   end
  end
  --animate text
  if sash_delay_t>0 then
   sash_delay_t-=1
  else
   sash_tx+=(sash_tdx-sash_tx)/10
   if abs(sash_tx-sash_tdx)<0.3 then
    sash_tx=sash_tdx
   end
  end
  --make sash go away
  if sash_frames==75 then
   sash_dw=0
   sash_tdx=160
   sash_delay_w=15
   sash_delay_t=0
  end
  if sash_frames>115 then
   sash_v=false
  end
 end
end

function update_winnerwait()
 govercountdown-=1
 if govercountdown<=0 then
  govercountdown= -1
  blinkspeed=4
  mode="winner"
 end
end

function update_winner()
 local _ang = rnd()
 local _dx = sin(_ang)*(rnd(0.5))
 local _dy = cos(_ang)*(rnd(0.5))
 local _mycol={12,12,5,5,0}
 local _toprow=40
 local _btnrow=_toprow+52

 addpart(flr(rnd(128)),_toprow,_dx,_dy,5,120+rnd(15),_mycol,3+rnd(6))
 addpart(flr(rnd(128)),_btnrow,_dx,_dy,5,120+rnd(15),_mycol,3+rnd(6))

 if govercountdown<0 then
  if loghs then
   if btnp(0) then
    sfx(17)
    if nit_conf then
     nit_conf=false
     sfx(19)
    end
    nit_conf=false
    nit_sel-=1
    if nit_sel<1 then
     nit_sel = 3
    end
   end
   if btnp(1) then
    sfx(17)
    if nit_conf then
     nit_conf=false
     sfx(19)
    end
    nit_conf=false
    nit_sel+=1
    if nit_sel>3 then
     nit_sel = 1
    end
   end
   if btnp(2) then
    sfx(16)
    if nit_conf then
     nit_conf=false
     sfx(19)
    end
    nit_conf=false
    nitials[nit_sel]-=1
    if nitials[nit_sel]<1 then
     nitials[nit_sel]=#hschars
    end
   end
   if btnp(3) then
    sfx(16)
    if nit_conf then
     nit_conf=false
     sfx(19)
    end
    nitials[nit_sel]+=1
    if nitials[nit_sel]>#hschars then
     nitials[nit_sel]=1
    end
   end
   if btnp(4) then
    if nit_conf then
     --confirm initials
     --add a new high score
     addhs(points,nitials[1],nitials[2],nitials[3])
     savehs()
     govercountdown=80
     blinkspeed=1
     sfx(15)
    else
     nit_conf=true
     sfx(18)
    end
   end
   if btnp(5) then
    if nit_conf then
     nit_conf=false
     sfx(19)
    end
   end

  else
   if btnp(4) then
    govercountdown=80
    blinkspeed=1
    sfx(15)
   end
  end
 else
  govercountdown-=1
  fadeperc=(80-govercountdown)/80
  if govercountdown<=0 then
   govercountdown= -1
   blinkspeed=8
   mode="start"
   part={}
   startparts()
   hs_x=128
   hs_dx=0
  end
 end
end

function update_start()
 -- raining particles
 parttimer=parttimer+1

 spawnbgparts(true,parttimer)
 --slide the high score list
 if hs_x~=hs_dx then
  hs_x+=(hs_dx-hs_x)/5
  if abs(hs_dx-hs_x)<0.3 then
   hs_x=hs_dx
  end
 end

 if startcountdown<0 then
  -- fade in game
  if fadeperc~=0 then
   fadeperc-=0.05
   if fadeperc<0 then
    fadeperc=0
   end
  end

  if btnp(4) then
   startcountdown=80
   blinkspeed=1
   sfx(12)
  end
  if btnp(0) then
   if hs_dx~=0 then
    hs_dx=0
    sfx(20)
   end
  end
  if btnp(1) then
   if hs_dx~=128 then
    hs_dx=128
    sfx(20)
   end
  end
 else
  startcountdown-=1
  fadeperc=(80-startcountdown)/80
  if startcountdown<=0 then
   startcountdown= -1
   blinkspeed=8
   part={}
   startgame()
  end
 end
end

function update_gameover()
 local _ang = rnd()
 local _dx = sin(_ang)*(rnd(0.3))
 local _dy = cos(_ang)*(rnd(0.3))
 local _mycol={0,0,2,8}
 local _toprow=60
 local _btnrow=81

 addpart(flr(rnd(128)),_toprow,_dx,_dy,5,70+rnd(15),_mycol,3+rnd(6))
 addpart(flr(rnd(128)),_btnrow,_dx,_dy,5,70+rnd(15),_mycol,3+rnd(6))

 if govercountdown<0 then
  if btnp(4) then
   govercountdown=80
   blinkspeed=1
   sfx(12)
   goverrestart=true
  end
  if btnp(5) then
   govercountdown=80
   blinkspeed=1
   sfx(12)
   goverrestart=false
  end
 else
  govercountdown-=1
  fadeperc=(80-govercountdown)/80
  if govercountdown<=0 then
   if goverrestart then
    govercountdown= -1
    blinkspeed=8
    part={}
    startgame()
   else
    govercountdown= -1
    blinkspeed=8
    mode="start"
    part={}
    startparts()
    hs_x=128
    hs_dx=128
   end
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

function update_leveloverwait()
 govercountdown-=1
 if govercountdown<=0 then
  govercountdown= -1
  mode="levelover"
 end
end


function update_levelover()
 local _ang = rnd()
 local _dx = sin(_ang)*(rnd(0.3))
 local _dy = cos(_ang)*(rnd(0.3))
 local _mycol={12,12,5,5,0}
 local _toprow=60
 local _btnrow=75
 addpart(flr(rnd(128)),_toprow,_dx,_dy,5,70+rnd(15),_mycol,3+rnd(6))
 addpart(flr(rnd(128)),_btnrow,_dx,_dy,5,70+rnd(15),_mycol,3+rnd(6))

 if govercountdown<0 then
  if btnp(4) then
   govercountdown=80
   blinkspeed=1
   sfx(15)
  end
 else
  govercountdown-=1
  fadeperc=(80-govercountdown)/80
  if govercountdown<=0 then
   govercountdown= -1
   blinkspeed=8
   part={}
   nextlevel()
  end
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
   spawnpillpuft(pill[i].x,pill[i].y,pill[i].t)
   -- remove pill
   del(pill,pill[i])
   sfx(11)
  end
 end

 checkexplosions()

 if levelfinished() then
  _draw()
  if levelnum >= #levels then
   wingame()
  else
   levelover()
  end
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
   spawnpuft(nextx,nexty)
  end
  if nexty < 10 then
   nexty=mid(0,nexty,127)
   myball.dy = -myball.dy
   sfx(0)
   spawnpuft(nextx,nexty)
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
   spawnpuft(nextx,nexty)

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
  if timer_mega > 0 then
   spawnmtrail(nextx,nexty)
  else
   spawntrail(nextx,nexty)
  end
  -- check if ball left screen
  if nexty > 127 then
   sfx(2)
   spawndeath(myball.x,myball.y)
   if #ball > 1 then
    shake+=0.15
    del(ball,myball)
   else
    shake+=0.4
    lives-=1
    if lives<0 then
     lives=0
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
 elseif mode=="leveloverwait" then
  draw_game()
 elseif mode=="winner" then
  draw_winner()
 elseif mode=="winnerwait" then
  draw_game()
 end
 -- fade the screen
 pal()
 if fadeperc ~= 0 then
  fadepal(fadeperc)
 end
end

function draw_sash()
 if sash_v then
  rectfill(0,64-sash_w,128,64+sash_w,sash_c)
  print(sash_text,sash_tx,62,sash_tc)
 end
end

function draw_winner()
 -- draw game underneath sash
 draw_game()

 if loghs then
  --won. type in name
  --for highscore list
  local _y=40
  rectfill(0,_y,128,_y+52,12)
  print("★congratulations!★",26,_y+4,1)
  print("you have beaten the game",15,_y+14,7)
  print("enter your initials",15,_y+20,7)
  print("for the high score list.",15,_y+26,7)
  local _colors = {7,7,7}
  if nit_conf then
    _colors = {blink_b,blink_b,blink_b}
  else
   _colors[nit_sel] = blink_b
  end
  print(hschars[nitials[1]],59,_y+34,_colors[1])
  print(hschars[nitials[2]],63,_y+34,_colors[2])
  print(hschars[nitials[3]],67,_y+34,_colors[3])

  if nit_conf then
   print("press ❎ to confirm",27,_y+42,blink_b)
  else
   print("use ⬅️➡️⬆️⬇️❎",35,_y+42,6)
  end
 else
  --won but no highscore
  local _y=40
  rectfill(0,_y,128,_y+52,12)
  print("★congratulations!★",26,_y+4,1)
  print("you have beaten the game",15,_y+14,7)
  print("but your score is too low",15,_y+20,7)
  print("for the high score list.",15,_y+26,7)
  print("try again!",15,_y+32,7)

  print("press ❎ for main menu",20,_y+42,blink_b)
 end
end

function draw_start()
 cls()

 -- particles
 drawparts()

 --draw logo
 palt(14,true)
 spr(64,(hs_x-128)+36,10,7,5)
 palt()
 print("by lazy devs",40+(hs_x-128),50,2)
 print("bit.ly/lazydevs",34+(hs_x-128),56,2)

 prinths(hs_x)
 print("press ❎ to start",32,80,blink_g)
 if hs_x==128 then
  print("press ⬅️ for high score list",9,97,3)
 end
end

function draw_gameover()
 -- draw particles
 draw_game()

 local _c1, _c2
 rectfill(0,60,128,81,0)
 print("game over",46,62,7)
 if govercountdown<0 then
  _c1=blink_w
  _c2=blink_w
 else
  if goverrestart then
   _c1=blink_w
   _c2=5
  else
   _c2=blink_w
   _c1=5
  end
 end
 print("press ❎ to restart",27,68,_c1)
 print("press 🅾️ for main menu",20,74,_c2)

end

function draw_levelover()
 draw_game()

 rectfill(0,60,128,75,12)
 print("stage clear!",46,62,1)
 print("press ❎ to continue",27,68,blink_b)
end

function draw_game()
 local i
 cls()
 --cls(1)
 rectfill(0,0,127,127,1)

 --draw brick
 local _bsprite=false
 local _bspritex=64

 for i=1,#bricks do
  local _b=bricks[i]
  if _b.v or _b.fsh>0 then
   if _b.fsh>0 then
    brickcol = 7
    _b.fsh-=1
   elseif _b.t == "b" then
    brickcol = 14
    _bsprite=false
   elseif _b.t == "i" then
    brickcol = 6
    _bsprite=true
    _bspritex=74
   elseif _b.t == "h" then
    brickcol = 15
    _bsprite=true
    _bspritex=94
   elseif _b.t == "s" then
    brickcol = 9
    _bsprite=true
    _bspritex=64
   elseif _b.t == "p" then
    brickcol = 12
    _bsprite=true
    _bspritex=84
   elseif _b.t == "z" or bricks[i].t == "zz" then
    brickcol = 7
   end
   local _bx = _b.x+_b.ox
   local _by = _b.y+_b.oy
   if _bsprite and _b.fsh==0 then
    palt(0,false)
    sspr(_bspritex,0,10,5,_bx,_by)
    palt()
   else
    rectfill(_bx,_by,_bx+brick_w,_by+brick_h,brickcol)
   end
  end
 end

 -- particles
 drawparts()

 -- pills
 for i=1,#pill do
  palt(0,false)
  palt(13,true)
  spr(pill[i].t,pill[i].x,pill[i].y)
  palt()
 end

 -- balls
 for i=1,#ball do
  local _ballspr=34
  if timer_mega > 0 then
   _ballspr=35
  end
  palt(1,true)
  spr(_ballspr,ball[i].x-3,ball[i].y-3)
  palt()
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
 palt(1,true)
 sspr(0,16,5,6,pad_x,pad_y)
 sspr(8,16,5,6,pad_x+pad_w-4,pad_y)
 for i=5,pad_w-5 do
  sspr(5,16,1,6,pad_x+i,pad_y)
 end
 palt()

 --ui
 rectfill(0,0,128,6,0)
 if debug!="" then
  print(debug,1,1,7)
 else
  print("lives:"..lives,1,1,7)
  print("score:"..points,60,1,7)
  print(chain.."x",120,1,7)
 end

 draw_sash()
end
-->8
--highscore tab

--add a new high score
function addhs(_score,_c1,_c2,_c3)
 add(hs,_score)
 add(hs1,_c1)
 add(hs2,_c2)
 add(hs3,_c3)
 for i=1,#hsb do
  hsb[i]=false
 end
 add(hsb,true)
 sorths()
end

function resethsb()
 for i=1,#hsb do
  hsb[i]=false
 end
 hsb[1]=true
end

--sort high score list
function sorths()
 for i=1,#hs do
  local j = i
  while j > 1 and hs[j-1] < hs[j] do
   hs[j],hs[j-1]=hs[j-1],hs[j]
   hs1[j],hs1[j-1]=hs1[j-1],hs1[j]
   hs2[j],hs2[j-1]=hs2[j-1],hs2[j]
   hs3[j],hs3[j-1]=hs3[j-1],hs3[j]
   hsb[j],hsb[j-1]=hsb[j-1],hsb[j]
   j = j - 1
  end
 end
end

--resets the high score list
function reseths()
 --create default values
 hs={100,1,1,1,1}
 hs1={1,1,8,1,1}
 hs2={1,6,1,1,14}
 hs3={10,1,1,12,1}
 hsb={true,false,false,false,false}

 sorths()
 savehs()
end

--load the highscore list
function loadhs()
 local _slot=0

 if dget(0)==1 then
  --load the data
  _slot+=1
  for i=1,5 do
   hs[i]=dget(_slot)
   hs1[i]=dget(_slot+1)
   hs2[i]=dget(_slot+2)
   hs3[i]=dget(_slot+3)
   _slot+=4
  end
  sorths()
 else
  --file is empty
  reseths()
 end
end

--save the high score list
function savehs()
 local _slot
 dset(0, 1)
 --load the data
 _slot=1
 for i=1,5 do
  dset(_slot,hs[i])
  dset(_slot+1,hs1[i])
  dset(_slot+2,hs2[i])
  dset(_slot+3,hs3[i])
  _slot+=4
 end
end

--prints the high score list
function prinths(_x)
 rectfill(_x+29,8,_x+99,16,8)
 print("high score list",_x+36,10,7)

 for i=1,5 do
  -- number of rank
  print(i.." - ",_x+30,14+7*i,5)
  --name
  local _c=7
  if hsb[i] then
   _c=blink_w
  end
  local _name = hschars[hs1[i]]
  _name = _name..hschars[hs2[i]]
  _name = _name..hschars[hs3[i]]

  print(_name,_x+45,14+7*i,_c)

  -- actual score
  local _score=" "..hs[i]

  print(_score,(_x+100)-(#_score*4),14+7*i,_c)
 end
end
__gfx__
00000000dd6666dddd6666dddd6666dddd6666dddd6666dddd6666dddd6666dd5aa55aa55a776666666677766667777777777777000000000000000000000000
00000000d660066dd660066dd660066dd660066dd660066dd660066dd660066d9900990099ddddddd6ddccddddddcceeeeeeeeee000000000000000000000000
00700700660440556606605566033055660110556600005566022055660990559009900990dddd6dddddccddccddcceeeeeeeeee000000000000000000000000
00077000604749056067670560373b0560171c05600705056027280560979a050099009900d6ddddddd6ccddddddcceeeeeeeeee000000000000000000000000
0007700060449905606677056033bb056011cc0560005505602288056099aa0504400440045555555555ddd5555ddddddddddddd000000000000000000000000
007007006609905566077055660bb055660cc0556605505566088055660aa0550000000000000000000000000000000000000000000000000000000000000000
00000000d650055dd650055dd650055dd650055dd650055dd650055dd650055d0000000000000000000000000000000000000000000000000000000000000000
00000000dd5555dddd5555dddd5555dddd5555dddd5555dddd5555dddd5555dd0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000
00070000000070000007000000000000000700000000000000000700000070000000770000000000007777000000000000007700000000000000000000000000
00777000000077000077700000070000000770000077700000077700007770000007700000077700007777000007777000777700000770000000000000000000
00077000000070000077700000077000000770000007770000077000000770000007770000077000077777000007707000077000007770000000000000000000
00000000000000000000000000000000000000000000700000000000000000000000000000007000000770000000000000000000000770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1ddd1ddd1ddd11111111111111888111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d666d666d666d11111aaa11118000811000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d676d777d676d1111a7aaa1180700081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d666d666d666d1111aaa9a1180005081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d666d666d666d1111a999a1180555081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1ddd1ddd1ddd111111aaa11118000811000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111888111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaaaaeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeaaaaaaee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeee7eeeeeeaa7aaa9ae000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeeeeeeeeeeeeeeaa7aaa9ae000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeeeeeeeeeeeeeaaaaa99ae000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeee767eeeeeeeeeeeeeeeeeeee7eaaaa999ae000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee777eeeeeeeeeeeeeeeeeee7eea9999aee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee7777eeeeeeeeeeeeeeeeee77eeaaaaeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee777eeeee7eeeeeeeeeee777eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeee767eeeee7e7ee7ee7e77777777eeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeeeeeeeeee7777777eeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeee767ee7eeee7e77ee777777eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee7eee777eee77eee77ee77777eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeee767ee777eeeee77777eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeee7ee777ee777eeee7777eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee767ee77e7ee777eee7eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee77e7eeee767eeeeee777eee77eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee77eeee7ee767e77ee77ee7e77eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeee77e77ee7eeeeeeeee7eee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee7ee7e777eeee7777eeee777eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee77eeeeeeeeeee777eeee77777eee777ee7ee77e000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeee777777eeeeee77777777777eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
11111ee11111ee111111ee111ee1111111ee111ee111e11111111111000000000000000000000000000000000000000000000000000000000000000000000000
177771e177771e177771e17771e1771771e17771e177177117777771000000000000000000000000000000000000000000000000000000000000000000000000
1ddddd11ddddd11dddd11ddddd11dd1dd11ddddd11dd1dd11dddddd1000000000000000000000000000000000000000000000000000000000000000000000000
1dd1dd11dd1dd11dd1111dd1dd11dd1dd11dd1dd11dd1dd1111dd111000000000000000000000000000000000000000000000000000000000000000000000000
166661e166666116661e1666661166661e16616611661661ee1661ee000000000000000000000000000000000000000000000000000000000000000000000000
1666661166661e16661e1666661166661e16616611661661ee1661ee000000000000000000000000000000000000000000000000000000000000000000000000
1771771177177117711e1771771177177117717711771771ee1771ee000000000000000000000000000000000000000000000000000000000000000000000000
177777117717711777711771771177177117222222227221e22271ee000000000000000000000000000000000000000000000000000000000000000000000000
177771e177177117777117717711771771e1282828882882288821ee000000000000000000000000000000000000000000000000000000000000000000000000
11111ee1111111111111111e111111e111ee282828222828282821ee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee288882882888282282eee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeee2e2e22e22222e28282882282828282eeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee28282888282828882eeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeee2e2e22e222222222222222e222e222eeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000183601836018350183301832018310013002130021300213002130021300213001d7001c7001c7001b7001b7001b7001c7001d7001d7001d7001e7001e70000000000000000000000000000000000000
000100002436024360243502433024320243100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000204501e4501b450184501645013450104500d4500a4500745003450014500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a36030360303503033030300163001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c36032360323503233036300163001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002e36034360343503433035300163001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000303603636036350363303a300163001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000323603836038350383303c3003b3001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000343603a3603a3503a3303e3003b3001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000363603c3603c3503c3303f3003b3001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003946035460354503543030300163001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003a0503505030050290403b0503b0503b0501f0401d0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000028050280502f0302f03027020270202f0202f02028010280102f0102f01028010280152f0102f01028010280102e0002e000280002800000000000000000000000000000000000000000000000000000
010400003d6302d630206301c6301562013615106240f6150e6140d6150d614000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300003f6732d673396711f6511465112651116510f6530f6420f6320b6320a6320a63209632096320762203622036120361203612036120361503614036150361401615016140161501613000000000000000
010300002805128051310303103036030390301f0301f0302803128031310303103036030390301f0101f01028010280103101031010360103901010010100102801028010310103101036010390161001610016
00030000294202e4201d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e42012420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002805128051310303103036000390001f0001f0002800028000310003100036000390001f0001f00028000280003100031000360003900010000100002800028000310003100036000390001000010000
000200003105131051280302803036000390001f0001f0002800028000310003100036000390001f0001f00028000280003100031000360003900010000100002800028000310003100036000390001000010000
000100000c6100f6101061013610186101a610216102a6103e6203d6203c6203b62030620206201d61018610156100e6100b61009610066100461000000000000000000000000000000000000000000000000000
