#ifndef COLA_FORTRAN_FortranWriter_WRITER_HH
#define COLA_FORTRAN_FortranWriter_WRITER_HH

#include <memory>

#include <COLA.hh>
#include <COLA_Fortran/utils.hh>

namespace cola::fortran {
    // NOLINTBEGIN(readability-identifier-naming)
    extern "C" {
        /** Create writer instance. Returns opaque handle. \p params is ParametersMap* (vector of pair<string,string>). */
        void* cola_fortran_FortranWriter_create(const void* params);

        /** Write one event. \p data is EventData* (read-only from C++ side). */
        void cola_fortran_FortranWriter_run(void* handle, void* data);

        /** Destroy writer instance and release resources for \p handle. */
        void cola_fortran_FortranWriter_destroy(void* handle);
    }
    // NOLINTEND(readability-identifier-naming)

    class FortranWriterFactory : public cola::VWriterFactory {
      public:
        FortranWriterFactory() = default;

        std::unique_ptr<cola::VFilter> Create(const std::unordered_map<std::string, std::string>& metaData) override;

        const std::string& GetFilterName() const override {
            static const std::string NAME = "FortranWriter";
            return NAME;
        }
    };

} // namespace cola::fortran

#endif // COLA_FORTRAN_FortranWriter_WRITER_HH
