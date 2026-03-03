#include "Urqmd4/Urqmd4Module.hh"
#include <COLA/EventData.hh>
#include <iomanip>
#include <iostream>
#include <string>
#include <unordered_map>

int main(int argc, char** argv) {
    const std::string configFile = (argc > 1) ? argv[1] : "urqmd_compare_input";
    const std::string particleSource = (argc > 2) ? argv[2] : "";

    auto mod = cola::fortran::Urqmd4Module();
    auto filters = mod.GetModuleFilters();
    std::unordered_map<std::string, std::string> params = {
        {"config_file", configFile}
    };
    if (!particleSource.empty()) {
        params["take_particles_from"] = particleSource;
    }
    auto filter = filters["URQMDGenerator"]->Create(params);
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
