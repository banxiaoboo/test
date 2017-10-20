# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"


# 1 "./misc.h" 1
# 3 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90" 2

# 1 "./params.h" 1
# 4 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90" 2
module moistconvection
!
! Moist convection. Primarily data used by both Zhang-McFarlane convection
! and Hack shallow convective schemes.
!
! $Id: moistconvection.F90,v 1.1.4.4 2002/06/15 13:49:16 erik Exp $
!
   use shr_kind_mod, only: r8 => shr_kind_r8
   implicit none

   private
   save
!
! Public interfaces
!
   public mfinti   !  Initialization of data for moist convection
   public cmfmca   !  Hack shallow convection
!
! Public Data for moist convection
!
   real(r8), public :: cp          ! specific heat of dry air
   real(r8), public :: grav        ! gravitational constant       
   real(r8), public :: rgrav       ! reciprocal of grav
   real(r8), public :: rgas        ! gas constant for dry air
   integer, public :: limcnv       ! top interface level limit for convection
   character(len=16),public :: convection_scheme   ! name of the convection scheme to be used in the physics package
!
! Private data used for Hack shallow convection
!
   real(r8) :: hlat        ! latent heat of vaporization
   real(r8) :: c0          ! rain water autoconversion coefficient
   real(r8) :: betamn      ! minimum overshoot parameter
   real(r8) :: rhlat       ! reciprocal of hlat
   real(r8) :: rcp         ! reciprocal of cp
   real(r8) :: cmftau      ! characteristic adjustment time scale
   real(r8) :: rhoh2o      ! density of liquid water (STP)
   real(r8) :: dzmin       ! minimum convective depth for precipitation
   real(r8) :: tiny        ! arbitrary small num used in transport estimates
   real(r8) :: eps         ! convergence criteria (machine dependent)
   real(r8) :: tpmax       ! maximum acceptable t perturbation (degrees C)
   real(r8) :: shpmax      ! maximum acceptable q perturbation (g/g)           

   integer :: iloc         ! longitude location for diagnostics
   integer :: jloc         ! latitude  location for diagnostics
   integer :: nsloc        ! nstep for which to produce diagnostics
!
   logical :: rlxclm       ! logical to relax column versus cloud triplet

contains

subroutine mfinti (rair    ,cpair   ,gravit  ,latvap  ,rhowtr  )
!----------------------------------------------------------------------- 
! 
! Purpose: 
! Initialize moist convective mass flux procedure common block, cmfmca
! 
! Method: 
! <Describe the algorithm(s) used in the routine.> 
! <Also include any applicable external references.> 
! 
! Author: J. Hack
! 
!-----------------------------------------------------------------------
   use pmgrid, only: plev, plevp, masterproc, plevstd,plond,plat


# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/comhyb.h" 1
!----------------------------------------------------------------------- 
! 
! Purpose: Hybrid level definitions: p = a*p0 + b*ps
!          interfaces   p(k) = hyai(k)*ps0 + hybi(k)*ps
!          midpoints    p(k) = hyam(k)*ps0 + hybm(k)*ps
! 
!-----------------------------------------------------------------------
!!!  vertical level definitions in LASG dynamical core: p = pes*sigma + pt
!!!        interfaces   ply(k) = ps*sig (k) + pmtop
!!!        midpoints    ply(k) = ps*sigl(k) + pmtop
!!!---------------------------------------------------------------------
!!!(wanhui 2003.04.30)
!!!(wanhui 2003.10.23)  (std.atm. variables removed)

      real(r8) hyai(plevp)       ! ps0 component of hybrid coordinate - interfaces
      real(r8) hybi(plevp)       ! ps component of hybrid coordinate - interfaces
      real(r8) hyam(plev)        ! ps0 component of hybrid coordinate - midpoints
      real(r8) hybm(plev)        ! ps component of hybrid coordinate - midpoints

!!    real(r8) hybd(plev)        ! difference  in b (hybi) across layers
      real(r8) hypi(plevp)       ! reference pressures at interfaces
      real(r8) hypm(plev)        ! reference pressures at midpoints
!!    real(r8) hypd(plev)        ! reference pressure layer thickness

      real(r8) ps0         ! base state sfc pressure for level definitions
!!    real(r8) psr         ! reference surface pressure for linearization
!!    real(r8) prsfac      ! log pressure extrapolation factor (time, space independent)

!!    integer nprlev       ! number of pure pressure levels at top

      real(r8) :: pmtop              !
      real(r8) :: sig (plevp)        !
      real(r8) :: sigl(plev)         !  fm2003 VPAR variables
      real(r8) :: dsig(plev)         !

!!(wanhui 2003.10.23)
!!------------------------------------------------------------
!!    real(r8) :: tbb (plevstd)         !
!!    real(r8) :: hbb (plevstd)         !
!!    real(r8) :: cbb (plevstd)         !
!!    real(r8) :: dcbb(plevstd)         !  fm2003 std. atm.
!!    real(r8) :: p00, t00              !
!!    real(r8) :: psb (plond,plat)      !
!!    real(r8) :: tsb (plond,plat)      !
!!------------------------------------------------------------
!!(2003.10.23)(these variables are in module stdatm now)


!!      common /comhyb/ hyai ,hyam  ,hybi ,hybm
!!      common /comhyb/ hybd ,hypi ,hypm  ,hypd
!!      common /comhyb/ ps0         ,psr         ,prsfac      ,nprlev

      common /comhyb/ hyai ,hybi ,hyam ,hybm
      common /comhyb/ hypi ,hypm
      common /comhyb/ ps0  ,pmtop
      common /comhyb/ sig  ,sigl , dsig
