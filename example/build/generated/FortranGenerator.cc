#include "FortranGenerator.hh"

namespace cola::fortran {

    class FortranGenerator : public cola::VGenerator {
    public:
        FortranGenerator(const std::unordered_map<std::string, std::string>& params)
            : handle_(cola_fortran_FortranGenerator_create(ToFortranParametersMap(params).data()), cola_fortran_FortranGenerator_destroy) {}

        ~FortranGenerator() = default;

        std::unique_ptr<EventData> operator()() override {
            void* raw = cola_fortran_FortranGenerator_run(handle_.get());
            return std::unique_ptr<EventData>(static_cast<EventData*>(raw));
        }

    private:
        std::unique_ptr<void, void (*)(void*)> handle_;
    };

    std::unique_ptr<cola::VFilter> FortranGeneratorFactory::Create(const std::unordered_map<std::string, std::string>& metaData) {
        return std::make_unique<FortranGenerator>(metaData);
    }

} // namespace cola::fortran
