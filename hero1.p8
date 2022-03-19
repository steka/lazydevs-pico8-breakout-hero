pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
--goals
-- 6. powerups
--     - speed down
--     - megaball
--     - multiball

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

 sticky=true

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

 sticky=true
 chain=1

 serveball()
end

function buildbricks(lvl)
 local i,j,o,chr,last
 brick_x={}
 brick_y={}
 brick_v={}
 brick_t={}

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
 pill_x={}
 pill_y={}
 pill_v={}
 pill_t={}
end

function addbrick(_i,_t)
 add(brick_x,4+((_i-1)%11)*(brick_w+2))
 add(brick_y,20+flr((_i-1)/11)*(brick_h+2))
 add(brick_v,true)
 add(brick_t,_t)
end

function levelfinished()
 if #brick_v == 0 then return true end

 for i=1,#brick_v do
  if brick_v[i] == true and brick_t[i] != "i" then
   return false
  end
 end
 return true
end

function serveball()
 ball_x=pad_x+flr(pad_w/2)
 ball_y=pad_y-ball_r
 ball_dx=1
 ball_dy=-1
 ball_ang=1
 pointsmult=1
 chain=1
 resetpills()

 sticky=true
 sticky_x=flr(pad_w/2)

 --0.50
 --1.30
 powerup=0
 powerup_t=0

end

function setang(ang)
 ball_ang=ang
 if ang==2 then
  ball_dx=0.50*sign(ball_dx)
  ball_dy=1.30*sign(ball_dy)
 elseif ang==0 then
  ball_dx=1.30*sign(ball_dx)
  ball_dy=0.50*sign(ball_dy)
 else
  ball_dx=1*sign(ball_dx)
  ball_dy=1*sign(ball_dy)
 end
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
  if sticky then
   ball_dx=-1
  end
 end
 if btn(1) then
  --right
  pad_dx=2.5
  buttpress=true
  --pad_x+=5
  if sticky then
   ball_dx=1
  end
 end
 if sticky and btnp(4) then
  sticky=false
  ball_x=mid(3,ball_x,124)
 end

 if not(buttpress) then
  pad_dx=pad_dx/1.3
 end
 pad_x+=pad_dx
 pad_x=mid(0,pad_x,127-pad_w)

 if sticky then
  --ball_x=pad_x+flr(pad_w/2)
  ball_x=pad_x+sticky_x
  ball_y=pad_y-ball_r-1
 else
  --regular ball physics
  nextx=ball_x+ball_dx
  nexty=ball_y+ball_dy

  --check if ball hit wall
  if nextx > 124 or nextx < 3 then
   nextx=mid(0,nextx,127)
   ball_dx = -ball_dx
   sfx(0)
  end
  if nexty < 10 then
   nexty=mid(0,nexty,127)
   ball_dy = -ball_dy
   sfx(0)
  end

  -- check if ball hit pad
  if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
   -- deal with collision
   if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
    --ball hit paddle on the side
    ball_dx = -ball_dx
    if ball_x < pad_x+pad_w/2 then
     nextx=pad_x-ball_r
    else
     nextx=pad_x+pad_w+ball_r
    end
   else
    --ball hit paddle on the top/bottom
    ball_dy = -ball_dy
    if ball_y > pad_y then
     --bottom
     nexty=pad_y+pad_h+ball_r
    else
     --top
     nexty=pad_y-ball_r
     if abs(pad_dx)>2 then
      --change angle
      if sign(pad_dx)==sign(ball_dx) then
       --flatten angle
       setang(mid(0,ball_ang-1,2))
      else
       --raise angle
       if ball_ang==2 then
        ball_dx=-ball_dx
       else
        setang(mid(0,ball_ang+1,2))
       end
      end
     end
    end
   end
   sfx(1)
   chain=1

   --catch powerup
   if powerup==3 and ball_dy < 0 then
    sticky = true
    sticky_x = ball_x-pad_x
   end
  end

  brickhit=false
  for i=1,#brick_x do
   -- check if ball hit brick
   if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
    -- deal with collision
    if not(brickhit) then
     if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
      ball_dx = -ball_dx
     else
      ball_dy = -ball_dy
     end
    end
    brickhit=true
    hitbrick(i,true)
   end
  end
  ball_x=nextx
  ball_y=nexty

  -- check if ball left screen
  if nexty > 127 then
   sfx(2)
   lives-=1
   if lives<0 then
    gameover()
   else
    serveball()
   end
  end

 end -- end of sticky if

 -- move pills
 -- check collision for pills
 for i=1,#pill_x do
  if pill_v[i] then
   pill_y[i]+=0.7
   if pill_y[i] > 128 then
    pill_v[i]=false
   end
   if box_box(pill_x[i],pill_y[i],8,6,pad_x,pad_y,pad_w,pad_h) then
    powerupget(pill_t[i])
    pill_v[i]=false
    sfx(11)
   end
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