!!    common /comhyb/ tbb  ,hbb  , cbb  ,dcbb  ,p00 ,t00 ,psb ,tsb    !!(wh 2003.10.23)
 
# 70 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90" 2
!------------------------------Arguments--------------------------------
!
! Input arguments
!
   real(r8), intent(in) :: rair              ! gas constant for dry air
   real(r8), intent(in) :: cpair             ! specific heat of dry air
   real(r8), intent(in) :: gravit            ! acceleration due to gravity
   real(r8), intent(in) :: latvap            ! latent heat of vaporization
   real(r8), intent(in) :: rhowtr            ! density of liquid water (STP)

   integer k              ! vertical level index
!
!-----------------------------------------------------------------------
!
! Initialize physical constants for moist convective mass flux procedure
!
   cp     = cpair         ! specific heat of dry air
   hlat   = latvap        ! latent heat of vaporization
   grav   = gravit        ! gravitational constant
   rgas   = rair          ! gas constant for dry air
   rhoh2o = rhowtr        ! density of liquid water (STP)
!
! Initialize free parameters for moist convective mass flux procedure
!
   c0     = 5.0e-5        ! rain water autoconversion coeff (1/m)
   dzmin  = 0.0           ! minimum cloud depth to precipitate (m)
   betamn = 0.30          ! minimum overshoot parameter
   cmftau = 3600.*2       ! characteristic adjustment time scale
!
! Limit convection to regions below 40 mb
!
   if (hypi(1) >= 4.e3) then
      limcnv = 1
   else
      do k=1,plev
         if (hypi(k) < 4.e3 .and. hypi(k+1) >= 4.e3) then
            limcnv = k
            goto 10
         end if
      end do
      limcnv = plevp
   end if

10 continue

   if (masterproc) then
      write(6,*)'MFINTI: Convection will be capped at intfc ',limcnv, &
                ' which is ',hypi(limcnv),' pascals'
   end if

   tpmax  = 1.50          ! maximum acceptable t perturbation (deg C)
   shpmax = 1.50e-3       ! maximum acceptable q perturbation (g/g)
   rlxclm = .true.        ! logical variable to specify that relaxation
!                                time scale should applied to column as
!                                opposed to triplets individually
!
! Initialize miscellaneous (frequently used) constants
!
   rhlat  = 1.0/hlat      ! reciprocal latent heat of vaporization
   rcp    = 1.0/cp        ! reciprocal specific heat of dry air
   rgrav  = 1.0/grav      ! reciprocal gravitational constant
!
! Initialize diagnostic location information for moist convection scheme
!
   iloc   = 1             ! longitude point for diagnostic info
   jloc   = 1             ! latitude  point for diagnostic info
   nsloc  = 1             ! nstep value at which to begin diagnostics
!
! Initialize other miscellaneous parameters
!
   tiny   = 1.0e-36       ! arbitrary small number (scalar transport)
   eps    = 1.0e-13       ! convergence criteria (machine dependent)
!
   return
end subroutine mfinti

subroutine cmfmca(lchnk   ,ncol    , &
                  nstep   ,ztodt     ,pmid    ,pdel    , &
                  rpdel   ,zm      ,tpert   ,qpert   ,phis    , &
                  pblht   ,t       ,q       ,cmfdt   ,dq      , &
                  cmfmc   ,cmfdqr  ,cmfsl   ,cmflq   ,precc   , &



                  qc      ,cnt     ,cnb     ,icwmr)

!----------------------------------------------------------------------- 
! 
! Purpose: 
! Moist convective mass flux procedure:
! 
! Method: 
! If stratification is unstable to nonentraining parcel ascent,
! complete an adjustment making successive use of a simple cloud model
! consisting of three layers (sometimes referred to as a triplet)
!
! Code generalized to allow specification of parcel ("updraft")
! properties, as well as convective transport of an arbitrary
! number of passive constituents (see q array).  The code
! is written so the water vapor field is passed independently
! in the calling list from the block of other transported
! constituents, even though as currently designed, it is the
! first component in the constituents field.
! 
! Author: J. Hack
!
! BAB: changed code to report tendencies in cmfdt and dq, instead of
! updating profiles. Cmfdq contains water only, made it a local variable
! made dq (all constituents) the argument.
! 
!-----------------------------------------------------------------------

!#######################################################################
!#                                                                     #
!# Debugging blocks are marked this way for easy identification        #
!#                                                                     #
!#######################################################################
   use tracers,   only: pcnst, pnats
   use ppgrid,    only: pcols, pver, pverp
   use phys_grid, only: get_lat_all_p, get_lon_all_p
   use wv_saturation, only: aqsatd, vqsatd

   real(r8) ssfac               ! supersaturation bound (detrained air)
   parameter (ssfac = 1.001)

