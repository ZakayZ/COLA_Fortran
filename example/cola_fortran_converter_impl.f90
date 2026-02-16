! ---------------------------------------------------------------------------
! FortranConverter extends AbstractFortranConverter (init, run); adds final.
! No C interop.
! ---------------------------------------------------------------------------
module cola_fortran_converter_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranConverter) :: FortranConverter
  contains
    procedure :: init => converter_init
    procedure :: run => converter_run
    final :: converter_final
  end type FortranConverter
contains
  subroutine converter_init(self, pmap)
    class(FortranConverter), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    integer :: n
    n = pmap%size()
    ! Use pmap%get(i) etc. for configuration
  end subroutine converter_init

  subroutine converter_run(self, ed)
    class(FortranConverter), intent(in) :: self
    type(EventData), intent(inout) :: ed
    type(EventIniState) :: ini
    ini = ed%get_iniState()
    call ini%set_energy(2.0 * ini%get_energy())
  end subroutine converter_run

  subroutine converter_final(self)
    type(FortranConverter), intent(inout) :: self
  end subroutine converter_final
end module cola_fortran_converter_impl
