subroutine calc_press(pressp, pint)
  implicit none
  integer :: k,kmax
  real, dimension(16) :: pressp,pint

  do k=1,16
     if(k.eq.1) then
        pressp(1)=100000.
        pint(1)=2500.
     else if(k.eq.2) then
        pressp(2)=97500.
        pint(2)=2500.
     else if(k.eq.3) then
        pressp(3)=95000.
        pint(3)=2500.
     else if(k.eq.4) then
        pressp(4)=92500.
        pint(4)=2500.
     else if(k.eq.5) then
        pressp(5)=90000.
        pint(5)=2500.
     else if(k.eq.6) then
        pressp(6)=85000.
        pint(6)=5000.
     else if(k.eq.7) then
        pressp(7)=80000.
        pint(7)=5000.
     else if(k.eq.8) then
        pressp(8)=70000.
        pint(8)=10000.
     else if(k.eq.9) then
        pressp(9)=60000.
        pint(9)=10000.
     else if(k.eq.10) then
        pressp(10)=50000.
        pint(10)=10000.
     else if(k.eq.11) then
        pressp(11)=40000.
        pint(11)=10000.
     else if(k.eq.12) then
        pressp(12)=30000.
        pint(12)=10000.
     else if(k.eq.13) then
        pressp(13)=25000.
        pint(13)=5000.
     else if(k.eq.14) then
        pressp(14)=20000.
        pint(14)=5000.
     else if(k.eq.15) then
        pressp(15)=15000.
        pint(15)=5000.
     else if(k.eq.16) then
        pressp(16)=10000.
        pint(16)=5000.
     end if
  end do

  return
end subroutine calc_press
