subroutine calc_wsh(kmin,kmax,uwnd,vwnd, wsh)
  implicit none
  integer :: k,kmin,kmax
  real, dimension(16) :: uwnd,vwnd
  real :: u,v, wsh

  u=0.
  v=0.

  do k=kmin,kmax
     u=u+uwnd(k)
     v=v+vwnd(k)
  end do

  u=u/real(kmax-kmin+1)
  v=v/real(kmax-kmin+1)

  wsh=sqrt( u**2+v**2 )

  return
end subroutine calc_wsh