!------------------------------Arguments--------------------------------
!
! Input arguments
!
   integer, intent(in) :: lchnk                ! chunk identifier
   integer, intent(in) :: ncol                 ! number of atmospheric columns
   integer, intent(in) :: nstep                ! current time step index

   real(r8), intent(in) :: ztodt               ! 2 delta-t (seconds)
   real(r8), intent(in) :: pmid(pcols,pver)    ! pressure
   real(r8), intent(in) :: pdel(pcols,pver)    ! delta-p
   real(r8), intent(in) :: rpdel(pcols,pver)   ! 1./pdel
   real(r8), intent(in) :: zm(pcols,pver)      ! height abv sfc at midpoints
   real(r8), intent(in) :: tpert(pcols)        ! PBL perturbation theta
   real(r8), intent(in) :: qpert(pcols,pcnst+pnats)  ! PBL perturbation specific humidity
   real(r8), intent(in) :: phis(pcols)         ! surface geopotential
   real(r8), intent(in) :: pblht(pcols)        ! PBL height (provided by PBL routine)
   real(r8), intent(in) :: t(pcols,pver)       ! temperature (t bar)
   real(r8), intent(in) :: q(pcols,pver,pcnst+pnats) ! specific humidity (sh bar)
!
! Output arguments
!
   real(r8), intent(out) :: cmfdt(pcols,pver)   ! dt/dt due to moist convection
   real(r8), intent(out) :: cmfmc(pcols,pver )  ! moist convection cloud mass flux
   real(r8), intent(out) :: cmfdqr(pcols,pver)  ! dq/dt due to convective rainout
   real(r8), intent(out) :: cmfsl(pcols,pver )  ! convective lw static energy flux
   real(r8), intent(out) :: cmflq(pcols,pver )  ! convective total water flux
   real(r8), intent(out) :: precc(pcols)        ! convective precipitation rate
   real(r8), intent(out) :: qc(pcols,pver)      ! dq/dt due to rainout terms
   real(r8), intent(out) :: cnt(pcols)          ! top level of convective activity
   real(r8), intent(out) :: cnb(pcols)          ! bottom level of convective activity
   real(r8), intent(out) :: dq(pcols,pver,pcnst+pnats) ! constituent tendencies
   real(r8), intent(out) :: icwmr(pcols,pver)





!
!---------------------------Local workspace-----------------------------
!
   real(r8) cmfdq(pcols,pver)   ! dq/dt due to moist convection
   real(r8) gam(pcols,pver)     ! 1/cp (d(qsat)/dT)
   real(r8) sb(pcols,pver)      ! dry static energy (s bar)
   real(r8) hb(pcols,pver)      ! moist static energy (h bar)
   real(r8) shbs(pcols,pver)    ! sat. specific humidity (sh bar star)
   real(r8) hbs(pcols,pver)     ! sat. moist static energy (h bar star)
   real(r8) shbh(pcols,pverp)   ! specific humidity on interfaces
   real(r8) sbh(pcols,pverp)    ! s bar on interfaces
   real(r8) hbh(pcols,pverp)    ! h bar on interfaces
   real(r8) cmrh(pcols,pverp)   ! interface constituent mixing ratio
   real(r8) prec(pcols)         ! instantaneous total precipitation
   real(r8) dzcld(pcols)        ! depth of convective layer (m)
   real(r8) beta(pcols)         ! overshoot parameter (fraction)
   real(r8) betamx(pcols)       ! local maximum on overshoot
   real(r8) eta(pcols)          ! convective mass flux (kg/m^2 s)
   real(r8) etagdt(pcols)       ! eta*grav*dt
   real(r8) cldwtr(pcols)       ! cloud water (mass)
   real(r8) rnwtr(pcols)        ! rain water  (mass)
   real(r8) sc  (pcols)         ! dry static energy   ("in-cloud")
   real(r8) shc (pcols)         ! specific humidity   ("in-cloud")
   real(r8) hc  (pcols)         ! moist static energy ("in-cloud")
   real(r8) cmrc(pcols)         ! constituent mix rat ("in-cloud")
   real(r8) dq1(pcols)          ! shb  convective change (lower lvl)
   real(r8) dq2(pcols)          ! shb  convective change (mid level)
   real(r8) dq3(pcols)          ! shb  convective change (upper lvl)
   real(r8) ds1(pcols)          ! sb   convective change (lower lvl)
   real(r8) ds2(pcols)          ! sb   convective change (mid level)
   real(r8) ds3(pcols)          ! sb   convective change (upper lvl)
   real(r8) dcmr1(pcols)        ! q convective change (lower lvl)
   real(r8) dcmr2(pcols)        ! q convective change (mid level)
   real(r8) dcmr3(pcols)        ! q convective change (upper lvl)
   real(r8) estemp(pcols,pver)  ! saturation vapor pressure (scratch)
   real(r8) vtemp1(2*pcols)     ! intermediate scratch vector
   real(r8) vtemp2(2*pcols)     ! intermediate scratch vector
   real(r8) vtemp3(2*pcols)     ! intermediate scratch vector
   real(r8) vtemp4(2*pcols)     ! intermediate scratch vector
   integer indx1(pcols)     ! longitude indices for condition true
   logical etagt0           ! true if eta > 0.0
   real(r8) sh1                 ! dummy arg in qhalf statement func.
   real(r8) sh2                 ! dummy arg in qhalf statement func.
   real(r8) shbs1               ! dummy arg in qhalf statement func.
   real(r8) shbs2               ! dummy arg in qhalf statement func.
   real(r8) cats                ! modified characteristic adj. time
   real(r8) rtdt                ! 1./ztodt
   real(r8) qprime              ! modified specific humidity pert.
   real(r8) tprime              ! modified thermal perturbation
   real(r8) pblhgt              ! bounded pbl height (max[pblh,1m])
   real(r8) fac1                ! intermediate scratch variable
   real(r8) shprme              ! intermediate specific humidity pert.
   real(r8) qsattp              ! sat mix rat for thermally pert PBL parcels
   real(r8) dz                  ! local layer depth
   real(r8) temp1               ! intermediate scratch variable
   real(r8) b1                  ! bouyancy measure in detrainment lvl
   real(r8) b2                  ! bouyancy measure in condensation lvl
   real(r8) temp2               ! intermediate scratch variable
   real(r8) temp3               ! intermediate scratch variable
   real(r8) g                   ! bounded vertical gradient of hb
   real(r8) tmass               ! total mass available for convective exch
   real(r8) denom               ! intermediate scratch variable
   real(r8) qtest1              ! used in negative q test (middle lvl)
   real(r8) qtest2              ! used in negative q test (lower lvl)
   real(r8) fslkp               ! flux lw static energy (bot interface)
   real(r8) fslkm               ! flux lw static energy (top interface)
   real(r8) fqlkp               ! flux total water (bottom interface)
   real(r8) fqlkm               ! flux total water (top interface)
   real(r8) botflx              ! bottom constituent mixing ratio flux
   real(r8) topflx              ! top constituent mixing ratio flux
   real(r8) efac1               ! ratio q to convectively induced chg (btm lvl)
   real(r8) efac2               ! ratio q to convectively induced chg (mid lvl)
   real(r8) efac3               ! ratio q to convectively induced chg (top lvl)
   real(r8) tb(pcols,pver)      ! working storage for temp (t bar)
   real(r8) shb(pcols,pver)     ! working storage for spec hum (sh bar)
   real(r8) adjfac              ! adjustment factor (relaxation related)
   real(r8) rktp
   real(r8) rk
