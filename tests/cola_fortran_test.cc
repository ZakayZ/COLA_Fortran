#include "TestFortranFilters/TestFortranFiltersModule.hh"

#include <COLA.hh>
#include <gtest/gtest.h>

using namespace cola;

TEST(ColaFortranExamplePipeline, GeneratorThenConverterMatchesExample) {
  auto mod = cola::fortran::TestFortranFiltersModule();
  auto filters = mod.GetModuleFilters();

  auto gen_filter = filters["FortranGenerator"]->Create({});
  auto conv_filter = filters["FortranConverter"]->Create({});

  auto* gen = dynamic_cast<VGenerator*>(gen_filter.get());
  auto* conv = dynamic_cast<VConverter*>(conv_filter.get());
  ASSERT_NE(gen, nullptr);
  ASSERT_NE(conv, nullptr);

  auto data = (*gen)();
  ASSERT_NE(data, nullptr);
  EXPECT_NEAR(data->iniState.energy, 1.0, 1e-12);
  ASSERT_EQ(data->particles.size(), 1u);
  EXPECT_EQ(data->particles[0].pdgCode, 2212);

  data = (*conv)(std::move(data));
  ASSERT_NE(data, nullptr);
  EXPECT_NEAR(data->iniState.energy, 2.0, 1e-12);
  ASSERT_EQ(data->particles.size(), 1u);
  EXPECT_EQ(data->particles[0].pdgCode, 2212);
}
