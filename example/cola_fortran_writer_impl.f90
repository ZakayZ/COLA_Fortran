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
    type(EventIniState) :: ini
    type(EventParticles) :: parts
    type(Particle) :: p
    integer :: i, n

    ini = ed%get_iniState()
    parts = ed%get_particles()
    n = parts%size()
    print '(a,f0.4)', 'Event energy: ', ini%get_energy()
    print '(a,i0)', 'Number of particles: ', n
    if (n > 0) then
      do i = 1, n
        p = parts%get(i)
        print '(a,i0,a,i0)', '  Particle ', i, ': pdg_code = ', p%get_pdgCode()
      end do
    end if
    print '(a)', '---'
  end subroutine writer_run

  subroutine writer_final(self)
    type(FortranWriter), intent(inout) :: self
  end subroutine writer_final
end module cola_fortran_writer_impl
