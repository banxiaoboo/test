# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90"

# 1 "./misc.h" 1
# 2 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90" 2

# 1 "./preproc.h" 1






 
# 3 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90" 2

module atm_lndMod



!----------------------------------------------------------------------- 
! 
! Purpose: 
! Atm - Land interface module
! 
! Method: 
! If running as part of cam, the land surface model must use the same 
! grid as the cam. The land surface model calculates its own net solar 
! radiation and net longwave radiation at the surface. The net longwave 
! radiation at the surface will differ somewhat from that calculated in 
! the atmospheric model because the atm model will use the upward 
! longwave flux (or radiative temperature) from the previous time
! step whereas the land surface model uses the flux for the current
! time step. The net solar radiation should equal that calculated
! in the atmospheric model. If not, there is a problem in how the models
! are coupled.
! 
! Author: Mariana Vertenstein
! 
!-----------------------------------------------------------------------
! $Id: atm_lndMod.F90,v 1.1.2.8 2002/08/28 15:41:10 erik Exp $
!-----------------------------------------------------------------------

  use shr_kind_mod, only: r8 => shr_kind_r8
  use pmgrid, only: plon, plond, plat
  use tracers, only: pcnst, pnats
  use rgrid, only: nlon
  use ppgrid, only: pcols, begchunk, endchunk
  use phys_grid
  use comsrf, only :snowhland, srfflx_state2d, srfflx_parm2d,srfflx_parm,surface_state,landfrac
  use history, only :  ctitle, inithist, nhtfrq, mfilt
  use filenames, only: caseid
  use shr_const_mod, only: SHR_CONST_PI
  implicit none
  
  private              ! By default make data private
  integer :: landmask(plon,plat) !2d land mask
  integer, allocatable, dimension(:,:) :: landmask_chunk
  
  integer , private, parameter :: nsend_atm = 16
  real(r8), private :: send2d(plon,nsend_atm, plat) !output to clm
  real(r8), allocatable, dimension(:,:,:) :: send2d_chunk
  
  integer , private, parameter :: nrecv_atm = 13
  real(r8), private :: recv2d(plon,nrecv_atm, plat) !input from clm
  real(r8), allocatable, dimension(:,:,:) :: recv2d_chunk

  public atmlnd_ini, atmlnd_drv ! Public interfaces


!===============================================================================
CONTAINS
!===============================================================================

  subroutine atmlnd_ini(srfflx2d)

    use initializeMod, only : initialize           !initialization of clm 
    use lnd_atmMod, only : allocate_atmlnd_ini, lnd_to_atm_mapping_ini 
    use error_messages, only: alloc_err

    use mpishorthand

    use commap    
    use time_manager, only: get_nstep
    use filenames,    only: mss_irt


# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/comsol.h" 1
!
!	Common's to do with solar radiation
!
!	$Id: comsol.h,v 1.3 2000/06/02 16:20:40 jet Exp $
!
! Visible optical depth
!
      real(r8) tauvis     ! Visible optical depth

      common /comvis/ tauvis
!
! Solar constant
!
      real(r8) scon       ! Solar constant

      common /comsol/ scon
!
! Earth's orbital characteristics
!	
      real(r8) eccen       ! Earth's eccentricity factor (unitless) (typically 0 to 0.1)
      real(r8) obliq       ! Earth's obliquity angle (degree's) (-90 to +90) (typically 22-26)
      real(r8) mvelp       ! Earth's moving vernal equinox at perhelion (degree's) (0 to 360.0)
      integer iyear_AD ! Year (AD) to simulate above earth's orbital parameters for
!
! Orbital information after processed by orbit_params
!
      real(r8) obliqr      ! Earth's obliquity in radians
      real(r8) lambm0      ! Mean longitude of perihelion at the 
!                          ! vernal equinox (radians)
      real(r8) mvelpp      ! Earth's moving vernal equinox longitude
!                          ! of perihelion plus pi (radians)
!
      common /comorb/ eccen   , obliq   , mvelp   , obliqr  
      common /comorb/ lambm0  , mvelpp  , iyear_AD

# 75 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90" 2

# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/comctl.h" 1
!----------------------------------------------------------------------- 
! 
! Purpose: Model control variables
! 
! Author: CCM Core Group
! 
!-----------------------------------------------------------------------
!! (wh 2003.04.30)
!! (wh 2003.12.27)

      common /comctl/ itsst   ,nsrest  ,iradsw  ,iradlw  ,iradae
      common /comctl/ nrefrq
      common /comctl/ anncyc  ,nlend   ,nlres   ,nlhst   ,lbrnch
      common /comctl/ aeres   ,ozncyc  ,sstcyc  ,icecyc
      common /comctl/ adiabatic,flxave
      common /comctl/ trace_gas, trace_test1,trace_test2, trace_test3
!!    common /comctl/ readtrace,ideal_phys, nsplit, iord, jord, kord, use_eta, aqua_planet
      common /comctl/ readtrace,ideal_phys,                                    aqua_planet
      common /comctl/ doRamp_ghg, doRamp_so4, doRamp_scon, fullgrid, doIPCC_so4, &
                      doCmip5_scon,doCmip5_ghg  !!(wh)
      common /comctl/ print_step_cost
      common /comctl/ doabsems, dosw, dolw, indirect

!!    common /comctl_r8/ divdampn, precc_thresh, precl_thresh
      common /comctl_r8/           precc_thresh, precl_thresh

      integer itsst             ! Sea surf. temp. update freq. (iters)
      integer nsrest            ! Restart flag
      integer iradsw            ! Iteration freq. for shortwave radiation
      integer iradlw            ! Iteration freq. for longwave radiation
      integer iradae            ! Iteration freq. for absorptivity/emissivity
      integer nrefrq            ! Restart write freq.

! f-v dynamics specific
! _ord = 1: first order upwind
! _ord = 2: 2nd order van Leer (Lin et al 1994)
! _ord = 3: standard PPM 
! _ord = 4: enhanced PPM (default)
!!      integer nsplit            ! Lagrangian time splits (Lin-Rood only)
!!      integer iord              ! scheme to be used in E-W direction
!!      integer jord              ! scheme to be used in N-S direction
!!      integer kord              ! scheme to be used for vertical mapping
!!      logical use_eta           ! Flag to use a's and b's set by dynamics/lr/set_eta.F90

      logical aqua_planet       ! Flag to run model in "aqua planet" mode

      logical anncyc            ! true => do annual cycle (otherwise perpetual)
      logical nlend             ! true => end of run
      logical nlres             ! true => continuation run
      logical nlhst             ! true => regeneration run
      logical lbrnch            ! true => branch run
      logical aeres             ! true => read/write a/e data to/from restart file
      logical ozncyc            ! true => cycle ozone dataset
      logical sstcyc            ! true => cycle sst dataset
      logical icecyc            ! true => cycle ice fraction dataset
      logical adiabatic         ! true => no physics
      logical ideal_phys        ! true => run "idealized" model configuration
      logical flxave            ! true => send to coupler only on radiation time steps

      logical trace_gas         ! true => turn on greenhouse gas code
      logical trace_test1       ! true => turn on test tracer code with 1 tracer
      logical trace_test2       ! true => turn on test tracer code with 2 tracers
      logical trace_test3       ! true => turn on test tracer code with 3 tracers
      logical readtrace         ! true => obtain initial tracer data from IC file

      logical doRamp_ghg        ! true => turn on ramping for ghg
      logical doRamp_so4        ! true => turn on ramping for so4
      logical doRamp_scon       ! true => turn on ramping for scon
      logical doIPCC_so4        ! true => turn on IPCC scenario for so4  !!(wh) 
      logical doCmip5_scon      !
      logical doCmip5_ghg       ! ljli2010-08-12
      logical fullgrid          ! true => no grid reduction towards poles

      logical print_step_cost   ! true => print per-timestep cost info

      logical doabsems          ! True => abs/emiss calculation this timestep
      logical dosw              ! True => shortwave calculation this timestep
      logical dolw              ! True => longwave calculation this timestep
      logical indirect          ! True => include indirect radiative effects of sulfate aerosols

!!    real(r8) divdampn         ! Number of days to invoke divergence damper
      real(r8) precc_thresh     ! Precipitation threshold for PRECCINT and PRECCFRQ
      real(r8) precl_thresh     ! Precipitation threshold for PRECLINT and PRECLFRQ
# 76 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/lnd/clm2/src/main/atm_lndMod.F90" 2

