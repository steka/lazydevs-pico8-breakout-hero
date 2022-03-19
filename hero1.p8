pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--goals
-- 6. multiball
--    - maybe just 2 multball
--    - split random ball
--    - release copied ball
--    - slowdown - timer
--    - expand - timer, cancels reduce
--    - reduce - timer, cancels expand
--    - megaball - timer

-- 7. juicyness
--     arrow anim
--     text blinking
--     particles
--     screenshake
-- 8. high score
-- 9. better collision
-- 10. gameplay tweaks
--     - smaller paddle

function _init()
 cls()
 mode="start"
 level=""
 debug=""
 levelnum = 1
 levels={}
 --levels[1] = "x5b"
 levels[1] = "b9b/p9p"
 --levels[1] = "hxixsxpxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxbxb"
 --levels[1] = "////x4b/s9s"
end

function _update60()
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="gameover" then
  update_gameover()
 elseif mode=="levelover" then
  update_levelover()
 end
end

function update_start()
 if btnp(4) then
  startgame()
 end
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

 lives=3
 points=0
 sticky = false

 chain=1 --combo chain multiplier

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
 resetpills()

 sticky_x=flr(pad_w/2)

 --0.50
 --1.30
 powerup=0
 powerup_t=0
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
 ball2 = copyball(ball[1])
 ball3 = copyball(ball[1])

 if ball[1].ang==0 then
  setang(ball2,1)
  setang(ball3,2)
 elseif ball[1].ang==1 then
  setang(ball2,0)
  setang(ball3,2)
 else
  setang(ball2,0)
  setang(ball3,1)
 end

 ball[#ball+1]=ball2
 ball[#ball+1]=ball3
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
 mode="gameover"
end

function levelover()
 mode="levelover"
end

function update_gameover()
 if btnp(4) then
  startgame()
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

 if powerup == 4 then
  -- check if pad should grow
  pad_w = flr(pad_wo * 1.5)
 elseif powerup == 5 then
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

 if powerup!=0 then
  powerup_t-=1
  --debug = powerup_t
  if powerup_t<=0 then
   powerup=0
  end
 end

end

function updateball(bi)
 myball = ball[bi]
 if myball.stuck then
  --ball_x=pad_x+flr(pad_w/2)
  myball.x=pad_x+sticky_x
  myball.y=pad_y-ball_r-1
 else
  --regular ball physics
  if powerup==1 then
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
     if (powerup == 6 and bricks[i].t=="i")
     or powerup != 6 then
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

  -- check if ball left screen
  if nexty > 127 then
   sfx(2)
   if #ball > 1 then
    del(ball,myball)
   else
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
  powerup = 1
  powerup_t = 900
 elseif _p == 2 then
  -- life
  powerup = 0
  powerup_t = 0
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
  powerup = 4
  powerup_t = 900
 elseif _p == 5 then
  -- reduce
  powerup = 5
  powerup_t = 900
 elseif _p == 6 then
  -- megaball
  powerup = 6
  powerup_t = 900
 elseif _p == 7 then
  -- multiball
  releasestuck()
  multiball()
 end
end

function hitbrick(_i,_combo)
 if bricks[_i].t=="b" then
  sfx(2+chain)
  bricks[_i].v=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
 elseif bricks[_i].t=="i" then
  sfx(10)
 elseif bricks[_i].t=="h" then
  if powerup==6 then
   sfx(2+chain)
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
  sfx(2+chain)
  bricks[_i].v=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
  spawnpill(bricks[_i].x,bricks[_i].y)
 elseif bricks[_i].t=="s" then
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

 --_t = flr(rnd(7))+1
 _t = flr(rnd(2))
 if _t== 0 then
  _t = 7
 else
  _t = 3
 end


 _pill={}
 _pill.x = _x
 _pill.y = _y
 _pill.t = _t
 add(pill,_pill)
end

function checkexplosions()
 for i=1,#bricks do
  if bricks[i].t == "zz" then
   bricks[i].t="z"
  end
 end

 for i=1,#bricks do
  if bricks[i].t == "z" then
   explodebrick(i)
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

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="gameover" then
  draw_gameover()
 elseif mode=="levelover" then
  draw_levelover()
 end
end

function draw_start()
 cls()
 print("pico hero breakout",30,40,7)
 print("press ❎ to start",32,80,11)
end

function draw_gameover()
 rectfill(0,60,128,75,0)
 print("game over",46,62,7)
 print("press ❎ to restart",27,68,6)
end

function draw_levelover()
 rectfill(0,60,128,75,0)
 print("stage clear!",46,62,7)
 print("press ❎ to continue",27,68,6)
end

function draw_game()
 local i

 cls(1)
 for i=1,#ball do
  circfill(ball[i].x,ball[i].y,ball_r, 10)
  if ball[i].stuck then
   line(ball[i].x+ball[i].dx*4,ball[i].y+ball[i].dy*4,ball[i].x+ball[i].dx*6,ball[i].y+ball[i].dy*6,10)
  end
 end

 rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)

 --draw bricks
 for i=1,#bricks do
  if bricks[i].v then
   if bricks[i].t == "b" then
    brickcol = 14
   elseif bricks[i].t == "i" then
    brickcol = 6
   elseif bricks[i].t == "h" then
    brickcol = 15
   elseif bricks[i].t == "s" then
    brickcol = 9
   elseif bricks[i].t == "p" then
    brickcol = 12
   elseif bricks[i].t == "z" or bricks[i].t == "zz" then
    brickcol = 8
   end
   rectfill(bricks[i].x,bricks[i].y,bricks[i].x+brick_w,bricks[i].y+brick_h,brickcol)
  end
 end

 for i=1,#pill do
  if pill[i].t==5 then
   palt(0,false)
   palt(15,true)
  end
  spr(pill[i].t,pill[i].x,pill[i].y)
  palt()
 end

 rectfill(0,0,128,6,0)
 if debug!="" then
  print(debug,1,1,7)
 else
  print("lives:"..lives,1,1,7)
  print("score:"..points,40,1,7)
  print("chain:"..chain.."x",100,1,7)
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
