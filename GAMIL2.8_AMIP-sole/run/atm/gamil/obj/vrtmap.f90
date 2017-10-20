# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/vrtmap.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/vrtmap.F90"

# 1 "./misc.h" 1
# 2 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/vrtmap.F90" 2

# 1 "./params.h" 1
# 3 "/data3/work/yuxinzhu/test/model_platform/models/atm/GAMIL2.8_AMIP/src/control/vrtmap.F90" 2

subroutine vrtmap (pkdim   ,pmap    ,sigln   ,dsigln  ,kdpmap  )
!----------------------------------------------------------------------- 
! 
! Purpose: Map indices of an artificial evenly spaced (in log) vertical grid to
!          the indices of the log of the model vertical grid.  The resultant
!          array of mapped indices will be used by "kdpfnd" to find the vertical
!          location of any departure point relative to the model grid.
! 
! Method: 
! 
! Author: Jerry Olson
! 
!-----------------------------------------------------------------------
   use shr_kind_mod, only: r8 => shr_kind_r8

   use srchutil, only: ismin

!-----------------------------------------------------------------------
   implicit none
!-----------------------------------------------------------------------
!
! Arguments
!
   integer, intent(in) :: pkdim             ! dimension of "sigln" and "dsigln"
   integer, intent(in) :: pmap              ! dimension of "kdpmap"

   real(r8), intent(in) :: sigln (pkdim)    ! model levels (log(eta))
   real(r8), intent(in) :: dsigln(pkdim)    ! intervals between model levels (log)

   integer, intent(out) :: kdpmap(pmap)     ! array of mapped indices
!
!---------------------------Local variables-----------------------------
!
   integer imin              ! |
   integer k                 ! |-- indices
   integer kk                ! |
   integer newmap            ! estimated value of "pmap"

   real(r8) del              ! artificial grid interval
   real(r8) dp               ! artificial departure point
   real(r8) eps              ! epsilon factor



!
!-----------------------------------------------------------------------
!
   eps = 1.e-05
   del = ( sigln(pkdim) - sigln(1) )/float(pmap)
   imin = ismin( pkdim-1,dsigln, 1 )
   if (del + eps  >=  dsigln(imin)) then
      newmap = ( sigln(pkdim) - sigln(1) )/dsigln(imin) + 1
      write(6,9000) pmap,newmap
      call endrun
   end if

   kdpmap(1) = 1
   do kk = 2,pmap
      dp = sigln(1) + float(kk-1)*del
      do k = 1,pkdim-1
         if(dp > sigln(k) + eps) then
            kdpmap(kk) = k
         end if
      end do
   end do

   return
9000 format(' VRTMAP:  Not enough artificial grid intervals.'/ &
            ' Currently, "pmap" is set to ',i20/ &
            ' Reset parameter "pmap" to at least ',i20)
end subroutine vrtmap
