module cola_fortran_generator_impl
  use cola
  use, intrinsic :: iso_c_binding
  implicit none
  private

  logical, save :: run_lock_taken = .false.

  type, public, extends(AbstractFortranGenerator) :: URQMDGenerator
    logical :: urqmd_initialized = .false.
    logical :: allow_table_generation = .false.
    character(len=512) :: input_file = ''
    character(len=512) :: generated_config_file = ''
    character(len=512) :: tables_file = ''
  contains
    procedure :: init => generator_init
    procedure :: run => generator_run
    final :: generator_final
  end type URQMDGenerator

  interface
    function setenv(name, value, overwrite) bind(c)
      import :: c_int, c_char
      integer(c_int) :: setenv
      character(kind=c_char), intent(in) :: name(*), value(*)
      integer(c_int), value :: overwrite
    end function
  end interface

  interface
    subroutine urqmd_cola_uinit(io)
      integer, intent(in) :: io
    end subroutine
    subroutine urqmd_cola_disable_outputs()
    end subroutine
    subroutine urqmd_cola_generate_tables(tabpath, ok)
      character(len=*), intent(in) :: tabpath
      logical, intent(out) :: ok
    end subroutine
    subroutine urqmd_cola_run_one_event(ebeam_out, bimp_out, np, parts)
      import :: EventParticles
      real(8), intent(out) :: ebeam_out, bimp_out
      integer, intent(out) :: np
      type(EventParticles), intent(inout) :: parts
    end subroutine
  end interface

  integer, external :: pdgid

