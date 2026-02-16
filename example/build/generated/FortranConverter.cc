#include "FortranConverter.hh"

namespace cola::fortran {
    class FortranConverter : public cola::VConverter {
    public:
        FortranConverter(const std::unordered_map<std::string, std::string>& params)
            : handle_(cola_fortran_FortranConverter_create(ToFortranParametersMap(params).data()), cola_fortran_FortranConverter_destroy) {}

        ~FortranConverter() = default;

        std::unique_ptr<EventData> operator()(std::unique_ptr<EventData>&& data) override {
            cola_fortran_FortranConverter_run(handle_.get(), data.get());
            return data;
        }

    private:
        std::unique_ptr<void, void (*)(void*)> handle_;
    };

    std::unique_ptr<cola::VFilter> FortranConverterFactory::Create(const std::unordered_map<std::string, std::string>& metaData) {
        return std::make_unique<FortranConverter>(metaData);
    }
} // namespace cola::fortran
