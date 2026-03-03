%module cola

%{
#include <utility>
#include <vector>
#include <cstdint>
#include <COLA/EventData.hh>
#include <COLA/LorentzVector.hh>
%}

%ignore cola::Vector3;
%ignore cola::RotateUz;

%include <std_pair.i>
%include <std_string.i>
%include <std_vector.i>
%include <stdint.i>

%include <COLA/LorentzVector.hh>
%template(LorentzVector) cola::LorentzVectorImpl<double>;

// nested union e/t not supported; add accessors and init constructor
%extend cola::LorentzVectorImpl<double> {
  double get_e() const { return $self->e; }
  void set_e(double v) { $self->e = v; }
  double get_t() const { return $self->t; }
  void set_t(double v) { $self->t = v; }
  LorentzVectorImpl(double e, double x, double y, double z) {
    cola::LorentzVector *v = new cola::LorentzVector();
    v->e = e;
    v->x = x;
    v->y = y;
    v->z = z;
    return v;
  }
}

%include <COLA/EventData.hh>

%template(AZ) std::pair<uint16_t, uint16_t>;
%template(ParametersMapItem) std::pair<std::string, std::string>;
%template(ParametersMap) std::vector<std::pair<std::string, std::string>>;
%template(EventParticles) std::vector<cola::Particle>;

%insert("fdecl") %{
  type, abstract, public :: AbstractFortranConverter
  contains
    procedure(fortran_converter_init_interface), deferred :: init
    procedure(fortran_converter_run_interface), deferred :: run
  end type AbstractFortranConverter

  type, abstract, public :: AbstractFortranGenerator
  contains
    procedure(fortran_generator_init_interface), deferred :: init
    procedure(fortran_generator_run_interface), deferred :: run
  end type AbstractFortranGenerator

  type, abstract, public :: AbstractFortranWriter
  contains
    procedure(fortran_writer_init_interface), deferred :: init
    procedure(fortran_writer_run_interface), deferred :: run
  end type AbstractFortranWriter

  abstract interface
    subroutine fortran_converter_init_interface(self, pmap, err)
      import :: AbstractFortranConverter, ParametersMap
      class(AbstractFortranConverter), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
      character(len=:), allocatable, intent(out) :: err
    end subroutine
    subroutine fortran_converter_run_interface(self, ed, err)
      import :: AbstractFortranConverter, EventData
      class(AbstractFortranConverter), intent(in) :: self
      type(EventData), intent(inout) :: ed
      character(len=:), allocatable, intent(out) :: err
    end subroutine

    subroutine fortran_generator_init_interface(self, pmap, err)
      import :: AbstractFortranGenerator, ParametersMap
      class(AbstractFortranGenerator), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
      character(len=:), allocatable, intent(out) :: err
    end subroutine
    function fortran_generator_run_interface(self, err) result(ed)
      import :: AbstractFortranGenerator, EventData
      class(AbstractFortranGenerator), intent(in) :: self
      character(len=:), allocatable, intent(out) :: err
      type(EventData) :: ed
    end function

    subroutine fortran_writer_init_interface(self, pmap, err)
      import :: AbstractFortranWriter, ParametersMap
      class(AbstractFortranWriter), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
      character(len=:), allocatable, intent(out) :: err
    end subroutine
    subroutine fortran_writer_run_interface(self, ed, err)
      import :: AbstractFortranWriter, EventData
      class(AbstractFortranWriter), intent(in) :: self
      type(EventData), intent(in) :: ed
      character(len=:), allocatable, intent(out) :: err
    end subroutine
  end interface
%}
