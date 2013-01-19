subroutine file_write2d( file_name, nx, ny, var )

  implicit none

  integer            :: nx
  integer            :: ny
  character(*)       :: file_name
  real               :: var(nx,ny)
  integer, parameter :: debug_level=100

  open(unit=11,file=file_name,form='unformatted',access='direct',recl=nx*ny*4)
  write(11,rec=1) var
  close(unit=11)
  if(debug_level.ge.100) print *, "DEBUG: Success output ",file_name

  return
end subroutine file_write2d
