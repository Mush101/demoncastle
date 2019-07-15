pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
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
function a:bh(bj)
bk={}
for v=self.b,self.b+self.d-1,8 do
add(bk,v)
end
add(bk,self.b+self.d-1)
bl={}
for v=self.c,self.c+self.e-1,8 do
add(bl,v)
end
add(bl,self.c+self.e-1)
for v in all(bk) do
for bm in all(bl) do
if ba(v,bm) then
return true
end
end
if ba(v,self.c+self.e-1) then
return true
end
end
return false
end
function a:bn()
self:bo()
self:bb()
end
function a:bo()
self.g+=self.i
self.g=bp(0,self.g,self.j)
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
function a:bq()
self.u={}
end
function a:br()
if not self.u then return end
for r in all(self.u) do
r:n()
end
end
function a:bs(m)
if not self.u then return end
add(self.u,m)
m.bt,m.pal=self,self.pal
end
function a:bu()
if not self.bt then return end
self.b=self.bt.b
self.c=self.bt.c
end
function a:bv()
return self.b<bw.b-self.d-32 or self.b>bw.b+128+32
end
function a:bx()
return self.b+self.d>=bw.b and self.b<bw.b+128 and self.c+self.e>=bw.c and self.c<bw.c+112
end
function a:by(m)
if self.b+self.d<m.b then return false end
if m.b+m.d<self.b then return false end
if self.c+self.e<m.c then return false end
if m.c+m.e<self.c then return false end
return true
end
function a:bz(z,ca)
if self:by(z) then
if not self.r or not z.r then
return true
end
rectfill(0,0,16,8,0)
spr(self.r,0,0,1,1,self.t)
spr(z.r,8,0,1,1,z.t)
cb,cc=z.b-self.b,z.c-self.c
for b=max(0,cb),min(7,7+cb) do
for c=max(0,cc),min(7,7+cc) do
cd,ce=pget(b,c),pget(8+b-cb,c-cc)
if cd!=0 and ce!=0 then
return true
end
end
end
if z.u and ca then
for m in all(z.u) do
if m.cf and self:bz(m,ca) then return true end
end
end
end
return false
end
function a:cg(ch)
if self.bt then
self.bt:cg(ch)
end
end
function a:ci()
if self.cj==1 then
self.pal=ck
end
end
function a:cl()
cm(cl:l({b=self.b+rnd(self.d),c=self.c+rnd(self.e)}))
end
function a:cn()
if self.co then
self.co+=cp
self.cq+=cp
end
return self
end
bw=a:l({cr=0.5,cs=true})
function bw:n()
if ct.cu then
self.cr=0.5
local cv=self.c
self:cw()
if self.c!=cv then
cx=40
self:cy()
if not cz then
ct:da()
end
end
else
self.cr=2
end
self:db()
self.b=bp(self.dc,self.b,self.cr)
if self.b<=0 then
self.b=0
end
for m in all(dd) do
if(m.c>=bw.c and m.c<bw.c+112) m:de()
if(m.df) del(dd,m)
end
end
function bw:db()
if self.dg then
self.dg=false
else
self.dc=ct.b-60
end
end
function bw:cy()
self:db()
self.b=self.dc
end
function bw:cw()
if ct.c<=104 then
self.c=0
else
self.c=112
end
end
function bw:dh()
camera(self.b,self.c-16)
if not di then
clip(0,0,128,112)
camera(self.b,self.c)
end
end
ct=a:l({r=0,e=14,j=0.5,h=1,dj=0,
dk=0,dl=0,dm=0,
dn=0,dp=0,cs=true,
dq=0})
function ct:n()
self.dr,self.ds,self.pal=self.b,self.c,dt
if self.cq<=0 then
self:cl()
end
if self.dn==0 and self.dp>0 then
self:du()
end
if self.dn==0 and self.dp==0 then
self.q=false
end
if not self.cu then
if self.dn==0 then
if self.cq>0 then
if btn(1) and not btn(0) then
self.i=1
if self.dl==0 then
self.t=false
end
elseif btn(0) and not btn(1) then
self.i=-1
if self.dl==0 then
self.t=true
end
else
self.i=0
end
self.e=14
if self:bh() then
self.c-=2
end
if self:x() and dv and not di then
self.f=-dw
end
end
self:bn()
if abs(self.g)<0.1 then
self.dj=1.9
end
if self:x() and btn(2) then
self:dx()
elseif self:x() and btn(3) and dy==0 then
self:dz()
end
else
self:ea()
self:bn()
end
end
if self.cu then
if self.dn>0 then
self:du()
end
self.g=0
local eb,ec=1,0
if self.ed then
eb,ec=0,1
end
if self.cq>0 then
if btn(2) and not btn(3) then
self.dk+=1
self.t=self.ed
elseif(btn(3) and not btn(2) or btn(ec)) and dy==0 then
self.dk-=1
self.t=not self.ed
elseif btn(eb) then
self.dk+=1
self.t=self.ed
end
end
if self.dk>=6 then
self.dk=0
self.c-=2
if self.t then
self.b-=2
else
self.b+=2
end
self.dj+=1
if self.c%4==0 then
sfx(5)
else
sfx(6)
end
elseif self.dk<=-6 then
self.dk=0
self.c+=2
if self.t then
self.b-=2
else
self.b+=2
end
self.dj+=1
if self.c%4==0 then
sfx(5)
else
sfx(7)
end
end
self:ee()
end
if ef and self.dl==0 and self.dm==0 and self.cq>0 and not di then
self.dl=0.1
sfx(4)
end
if self:x() then
self.dj+=abs(self.g)/10
end
self.dj=self.dj%4
self.r=flr(self.dj)
if self.r==3 then
self.r=1
end
self.dq=self.r
if self.dm>0 then
self.dm-=1
self.r=6
if self.dm<=0 then
self.dl=0
end
else
if self.dl>0 then
self.dl+=0.25
if self.dl<2 then
end
if self.dl>=4 then
self.dm=10
self.r=6
else
self.r=3+flr(self.dl)
end
end
end
if self.cu then
if self.c<-8 then
self.c+=224
self.b+=eg*8
bw:cy()
elseif self.c>224-8 then
self.c-=224
self.b-=eg*8
bw:cy()
end
end
if self.b<bw.b then
self.b=bw.b
end
if not self.cu and self.c>=bw.c+104 then
self.cq=0
end
if self.cq<=0 and self.dn==0 then
eh=eh or 90
ei(5)
self.q,self.g,self.i=true,0,0
end
self:br()
end
function ct:da()
ej,ek,el,em,en=self.b,self.c,self.cu,self.t,self.ed
end
function ct:x()
for m in all(eo) do
if m.ep then
return true
end
end
return a.x(self)
end
function ct:dz()
local eq,er=flr((self.b+4)/8),flr((self.c+16)/8)
for add=-1,1 do
es=eq+add
local et=eu(es,er,1)
local ev=eu(es,er,2)
if et and not(ev and add==-1) and not(not ev and add==1) then
self.cu=true
self.b=es*8
self.c=er*8-14
if ev then
self.b-=2
else
self.b+=2
end
self.dj=1
self.ed=ev
self.t=not ev
self.dk=-10
end
end
end
function ct:dx()
local eq,er=flr((self.b+4)/8),flr((self.c+10)/8)
for add=-1,1 do
es=eq+add
local et=eu(es,er,1)
local ev=eu(es,er,2)
if et and not(ev and add==1) and not(not ev and add==-1) then
self.cu=true
self.b=es*8
self.c=er*8-6
if ev then
self.b+=6
else
self.b-=6
end
self.dj=1
self.ed=ev
self.t=ev
self.dk=10
end
end
end
function ct:ee()
if self.c%8!=2 then return end
if self.c>=208 then return end
if self.c<0 then return end
local es,ew=self.b+4,self.c+8
if self.ed==self.t then
if not self.ed then
es+=8
else
es-=8
end
else
ew+=8
end
if not ex(es,ew,1) then
self.cu=false
end
end
ey=a:l({r=16,e=6,cf=true})
function ey:n()
self:bu()
self.pal=self.bt.pal
self.c+=8
self.t=self.bt.t
self.r=16+self.bt.dq%2
if self.r==16 and self.bt.cu then
self.r+=2
if self.bt.t!=self.bt.ed then
self.r+=1
end
end
if not self.bt:x() and not self.bt.cu then
self.r=20
end
end
function ct:cg(ch)
if self.dn==0 and self.dp==0 and self.cq>0 then
sfx(12)
self.cq-=1
self.dn,self.dp=24,24
if not self.cu then
self.f,self.i=-1.5,0
end
if ch.b>self.b then
self.g,self.t=-0.5,false
else
self.g,self.t=0.5,false
end
end
end
function ct:ea()
if self.g>0 then
self.g=self.h
else
self.g=-self.h
end
self:du()
end
function ct:du()
if self.dn>0 then
self.dn-=1
self.pal=ez
else
self.dp-=1
end
self.q=not self.q
end
fa=a:l({r=32,fb=0,fc=2,fd=0,d=3,e=3})
function fa:n()
self.dr=self.b
self.ds=self.c
if self.bt==ct then
self:bu()
local fe=-4
local ff=3
if ct.r==4 then
fe=-1
ff=-1
elseif ct.r==5 then
fe=3
elseif ct.r==6 then
fe=4
ff=6
end
self.fb=0.5-ct.dl/8
self.fd=0.0625-ct.dl/64
if ct.dm>0 then
self.fd=0
self.fb=0
end
if ct.t then
self.fb=-(self.fb-0.25)+0.25
self.fd=-self.fd
fe=-fe
end
self.b+=3+fe
self.c+=ff
self.q=ct.dl<=0
else
self.fd=self.bt.fd
self.fb=self.bt.fb+self.fd
self.fc=self.bt.fc
self.q=self.bt.q
self:bu()
self.b+=self.fc*cos(self.fb)
self.c+=self.fc*sin(self.fb)
end
if not self.q then
for m in all(eo) do
if m.fg and self:bz(m,true) then
m:cg(ct)
elseif m.fh and self:bz(m) then
m:fi()
end
end
end
self:br()
end
function fa:fj(fk)
self.fk=fk
if fk>0 then
self:bq()
local fl=fa:l()
fl:fj(fk-1)
self:bs(fl)
end
end
fg=a:l({fg=true,cq=1,cj=1,j=0,fm=0.25,t=true,dn=0})
function fg:ea()
if self:x() then
self.dn-=0.5
if self.cq>0 then
self.dn-=0.5
end
self.h=self.fm
else
self.h=1
if self.g>0 then
self.g=self.h
else
self.g=-self.h
end
end
self.pal=ez
self.q=not self.q
if self.cq<=0 then
self:cl()
end
end
function fg:cg(ch)
if self.cq<=0 then
return
end
if self.dn==0 then
self.cq-=1
self.dn=12
self.f=-1.5
self.i=0
if not self.fn then
if ch.b>self.b then
self.g=-0.5
self.t=false
else
self.g=0.5
self.t=true
end
end
if self.cq<=0 and self.fo then
sfx(self.fo)
elseif self.fp then
sfx(self.fp)
end
end
end
function fg:fq()
if self.cq<=0 then
self.df=true
end
return not self.df
end
function a:fr(fs)
if fs or(self.dn==0 and self.cq>0) then
if self:bz(ct,true) then
ct:cg(self)
return true
end
if self.u then
for m in all(self.u) do
m:fr(true)
end
end
end
end
function fg:ft()
ft,fu=self.cq,self.co
end
fv=fg:l({r=15,e=14,fw=0.05,fo=9})
function fv:o()
self:bq()
self:bs(fx:l())
self:ci()
self.c+=2
self.t=true
self:br()
end
function fv:n()
if self:bv() then
self:br()
return
end
if self.dn>0 then
self:ea()
else
if self:fq() then
self.q=false
self.h=self.fm
self.i=0.1
if self.t then
self.i=-0.1
end
self:ci()
end
end
self:bn()
if self.dn<=0 then
if abs(self.g)<=0 or not(self:x(true) and self.f>=0) then
self:fy()
end
self:fr()
end
self:br()
end
function fv:fy()
self.t=not self.t
self.g=-self.g
end
fx=fg:l({dj=0,fg=true,cf=true})
function fx:n()
self:bu()
self.c+=8
self.t=self.bt.t
self.dj+=self.bt.fw
self.dj=self.dj%2
self.r=30+self.dj
self.pal=self.bt.pal
end
cl=a:l({fz=3,cs=true})
function cl:n()
self.c-=0.5
self.fz-=0.4
if self.fz<=0 then
self.df=true
end
end
function cl:p()
circfill(self.b,self.c,self.fz,7)
end
ga=fg:l({r=26,bd=true,bg=true,bf=1,fm=1,fp=10,gb=0})
function ga:o()
self:ci()
end
function ga:n()
if self:bv() then return end
if self.dn>0 then
if not self:bh() then
self.bg=false
end
self.bd=false
self:ea()
self:bn()
self:gc()
else
self.bg=true
self.bd=true
self.q=false
self:ci()
if self:fq() then
if self.gd then
self.t=self.b>ct.b
if self.t then
self.i=-0.05
else
self.i=0.05
end
if self.c>ct.c then
self.be=-0.05
else
self.be=0.05
end
self:bn()
self:fr()
self:gc()
end
if ge(self.b,self.c,ct.b,ct.c)<32 then
self.gd=true
end
end
end
if self.c<bw.c+4 then
self.c=bw.c+4
end
end
function ga:gc()
self.gb=(self.gb+0.2)%2
self.r=27+self.gb
end
gf=ga:l({cq=6,r=194,fo=13,co=6})
function gf:n()
ga.n(self)
self:gc()
if self.gd then
if self.b<=bw.b and self.b>bw.b-8 then
self.b=bw.b
end
self.b=min(self.b,bw.b+120)
end
self:br()
if gg==2 or gg==6 then
self:ft()
end
end
function gf:o()
self:ci()
self.gb=0
self:bq()
self:bs(gh:l())
self:bs(gh:l({t=false}))
self:br()
end
function gf:gc()
self.gb=(self.gb+0.1)%2
self.gi=192+self.gb
self:br()
end
gh=fg:l()
function gh:n()
self:bu()
self.r,self.pal=self.bt.gi,self.bt.pal
if self.t then
self.b+=8
else
self.b-=8
end
end
gj=fg:l({r=29,cq=3,gk=true,gl=0,fo=11})
function gj:n()
if self.dn>0 then
self:ea()
else
self:ci()
if self:fq() then
self:fr()
if not self:bv() then
self.gl+=1
if self.gl>120 then
local t=gm:l({b=self.b,c=self.c+3,gn=self.t})
cm(t)
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
self:gc()
self:ci()
if self:bv() then
self.df=true
end
if self.gn then
self.b-=self.g
else
self.b+=self.g
end
if self:bz(ct,true) then
ct:cg(self)
self.df=true
end
end
function gm:gc()
self.r,self.t=84-self.r,self.gn
end
go=gm:l({r=41,gl=0,cj=1,g=1,gp=1})
function go:gc()
self.gl+=1
if self.gl>6 then
self.r+=self.gp
if self.r==44 or self.r==40 then
self.t=not self.t
self.gp*=-1
end
self.gl=0
end
self:ci()
end
gq=fg:l({r=8,e=16,cq=5,co=5,fm=0.5,gr=32,gs=0,gt=0,fo=11})
function gq:o()
self:bq()
self:bs(gu:l())
self:bs(gv:l())
self:br()
end
function gq:n()
if self:bx() then
if self.dn<=0 then
if self:fq() then
self.q=false
self:ci()
self.h=self.fm
if self.b>ct.b then
self.t,self.i=true,-0.02
else
self.t,self.i=false,0.02
end
local fc=abs(self.b-ct.b)
if fc<self.gr then
self.i*=-1
end
if self.gt>0 then
self.gt-=1
if self.gt==11 then
local t=go:l({b=self.b,c=self.c+3,gn=self.t})
cm(t)
t:n()
self.gs=60
end
else
if self.gs==0 then
self.gt=15
end
self.gs=max(0,self.gs-rnd(2))
end
self:fr()
end
else
self:ea()
end
self:bo()
self:br()
end
if gg==3 then
self:ft()
end
end
gu=fg:l({r=24,gl=0,cj=1})
function gu:n()
self:bu()
self.c+=8
self.t,self.q,self.pal=self.bt.t,self.bt.q,self.bt.pal
self.gl+=abs(self.bt.g)
if self.gl>4 then
self.gl,self.r=0,49-self.r
end
end
gv=fg:l()
function gv:n()
self:bu()
self.t,self.q,self.pal=self.bt.t,self.bt.q,self.bt.pal
local gw=6
if self.t then gw*=-1 end
self.b+=gw
if self.bt.gt>10 then
self.r=9
elseif self.bt.gt>0 then
self.r=10
self.c+=1
else
self.q=true
end
end
gx=fg:l({r=13,gl=0,bg=true,fp=10,cs=true})
function gx:o()
self.b=bw.b+127
self.gy=max(ct.c+rnd(16)-8,bw.c+16)
self.c=self.gy
if rnd(10)<5 then
self.gl=0.5
end
end
function gx:n()
if self:bv() then
self.df=true
end
if self.dn>0 then
self:ea()
self:bn()
else
self:ci()
if self:fq() then
self:fr()
end
self.b-=1
self.gl=(self.gl+0.01)%1
self.c=self.gy+sin(self.gl)*12
end
end
gz=a:l({gl=60})
function gz:n()
if ct.b<self.b and ct.b>self.b-256 then
self.gl+=1
if self.gl>=90 then
self.gl=0
local ha=gx:l()
ha:o()
cm(ha)
end
end
end
hb=fg:l({r=11,fp=10,cq=3,hc=1})
function hb:n()
if(not self:bx()) return
self.r=11
if self.dn>0 then
self:ea()
self:bn()
else
self.q=false
self:ci()
self.h=2
if self:fq() then
if self:x() then
self.g=0
self.hc-=0.1
if self.hc<=-2 or rnd(100)<5 then
self.f,self.g,self.hc=self.hc,self.hc/2,0
if(ct.b>self.b) self.g*=-1
if(rnd(9)<2) self.g*=-1
end
else
self.r=12
end
self:bn()
self:fr()
end
end
end
hd=hb:l({cq=6,r=208,fo=13,co=6,e=16,d=16})
function hd:o(he)
self:bq()
self:bs(hf:l():flip())
self:bs(hg:l():o(he))
self:ft()
end
function hd:n()
hb.n(self)
if self.b<=bw.b+1 then
self.b=bw.b+1
end
self.r+=197
self.t=false
self:br()
self:ft()
end
hg=fg:l({cf=true})
function hg:o(he)
self:bq()
self:bs(hf:l())
if(he) self:bs(hg:l():o())
return self
end
function hg:n()
self:bu()
self.r,self.pal,self.q,self.bt.fn=self.bt.r+16,self.bt.pal,self.bt.q,true
self.c+=8
self:br()
end
hh=fg:l({r=229,cq=6,co=6,d=16,e=16,gl=0,q=true})
function hh:o()
hd.o(self)
end
function hh:n()
self:ft()
if(self:bv()) return
dy=8
self.gl+=1
if self.gl>20 then
self.gl,self.r=0,459-self.r
end
if self.dn>0 then
self:ea()
self:bb()
self.cq=0
else
self.c,self.q=176+sin(hi)*3,false
if self:fq() then
self:fr()
else
hj=hk:l():o()
cm(hj)
ei(24)
end
end
self.t=false
self:br()
end
hk=fg:l({r=210,cq=9,co=9,gl=0,d=16,e=24,b=400,c=128})
function hk:o()
hd.o(self,true)
self:bs(hl:l())
self:bs(hl:l({t=false}))
return self
end
function hk:n()
self:ft()
if(self:bv()) return
if self.cq<=0 then
self.gl,self.r=bp(0.25,self.gl,0.01),212
self:hm()
ei(-1)
if self.gl==0.25 then
hn=true
if(ho>=3) hp=true
end
elseif self.dn>0 then
self.dn-=1
self.q=not self.q
else
dy=min(dy+0.5,46)
self.q=dy<46
if not self.q and not eh then
self.gl=(self.gl+0.008)%1
self.r=210+self.gl*2
self:hm()
self:fr()
end
end
self.t=false
self:br()
end
function hk:hm()
if(hn) return
self.c=140+max(-0.5,sin(self.gl))*30
end
hl=fg:l({r=240})
function hl:n()
local ha=-1
if(self.t) ha=1
local gl=self.bt.gl*2+0.4*ha
self:bu()
self.b+=ha*(cos(gl)*-15+16)+4
self.c+=cos(gl)*8+20
end
hq=a:l({r=58,cs=true})
function hq:n()
local gl=hr+self.hs/3
if ht then
self.r=55
self:bb()
else
local hu=dy-3*sin(hi)
self.b,self.c=bw.b+60+sin(gl)*hu,bw.c+36+cos(gl)*hu
end
end
hv=a:l({d=16,e=3,r=48,cr=0.005,hw=0,hx=0})
function hv:o()
self.hy,self.hz,self.ia=self.b,self.c,0
self:bq()
self:bs(hf:l())
end
function hv:n()
self.ep=false
if ct.b>self.b-8 and ct.b<self.b+self.d then
if ct.c+ct.e>=self.c and ct.ds+ct.e<=self.c+self.e then
ct.c,ct.f=self.c-14,0
self.ep=true
end
end
local dr,ds=self.b,self.c
self:hm()
if self.ep then
ib,ic=ct.b,ct.c
ct.b+=self.b-dr
ct.c+=self.c-ds
if ct:bh() then
ct.b,ct.c=ib,ic
end
ct:br()
end
self:br()
end
function hv:p()
local dr=self.b
if self.ep then
self.b=ct.b-flr(ct.b-self.b)
self:br()
end
a.p(self)
self.b=dr
self:br()
end
function hv:hm()
self.ia=(self.ia+self.cr)%1
self.b,self.c=self.hy+self.hw*sin(self.ia),self.hz+self.hx*sin(self.ia)
end
id=hv:l({hw=0,hx=0,cr=0.003})
function id:o()
hv.o(self)
self.fk=self.c-self:ie()
end
function id:hm()
self.ia=(self.ia+self.cr)%1
local ig=sin(self.ia)/15
self.b,self.c=self.hy+self.fk*sin(ig),self:ie()+self.fk*cos(ig)
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
add(dd,self)
end
function ih:de()
if(self.ii and ct.c>self.c+16) return
if self.b+8>=ct.b then
bw.b=min(bw.b,self.b-120)
else
self:ij()
end
end
function ih:ij()
if self:bx() and abs(self.b-ct.b)<16 then
self.df=true
end
end
ik=ih:l()
function ik:de()
if self.b<=ct.b then
bw.b=max(bw.b,self.b)
else
self:ij()
end
end
il=ik:l()
function il:de()
if ct.b>=self.b then
bw.dc,bw.dg=self.b,true
if not im and not eh then
ei(6)
end
end
end
hf=a:l({cf=true})
function hf:n()
self:bu()
self.b+=8
self.r,self.pal,self.q=self.bt.r,self.bt.pal,self.bt.q
end
function hf:flip()
self.t=true
return self
end
io=a:l({r=61,f=-2,q=true})
function io:o()
self.c+=8
end
function io:n()
if not self:bh() then
self.q=false
self:bb()
if self:bz(ct,true) then
ct.cq,self.df=ip,true
sfx(2)
end
end
end
iq=a:l({fh=true,ir=49})
function iq:fi()
self.fh=false
mset(self.b/8,self.c/8,0)
self.df=true
for v=0,1 do
for bm=0,1 do
cm(is:l({r=self.ir,b=self.b+v*4,c=self.c+bm*4,f=-2+bm,i=(v-0.5)/8,t=v==bm}))
end
end
for m in all(dd) do
if m.b==self.b then
m.df=true
end
end
sfx(8)
end
is=a:l({it=30,d=4,e=4,j=0,bg=true,cs=true})
function is:n()
self:bn()
self.it-=1
if self.it<=0 then
self.df=true
end
end
iu=a:l({r=57,q=true,f=-2})
function iu:o()
self.b-=36
end
function iu:n()
if not self:bx() then return end
if self.q then
if bw.b>self.b-80 or self.fs then
self.q=false
for m in all(eo) do
if m.fg and m:bx() then
self.q=true
end
end
if not self.q then
self:iv()
end
end
else
self:bb()
if self.f<0 then
self:cl()
end
if self:bz(ct,true) then
self.df=true
self:iw()
end
end
end
function iu:iw()
sfx(3)
ix=true
im=true
ei(-1)
end
function iu:iv() end
iy=iu:l({r=58,fs=true})
function iy:iw()
sfx(3)
ho+=1
iz=true
end
function iy:iv()
if iz then
self.df=true
cm(io:l({b=self.b,c=self.c}))
end
end
ja=iy:l({r=56})
function ja:iw()
sfx(3)
jb,iz=true,true
end
jc=a:l()
function jc:n()
if(not self:bx()) return
self.jd=je
if self.jf then
self.jd=jg
end
if abs(self.c-ct.c)<16 then
jh[cp+2]=ji[self.jd].jj
end
if self:bz(ct) then
jk,im=self.jd,true
cp+=1
end
end
jl=a:l()
function jl:n()
if self:bz(ct) then
if jb then
mset(31,25,0)
mset(31,26,0)
sfx(45)
for m in all(eo) do
if(m.b<280) m.ii=true
end
jb=false
end
self.df=true
end
end
ji=
{
{jm="000000001i?+??+??+??+??+Hh7wy?+3S?PERSC:2P?:3B?+1S?S?+1xh+1xh+1x:2h?:3AEARCS?+8:2?hy?w7?+2T?+1C?TC?+1AB?S?S?+1xh+1xh+1xh?+1C?+1CT?zQB?+5ywymy?+2zA+1DA+1D:jA?A+1?T?S?+1xh+1xh+1x:jh?ADA+1DAQA+2B?u+2:ju1+30+15lt+7?A+1B?+1T?NXUZNONON?t+6NXUZMfvfvj+40j3J+6z?A+2?+42?xzBx?+2J+72JNO?L?L?0+5?3?+3zA+1?A+2B?+22?+1xA+1xB?+2e?+42?NOM?L?L?+10?0+3B3zBzA+1:kA?A+3B?2ezAxA+1xA:kB?+1x?+1e?2?NONO?L?L?+20+6s+5?s+4NONONO1+4?ONONONONONOM8+3?+??+??+??+??+HA+5R?+1PA+4:2A?:3B?+3S?+3S?+1S?:2?+3zA+1QA+dR?+5PA+3?QAB?+1T?+3S?+1T?+1zANO1+cAER?+9PAE?A+1QAQB?+3T?+2z:jAQNONONOj+9?C?+8zB?+1C?1+40+15l1+6NONOh+1NONONO?+4BC?+1zB?/ef/?zAQABC?Oj+63j+3NONOy/A/?why/z/w:gNO:2N+5ADBzQAB/uv/zQA+1QA:jD?NONOABzB?3?+1zB/y/h+1y/P/6ywn/P/wMNO+5t+f?ONONOAQA+1B3zQ:nA/O/hywh+1nwhywNON+5J+f?NO?+1NOt+5NONONONONONONONO+5"},
{jn=4,jo=58,jp=16,jq=82,jr="the path splits here...",je=3,jg=4,gw=-58,jm="g5820e2835/6/+p0+2h+3n?wh+4n?+10+2wh+3n:20+1?+42?+20:20+4:30+1y3?w:3yx/6+5:e6+e:26/0/6/+p0+2hy?+6mh:0hn?+10+2wh+3n0+1?+32?+30+7h73mhx/6/+l0/6+7456/+f0+2y?+46y?+60+2nwhnmh0+1?+22?+40+7yw73mx/6+h456/+10/6+7kl6+5w236+1w236/+10+2y?+2wh+27?+3wy0+2h+27?w0+1?0+4kc0/+e36+1w236+b:fkl6/+10/1236+1w236+1w236+1wMij01Mij01/0+4k40+45l0+6wnwh7m0?+2;1?+320/+fj01Mij0136+1w236+1w23w23/0/hij01Mij01Mij01M/?/+2gh/?/+2gh/?x?+226h0+2h73?+1mn0+2wy?mn?0?+52?0+f?/gh/?/+2ghj01Mij01MijMij/0?/+2gh/?/+2gh/?/+2gh/?+bx?+126;0hn0+2yw73?+1hn0wh+1y?+2:90?+42?+10+8h0m0+3?/+8gh/?/+2gh/?+50?+qx?2?wy60+2h+273?mhxwnwn?w7:90?+32?+20+8ny?0y0+1?+f:d?+50?+p0+4k40+5wh73?mx;0mh+1n?0+i?mhn0w0+1?+l0?+86e?+fxhy?260+5ywh73?x?wn?+10+i7?n?ym0+1?+7e?+bw0B?+2zB?+2wx?+3zA0+4?+3zx:0n?26h0+71+20+110+151+30+110+21+20+6y?+1ym70+1?+16hye?+1xwy?+6e?wh0AB?zAxy6yhx?+2zA+1x?+2xAB?zAxy26ym0+7j+20xj0j+13j+60j+40+5h76h7m0+1?ewh+1x?+1xh+2e?+4xh+201+3NONONONO1+4x?+2x1+f0+2?+20x?0+1?+13?+c0+41+50+11+1k40+11+1010+21+40+110+1j+gx?+2xj+e0+3?+10+1x0+2?+23?+b0+4j+50+1j+12j+i0/6:36/0+1hyx?+3xwh0+1:2/6/+10+u:30+1?+13?+6PA+1QA+2QA+1R?+62?0:20/+i6/+10+1hyx?+3xwh0/+16/+10+wB?+13?+6QA+2QA+1RS?+62?+1:80/+j6/+10+1mhx?+3x7m0/+16/+10+wAB?+13?+5PA+4R?S?+52?+2:90/+j6/+10+17mx?+3xh70/+16/+10+x5l0+2?+5SAQRS;1?+1T?+42?+3:90/+j6/+10+1hyx?:7?+2xyh0/+16w/0+w?+13?+8TPR?S?+40/+r36/0+1h+1x?+3xw:hn0/+11M/0+wB;0?+13?+bS?+50/+qj0/0+1ywx?+3xn60/+1h/?0+wA+1B?3?+aT?+60+1?x?+1x?/+jg/0+1y?x?+3x6y0+1?+10+D?+g0+1?x?+1x?+k0+1hyx?+3xhn0+1?+10+w?x?x?x?+c:4?+40+1?x?+1x?+k0+1hyx?+2:c?xw70+1?+10+wBx?xBx?+h0+1?x?+1x?+j0+2y+1x?+3xwh0+2?0+wAxzx:0AxB?+6:0?+8z0+1?x?+1x?+j0+2k40+55l0+2?0+wAxAxAxAB?zB?+2zB?+1;a?+2zA+10+1?x?+1x?+i0+1?+12?+2mhnmn3mh0+y1+a?+11+2?+11+50+1?x?+1x?+i0+1?2?+36n6nwn3w0+m8+mo+18+2o+18+v"},
{jn=4,jo=194,jp=16,jq=82,jr="the path continues...",je=5,jj={60,13},jm="11d20d122iA+5B?+1PA+kR?PA:iA+aE:2A0:3A+f:eR?PA+b:2A0A+6B?+1PA+bRPA+3RS?+3PA+7R?C?0A+bEAR?+3A+c0A+7B?+1PA+9R?+1PER?+1S?+4SPA+3R?+2C?0A+2R?PAEAR?+1C?+5PA+b0A+7R?+3PA+6R?+3C?+2T?+4T?+1PER?+3C?0AR?+4C?+3C?+7PA+5:fA+30PA+5R?+5PA+4R?+4C?+cC?+4C?0?+6C?:5?+2C?+8A+90?+1PAEAR?+4e?+2PER?+6C?ey?+9C?+4C?0?+6C?+3C?+1NONONO?PA+80?+3C?+5wx?+3C?+5zBCzxh7?+3zAB?+1C?+4C?0?+6C?+3C?+1:8MNO?+1x?+1P+1EARSPAE0?+3C?+4whxy?+2C?+3zA+2DAxh+1y?zA+4BC?+3zDA0?+1:4?+3:0?C?+2zDB?:pNOM?+1x?+3C?+1S?+1C0?+3C?+4h+1xy?+2C?+1zA+4NONONOt+2NONOADB?zA+30?+5zDB?zA+2B:pMNO?+1x?+3C?+1T?+1C0AB?+1C?+36h+1xh7?zDA+7MNOJ+6NOMA+80?+4NOt+105lt+2NOMB?x?+3C?+4C0A+2BCzB?+1NONOt+cNO?+8NOt+20k40t+2?+4MNOJ+23J+2?NOABx?+3:cC?+2zAD0A+3DA+3MNOJ+dM?+aMJ+32J+4?+4NO?+43?+3MA+1xABzADA+50t+8NO?+u2?+aM?+63?+1NOt+eJ+8M?+u2?+5o+5NO?+63?+1MJ+e?+2PA+7R?+2S?+1S?+1S?+2S?+1whyw:30?+52?+7PA+8R?+33?+5;i?+fPA+4R?+3S?+1T?+1S?+2S?+1mhnw0?+42?+9SPA+4RS?+53?+fy?+4A+3R?+4S?+4S?+2T?+2whn:90?+32?+aS?+1PA+1R?S?+63?+1;0?+cy?e?+2PAR;1?+2:g?e?+1T?+4S?+6my?:90?+22?+bS?+2S?+2S?+73?+dhyx?+3;1?+4wx?+7T?+60+e?+4T?+2T?+2T?+60+4?+ah+1x?+8wxy?+gx?x?+5x?x?+e:0?+7x?x?+bh+1xh7?+5whxy?+fzxBx?+5x?x?+i:6?+3x?x?+bh+1xh+1y?+36h+1xhy?+czA+1xAxB?+4x?x?+c0+4?+4x?x?+bNONOt+7NONO?+aNONOt+4NONO?x?x?0+2?+5:4?+3x?x?+5x?x?+bMNOJ+9NOMy?+2:5?+5wMNOJ+6NOMBx?x?x?x?+2zB?+4x?x?+5x?x?+bNO?+bNOhy?+66hNO?+8NOAxBx?x:0?x?+1zA+2B?:0?+1x?x?+5x?x?+bM?+dMhy?+6h+1M?+aM;bAxAxBx?x?zA+4B?+1x?x?+5x?x?+bNO?+bNOh+17?+46h+1NO?+8NOt+lNO?+2x?x?+bM?+dMh+2y?+2wh+2M?+aMJ+mMo+h"},
{jn=140,jo=90,jp=16,jq=194,jr="the path splits again...",je=8,jg=6,gw=50,jj={49,27},jm="85b30b532jB?3?+7S?+1S?+2S?+43?+5S?+4S?+cS?+1S?+1S?+2S?+3:e?+3S?+7S?+10A?+13?+6T?+1S?+2S?+53?+4S?+4T?+cT?+1S?+1S?+2S?+7S?+7S?+10AB?+13?+8S?+2T?+63?+3T?+lS?+1S?+2T?+7S?+7S?+10s+6NO?+4T?+b3;lKu?+e:l?Ku+2?+3S?+1T?+bT?+6:f?S?+10I+5NOMB?+efvfvf?+4:5?+9fvfvf?+3T?+nT?+10?+6NOAB?+1u;lu+2?+8L?L?+gL?L?+w0?+6s+3NOf+1vf?+8L?L?+gL?L?+5zB?+o0?+3NO?I+2NOM?+1L?+9L?L?+c:4?+3L?L?+4:0zA+1B?:0?+m0?+aNO?+1L?+9L?L?+7:0?+8L?L?+3zA+5B?:8?+j0?+5NO?+3M?+1L?+1:4?+7L?L?+6Ku+3?+4L?L?+1NONOs+3NON:pO?+e:m?+30?+aNO?+1L?+4:l?+4L?:5L?+4fvf+2vf?+4L?L?+1MNOI+5NOM?NO?+f0?+1NO?+7M?+1L?+4Ku+2?L?L?+5L?+2L?+5L?L?+1NO?+7NO?M+1?NONOs+5NONO?0?+aNO?+1L?+3fvfvf?L?L?+5L?+2L?+5L?L?+1M?+9M?NO?MNOI+7NOM?0?+bMo+BNO?+7NOoM+1oNO?+9NOo0/6+S:26/0+3:3/6+k:26/0/6+7456/+J0/+36/+l0/6+1w236+2kl6+aw236/+v0/+36+c456/+60/01Mij0136+1w236+1w23w01Mij0136+1w236+1w23w236+7w236/+40/+36+ckl6/+60/gh/?/+2ghj01Mij01MijMgh/?/+2ghj01Mij01MijMij0136w201Mij0136/+10/+36w23w236+7w236/+30?/+7gh/?/+2gh/?/+bgh/?/+2gh/?/+5ghj1Migh/?/+2ghj01/0/+31MijMij0136w201Mij0136/0?/+Gh/?/+9gh/0/+3h/?/+5ghj1Migh/?/+2ghj1/0?+T0+3?/+9h/?/+9h/0AB?+R0+3?+e:g?+60A+3B?+hw7?+1wy?+mzAB?0+3?+4e?+f0A+4B?+d:0?+1why?6:lh+17?+b:0?+7zQA+2B0+3?+4xy:0?+8e?+40A+6B?u+a?+1hNO?hNOy?+1u+3?+1u+6?+2zQA+3:lQA0+3?+4xh7?;l?+5wx?+40s+8f+1vf+1vf+1vf+1s+1NONONOs+3f+1vf?+1f+1vf+1vf?+1s+1050+2s+5?+3s+30+350s+3?+30I+8o+aI+bo+eI+33I+7o+3I+83I+3o+30"},
{jn=276,jo=58,jp=16,jq=82,jr="the castle is ahead.",je=7,gw=-24,jj={69,22},jm="14a90a492dA+tR?+23?+4:2MNO?+6mh+1yh:2NONOM?+32?+1PA+6:2ANA+bRS?PA+bRS?+43?+3NOM?+8w7wN+1:3ONO?+22?+3SPA+5NPA+9R?S?+1SPA+8R?S?+53?+2MNO?+7:g?+1myNONO;b?+22?+4S?SPEA+2N?SPA+6R?+1S?+1S?SPA+1EA+2R?+1S?+63?+1NOM?+awMNONONONONONOS?S?CPA+1N?S?+1PAEARS?+2S?+1T?S?;1?SC?;1?S?+2S?+2;l?+3NONONO?+1NONONO;b?+3NONONO?+4x?S?T?C:1?SPN?T?+3C?+1S?+2S?+3T?+1TC?+1S?+2T?+1NXUZNONONOM?+2NONONO?+2MNONO?+5x?S?+2C?S?N?+5C?+1S?+2T?+7C?+1S?+62wNONONONO?+3x:1?+2NOUZNONO?+6x?T?+2C?T?N?+5C?+1S?+4zA+1B?+2C?+1T?+52?6h+2NONO?+4x?+32?NONO?+7x?+4C?+2N?zAB?+1C?+1T?zB?zA+5BC?+72?wh+2ywNO?+5x?+22?NONONO:8?+6x?+4C?+2NzA+2B?C?+1zA+4QA+5DAB?+4NONOywh+2n:pM?+5x?+12?NONO6hN:pO?+5x?+1zA+1DABN+1A+1QA+2DA+3QA+4NONOA:lA+2B?+4NONOh+3y:pM?67?+2x?2?+2NO7wNONO?+3:0?x?zA+2NONONA+fNONONONOA+1B?NONONONOywyNOh+2y?+1x2?e?+2NOmhNO?+3zAxA+3NONON+1t+X040+1t+bNJ+X2J+eN/6+M:26/N:3ONOh+1n?+12:e?+3PA+aN/6/+NN+1OMhn?+12?+5PA+6QA+1N/6+4456+gw236+aw236+1w236+1w2/NONOy?+12?+7SPA+6QN/6+4kl6+5w236+1w236+1wMij36+1w236+3wMij01Mij01Mi/N+1OMn?2?+8S?+1S?+1:fPA+2N/6+1w236+1w236+1wMij01Mij01M/?/+2j01Mij0101M/?/+2gh/?/+2gh/?+1NONONONONO?+5T?+1S?+5N/01Mij01Mij01M/?/+2gh/?/+2gh/?/+4gh/?/+2ghgh/?+cN+1ONONONOM?+8S?+5N/gh/?/+2gh/?/+2gh/?+BNONONONONONONO?+4S?+1NONON?+n:l?+56e?+6;i?+a0?+3NONONO?x?+5T?+2x?N+1?+ke?NO?+1eywh:0xB?+7e?+6z0?+4NONO?+1x?+9x?ANAB?+e:l?NONONONO?xh+1nxA+2B?+4xy?+3zA+10?+5NOMB?x?+2e?+4:m?xzANA+2B?+4e?+2;0?+1zANONONONONONONONOA+5B?:lxhn?ezA+20?+6NOABx?+2x?+4zxA+1NA+4B?+2xy?ezA+1NONONONONO?+1NONONOt+7k40+1A+30?+5NOMA+1xAB?x?+1e?zAxA+1NA+50+15lt+5MNO?+3NONO?+1NO?+1NOJ+62J+1zA+30?+6NOt+fNA+5BJ+13J+5NO?+fNO?+42?+1zA+40?+7MJ+fN"},
{jn=140,jo=170,jp=16,jq=66,jr="the castle is ahead.",je=7,gw=-16,jj={62,32},jm="156707562m/6/+p0+1?+8wh+10+3h+4n?+13?+20+3h+2n?+32?+20+1?mh0/+16+9w236+1w236+4456+1w236+1w/0+1?w7h7?+3wh+10:2?+10h+3n?+33?+10+3hn?+42?+3:90:90?+1w0/+16+8wMij01Mij36+3kl6wMij01M/0+1?mh+3y?+2wh0?+10h+1n?+2mh0+4?+10n?+42?+5:90?+1m0/+16+601M/?/+2gh/?/+2j36+4wM/?/+2gh/?+4whywhy?+2w0+3n?+5wh+30?+10?+10+b7?+10/+16+6gh/?/+9j01201M/?+bmh+37?+1w0+3;b?+7wh+20+1?0?+36h+4n?0+1y?+10/+101:22/+4?/+cghigh/?+7:0?+2w7?+2mh+1y?w0+7y?+3wh+10+3?+2wnwhn?+30+1y?+10/+1ghi/+4?+2e?+n6hy?+3why?+10+3:1wh+2n?+5m0+3?6hn6hn?+1:c?+20+1y?+10+1?+6B?+1x?+4e?+b0+1kc0+7?+1h+1y?0?0+1h+1n?+7;a?0:2?0+1hywywn?+50:20y?+10+8AB?x?+4x?+d2?0+4?x?+16hy?+10?+10hy?+4w0+4?0+ak40+2y?+10+8A+2xB?+2zx?+7e?+32?z0+2?+2x?6nwye?0?+10n?+5whywy0+3h+3n?+326h0+1y?6h:8h+10+51+40?zAxB?+2e?+1zxB?+12?+1A0+1?+1wyx?wewyx?0+1:3?0;b?+7wh+1y0+1:3?0h+1n?+42?wy:90wh7wy:90w0+5j+41+50?+1x?zAxAB2?ezA0+1?e6yxwyxwyx?0+450+1?+17?+1ywh0+1?0hn?+426h+27:90h+50+5?+4j+51+e0+9k40+5h73?+2wy6h7w0+55l0+l?+aj+e0+1wh+2n?+226h+10+3yw73?+1wh+1ywh0+3?x?3?+5x?0+Fwh+1n?+226ywh0?0+1ywh73?+1whywh0+3?x?+13?+3:e0/+46/+a0h7wh+5ywh+2y?+3mh+1ywh+10+1mhy?+226hnwn0?0+1hy?h73?+1wywh0+3?x?+23?+10/+56+6456/+10wywh+2y?mh+2n?+bmn:90?wy?+126h+2n?0?0+1y?+1my?3?wh7:aw0+3?x?+33?0+1?/j/x/6+7kl6/+10h+17whn?+2:gwn?+e:90:90?why26ywn?+1:a?0+1:3?0y?+20+8:2?0+3k40+4?+2x/36+3w23:f6+1w2/0wh+1y?+6:5?+40+2?+30+dk40+2?0y?+3wh7?mh+10?0+1n?2?+2x?+4x/j36+1wMij01Mi/0h+1n?+l0?0h+2n?+426h0+3y?+167why?+1wh0?0+1?2?+3x?+4x?/j01M/?/+2gh/?+10y?+n0?0hy?+52?mh0:2?0+1y:4?+1wywywy?+1w0+6?+2x?+4x?/+1h/+1?+70n?+i:4?+3w0+2y?+2:0?+22?+2w0?0+1y?+1mh+10+1y?+1w0+6?+2x?+4x?+7:d?+30?+10+5?+e6h0+2hn?+32?+3w0+3y?+2wh0+1y?+1h0?:3?x?0+1B?+1x?+4x?+b0?+2x?+1x?+3:0?+awh+10:3?0y?05l0+4?h0+3h7?6h0+2y:6?+1h0?+1x?0+1A?+1x?+1e?+1x?+b0?+2x?+1x?+dwhyw0?0y?+23?+5m0?0+9y?+1w0+1?x?0+1AB?x?+1xzBx?zB?+6zA0?+2x?+1x?+20+2?+10+a?0n?+33?+1wy?+10?x?+1x?+1x?0+1y?+1w0+1?x?0+1A+1BxzAxA+1xA+3B?+2zA+20?+2x?+1x?+3x?+3x?x?x?x?+10+2?w7?+23?my?+10?x?+1x?+1x?0+1n?6h0?+1x?0+11+m?+2x?+1x?+3x?+3x?x?x?x?+10+26h+1y?+23?m7?0+bk40+3?x?0+1j+m"},
{jp=16,jq=50,gw=-28,jj={84,22},jm="g5820e283g/6+iw20/MNOMhn?26h+2ywM:2NONONONONO?+1NONONO?+h2?+fNONO?+a:2?/+66+a456+4wMih/NONOn?26nhnwyhN:3ONONO?+1NONONO?+1NO?+h2?+gMNONO?/+g36+1w236+1w23kl6+3wM/?+3NOM?26nwy?mywMNONO?+5;1?+5;1?+h2?+hNONO?/+hj01Mij01Mij36+1w01M/?+5NONOYVWO?+1whNOMy?+rYVWO?+6NONOYVWONONONONO?/+hgh/?/+2gh/?/+2j01Mih/?+7xh+273?+2h+1MNOy?+rx73?+6wM:2NOMh73?+2h+2NONO?/+rgh/?+axh+1nw73?+1:gmhNOMy?+rxh73?+46hNONOwh73?+1wh:0h+1NONO?+Dxhy?+1m73?+1hMNOhy?+p6xh+1e3?6ywywMNOM?wh73?+1mh+2NONONONO?+9u+e?+9xh+1:d7?+1h73?mNOMwhy?+ohxywNONONXUZNONONONONXUZNONONONONONONO?+6fvf+4vf+4vfNONONO?+3xywhyewh73?MNOw;0ywy?+d:7?+86hxywxywhn26NONONOw;1hn?2?+1mh+1y?+1;1?+2whNONO+6?L?+4L?+4L?+1NONOM?+3xh7wyxwNONONOMy+1why?+5:7?+fwhx7wxyhn26ywNONOywy?2?+3why?+5mhNON+6?L?+4L?+2e?L?+1x?+1NO?+3xhywhxhMNONONONONXUZ?+j6h+1xywxhy26hywMNOMyhn2?+5h+1y?+5whNO+6?L?+1e?+1L?+2x?L?+1x?NOM1+aNONONONOn?26hy?+gNONONONONONONONONONONONONO?:b?+2wy+1?+5whMN+6?L?+1x?+1Le?+1x?L?+1x?+1NOj+aMNONONOn?26ywhywy?+2why?+2wymhyMNONONONONONONONONONONONONONONONO?+5w;ahNO+68+vNONONO?+126hywhywhy?whywhymh+17whNONONONONONONONONONONONONONONONONONOYVWONON+6OMh+2n?+owh+1y+1?+226M:2N/6/+PNONOh73?+1mh+1ywNO:2N+1Ohn?+rmymy+1?26yNO/6+c45:26/0/6/+zNONOh73?+1wywhMNO+1My?+ty?wy26y+1MN:3/36+1w236+6kl6/0:3/36+1w236+5w36+1w236+gw/NONOh73?+1m7mhMN+1Oy?+tYVWONONONO/j01Mij36+1w0136+1w/0/j01Mij36+1w01Mj01Mij36+1w0136+1w236+3wMi/NONOh73?+1wywNO+1My?+v3?mhyNON?/gh/?/+2j01Mihj01M/0?/gh/?/+2j01Mih/?/+1gh/?/+2j01Mihj01Mij36+1wM/?NONONOh73?+1myMN+1Oy?+v73?w:0ywNO?/+6gh/?/+3gh/?0?/+6gh/?/+agh/?/+3gh/?/+2j01M/?+4NONONONXUZNO+1Mhy?+s;a?wh73mhyMN?+f0?/+vgh/?+4NONOh+1n?26NON+1Oh+1y?+9:7?+hYVWONONONO?+f0?+j0+15l0?+3:5?+aNONOn?26hMNO+1NONONXUZNO?+n3mhywNON?+f0B?+ixhn3?+gxhy?26h+1NONywywn?26NOM?+mh73mh;0hyNO?+f0A+1B?+gxy?+13?+fxn?26h+1NONOywhy?26hMNO?+b:7?+9wh+173mywMN9a?+39:oa9a?+39a0A+5B?+1zB?+8xnzBe3?+ex?26h+1NONO;iNnhn?2?ywNOM?+4ywy?+dwywhNONONOa9a9a9a9a9a9a9a91+aNO?+3:5?+3x70+4?+8NO1+dy+1?2?wywMNOywy6h+2ywhy?+66yhNONONONONON+1ONXUZNONONONONOj+bM?+7xyx?+2x?+8Mj+ehn26hy?wNOMhywh+1ywh7wh+2y?wywhywMNONONONONO?NX26h+7NO?o+Q"},
{jn=276,jo=90,jp=16,jq=192,gw=41,jj={69,22},je=7,jr="the castle is ahead.",jm="81d20d1231ONOh73?+3NONONONONONONONONONONONONONONONONONONO?+23?+3NONONONONO?+1:e?+3PA+aN+dO:8Mwy?3?+7PA+2NONONONOA+6R?+4PA+3R?+53?+jPA+9O+dN:pO7wy?3?+7SPA+1NONONOA+3RS?S?+6SPAR?+73?+6:g?+cSPA+1R?+1SPAN+dO:pMymh+173?+6S?PA+1NONOA+2R?+1S?T?+6T?S?+93?+iS?S?+2:f?S?SO+dNONONONONONO?+2T?+1SPMNOMARS?+2S?+aS?+a3?+hT?S?+3S?TN+dONONONONONO?+6S?NONOS?S?+2T?+aT?+6NONONONONONO?+cS?+3T?+1O+dNONONONONO?+7T?+1NO?T?S?+ox?S?+1S?x?+eT?+6N+c?wh+1NONONOy?+fT?+7:0?+gx?S?+1T?x?+mO+c?+1mh+1NONOMy?+Fx?T?+3x?+i:m?+3N+c?+2wh+1NONOh7?+a:0?+6NXUZNONO?+ex?+5x?+mO+c?+3mNONOMh+1y?+3:0?+4;l?+826NONOM?+2NONO?+7x?+5x?+7NONONONONONONO?O+c?+5NONOywh7?+6NONO?+3:l?26nwNONOy?+1MNOM?+2NONO?x?+5x?NONO?+1wMNONONONONONOM?N+c?+6NONONONONONOy?xy6x?wNONOy6hMNOMh+1yNONOy?wMNOMyxwNONOyxwMNOMy6hNONONONONONONOyO+co+?o+wONOywh+2y?+5S?S?+1SPA+aR?+5PA+9R?+7PA+1QA+6QA+1R?+5PA+c:2N?NOMy?wh+27?+4T?S?+1S?PA+7RS?+7PA+5R?S?+9PA+b?+7A+4QA+6M?ONOywhnwywy?+5S?+1T?+1S?+1PA+1RS?S?+8S?+2S?+2T?+aPA+4QA+3R?+7PA:iA+7QA+1N?NOMh7wywh+1y?+5T?+4S?+2S?+1T?S?+8T?+2S?+fS?SPA+2R?S?+9PAQA+7RM?ONOhywh7mh+17?+4:0?+5T?+2S?+3T?+cT?+fS?T?S?S?+1T?+aPA+1R?+1PA+1R?N?NONOh7wy+2wy?:l?+dT?+yT?+2T?S?+fS?+4S?+1M?ONONOYVWONONONONONO?+NT?+fT?+4S?+1N?h+1ywhy?3?wywNONONO?+??+9T?+1M?ywhywh7?3?myMNONO?+x:0?+HN?nwhy6h+1y?3?wNONO?+hzB?+bzAB?+kNO?+2:4?+4NO?+aM?6hywh+37?3mMNOM?+gzANO?+9zANONO?+e;0?+2NOM?+7MNO?+9N?why?wywhNONONONO?+5zB?:l?+6;lzANOM?+7zA:lA+1MNONO?+fNONO?+7NONO?+6:0?+1M?ONONONONONONONOM?+4NONONO?+1NONONONO?+3NOYVWONONONONONO?+3:5?+5NONONOM?+7MNONONO?+5N?NONONONONONONONOo+4MNONOMo+1MNONONOMo+3MNO73mhNONONONOMo+9MNONONOo+7NONONONOYVWONO?"}
}
function _init()
ez,dt,w=js("2982928"),js("1d2f"),js("567fabd")
ct:bq()
ct:bs(ey)
ct.fa=fa:l()
ct:bs(ct.fa)
ct.fa:fj(10)
bc,be,dw,ct.cq,ip,jt,ft,fu=4,0.15,2.5,6,6,0,0,0
ho,hr,ju,cx,jv,jw,jx=0,0.25,{},0,js("001121562493d52e"),0,0.01
jy,jz,ka,kb,cp,di,dy,hi,jh,kc,kd,ke=0,-20,true,true,0,false,0,0,{{38,17}},0,0,0
ct:n()
end
function js(r)
m={}
for v=1,#r+1 do
add(m,kf(kg(r,v)))
end
return m
end
function kh()
eo={ct,bw}
for v=0,127 do
for bm=0,27 do
mset(v,bm,0)
end
end
end
ki={fv,ga,ih,ik,hv:l({hx=24}),hv:l({hw=24}),hv:l({hx=-24}),id,io,iq,gj,gj:l({gk=false}),gq,gf,il,iu,iy,ja,gz,jc,jc:l({jf=true}),hb,hd,jl,hh,iq:l({ir=33})}
function kj(kk,kl)
cls()
kh()
di,dy=kk==1,0
if kk==6 then
km=true
end
gg=kk
kk=ji[kk]
r=kk.jm
jp,jq=kk.jp or jn,kk.jq or jo
jn,jo=kk.jn or jn,kk.jo or jo
jk,je,jg=kk.jk or 1,kk.je or je,kk.jg or jg
eg=kk.gw or 0
if gg==7 and km then
jp,jq=540,186
end
dd={}
if(kk.jr) jr=kk.jr
ck,d,cursor,b,c,kn,ko=js(sub(r,2,8)),kp(sub(r,9,10)),11,0,0,0,64
while cursor<#r or kn!=0 do
if kn<=0 then
kq=sub(r,cursor,cursor)
if kq=="/"then
ko=192-ko
elseif kq==":"or kq==";"then
hs=sub(r,cursor+1,cursor+1)
if kq==":"or cz then
kr=ki[kf(hs)+1]:l():cn()
kr.b,kr.c=b*8,c*8
kr:ci()
kr:o()
cm(kr)
end
cursor+=1
elseif kq=="+"then
hs=sub(r,cursor+1,cursor+1)
kn=kf(hs)
cursor+=1
else
ks=kf(kq)+ko
mset(b,c,ks)
b+=1
end
cursor+=1
else
mset(b,c,ks)
kn-=1
b+=1
end
if b>=d then
b=0
c+=1
end
end
kt=kf(sub(r,1,1))
if di then
ei(kt)
else
ei(-1)
end
if not kl then
ct.b,ct.c,ct.i,ct.g,ct.f,ct.t=jp,jq,0,0,0,false
ct:da()
bw.dg=false
else
ct.cq=ip
ct.b,ct.c,ct.cu,ct.t,ct.ed=ej,ek,el,em,en
ct.dn,ct.q,ct.ku,ct.f,ct.q,bw.dg,ct.r=0,false,0,0,false,false,1
end
ct:br()
bw:cy()
bw:cw()
bw:n()
if di then
bw.b=flr(ct.b/136)*136
end
end
function kf(kv)
for v=0,63 do
if kg("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?",v+1)==kv then
return v
end
end
end
function kp(kw)
local kx,jf=kf(kg(kw,1)),kf(kg(kw,2))
return jf+kx*32
end
function kg(r,v)
return sub(r,v,v)
end
function _update60()
ef,dv=btn(5) and not ky,btn(4) and not kz
ky,kz=btn(5),btn(4)
if(not im) jh[cp+2]=nil
hi=(hi+0.01)%1
if eh then
eh-=1
if eh<=0 then
eh=nil
kj(gg,true)
ka=true
kc+=1
end
end
if kb then
if btnp(3) or btnp(2) then
cz=not cz
sfx(2)
end
if dv or ef then
kb=false
if cz then
ct.cq,ip=4,4
end
kj(2)
sfx(3)
jw=5
end
return
end
if not la then
ke+=1/60
if ke>=60 then
kd+=1
ke=0
end
end
if cx>0 then
cx-=1
return
end
if ix then
if jt>=10 then
if ct.cq>=ip then
ix=false
ip+=1
sfx(1)
else
sfx(0)
end
ct.cq+=1
jt=0
end
jt+=1
return
end
if im then
if jz<=40 then
jz+=1
else
ka,im,jz,iz=true,false,0,false
if not la then
kj(jk)
else
jr="you couldn't stop the demon"
if(hp) jr="the end"
end
end
jw=jz/5
if(not hn) return
elseif la then
jw-=0.1
return
end
if ka then
if jy<=20 then
jy+=1
jw=5-jy/5
else
ka,jy,jw=false,0,0
ei(kt,0b11)
end
return
end
if hn then
hr=(hr+jx)%1
if not lb then
for v=1,ho do
local lc=hq:l({hs=v})
add(ju,lc)
cm(lc)
end
lb=true
else
dy-=0.05
if hp then
jx+=0.000025
dy-=0.05
if(dy<24) hj.q=not hj.q
else
jx-=0.000025
if dy<16 or ht then
hj.c-=2
hj.r=210
hj:br()
dy+=2
ht=true
end
end
end
if dy<=12 or dy>128 then
im,la=true,true
end
end
del(eo,bw)
add(eo,bw)
for m in all(eo) do
if m.cs or(m.c>=bw.c and m.c<bw.c+112) then
m:n()
if m.fg and m.cq<=0 and not m:bx() then
m.df=true
end
if m.df then
del(eo,m)
end
end
end
end
function ei(hs)
if ld!=hs then
music(hs)
ld=hs
end
end
function cm(m)
add(eo,m)
end
function ba(b,c)
if c<bw.c then
c=bw.c
end
return ex(b,c,0)
end
function ex(b,c,le)
b/=8
c/=8
return eu(b,c,le)
end
function eu(b,c,le)
return fget(mget(b,c),le)
end
function bp(gr,lf,cr)
if gr+cr<lf then
return lf-cr
elseif gr-cr>lf then
return lf+cr
else
return gr
end
end
function ge(lg,lh,li,lj)
local lk,ll=abs(lg-li),abs(lh-lj)
return sqrt(lk*lk+ll*ll)
end
function _draw()
if jw!=0 and lm==jw and not la then return end
lm=jw
cls()
if la and not im then
ln()
lo("deaths: "..kc,72,7)
local he=""
if ke<10 then
he="0"
end
lo("time: "..kd..":"..he..flr(ke),82,7)
if(cz) lo("hard difficulty",96,7)
lo(ho.."/3  ",116,7)
spr(58,68,114)
else
if cx<=0 then
bw:dh()
map(0,0,0,0,128,32)
if(kb) lp() return
lq()
for m in all(eo) do
m:p()
end
ct:p()
map(0,0,0,0,128,32,0b1000)
camera()
clip()
end
if di then
ln()
else
lr()
end
end
for v=1,jw do
lt()
end
end
function lq()
if(dy<=0) return
camera()
local hu=dy-3*sin(hi)
circfill(63,36,hu+1,1)
circfill(63,36,hu,0)
bw:dh()
end
function lr()
line(0,112,127,112,5)
print("player",1,114,7)
print("enemy",108,114)
for v=0,ip-1 do
spr(47,v*5,120)
end
for v=0,ct.cq-1 do
spr(63,v*5,120)
end
for v=0,fu-1 do
spr(46,120-v*5,120)
end
for v=0,ft-1 do
spr(62,120-v*5,120)
end
local r={}
if jb then
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
function lp()
clip()
lo("normal",72,7)
lo("hard",82,7)
local lk,ll=0,0
if(cz) lk=4 ll=10
spr(180,40+lk,72+ll)
spr(181,79-lk,72+ll)
lo("mush101.itch.io",118,5)
end
function ln()
local lu={0,8,0}
if not la then
for v=1,3 do
rect(v-1,63+v,128-v,128-v,lu[v])
end
end
rectfill(0,0,127,63,0)
sspr(56,96,64,32,32,8)
lo(jr,50,7)
local lv,hs=nil,-1
for ha in all(jh) do
lw,lx=ha[1],ha[2]
if lv and(hs<cp or hi%0.2<0.1) then
line(lw,lx,lv[1],lv[2])
end
hs+=1
circfill(lw,lx,1,8)
lv=ha
end
end
function lo(ly,c,lz)
print(ly,64-2*#ly,c,lz)
end
function lt()
for v=0x6000,0x7fff do
local ma=peek(v)
local mb=ma%16
local mc=lshr(ma-mb,4)%16
mc,mb=jv[mc+1],jv[mb+1]
poke(v,shl(mc,4)+mb)
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
0055550000555500005555000677550000755550000000000000000000000000babbbaddbabbbadd060550600006000600060006006666000066660000677600
0075570000077500007756606667755056775660000000000000000000000000baaabaadbaaabaad060550600050555500005555065555500067760000777700
06770770000777000077766066007750566006600000000000000000000000000baabaad0baabaad655555560560565600055656655575550007770007770770
66600660000660000667055555500770500005550000000000000000000000000bbbbbad0bbbbbad655555565666555500566555555577550007600066600760
56000660000660000660000000000670000000000000000000000000000000000adbabad0aadbbad656556565666555000566556555555500006700067000670
0550055500055500056600000000066000000000000000000000000000000000aaababaa0aaabbaa066556605665550005665566555500600006670006700667
0000000000000000005600000000056600000000000000000000000000000000aadbadba0aadb0ba005555000605550005055560555000000000000000000000
0000000000000000000500000000005500000000000000000000000000000000aaadbadb0aaadb0b006006000050500000505000055555500000000000000000
0500000007770000088000000000000000000000000000000000000000000000a000000a000a000000aaaaaabb00a000000bb000055000000000000000000000
5650000076660000899800000000000000000000000000000000000000800000aa0bb0aa00aa0000000aaaa0bbb0aa00000bb00056650000000666600aaaa000
0500000066650000899800000000000000000000000000000000000008880000aaabbaaa0aaabb000000aa000bbbaaa0a00bb00a56650000000600600a00a000
0000000066500000088000000000000000000000000000000000000000800000aaabbaaaaaabbb00bbbbbbb000bbbaaaaa0bb0aa05500000000600600a00a000
0000000000000000000000000000000000000000000000000000000000000000aa0bb0aa00bbbaaabbbbbbb0aaabbb00aaabbaaa00000000000600600a00a000
0000000000000000000000000000000000000000000000000000000000000000a00bb00a0bbbaaa00000aa000aaabb00aaabbaaa00000000000d00d009009000
0000000000000000000000000000000000000000000000000000000000000000000bb000bbb0aa00000aaaa000aa0000aa0bb0aa00000000000dddd009999000
0000000000000000000000000000000000000000000000000000000000000000000bb000bb00a00000aaaaaa000a0000a000000a000000000000000000000000
09900990077700000990000000000000000000000000000000000000006666000660000002202200009999000000000000000000000000000000000000000000
977897787eee00009aa900000000000000000000000000000000000006666660600600002882882009999990000000000000000000000007000666600aaaa000
97789778eee200009aa900000000000000000000000000000000000066776665600600002888e82099779994000000000000000000990970000622600a88a000
08800880ee200000099000000000000000000000000000000000000066776665066600002888882099779994000000000000000009449440000622600a88a000
0000000000000000000000000000000000000000000000000000000066666655000560600288820099999944000000000000000064444446000622600a88a000
0000000000000000000000000000000000000000000000000000000056666555000056560028200049999444000000000000000060444406000d22d009889000
0000000000000000000000000000000000000000000000000000000005555550000005600002000004444440000000000000000066000066000dddd009999000
00000000000000000000000000000000000000000000000000000000005555000000000000000000004444000000000000000000066666600000000000000000
0777777077277767000055555555000007705555555507700000000000000000777777770ddddddddddddd000000000007705555555507700000000056666665
7eeeeee80070007000000666666000007ee0066666600ee80000005500000000c717c717d555555555555550000000007ee0066666600ee80006500054444445
7eeeeee82202200200000000000000007ee0000000000ee8000000000000000071c171c1d555555555555550000000007ee0000000000ee85605555005555550
7eeeeee8822822280000060000600000000006000060000000005505550000001c1c1c1cd5555555555555000000000000000608706000005566550000000000
7eeeee888888888855550000000055555555000000005555000000000000000011111111d5555555555550500000000055550008700055555665555000000000
7eeeee880828082006660000000066600666000000006660005505550555000011111111d5555505050505000000000006660e887ee066605666555000000000
7eee88880000000000000000000000000000000000000000000000000000000011111111055050505050500000000000700008887ee000005665555000000000
08888880200020080600000000000060060000000000006055055505550555001111111100000000000000000000000006888880088880605566550000000000
00000000000000000000000002000000077777700777777000000000000000007777777700000000000000000000000077377767774777670000000056666665
000000000555055500000000000000207eeeeee87eeeeee80555055505550000c717c71700000000000000000000000000700070007000704444444454444445
000000000000000000000000000000007eeeeee87eeeeee8000000000000000071c171c100000000000000000000000033033003440440045555555505555550
000000005505550500000000002000007eeeeee00eeeeee800055505550555001c1c1c1c000000000000000000000000b33b333b944944490004900000494400
000000000000000000000000000000007eeeee800eeeee88000000000000000011111111000000000000000000000000bbbbbbbb999999990004900000499400
000000000555055500000000000000007eeeee800eeeee880000055505550000111111110000000000000000000000000b3b0b30094909400004900000449400
000000000000000000000000000000007eee88800888888800000000000000001111111100000000000000000000000000000000000000000004900000494400
0000000055055505000000000000000008800000000008800000000555000000111111110000000000000000000000003000300b400040090004900000449400
00000000566555500000000000000030303000303030000049944440499444403030003000000000000000000000000003000000040000000000000000494400
05550555565655500555000000033033000330330003300049494440094944000003303300000000000000000000000000000030000000400000004400494400
00000000566555500000000000303030303030303030300049944440309440303030303000000000000000000000000000000000000000000044445500449400
00055505556655005505550000300003303000033030003044994400300900033030000300000000000000000000000000300000004000000455550000494400
00000000566555500000000003030330030303300303033049944440030003300303033000000000000000000000000000000000000000000504900000449400
05550555566655500555000000330033003300330033003349994440003300330000003300000000000000000000000000000000000000000004900000449400
00000000566555500000000033003300330033003300330049944440330033000094400000000000000000000000000000000000000000000004900000494400
00055505556655005505550000330003003300030033000344994400003300030499440000000000000000000000000000000000000000000004900000449400
07777770077777777777777030003300303000303000330003000300030003000770555555550770077777777777777007777770077777700000000000000000
76666665766666666666666500330033007330330033003300300300003003007660066666600665766666666666666576666660066666650000000000000000
7666666576666666666666653300330037a730303300330000033000000330007660000000000665766666666666666576666660066666650000000000000000
76666655766666666666665503303030307000730330303000033000000000000000060000600000066666666666665076666666666666550000000000000000
76666565766666666666656503000303030307a73000030000300300000000005555000660005555066666666666656076666666666665650000000000000000
76565655766666565656565500030303003700730303030000300030000000000666005656006660066666565656565076666656565656550000000000000000
75656555766565656565655500033000337a73003303300003000030000000000000056565600000066565656565655076656565656565550000000000000000
05555550055555555555555000000303003700030300000003000030000000000600555555550060000005555550000005555555555555500000000000000000
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
00005550000000500500005000000000000000000000000000000000f90004999999400004999940000004999999994000000000004999999940000000000000
00057575000005750555555000000000000000000000000000000000949999404444999999222299940049222222229999940004999400022224000011111011
0057576500005755555555550000000000000000008000000000080094440402044422222222222229999222f222222222299999444000222222900011111011
05765657000055755655556500000000000000000088000000008800490000020444f222222f222222222222222222222222222f400000222222940011111011
5765765600057565556556550000000000000000008880000008880009f420f220444ff222222222222222222222222222f22ff4000002222222294000000000
56656556000565655555555500000000000000000008880000888000904400000044444f22222222222222222222222222222440000022222222229410111111
055550050005655005555550000000000000000000008800008800009000f4442004444422222222222f2222222222222222f440000222244222222910111111
00000000000055000055550000000000000000000000000000000000940f440420044244f2222f22222222222222222222224400022222222222222910111111
0000000000000000000110000000000000011000888880008888200094000000004044444222222222222222222222222fff4000022222222222442900000000
00000000000000bb001100000001000000110000888820008882000049440440440444444f22200000000000022ffffff4444000202020202222222911111000
000000bb00000baa0171000000110000017100008882000088820000090442442444444444ff02244444444220f4442444440002200000002222222911111000
0000bbaa0000baaa0171000001710000017100008882000088820000094444444444200044440000000000000024244244400022220f42022222222911111000
000baaaa0000baaa1761000017610000176100008882000088820000094244444442000002440f44444442442022244444000222220402022222229400000000
00baaaaa000baaaa17610000166100111761000088882000888820000944444242000000002404044f4422402044444240000000000442022244229010000000
0baaaaaa000baaaa1661001116651122166100118888820088888200094442000000002000240000000000000024424404242424040402044222229010000000
0baaaaaa00baaaaa1665112216552222166511222822880028228800494400000000000002444444424424242444444042424240440000044422229010000000
aaaaaaabaaaadb002222556122222551222255610000008800220088944002000002000002444442242242222424000000000000444444440022229000000000
aaaaaadbaaaddb002222255122222211222225510000088800220888942000000000000004000022400000000000200000222220004444000022229400011111
aaaadddbdddddb00222222112222221022222211220008880088088894000000020000002440f400000000200000000002222200000000000002222900011111
dddddddbddddbb002222221020022100222222102200088800880888940000000000000024404400000000000002220002222200000002000002222900011111
ddddddbbddddbb002202221022222100202222108880028800888288942002000000200044404020022222222222200022222000020000000202442900000000
ddddbbbbdddbbb002002210022221000220221008888882800888828942200000000000024004420222224222222200224422002000000200002222900000001
bbbbbbb0bbbbb000222221002222100022222100088888280008882849422000020002244000402042244224442200222222200f000020002000222900000001
bbbbb000bbb000002222100022221000222210000088888200088882094422000000224400000420404444442444002222220000000000000000222900000001
00111100001111102222100022221000222210008888800088882000094442222222444000204020440424444444022222222220000000000222222900000000
01222210012222712222100020221000222210008888200088820000094244444444240000424444444444444444422222442222222222222222222911011111
01222221122222112221000022210000222100008882000088820000922444244244400004222442444000000044442222222222222222222222229411011111
1222217112222100202100002211000020210000888200008820000094222244444000002222422444440f420444244222222222222244222224429011011111
12222111122227102021000011100000202100008882000088200000094222222000000222422242244204020442424222222222222222222222229000000000
12117100122221102221000011000000222100008820000082000000092224220000022999942422424444444424224422999999992222222222222911111101
17101100012227102210000000000000221000008200000082000000924999900002299400499422999942422999999999440000049999999999222911111101
01100000001111101100000000000000110000002000000020000000499400499999900000004999400099999400000000000000000000000044999411111101
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010206030700000900000003070009000000010101000008000000010108090000000000000000000000000101080801010100000000000307010101010000
0000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf0000a58788898a8b8c8d0000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf00ae969798999a9b9c9daf00efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf00bea6a7a8a9aaabacadbf00efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf0000b6b7b8b9babbbcbd0000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfdf000000000000000000000000efff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01100000211002110021100211001f1001d1001c1001a1001f1001f1001f1001f1001c1001a10018100171001d1001d1001d1001d10017100181001a1001d1001c1001c1001c1001c1001c1001c1000000000000
011000001d1001d1001d1001d10017100181001a1001d1001c1001c1001c1001c100131001510017100181001a1001a1001a1001a100131001510017100181001510015100151001510015100151000000000000
01100000211002110021100211001f1001d1001c1001a1001f1001f1001f1001f1001c1001a10018100171001d1001d1001d1001d10017100181001a1001d1001c1001c1001c1001c1001c1001c1000000000000
011000001d1001d1001d1001d10017100181001a1001d1001c1001c1001c1001c100131001510017100181001a1001a1001a1001a100131001510017100181001510015100151001510015100151000000000000
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
