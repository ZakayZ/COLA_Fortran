! ---------------------------------------------------------------------------
! URQMDGenerator: extends AbstractFortranGenerator.
! Configured by input file only. Create({{"input", "path/to/urqmd_input"}}).
! ---------------------------------------------------------------------------
module cola_fortran_generator_impl
  use cola
  implicit none
  private

  type, public, extends(AbstractFortranGenerator) :: URQMDGenerator
    logical :: urqmd_initialized = .false.
  contains
    procedure :: init => generator_init
    procedure :: run => generator_run
    final :: generator_final
  end type URQMDGenerator

  character(len=512) :: input_file = ''

  interface
    subroutine urqmd_cola_set_input_file(path)
      character(len=*), intent(in) :: path
    end subroutine
    subroutine urqmd_cola_uinit(io)
      integer, intent(in) :: io
    end subroutine
    subroutine urqmd_cola_get_ebeam_bimp(ebeam_out, bimp_out)
      real(8), intent(out) :: ebeam_out, bimp_out
    end subroutine
    subroutine urqmd_cola_init_event
    end subroutine
    subroutine urqmd_cola_run_cascade
    end subroutine
    subroutine urqmd_cola_get_particle(i, r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv, itypv, iso3v, np)
      integer, intent(in) :: i
      real(8), intent(out) :: r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv
      integer, intent(out) :: itypv, iso3v, np
    end subroutine
  end interface

  integer, external :: pdgid

contains

  subroutine generator_init(self, pmap)
    class(URQMDGenerator), intent(inout) :: self
    type(ParametersMap), intent(in) :: pmap
    type(ParametersMapItem) :: kv
    character(len=:), allocatable :: key, val
    integer :: i, n
    input_file = ''
    n = pmap%size()
    do i = 1, n
      kv = pmap%get(i)
      key = kv%get_first()
      val = kv%get_second()
      if (trim(key) == 'input') then
        input_file = trim(val)
        exit
      end if
    end do
    if (.not. self%urqmd_initialized) then
      if (len_trim(input_file) > 0) then
        call urqmd_cola_set_input_file(trim(input_file))
        call urqmd_cola_uinit(0)
      else
        call urqmd_cola_uinit(1)
      end if
      self%urqmd_initialized = .true.
    end if
  end subroutine generator_init

  function generator_run(self) result(ed)
    class(URQMDGenerator), intent(in) :: self
    type(EventData) :: ed
    type(EventIniState) :: ini
    type(EventParticles) :: parts
    type(Particle) :: p
    type(LorentzVector) :: mom, pos
    integer :: np, i, itypv, iso3v, pdg
    real(8) :: r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv
    real(8) :: ebeam_val, bimp_val

    call urqmd_cola_init_event
    call urqmd_cola_run_cascade

    ed = EventData()
    ini = ed%get_iniState()
    call urqmd_cola_get_ebeam_bimp(ebeam_val, bimp_val)
    call ini%set_energy(ebeam_val)
    call ini%set_b(real(bimp_val, kind(0.0)))
    parts = EventParticles()
    call urqmd_cola_get_particle(0, r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv, itypv, iso3v, np)
    do i = 1, np
      call urqmd_cola_get_particle(i, r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv, itypv, iso3v, np)
      if (p0v /= p0v .or. p0v <= 0.0d0) then
        p0v = sqrt(max(0.0d0, pxv**2 + pyv**2 + pzv**2 + fmassv**2))
      end if
      pdg = pdgid(itypv, iso3v)
      p = Particle()
      call p%set_pdgCode(pdg)
      call p%set_pClass(ParticleClass_PRODUCED)
      mom = LorentzVector(p0v, pxv, pyv, pzv)
      call p%set_momentum(mom)
      pos = LorentzVector(r0v, rxv, ryv, rzv)
      call p%set_position(pos)
      call parts%push_back(p)
    end do
    call ed%set_particles(parts)
  end function generator_run

  subroutine generator_final(self)
    type(URQMDGenerator), intent(inout) :: self
  end subroutine generator_final
end module cola_fortran_generator_impl