# 323 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
   integer i,k              ! longitude, level indices
   integer ii               ! index on "gathered" vectors
   integer len1             ! vector length of "gathered" vectors
   integer m                ! constituent index
   integer ktp              ! tmp indx used to track top of convective layer
# 336 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!
!---------------------------Statement functions-------------------------
!
   real(r8) qhalf
   qhalf(sh1,sh2,shbs1,shbs2) = min(max(sh1,sh2),(shbs2*sh1 + shbs1*sh2)/(shbs1+shbs2))
!
!-----------------------------------------------------------------------

!** BAB initialize output tendencies here
!       copy q to dq; use dq below for passive tracer transport
   cmfdt(:ncol,:)  = 0.
   cmfdq(:ncol,:)  = 0.
   dq(:ncol,:,2:)  = q(:ncol,:,2:)
   cmfmc(:ncol,:)  = 0.
   cmfdqr(:ncol,:) = 0.
   cmfsl(:ncol,:)  = 0.
   cmflq(:ncol,:)  = 0.
   qc(:ncol,:)     = 0.
!





!
! Ensure that characteristic adjustment time scale (cmftau) assumed
! in estimate of eta isn't smaller than model time scale (ztodt)
! The time over which the convection is assumed to act (the adjustment
! time scale) can be applied with each application of the three-level
! cloud model, or applied to the column tendencies after a "hard"
! adjustment (i.e., on a 2-delta t time scale) is evaluated
!
   if (rlxclm) then
      cats   = ztodt             ! relaxation applied to column
      adjfac = ztodt/(max(ztodt,cmftau))
   else
      cats   = max(ztodt,cmftau) ! relaxation applied to triplet
      adjfac = 1.0
   endif
   rtdt = 1.0/ztodt
!
! Move temperature and moisture into working storage
!
   do k=limcnv,pver
      do i=1,ncol
         tb (i,k) = t(i,k)
         shb(i,k) = q(i,k,1)
      end do
   end do
   do k=1,pver
      do i=1,ncol
         icwmr(i,k) = 0.
      end do
   end do
!
! Compute sb,hb,shbs,hbs
!
   call aqsatd(tb      ,pmid    ,estemp ,shbs    ,gam     , &
               pcols   ,ncol    ,pver   ,limcnv  ,pver    )
!
   do k=limcnv,pver
      do i=1,ncol
         sb (i,k) = cp*tb(i,k) + zm(i,k)*grav + phis(i)
         hb (i,k) = sb(i,k) + hlat*shb(i,k)
         hbs(i,k) = sb(i,k) + hlat*shbs(i,k)
      end do
   end do
!
! Compute sbh, shbh
!
   do k=limcnv+1,pver
      do i=1,ncol
         sbh (i,k) = 0.5*(sb(i,k-1) + sb(i,k))
         shbh(i,k) = qhalf(shb(i,k-1),shb(i,k),shbs(i,k-1),shbs(i,k))
         hbh (i,k) = sbh(i,k) + hlat*shbh(i,k)
      end do
   end do
!
! Specify properties at top of model (not used, but filling anyway)
!
   do i=1,ncol
      sbh (i,limcnv) = sb(i,limcnv)
      shbh(i,limcnv) = shb(i,limcnv)
      hbh (i,limcnv) = hb(i,limcnv)
   end do
!
! Zero vertically independent control, tendency & diagnostic arrays
!
   do i=1,ncol
      prec(i)  = 0.0
      dzcld(i) = 0.0
      cnb(i)   = 0.0
      cnt(i)   = float(pver+1)
   end do
# 461 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!#                                                                     #
!#                                                                     #
!#######################################################################
!
! Begin moist convective mass flux adjustment procedure.
! Formalism ensures that negative cloud liquid water can never occur
!
   do 70 k=pver-1,limcnv+1,-1
      do 10 i=1,ncol
         etagdt(i) = 0.0
         eta   (i) = 0.0
         beta  (i) = 0.0
         ds1   (i) = 0.0
         ds2   (i) = 0.0
         ds3   (i) = 0.0
         dq1   (i) = 0.0
         dq2   (i) = 0.0
         dq3   (i) = 0.0
