!
! Program of calcucate indexes for JMA-MSM
! produced by Takashi Unuma, Kyoto Univ.
! Last modified: 2013/01/19
!

program calc_index

  USE Thermo_Function
  USE Thermo_Advanced_Function
  USE Thermo_Advanced_Routine

  implicit none

  integer :: i, j, k
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
  real, dimension(:,:),   allocatable :: cor,ki,tt,pw,eh,srh,ehi
  real, dimension(:,:),   allocatable :: ltemp500,ssi,brn,wsh
  real, dimension(:,:,:), allocatable :: tempp,rhp,hgt,uuu,vvv,www
  real, dimension(:,:,:), allocatable :: esp,qvp,thetaep,wspd,wdir
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
  allocate( lcl2d(nxp,nyp), lfc2d(nxp,nyp), lnb2d(nxp,nyp) )
  allocate( wspd(nxp,nyp,nk1), wdir(nxp,nyp,nk1), ehi(nxp,nyp) )
  allocate( cape2d(nxp,nyp), cin2d(nxp,nyp), cor(nxp,nyp), ssi(nxp,nyp) )
  allocate( eh(nxp,nyp), srh(nxp,nyp), ltemp500(nxp,nyp), brn(nxp,nyp) )
  allocate( qfu(nxp,nyp,nk1), qfv(nxp,nyp,nk1), qfwind(nxp,nyp,nk1) )
  if(debug_level.ge.100) print *, "DEBUG: Success allocate"


  ! input files
  ! read temp [K] for surface
  CALL file_read2d( "temp.bin",nxs,nys,temp(:,:) )
  ! read rh [%] for surface
  CALL file_read2d( "rh.bin",nxs,nys,rh(:,:) )
  ! read prmsl [Pa] for surface
  CALL file_read2d( "prmsl.bin",nxs,nys,prmsl(:,:) )
  ! read temp [K] for pressure
  CALL file_read3d( "ttt.bin",nxs,nys,nk1,tempp(:,:,:) )
  ! read rh [%] for pressure
  CALL file_read3d( "rhh.bin",nxs,nys,nk2,rhp(:,:,:) )
  ! read hgt [m] for pressure
  CALL file_read3d( "hgt.bin",nxs,nys,nk1,hgt(:,:,:) )
  ! read uuu [m/s] for pressure
  CALL file_read3d( "uuu.bin",nxs,nys,nk1,uuu(:,:,:) )
  ! read vvv [m/s] for pressure
  CALL file_read3d( "vvv.bin",nxs,nys,nk1,vvv(:,:,:) )
  ! read www [m/s] for pressure
  CALL file_read3d( "www.bin",nxs,nys,nk1,www(:,:,:) )


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
     rhop(i,j,k)=TP_2_rho( tempp(i,j,k), pressp(k) )
     ptp(i,j,k)=theta_dry( tempp(i,j,k), pressp(k) )
     tdp(i,j,k)=es_TD( esp(i,j,k) )
     call calc_qflux( pressp(k), qvp(i,j,k), uuu(i,j,k), vvv(i,j,k), qfu(i,j,k) ,qfv(i,j,k), qfwind(i,j,k) )
     call calc_wspd(uuu(i,j,k),vvv(i,j,k),wspd(i,j,k))
     call calc_wdir(uuu(i,j,k),vvv(i,j,k),wdir(i,j,k))
  end do
  end do
  end do
