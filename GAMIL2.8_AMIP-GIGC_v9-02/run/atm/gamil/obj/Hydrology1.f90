# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90"

# 1 "./misc.h" 1
# 2 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90" 2

# 1 "./preproc.h" 1






 
# 3 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90" 2

subroutine Hydrology1 (clm)

!-----------------------------------------------------------------------
!
!  CLMCLMCLMCLMCLMCLMCLMCLMCLMCL  A community developed and sponsored, freely
!  L                           M  available land surface process model.
!  M --COMMUNITY LAND MODEL--  C
!  C                           L
!  LMCLMCLMCLMCLMCLMCLMCLMCLMCLM
!
!-----------------------------------------------------------------------
! Purpose:
! Calculation of 
! (1) water storage of intercepted precipitation
! (2) direct throughfall and canopy drainage of precipitation
! (3) the fraction of foliage covered by water and the fraction
!     of foliage that is dry and transpiring. 
! (4) snow layer initialization if the snow accumulation exceeds 10 mm.
!
! Note:  The evaporation loss is taken off after the calculation of leaf 
! temperature in the subroutine clm_leaftem.f90, not in this subroutine.
!
! Method:
!
! Author:
! 15 September 1999: Yongjiu Dai; Initial code
! 15 December 1999:  Paul Houser and Jon Radakovich; F90 Revision 
! April 2002: Vertenstein/Oleson/Levis; Final form
!-----------------------------------------------------------------------
! $Id: Hydrology1.F90,v 1.4.2.3 2002/06/15 13:50:15 erik Exp $
!-----------------------------------------------------------------------

  use shr_kind_mod, only: r8 => shr_kind_r8
  use clmtype
  use clm_varcon, only : tfrz, istice, istwet, istsoil
  implicit none

!----Arguments----------------------------------------------------------

  type (clm1d), intent(inout) :: clm        !CLM 1-D Module

!----Local Variables----------------------------------------------------

  integer newnode       ! flag when new snow node is set, (1=yes, 0=no)
  real(r8) prcp         ! precipitation rate [mm/s]
  real(r8) h2ocanmx     ! maximum allowed water on canopy [mm]
  real(r8) fpi          ! coefficient of interception [-]
  real(r8) xrun         ! water that exceeds the leaf capacity [mm/s]
  real(r8) qflx_candrip ! rate of canopy runoff and snow falling off canopy [mm/s]
  real(r8) qflx_through ! direct throughfall [mm/s]
  real(r8) dz_snowf     ! layer thickness rate change due to precipitation [mm/s]
  real(r8) flfall       ! fraction of liquid water within falling precip. [-]
  real(r8) bifall       ! bulk density of newly fallen dry snow [kg/m3]
  real(r8) coefb        ! Slope of "Alta" expression for dependence of flfall on temp
  real(r8) coefa        ! Offset of "Alta" expression for dependence of flfall on temp

!----End Variable List--------------------------------------------------

!
! [1] Canopy interception and precipitation onto ground surface
!

!
! [1.1] Add precipitation to leaf water 
!

  if (clm%itypwat==istsoil .OR. clm%itypwat==istwet) then

     qflx_candrip = 0.                 ! rate of canopy runoff
     qflx_through = 0.                 ! precipitation direct through canopy
     clm%qflx_prec_intr = 0.           ! intercepted precipitation  

     prcp = clm%forc_rain + clm%forc_snow  ! total precipitation

     if (clm%frac_veg_nosno == 1 .AND. prcp > 0.) then

!
! The leaf water capacities for solid and liquid are different, 
! generally double for snow, but these are of somewhat less significance
! for the water budget because of lower evap. rate at lower temperature.
! Hence, it is reasonable to assume that vegetation storage of solid water 
! is the same as liquid water.
!

        h2ocanmx = clm%dewmx * (clm%elai + clm%esai)

!
! Direct throughfall
!

        fpi = 1. - exp(-0.5*(clm%elai + clm%esai))
        qflx_through  = prcp*(1.-fpi)

!
! Water storage of intercepted precipitation and dew
!

        clm%qflx_prec_intr = prcp*fpi
        clm%h2ocan = max(0._r8, clm%h2ocan + clm%dtime*clm%qflx_prec_intr)

!
! Initialize rate of canopy runoff and snow falling off canopy
!

        qflx_candrip = 0.0

!
! Water that exceeds the leaf capacity
!

        xrun = (clm%h2ocan - h2ocanmx)/clm%dtime

!
! Test on maximum dew on leaf
!

        if (xrun > 0.) then
           qflx_candrip = xrun
           clm%h2ocan = h2ocanmx
        endif

     endif

  else if (clm%itypwat == istice) then

     clm%qflx_prec_intr = 0.
     clm%h2ocan = 0.
     qflx_candrip = 0.
     qflx_through = 0.  

  endif

!
! [1.2] Precipitation onto ground (kg/(m2 s))
!

  if (clm%frac_veg_nosno == 0) then
     clm%qflx_prec_grnd = clm%forc_rain + clm%forc_snow
  else
     clm%qflx_prec_grnd = qflx_through + qflx_candrip  
  endif
  
