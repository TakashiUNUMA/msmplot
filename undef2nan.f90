subroutine undef2nan(nxp,nyp,nk1,idata)

  implicit none

  integer :: nxp,nyp,nk1,i,j,k
  real, dimension(nxp,nyp,nk1) :: idata
  real :: nan
  data nan/Z'7fffffff'/

  do k=1, nk1
  do j=1, nyp
  do i=1, nxp
     if (idata(i,j,k).lt.-900) then
        idata(i,j,k)=nan
     endif
  end do
  end do
  end do

  return
end subroutine undef2nan
