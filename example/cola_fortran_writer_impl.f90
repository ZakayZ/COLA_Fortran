! ---------------------------------------------------------------------------
! FortranWriter extends AbstractFortranWriter (init, run); adds final.
! No C interop.
! ---------------------------------------------------------------------------
module cola_fortran_writer_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranWriter) :: FortranWriter
  contains
    procedure :: init => writer_init
    procedure :: run => writer_run
    final :: writer_final
  end type FortranWriter
contains
  subroutine writer_init(self, pmap)
    class(FortranWriter), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    integer :: n
    n = pmap%size()
    ! Use pmap%get(i) etc. for configuration
  end subroutine writer_init

  subroutine writer_run(self, ed)
    class(FortranWriter), intent(in) :: self
    type(EventData), intent(in) :: ed
    ! Write event (e.g. to file, stream). Placeholder: use ed%get_iniState(), ed%get_particles(), etc.
  end subroutine writer_run

  subroutine writer_final(self)
    type(FortranWriter), intent(inout) :: self
  end subroutine writer_final
end module cola_fortran_writer_impl
