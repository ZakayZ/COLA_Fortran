#ifndef COLA_FORTRAN_FortranGenerator_GENERATOR_HH
#define COLA_FORTRAN_FortranGenerator_GENERATOR_HH

#include <memory>

#include <COLA.hh>
#include <COLA_Fortran/utils.hh>

namespace cola::fortran {
    // NOLINTBEGIN(readability-identifier-naming)
    extern "C" {
        /** Create generator instance. Returns opaque handle. \p params is ParametersMap* (vector of pair<string,string>). */
        void* cola_fortran_FortranGenerator_create(const void* params);

        /** Produce one event. Returns new EventData*; ownership is transferred to the caller. */
        void* cola_fortran_FortranGenerator_run(void* handle);

        /** Destroy generator instance and release resources for \p handle. */
        void cola_fortran_FortranGenerator_destroy(void* handle);
    }
    // NOLINTEND(readability-identifier-naming)

    class FortranGeneratorFactory : public cola::VGeneratorFactory {
      public:
        FortranGeneratorFactory() = default;

        std::unique_ptr<cola::VFilter> Create(const std::unordered_map<std::string, std::string>& metaData) override;

        const std::string& GetFilterName() const override {
            static const std::string NAME = "FortranGenerator";
            return NAME;
        }
    };

} // namespace cola::fortran

#endif // COLA_FORTRAN_FortranGenerator_GENERATOR_HH
