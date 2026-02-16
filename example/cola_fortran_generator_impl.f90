! ---------------------------------------------------------------------------
! FortranGenerator extends AbstractFortranGenerator (init, run); adds final.
! No C interop.
! ---------------------------------------------------------------------------
module cola_fortran_generator_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranGenerator) :: FortranGenerator
  contains
    procedure :: init => generator_init
    procedure :: run => generator_run
    final :: generator_final
  end type FortranGenerator
contains
  subroutine generator_init(self, pmap)
    class(FortranGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    integer :: n
    n = pmap%size()
    ! Use pmap%get(i) etc. for configuration
  end subroutine generator_init

  function generator_run(self) result(ed)
    class(FortranGenerator), intent(in) :: self
    type(EventData) :: ed
    type(EventIniState) :: ini
    ! Create EventData from scratch and fill it
    ed = EventData()
    ini = ed%get_iniState()
    call ini%set_energy(1.0d0)
  end function generator_run

  subroutine generator_final(self)
    type(FortranGenerator), intent(inout) :: self
  end subroutine generator_final
end module cola_fortran_generator_impl
