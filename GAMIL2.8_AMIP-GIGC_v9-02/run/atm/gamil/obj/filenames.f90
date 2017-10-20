# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/filenames.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/filenames.F90"
!-----------------------------------------------------------------------
!
! !MODULE: filenames
!
! DESCRIPTION
!
! Module and methods to handle filenames needed for the model. This
! includes input filenames, and most output filenames that the model
! uses. All filenames that the model uses will use methods or data
! constructed by this module. In some cases (such as the history module)
! other modules or routines will store the actual filenames used, but
! this module is used to determine the names.
!
!-----------------------------------------------------------------------

module filenames

    use time_manager, only: get_curr_date, get_prev_date

    implicit none

    public init_filepaths                           ! Initialize filepaths
    public get_archivedir                           ! Get the specific archive directory name
    public interpret_filename_spec                  ! Interpret a filename specifier
    !
    ! !PUBLIC DATA MEMBERS:
    !
    !   Note: Only make data needed for namelist public, everything else should be private.
    !
    ! Input datasets
    !
    character(len=256), public :: ncdata = 'ncdata' ! full pathname for initial dataset
    character(len=256), public :: bndtvs = 'bndtvs' ! full pathname for time-variant sst dataset
    character(len=256), public :: bndtvo = 'bndtvo' ! full pathname for time-variant ozone dataset
    character(len=256), public :: absems_data = 'absems_data' ! full pathname for time-invariant absorption dataset
    character(len=256), public :: bndtvg = 'bndtvg' ! full pathname for time-variant greenhouse gas loss rate
    character(len=256), public :: isccpdata = 'isccpdata' ! full pathname for ISCCP input data !!(2005.01.28)

    !character(shr_kind_cl), public :: bnd_topo = 'bnd_topo' ! full pathname for topography dataset
    character(len=256), public :: bndtvaer = 'bndtvaer' ! full pathname for time-variant aerosol mass climatology dataset
    !character(len=256), public :: bndtvcarbonscale = 'bndtvcarbonscale' ! full pathname for time-variant population dataset
    !character(len=256), public :: bndtvvolc = 'bndtvvolc' ! full pathname for time-variant stratospheric volcanic aerosol masses
    !character(len=256), public :: aeroptics = 'aeroptics' ! full pathname for aerosol optical dataset

    !character(shr_kind_cl), public :: caer_emis = 'caer_emis' ! full pathname for time-variant carbon emission dataset
    !character(shr_kind_cl), public :: bndtvdms = 'bndtvdms' ! full pathname for time-variant DMS emission dataset
    !character(shr_kind_cl), public :: soil_erod = 'soil_erod' ! full pathname for time-variant soil erodibility dataset
    !character(shr_kind_cl), public :: bndtvoxid = 'bndtvoxid' ! full pathname for time-variant oxidant dataset
    !character(shr_kind_cl), public :: bndtvsox = 'bndtvsox' ! full pathname for time-variant SOx emission dataset
    !character(shr_kind_cl), public :: absems_data = 'absems_data' ! full pathname for time-invariant absorption dataset
    !character(shr_kind_cl), public :: isccpdata = 'isccpdata' ! full pathname for ISCCP input data
    !character(shr_kind_cl), public :: bndtvsf6 = 'bndtvsf6' ! full pathname for time-variant sf6 tracer emission rate
    !
    !
    ! Filenames used for restart or branch
    !
    character(len=256), public :: nrevsn = ' '       ! Dataset to branch from, in namelist
    character(len=256), public :: rest_pfile = ' '   ! File name for restart dataset
    !
    ! Variables associated with archival (MSS) pathnames
    !
    character(len=257), public :: caseid = ' '       ! Case identifier (max 32 chars)
    character(len= 8), public :: mss_wpass = ' '    ! MSS write password
    integer, public :: mss_irt = 365               ! Mass Store retention period for output files
    !
    ! Private data used for filenames
    !
    private

    character(len=256), private :: archive_dir = ' '        ! Root archival directory
                                                            ! (ie MSS directory)
    integer, parameter :: nlen = 256                        ! String length