!
! Specification of "cloud base" conditions
!
         qprime    = 0.0
         tprime    = 0.0
!
! Assign tprime within the PBL to be proportional to the quantity
! tpert (which will be bounded by tpmax), passed to this routine by
! the PBL routine.  Don't allow perturbation to produce a dry
! adiabatically unstable parcel.  Assign qprime within the PBL to be
! an appropriately modified value of the quantity qpert (which will be
! bounded by shpmax) passed to this routine by the PBL routine.  The
! quantity qprime should be less than the local saturation value
! (qsattp=qsat[t+tprime,p]).  In both cases, tpert and qpert are
! linearly reduced toward zero as the PBL top is approached.
!
         pblhgt = max(pblht(i),1.0_r8)
         if ( (zm(i,k+1) <= pblhgt) .and. dzcld(i) == 0.0 ) then
            fac1   = max(0.0_r8,1.0-zm(i,k+1)/pblhgt)
            tprime = min(tpert(i),tpmax)*fac1
            qsattp = shbs(i,k+1) + cp*rhlat*gam(i,k+1)*tprime
            shprme = min(min(qpert(i,1),shpmax)*fac1,max(qsattp-shb(i,k+1),0.0_r8))
            qprime = max(qprime,shprme)
         else
            tprime = 0.0
            qprime = 0.0
         end if
!
! Specify "updraft" (in-cloud) thermodynamic properties
!
         sc (i)    = sb (i,k+1) + cp*tprime
         shc(i)    = shb(i,k+1) + qprime
         hc (i)    = sc (i    ) + hlat*shc(i)
         vtemp4(i) = hc(i) - hbs(i,k)
         dz        = pdel(i,k)*rgas*tb(i,k)*rgrav/pmid(i,k)
         if (vtemp4(i) > 0.0) then
            dzcld(i) = dzcld(i) + dz
         else
            dzcld(i) = 0.0
         end if
10       continue
# 533 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!
! Check on moist convective instability
! Build index vector of points where instability exists
!
         len1 = 0
         do i=1,ncol
            if (vtemp4(i) > 0.0) then
               len1 = len1 + 1
               indx1(len1) = i
            end if
         end do
         if (len1 <= 0) go to 70
!
! Current level just below top level => no overshoot
!
         if (k <= limcnv+1) then
            do ii=1,len1
               i = indx1(ii)
               temp1     = vtemp4(i)/(1.0 + gam(i,k))
               cldwtr(i) = max(0.0_r8,(sb(i,k) - sc(i) + temp1))
               beta(i)   = 0.0
               vtemp3(i) = (1.0 + gam(i,k))*(sc(i) - sbh(i,k))
            end do
         else
!
! First guess at overshoot parameter using crude buoyancy closure
! 10% overshoot assumed as a minimum and 1-c0*dz maximum to start
! If pre-existing supersaturation in detrainment layer, beta=0
! cldwtr is temporarily equal to hlat*l (l=> liquid water)
!
!CDIR$ IVDEP
            do ii=1,len1
               i = indx1(ii)
               temp1     = vtemp4(i)/(1.0 + gam(i,k))
               cldwtr(i) = max(0.0_r8,(sb(i,k)-sc(i)+temp1))
               betamx(i) = 1.0 - c0*max(0.0_r8,(dzcld(i)-dzmin))
               b1        = (hc(i) - hbs(i,k-1))*pdel(i,k-1)
               b2        = (hc(i) - hbs(i,k  ))*pdel(i,k  )
               beta(i)   = max(betamn,min(betamx(i), 1.0 + b1/b2))
               if (hbs(i,k-1) <= hb(i,k-1)) beta(i) = 0.0
!
! Bound maximum beta to ensure physically realistic solutions
!
! First check constrains beta so that eta remains positive
! (assuming that eta is already positive for beta equal zero)
!
               vtemp1(i) = -(hbh(i,k+1) - hc(i))*pdel(i,k)*rpdel(i,k+1)+ &
                           (1.0 + gam(i,k))*(sc(i) - sbh(i,k+1) + cldwtr(i))
               vtemp2(i) = (1.0 + gam(i,k))*(sc(i) - sbh(i,k))
               vtemp3(i) = vtemp2(i)
               if ((beta(i)*vtemp2(i) - vtemp1(i)) > 0.) then
                  betamx(i) = 0.99*(vtemp1(i)/vtemp2(i))
                  beta(i)   = max(0.0_r8,min(betamx(i),beta(i)))
               end if
            end do
!
! Second check involves supersaturation of "detrainment layer"
! small amount of supersaturation acceptable (by ssfac factor)
!
!CDIR$ IVDEP
            do ii=1,len1
               i = indx1(ii)
               if (hb(i,k-1) < hbs(i,k-1)) then
                  vtemp1(i) = vtemp1(i)*rpdel(i,k)
                  temp2 = gam(i,k-1)*(sbh(i,k) - sc(i) + cldwtr(i)) -  &
                          hbh(i,k) + hc(i) - sc(i) + sbh(i,k)
                  temp3 = vtemp3(i)*rpdel(i,k)
                  vtemp2(i) = (ztodt/cats)*(hc(i) - hbs(i,k))*temp2/ &
                              (pdel(i,k-1)*(hbs(i,k-1) - hb(i,k-1))) + temp3
                  if ((beta(i)*vtemp2(i) - vtemp1(i)) > 0.) then
                     betamx(i) = ssfac*(vtemp1(i)/vtemp2(i))
                     beta(i)   = max(0.0_r8,min(betamx(i),beta(i)))
                  end if
               else
                  beta(i) = 0.0
               end if
            end do
