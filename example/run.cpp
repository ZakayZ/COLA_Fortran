#include "ExampleFortran/ExampleFortranModule.hh"

int main() {
    auto mod = cola::fortran::ExampleFortranModule();
    auto filters = mod.GetModuleFilters();

    auto genFilter = filters["FortranGenerator"]->Create({});
    auto convFilter = filters["FortranConverter"]->Create({});
    auto wrFilter = filters["FortranWriter"]->Create({});

    auto* gen = dynamic_cast<cola::VGenerator*>(genFilter.get());
    auto* conv = dynamic_cast<cola::VConverter*>(convFilter.get());
    auto* wr = dynamic_cast<cola::VWriter*>(wrFilter.get());

    // Run pipeline: generate -> convert (double energy) -> write (print)
    auto data = (*gen)();
    data = (*conv)(std::move(data));
    (*wr)(std::move(data));
}
