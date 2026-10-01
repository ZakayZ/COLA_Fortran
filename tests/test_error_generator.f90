module test_error_generator_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranGenerator) :: ErrorGenerator
    logical :: fail_run = .false.
  contains
    procedure :: init => generator_init
    procedure :: run => generator_run
  end type ErrorGenerator

contains

  subroutine generator_init(self, pmap, err)
    class(ErrorGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    type(ParametersMapItem) :: item
    character(len=:), allocatable :: key, value
    integer :: i

    self%fail_run = .false.
    err = ''
    do i = 1, pmap%size()
      item = pmap%get(i)
      key = item%get_first()
      value = item%get_second()
      if (key /= 'error_stage') cycle
      if (value == 'init') then
        err = 'expected Fortran init error'
        return
      end if
      if (value == 'run') self%fail_run = .true.
    end do
  end subroutine generator_init

  function generator_run(self, err) result(ed)
    class(ErrorGenerator), intent(in) :: self
    character(len=:), allocatable, intent(out) :: err
    type(EventData) :: ed

    ed = EventData()
    if (self%fail_run) then
      err = 'expected Fortran run error'
      return
    end if
    err = ''
  end function generator_run

end module test_error_generator_impl