!
! Third check to avoid introducing 2 delta x thermodynamic
! noise in the vertical ... constrain adjusted h (or theta e)
! so that the adjustment doesn't contribute to "kinks" in h
!
!CDIR$ IVDEP
            do ii=1,len1
               i = indx1(ii)
               g = min(0.0_r8,hb(i,k) - hb(i,k-1))
               temp1 = (hb(i,k) - hb(i,k-1) - g)*(cats/ztodt)/(hc(i) - hbs(i,k))
               vtemp1(i) = temp1*vtemp1(i) + (hc(i) - hbh(i,k+1))*rpdel(i,k)
               vtemp2(i) = temp1*vtemp3(i)*rpdel(i,k) + (hc(i) - hbh(i,k) - cldwtr(i))* &
                           (rpdel(i,k) + rpdel(i,k+1))
               if ((beta(i)*vtemp2(i) - vtemp1(i)) > 0.) then
                  if (vtemp2(i) /= 0.0) then
                     betamx(i) = vtemp1(i)/vtemp2(i)
                  else
                     betamx(i) = 0.0
                  end if
                  beta(i) = max(0.0_r8,min(betamx(i),beta(i)))
               end if
            end do
         end if
!
! Calculate mass flux required for stabilization.
!
! Ensure that the convective mass flux, eta, is positive by
! setting negative values of eta to zero..
! Ensure that estimated mass flux cannot move more than the
! minimum of total mass contained in either layer k or layer k+1.
! Also test for other pathological cases that result in non-
! physical states and adjust eta accordingly.
!
!CDIR$ IVDEP
         do ii=1,len1
            i = indx1(ii)
            beta(i) = max(0.0_r8,beta(i))
            temp1 = hc(i) - hbs(i,k)
            temp2 = ((1.0 + gam(i,k))*(sc(i) - sbh(i,k+1) + cldwtr(i)) - &
                      beta(i)*vtemp3(i))*rpdel(i,k) - (hbh(i,k+1) - hc(i))*rpdel(i,k+1)
            eta(i) = temp1/(temp2*grav*cats)
            tmass = min(pdel(i,k),pdel(i,k+1))*rgrav
            if (eta(i) > tmass*rtdt .or. eta(i) <= 0.0) eta(i) = 0.0
!
! Check on negative q in top layer (bound beta)
!
            if (shc(i)-shbh(i,k) < 0.0 .and. beta(i)*eta(i) /= 0.0) then
               denom = eta(i)*grav*ztodt*(shc(i) - shbh(i,k))*rpdel(i,k-1)
               beta(i) = max(0.0_r8,min(-0.999*shb(i,k-1)/denom,beta(i)))
            end if
!
! Check on negative q in middle layer (zero eta)
!
            qtest1 = shb(i,k) + eta(i)*grav*ztodt*((shc(i) - shbh(i,k+1)) - &
                     (1.0 - beta(i))*cldwtr(i)*rhlat - beta(i)*(shc(i) - shbh(i,k)))* &
	             rpdel(i,k)
            if (qtest1 <= 0.0) eta(i) = 0.0
!
! Check on negative q in lower layer (bound eta)
!
            fac1 = -(shbh(i,k+1) - shc(i))*rpdel(i,k+1)
            qtest2 = shb(i,k+1) - eta(i)*grav*ztodt*fac1
            if (qtest2 < 0.0) then
               eta(i) = 0.99*shb(i,k+1)/(grav*ztodt*fac1)
            end if
            etagdt(i) = eta(i)*grav*ztodt
         end do
!
# 689 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!
! Calculate cloud water, rain water, and thermodynamic changes
!
!CDIR$ IVDEP
         do 30 ii=1,len1
            i = indx1(ii)
            icwmr(i,k) = cldwtr(i)*rhlat
            cldwtr(i) = etagdt(i)*cldwtr(i)*rhlat*rgrav
            rnwtr(i) = (1.0 - beta(i))*cldwtr(i)
            ds1(i) = etagdt(i)*(sbh(i,k+1) - sc(i))*rpdel(i,k+1)
            dq1(i) = etagdt(i)*(shbh(i,k+1) - shc(i))*rpdel(i,k+1)
            ds2(i) = (etagdt(i)*(sc(i) - sbh(i,k+1)) +  &
                     hlat*grav*cldwtr(i) - beta(i)*etagdt(i)*(sc(i) - sbh(i,k)))*rpdel(i,k)
            dq2(i) = (etagdt(i)*(shc(i) - shbh(i,k+1)) - grav*rnwtr(i) - beta(i)* &
                     etagdt(i)*(shc(i) - shbh(i,k)))*rpdel(i,k)
            ds3(i) = beta(i)*(etagdt(i)*(sc(i) - sbh(i,k)) - hlat*grav*cldwtr(i))* &
                     rpdel(i,k-1)
            dq3(i) = beta(i)*etagdt(i)*(shc(i) - shbh(i,k))*rpdel(i,k-1)
