module test_writer_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranWriter) :: FileWriter
    character(len=1024) :: output_file = ''
  contains
    procedure :: init => writer_init
    procedure :: run => writer_run
  end type FileWriter

contains

  subroutine writer_init(self, pmap, err)
    class(FileWriter), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    type(ParametersMapItem) :: item
    character(len=:), allocatable :: key, value
    integer :: i

    self%output_file = ''
    err = ''
    do i = 1, pmap%size()
      item = pmap%get(i)
      key = item%get_first()
      value = item%get_second()
      if (key == 'output_file') self%output_file = trim(value)
    end do

    if (len_trim(self%output_file) == 0) err = 'FileWriter requires output_file'
  end subroutine writer_init

  subroutine writer_run(self, ed, err)
    class(FileWriter), intent(in) :: self
    type(EventData), intent(in) :: ed
    character(len=:), allocatable, intent(out) :: err
    type(EventIniState) :: ini
    integer :: unit, write_status, close_status

    err = ''
    open(newunit=unit, file=trim(self%output_file), status='replace', action='write', iostat=write_status)
    if (write_status /= 0) then
      err = 'FileWriter failed to open output_file'
      return
    end if

    ini = ed%get_ini_state()
    write(unit, '(f0.1)', iostat=write_status) ini%get_energy()
    close(unit, iostat=close_status)
    if (write_status /= 0 .or. close_status /= 0) err = 'FileWriter failed to write output_file'
  end subroutine writer_run

end module test_writer_impl
