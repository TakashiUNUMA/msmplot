subroutine file_read3d( file_name, nx, ny, nz, var )

  implicit none

  integer            :: nx
  integer            :: ny
  integer            :: nz
  character(*)       :: file_name
  real               :: var(nx,ny,nz)
  integer, parameter :: debug_level=100

  open(unit=10,file=file_name,form='unformatted',access='direct',status='old',recl=nx*ny*nz*4)
  read(10,rec=1) var
  close(unit=10)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of ",file_name
  if(debug_level.ge.100) print *, "DEBUG: ",file_name,"(1,1,1)  ",var(1,1,1)

  return
end subroutine file_read3d
