#include "ExampleFortran/ExampleFortranModule.hh"

int main() {
  auto mod = cola::fortran::ExampleFortranModule();
  auto filters = mod.GetModuleFilters();

  auto gen_filter = filters["FortranGenerator"]->Create({});
  auto conv_filter = filters["FortranConverter"]->Create({});
  auto wr_filter = filters["FortranWriter"]->Create({});

  auto* gen = dynamic_cast<cola::VGenerator*>(gen_filter.get());
  auto* conv = dynamic_cast<cola::VConverter*>(conv_filter.get());
  auto* wr = dynamic_cast<cola::VWriter*>(wr_filter.get());

  auto data = (*gen)();
  data = (*conv)(std::move(data));
  (*wr)(std::move(data));
}