function powerupget(_p)
 if _p == 1 then
  -- slowdown
  powerup = 1
  powerup_t = 0
 elseif _p == 2 then
  -- life
  powerup = 0
  powerup_t = 0
  lives+=1
 elseif _p == 3 then
  -- catch
  powerup = 3
  powerup_t = 900
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
  powerup_t = 0
 elseif _p == 7 then
  -- multiball
  powerup = 7
  powerup_t = 0
 end
end

function hitbrick(_i,_combo)
 if brick_t[_i]=="b" then
  sfx(2+chain)
  brick_v[_i]=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
 elseif brick_t[_i]=="i" then
  sfx(10)
 elseif brick_t[_i]=="h" then
  sfx(10)
  brick_t[_i]="b"
 elseif brick_t[_i]=="p" then
  sfx(2+chain)
  brick_v[_i]=false
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
  spawnpill(brick_x[_i],brick_y[_i])
 elseif brick_t[_i]=="s" then
  sfx(2+chain)
  brick_t[_i]="zz"
  if _combo then
   points+=10*chain*pointsmult
   chain+=1
   chain=mid(1,chain,7)
  end
 end
end

function spawnpill(_x,_y)
 local _t

 _t = flr(rnd(7))+1
 _t = 5
 add(pill_x,_x)
 add(pill_y,_y)
 add(pill_v,true)
 add(pill_t,_t)

 --pill_x[#pill_x+1]=_x
 --pill_y[#pill_x]=_y
 --pill_v[#pill_x]=true
 --pill_t[#pill_x]=_t
end

function checkexplosions()
 for i=1,#brick_x do
  if brick_t[i] == "zz" then
   brick_t[i]="z"
  end
 end

 for i=1,#brick_x do
  if brick_t[i] == "z" then
   explodebrick(i)
  end
 end

 for i=1,#brick_x do
  if brick_t[i] == "zz" then
   brick_t[i]="z"
  end
 end
end

function explodebrick(_i)
 brick_v[_i]=false
 for j=1,#brick_x do
  if j!=_i
  and brick_v[j]
  and abs(brick_x[j]-brick_x[_i]) <= (brick_w+2)
  and abs(brick_y[j]-brick_y[_i]) <= (brick_h+2)
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
 circfill(ball_x,ball_y,ball_r, 10)
 if sticky then
  -- serve preview
  line(ball_x+ball_dx*4,ball_y+ball_dy*4,ball_x+ball_dx*6,ball_y+ball_dy*6,10)
 end

 rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)

 --draw bricks
 for i=1,#brick_x do
  if brick_v[i] then
   if brick_t[i] == "b" then
    brickcol = 14
   elseif brick_t[i] == "i" then
    brickcol = 6
   elseif brick_t[i] == "h" then
    brickcol = 15
   elseif brick_t[i] == "s" then
    brickcol = 9
   elseif brick_t[i] == "p" then
    brickcol = 12
   elseif brick_t[i] == "z" or brick_t[i] == "zz" then
    brickcol = 8
   end
   rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,brickcol)
  end
 end

 for i=1,#pill_x do
  if pill_v[i] then
   if pill_t[i]==5 then
    palt(0,false)
    palt(15,true)
   end
   spr(pill_t[i],pill_x[i],pill_y[i])
   palt()
  end
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