!-----------------------------------------------------------------------
! Initialize land surface model and obtain relevant atmospheric model 
! arrays back from (i.e. albedos, surface temperature and snow cover over land)
!-----------------------------------------------------------------------

!---------------------------Local workspace-----------------------------
    integer  :: i,lat,n,lchnk,ncols !indices
    integer  :: istat               !error return
    integer  :: nstep               !current timestep number
    integer  :: lats(pcols)         !chunk latitudes
    integer  :: lons(pcols)         !chunk longitudes
    real(r8) :: oro_glob(plon,plat)!global oro field
    real(r8) :: lsmlandfrac(plon,plat) !2d fractional land
    real(r8) :: latixy(plon,plat)   !2d latitude  grid (degrees)
    real(r8) :: longxy(plon,plat)   !2d longitude grid (degrees)
    real(r8) :: pi
    type(srfflx_parm), intent(inout), dimension(begchunk:endchunk) :: srfflx2d
!-----------------------------------------------------------------------
! Time management variables.

    nstep = get_nstep()

! Allocate land model chunk data structures

   allocate( landmask_chunk(pcols,begchunk:endchunk), stat=istat )
   call alloc_err( istat, 'atmlnd_ini', 'landmask_chunk', &
                   pcols*(endchunk-begchunk+1) )
   allocate( send2d_chunk(pcols,nsend_atm,begchunk:endchunk), stat=istat )
   call alloc_err( istat, 'atmlnd_ini', 'send2d_chunk', &
                   pcols*nsend_atm*(endchunk-begchunk+1) )
   allocate( recv2d_chunk(pcols,nrecv_atm,begchunk:endchunk), stat=istat )
   call alloc_err( istat, 'atmlnd_ini', 'recv2d_chunk', &
                   pcols*nrecv_atm*(endchunk-begchunk+1) )

! Initialize land model

    call gather_chunk_to_field(1,1,1,plon,landfrac,oro_glob)

    call mpibcast (oro_glob, size(oro_glob), mpir8, 0, mpicom)


    pi = SHR_CONST_PI
    longxy(:,:) = 1.e36
    do lat = 1,plat
       do i = 1,nlon(lat)
          longxy(i,lat) = (i-1)*360.0/nlon(lat)
          latixy(i,lat) = (180./pi)*clat(lat)
          if (oro_glob(i,lat) > 0.) then
             landmask(i,lat) = 1
             lsmlandfrac(i,lat) = oro_glob(i,lat)
          else
             landmask(i,lat) = 0
             lsmlandfrac(i,lat) = 0.
          endif
       end do
    end do

    do lchnk=begchunk,endchunk
       ncols = get_ncols_p(lchnk)
       call get_lat_all_p(lchnk,pcols,lats)
       call get_lon_all_p(lchnk,pcols,lons)
       do i=1,ncols
          landmask_chunk(i,lchnk) = landmask(lons(i),lats(i))
       enddo
    enddo

! Initialize albedos, surface temperature, upward longwave radiation,
! and snow depth for land points (used for initial run only)

    call  initialize(eccen    , obliqr   , lambm0  , mvelpp  , caseid  , &
                     ctitle   , nsrest   , nstep   , iradsw  , inithist, &
                     nhtfrq(1), mfilt(1) , longxy  , latixy  , nlon    , &
                     landmask , lsmlandfrac , mss_irt)

! Allocate dynamic memory for atm to/from land exchange

    call allocate_atmlnd_ini()
	
! For initial run only - get 2d data back from land model (Note that 
! in  case, only masterproc contains valid recv2d data) and 
! split 2d data into appropriate arrays contained in module comsrf. 

    if (nstep == 0) then

       call lnd_to_atm_mapping_ini(recv2d)
       call scatter_field_to_chunk(1,nrecv_atm,1,plon,recv2d,recv2d_chunk)

       do lchnk=begchunk,endchunk
          ncols = get_ncols_p(lchnk)
          do i=1,ncols
             if (landmask_chunk(i,lchnk) == 1) then
                srfflx2d(lchnk)%ts(i)    = recv2d_chunk(i, 1,lchnk) 
                srfflx2d(lchnk)%asdir(i) = recv2d_chunk(i, 2,lchnk) 
                srfflx2d(lchnk)%aldir(i) = recv2d_chunk(i, 3,lchnk) 
                srfflx2d(lchnk)%asdif(i) = recv2d_chunk(i, 4,lchnk) 
                srfflx2d(lchnk)%aldif(i) = recv2d_chunk(i, 5,lchnk) 
                snowhland(i,lchnk)     = recv2d_chunk(i, 6,lchnk) 
                srfflx2d(lchnk)%lwup(i)  = recv2d_chunk(i,11,lchnk) 
             endif
          end do
       end do

    endif
    
    return
  end subroutine atmlnd_ini

