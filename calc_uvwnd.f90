subroutine calc_uvwnd(wspd,wdir,uwnd,vwnd)
  use Math_Const
  implicit none
  real :: uwnd,vwnd,wspd,wdir

  uwnd=wspd*cos((real(270.)-wdir)*(180./pi))
  vwnd=wspd*sin((real(270.)-wdir)*(180./pi))

  return
end subroutine calc_uvwnd
