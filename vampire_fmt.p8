pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--demon castle
--by mush
a={b=0,c=0,d=8,e=8,f=0,g=0,h=2,i=0,j=1,k=0}
function a:l(m)
self.__index=self
return setmetatable(m or{},self)
end
function a:n() end
function a:o() end
function a:p()
if self.q then return end
if self.r then
if self.pal then
self:s()
end
spr(self.r,self.b,self.c,1,1,self.t)
pal()
end
if self.u then
for r in all(self.u) do
r:p()
end
end
end
function a:s()
for v=1,7 do
pal(w[v],self.pal[v])
end
end
function a:x(y)
local m,z=ba(self.b,self.c+self.e+1),ba(self.b+self.d-1,self.c+self.e+1)
if y then return m and z else return m or z end
end
function a:bb()
self.c+=self.f
self.f=min(self.f,bc)
if self.bd then
self.f+=self.be
self.f=mid(-self.bf,self.f,self.bf)
else
self.f+=be
end
if not self.bg then
if self:bh() then
if self.f>0 then
local bi=self.c+self.e
bi=flr(bi/8)*8
self.c=bi-self.e
else
self.c=flr(self.c/8)*8+8
end
self.f=0
end
end
end
function a:bh()
bj={}
for v=self.b,self.b+self.d-1,8 do
add(bj,v)
end
add(bj,self.b+self.d-1)
bk={}
for v=self.c,self.c+self.e-1,8 do
add(bk,v)
end
add(bk,self.c+self.e-1)
for v in all(bj) do
for bl in all(bk) do
if ba(v,bl) then
return true
end
end
end
return false
end
function a:bm()
self.g+=self.i
self.g=bn(0,self.g,self.j)
self.g=mid(-self.h,self.g,self.h)
self.b+=self.g
if not self.bg then
if self:bh() then
self.b=flr(self.b)
while self:bh() do
if self.g>0 then
self.b-=1
else
self.b+=1
end
end
self.g=0
end
end
end
function a:bo()
self:bm()
self:bb()
end
function a:bp()
self.u={}
end
function a:bq()
if not self.u then return end
for r in all(self.u) do
r:n()
end
end
function a:br(m)
if not self.u then return end
add(self.u,m)
m.bs,m.pal=self,self.pal
end
function a:bt()
if not self.bs then return end
self.b=self.bs.b
self.c=self.bs.c
end
function a:bu()
return self.b<bv.b-self.d-32 or self.b>bv.b+128+32
end
function a:bw()
return self.b+self.d>=bv.b and self.b<bv.b+128 and self.c+self.e>=bv.c and self.c<bv.c+112
end
function a:bx(m)
if self.b+self.d<m.b then return false end
if m.b+m.d<self.b then return false end
if self.c+self.e<m.c then return false end
if m.c+m.e<self.c then return false end
return true
end
function a:by(z,bz)
if self:bx(z) then
if not self.r or not z.r then
return true
end
rectfill(0,0,16,8,0)
spr(self.r,0,0,1,1,self.t)
spr(z.r,8,0,1,1,z.t)
ca,cb=z.b-self.b,z.c-self.c
for b=max(0,ca),min(7,7+ca) do
for c=max(0,cb),min(7,7+cb) do
cc,cd=pget(b,c),pget(8+b-ca,c-cb)
if cc!=0 and cd!=0 then
return true
end
end
end
end
if z.u and bz then
for m in all(z.u) do
if m.ce and self:by(m,bz) then return true end
end
end
return false
end
function a:cf(cg)
if self.bs then
self.bs:cf(cg)
end
end
function a:ch()
if self.ci==1 then
self.pal=cj
end
end
function a:ck()
cl(ck:l({b=self.b+rnd(self.d),c=self.c+rnd(self.e)}))
end
function a:cm()
if self.cn then
self.cn+=co
self.cp+=co
end
return self
end
bv=a:l({cq=0.5,cr=true,b=896})
function bv:n()
if cs.ct then
self.cq=0.5
local cu=self.c
self:cv()
if self.c!=cu then
cw=40
self:cx()
if not cy then
cs:cz()
end
end
else
self.cq=2
end
self:da()
self.b=bn(self.db,self.b,self.cq)
if self.b<=0 then
self.b=0
end
for m in all(dc) do
if(m.c>=bv.c and m.c<bv.c+112) m:dd()
if(m.de) del(dc,m)
end
end
function bv:da()
if self.df then
self.df=false
else
self.db=cs.b-60
end
end
function bv:cx()
self:da()
self.b=self.db
end
function bv:cv()
if cs.c<=104 then
self.c=0
else
self.c=112
end
end
function bv:dg()
camera(self.b,self.c-16)
if not dh then
clip(0,0,128,112)
camera(self.b,self.c)
end
end
cs=a:l({r=0,e=14,j=0.5,h=1,di=0,
dj=0,dk=0,dl=0,
dm=0,dn=0,cr=true,
dp=0})
function cs:n()
self.dq,self.dr,self.pal=self.b,self.c,ds
if self.cp<=0 then
self:ck()
end
if self.dm==0 and self.dn>0 then
self:dt()
end
if self.dm==0 and self.dn==0 then
self.q=false
end
if not self.ct then
if self.dm==0 then
if self.cp>0 then
if btn(1) and not btn(0) then
self.i=1
if self.dk==0 then
self.t=false
end
elseif btn(0) and not btn(1) then
self.i=-1
if self.dk==0 then
self.t=true
end
else
self.i=0
end
if self:x() and du and not dh then
self.f=-dv
end
end
self:bo()
if abs(self.g)<0.1 then
self.di=1.9
end
if self:x() and btn(2) then
self:dw()
elseif self:x() and btn(3) and dx==0 then
self:dy()
end
else
self:dz()
self:bo()
end
end
if self.ct then
if self.dm>0 then
self:dt()
end
self.g=0
local ea,eb=1,0
if self.ec then
ea,eb=0,1
end
if self.cp>0 then
if btn(2) and not btn(3) then
self.dj+=1
self.t=self.ec
elseif(btn(3) and not btn(2) or btn(eb)) and dx==0 then
self.dj-=1
self.t=not self.ec
elseif btn(ea) then
self.dj+=1
self.t=self.ec
end
end
if self.dj>=6 then
self.dj=0
self.c-=2
if self.t then
self.b-=2
else
self.b+=2
end
self.di+=1
if self.c%4==0 then
sfx(5)
else
sfx(6)
end
elseif self.dj<=-6 then
self.dj=0
self.c+=2
if self.t then
self.b-=2
else
self.b+=2
end
self.di+=1
if self.c%4==0 then
sfx(5)
else
sfx(7)
end
end
self:ed()
end
if ee and self.dk==0 and self.dl==0 and self.cp>0 and not dh then
self.dk=0.1
sfx(4)
end
if self:x() then
self.di+=abs(self.g)/10
end
self.di=self.di%4
self.r=flr(self.di)
if self.r==3 then
self.r=1
end
self.dp=self.r
if self.dl>0 then
self.dl-=1
self.r=6
if self.dl<=0 then
self.dk=0
end
else
if self.dk>0 then
self.dk+=0.25
if self.dk>=4 then
self.dl=10
self.r=6
else
self.r=3+flr(self.dk)
end
end
end
if self.ct then
if self.c<-8 then
self.c+=224
self.b+=ef*8
bv:cx()
elseif self.c>224-8 then
self.c-=224
self.b-=ef*8
bv:cx()
end
end
if self.b<bv.b then
self.b=bv.b
end
if not self.ct and self.c>=bv.c+104 then
self.cp=0
end
if self.cp<=0 and self.dm==0 then
eg=eg or 90
eh(5)
self.q,self.g,self.i=true,0,0
end
self:bq()
end
function cs:cz()
ei,ej,ek,el,em=self.b,self.c,self.ct,self.t,self.ec
end
function cs:x()
for m in all(en) do
if m.eo then
return true
end
end
return a.x(self)
end
function cs:dy()
local ep,eq=flr((self.b+4)/8),flr((self.c+16)/8)
for add=-1,1 do
er=ep+add
local es=et(er,eq,1)
local eu=et(er,eq,2)
if es and not(eu and add==-1) and not(not eu and add==1) then
self.ct=true
self.b=er*8
self.c=eq*8-14
if eu then
self.b-=2
else
self.b+=2
end
self.di=1
self.ec=eu
self.t=not eu
self.dj=-10
end
end
end
function cs:dw()
local ep,eq=flr((self.b+4)/8),flr((self.c+10)/8)
for add=-1,1 do
er=ep+add
local es=et(er,eq,1)
local eu=et(er,eq,2)
if es and not(eu and add==1) and not(not eu and add==-1) then
self.ct=true
self.b=er*8
self.c=eq*8-6
if eu then
self.b+=6
else
self.b-=6
end
self.di=1
self.ec=eu
self.t=eu
self.dj=10
end
end
end
function cs:ed()
if self.c%8!=2 then return end
if self.c>=208 then return end
if self.c<0 then return end
local er,ev=self.b+4,self.c+8
if self.ec==self.t then
if not self.ec then
er+=8
else
er-=8
end
else
ev+=8
end
if not ew(er,ev,1) then
self.ct=false
end
end
ex=a:l({r=16,e=6,ce=true})
function ex:n()
self:bt()
self.pal=self.bs.pal
self.c+=8
self.t=self.bs.t
self.r=16+self.bs.dp%2
if self.r==16 and self.bs.ct then
self.r+=2
if self.bs.t!=self.bs.ec then
self.r+=1
end
end
if not self.bs:x() and not self.bs.ct then
self.r=20
end
end
function cs:cf(cg)
if self.dm==0 and self.dn==0 and self.cp>0 then
sfx(12)
self.cp-=1
self.dm,self.dn=24,24
if not self.ct then
self.f,self.i=-1.5,0
end
if cg.b>self.b then
self.g,self.t=-0.5,false
else
self.g,self.t=0.5,true
end
end
end
function cs:dz()
if self.g>0 then
self.g=self.h
else
self.g=-self.h
end
self:dt()
end
function cs:dt()
if self.dm>0 then
self.dm-=1
self.pal=ey
else
self.dn-=1
end
self.q=not self.q
end
ez=a:l({r=32,fa=0,fb=2,fc=0,d=3,e=3})
function ez:n()
self.dq=self.b
self.dr=self.c
if self.bs==cs then
self:bt()
local fd=-4
local fe=3
if cs.r==4 then
fd=-1
fe=-1
elseif cs.r==5 then
fd=3
elseif cs.r==6 then
fd=4
fe=6
end
self.fa=0.5-cs.dk/8
self.fc=0.0625-cs.dk/64
if cs.dl>0 then
self.fc=0
self.fa=0
end
if cs.t then
self.fa=-(self.fa-0.25)+0.25
self.fc=-self.fc
fd=-fd
end
self.b+=3+fd
self.c+=fe
self.q=cs.dk<=0
else
self.fc=self.bs.fc
self.fa=self.bs.fa+self.fc
self.fb=self.bs.fb
self.q=self.bs.q
self:bt()
self.b+=self.fb*cos(self.fa)
self.c+=self.fb*sin(self.fa)
end
if not self.q then
for m in all(en) do
if m.ff and self:by(m,true) and cs.cp>0 then
m:cf(cs)
elseif m.fg and self:by(m) then
m:fh()
end
end
end
self:bq()
end
function ez:fi(fj)
self.fj=fj
if fj>0 then
self:bp()
local fk=ez:l()
fk:fi(fj-1)
self:br(fk)
end
end
ff=a:l({ff=true,cp=1,ci=1,j=0,fl=0.25,t=true,dm=0})
function ff:dz()
if self:x() then
self.dm-=0.5
if self.cp>0 then
self.dm-=0.5
end
self.h=self.fl
else
self.h=1
if self.g>0 then
self.g=self.h
else
self.g=-self.h
end
end
self.pal=ey
self.q=not self.q
if self.cp<=0 then
self:ck()
end
end
function ff:cf(cg)
if self.cp<=0 then
return
end
if self.dm==0 then
self.cp-=1
self.dm=12
self.f=-1.5
self.i=0
if not self.fm then
if cg.b>self.b then
self.g=-0.5
self.t=false
else
self.g=0.5
self.t=true
end
end
if self.cp<=0 and self.fn then
sfx(self.fn)
elseif self.fo then
sfx(self.fo)
end
end
end
function ff:fp()
if self.cp<=0 then
self.de=true
end
return not self.de
end
function a:fq(fr)
if fr or(self.dm==0 and self.cp>0) then
if self:by(cs,true) then
cs:cf(self)
return true
end
if self.u then
for m in all(self.u) do
m:fq(true)
end
end
end
end
function ff:fs()
fs,ft=self.cp,self.cn
end
fu=ff:l({r=15,e=14,fv=0.05,fn=9})
function fu:o()
self:bp()
self:br(fw:l())
self:ch()
self.c+=2
self.t=true
self:bq()
end
function fu:n()
if self:bu() then
self:bq()
return
end
if self.dm>0 then
self:dz()
else
if self:fp() then
self.q=false
self.h=self.fl
self.i=0.1
if self.t then
self.i=-0.1
end
self:ch()
end
end
self:bo()
if self.dm<=0 then
if abs(self.g)<=0 or not(self:x(true) and self.f>=0) then
self:fx()
end
self:fq()
end
self:bq()
end
function fu:fx()
self.t=not self.t
self.g=-self.g
end
fw=ff:l({di=0,ff=true,ce=true})
function fw:n()
self:bt()
self.c+=8
self.t=self.bs.t
self.di+=self.bs.fv
self.di=self.di%2
self.r=30+self.di
self.pal=self.bs.pal
end
ck=a:l({fy=3,cr=true})
function ck:n()
self.c-=0.5
self.fy-=0.4
if self.fy<=0 then
self.de=true
end
end
function ck:p()
circfill(self.b,self.c,self.fy,7)
end
fz=ff:l({r=26,bd=true,bg=true,bf=1,fl=1,fo=10,ga=0})
function fz:o()
self:ch()
end
function fz:n()
if self:bu() then return end
if self.dm>0 then
if not self:bh() then
self.bg=false
end
self.bd=false
self:dz()
self:bo()
self:gb()
else
self.bg=true
self.bd=true
self.q=false
self:ch()
if self:fp() then
if self.gc then
self.t=self.b>cs.b
if self.t then
self.i=-0.05
else
self.i=0.05
end
if self.c>cs.c then
self.be=-0.05
else
self.be=0.05
end
self:bo()
self:fq()
self:gb()
end
local gd,ge=abs(self.b-cs.b),abs(self.c-cs.c)
if sqrt(gd*gd+ge*ge)<32 then
self.gc=true
end
end
end
if self.c<bv.c+4 then
self.c=bv.c+4
end
end
function fz:gb()
self.ga=(self.ga+0.2)%2
self.r=27+self.ga
end
gf=fz:l({cp=6,r=194,fn=13,cn=6})
function gf:n()
fz.n(self)
self:gb()
if self.gc then
if self.b<=bv.b and self.b>bv.b-8 then
self.b=bv.b
end
self.b=min(self.b,bv.b+120)
end
self:bq()
if gg==2 or gg==6 then
self:fs()
end
end
function gf:o()
self:ch()
self.ga=0
self:bp()
self:br(gh:l())
self:br(gh:l({t=false}))
self:bq()
end
function gf:gb()
self.ga=(self.ga+0.1)%2
self.gi=192+self.ga
self:bq()
end
gh=ff:l()
function gh:n()
self:bt()
self.r,self.pal=self.bs.gi,self.bs.pal
if self.t then
self.b+=8
else
self.b-=8
end
end
gj=ff:l({r=29,cp=3,gk=true,gl=0,fn=11})
function gj:n()
if self.dm>0 then
self:dz()
else
self:ch()
if self:fp() then
self:fq()
if not self:bu() then
self.gl+=1
if self.gl>120 then
local t=gm:l({b=self.b,c=self.c+3,gn=self.t})
cl(t)
t:n()
self.gl=0
end
end
end
end
self.t=self.gk
end
gm=a:l({r=34,g=1,e=4})
function gm:n()
self:gb()
self:ch()
if self:bu() then
self.de=true
end
if self.gn then
self.b-=self.g
else
self.b+=self.g
end
if self:by(cs,true) then
cs:cf(self)
self.de=true
end
end
function gm:gb()
self.r,self.t=84-self.r,self.gn
end
go=gm:l({r=41,gl=0,ci=1,g=1,gp=1})
function go:gb()
self.gl+=1
if self.gl>6 then
self.r+=self.gp
if self.r==44 or self.r==40 then
self.t=not self.t
self.gp*=-1
end
self.gl=0
end
self:ch()
end
gq=ff:l({r=8,e=16,cp=5,cn=5,fl=0.5,gr=32,gs=0,gt=0,fn=11})
function gq:o()
self:bp()
self:br(gu:l())
self:br(gv:l())
self:bq()
end
function gq:n()
if self:bw() then
if self.dm<=0 then
if self:fp() then
self.q=false
self:ch()
self.h=self.fl
if self.b>cs.b then
self.t,self.i=true,-0.02
else
self.t,self.i=false,0.02
end
local fb=abs(self.b-cs.b)
if fb<self.gr then
self.i*=-1
end
if self.gt>0 then
self.gt-=1
if self.gt==11 then
local t=go:l({b=self.b,c=self.c+3,gn=self.t})
cl(t)
t:n()
self.gs=60
end
else
if self.gs==0 then
self.gt=15
end
self.gs=max(0,self.gs-rnd(2))
end
self:fq()
end
else
self:dz()
end
self:bm()
self:bq()
end
if gg==3 then
self:fs()
end
end
gu=ff:l({r=24,gl=0,ci=1})
function gu:n()
self:bt()
self.c+=8
self.t,self.q,self.pal=self.bs.t,self.bs.q,self.bs.pal
self.gl+=abs(self.bs.g)
if self.gl>4 then
self.gl,self.r=0,49-self.r
end
end
gv=ff:l()
function gv:n()
self:bt()
self.t,self.q,self.pal=self.bs.t,self.bs.q,self.bs.pal
local gw=6
if self.t then gw*=-1 end
self.b+=gw
if self.bs.gt>10 then
self.r=9
elseif self.bs.gt>0 then
self.r=10
self.c+=1
else
self.q=true
end
end
gx=ff:l({r=13,gl=0,bg=true,fo=10,cr=true})
function gx:o()
self.b=bv.b+127
self.gy=max(cs.c+rnd(16)-8,bv.c+16)
self.c=self.gy
if rnd(10)<5 then
self.gl=0.5
end
end
function gx:n()
if self:bu() then
self.de=true
end
if self.dm>0 then
self:dz()
self:bo()
else
self:ch()
if self:fp() then
self:fq()
end
self.b-=1
self.gl=(self.gl+0.01)%1
self.c=self.gy+sin(self.gl)*12
end
end
gz=a:l({gl=60})
function gz:n()
if cs.b<self.b and cs.b>self.b-256 then
self.gl+=1
if self.gl>=90 then
self.gl=0
local ha=gx:l()
ha:o()
cl(ha)
end
end
end
hb=ff:l({r=11,fo=10,cp=3,hc=1})
function hb:n()
if(not self:bw()) return
self.r=11
if self.dm>0 then
self:dz()
self:bo()
else
self.q=false
self:ch()
self.h=2
if self:fp() then
if self:x() then
self.g=0
self.hc-=0.1
if self.hc<=-2 or rnd(100)<5 then
self.f,self.g,self.hc=self.hc,self.hc/2,0
if(cs.b>self.b) self.g*=-1
if(rnd(9)<2) self.g*=-1
end
else
self.r=12
end
self:bo()
self:fq()
end
end
end
hd=hb:l({cp=6,r=208,fn=13,cn=6,e=16,d=16})
function hd:o(he)
self:bp()
self:br(hf:l():flip())
self:br(hg:l():o(he))
self:fs()
end
function hd:n()
hb.n(self)
self.b=max(self.b,bv.b+1)
self.r+=197
self.t=false
self:bq()
self:fs()
end
hg=ff:l({ce=true})
function hg:o(he)
self:bp()
self:br(hf:l())
if(he) self:br(hg:l():o())
return self
end
function hg:n()
self:bt()
self.r,self.pal,self.q,self.bs.fm=self.bs.r+16,self.bs.pal,self.bs.q,true
self.c+=8
self:bq()
end
hh=ff:l({r=229,cp=6,cn=6,d=16,e=16,gl=0,q=true})
function hh:o()
hd.o(self)
end
function hh:n()
self:fs()
if(self:bu()) return
dx=8
self.gl+=1
if self.gl>20 then
self.gl,self.r=0,459-self.r
end
if self.dm>0 then
self:dz()
self:bb()
self.cp=0
else
self.c,self.q=176+sin(hi)*3,false
if self:fp() then
self:fq()
else
hj=hk:l():o()
cl(hj)
eh(24)
end
end
self.t=false
self:bq()
end
hk=ff:l({r=210,cp=9,cn=9,gl=0,d=16,e=24,b=400,c=128})
function hk:o()
hd.o(self,true)
self:br(hl:l())
self:br(hl:l({t=false}))
return self
end
function hk:n()
self:fs()
if(self:bu()) return
if self.cp<=0 then
self.gl,self.r=bn(0.25,self.gl,0.01),212
self:hm()
eh(-1)
if self.gl==0.25 then
hn=true
if(ho>=3) hp=true
end
elseif self.dm>0 then
self.dm-=1
self.q=not self.q
else
dx=min(dx+0.5,46)
self.q=dx<46
if not self.q and not eg then
self.gl=(self.gl+0.008)%1
self.r=210+self.gl*2
self:hm()
self:fq()
end
end
self.t=false
self:bq()
end
function hk:hm()
if(hn) return
self.c=140+max(-0.5,sin(self.gl))*30
end
hl=ff:l({r=240})
function hl:n()
local ha=-1
if(self.t) ha=1
local gl=self.bs.gl*2+0.4*ha
self:bt()
self.b+=ha*(cos(gl)*-15+16)+4
self.c+=cos(gl)*8+20
end
hq=a:l({r=58,cr=true})
function hq:n()
local gl=hr+self.hs/3
if ht then
self.r=55
self:bb()
else
local hu=dx-3*sin(hi)
self.b,self.c=bv.b+60+sin(gl)*hu,bv.c+34+cos(gl)*hu
end
end
hv=a:l({d=16,e=3,r=48,cq=0.005,hw=0,hx=0})
function hv:o()
self.hy,self.hz,self.ia=self.b,self.c,0
self:bp()
self:br(hf:l())
end
function hv:n()
self.eo=false
if cs.b>self.b-8 and cs.b<self.b+self.d then
if cs.c+cs.e>=self.c and cs.dr+cs.e<=self.c+self.e then
cs.c,cs.f=self.c-14,0
self.eo=true
end
end
local dq,dr=self.b,self.c
self:hm()
if self.eo then
ib,ic=cs.b,cs.c
cs.b+=self.b-dq
cs.c+=self.c-dr
if cs:bh() then
cs.b,cs.c=ib,ic
end
cs:bq()
end
self:bq()
end
function hv:p()
local dq=self.b
if self.eo then
self.b=cs.b-flr(cs.b-self.b)
self:bq()
end
a.p(self)
self.b=dq
self:bq()
end
function hv:hm()
self.ia=(self.ia+self.cq)%1
self.b,self.c=self.hy+self.hw*sin(self.ia),self.hz+self.hx*sin(self.ia)
end
id=hv:l({hw=0,hx=0,cq=0.003})
function id:o()
hv.o(self)
self.fj=self.c-self:ie()
end
function id:hm()
self.ia=(self.ia+self.cq)%1
local ig=sin(self.ia)/15
self.b,self.c=self.hy+self.fj*sin(ig),self:ie()+self.fj*cos(ig)
end
function id:p()
for v=-1,1 do
line(self.hy+8+v,self:ie(),self.b+8+v,self.c+8,6-abs(v))
end
for v=0,1 do
circfill(self.b+8,self.c+6,10-v*3,9+v)
end
end
function id:ie()
return self.c-self.c%112
end
ih=a:l()
function ih:o()
add(dc,self)
end
function ih:dd()
if(self.ii and cs.c>self.c+16) return
if self.b+8>=cs.b then
bv.b=min(bv.b,self.b-120)
else
self:ij()
end
end
function ih:ij()
if self:bw() and abs(self.b-cs.b)<16 then
self.de=true
end
end
ik=ih:l()
function ik:dd()
if self.b<=cs.b then
bv.b=max(bv.b,self.b)
else
self:ij()
end
end
il=ik:l()
function il:dd()
if(cs.b>=self.b) or self.im then
bv.db,bv.df,self.im=self.b,true,true
if not io and not eg then
eh(6)
end
end
end
hf=a:l({ce=true})
function hf:n()
self:bt()
self.b+=8
self.r,self.pal,self.q=self.bs.r,self.bs.pal,self.bs.q
end
function hf:flip()
self.t=true
return self
end
ip=a:l({r=61,f=-2,q=true})
function ip:o()
self.c+=8
end
function ip:n()
if not self:bh() then
self.q=false
self:bb()
if self:by(cs,true) then
cs.cp,self.de=iq,true
sfx(2)
end
end
end
ir=a:l({fg=true,is=49})
function ir:o()
if(gg==2) mset(self.b/8,self.c/8,64)
end
function ir:fh()
mset(self.b/8,self.c/8,0)
self.de=true
for v=0,1 do
for bl=0,1 do
cl(it:l({r=self.is,b=self.b+v*4,c=self.c+bl*4,f=-2+bl,i=(v-0.5)/8,t=v==bl}))
end
end
for m in all(dc) do
if m.b==self.b then
m.de=true
end
end
sfx(8)
end
it=a:l({iu=30,d=4,e=4,j=0,bg=true,cr=true})
function it:n()
self:bo()
self.iu-=1
if self.iu<=0 then
self.de=true
end
end
iv=a:l({r=57,q=true,f=-2})
function iv:o()
self.b-=36
end
function iv:n()
if not self:bw() then return end
if self.q then
if bv.b>self.b-80 or self.fr then
self.q=false
for m in all(en) do
if m.ff and m:bw() then
self.q=true
end
end
if not self.q then
self:iw()
end
end
else
self:bb()
if self.f<0 then
self:ck()
end
if self:by(cs,true) then
self.de=true
self:ix()
end
end
end
function iv:ix()
sfx(3)
iy=true
io=true
eh(-1)
end
function iv:iw() end
iz=iv:l({r=58,fr=true})
function iz:ix()
sfx(3)
ho+=1
ja=true
end
function iz:iw()
if ja then
self.de=true
cl(ip:l({b=self.b,c=self.c}))
end
end
jb=iz:l({r=56})
function jb:ix()
sfx(3)
jc,ja=true,true
end
jd=a:l()
function jd:n()
if(not self:bw()) return
self.je=jf
if self.jg then
self.je=jh
end
if abs(self.c-cs.c)<16 then
ji[co+2]=jj[self.je].jk
end
if self:by(cs) then
jl,io=self.je,true
co+=1
end
end
jm=a:l()
function jm:n()
if self:by(cs) then
if jc then
mset(31,25,0)
mset(31,26,0)
sfx(45)
for m in all(en) do
if(m.b<280) m.ii=true
end
jc=false
end
self.de=true
end
end
jj=
{
{jn="000000001i?+??+??+??+??+Hh7wy?+3S?PERSC:2P?:3B?+1S?S?+1xh+1xh+1x:2h?:3AEARCS?+8:2?hy?w7?+2T?+1C?TC?+1AB?S?S?+1xh+1xh+1xh?+1C?+1CT?zQB?+5ywymy?+2zA+1DA+1D:jA?A+1?T?S?+1xh+1xh+1x:jh?ADA+1DAQA+2B?u+2:ju1+30+15lt+7?A+1B?+1T?NXUZNONON?t+6NONOMfvfvj+40j3J+6z?A+2?+42?xzBx?+2J+7NONO?L?L?0+5?3?+3zA+1?A+2B?+22?+1xA+1xB?+aNOM?L?L?+10?0+3B3zBzA+1:kA?A+3B?2ezAxA+1xA:kB?+aNO?L?L?+20+6s+5?s+4NONONO1+4?+9NOM8+3?+??+??+??+??+HA+5R?+1PA+4:2A?:3B?+3S?+3S?+1S?:2?+3zA+1QA+dR?+5PA+3?QAB?+1T?+3S?+1T?+1zANO1+cAER?+9PAE?A+1QAQB?+3T?+2z:jAQNONONOj+9?C?+8zB?+1C?1+40+15l1+6NONOh+1NONONO?+4BC?+1zB?/ef/?zAQABC?Oj+63j+3NONOy/A/?why/z/w:gNO:2N+5ADBzQAB/uv/zQA+1QA:jD?NONOABzB?3?+1zB/y/h+1y/P/6ywn/P/wMNO+5t+f?ONONOAQA+1B3zQ:nA/O/hywh+1nwhywNON+5J+f?NO?+1NOt+5NONONONONONONONO+5"},
{jo=4,jp=58,jq=16,jr=82,js="the path splits here...",jf=3,jh=4,gw=-58,jn="g5820e2835?+Q:2?+b:2?+4:3?+5:3?+7:e?+e:2?+F:0?+??+??+??+??+1:f?+Z;1?+??+??+M;0?+k:9?+??+A:9?+E:d?+Q;0?+??+??+T:0?+??+??+??+??+??+U:3?+e:2?+w:3?+w:2?+??+z:8?+??+A:9?+??+n;1?+c:9?+r:7?+??+F:h?+C;0?+??+??+??+??+??:4?+E:c?+??+??+h:0?+9:0?+??+E;a?+??+??+??+F"},
{jo=4,jp=194,jq=16,jr=82,js="the path continues...",jf=5,jk={42,18,35},jn="11d20d122iA+5B?+1PA+kR?PA:iA+aE:2A0:3A+f:eR?PA+b:2A0A+6B?+1PA+bRPA+3RS?+3PA+7R?C?0A+bEAR?+3A+c0A+7B?+1PA+9R?+1PER?+1S?+4SPA+3R?+2C?0A+2R?PAEAR?+1C?+5PA+b0A+7R?+3PA+6R?+3C?+2T?+4T?+1PER?+3C?0AR?+4C?+3C?+7PA+5:fA+30PA+5R?+5PA+4R?+4C?+cC?+4C?0?+6C?:5?+2C?+8A+90?+1PAEAR?+4e?+2PER?+6C?ey?+9C?+4C?0?+6C?+3C?+1NONONO?PA+80?+3C?+5wx?+3C?+5zBCzxh7?+3zAB?+1C?+4C?0?+6C?+3C?+1:8MNO?+1x?+1P+1EARSPAE0?+3C?+4whxy?+2C?+3zA+2DAxh+1y?zA+4BC?+3zDA0?+1:4?+3:0?C?+2zDB?:pNOM?+1x?+3C?+1S?+1C0?+3C?+4h+1xy?+2C?+1zA+4NONONOt+2NONOADB?zA+30?+5zDB?zA+2B:pMNO?+1x?+3C?+1T?+1C0AB?+1C?+36h+1xh7?zDA+7MNOJ+6NOMA+80?+4NOt+105lt+2NOMB?x?+3C?+4C0A+2BCzB?+1NONOt+cNO?+8NOt+20k40t+2?+4MNOJ+23J+2?NOABx?+3:cC?+2zAD0A+3DA+3MNOJ+dM?+aMJ+32J+4?+4NO?+43?+3MA+1xABzADA+50t+8NO?+u2?+aM?+63?+1NOt+eJ+8M?+u2?+5o+5NO?+63?+1MJ+e?+2PA+7R?+2S?+1S?+1S?+2S?+1whyw:30?+52?+7PA+8R?+33?+5;i?+fPA+4R?+3S?+1T?+1S?+2S?+1mhnw0?+42?+9SPA+4RS?+53?+fy?+4A+3R?+4S?+4S?+2T?+2whn:90?+32?+aS?+1PA+1R?S?+63?+1;0?+cy?e?+2PAR;1?+2:g?e?+1T?+4S?+6my?:90?+22?+bS?+2S?+2S?+73?+dhyx?+3;1?+4wx?+7T?+60+e?+4T?+2T?+2T?+60+4?+ah+1x?+8wxy?+gx?x?+5x?x?+e:0?+7x?x?+bh+1xh7?+5whxy?+fzxBx?+5x?x?+i:6?+3x?x?+bh+1xh+1y?+36h+1xhy?+czA+1xAxB?+4x?x?+c0+4?+4x?x?+bNONOt+7NONO?+aNONOt+4NONO?x?x?0+2?+5:4?+3x?x?+5x?x?+bMNOJ+9NOMy?+2:5?+5wMNOJ+6NOMBx?x?x?x?+2zB?+4x?x?+5x?x?+bNO?+bNOhy?+66hNO?+8NOAxBx?x:0?x?+1zA+2B?:0?+1x?x?+5x?x?+bM?+dMhy?+6h+1M?+aM;bAxAxBx?x?zA+4B?+1x?x?+5x?x?+bNO?+bNOh+17?+46h+1NO?+8NOt+lNO?+2x?x?+bM?+dMh+2y?+2wh+2M?+aMJ+mMo+h"},
{jo=140,jp=90,jq=16,jr=194,js="the path splits again...",jf=5,jh=6,gw=50,jk={42,24,51},jn="85b30b532gB?3?+7S?+1S?+2S?+43?+5S?+4S?+cS?+1S?+2S?+3:e?+3S?+7S?+10A?+13?+6T?+1S?+2S?+53?+4S?+4T?+cT?+1S?+2S?+7S?+7S?+10AB?+13?+8S?+2T?+63?+3T?+lS?+2T?+7S?+7S?+10s+6NO?+4T?+b3;lKu?+e:l?Ku+2?+3S?+bT?+6:f?S?+10I+5NOMB?+efvfvf?+4:5?+9fvfvf?+3T?+kT?+10?+6NOAB?+1u;lu+2?+8L?L?+gL?L?+t0?+6s+3NOf+1vf?+8L?L?+gL?L?+t0?+6I+2NOM?+1L?+9L?L?+c:4?+3L?L?+3z:0AB?+m0?+aNO?+1L?+9L?L?+7:0?+8L?L?+2zA+3B?:8?+j0?+bM?+1L?+1:4?+7L?L?+6Ku+3?+4L?L?+1NOs+4N:pO?+e:m?+30?+aNO?+1L?+4:l?+4L?:5L?+4fvf+2vf?+4L?L?+1MNOI+2NOM?NO?+f0?+bM?+1L?+4Ku+2?L?L?+5L?+2L?+5L?L?+1NO?+4NO?M+1?NONOs+5NONO?0?+aNO?+1L?+3fvfvf?L?L?+5L?+2L?+5L?L?+1M?+6M?NO?MNOI+7NOM?0?+bMo+BNO?+4NOoM+1oNO?+9NOo0/6+S:26/0+6:3/6+e:26/0/6+7456/+J0/+66/+f0/6+1w236+2kl6+aw236/+v0/+66+9456/+30/01Mij0136+1w236+1w23w01Mij0136+1w236+1w23w236+7w236/+40/+66+9kl6/+30/gh/?/+2ghj01Mij01MijMgh/?/+2ghj01Mij01MijMij0136w201Mij0136/+10/+63w236+7w236/0?/+7gh/?/+2gh/?/+bgh/?/+2gh/?/+5ghj1Migh/?/+2ghj01/0/+6jMij0136w201Mij0/0?/+Gh/?/+9gh/0+6?/+3ghj1Migh/?/+2g/0?+T0+6?/+6h/?+70AB?+R0+6?+b:g?+30A+3B?+hw7?+1wy?+mzAB?0+6?+1e?+c0A+4B?+d:0?+1why?6:lh+17?+b:0?+7zQA+2B0+6?+1xy:0?+8e?+10A+6B?u+a?+1hNO?hNOy?+1u+3?+1u+6?+2zQA+3:lQA0+6?+1xh7?;l?+5wx?+10s+8f+1vf+1vf+1vf+1s+1NONONOs+3f+1vf?+1f+1vf+1vf?+1s+1050+2s+8?s+30+350s+3?0I+8o+aI+bo+eI+33I+aoI+83I+3o0"},
{jo=276,jp=58,jq=16,jr=194,js="the castle is ahead.",jf=7,gw=-24,jk={55,15,21},jn="84a90a492tONONOA+9Rmh+1NONO:3NOA+1R?+32?PA+aR?+23?+4:2MNO?+6mh+1yh:2NONOM?+32?+1PA+6:2AN+1ONO?PA+6RS?+1wNONONOMRS?+32?+2A+8RS?+43?+3NOM?+8w7wN+1:3ONO?+22?+3SPA+5N?+1xn?+2S?PA+1R?T?+2wNONONO?T?+22?+3PA+6R?S?+53?+2MNO?+7:g?+1myNONO;b?+22?+4S?SPEA+2N?+1x?+3S?+2S?+7NONOM?+32?+5PAEA+2R?+1S?+63?+1NOM?+awMNONONONONONOS?S?CPA+1N?wx?+3T?+2S?+8NONONONONONO?+3SC?;1?S?+2S?+2;l?+3NONONO?+1NONONO;b?+3NONONO?+4x?S?T?C:1?SPN?wx7?+6T?6y?+4NONONONONONO?+4TC?+1S?+2T?+1NXUZNONONOM?+2NONONO?+2MNONO?+5x?S?+2C?S?NONONONOM?+4wy?+4wx?+6NO?+6C?+1S?+62wNONONONO?+3x:1?+2NXUZNONO?+6x?T?+2C?T?N+1ONONONOy?+2wh+1y?:0?+2mx?+fC?+1T?+52?6h+2NONO?+4x?+32?NONO?+7x?+4C?+2N?+4NOMy?+16hywy?+3;a?xy?+7e?+3zBC?+72?wh+2ywNO?+5x?+22?NONONO:8?+6x?+4C?+2N?+1NO?+1NOt+dNOM?+5x?+2zA+1DAB?+4NONOywh+2n:pM?+5x?+12?NONO6hN:pO?+5x?+1zA+1DABN+1?+7J+eNOy?e?+2x?NONOA:lA+2B?+4NONOh+3y:pM?67?+2x?2?+2NO7wNONO?+3:0?x?zA+2NONON?+dNO?+5NOMy?x?+1NONONONONOA+1B?NONONONOywyNOh+2y?+1x2?e?+2NOmhNO?+3zAxA+3NONON+1?+8NO?+bNONONONOt+I040+1t+bN?+nNONONOJ+J2J+eN/6+e:26:36+M:26/N:3ONOh+1n?+12:e?+3PA+aN/6+?6/+1N+1OMhn?+12?+5PA+6QA+1N/6+3456+xw236+aw236+1w236+1w2/NONOy?+12?+7SPA+6QN/6+3kl6+5w236+dw236+1w236+1wMij36+1w236+3wMij01Mij01Mi/N+1OMn?2?+8S?+1S?+1:fPA+2N/6w236+1w236+1wMij36+1w236+1w236+1wMij01Mij01M/?/+2j01Mij0101M/?/+2gh/?/+2gh/?+1NONONONONO?+5T?+1S?+5N/1Mij01Mij01M/?/+2j01Mij01Mij01M/?/+2gh/?/+2gh/?/+4gh/?/+2ghgh/?+cN+1ONONONOM?+8S?+5N/h/?/+2gh/?/+2gh/?/+4gh/?/+2gh/?/+2gh/?+BNONONONONONONO?+4S?+1NONON?+dM?+o:l?+56e?+6;i?+a0?+3NONONO?x?+5T?+2x?N+1?+dNO?+ke?NO?+1eywh:0xB?+7e?+6z0?+4NONO?+1x?+9x?AN?+dMN?+g:l?NONONONO?xh+1nxA+2B?+4xy?+3zA+10?+5NOMB?x?+2e?+4:m?xzANAB?+bNO?+8e?+2;0?+1zANONONONONONONONOA+5B?:lxhn?ezA+20?+6NOABx?+2x?+4zxA+1NA+2B?+2zB?+3NONzB?+6xy?ezA+1NONONONONO?+1NONONOt+7k40+1A+30?+5NOMA+1xAB?x?+1e?zAxA+1Nt+70k40t+3A+1B?+20+15lt+5MNO?+3NONO?+1NO?+1NOJ+62J+1zA+30?+6NOt+fNJ+82J+5A+3B?+1J+13J+5NO?+fNO?+42?+1zA+40?+7MJ+fN"},
{jo=140,jp=170,jq=16,jr=66,js="the castle is ahead.",jf=7,gw=-16,jk={57,26,53},jn="156707562m/6/+p0+1?+8wh+10+3h+4n?+13?+20+3h+2n?+32?+20+1?mh0/+16+9w236+1w236+4456+1w236+1w/0+1?w7h7?+3wh+10:2?+10h+3n?+33?+10+3hn?+42?+3:90:90?+1w0/+16+8wMij01Mij36+3kl6wMij01M/0+1?mh+3y?+2wh0?+10h+1n?+2mh0+4?+10n?+42?+5:90?+1m0/+16+601M/?/+2gh/?/+2j36+4wM/?/+2gh/?+4whywhy?+2w0+3n?+5wh+30?+10?+10+b7?+10/+16+6gh/?/+9j01201M/?+bmh+37?+1w0+3;b?+7wh+20+1?0?+36h+4n?0+1y?+10/+101:22/+4?/+cghigh/?+7:0?+2w7?+2mh+1y?w0+7y?+3wh+10+3?+2wnwhn?+30+1y?+10/+1ghi/+4?+2e?+n6hy?+3why?+10+3:1wh+2n?+5m0+3?6hn6hn?+1:c?+20+1y?+10+1?+6B?+1x?+4e?+b0+1kc0+7?+1h+1y?0?0+1h+1n?+7;a?0:2?0+1hywywn?+50:20y?+10+8AB?x?+4x?+d2?0+4?x?+16hy?+10?+10hy?+4w0+4?0+ak40+2y?+10+8A+2xB?+2zx?+7e?+32?z0+2?+2x?6nwye?0?+10n?+5whywy0+3h+3n?+326h0+1y?6h:8h+10+51+40?zAxB?+2e?+1zxB?+12?+1A0+1?+1wyx?wewyx?0+1:3?0;b?+7wh+1y0+1:3?0h+1n?+42?wy:90wh7wy:90w0+5j+41+50?+1x?zAxAB2?ezA0+1?e6yxwyxwyx?0+450+1?+17?+1ywh0+1?0hn?+426h+27:90h+50+5?+4j+51+e0+9k40+5h73?+2wy6h7w0+55l0+l?+aj+e0+1wh+2n?+226h+10+3yw73?+1wh+1ywh0+3?x?3?+5x?0+Fwh+1n?+226ywh0?0+1ywh73?+1whywh0+3?x?+13?+3:e0/+46/+a0h7wh+5ywh+2y?+3mh+1ywh+10+1mhy?+226hnwn0?0+1hy?h73?+1wywh0+3?x?+23?+10/+56+6456/+10wywh+2y?mh+2n?+bmn:90?wy?+126h+2n?0?0+1y?+1my?3?wh7:aw0+3?x?+33?0+1?/j/x/6+7kl6/+10h+17whn?+2:gwn?+e:90:90?why26ywn?+1:a?0+1:3?0y?+20+8:2?0+3k40+4?+2x/36+3w23:f6+1w2/0wh+1y?+6:5?+40+2?+30+dk40+2?0y?+3wh7?mh+10?0+1n?2?+2x?+4x/j36+1wMij01Mi/0h+1n?+l0?0h+2n?+426h0+3y?+167why?+1wh0?0+1?2?+3x?+4x?/j01M/?/+2gh/?+10y?+n0?0hy?+52?mh0:2?0+1y:4?+1wywywy?+1w0+6?+2x?+4x?/+1h/+1?+70n?+i:4?+3w0+2y?+2:0?+22?+2w0?0+1y?+1mh+10+1y?+1w0+6?+2x?+4x?+7:d?+30?+10+5?+e6h0+2hn?+32?+3w0+3y?+2wh0+1y?+1h0?:3?x?0+1B?+1x?+4x?+b0?+2x?+1x?+3:0?+awh+10:3?0y?05l0+4?h0+3h7?6h0+2y:6?+1h0?+1x?0+1A?+1x?+1e?+1x?+b0?+2x?+1x?+dwhyw0?0y?+23?+5m0?0+9y?+1w0+1?x?0+1AB?x?+1xzBx?zB?+6zA0?+2x?+1x?+20+2?+10+a?0n?+33?+1wy?+10?x?+1x?+1x?0+1y?+1w0+1?x?0+1A+1BxzAxA+1xA+3B?+2zA+20?+2x?+1x?+3x?+3x?x?x?x?+10+2?w7?+23?my?+10?x?+1x?+1x?0+1n?6h0?+1x?0+11+m?+2x?+1x?+3x?+3x?x?x?x?+10+26h+1y?+23?m7?0+bk40+3?x?0+1j+m"},
{jq=16,jr=50,gw=-28,jk={70,20,89},jn="g5820e283g/6+iw20/MNOMhn?26h+2yw:2MNONONONONO?+1NONONO?+h2?+fNONOh7?mhywh+2y:2h?/+56+a456+4wMih/NONOn?26nhnwyhNO:3NONO?+1NONONO?+1NO?+h2?+gMNONOy?+1wh+6?/+536+1w236+1w23kl6+3wM/?+3NOM?26nwy?mywMNONO?+5;1?+5;1?+h2?+hNONOhy?+2nmywywh?/+5j01Mij01Mij36+1w01M/?+5NONOYVWO?+1whNOMy?+rYVWO?+6NONOYVWONONONONOhy?7?+1whywh?/+6gh/?/+2gh/?/+2j01Mih/?+7xh+273?+2h+1MNOy?+rx73?+6wM:2NOMh73?+2h+2NONOh7w7?+1h+3?/+hgh/?+axh+1nw73?+1:gmhNOMy?+rxh73?+46hNONOwh73?+1wh:0h+1NONOywy?+2mh+1?+uxhy?+1m73?+1hMNOhy?+p6xh+1e3?6ywywMNOM?wh73?+1mh+2NONONONO?+1wh?+5u+e?+9xh+1:d7?+1h73?mNOMwhy?+ohxywNONONXUZNONONONONXUZNONONONONONONOh?+5fvf+4vf+4vfNONONO?+3xywhyewh73?MNOw;0ywy?+d:7?+86hxywxywhn26NONONOw;1hn?2?+1mh+1y?+1;1?+2whNONO+6?L?+4L?+4L?+1NONOM?+3xh7wyxwNONONOMy+1why?+5:7?+fwhx7wxyhn26ywNONOywy?2?+3why?+5mhNON+6?L?+4L?+2e?L?+1x?+1NO?+3xhywhxhMNONONONONXUZ?+j6h+1xywxhy26hywMNOMyhn2?+5h+1y?+5whNO+6?L?+1e?+1L?+2x?L?+1x?NOM1+aNONONONOn?26hy?+gNONONONONONONONONONONONONO?:b?+2wy+1?+5whMN+6?L?+1x?+1Le?+1x?L?+1x?+1NOj+aMNONONOn?26ywhywy?+2why?+2wymhyMNONONONONONONONONONONONONONONONO?+5w;ahNO+68+vNONONO?+126hywhywhy?whywhymh+17whNONONONONONONONONONONONONONONONONONOYVWONON+6OMh+2n?+owh+1y+1?+226M:2N/6/+PNONOh73?+1mh+1ywNO:2N+1Ohn?+rmymy+1?26yNO/6+c45:26/0/6/+zNONOh73?+1wywhMNO+1My?+ty?wy26y+1MN:3/36+1w236+6kl6/0:3/36+1w236+5w36+1w236+gw/NONOh73?+1m7mhMN+1Oy?+tYVWONONONO/j01Mij36+1w0136+1w/0/j01Mij36+1w01Mj01Mij36+1w0136+1w236+3wMi/NONOh73?+1wywNO+1My?+v3?mhyNON?/gh/?/+2j01Mihj01M/0?/gh/?/+2j01Mih/?/+1gh/?/+2j01Mihj01Mij36+1wM/?NONONOh73?+1myMN+1Oy?+v73?w:0ywNO?/+6gh/?/+3gh/?0?/+6gh/?/+agh/?/+3gh/?/+2j01M/?+4NONONONXUZNO+1Mhy?+s;a?wh73mhyMN?+f0?/+vgh/?+4NONOh+1n?26NON+1Oh+1y?+9:7?+hYVWONONONO?+f0?+j0+15l0?+3:5?+aNONOn?26hMNO+1NONONXUZNO?+n3mhywNON?+f0B?+ixhn3?+gxhy?26h+1NONywywn?26NOM?+mh73mh;0hyNO?+f0A+1B?+gxy?+13?+fxn?26h+1NONOywhy?26hMNO?+b:7?+9wh+173mywMN9a?+39:oa9a?+39a0A+5B?+1zB?+8xnzBe3?+ex?26h+1NONO;iNnhn?2?ywNOM?+4ywy?+dwywhNONONOa9a9a9a9a9a9a9a91+aNO?+3:5?+3x70+4?+8NO1+dy+1?2?wywMNOywy6h+2ywhy?+66yhNONONONONON+1ONXUZNONONONONOj+bM?+7xyx?+2x?+8Mj+ehn26hy?wNOMhywh+1ywh7wh+2y?wywhywMNONONONONO?NX26h+7NO?o+Q"}
}
function _init()
ey,ds,w=jt("2982928"),jt("1d2f"),jt("567fabd")
cs:bp()
cs:br(ex)
cs.ez=ez:l()
cs:br(cs.ez)
cs.ez:fi(10)
bc,be,dv,cs.cp,iq,ju,fs,ft,ho,hr,jv,cw,jw,jx,jy,jz,ka,kb,kc,co,dh,dx,hi,ji,kd,ke,kf=4,0.15,2.5,6,6,0,0,0,0,0.25,{},0,{jt("001521562443d52e"),jt("0001101512250112"),jt("0000000101110001")},0,0.01,0,-20,true,true,0,false,0,0,{{41,24,195}},0,0,0
cs:n()
end
function jt(r)
m={}
for v=1,#r+1 do
add(m,kg(kh(r,v)))
end
return m
end
ki={fu,fz,ih,ik,hv:l({hx=24}),hv:l({hw=24}),hv:l({hx=-24}),id,ip,ir,gj,gj:l({gk=false}),gq,gf,il,iv,iz,jb,gz,jd,jd:l({jg=true}),hb,hd,jm,hh,ir:l({is=33})}
function kj(kk,kl)
cls()
en={cs,bv}
dh,dx=kk==1,0
if kk==6 then
km=true
jj[7].jk={69,30,105}
elseif kk==4 then
kn=true
jj[5].jk={57,20,37}
end
gg=kk
kk=jj[kk]
r,jq,jr,jo,jp,jl,jf,jh,ef,dc=kk.jn,kk.jq or jo,kk.jr or jp,kk.jo or jo,kk.jp or jp,kk.jl or 1,kk.jf or jf,kk.jh or jh,kk.gw or 0,{}
if gg==7 and km then
jq,jr=496,186
elseif gg==5 and kn then
jr=34
end
if(kk.js) js=kk.js
cj,d,cursor,b,c,ko,kp=jt(sub(r,2,8)),kq(sub(r,9,10)),11,0,0,0,64
while cursor<#r or ko!=0 do
if ko<=0 then
kr=sub(r,cursor,cursor)
if kr=="/"then
kp=192-kp
elseif kr==":"or kr==";"then
hs=sub(r,cursor+1,cursor+1)
if kr==":"or cy then
ks=ki[kg(hs)+1]:l():cm()
ks.b,ks.c=b*8,c*8
ks:ch()
ks:o()
cl(ks)
end
cursor+=1
elseif kr=="+"then
hs=sub(r,cursor+1,cursor+1)
ko=kg(hs)
cursor+=1
else
kt=kg(kr)+kp
if(gg!=2) mset(b,c,kt)
b+=1
end
cursor+=1
else
if(gg!=2) mset(b,c,kt)
ko-=1
b+=1
end
if b>=d then
b=0
c+=1
end
end
ku=kg(sub(r,1,1))
if dh then
eh(ku)
else
eh(-1)
end
if not kl then
cs.b,cs.c,cs.i,cs.g,cs.f,cs.t=jq,jr,0,0,0,false
cs:cz()
bv.df=false
else
cs.cp=iq
cs.b,cs.c,cs.ct,cs.t,cs.ec=ei,ej,ek,el,em
cs.dm,cs.q,cs.kv,cs.f,cs.q,bv.df,cs.r=0,false,0,0,false,false,1
end
cs:bq()
bv:cx()
bv:cv()
bv:n()
if dh then
bv.b=flr(cs.b/136)*136
end
end
function kg(kw)
for v=0,63 do
if kh("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?",v+1)==kw then
return v
end
end
end
function kq(kx)
local ky,jg=kg(kh(kx,1)),kg(kh(kx,2))
return jg+ky*32
end
function kh(r,v)
return sub(r,v,v)
end
function _update60()
ee,du=btn(5) and not kz,btn(4) and not la
kz,la=btn(5),btn(4)
if(not io) ji[co+2]=nil
hi=(hi+0.01)%1
if eg then
eg-=1
if eg<=0 then
eg=nil
kj(gg,true)
kb=true
kd+=1
end
end
if kc then
if btnp(3) or btnp(2) then
cy=not cy
sfx(2)
end
if du or ee then
kc=false
if cy then
cs.cp,iq=4,4
end
kj(2)
sfx(3)
jx,cw=5,20
end
return
end
if not lb then
kf+=1/60
if kf>=60 then
ke+=1
kf=0
end
end
if cw>0 then
cw-=1
return
end
if iy then
if ju>=10 then
if cs.cp>=iq then
iy=false
iq+=1
sfx(1)
else
sfx(0)
end
cs.cp+=1
ju=0
end
ju+=1
return
end
if io then
if ka<=80 then
ka+=1
jx=ka/5
else
kb,io,ka,ja=true,false,-20,false
if not lb then
kj(jl)
else
js="you couldn't stop the demon"
if(hp) js="you sealed the demon away"
end
end
if(not hn) return
elseif lb then
jx-=0.1
if hp then
eh(26)
else
eh(25)
end
return
end
if kb then
if jz<=20 then
jz+=1
jx=5-jz/5
else
kb,jz,jx=false,0,0
eh(ku,0b11)
end
return
end
if hn then
hr=(hr+jy)%1
if not lc then
for v=1,ho do
local ld=hq:l({hs=v})
add(jv,ld)
cl(ld)
end
lc=true
else
dx-=0.05
if hp then
jy+=0.000025
dx-=0.05
if(dx<24) hj.q=not hj.q
else
jy-=0.000025
if dx<16 or ht then
hj.c-=2
hj.r=210
hj:bq()
dx+=2
ht=true
end
end
end
if dx<=12 or dx>128 then
io,lb=true,true
end
end
del(en,cs)
del(en,bv)
cl(cs)
cl(bv)
for m in all(en) do
if m.cr or(m.c>=bv.c and m.c<bv.c+112) then
m:n()
if m.ff and m.cp<=0 and not m:bw() then
m.de=true
end
if m.de then
del(en,m)
end
end
end
end
function eh(hs)
if le!=hs then
music(hs)
le=hs
end
end
function cl(m)
add(en,m)
end
function ba(b,c)
return ew(b,max(c,bv.c),0)
end
function ew(b,c,lf)
b/=8
c/=8
return et(b,c,lf)
end
function et(b,c,lf)
return fget(mget(b,c),lf)
end
function bn(gr,lg,cq)
if gr+cq<lg then
return lg-cq
elseif gr-cq>lg then
return lg+cq
else
return gr
end
end
function _draw()
cls()
if(jx>=4) return
if lb and not io then
lh()
li("deaths: "..kd,72,7)
local he=""
if kf<10 then
he="0"
end
li("time: "..ke..":"..he..flr(kf),82,7)
if(cy) li("hard difficulty",92,7)
li(ho.."/3  ",116,7)
spr(58,68,114)
else
if cw<=0 then
bv:dg()
map(0,0,0,0,128,32)
if kc then
clip()
camera()
li("normal",72,7)
li("hard",82,7)
local gd,ge=0,0
if(cy) gd=4 ge=10
spr(180,40+gd,72+ge)
spr(181,79-gd,72+ge)
li("mush101.itch.io",118,5)
return
end
lj()
for m in all(en) do
m:p()
end
map(0,0,0,0,128,32,0b1000)
camera()
clip()
end
if dh then
lh()
else
lk()
end
end
if(jx>=1) ll()
end
function lj()
if(dx<=0) return
camera()
local hu=dx-3*sin(hi)
circfill(63,36,hu+1,1)
circfill(63,36,hu,0)
bv:dg()
end
function lk()
line(0,112,127,112,5)
print("player",1,114,7)
print("enemy",108,114)
for v=0,iq-1 do
spr(47,v*5,120)
end
for v=0,cs.cp-1 do
spr(63,v*5,120)
end
for v=0,ft-1 do
spr(46,120-v*5,120)
end
for v=0,fs-1 do
spr(62,120-v*5,120)
end
local r={}
if jc then
r={56}
end
for v=1,ho do
add(r,58)
end
local cursor=65-5*#r
for v in all(r) do
spr(v,cursor,114)
cursor+=10
end
end
function lh()
rectfill(0,0,127,63,0)
sspr(56,96,64,32,32,8)
local lm={0,8,0}
if not lb then
for v=1,3 do
rect(v-1,63+v,128-v,128-v,lm[v])
end
if(jc) spr(56,119,56)
end
li(js,50,7)
hs=-1
pal(3,0)
for ha in all(ji) do
if hs<co or hi%0.2<0.1 then
spr(ha[3],ha[1],ha[2])
spr(ha[3]+1,ha[1]+8,ha[2])
end
hs+=1
end
pal()
end
function li(ln,c,lo)
print(ln,64-2*#ln,c,lo)
end
function ll()
for v=0x6000,0x7fff do
local lp=peek(v)
local lq=lp%16
local lr=lshr(lp-lq,4)%16
lr,lq=jw[flr(jx)][lr+1],jw[flr(jx)][lq+1]
poke(v,shl(lr,4)+lq)
end
end
__gfx__
0000660600006606000066060006606000ff660600006606000066060000000000aaaa00000000000000000000000000000bb00000dda0000000770000005505
0006666000066660000666600066660000ff66600006666000066660000000000aaaaaa0000bb000000000000000000000baab000dddaa000007777000055550
0066fff00066fff000666ff0066fff0000f6fff00066fff00066fff0000000000aaaaaa000bddb000000000000bbbb000baaaab0dddaada07707777000057770
0066fff00066fff000666ff0ff6fff0000f6fff00066fff00066fff0000000000aaafff000badb000bbbb0000baaaab00baaaab0dddaabaa7705777000557770
067766700677667006666660ff76670006f7667006776ff00677667000000000bdaaafa00baab00000aaab00baaaaaab0baaaab0dddaaaa00766557000665570
6f77777f06f77770066677700f77770006777770067ff770067f777000000000bbdaafab00abb00000aaadb0bdaaaadb0bdaadb0bdddaa000076660000666600
6ff7777f06fff7700667fff00777770006777770067777700677ffff00000000bbbbbbbb00ab000000bbddb0bddddddb0bddddb00bbddaa00066660000667777
0ff55500005ff50000555ff0055555000055550000555550005555ff00000000bababaaa00b000000000bb000bbbbbb000bbbb0000bbb0000066660000666657
0055550000555500005555000677550000755550000333333000000000000000babbbaddbabbbadd060550600006000600060006006666000066660000677600
0075570000077500007756606667755056775660033888888300000000000000baaabaadbaaabaad060550600050555500005555065555500067760000777700
06770770000777000077766066007750566006603883333338300000000000000baabaad0baabaad655555560560565600055656655575550007770007770770
66600660000660000667055555500770500005558330000038300000000000000bbbbbad0bbbbbad655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000003000000003830000000000000adbabad0aadbbad656556565666555000566556555555500006700067000670
0550055500055500056600000000066000000000000000000383333000000000aaababaa0aaabbaa066556605665550005665566555500600006670006700667
0000000000000000005600000000056600000000000000000038888300000000aadbadba0aadb0ba005555000605550005055560555000000000000000000000
0000000000000000000500000000005500000000000000000003333000000000aaadbadb0aaadb0b006006000050500000505000055555500000000000000000
0500000007770000088000000000000000033000000000000333300000000000a000000a000a000000aaaaaabb00a000000bb000055000000000000000000000
5650000076660000899800000000000003388300000000333888830000000000aa0bb0aa00aa0000000aaaa0bbb0aa00000bb00056650000000666600aaaa000
0500000066650000899800000000000338833000000033888333300000000000aaabbaaa0aaabb000000aa000bbbaaa0a00bb00a56650000000600600a00a000
0000000066500000088000000000033883300000003388333000000000000000aaabbaaaaaabbb00bbbbbbb000bbbaaaaa0bb0aa05500000000600600a00a000
0000000000000000000000000003388330000000338833000000000000000000aa0bb0aa00bbbaaabbbbbbb0aaabbb00aaabbaaa00000000000600600a00a000
0000000000000000000000000338833000000000883300000000000000000000a00bb00a0bbbaaa00000aa000aaabb00aaabbaaa00000000000d00d009009000
0000000000000000000000003883300000000000030000000000000000000000000bb000bbb0aa00000aaaa000aa0000aa0bb0aa00000000000dddd009999000
0000000000000000000000008330000000000000000000000000000000000000000bb000bb00a00000aaaaaa000a0000a000000a000000000000000000000000
09900990077700000990000033000000000000003330000000000000006666000660000002202200009999000000000000000000000000000000000000000000
977897787eee00009aa900008833000000000330880000000000000006666660600600002882882009999990808080808080080000000007000666600aaaa000
97789778eee200009aa900003388300000333883330000000000000066776665600600002888e82099779994808080808880088000990970000622600a88a000
08800880ee200000099000000033833333888330000000000000000066776665066600002888882099779994888080808880888809449440000622600a88a000
0000000000000000000000000000388888333000000000000000000066666655000560600288820099999944080080808080088064444446000622600a88a000
0000000000000000000000000000033333000000000383333333300056666555000056560028200049999444080008808080080060444406000d22d009889000
0000000000000000000000000000000000000000000388888888830005555550000005600002000004444440000000000000000066000066000dddd009999000
00000000000000000000000000000000000000000003333333333000005555000000000000000000004444008888888888888880066666600000000000000000
0777777077277767000055555555000007705555555507700000000000000000777777770ddddddddddddd000055055507705555555507700000000056666665
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c717d555555555555550060005557ee0066666600ee80006500054444445
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c1d5555555555555506506d0507ee0000000000ee85605555005555550
7eeeeee8822822280000060000600000000006000060000000005505550000001c1c1c1cd555555555555500d50d550600000608706000005566550000000000
7eeeee888888888855550000000055555555000000005555000000000000000011111111d5555555555550505005550d55550008700055555665555000000000
7eeeee880828082006660000000066600666000000006660005505550555000011111111d55555050505050006d0500506660e887ee066605666555000000000
7eee8888000000000000000000000000000000000000000000000000000000001111111105505050505050006d5506d0700008887ee000005665555000000000
0888888020002008060000000000006006000000000000605505550555055500111111110000000000000000d5550d5006888880088880605566550000000000
00000000000000000000000002000000077777700777777000000000000000007777777733300000000000000055055077377767774777670000000056666665
066605550555055506660660000000207eeeeee87eeeeee80555055505550000c717c71788833333333333300600055000700070007000704444444454444445
000000000000000000000000000000007eeeeee87eeeeee8000000000000000071c171c133388888888888836506d05033033003440440045555555505555550
060666055505550555066600002000007eeeeee00eeeeee800055505550555001c1c1c1c0003333333333330d50d5500b33b333b944944490004900000494400
000000000000000000000000000000007eeeee800eeeee88000000000000000011111111000000000000000050055500bbbbbbbb999999990004900000499400
066605550555055506660660000000007eeeee800eeeee88000005550555000011111111000000000000000006d050000b3b0b30094909400004900000449400
000000000000000000000000000000007eee88800888888800000000000000001111111100000000000000006d5506d000000000000000000004900000494400
0606660555055505550666000000000008800000000008800000000555000000111111110000000000000000d5550d503000300b400040090004900000449400
00000000566555500000000000000030303000303030000049944440499444403030003000000000003300000055055003000000040000000000000000494400
05550555565655500555000000033033000330330003300049494440094944000003303303333333338300000d00005000000030000000400000004400494400
00000000566555500000000000303030303030303030300049944440309440303030303008888888883000006506d00000000000000000000044445500449400
0005550555665500550555000030000330300003303000304499440030090003303000033333333333000000d50d550000300000004000000455550000494400
0000000056655550000000000303033003030330030303304994444003000330030303300000000000000000500d550000000000000000000504900000449400
055505555666555005550000003300330033003300330033499944400033003300000033000000000000000006d0500000000000000000000004900000449400
00000000566555500000000033003300330033003300330049944440330033000094400000000000000000000d55000000000000000000000004900000494400
00055505556655005505550000330003003300030033000344994400003300030499440000000000000000000000000000000000000000000004900000449400
07777770077777777777777030003300303000303000330003000300030003000770555555550770077777777777777007777770077777702020202000000000
76666665766666666666666500330033007330330033003300300300003003007660066666600665766666666666666576666660066666650202020200000000
7666666576666666666666653300330037a730303300330000033000000330007660000000000665766666666666666576666660066666652020202000000000
76666655766666666666665503303030307000730330303000033000000000000000060000600000066666666666665076666666666666550202020200000000
76666565766666666666656503000303030307a73000030000300300000000005555000660005555066666666666656076666666666665652020202000000000
76565655766666565656565500030303003700730303030000300030000000000666005656006660066666565656565076666656565656550202020200000000
75656555766565656565655500033000337a73003303300003000030000000000000056565600000066565656565655076656565656565552020202000000000
05555550055555555555555000000303003700030300000003000030000000000600555555550060000005555550000005555555555555500202020200000000
22222222222222222220022222222222222227777772222222222222000000000000000000000000000000000000000000000000000000000000006666000000
22222222222222222207002222222222222222226777722222222222000000000000000000000000000000000000000000000000000000000000665555660000
22222222222222222077030222222222222222222277772222222222777777777777777777777777777777777777777777777777770000000006555660555000
22222222222222220730733022222222222222222227777222222222111111111111111111111111111111111111111111111111117700000005555660555000
02222222220222207777373702222222222222222226777222222222111111111111111111111111111111111111111111111111111170000005566666605000
30222022207022073773033030222222222222222222777722222222000000001111111111111111111111111111111111111111111117000005566666605000
33020702073000773333303033022222222222222222777722222222088888880000000000000011d000001d0000d00001d00000111111700005500660005000
33307330733307733333300333302222222222222222777722222222d0880008808888888088800d008880d08888008880d08880111111170005555660555000
00070337033077333300330070030222222222222222777771111111d0880d08800880008008880008880d08800880088800880d111111170005555660555000
00733030000773330033000300330022222222222226777771111111d0880d088008800000088880888800880d08800888808801111111170005555660555000
00003003007000000000030000030302722222222227777771111111d0880d0880088880dd088088808800880d088008808888011111111700e5555000555800
00000030000003300030000000003330672222222277777207111111d0880008800880001d088008008800880d08800880088801111111700e33355555558a80
0000000000000000330000000000030027722222677777720711111d00880330800880dd000880d0d08800880d08800880d08801111111706666666666666666
000000000000000000000000000000332277777777777722711111d03088033300088000800880ddd088008800880d0880d08801111111176565565556565656
00000000000000000000000000000030222777777777722271111d03308800033088888880888011d08880088880d08880d08880111111175555555555555555
0000000000000000000000000000007322222777777222221111d03330880d000000000000000000000000000000000000d00000000011115050050500050505
2222222222222222505050507000000770000007000000007111d033308800880d03333330d0033330033333333033330dd03333333011170000000000000000
2222222222222222605050506000000660000006000000007111d03308888880ddd033330dd033003303003300300330d1dd0330003011170000000000000000
2222222222222222606050507067660770676607000000775711d0330000000d11d0300301d033000000d0330d000330111d0330000011750000000000000000
2222222222222222606060507077770770777707000077110711d03330ddddd11d03300330dd03330dddd0330ddd0330111d033330dd11700000000000000000
2222222002022220606060607007070770707007000711117111d033301111d0000333333000d0333011d033011d0330111d0330001111170000700000070000
22222207307022076060606070777607706777070071111d7111dd03330000033003300330030d003301d033011d03301d000330dd0011170007170000717000
22222077073000776000006070776007700677070711111d71111dd0333333330d033003300330003301d033011d033000300330003011170071117777111700
22220773733307736066606067000076670000767111111d711111dd03333330d03330033300333330dd033330d0333333303333333011170711111111111170
2220773300000000606060600677776000007700007700005711111dd000000dd0000000000d00000d1d000000d0000000000000000011750571117777111750
22077333055505556060606000067000000076700767000005711111ddddddd1ddddddddddddddddd11ddddddddddddddddddddddddd17500057175555717500
20773030000000006066606000777700000076677667000000571111111111111111111111111111111111111111111111111111111175000005750000575000
07730330550555056000006000067000000076700767000000057711111111111111111111111111111111111111111111111111117750000000500000050000
73303000000000006060606000777700000077000077000000005577777777777777777777777777777777777777777777777777775500000000000000000000
30373000055505556060606007600670000000000000000000000055555555555555555555555555555555555555555555555555550000000000000000000000
73730000000000006060606007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000000550555056060606076000067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005550000000500500005003000000000000000200002002000020000000004999400004999940000004999999994000000000004999999940000000000000
00057575000005750555555038300000000000000200002002000020000000499222999999222299940049222222229999940004999200000024000011111011
00575765000057555555555503000000000000000222222002222220000000922222222222222222299992222242222222299999222000000222900011111011
05765657000055755655556500000000000000000202202002022020000000922244422224444222222222244444444442222222200000002222940011111011
57657656000575655565565500000000000000000022220000222200000004922442444244242422442224444444424444224222000000222222294000000000
56656556000565655555555500000000000000000002200000022000000049224244442444422444242440004444444444444420000022222222229410111111
05555005000565500555555000000000000000002200000000000022004992244444444444444424444420f40242244224244200000222244222222910111111
00000000000055000055550000000000000000000000002222000000009222424424444444244444424222222444442242442200002222222222222910111111
00000000000000000001100000000000000110008888800088882000049224444244424444444442444424244240000004422000022222222222442900000000
00000000000000bb001100000001000000110000888820008882000009224244444444440000444444244244240f444204242000202020202222222911111000
000000bb00000baa017100000011000001710000888200008882000009224444442444440f420444000000444404040202420002200000002222222911111000
0000bbaa0000baaa01710000017100000171000088820000888200000924444444444444042204440f4442024204422204220002220f42022222222911111000
000baaaa0000baaa1761000017610000176100008882000088820000094244404444444442222244040202042442222222420002220402022222229400000000
00baaaaa000baaaa1761000016610011176100008888200088882000092444020442444442444444422222224424444444400000000442022244229010000000
0baaaaaa000baaaa1661001116651122166100118888820088888200090000020444442424244444444444444244424444042424040202044222229010000000
0baaaaaa00baaaaa166511221655222216651122282288002822880049f420222044444442224000444244244442444440424240444222224422229010000000
aaaaaaabaaaadb0022225561222225512222556100000088002200889f0000000044444442420f20444440400444444420000000444444440022229000000000
aaaaaadbaaaddb002222255122222211222225510000088800220888940f4444204424424220f420442400020424424220002220004444000022229400011111
aaaadddbdddddb00222222112222221022222211220008880088088890044220200444242422222244440f204242222200022200000000000002222900011111
dddddddbddddbb0022222210200221002222221022000888008808889442222222244444002442442440f4202220000000022200000002000002222900011111
ddddddbbddddbb0022022210222221002022221088800288008882889044044444444220f2022244442040200000000000222000020000000202442900000000
ddddbbbbdddbbb002002210022221000220221008888882800888828944040404404444044204242442044200000000002442002000000200002222900000001
bbbbbbb0bbbbb0002222210022221000222221000888882800088828494424442444242422222424220040200000222422222004000020002000222900000001
bbbbb000bbb000002222100022221000222210000088888200088882092444424424422442224242000044202224244442220000000000000000222900000001
00111100001111102222100022221000222210008888800088882000094242444244444442424420000020202242444422222220000000000222222900000000
01222210012222712222100020221000222210008888200088820000092224424424424222222200000222224024244222244222222222222222222911011111
01222221122222112221000022210000222100008882000088820000900002222244242200000000022242440444444422222222222222222222229411011111
12222171122221002021000022110000202100008882000088200000900000000222220000000000224444444400004222222222222244222224429011011111
122221111222271020210000111000002021000088820000882000009000000000000000000000022424244240f4204222222222222222222222229000000000
12117100122221102221000011000000222100008820000082000000490000000000000999900022424444404022204422999999992222222222222911111101
17101100012227102210000000000000221000008200000082000000049999900000099400499224999944240999949999440000049999999999222911111101
01100000001111101100000000000000110000002000000020000000000000499999900000004999400099999400000000000000000000000044999411111101
__label__
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222002222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220700222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222207703022222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222073073302222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220777737370222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222207377303303022222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222077333330303302222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220773333330033330222222222222
22222222222222222220022222222222222222222222222222200222222222222222222222200222222222222222222222207733330033007003022222222222
22222222222222222207002222222222222222222222222222070022222222222222222222070022222222222222222222077333003300030033002222222222
22222222222222222077030222222222222222222222222220770302222222222222222220770302222222222222222220773030000003000003030222222222
22222222222222220730733022222222222222222222222207307330222222222222222207307330222222222222222207730330003000000000333022222222
02222222220222207777373702222222222222222222222077773737022222222202222077773737022222222202222073303000330000000000030002222222
30222022207022073773033030222222222222222222220737730330302220222070220737730330302220222070220730373000000000000000003330222022
33020702073000773333303033022222222222222222207733333030330207020730007733333030330207020730007773730000000000000000003033020702
33307330733307733333300333302222222222222222077333333003333073307333077333333003333073307333077303000000000000000000007333307330
00070337033077333300330070030222222222222220773333003300000703370330773333003300000703370330773300000000000000000000000000070337
00733030000773330033000300330022222222222207733300330003007330300007733300330003007330300007733300000000000000000000000000733030
00003003007000000000030000030302222222222077303000000300000030030070000000000300000030030070000000000000000000000000000000003003
00000030000003300030000000003330222222220773033000300000000000300000033000300000000000300000033000000000000000000000000000000030
00000000000000003300000000000300020222207330300033000000000000000000000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000033307022073037300000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000030073000777373000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000073733307730300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000703370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007330300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000030030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006500000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005605555000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005566550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005665555000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005666555000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005665555000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005566550000000000000000000000000000000000
30300000000000000000000000000000000000000000000000000000000000000000000000000000000000305665555000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000330335656555005550000000000000000000000000055
303030000000000000000000000dd0d0000000000000000000000505500000000000000000000000003030305665555000000000000000000000000000000000
30300030000000000000000000dddd00000000000000000000000055550000000000000000000000003000035566550055055500000000000000000000005505
0303033000000000000000000ddfff00000000000000000000000022250000000000000000000000030303305665555000000000000000000000000000000000
0033003300000000000000000ddfff00000000000000000000000022255000000000000000000000003300335666555005550000000000000000000000550555
330033000000000000000000d22dd200000000000000000000000025588000000000000000000000330033005665555000000000000000000000000000000000
00330003000000000000000df22222f0000000000000000000000008888000000000000000000000003300035566550055055500000000000000000055055505
30300030303000000000000dff2222f0000000000000000000000222288000000000003030300030303000305665555000000000000000000000000000000000
000330330003300000000000ff111000000000000000000000000258888000000003303300033033000330335656555005550555055505550000000005550555
30303030303030000000000001111000000000000000000000000008228000000030303030303030303030305665555000000000000000000000000000000000
30300003303000300000000002112000000000000000000000000002222000000030000330300003303000035566550055055505550555055500000000055505
030303300303033000000000d2202200000000000000000000000022022200000303033003030330030303305665555000000000000000000000000000000000
00330033003300330000000ddd00dd00000000000000000000000082008880000033003300330033003300335666555005550555055505550555000005550555
330033003300330000000001d000dd00000000000000000000000028000280003300330033003300330033005665555000000000000000000000000000000000
00330003003300030000000011001110000000000000000000000288002800000033000300330003003300035566550055055505550555055505550000055505
77277767772777677727776777277767772777677727776777277767772777677727776777277767772777670777777777777770077777777777777007777777
00700070007000700070007000700070007000700070007000700070007000700070007000700070007000707666666666666665766666666666666576666666
22022002220220022202200222022002220220022202200222022002220220022202200222022002220220027666666666666665766666666666666576666666
82282228822822288228222882282228822822288228222882282228822822288228222882282228822822287666666666666655766666666666665576666666
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888887666666666666565766666666666656576666666
08280820082808200828082008280820082808200828082008280820082808200828082008280820082808207666665656565655766666565656565576666656
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007665656565656555766565656565655576656565
20002008200020082000200820002008200020082000200820002008200020082000200820002008200020080555555555555550055555555555555005555555
02000000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000002000000
00000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000002000000020
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200000002000000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000002000000020000000200000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000777777777777777777777777777777777777777777777777777700000000000000000000000000000000000000
00000000000000000000000000000000000077111111111111111111111111111111111111111111111111111177000000000000000000000000000000000000
00000000000000000000000000000000000711111111111111111111111111111111111111111111111111111111700000000000000000000000000000000000
000000000000000000000000000000000071111d0000000011111111111111111111111111111111111111111111170000000000000000000000000000000000
000000000000000000000000000000000711111d088888880000000000000011d000001d0000d00001d000001111117000000000000000000000000000000000
000000000000000000000000000000007111111dd0880008808888888088800d008880d08888008880d088801111111700000000000000000000000000000000
0000000000000000000000000000000071111111d0880d08800880008008880008880d08800880088800880d1111111700000000000000000000000000000000
0000000000000000000000000000000071111111d0880d088008800000088880888800880d088008888088011111111700000000000000000000000000000000
0000000000000000000000000000000071111111d0880d0880088880dd088088808800880d088008808888011111111700000000000000000000000000000000
0000000000000000000000000000000007111111d0880008800880001d088008008800880d088008800888011111117000000000000000000000000000000000
000000000000000000000000000070000711111d00880330800880dd000880d0d08800880d08800880d088011111117000070000000000000000000000000000
00000000000000000000000000071700711111d03088033300088000800880ddd088008800880d0880d088011111111700717000000000000000000000000000
0000000000000000000000000071117771111d03308800033088888880888011d08880088880d08880d088801111111777111700000000000000000000000000
000000000000000000000000071111111111d03330880d000000000000000000000000000000000000d000000000111111111170000000000000000000000000
000000000000000000000000057111777111d033308800880d03333330d0033330033333333033330dd033333330111777111750000000000000000000000000
000000000000000000000000005717557111d03308888880ddd033330dd033003303003300300330d1dd03300030111755717500000000000000000000000000
000000000000000000000000000575005711d0330000000d11d0300301d033000000d0330d000330111d03300000117500575000000000000000000000000000
000000000000000000000000000050000711d03330ddddd11d03300330dd03330dddd0330ddd0330111d033330dd117000050000000000000000000000000000
000000000000000000000000000000007111d033301111d0000333333000d0333011d033011d0330111d03300011111700000000000000000000000000000000
000000000000000000000000000000007111dd03330000033003300330030d003301d033011d03301d000330dd00111700000000000000000000000000000000
0000000000000000000000000000000071111dd0333333330d033003300330003301d033011d0330003003300030111700000000000000000000000000000000
00000000000000000000000000000000711111dd03333330d03330033300333330dd033330d03333333033333330111700000000000000000000000000000000
000000000000000000000000000000005711111dd000000dd0000000000d00000d1d000000d00000000000000000117500000000000000000000000000000000
0000000000000000000000000000000005711111ddddddd1ddddddddddddddddd11ddddddddddddddddddddddddd175000000000000000000000000000000000
00000000000000000000000000000000005711111111111111111111111111111111111111111111111111111111750000000000000000000000000000000000
00000000000000000000000000000000000577111111111111111111111111111111111111111111111111111177500000000000000000000000000000000000
00000000000000000000000000000000000055777777777777777777777777777777777777777777777777777755000000000000000000000000000000000000
00000000000000000000000000000000000000555555555555555555555555555555555555555555555555555500000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010206030700000900000103070009000000010101000008010101010108090000000000000000000101010101080801010100000000000307010101010000
0000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
86868686868686868686868686868686868686868686868686864040405151515700605151515151570000004040406051515151574040000000000042000000404040404040404062430060626186868686868686868686868686868686868686868686400000000000000000000000cfdf000000000000000000000000efff
86868686868686868686868686868686868686868686868686864040405162000000000000565151570000004040406051515151574040000000004200000000404040404040404051474356516186868686868686868686868686868686868686868686400000000000000000000000cfdf000000000000000000000000efff
86868686868686868485868686868686868686868686868686864040406200000000004662000000000000004040405751515756514040000000420000000000404040404040404062604743566186868686868686868686868686868686868684858686400000000000000000000000cfdf000000000000000000000000efff
86868686868686869495868686868686a082838686a0828386864040406200000060515151470000000060624040405151514700604040004040404040544c404040404040404040404040404040838686a0828386868686868686868686868694958686400000000000000000000000cfdf0000a58788898a8b8c8d0000efff
8182838686a082838686a082838686a0b092938081b09293808140404040405444404040404045554040404040404060576051475640000000000000004240404040404040404040404040404040938081b092938081838686a082838686a08283a08283400000000000000000000000cfdf00ae969798999a9b9c9daf00efff
9192938081b092938081b092938081b000000090910000009091926100000042465140404051474300005657404040606200565700400000000000004200404040404040404040404040404040400090910000009091938081b092938081b09293b09293400000000000000000000000cfdf00bea6a7a8a9aaabacadbf00efff
00000090910000009192000000919200000000000000000000000061000042465157404040626047430000515740605151620000004000000000004200004040404040404040405140564040404000000000000000000090910000009091000000000000400000000000000000000000cfdf0000b6b7b8b9babbbcbd0000efff
00000000000000000000000000000000000000000000000000000061004200606246404040515151474300565161605760570060474000000000420000004040404040404040405762004062404000000000000000000000000000000000000000000000400000000000000000000000cfdf000000000000000000000000efff
00000000000000000000000000000000000000000000000000004040404040544440404040404060514743005661565151570040404040404040404040404040404040404040005651574060404000000000000000000000000000000000000000000000400000000000000000000000cfdf000000000000000000000000efff
000000000000000000464e0000000000000000000000000000000061516200424640404040404062605147430061006057000040404040404040404040404040404040404040470057006256404000000000000000004e00000000000000000000000060400000000000000000000000cfdf000000000000000000000000efff
65000000636500000060610000000063644040404040000000006361570042465140404040404040404141414040414040454141414140404140404041414140404040404040620000625647404000004651624e0000616062000000000000004e006051400000000000000000000000cfdf000000000000000000000000efff
646500636461624662516100000063646461000000616465006364616242466256404040404040404053535340615340535343535353535353534053535353534040404040405147465147564040004e605151610000615151514e000000000061515151400000000000000000000000cfdf000000000000000000000000efff
41414141717271727172717241414141416100000061414141414141414141414141414141414040400000004061004000000043000000000000000000000000004040404040414141414141404041415444404041414041404040414141414140404140400000000000000000000000cfdf000000000000000000000000efff
53535353535353535353535353535353536100000061535353535300535353535353535353404040400000404061404000404000430000000000000000000000004040404040535353535353404053534253535353535353535353535353535353535353400000000000000000000000cfdf000000000000000000000000efff
4086404051626100000000616051404086000000000000000000000000000000000000000000000000000000000000000040400000430000000000000073646474646464746464750000000000000042004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40864040516261000000006160514040860000007e7e007e7e7e007e7e7e007e7e7e00000000007e7e7e007e007e00000040406500004300000000000000746464647464647576000000000000004200004040007e7e7e007e007e007e7e7e007e7e00007e007e00000000007e007e00007e7e007e007e000000007e007e0000
408640405651610000000061475640408600007e0000007e007e007e7e7e007e000000000000007e007e007e007e0000004040646500004300000000000073646464646475007600000000000042000000404000007e00007e007e007e007e007e007e007e007e00000000007e007e007e007e007e007e000000000000000000
408640404756610000000061514740408600007e0000007e7e7e007e007e007e7e0000000000007e7e00007e7e7e0000004040404555404040000000000000766474757600007700000000004200000000404000007e00007e7e7e007e7e7e007e007e007e7e0000000000007e7e7e007e007e007e007e0000007e0000007e00
408640405162610000000061625140408600007e007e007e007e007e007e007e000000000000007e007e0000007e0000004040000043000000000000000000777375007600000000004040404040404040404000007e00007e007e007e007e007e007e007e007e000000000000007e007e007e007e007e000000007e7e7e0000
408640405151610000000061605740408100007e7e7e007e007e007e007e007e7e7e00000000007e7e7e007e7e7e0000004040650000430000000000000000000000007600000000000040404040404040404000007e00007e007e007e007e007e007e007e007e00000000007e7e7e007e7e0000007e7e000000000000000000
4080404062606100000000615746404091000000000000000000000000000000000000000000000000000000000000000040406464650043000000000000000000000077000000000000004040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009040406200610000000061466240400000000000000000007e7e7e007e007e00007e7e007e007e00000000000000000040404040404040404000000000000000000000000000000000004040006100006100007e7e7e00007e7e007e7e7e00000000007e7e7e007e0000007e7e7e007e007e007e7e7e007e7e0000007e7e00
000040405162610000000061515740400000000000000000007e7e7e007e007e007e0000007e007e00000000000000000040400061006100610000000000000000000000000000000000004040006100006100007e0000007e007e007e007e00000000007e007e007e0000007e007e007e007e00007e00007e007e007e000000
000040405162610000000061604740400000000000000000007e007e007e007e00007e00007e7e7e00000000000000000040406561006165610000000000000000000000000000000000004040006100006100007e7e00007e007e007e7e0000000000007e7e7e007e0000007e7e7e007e7e7e00007e00007e007e007e000000
404040406262610000000061605140404000000000000000007e007e007e007e0000007e007e007e00000000000000000040406461636164616500000000000000000000000000000000634040006100006100007e0000007e007e007e007e00000000007e0000007e0000007e007e0000007e00007e00007e007e007e007e00
404040405444404040404040455540404000000000000000007e007e00007e7e007e7e00007e007e00000000000000000040406461646164616465006365000000636500000000006364644040006100006100007e0000007e7e00007e007e00000000007e0000007e7e7e007e007e007e7e7e007e7e7e007e007e007e7e7e00
4040000042000000565157565743565140000000000000000000000000000000000000000000000000000000000000000040404141414141414141414141000041414100004141414141414040006100006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040004200000000465746576057436040000000000000000000000000000000000000000000000000000000000000000048484848484848484848484848585848484858584848484848484848484848484848000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000171501715019150191501a1501a1501e1501e15023150231501e1501e1501a1501a150191501915017150171501714017140171301713217122171150010000100001000010000100001000010000100
0106000017550195501e5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001a5501e550235500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001362016630166301663015620146102362024630266222862229612000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001175000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000024630216401d6401a63019630176201760019600166001560015600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c1201d1201e1301f1301f1301f1301d1201b1201a1202460024600246002460024600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400002423025230262302723028220282202822228222262322523224232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001c6301c6301c6302b6302b6302b6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001133010330113301232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000216302364023640180001f6302164021640180001d6201f6301f6300c0001a6101c6201c6200000014630146201462314613146130000000000000000000000000000000000000000000000000000000
011400100253000500055300050004530005000553000500025300253205530005000453000500055300050000500005000050000500005000050000500004000040000500005000050000500005000050000500
010e00101a020190201702015020190201702015020130201e0201c0201a020190201c0201a020190201702000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000019020170201502013020170201502013020120201c0201a020170201a020190201702015020170201a020190201702015020190201702015020130201e0201c0201a020190201c0201a0201902017020
010e001019020170201502013020170201502013020120201002013020170201a0201902017020150201702000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e0010190201702015020130201602013020120200e020190201602013020120201a02019020170201502000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001a1401a1301a1201a1201c1401c1301c1201c12019140191301714015140151401513015120151121a1401a1301a1201a1201c1401c1301c1201c1201e1401e130261402314023130231202312023112
010e00002514025120251402512025140251202514025120251402314023130231202114021130231402313025140251302512025120251202512025120251202512025122251222512225112251122511225112
010e0000231402313023120231201f1401f1301f1201f12021140211301f1401e1401e1301e1201e1201e1121f1401f1301f1201f1201c1401c1301c1201c1201e1401e1301c1401b1401b1301b1201b1201b112
010e00001c1401c1301c1201c1201a1401a1301a1201a120191401913019120191201614016130161201612017140171201714017120161401612017140171301712017120171201712017110171101711217112
011000001f0401e0401d0401c0401b0401b0401b0301b032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01160020181301a1301b1301f130181301a1301b1301f1301d1301a130161301a1301d1301a130161301a1301b1301813014130181301b13018130141301813016130181301a1301b1301d1301a130161301a130
011600001f0501f0501f0501f0501f0501f0501f0501f0501a0501a0501a0501a0501a0501a0501a0501a0501b0501b0501b0501b0501b0501b0501b0501b0501d0501d0501d0501d0501d0501d0501d0501d050
010e00001c0401e0401f0402104023040230302302023020230202302021040210301f0401f0301c0401c0301e0401e0301e0201a0401a0301a02017040170301702017020170201702217022170221702217022
010e00001c0401e0401f0402104023040230302302023020230202302021040210301f0401f0301c0401c0301e0401e0301e02026040260302602023040230302302023020230202302223022230222302223022
010e0000240402604028040240402104021030210202102021020210201e0401e0302104021030210202102026040260302602024040240302402023040230302302023020230202302223022230222302223022
010e0000210401f0401e0401b04017040170301702017020170201702017040170301b0401b0301b0201b0201c0401c0301c0201b0401b0301b0201c0401c0301c0201c0201c0201c0221c0221c0221c0221c022
010e0000100401003010020100200b0400b0300b0200b0200b0200b0201204012030120201202012020120200e0400e0300e0200e0200e0200e0200b0200f0401204015040170401504013040120401203012020
010e0000180401803018020180201504015030150201502015020150201204012030120201202012020120200e0400e0300e0200e0200e0200e0200b0200f0401204015040170401504013040120401203012020
010e00001504015030150201502012040120301202012020120201202012020120200f0400f0300f0200f0201004010030100200b0400b0300b02004040040300402004020040200402004022040220402204022
01100000211502114021122211121f1501d1501c1501a1501f1501f1401f1221f1121c1501a15018150171501d1501d1401d1321d11217150181501a1501d1501c1501c1501c1421c1321c1221c1120000000000
011000001d1501d1401d1221d11217150181501a1501d1501c1501c1401c1221c112131501515017150181501a1501a1401a1321a112131501515017150181501515015150151421513215122151120000000000
01100000211502114021122211121f1501d1501c1501a1501f1501f1401f1221f1121c1501a15018150171501d1501d1401d1321d11217150181501a1501d1501c1501c1501c1421c1321c1221c1120000000000
011000001d1501d1401d1221d11217150181501a1501d1501c1501c1401c1221c112131501515017150181501a1501a1401a1321a112131501515017150181501515015150151421513215122151120000000000
010e00001f0501f0301f0501f030210502205022040220321f0501f0301f0501f0302105022050220402203221050210401d0501d0301d0501d0301a0501f0501f0501f0501f0501f0421f0321f0221f0121f000
010e00001f0501f0301f0501f030210502205022040220321f0501f0301f0501f0302105022050220402203224050240402105021040270502704026040260502604026030260222601225050250402605026040
010e000027050270302705027030290502b0502b0402b03029050290502905029050290402903029022290122a0502a0302a0502a0302b0502d0502d0402d0302e0502e0502e0502e0502b0402b0302d0402d030
010e00002e0502e0302e0502e0302d0502b0502b0402a0502a0402a0302605026030260502603026050260302705027040260502604024050220502204022030210502105021040210301d0501d0501d0401d030
010e00001302015020160201a0201302015020160201a0201302015020160201a0201302015020160201a020130200e0201302016020130200e02013020160201302015020160201a0201302015020160201a020
010e00001302015020160201a0201302015020160201a0201302015020160201a0201302015020160201a0201802015020180201b0201802015020180201b0201a020160201a0201d0201a020160201a0201d020
010e00001b020160201b020160201b020160201b020160201d0201a0201d020210201d0201a0201d020210201e0201a0201e0201a0201e0201a0201e0201a0201f0201a0201f020210201f0201a0201f02021020
010e00001b020160201b0201f0201d0201a0201d020210201f0201b0201f02022020210201d020210202402022020210201f0201e0201b0201a0201802016020150201102015020110200e020110201502011020
0003000015540125300d5201c5001c550225402a53000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010a00002105021030210402103023040230302404024030210502103021040210302304023030240402403023050230301f0401f0301f0401f0301c0401c0302104021040210402104021040210302102221012
010a00002105021030210402103023040230302404024030210502103021040210302304023030240402403026050260302304023030290402903028040280302404024040240322402226040260302804028030
010a0000290502903024040240302b0402b0302d0402d0302b0502b0502b0502b0502b0402b0322b0222b0122c0502c03028040280302d0402d0302f0402f030300503004030032300322d0402d0302f0402f030
010a0000300503003030040300302f0402f0302d0402d0302c0402c0302804028030280402803028040280302905029030280402803026040260302404024030230502304023030230221f0401f0401f0321f022
010a0000150301503015020150101c0301c0301c0201c010180301803018020180101503015030150201501017030170301703017030170301703017020170101503015030150301503015030150301502015010
010a0000150301503015020150101c0301c0301c0201c010180301803018020180101503015030150201501017030170301703017030170301703017020170101c0301c0301c0301c0301c0301c0301c0201c010
010a00001d0301d0301d0201d0101c0301c0301c0201c010180301803018020180101703017030170201701015030150301502015010140301403014020140101103011030110201101010030100301001010020
010a0000180301803018020180101503015030150201501015030150301502015010100301003010020100101403014030140301403014030140301402014010100301003010020100100b0300b0300b0200b010
000600000925009250092500c2500f2501025011250112501125011250102500e2500c2500b2500b2500b25009250082500825008200082300820008220082000820008210006000060000600006000060000600
011000001a1251a1251c1351c1351d1451d1451f1551f1551a1551a1551c1551c1551d1551d1551f1551f15521155211551f1551f155211552115524155241551d1551d1551d1551d1551a1551a1451a1351a125
011000001a0351c0451e055210551a0551c0551e055210551f0551c05519055150551f0551c055190551505517055190551a0551c0551a0551c0551e055210551f05521055230552505526045260352602526015
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 0e424344
01 130f4344
00 14104344
00 15114344
02 16124344
04 17424344
01 18594344
02 18194344
01 1a1e4344
00 1b1e4344
00 1c1f4344
02 1d204344
01 21234344
00 22234344
00 24254344
00 24254344
01 25294344
00 262a4344
00 272b4344
02 282c4344
01 2e324344
00 2f334344
00 30344344
02 31354344
02 36424344
04 37424344
04 38424344
