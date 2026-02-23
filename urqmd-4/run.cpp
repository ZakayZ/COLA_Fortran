#include "Urqmd4/Urqmd4Module.hh"
#include <COLA/EventData.hh>
#include <iomanip>
#include <iostream>

int main() {
    auto mod = cola::fortran::Urqmd4Module();
    auto filters = mod.GetModuleFilters();
    auto filter = filters["URQMDGenerator"]->Create({{"config_path", "urqmd_compare_input"}});
    auto gen = dynamic_cast<cola::VGenerator*>(filter.get());

    auto data = (*gen)();

    std::cout << std::scientific << std::setprecision(8);
    const auto& parts = data->particles;
    std::cout << parts.size() << "\n";
    for (size_t i = 0; i < parts.size(); ++i) {
        const auto& p = parts[i];
        const auto& pos = p.position;
        const auto& mom = p.momentum;
        std::cout << pos.t << " " << pos.x << " " << pos.y << " " << pos.z << " "
            << mom.e << " " << mom.x << " " << mom.y << " " << mom.z << " "
            << p.pdgCode << "\n";
    }
}