contains

  subroutine acquire_run_lock()
    logical :: acquired
    do
      acquired = .false.
      critical
        if (.not. run_lock_taken) then
          run_lock_taken = .true.
          acquired = .true.
        end if
      end critical
      if (acquired) exit
    end do
  end subroutine acquire_run_lock

  subroutine release_run_lock()
    critical
      run_lock_taken = .false.
    end critical
  end subroutine release_run_lock

  pure function lower_ascii(s) result(out)
    character(len=*), intent(in) :: s
    character(len=len(s)) :: out
    integer :: i, c
    out = s
    do i = 1, len(out)
      c = iachar(out(i:i))
      if (c >= iachar('A') .and. c <= iachar('Z')) then
        out(i:i) = achar(c + 32)
      end if
    end do
  end function lower_ascii

  subroutine urqmd_cola_set_env(name_no_nul, path)
    character(len=*), intent(in) :: name_no_nul, path
    character(len=64) :: name
    character(len=1024) :: path_c
    integer(c_int) :: ierr
    name = trim(name_no_nul) // c_null_char
    path_c = trim(path) // c_null_char
    ierr = setenv(name, path_c, 1_c_int)
  end subroutine urqmd_cola_set_env

  logical function is_control_key(key)
    character(len=*), intent(in) :: key
    character(len=:), allocatable :: k
    k = trim(lower_ascii(key))
    is_control_key = (k == 'config_file' .or. k == 'config_path' .or. &
      k == 'generated_config_file' .or. k == 'generated_config_path' .or. &
      k == 'take_particles_from' .or. k == 'from_output_file' .or. &
      k == 'tables_file' .or. k == 'urqmd_tables_file' .or. &
      k == 'allow_table_generation')
  end function is_control_key

  subroutine get_tmpdir(tmpdir)
    character(len=512), intent(out) :: tmpdir
    integer :: len, status
    tmpdir = ''
    call get_environment_variable('TMPDIR', tmpdir, len, status)
    if (status /= 0 .or. len == 0) then
      call get_environment_variable('TEMP', tmpdir, len, status)
    end if
    if (status /= 0 .or. len == 0) then
      call get_environment_variable('TMP', tmpdir, len, status)
    end if
    if (len_trim(tmpdir) == 0) tmpdir = '/tmp'
  end subroutine get_tmpdir

  subroutine resolve_tables_path(self, path, exists)
    class(URQMDGenerator), intent(in) :: self
    character(len=512), intent(out) :: path
    logical, intent(out) :: exists
    path = ''
    exists = .false.
    if (len_trim(self%tables_file) > 0) then
      path = trim(self%tables_file)
      inquire(file=trim(path), exist=exists)
      if (exists) return
    end if
    path = 'tables.dat'
    inquire(file=trim(path), exist=exists)
  end subroutine resolve_tables_path

  subroutine generate_tables_external(table_path, ok)
    character(len=*), intent(in) :: table_path
    logical, intent(out) :: ok
    call urqmd_cola_set_env('URQMD_TAB', trim(table_path))
    call urqmd_cola_generate_tables(trim(table_path), ok)
  end subroutine generate_tables_external

  subroutine generator_init(self, pmap, err)
    class(URQMDGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    character(len=:), allocatable, intent(out) :: err
    type(ParametersMapItem) :: kv
    character(len=:), allocatable :: key, val, lkey
    character(len=512) :: tmpdir
    character(len=512) :: tables_path
    integer :: i, n, iostat, u
    logical :: tables_ok

    self%input_file = ''
    self%generated_config_file = ''
    self%tables_file = ''
    self%allow_table_generation = .true.
    err = ''
    n = pmap%size()

    do i = 1, n
      kv = pmap%get(i)
      key = kv%get_first()
      val = kv%get_second()
      lkey = trim(lower_ascii(key))
      if (lkey == 'config_file' .or. lkey == 'config_path') then
        self%input_file = trim(val)
      else if (lkey == 'generated_config_file' .or. lkey == 'generated_config_path') then
        self%generated_config_file = trim(val)
      else if (lkey == 'tables_file' .or. lkey == 'urqmd_tables_file') then
        self%tables_file = trim(val)
      else if (lkey == 'allow_table_generation') then
        if (trim(val) == '0' .or. trim(lower_ascii(val)) == 'false' .or. trim(lower_ascii(val)) == 'no') then
          self%allow_table_generation = .false.
        else if (trim(val) == '1' .or. trim(lower_ascii(val)) == 'true' .or. trim(lower_ascii(val)) == 'yes') then
          self%allow_table_generation = .true.
        end if
      end if
    end do

    if (len_trim(self%input_file) == 0) then
      if (len_trim(self%generated_config_file) == 0) then
        call get_tmpdir(tmpdir)
        tmpdir = trim(tmpdir)
        if (tmpdir(len_trim(tmpdir):len_trim(tmpdir)) /= '/') then
          self%generated_config_file = trim(tmpdir) // '/urqmd_cola_config.txt'
        else
          self%generated_config_file = trim(tmpdir) // 'urqmd_cola_config.txt'
        end if
      end if

      open(newunit=u, file=trim(self%generated_config_file), status='replace', action='write', iostat=iostat)
      if (iostat /= 0) then
        err = 'URQMD init failed: failed to create generated config file.'
        return
      end if
      do i = 1, n
        kv = pmap%get(i)
        key = kv%get_first()
        val = kv%get_second()
        if (is_control_key(key)) cycle
        write(u, '(a)') trim(key) // ' ' // trim(val)
      end do
      write(u, '(a)') 'xxx'
      close(u)
      self%input_file = trim(self%generated_config_file)
    end if

    call urqmd_cola_set_env('ftn09', trim(self%input_file))

    ! Stop UrQMD from writing to files
    call urqmd_cola_set_env('ftn13', ' ')
    call urqmd_cola_set_env('ftn14', ' ')
    call urqmd_cola_set_env('ftn15', ' ')
    call urqmd_cola_set_env('ftn16', ' ')
    call urqmd_cola_set_env('ftn19', ' ')
    call urqmd_cola_set_env('ftn20', ' ')

    call resolve_tables_path(self, tables_path, tables_ok)
    if (.not. tables_ok) then
      call generate_tables_external(trim(tables_path), tables_ok)
      if (tables_ok) then
        call resolve_tables_path(self, tables_path, tables_ok)
      end if
    end if
    if (.not. tables_ok) then
      err = 'URQMD init failed: failed to generate tables.dat.'
      return
    end if
    call urqmd_cola_set_env('URQMD_TAB', trim(tables_path))
    if (len_trim(self%tables_file) > 0) then
      call urqmd_cola_set_env('URQMD_TAB', trim(self%tables_file))
    end if
    call urqmd_cola_set_env('ftn09', trim(self%input_file))

    call urqmd_cola_uinit(0)
    call urqmd_cola_disable_outputs()
  end subroutine generator_init

  function generator_run(self, err) result(ed)
    class(URQMDGenerator), intent(in) :: self
    character(len=:), allocatable, intent(out) :: err
    type(EventData) :: ed
    type(EventIniState) :: ini
    type(EventParticles) :: parts
    integer :: np
    real(8) :: ebeam_val, bimp_val

    ed = EventData()
    err = ''
    call acquire_run_lock()
    parts = EventParticles()

    call urqmd_cola_run_one_event(ebeam_val, bimp_val, np, parts)

    ini = ed%get_iniState()
    call ini%set_energy(ebeam_val)
    call ini%set_b(real(bimp_val, kind(0.0)))
    if (np < 0) np = 0
    call ed%set_particles(parts)

    call release_run_lock()
  end function generator_run

  subroutine generator_final(self)
    type(URQMDGenerator), intent(inout) :: self
  end subroutine generator_final
end module cola_fortran_generator_impl
