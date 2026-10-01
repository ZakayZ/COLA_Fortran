module multiple_generators_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranGenerator) :: FirstGenerator
  contains
    procedure :: init => first_generator_init
    procedure :: run => first_generator_run
  end type FirstGenerator

  type, public, extends(AbstractFortranGenerator) :: SecondGenerator
  contains
    procedure :: init => second_generator_init
    procedure :: run => second_generator_run
  end type SecondGenerator

contains

  subroutine first_generator_init(self, pmap, err)
    class(FirstGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    err = ''
  end subroutine first_generator_init

  function first_generator_run(self, err) result(ed)
    class(FirstGenerator), intent(in) :: self
    character(len=:), allocatable, intent(out) :: err
    type(EventData) :: ed
    type(EventIniState) :: ini
    ed = EventData()
    ini = ed%get_ini_state()
    call ini%set_energy(1.0d0)
    err = ''
  end function first_generator_run

  subroutine second_generator_init(self, pmap, err)
    class(SecondGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    err = ''
  end subroutine second_generator_init

  function second_generator_run(self, err) result(ed)
    class(SecondGenerator), intent(in) :: self
    character(len=:), allocatable, intent(out) :: err
    type(EventData) :: ed
    type(EventIniState) :: ini
    ed = EventData()
    ini = ed%get_ini_state()
    call ini%set_energy(2.0d0)
    err = ''
  end function second_generator_run

end module multiple_generators_impl
