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
  subroutine converter_init(self, pmap, err)
    class(FortranConverter), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    integer :: n
    err = ''
    n = pmap%size()
    ! Use pmap%get(i) etc. for configuration
  end subroutine converter_init

  subroutine converter_run(self, ed, err)
    class(FortranConverter), intent(in) :: self
    type(EventData), intent(inout) :: ed
    character(len=:), allocatable, intent(out) :: err
    type(EventIniState) :: ini
    ini = ed%get_iniState()
    call ini%set_energy(2.0d0 * ini%get_energy())
    err = ''
  end subroutine converter_run

  subroutine converter_final(self)
    type(FortranConverter), intent(inout) :: self
  end subroutine converter_final

end module cola_fortran_converter_impl