!
! Isolate convective fluxes for later diagnostics
!
            fslkp = eta(i)*(sc(i) - sbh(i,k+1))
            fslkm = beta(i)*(eta(i)*(sc(i) - sbh(i,k)) - hlat*cldwtr(i)*rtdt)
            fqlkp = eta(i)*(shc(i) - shbh(i,k+1))
            fqlkm = beta(i)*eta(i)*(shc(i) - shbh(i,k))
!
! Update thermodynamic profile (update sb, hb, & hbs later)
!
            tb (i,k+1) = tb(i,k+1)  + ds1(i)*rcp
            tb (i,k  ) = tb(i,k  )  + ds2(i)*rcp
            tb (i,k-1) = tb(i,k-1)  + ds3(i)*rcp
            shb(i,k+1) = shb(i,k+1) + dq1(i)
            shb(i,k  ) = shb(i,k  ) + dq2(i)
            shb(i,k-1) = shb(i,k-1) + dq3(i)
!
! ** Update diagnostic information for final budget **
! Tracking precipitation, temperature & specific humidity tendencies,
! rainout term, convective mass flux, convective liquid
! water static energy flux, and convective total water flux
! The variable afac makes the necessary adjustment to the
! diagnostic fluxes to account for adjustment time scale based on
! how relaxation time scale is to be applied (column vs. triplet)
!







!
! The following variables have units of "units"/second
!
            cmfdt (i,k+1) = cmfdt (i,k+1) + ds1(i)*rtdt*adjfac
            cmfdt (i,k  ) = cmfdt (i,k  ) + ds2(i)*rtdt*adjfac
            cmfdt (i,k-1) = cmfdt (i,k-1) + ds3(i)*rtdt*adjfac
            cmfdq (i,k+1) = cmfdq (i,k+1) + dq1(i)*rtdt*adjfac
            cmfdq (i,k  ) = cmfdq (i,k  ) + dq2(i)*rtdt*adjfac
            cmfdq (i,k-1) = cmfdq (i,k-1) + dq3(i)*rtdt*adjfac
            qc    (i,k  ) = (grav*rnwtr(i)*rpdel(i,k))*rtdt*adjfac
            cmfdqr(i,k  ) = cmfdqr(i,k  ) + qc(i,k)
            cmfmc (i,k+1) = cmfmc (i,k+1) + eta(i)*adjfac
            cmfmc (i,k  ) = cmfmc (i,k  ) + beta(i)*eta(i)*adjfac
!
! The following variables have units of w/m**2
!
            cmfsl (i,k+1) = cmfsl (i,k+1) + fslkp*adjfac
            cmfsl (i,k  ) = cmfsl (i,k  ) + fslkm*adjfac
            cmflq (i,k+1) = cmflq (i,k+1) + hlat*fqlkp*adjfac
            cmflq (i,k  ) = cmflq (i,k  ) + hlat*fqlkm*adjfac
30          continue
!
! Next, convectively modify passive constituents
! For now, when applying relaxation time scale to thermal fields after
! entire column has undergone convective overturning, constituents will
! be mixed using a "relaxed" value of the mass flux determined above
! Although this will be inconsistant with the treatment of the thermal
! fields, it's computationally much cheaper, no more-or-less justifiable,
! and consistent with how the history tape mass fluxes would be used in
! an off-line mode (i.e., using an off-line transport model)
!
            do 50 m=2,pcnst+pnats    ! note: indexing assumes water is first field
!CDIR$ IVDEP
               do 40 ii=1,len1
                  i = indx1(ii)
!
! If any of the reported values of the constituent is negative in
! the three adjacent levels, nothing will be done to the profile
!
                  if ((dq(i,k+1,m) < 0.0) .or. (dq(i,k,m) < 0.0) .or. (dq(i,k-1,m) < 0.0)) go to 40
!
! Specify constituent interface values (linear interpolation)
!
                  cmrh(i,k  ) = 0.5*(dq(i,k-1,m) + dq(i,k  ,m))
                  cmrh(i,k+1) = 0.5*(dq(i,k  ,m) + dq(i,k+1,m))
!
! Specify perturbation properties of constituents in PBL
!
                  pblhgt = max(pblht(i),1.0_r8)
                  if ( (zm(i,k+1) <= pblhgt) .and. dzcld(i) == 0.0 ) then
                     fac1 = max(0.0_r8,1.0-zm(i,k+1)/pblhgt)
                     cmrc(i) = dq(i,k+1,m) + qpert(i,m)*fac1
                  else
                     cmrc(i) = dq(i,k+1,m)
                  end if
!
! Determine fluxes, flux divergence => changes due to convection
! Logic must be included to avoid producing negative values. A bit
! messy since there are no a priori assumptions about profiles.
! Tendency is modified (reduced) when pending disaster detected.
!
                  botflx   = etagdt(i)*(cmrc(i) - cmrh(i,k+1))*adjfac
                  topflx   = beta(i)*etagdt(i)*(cmrc(i)-cmrh(i,k))*adjfac
                  dcmr1(i) = -botflx*rpdel(i,k+1)
                  efac1    = 1.0
                  efac2    = 1.0
                  efac3    = 1.0
!
                  if (dq(i,k+1,m)+dcmr1(i) < 0.0) then
                     efac1 = max(tiny,abs(dq(i,k+1,m)/dcmr1(i)) - eps)
                  end if
!
                  if (efac1 == tiny .or. efac1 > 1.0) efac1 = 0.0
                  dcmr1(i) = -efac1*botflx*rpdel(i,k+1)
                  dcmr2(i) = (efac1*botflx - topflx)*rpdel(i,k)
