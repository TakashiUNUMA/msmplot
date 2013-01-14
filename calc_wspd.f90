subroutine calc_wspd(uwnd,vwnd,wspd)
  implicit none
  real :: uwnd,vwnd,wspd
  
  wspd=sqrt(uwnd**2+vwnd**2)

  return
end subroutine calc_wspd
