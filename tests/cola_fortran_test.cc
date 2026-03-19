#include <COLA.hh>
#include <gtest/gtest.h>

#include "TestFortranFilters/TestFortranFiltersModule.hh"

using namespace cola;

TEST(COLA_Fortran_ExamplePipeline, GeneratorThenConverterMatchesExample) {
    auto mod = cola::fortran::TestFortranFiltersModule();
    auto filters = mod.GetModuleFilters();

    auto genFilter = filters["FortranGenerator"]->Create({});
    auto convFilter = filters["FortranConverter"]->Create({});

    auto* gen = dynamic_cast<VGenerator*>(genFilter.get());
    auto* conv = dynamic_cast<VConverter*>(convFilter.get());
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