!
! [1.3] The percentage of liquid water by mass is arbitrarily set to 
!       vary linearly with air temp, from 0% at 273.16 to 40% max at 275.16.
!

  if (clm%itypprc <= 1) then
     flfall = 1.               ! fraction of liquid water within falling precip
     if (clm%do_capsnow) then
        clm%qflx_snowcap = clm%qflx_prec_grnd
        clm%qflx_snow_grnd = 0.
        clm%qflx_rain_grnd = 0.
     else
        clm%qflx_snowcap = 0.
        clm%qflx_snow_grnd = 0.                  ! ice onto ground (mm/s)
        clm%qflx_rain_grnd = clm%qflx_prec_grnd  ! liquid water onto ground (mm/s)
     endif
     dz_snowf = 0.             ! rate of snowfall, snow depth/s (m/s)
  else
# 175 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90"
     if (clm%forc_t <= tfrz) then
        flfall = 0.
     else if (clm%forc_t <= tfrz+2.) then
        flfall = -54.632 + 0.2*clm%forc_t
     else
        flfall = 0.4
     endif

     
!
! Use Alta relationship, Anderson(1976); LaChapelle(1961), 
! U.S.Department of Agriculture Forest Service, Project F, 
! Progress Rep. 1, Alta Avalanche Study Center:Snow Layer Densification.
!

# 199 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/biogeophys/Hydrology1.F90"
     if (clm%forc_t > tfrz + 2.) then
        bifall =189.
     else if (clm%forc_t > tfrz - 15.) then
        bifall=50. + 1.7*(clm%forc_t - tfrz + 15.)**1.5
     else
        bifall=50.
     endif

     
     if (clm%do_capsnow) then
        clm%qflx_snowcap = clm%qflx_prec_grnd
        clm%qflx_snow_grnd = 0.
        clm%qflx_rain_grnd = 0.
        dz_snowf = 0.
     else
        clm%qflx_snowcap = 0.
        clm%qflx_snow_grnd = clm%qflx_prec_grnd*(1.-flfall)                 
        clm%qflx_rain_grnd = clm%qflx_prec_grnd*flfall
        dz_snowf = clm%qflx_snow_grnd/bifall                
        clm%snowdp = clm%snowdp + dz_snowf*clm%dtime         
        clm%h2osno = clm%h2osno + clm%qflx_snow_grnd*clm%dtime
     endif

     if (clm%itypwat==istwet .AND. clm%t_grnd>tfrz) then
        clm%h2osno=0. 
        clm%snowdp=0. 
        clm%snowage=0.
     endif

  endif

!
! [2] Determine the fraction of foliage covered by water and the 
!     fraction of foliage that is dry and transpiring.
!

  call Fwet(clm)

!
! [3] When the snow accumulation exceeds 10 mm, initialize snow layer.
!     Currently, the water temperature for the precipitation is simply set 
!     to the surface air temperature.
!

  newnode = 0    ! flag for when snow node will be initialized
  if (clm%snl == 0 .AND. clm%qflx_snow_grnd > 0.0 .AND. clm%snowdp >= 0.01) then
     newnode = 1
     clm%snl = -1
     clm%dz(0) = clm%snowdp                       ! meter
     clm%z(0) = -0.5*clm%dz(0)
     clm%zi(-1) = -clm%dz(0)
     clm%snowage = 0.                             ! snow age
     clm%t_soisno (0) = min(tfrz, clm%forc_t)     ! K
     clm%h2osoi_ice(0) = clm%h2osno               ! kg/m2
     clm%h2osoi_liq(0) = 0.                       ! kg/m2
     clm%frac_iceold(0) = 1.
  endif

!
! The change of ice partial density of surface node due to precipitation.
! Only ice part of snowfall is added here, the liquid part will be added later
!

  if (clm%snl < 0 .AND. newnode == 0) then
     clm%h2osoi_ice(clm%snl+1) = clm%h2osoi_ice(clm%snl+1)+clm%dtime*clm%qflx_snow_grnd
     clm%dz(clm%snl+1) = clm%dz(clm%snl+1)+dz_snowf*clm%dtime
  endif

end subroutine Hydrology1


!========================================================================

subroutine Fwet(clm)

  use shr_kind_mod, only: r8 => shr_kind_r8
  use clmtype
  implicit none

!=== Arguments ===========================================================

  type (clm1d), intent(inout) :: clm        !CLM 1-D Module

!=== Local Variables =====================================================

! fwet is the fraction of all vegetation surfaces which are wet 
! including stem area which contribute to evaporation.
! fdry is the fraction of elai which is dry because only leaves
! can transpire.  Adjusted for stem area which does not transpire.

  real(r8) vegt             ! frac_veg_nosno*lsai
  real(r8) dewmxi           ! inverse of maximum allowed dew [1/mm]

!=== End Variable List ===================================================

  if (clm%frac_veg_nosno == 1) then
     if (clm%h2ocan > 0.) then
        vegt     = clm%frac_veg_nosno*(clm%elai + clm%esai)
        dewmxi   = 1.0/clm%dewmx
        clm%fwet = ((dewmxi/vegt)*clm%h2ocan)**.666666666666
        clm%fwet = min (clm%fwet,1.0_r8)     ! Check for maximum limit of fwet
     else
        clm%fwet = 0.
     endif
     clm%fdry = (1.-clm%fwet)*clm%elai/(clm%elai+clm%esai)




  else
     clm%fwet = 0.
     clm%fdry = 0.
  endif

end subroutine Fwet