!
                  if (dq(i,k,m)+dcmr2(i) < 0.0) then
                     efac2 = max(tiny,abs(dq(i,k  ,m)/dcmr2(i)) - eps)
                  end if
!
                  if (efac2 == tiny .or. efac2 > 1.0) efac2 = 0.0
                  dcmr2(i) = (efac1*botflx - efac2*topflx)*rpdel(i,k)
                  dcmr3(i) = efac2*topflx*rpdel(i,k-1)
!
                  if (dq(i,k-1,m)+dcmr3(i) < 0.0) then
                     efac3 = max(tiny,abs(dq(i,k-1,m)/dcmr3(i)) - eps)
                  end if
!
                  if (efac3 == tiny .or. efac3 > 1.0) efac3 = 0.0
                  efac3    = min(efac2,efac3)
                  dcmr2(i) = (efac1*botflx - efac3*topflx)*rpdel(i,k)
                  dcmr3(i) = efac3*topflx*rpdel(i,k-1)
!
                  dq(i,k+1,m) = dq(i,k+1,m) + dcmr1(i)
                  dq(i,k  ,m) = dq(i,k  ,m) + dcmr2(i)
                  dq(i,k-1,m) = dq(i,k-1,m) + dcmr3(i)
40                continue
50                continue                ! end of m=2,pcnst+pnats loop
!
! Constituent modifications complete
!
                  if (k == limcnv+1) go to 60
!
! Complete update of thermodynamic structure at integer levels
! gather/scatter points that need new values of shbs and gamma
!
                  do ii=1,len1
                     i = indx1(ii)
                     vtemp1(ii     ) = tb(i,k)
                     vtemp1(ii+len1) = tb(i,k-1)
                     vtemp2(ii     ) = pmid(i,k)
                     vtemp2(ii+len1) = pmid(i,k-1)
                  end do
                  call vqsatd (vtemp1  ,vtemp2  ,estemp  ,vtemp3  , vtemp4  , &
                               2*len1   )    ! using estemp as extra long vector
!CDIR$ IVDEP
                  do ii=1,len1
                     i = indx1(ii)
                     shbs(i,k  ) = vtemp3(ii     )
                     shbs(i,k-1) = vtemp3(ii+len1)
                     gam(i,k  ) = vtemp4(ii     )
                     gam(i,k-1) = vtemp4(ii+len1)
                     sb (i,k  ) = sb(i,k  ) + ds2(i)
                     sb (i,k-1) = sb(i,k-1) + ds3(i)
                     hb (i,k  ) = sb(i,k  ) + hlat*shb(i,k  )
                     hb (i,k-1) = sb(i,k-1) + hlat*shb(i,k-1)
                     hbs(i,k  ) = sb(i,k  ) + hlat*shbs(i,k  )
                     hbs(i,k-1) = sb(i,k-1) + hlat*shbs(i,k-1)
                  end do
!
! Update thermodynamic information at half (i.e., interface) levels
!
!CDIR$ IVDEP
                  do ii=1,len1
                     i = indx1(ii)
                     sbh (i,k) = 0.5*(sb(i,k) + sb(i,k-1))
                     shbh(i,k) = qhalf(shb(i,k-1),shb(i,k),shbs(i,k-1),shbs(i,k))
                     hbh (i,k) = sbh(i,k) + hlat*shbh(i,k)
                     sbh (i,k-1) = 0.5*(sb(i,k-1) + sb(i,k-2))
                     shbh(i,k-1) = qhalf(shb(i,k-2),shb(i,k-1),shbs(i,k-2),shbs(i,k-1))
                     hbh (i,k-1) = sbh(i,k-1) + hlat*shbh(i,k-1)
                  end do
!
# 928 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!
! Ensure that dzcld is reset if convective mass flux zero
! specify the current vertical extent of the convective activity
! top of convective layer determined by size of overshoot param.
!
60                do i=1,ncol
                     etagt0 = eta(i).gt.0.0
                     if ( .not. etagt0) dzcld(i) = 0.0
                     if (etagt0 .and. beta(i) > betamn) then
                        ktp = k-1
                     else
                        ktp = k
                     end if
                     if (etagt0) then
                        rk=k
                        rktp=ktp
                        cnt(i) = min(cnt(i),rktp)
                        cnb(i) = max(cnb(i),rk)
                     end if
                  end do
70                continue                  ! end of k loop
!
! ** apply final thermodynamic tendencies **
!
!**BAB don't update input profiles
!!$                  do k=limcnv,pver
!!$                     do i=1,ncol
!!$                        t (i,k) = t (i,k) + cmfdt(i,k)*ztodt
!!$                        q(i,k,1) = q(i,k,1) + cmfdq(i,k)*ztodt
!!$                     end do
!!$                  end do
! Set output q tendencies 
      dq(:ncol,:,1 ) = cmfdq(:ncol,:)
      dq(:ncol,:,2:) = (dq(:ncol,:,2:) - q(:ncol,:,2:))/ztodt
!
! Kludge to prevent cnb-cnt from being zero (in the event
! someone decides that they want to divide by this quantity)
!
                  do i=1,ncol
                     if (cnb(i) /= 0.0 .and. cnb(i) == cnt(i)) then
                        cnt(i) = cnt(i) - 1.0
                     end if
                  end do
!
                  do i=1,ncol
                     precc(i) = prec(i)*rtdt
                  end do
!
# 1013 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
                  return                 ! we're all done ... return to calling procedure
# 1041 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/physics/cam1/moistconvection.F90"
!
end subroutine cmfmca
end module moistconvection
