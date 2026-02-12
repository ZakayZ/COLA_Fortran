%module cola

%{
#include <utility>
#include <vector>
#include <cstdint>
#include <COLA/EventData.hh>
%}

%ignore cola::Vector3;
%ignore cola::RotateUz;

%include <std_pair.i>
%include <std_string.i>
%include <std_vector.i>
%include <stdint.i>

%template(AZ) std::pair<uint16_t, uint16_t>;
%template(ParametersMap) std::vector<std::pair<std::string, std::string>>;
%template(EventParticles) std::vector<cola::Particle>;

%include <COLA/EventData.hh>

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
    subroutine fortran_converter_init_interface(self, pmap)
      import :: AbstractFortranConverter, ParametersMap
      class(AbstractFortranConverter), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
    end subroutine
    subroutine fortran_converter_run_interface(self, ed)
      import :: AbstractFortranConverter, EventData
      class(AbstractFortranConverter), intent(in) :: self
      type(EventData), intent(inout) :: ed
    end subroutine

    subroutine fortran_generator_init_interface(self, pmap)
      import :: AbstractFortranGenerator, ParametersMap
      class(AbstractFortranGenerator), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
    end subroutine
    function fortran_generator_run_interface(self) result(ed)
      import :: AbstractFortranGenerator, EventData
      class(AbstractFortranGenerator), intent(in) :: self
      type(EventData) :: ed
    end function

    subroutine fortran_writer_init_interface(self, pmap)
      import :: AbstractFortranWriter, ParametersMap
      class(AbstractFortranWriter), intent(inout) :: self
      type(ParametersMap), intent(in) :: pmap
    end subroutine
    subroutine fortran_writer_run_interface(self, ed)
      import :: AbstractFortranWriter, EventData
      class(AbstractFortranWriter), intent(in) :: self
      type(EventData), intent(in) :: ed
    end subroutine
  end interface
%}