!===============================================================================

  subroutine atmlnd_drv (nstep, iradsw, eccen, obliqr, lambm0, mvelpp,&
                         srf_state,srfflx2d)

!-----------------------------------------------------------------------
! Pack data to be sent to land model into a single array. 
! Send data to land model and call land model driver. 
! Receive data back from land model in a single array.
! Unpack this data into component arrays. 
! NOTE: component arrays are contained in module comsrf.
! When coupling to an atmospheric model: solar radiation depends on 
! surface albedos from the previous time step (based on current
! surface conditions and solar zenith angle for next time step).
! Longwave radiation depends on upward longwave flux from previous
! time step.
!-----------------------------------------------------------------------


    use mpishorthand

    use lnd_atmMod  !mapping from atm grid space <-> clm tile space
    use comsrf, only:surface_state
!---------------------------Arguments----------------------------------- 
    integer , intent(in) :: nstep    !Current time index
    integer , intent(in) :: iradsw   !Iteration frequency for shortwave radiation
    real(r8), intent(in) :: eccen    !Earth's orbital eccentricity
    real(r8), intent(in) :: obliqr   !Earth's obliquity in radians
    real(r8), intent(in) :: lambm0   !Mean longitude of perihelion at the vernal equinox (radians)
    real(r8), intent(in) :: mvelpp   !Earth's moving vernal equinox longitude of perihelion + pi (radians)
   type(srfflx_parm), intent(inout), dimension(begchunk:endchunk) :: srfflx2d
   type(surface_state), intent(inout), dimension(begchunk:endchunk) :: srf_state
!-----------------------------------------------------------------------

!---------------------------Local workspace-----------------------------
    integer :: i,lat,m,n,lchnk,ncols !indices
    logical doalb          !true if surface albedo calculation time step
!-----------------------------------------------------------------------

! -----------------------------------------------------------------
! Determine doalb
! [doalb] is a logical variable that is true when the next time
! step is a radiation time step. This allows for the fact that
! an atmospheric model may not do the radiative calculations 
! every time step. For example:
!      nstep dorad doalb
!        1     F     F
!        2     F     T
!        3     T     F
!        4     F     F
!        5     F     T
!        6     T     F
! The following expression for doalb is for example only (it is 
! specific to the NCAR CAM). This variable must be calculated
! appropriately for the host atmospheric model
! -----------------------------------------------------------------

    doalb = iradsw==1 .or. (mod(nstep,iradsw)==0 .and. nstep+1/=1)

! Condense the 2d atmospheric data needed by the land surface model into 
! one array. Note that precc and precl precipitation rates are in units 
! of m/sec. They are turned into fluxes by multiplying by 1000 kg/m^3.

