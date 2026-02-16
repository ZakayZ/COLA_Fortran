#ifndef COLA_FORTRAN_ExampleFortranModule_HH
#define COLA_FORTRAN_ExampleFortranModule_HH

#include <COLA.hh>

#include <FortranConverter.hh>
#include <FortranGenerator.hh>
#include <FortranWriter.hh>


namespace cola::fortran {
    using ExampleFortranModule = cola::GenericModule<FortranConverterFactory, FortranGeneratorFactory, FortranWriterFactory>;
} // namespace cola::fortran

#endif // COLA_FORTRAN_ExampleFortranModule_HH