contains

    subroutine init_filepaths(archivedirname)

        use shr_kind_mod, only: r8 => shr_kind_r8
        use string_utils, only: to_upper

        character(len=*), intent(in), optional :: archivedirname ! Archive directory name

        ! For nrefrq

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
# 85 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/filenames.F90" 2

        character(len=80) logname         ! user name
        character(len=80) upcaselogname   ! user name in upper-case
        character(len=80) :: home_dir = ' '  ! Pathname for regeneration dataset nsrest=2
        integer ind                       ! Index into directory name

        !
        ! Get the users home directory to write restart pointer file
        !
        call getenv('HOME', home_dir)
        if (home_dir == ' ') then
            write(6, "('Error: filenames::init_filepaths: Can''t find HOME environment variable.')")
            call endrun
        end if

        if (nrefrq == 1 .and. len_trim(rest_pfile) == 0) then
            rest_pfile = trim(home_dir)//'/gamil.'//trim(caseid)//'.rpointer'
        end if
        !
        ! Set archive_dir if not initialized, and make sure has trailing "/"
        !
        if (present(archivedirname)) then
            archive_dir = archivedirname
        end if

        if (len_trim(archive_dir) == 0) then
            logname = ' '
            !call getenv('LOGNAME', logname) ! WAN Hui 2003.10.22
            call getenv('HOME'   , logname)
            upcaselogname = to_upper(logname)
            !archive_dir = '/'//trim(upcaselogname)//'/csm/'//trim(caseid)//'/atm/'
            archive_dir = trim(upcaselogname)//'/csm/'//trim(caseid)//'/atm/'
        end if
        ind = len_trim(archive_dir)
        if (archive_dir(ind:ind) /= '/') then
            archive_dir = trim(archive_dir) // '/'
        end if
        if (archive_dir(1:1) /= '/') then
            write(6,*)'INIT_FILEPATHS: archive_dir must be an absolute directory name = ', &
                archive_dir
            call endrun
        end if

    end subroutine init_filepaths

!-----------------------------------------------------------------------
! BOP
!
! !ROUTINE: get_archivedir
!
! !DESCRIPTION: Return the archive directory for the specific type
! of file given.
!
!-----------------------------------------------------------------------
! !INTERFACE:
character(len=nlen) function get_archivedir( type )
!
! !PARAMETERS:
!
  character(len=*), intent(in) :: type ! Type of filename to create (init, rest, or hist)
!
! EOP
!
  if ( type /= 'hist' .and. type /= 'init' .and. type /= 'rest' )then
     write(6,*) 'GET_ARCHIVEDIR: Invalid type: ', type
     call endrun
  end if
  get_archivedir = trim(archive_dir) // trim(type) // '/'
end function get_archivedir

!-----------------------------------------------------------------------
! BOP
!
! !ROUTINE: interpret_filename_spec
!
! !DESCRIPTION: Create a filename from a filename specifyer. The
! filename specifyer includes codes for setting things such as the
! year, month, day, seconds in day, caseid, and tape number. This
! routine is private to filenames.F90
!
! Interpret filename specifyer string with:
!
!      %c for case,
!      %t for optional number argument sent into function
!      %y for year
!      %m for month
!      %d for day
!      %s for second
!      %% for the "%" character
!
! If the filename specifyer has spaces " ", they will be trimmed out
! of the resulting filename.
!
!-----------------------------------------------------------------------
! !INTERFACE:
character(len=nlen) function interpret_filename_spec( filename_spec, number, prev )
!
! !PARAMETERS:
!
  character(len=*), intent(in) :: filename_spec    ! Filename specifier to use
  integer, intent(in), optional :: number          ! Number to use for %t field
  logical, intent(in), optional :: prev            ! If should label with previous time-step
