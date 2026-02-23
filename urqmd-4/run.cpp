#include "Urqmd4/Urqmd4Module.hh"
#include <COLA/EventData.hh>

int main() {
    auto mod = cola::fortran::Urqmd4Module();
    auto filters = mod.GetModuleFilters();
    auto filter = filters["URQMDGenerator"]->Create({
        {"input", "urqmd_compare_input"}
    });
    auto gen = dynamic_cast<cola::VGenerator*>(filter.get());
    for (int i = 0; i < 3; ++i) {
        auto data = (*gen)();
    }
}
