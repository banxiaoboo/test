!!(wanhui 2003.11.05)
!!-------------------

#include <misc.h>
#include <params.h>

#if (defined SPMD)

      integer nprocessor
      parameter(nprocessor=NTASK)            !by LPF
      integer,parameter :: nx = 130
      integer,parameter :: ny = 60/nprocessor+2
      integer,parameter :: nl = 26
      integer,parameter :: nz = 27

#else
      integer,parameter :: nx = 130
      integer,parameter :: ny = 60
      integer,parameter :: nl = 26
      integer,parameter :: nz = 27
#endif

