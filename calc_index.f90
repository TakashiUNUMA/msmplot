!
! Program of calcucate indexes for JMA-MSM
! produced by Takashi Unuma, Kyoto Univ.
! Last modified: 2013/01/14
!

program calc_index

  use Thermo_Function
  use Thermo_Advanced_Function
  use Thermo_Advanced_Routine

  implicit none
  integer :: i, j, k, num
  integer, parameter :: nxs=481
  integer, parameter :: nys=505
  integer, parameter :: nxp=241
  integer, parameter :: nyp=253
  integer, parameter :: nk1=16
  integer, parameter :: nk2=12
  real, dimension(:),     allocatable :: pressp,pint,x,y,z
  real, dimension(:,:),   allocatable :: temp,rh,prmsl
  real, dimension(:,:),   allocatable :: press,es,qv,thetae,td
  real, dimension(:,:),   allocatable :: cape2d,cin2d,lcl2d,lfc2d,lnb2d
  real, dimension(:,:),   allocatable :: cor,ki,tt,pw,eh,srh
  real, dimension(:,:),   allocatable :: ltemp500,ssi,brn,wsh
  real, dimension(:,:,:), allocatable :: tempp,rhp,hgt,uuu,vvv,www
  real, dimension(:,:,:), allocatable :: esp,qvp,thetaep,wspd
  real, dimension(:,:,:), allocatable :: ptp,rhop,pvp,tdp,qfu,qfv,qfwind
  integer,parameter :: debug_level=100

  ! allocate values
  allocate( pressp(nk1), pint(nk1), x(nxp), y(nyp), z(nk1) )
  allocate( temp(nxs,nys), rh(nxs,nys), prmsl(nxs,nys), press(nxs,nys) )
  allocate( es(nxs,nys), qv(nxs,nys), thetae(nxs,nys), td(nxs,nys) )
  allocate( tempp(nxp,nyp,nk1), rhp(nxp,nyp,nk2), hgt(nxp,nyp,nk1) )
  allocate( esp(nxp,nyp,nk1), qvp(nxp,nyp,nk1), thetaep(nxp,nyp,nk1) )
  allocate( uuu(nxp,nyp,nk1), vvv(nxp,nyp,nk1), www(nxp,nyp,nk1) )
  allocate( ptp(nxp,nyp,nk1), rhop(nxp,nyp,nk1), pvp(nxp,nyp,nk1) )
  allocate( tdp(nxp,nyp,nk1), ki(nxp,nyp), tt(nxp,nyp), pw(nxp,nyp), wsh(nxp,nyp) )
  allocate( lcl2d(nxp,nyp), lfc2d(nxp,nyp), lnb2d(nxp,nyp), wspd(nxp,nyp,nk1) )
  allocate( cape2d(nxp,nyp), cin2d(nxp,nyp), cor(nxp,nyp), ssi(nxp,nyp) )
  allocate( eh(nxp,nyp), srh(nxp,nyp), ltemp500(nxp,nyp), brn(nxp,nyp) )
  allocate( qfu(nxp,nyp,nk1), qfv(nxp,nyp,nk1), qfwind(nxp,nyp,nk1) )
  if(debug_level.ge.100) print *, "DEBUG: Success allocate"



  ! read temp [K] for surface
  open(unit=10, file="temp.bin",form='unformatted',access='direct',status='old',recl=nxs*nys*4)
  read(unit=10,rec=1) temp
  close(unit=10)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of temp"
  if(debug_level.ge.100) print *, "DEBUG: temp(1,1)    ",temp(1,1)

  ! read rh [%] for surface
  open(unit=11, file="rh.bin",form='unformatted',access='direct',status='old',recl=nxs*nys*4)
  read(unit=11,rec=1) rh
  close(unit=11)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of rh"
  if(debug_level.ge.100) print *, "DEBUG: rh(1,1)      ",rh(1,1)

  ! read prmsl [Pa] for surface
  open(unit=12, file="prmsl.bin",form='unformatted',access='direct',status='old',recl=nxs*nys*4)
  read(unit=12,rec=1) prmsl
  close(unit=12)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of prmsl"
  if(debug_level.ge.100) print *, "DEBUG: prmsl(1,1)   ",prmsl(1,1)


  ! read temp [K] for pressure
  open(unit=13, file="ttt.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=13,rec=1) tempp
  close(unit=13)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of tempp"
  if(debug_level.ge.100) print *, "DEBUG: tempp(1,1,1) ",tempp(1,1,1)

  ! read rh [%] for pressure
  open(unit=14, file="rhh.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=14,rec=1) rhp
  close(unit=14)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of rhp"
  if(debug_level.ge.100) print *, "DEBUG: rhp(1,1,1)   ",rhp(1,1,1)

  ! read hgt [m] for pressure
  open(unit=15, file="hgt.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=15,rec=1) hgt
  close(unit=15)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of hgt"
  if(debug_level.ge.100) print *, "DEBUG: hgt(1,1,1)   ",hgt(1,1,1)

  ! read uuu [m/s] for pressure
  open(unit=16, file="uuu.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=16,rec=1) uuu
  close(unit=16)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of uuu"
  if(debug_level.ge.100) print *, "DEBUG: uuu(1,1,1)   ",uuu(1,1,1)

  ! read vvv [m/s] for pressure
  open(unit=17, file="vvv.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=17,rec=1) vvv
  close(unit=17)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of vvv"
  if(debug_level.ge.100) print *, "DEBUG: vvv(1,1,1)   ",vvv(1,1,1)

  ! read www [m/s] for pressure
  open(unit=18, file="www.bin",form='unformatted',access='direct',status='old',recl=nxp*nyp*nk1*4)
  read(unit=18,rec=1) www
  close(unit=18)
  if(debug_level.ge.100) print *, "DEBUG: Success open file of www"
  if(debug_level.ge.100) print *, "DEBUG: www(1,1,1)   ",www(1,1,1)



  ! calculate indexes for surface
!$omp parallel default(shared)
!$omp do private(i,j)
  do j=1,nys
  do i=1,nxs
     press(i,j)=prmsl(i,j)*real(0.01)
     es(i,j)=RHT_2_e( rh(i,j), temp(i,j) )
     qv(i,j)=eP_2_qv( es(i,j), prmsl(i,j) )
     thetae(i,j)=TqvP_2_thetae( temp(i,j), qv(i,j), prmsl(i,j) )
     td(i,j)=es_TD(es(i,j))
  end do
  end do
!$omp end do
!$omp end parallel
  if(debug_level.ge.100) print *, "DEBUG: press(1,1)   ",press(1,1)
  if(debug_level.ge.100) print *, "DEBUG: es(1,1)      ",es(1,1)
  if(debug_level.ge.100) print *, "DEBUG: qv(1,1)      ",qv(1,1)
  if(debug_level.ge.100) print *, "DEBUG: thetae(1,1)  ",thetae(1,1)
  if(debug_level.ge.100) print *, "DEBUG: td(1,1)      ",td(1,1)

  ! calculate indexes for pressure
  do i=1,nxp
     x(i)=real(i)
  end do
  do j=1,nyp
     y(j)=real(j)
  end do
  do k=1,nk1
     z(k)=real(k)
  end do

  call calc_press(pressp,pint)

!$omp parallel default(shared)
!$omp do private(i,j,k)
  do k=1,nk1
  do j=1,nyp
  do i=1,nxp
     if(k.ge.12) then
        esp(i,j,k)=RHT_2_e( rhp(i,j,12), tempp(i,j,k) )
     else
        esp(i,j,k)=RHT_2_e( rhp(i,j,k), tempp(i,j,k) )
     end if
     qvp(i,j,k)=eP_2_qv( esp(i,j,k), pressp(k) )
     thetaep(i,j,k)=TqvP_2_thetae( tempp(i,j,k), qvp(i,j,k), pressp(k) )
     wspd(i,j,k)=sqrt(uuu(i,j,k)**2+vvv(i,j,k)**2)
     rhop(i,j,k)=TP_2_rho( tempp(i,j,k), pressp(k) )
     ptp(i,j,k)=theta_dry( tempp(i,j,k), pressp(k) )
     tdp(i,j,k)=es_TD( esp(i,j,k) )
     call calc_qflux( pressp(k), qvp(i,j,k), uuu(i,j,k), vvv(i,j,k), qfu(i,j,k) ,qfv(i,j,k), qfwind(i,j,k) )
  end do
  end do
  end do
!$omp end do
!$omp end parallel
  if(debug_level.ge.100) print *, "DEBUG: pressp(1)      ",pressp(1)
  if(debug_level.ge.100) print *, "DEBUG: esp(1,1,1)     ",esp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qvp(1,1,1)     ",qvp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: thetaep(1,1,1) ",thetaep(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: wspd(1,1,1)    ",wspd(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: rhop(1,1,1)    ",rhop(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: ptp(1,1,1)     ",ptp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: tdp(1,1,1)     ",tdp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfu(1,1,1)     ",qfu(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfv(1,1,1)     ",qfv(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfwind(1,1,1)  ",qfwind(1,1,1)


!$omp parallel default(shared)
!$omp do private(i,j)
  do j=1,nyp
  do i=1,nxp
     cape2d(i,j)=CAPE( pressp(:),hgt(i,j,:),qvp(i,j,:),tempp(i,j,:),500.,-999. )
     cin2d(i,j)=CIN( pressp(:),hgt(i,j,:),qvp(i,j,:),tempp(i,j,:),500.,999. )
     lcl2d(i,j)=z_LCL( 500.,hgt(i,j,:),tempp(i,j,:),pressp(:),qvp(i,j,:),-999. )
     lfc2d(i,j)=z_LFC( 500.,hgt(i,j,:),tempp(i,j,:),pressp(:),qvp(i,j,:),-999. )
     lnb2d(i,j)=z_LNB( 500.,hgt(i,j,:),tempp(i,j,:),pressp(:),qvp(i,j,:),1,-999. )
     ki(i,j)=tempp(i,j,6)+tdp(i,j,6)+tdp(i,j,8)-tempp(i,j,8)-tempp(i,j,10)
     tt(i,j)=tempp(i,j,6)+tdp(i,j,6)-real(2.)*tempp(i,j,10)
     pw(i,j)=precip_water( pressp(:), qvp(i,j,:) )
     ltemp500(i,j)=moist_laps_temp( pressp(1), tempp(i,j,1), pressp(10) )
     ssi(i,j)=tempp(i,j,10)-ltemp500(i,j)
     call calc_helicity( 1, 8, uuu(i,j,:), vvv(i,j,:), eh(i,j), srh(i,j) )
     call calc_brn( 3, 11, uuu(i,j,:), vvv(i,j,:), cape2d(i,j), brn(i,j) )
     call calc_wsh( 3, 11, uuu(i,j,:), vvv(i,j,:), wsh(i,j) )
     cor(i,j)=real(0.0001)
  end do
  end do
!$omp end do
!$omp end parallel
  call Ertel_PV( x, y, z, uuu, vvv, www, rhop, ptp, cor, pvp )
  if(debug_level.ge.100) print *, "DEBUG: cape2d(1,1)    ",cape2d(1,1)
  if(debug_level.ge.100) print *, "DEBUG: cin2d(1,1)     ",cin2d(1,1)
  if(debug_level.ge.100) print *, "DEBUG: lcl2d(1,1)     ",lcl2d(1,1)
  if(debug_level.ge.100) print *, "DEBUG: lfc2d(1,1)     ",lfc2d(1,1)
  if(debug_level.ge.100) print *, "DEBUG: lnb2d(1,1)     ",lnb2d(1,1)
  if(debug_level.ge.100) print *, "DEBUG: ki(1,1)        ",ki(1,1)
  if(debug_level.ge.100) print *, "DEBUG: tt(1,1)        ",tt(1,1)
  if(debug_level.ge.100) print *, "DEBUG: pw(1,1)        ",pw(1,1)
  if(debug_level.ge.100) print *, "DEBUG: eh(1,1)        ",eh(1,1)
  if(debug_level.ge.100) print *, "DEBUG: ssi(1,1)       ",ssi(1,1)
  if(debug_level.ge.100) print *, "DEBUG: srh(1,1)       ",srh(1,1)
  if(debug_level.ge.100) print *, "DEBUG: brn(1,1)       ",brn(1,1)
  if(debug_level.ge.100) print *, "DEBUG: wsh(1,1)       ",wsh(1,1)
  if(debug_level.ge.100) print *, "DEBUG: pvp(1,1,1)     ",pvp(1,1,1)



  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- surface ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output press [hPa] for surface 2D
  num=20
  open(unit=num, file="press.bin",form='unformatted',access='direct',recl=nxs*nys*4)
  write(unit=num,rec=1) press
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output press"

  ! output qv [g/kg] for surface 2D
  open(unit=num, file="qv.bin",form='unformatted',access='direct',recl=nxs*nys*4)
  write(unit=num,rec=1) qv*real(1000)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv"

  ! output thetae [K] for surface 2D
  open(unit=num, file="thetae.bin",form='unformatted',access='direct',recl=nxs*nys*4)
  write(unit=num,rec=1) thetae
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output thetae"

  ! output td [K] for surface 2D
  open(unit=num, file="td.bin",form='unformatted',access='direct',recl=nxs*nys*4)
  write(unit=num,rec=1) td
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output thetae"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- diagnostic ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output cape2d [J/kg] for pressure 
  open(unit=num, file="cape.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) cape2d
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output cape2d"

  ! output cin2d [J/kg] for pressure 
  open(unit=num, file="cin.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) real(-1.)*cin2d
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output cin2d"

  ! output lcl2d [m] for pressure 
  open(unit=num, file="lcl.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) lcl2d
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output lcl2d"

  ! output lfc2d [m] for pressure 
  open(unit=num, file="lfc.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) lfc2d
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output lfc2d"

  ! output lnb2d [m] for pressure 
  open(unit=num, file="lnb.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) lnb2d
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output lnb2d"

  ! output ki [C] for pressure
  open(unit=num, file="ki.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) ki-real(273.15)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output ki.bin"

  ! output tt [K] for pressure
  open(unit=num, file="tt.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) tt
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output tt.bin"

  ! output pw [mm] for pressure
  open(unit=num, file="pw.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pw*real(1.020408)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pw.bin"

  ! output ehi [m^2/s^2*J/kg] for pressure
  open(unit=num, file="ehi.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) (cape2d*srh)/real(160000)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output eh.bin"

  ! output srh [m^2/s^2] for pressure
  open(unit=num, file="srh.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) srh
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output srh.bin"

  ! output brn [-] for pressure
  open(unit=num, file="brn.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) brn
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output brn.bin"

  ! output ssi [K] for pressure
  open(unit=num, file="ssi.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) ssi
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output ssi.bin"

  ! output wsh [m/s] for pressure
  open(unit=num, file="wsh.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) wsh
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output wsh.bin"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 1000 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output qv1000 [g/kg] for pressure
  open(unit=num, file="qv1000.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,1)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv1000"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 975 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output qfwind975 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfwind975.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfwind(:,:,2)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfwind975"

  ! output qfu975 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfu975.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfu(:,:,2)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfu975"

  ! output qfv975 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfv975.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfv(:,:,2)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfv975"

  ! output thetae975 [K] for pressure
  open(unit=num, file="thetae975.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) thetaep(:,:,2)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output thetae975"

  ! output qv975 [K] for pressure
  open(unit=num, file="qv975.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,2)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv975"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 950 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output qfwind950 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfwind950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfwind(:,:,3)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfwind950"

  ! output qfu950 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfu950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfu(:,:,3)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfu950"

  ! output qfv950 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfv950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfv(:,:,3)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfv950"

  ! output qv950 [g/kg] for pressure
  open(unit=num, file="qv950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,3)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv950"

  ! output pv950 [PVU] for pressure
  open(unit=num, file="pv950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,3)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv950.bin"

  ! output thetae950 [K] for pressure
  open(unit=num, file="thetae950.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) thetaep(:,:,3)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output thetae950"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 925 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output qfwind925 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfwind925.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfwind(:,:,4)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfwind925"

  ! output qfu925 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfu925.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfu(:,:,4)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfu925"

  ! output qfv925 [g/(m^2*s^1)] for pressure
  open(unit=num, file="qfv925.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qfv(:,:,4)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qfv925"

  ! output qv925 [g/kg] for pressure
  open(unit=num, file="qv925.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,4)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv925"

  ! output thetae925 [K] for pressure
  open(unit=num, file="thetae925.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) thetaep(:,:,4)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output thetae925"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 850 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output temp850 [C] for pressure
  open(unit=num, file="temp850.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) tempp(:,:,6)-real(273.15)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output temp850"

  ! output qv850 [g/kg] for pressure
  open(unit=num, file="qv850.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,6)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv850"

  ! output pv850 [PVU] for pressure
  open(unit=num, file="pv850.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,6)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv850.bin"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 700 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output temp700 [C] for pressure
  open(unit=num, file="temp700.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) tempp(:,:,8)-real(273.15)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output temp700"

  ! output qv700 [g/kg] for pressure
  open(unit=num, file="qv700.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) qvp(:,:,8)*real(1000.)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output qv700"

  ! output pv700 [PVU] for pressure
  open(unit=num, file="pv700.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,8)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv700.bin"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 600 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! none


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 500 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output hgt500 [m] for pressure
  open(unit=num, file="hgt500.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) hgt(:,:,10)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output hgt500"

  ! output pv500 [PVU] for pressure
  open(unit=num, file="pv500.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,10)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv500.bin"

  ! output temp500 [C] for pressure
  open(unit=num, file="temp500.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) tempp(:,:,10)-real(273.15)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output temp500"

  ! output wspd500 [gph] for pressure
  open(unit=num, file="wspd500.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) wspd(:,:,10)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output wspd500"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 300 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output pv300 [PVU] for pressure
  open(unit=num, file="pv300.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,12)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv300.bin"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 250 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output wspd250 [m/s] for pressure
  open(unit=num, file="wspd250.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) wspd(:,:,13)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output wspd250"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 200 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output pv200 [PVU] for pressure
  open(unit=num, file="pv200.bin",form='unformatted',access='direct',recl=nxp*nyp*4)
  write(unit=num,rec=1) pvp(:,:,14)*real(0.01)
  close(unit=num)
  if(debug_level.ge.100) print *, "DEBUG: Success output pv200.bin"


  deallocate( temp,rh,prmsl,press,es,qv,thetae,td,pint )
  deallocate( tempp,rhp,hgt,pressp,x,y,z,esp,qvp,thetaep )
  deallocate( uuu,vvv,www,wspd,ptp,rhop,pvp,tdp,ki,tt,pw )
  deallocate( lcl2d,lfc2d,lnb2d,cape2d,cin2d,cor,eh,srh )
  deallocate( ssi,ltemp500,brn,qfu,qfv,qfwind,wsh )
  if(debug_level.ge.100) print *, "DEBUG: Success deallocate all the values"

  if(debug_level.ge.100) print *, "DEBUG: Everything cool !!!"

  stop
end program calc_index
