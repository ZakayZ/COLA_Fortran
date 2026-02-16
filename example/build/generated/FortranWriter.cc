#include "FortranWriter.hh"

namespace cola::fortran {

    class FortranWriter : public cola::VWriter {
    public:
        FortranWriter(const std::unordered_map<std::string, std::string>& params)
            : handle_(cola_fortran_FortranWriter_create(ToFortranParametersMap(params).data()), cola_fortran_FortranWriter_destroy) {}

        ~FortranWriter() = default;

        void operator()(std::unique_ptr<cola::EventData>&& data) override {
            cola_fortran_FortranWriter_run(handle_.get(), data.get());
        }

    private:
        std::unique_ptr<void, void (*)(void*)> handle_;
    };

    std::unique_ptr<cola::VFilter> FortranWriterFactory::Create(const std::unordered_map<std::string, std::string>& metaData) {
        return std::make_unique<FortranWriter>(metaData);
    }

} // namespace cola::fortran
