#include "ExampleFortran/ExampleFortranModule.hh"

int main() {
    auto mod = cola::fortran::ExampleFortranModule();
    auto filters = mod.GetModuleFilters();
    for (auto& [filterName, factory] : filters) {
        auto filter = factory->Create({});
    }
}
