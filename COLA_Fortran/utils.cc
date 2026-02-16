#include "utils.hh"

namespace cola::fortran {
    FortranParametersMap ToFortranParametersMap(const std::unordered_map<std::string, std::string>& params) {
        FortranParametersMap result;
        for (const auto& [key, value] : params) {
            result.emplace_back(key, value);
        }
        return result;
    }
} // namespace cola::fortran