!$omp end do
!$omp end parallel
  if(debug_level.ge.100) print *, "DEBUG: pressp(1)      ",pressp(1)
  if(debug_level.ge.100) print *, "DEBUG: esp(1,1,1)     ",esp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qvp(1,1,1)     ",qvp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: thetaep(1,1,1) ",thetaep(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: rhop(1,1,1)    ",rhop(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: ptp(1,1,1)     ",ptp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: tdp(1,1,1)     ",tdp(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfu(1,1,1)     ",qfu(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfv(1,1,1)     ",qfv(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: qfwind(1,1,1)  ",qfwind(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: wspd(1,1,1)    ",wspd(1,1,1)
  if(debug_level.ge.100) print *, "DEBUG: wdir(1,1,1)    ",wdir(1,1,1)


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
     pw(i,j)=precip_water( pressp(:), qvp(i,j,:) )*real(1.020408)
     ltemp500(i,j)=moist_laps_temp( pressp(1), tempp(i,j,1), pressp(10) )
     ssi(i,j)=tempp(i,j,10)-ltemp500(i,j)
     CALL calc_helicity( 1, 8, uuu(i,j,:), vvv(i,j,:), eh(i,j), srh(i,j) )
     ehi(i,j)=(cape2d(i,j)*srh(i,j))/real(160000.)
     CALL calc_brn( 3, 11, uuu(i,j,:), vvv(i,j,:), cape2d(i,j), brn(i,j) )
     CALL calc_wsh( 3, 11, uuu(i,j,:), vvv(i,j,:), wsh(i,j) )
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


  ! make undef data
!  CALL undef2nan()


  ! output files
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- surface ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output press [hPa] for surface 2D
  CALL file_write2d( "press.bin",nxs,nys,press(:,:) )
  ! output qv [g/kg] for surface 2D
  CALL file_write2d( "qv.bin",nxs,nys,qv(:,:)*real(1000.) )
  ! output thetae [K] for surface 2D
  CALL file_write2d( "thetae.bin",nxs,nys,thetae(:,:) )
  ! output td [K] for surface 2D
  CALL file_write2d( "td.bin",nxs,nys,td(:,:) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- diagnostic ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output cape2d [J/kg] for pressure 
  CALL file_write2d( "cape.bin",nxp,nyp,cape2d(:,:) )
  ! output cin2d [J/kg] for pressure 
  CALL file_write2d( "cin.bin",nxp,nyp,real(-1.)*cin2d(:,:) )
  ! output lcl2d [m] for pressure 
  CALL file_write2d( "lcl.bin",nxp,nyp,lcl2d(:,:) )
  ! output lfc2d [m] for pressure 
  CALL file_write2d( "lfc.bin",nxp,nyp,lfc2d(:,:) )
  ! output lnb2d [m] for pressure 
  CALL file_write2d( "lnb.bin",nxp,nyp,lnb2d(:,:) )
  ! output ki [C] for pressure
  CALL file_write2d( "ki.bin",nxp,nyp,ki(:,:)-real(273.15) )
  ! output tt [K] for pressure
  CALL file_write2d( "tt.bin",nxp,nyp,tt(:,:) )
  ! output pw [mm] for pressure
  CALL file_write2d( "pw.bin",nxp,nyp,pw(:,:) )
  ! output ehi [m^2/s^2*J/kg] for pressure
  CALL file_write2d( "ehi.bin",nxp,nyp,ehi(:,:) )
  ! output srh [m^2/s^2] for pressure
  CALL file_write2d( "srh.bin",nxp,nyp,srh(:,:) )
  ! output brn [-] for pressure
  CALL file_write2d( "brn.bin",nxp,nyp,brn(:,:) )
  ! output ssi [K] for pressure
  CALL file_write2d( "ssi.bin",nxp,nyp,ssi(:,:) )
  ! output wsh [m/s] for pressure
  CALL file_write2d( "wsh.bin",nxp,nyp,wsh(:,:) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 1000 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output qv1000 [g/kg] for pressure
  CALL file_write2d( "qv1000.bin",nxp,nyp,qvp(:,:,1)*real(1000.) )
  ! output u1000 [m/s] for pressure
  CALL file_write2d( "u1000.bin",nxp,nyp,uuu(:,:,1) )
  ! output v1000 [m/s] for pressure
  CALL file_write2d( "v1000.bin",nxp,nyp,vvv(:,:,1) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 975 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output qfwind975 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfwind975.bin",nxp,nyp,qfwind(:,:,2)*real(1000.) )
  ! output qfu975 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfu975.bin",nxp,nyp,qfu(:,:,2)*real(1000.) )
  ! output qfv975 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfv975.bin",nxp,nyp,qfv(:,:,2)*real(1000.) )
  ! output thetae975 [K] for pressure
  CALL file_write2d( "thetae975.bin",nxp,nyp,thetaep(:,:,2) )
  ! output qv975 [K] for pressure
  CALL file_write2d( "qv975.bin",nxp,nyp,qvp(:,:,2)*real(1000.) )
  ! output u975 [m/s] for pressure
  CALL file_write2d( "u975.bin",nxp,nyp,uuu(:,:,2) )
  ! output v975 [m/s] for pressure
  CALL file_write2d( "v975.bin",nxp,nyp,vvv(:,:,2) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 950 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! output qfwind950 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfwind950.bin",nxp,nyp,qfwind(:,:,3)*real(1000.) )
  ! output qfu950 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfu950.bin",nxp,nyp,qfu(:,:,3)*real(1000.) )
  ! output qfv950 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfv950.bin",nxp,nyp,qfv(:,:,3)*real(1000.) )
  ! output qv950 [g/kg] for pressure
  CALL file_write2d( "qv950.bin",nxp,nyp,qvp(:,:,3)*real(1000.) )
  ! output pv950 [PVU] for pressure
  CALL file_write2d( "pv950.bin",nxp,nyp,pvp(:,:,3)*real(0.01) )
  ! output thetae950 [K] for pressure
  CALL file_write2d( "thetae950.bin",nxp,nyp,thetaep(:,:,3) )
  ! output u950 [m/s] for pressure
  CALL file_write2d( "u950.bin",nxp,nyp,uuu(:,:,3) )
  ! output v950 [m/s] for pressure
  CALL file_write2d( "v950.bin",nxp,nyp,vvv(:,:,3) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 925 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output qfwind925 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfwind925.bin",nxp,nyp,qfwind(:,:,4)*real(1000.) )
  ! output qfu925 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfu925.bin",nxp,nyp,qfu(:,:,4)*real(1000.) )
  ! output qfv925 [g/(m^2*s^1)] for pressure
  CALL file_write2d( "qfv925.bin",nxp,nyp,qfv(:,:,4)*real(1000.) )
  ! output qv925 [g/kg] for pressure
  CALL file_write2d( "qv925.bin",nxp,nyp,qvp(:,:,4)*real(1000.) )
  ! output thetae925 [K] for pressure
  CALL file_write2d( "thetae925.bin",nxp,nyp,thetaep(:,:,4) )
  ! output u925 [m/s] for pressure
  CALL file_write2d( "u925.bin",nxp,nyp,uuu(:,:,4) )
  ! output v925 [m/s] for pressure
  CALL file_write2d( "v925.bin",nxp,nyp,vvv(:,:,4) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 850 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output temp850 [C] for pressure
  CALL file_write2d( "temp850.bin",nxp,nyp,tempp(:,:,6)-real(273.15) )
  ! output qv850 [g/kg] for pressure
  CALL file_write2d( "qv850.bin",nxp,nyp,qvp(:,:,6)*real(1000.) )
  ! output pv850 [PVU] for pressure
  CALL file_write2d( "pv850.bin",nxp,nyp,pvp(:,:,6)*real(0.01) )
  ! output u850 [m/s] for pressure
  CALL file_write2d( "u850.bin",nxp,nyp,uuu(:,:,6) )
  ! output v850 [m/s] for pressure
  CALL file_write2d( "v850.bin",nxp,nyp,vvv(:,:,6) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 700 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output temp700 [C] for pressure
  CALL file_write2d( "temp700.bin",nxp,nyp,tempp(:,:,8)-real(273.15) )
  ! output qv700 [g/kg] for pressure
  CALL file_write2d( "qv700.bin",nxp,nyp,qvp(:,:,8)*real(1000.) )
  ! output pv700 [PVU] for pressure
  CALL file_write2d( "pv700.bin",nxp,nyp,pvp(:,:,8)*real(0.01) )
  ! output u700 [m/s] for pressure
  CALL file_write2d( "u700.bin",nxp,nyp,uuu(:,:,8) )
  ! output v700 [m/s] for pressure
  CALL file_write2d( "v700.bin",nxp,nyp,vvv(:,:,8) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 600 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! none

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 500 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output hgt500 [m] for pressure
  CALL file_write2d( "hgt500.bin",nxp,nyp,hgt(:,:,10) )
  ! output pv500 [PVU] for pressure
  CALL file_write2d( "pv500.bin",nxp,nyp,pvp(:,:,10)*real(0.01) )
  ! output temp500 [C] for pressure
  CALL file_write2d( "temp500.bin",nxp,nyp,tempp(:,:,10)-real(273.15) )
  ! output wspd500 [gph] for pressure
  CALL file_write2d( "wspd500.bin",nxp,nyp,wspd(:,:,10) )
  ! output u500 [m/s] for pressure
  CALL file_write2d( "u500.bin",nxp,nyp,uuu(:,:,10) )
  ! output v500 [m/s] for pressure
  CALL file_write2d( "v500.bin",nxp,nyp,vvv(:,:,10) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 300 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output pv300 [PVU] for pressure
  CALL file_write2d( "pv300.bin",nxp,nyp,pvp(:,:,12)*real(0.01) )
  ! output u300 [m/s] for pressure
  CALL file_write2d( "u300.bin",nxp,nyp,uuu(:,:,12) )
  ! output v300 [m/s] for pressure
  CALL file_write2d( "v300.bin",nxp,nyp,vvv(:,:,12) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 250 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output wspd250 [m/s] for pressure
  CALL file_write2d( "wspd250.bin",nxp,nyp,wspd(:,:,13) )
  ! output u250 [m/s] for pressure
  CALL file_write2d( "u250.bin",nxp,nyp,uuu(:,:,13) )
  ! output v250 [m/s] for pressure
  CALL file_write2d( "v250.bin",nxp,nyp,vvv(:,:,13) )

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! --- 200 hPa ---
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! output pv200 [PVU] for pressure
  CALL file_write2d( "pv200.bin",nxp,nyp,pvp(:,:,14)*real(0.01) )
  ! output u200 [m/s] for pressure
  CALL file_write2d( "u200.bin",nxp,nyp,uuu(:,:,14) )
  ! output v200 [m/s] for pressure
  CALL file_write2d( "v200.bin",nxp,nyp,vvv(:,:,14) )

!  status = grd_create( 'testpv200.grd', pvp(:,:,14)*real(0.01), (/120d0,150d0/), (/22.4d0,47.6d0/), &
!       & (/0.125d0,0.05d0/), NaN=-999., jscan=1 )
!  if(status.ge.1) print *, "DEBUG: Success output testpv200"


  deallocate( temp,rh,prmsl,press,es,qv,thetae,td,pint )
  deallocate( tempp,rhp,hgt,pressp,x,y,z,esp,qvp,thetaep )
  deallocate( uuu,vvv,www,wspd,ptp,rhop,pvp,tdp,ki,tt,pw )
  deallocate( lcl2d,lfc2d,lnb2d,cape2d,cin2d,cor,eh,srh,ehi )
  deallocate( ssi,ltemp500,brn,qfu,qfv,qfwind,wsh,wdir )
  if(debug_level.ge.100) print *, "DEBUG: Success deallocate all the values"

  if(debug_level.ge.100) print *, "DEBUG: Everything is cool !!!"

  stop
end program calc_index
