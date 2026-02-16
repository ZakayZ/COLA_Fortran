#ifndef COLA_FORTRAN_FortranConverter_CONVERTER_HH
#define COLA_FORTRAN_FortranConverter_CONVERTER_HH

#include <memory>

#include <COLA.hh>
#include <COLA_Fortran/utils.hh>

namespace cola::fortran {
    // NOLINTBEGIN(readability-identifier-naming)
    extern "C" {
        /** Create converter instance. Returns opaque handle. \p params is nullptr or ParametersMap* (vector of pair<string,string>). */
        void* cola_fortran_FortranConverter_create(const void* params);

        /** Run one conversion step: modify \p data (EventData*) in place. */
        void cola_fortran_FortranConverter_run(void* handle, void* data);

        /** Destroy converter instance and release resources for \p handle. */
        void cola_fortran_FortranConverter_destroy(void* handle);
    }
    // NOLINTEND(readability-identifier-naming)

    class FortranConverterFactory : public cola::VConverterFactory {
      public:
        FortranConverterFactory() = default;

        std::unique_ptr<cola::VFilter> Create(const std::unordered_map<std::string, std::string>& metaData) override;

        const std::string& GetFilterName() const override {
            static const std::string NAME = "FortranConverter";
            return NAME;
        }
    };

} // namespace cola::fortran

#endif // COLA_FORTRAN_FortranConverter_CONVERTER_HH