!$OMP PARALLEL DO PRIVATE(lchnk,ncols,i)
    do lchnk=begchunk,endchunk
       ncols = get_ncols_p(lchnk)
       do i=1,ncols
          send2d_chunk(i, 1,lchnk)  =  srf_state(lchnk)%zbot(i)  ! Atmospheric state variable m
          send2d_chunk(i, 2,lchnk)  =  srf_state(lchnk)%ubot(i)  ! Atmospheric state variable m/s
          send2d_chunk(i, 3,lchnk)  =  srf_state(lchnk)%vbot(i)  ! Atmospheric state variable m/s
          send2d_chunk(i, 4,lchnk)  =  srf_state(lchnk)%thbot(i) ! Atmospheric state variable K
          send2d_chunk(i, 5,lchnk)  =  srf_state(lchnk)%qbot(i)  ! Atmospheric state variable kg/kg
          send2d_chunk(i, 6,lchnk)  =  srf_state(lchnk)%pbot(i)  ! Atmospheric state variable Pa
          send2d_chunk(i, 7,lchnk)  =  srf_state(lchnk)%tbot(i)  ! Atmospheric state variable K
          send2d_chunk(i, 8,lchnk)  =  srf_state(lchnk)%flwds(i) ! Atmospheric flux W/m^2
          send2d_chunk(i, 9,lchnk)  =  srf_state(lchnk)%precsc(i)*1000.                  !convert from m/sec to mm/sec
          send2d_chunk(i,10,lchnk)  =  srf_state(lchnk)%precsl(i)*1000.                  !convert from m/sec to mm/sec
          send2d_chunk(i,11,lchnk)  =  (srf_state(lchnk)%precc(i) - srf_state(lchnk)%precsc(i))*1000. !convert from m/sec to mm/sec
          send2d_chunk(i,12,lchnk)  =  (srf_state(lchnk)%precl(i) - srf_state(lchnk)%precsl(i))*1000. !convert from m/sec to mm/sec
          send2d_chunk(i,13,lchnk)  =  srf_state(lchnk)%soll(i)  ! Atmospheric flux W/m^2
          send2d_chunk(i,14,lchnk)  =  srf_state(lchnk)%sols(i)  ! Atmospheric flux W/m^2
          send2d_chunk(i,15,lchnk)  =  srf_state(lchnk)%solld(i) ! Atmospheric flux W/m^2
          send2d_chunk(i,16,lchnk)  =  srf_state(lchnk)%solsd(i) ! Atmospheric flux W/m^2
       end do
    end do

    call gather_chunk_to_field(1,nsend_atm,1,plon,send2d_chunk,send2d)

! Convert two dimensional atm input data to one dimensional land model data
 
    call atm_to_lnd_mapping(send2d)

! Call land model driver

!!    write(6,*) 'calling land model driver...'
    call driver (doalb, eccen, obliqr, lambm0, mvelpp)

! Convert one dimensional land model output data to two dimensional atm data 

    call lnd_to_atm_mapping(recv2d) 
    call scatter_field_to_chunk(1,nrecv_atm,1,plon,recv2d,recv2d_chunk)

! Split 2d recv array into component arrays (in module comsrf)

!$OMP PARALLEL DO PRIVATE(lchnk,ncols,i)
    do lchnk=begchunk,endchunk
       ncols = get_ncols_p(lchnk)
       do i=1,ncols
          if (landmask_chunk(i,lchnk) == 1) then
             srfflx2d(lchnk)%ts(i)     =  recv2d_chunk(i, 1,lchnk) 
             srfflx2d(lchnk)%asdir(i)  =  recv2d_chunk(i, 2,lchnk) 
             srfflx2d(lchnk)%aldir(i)  =  recv2d_chunk(i, 3,lchnk) 
             srfflx2d(lchnk)%asdif(i)  =  recv2d_chunk(i, 4,lchnk) 
             srfflx2d(lchnk)%aldif(i)  =  recv2d_chunk(i, 5,lchnk) 
             snowhland(i,lchnk)        =  recv2d_chunk(i, 6,lchnk) 
             srfflx2d(lchnk)%wsx(i)    =  recv2d_chunk(i, 7,lchnk) 
             srfflx2d(lchnk)%wsy(i)    =  recv2d_chunk(i, 8,lchnk) 
             srfflx2d(lchnk)%lhf(i)    =  recv2d_chunk(i, 9,lchnk) 
             srfflx2d(lchnk)%shf(i)    =  recv2d_chunk(i,10,lchnk) 
             srfflx2d(lchnk)%lwup(i)   =  recv2d_chunk(i,11,lchnk) 
             srfflx2d(lchnk)%cflx(i,1) =  recv2d_chunk(i,12,lchnk) 
             srfflx2d(lchnk)%tref(i)   =  recv2d_chunk(i,13,lchnk) 
          endif
       end do
    end do
    
! Reset all other consitutent surfaces fluxes to zero over land

    do lchnk=begchunk,endchunk
       ncols = get_ncols_p(lchnk)
       do i=1,ncols
          if (landmask_chunk(i,lchnk) == 1) then
             do m = 2,pcnst+pnats
                srfflx2d(lchnk)%cflx(i,m) = 0.
             end do
          endif
       end do
    end do
    
    return
  end subroutine atmlnd_drv

!===============================================================================



end module atm_lndMod