!
! EOP
!
  integer :: year  ! Simulation year
  integer :: month ! Simulation month
  integer :: day   ! Simulation day
  integer :: ncsec ! Seconds into current simulation day
  character(len=nlen) :: string    ! Temporary character string
  character(len=nlen) :: format    ! Format character string
  integer :: i, n  ! Loop variables
  logical :: previous              ! If should label with previous time-step

  if ( len_trim(filename_spec) == 0 )then
     write(6,*) 'INTERPRET_FILENAME_SPEC: filename specifier is empty'
     call endrun
  end if
  if ( index(trim(filename_spec)," ") /= 0 )then
     write(6,*) 'INTERPRET_FILENAME_SPEC: filename specifier can not contain a space:', &
                trim(filename_spec)
     call endrun
  end if
  if ( .not. present(prev) ) then
     previous = .false.
  else
     previous = prev
  end if
  if ( previous ) then
     call get_prev_date(year, month, day, ncsec)
  else
     call get_curr_date(year, month, day, ncsec)
  end if
!
! Go through each character in the filename specifyer and interpret if special string
!
  i = 1
  interpret_filename_spec = ''
  do while ( i <= len_trim(filename_spec) )
!
! If following is an expansion string
!
     if ( filename_spec(i:i) == "%" )then
        i = i + 1
        select case( filename_spec(i:i) )
           case( 'c' )   ! caseid
              string = trim(caseid)
           case( 't' )   ! number
              if ( .not. present(number) )then
                 write(6,*) 'INTERPRET_FILENAME_SPEC: number needed in filename_spec' &
                            , ', but not provided to subroutine'
                 write(6,*) 'filename_spec = ', filename_spec
                 call endrun
              end if
              if (      number > 999 ) then
                 format = '(i4.4)'
                 if ( number > 9999 ) then
                   write(6,*) 'INTERPRET_FILENAME_SPEC: number is too large: ', number
                   call endrun
                 end if
              else if ( number > 99  ) then
                 format = '(i3.3)'
              else if ( number > 9   ) then
                 format = '(i2.2)'
              else
                 format = '(i1.1)'
              end if
              write(string,format) number
           case( 'y' )   ! year
              if ( year > 99999   ) then
                format = '(i6.6)'
              else if ( year > 9999    ) then
                format = '(i5.5)'
              else
                format = '(i4.4)'
              end if
              write(string,format) year
           case( 'm' )   ! month
              write(string,'(i2.2)') month
           case( 'd' )   ! day
              write(string,'(i2.2)') day
           case( 's' )   ! second
              write(string,'(i5.5)') ncsec
           case( '%' )   ! percent character
              string = "%"
           case default
              write(6,*) 'INTERPRET_FILENAME_SPEC: Invalid expansion character: ', &
                          filename_spec(i:i)
              call endrun
        end select
!
! Otherwise take normal text up to the next "%" character
!
     else
        n = index( filename_spec(i:), "%" )
        if ( n == 0 ) n = len_trim( filename_spec(i:) ) + 1
        if ( n == 0 ) exit
        string = filename_spec(i:n+i-2)
        i = n + i - 2
     end if
     if ( len_trim(interpret_filename_spec) == 0 )then
        interpret_filename_spec = trim(string)
     else
        if ( (len_trim(interpret_filename_spec)+len_trim(string)) >= nlen )then
           write(6,*) 'INTERPRET_FILENAME_SPEC: Resultant filename too long'
           call endrun
        end if
        interpret_filename_spec = trim(interpret_filename_spec) // trim(string)
     end if
     i = i + 1

  end do
  if ( len_trim(interpret_filename_spec) == 0 )then
     write(6,*) 'INTERPRET_FILENAME_SPEC: Resulting filename is empty'
     call endrun
  end if

end function interpret_filename_spec

end module filenames
