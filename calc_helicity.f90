subroutine calc_helicity(kmin,kmax,uwnd,vwnd, eh,srh)
  implicit none

  integer :: k,kmin,kmax,count
  real, dimension(16) :: uwnd,vwnd
  real :: sumu,sumv,meanu,meanv
  real :: reduct,rotate,ureduce,vreduce
  real :: stormwspd,stormwdir,stormu,stormv
  real :: du,dv,ubar,vbar,ehu,ehv,srhu,srhv
  real :: eh,srh
  integer, parameter :: storm=0

  sumu=0.
  sumv=0.
  count=0
  do k=kmin, kmax
     sumu=sumu+uwnd(k)
     sumv=sumv+vwnd(k)
     count=count+1
  end do
  meanu=sumu/count
  meanv=sumv/count
  
  if(storm.eq.1) then
     reduct=0.25
     rotate=30
     ureduce=real(1.-reduct)*meanu
     vreduce=real(1.-reduct)*meanv
     call calc_wspd(ureduce,vreduce,stormwspd)
     call calc_wdir(ureduce,vreduce,stormwdir)
     stormwdir=stormwdir+rotate
     if (stormwdir.ge.360.) stormwdir=stormwdir-360.
     call calc_uvwnd(stormwspd,stormwdir,stormu,stormv)
  else
     stormu=meanu
     stormv=meanv
  end if


  eh=0.
  srh=0.
  do k=kmin+1, kmax
     du=uwnd(k)-uwnd(k-1)
     dv=vwnd(k)-vwnd(k-1)
     ubar=real(0.5)*(uwnd(k)+uwnd(k-1))
     vbar=real(0.5)*(vwnd(k)+vwnd(k-1))
     ehu=-dv*ubar
     ehv=du*vbar
     eh=eh+ehu+ehv
     srhu=-dv*(ubar-stormu)
     srhv=du*(vbar-stormv)
     srh=srh+srhu+srhv
  end do

  return
end subroutine calc_helicity
