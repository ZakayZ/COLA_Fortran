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
    type(EventParticles) :: parts
    type(Particle) :: p
    ed = EventData()
    ini = ed%get_iniState()
    call ini%set_energy(1.0d0)

    p = Particle()
    call p%set_pdgCode(2212)
    call p%set_pClass(ParticleClass_PRODUCED)
    parts = EventParticles()
    call parts%push_back(p)
    call ed%set_particles(parts)
  end function generator_run

  subroutine generator_final(self)
    type(FortranGenerator), intent(inout) :: self
  end subroutine generator_final
end module cola_fortran_generator_impl
