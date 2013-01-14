subroutine calc_wdir(uwnd,vwnd,wdir)
  use Math_Const
  implicit none
  real :: uwnd,vwnd,wdir

  wdir=real(270.)-real(180./pi)*atan2(vwnd,uwnd)

  if (wdir.ge.360.) wdir=wdir-real(360.)
  if (wdir.lt.0.) wdir=wdir+real(360.)

  return
end subroutine calc_wdir
