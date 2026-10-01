#include "TestFortranFilters/TestFortranFiltersModule.hh"

#include <COLA.hh>
#include <gtest/gtest.h>

#include <chrono>
#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <string>

using namespace cola;

namespace {
  class TemporaryPath {
   public:
    TemporaryPath() {
      const auto suffix = std::chrono::steady_clock::now().time_since_epoch().count();
      path_ = std::filesystem::temp_directory_path() / ("cola_fortran_writer_" + std::to_string(suffix) + ".txt");
    }

    ~TemporaryPath() {
      std::error_code error;
      std::filesystem::remove(path_, error);
    }

    const std::filesystem::path& Get() const { return path_; }

   private:
    std::filesystem::path path_;
  };
}  // namespace

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
  EXPECT_NEAR(data->ini_state.energy, 1.0, 1e-12);
  ASSERT_EQ(data->particles.size(), 1u);
  EXPECT_EQ(data->particles[0].pdg_code, 2212);

  data = (*conv)(std::move(data));
  ASSERT_NE(data, nullptr);
  EXPECT_NEAR(data->ini_state.energy, 2.0, 1e-12);
  ASSERT_EQ(data->particles.size(), 1u);
  EXPECT_EQ(data->particles[0].pdg_code, 2212);
}

TEST(ColaFortranRegistration, DiscoversEveryTypeInOneSourceFile) {
  auto mod = cola::fortran::TestFortranFiltersModule();
  auto filters = mod.GetModuleFilters();

  ASSERT_NE(filters.find("FirstGenerator"), filters.end());
  ASSERT_NE(filters.find("SecondGenerator"), filters.end());

  auto first_filter = filters["FirstGenerator"]->Create({});
  auto second_filter = filters["SecondGenerator"]->Create({});
  auto* first = dynamic_cast<VGenerator*>(first_filter.get());
  auto* second = dynamic_cast<VGenerator*>(second_filter.get());
  ASSERT_NE(first, nullptr);
  ASSERT_NE(second, nullptr);

  const auto first_data = (*first)();
  const auto second_data = (*second)();
  ASSERT_NE(first_data, nullptr);
  ASSERT_NE(second_data, nullptr);
  EXPECT_NEAR(first_data->ini_state.energy, 1.0, 1e-12);
  EXPECT_NEAR(second_data->ini_state.energy, 2.0, 1e-12);
}

TEST(ColaFortranWriter, WritesEventToTemporaryFile) {
  TemporaryPath output;
  auto mod = cola::fortran::TestFortranFiltersModule();
  auto filters = mod.GetModuleFilters();
  auto generator_filter = filters["FortranGenerator"]->Create({});
  auto writer_filter = filters["FileWriter"]->Create({{"output_file", output.Get().string()}});
  auto* generator = dynamic_cast<VGenerator*>(generator_filter.get());
  auto* writer = dynamic_cast<VWriter*>(writer_filter.get());
  ASSERT_NE(generator, nullptr);
  ASSERT_NE(writer, nullptr);

  (*writer)((*generator)());

  std::ifstream stream(output.Get());
  ASSERT_TRUE(stream.is_open());
  double energy = 0.0;
  stream >> energy;
  EXPECT_NEAR(energy, 1.0, 1e-12);
}

TEST(ColaFortranErrors, PreservesInitializationErrorString) {
  auto mod = cola::fortran::TestFortranFiltersModule();
  auto filters = mod.GetModuleFilters();

  try {
    filters["ErrorGenerator"]->Create({{"error_stage", "init"}});
    FAIL() << "Expected generator creation to fail";
  } catch (const std::runtime_error& error) {
    EXPECT_STREQ(error.what(), "expected Fortran init error");
  }
}

TEST(ColaFortranErrors, PreservesRunErrorString) {
  auto mod = cola::fortran::TestFortranFiltersModule();
  auto filters = mod.GetModuleFilters();
  auto filter = filters["ErrorGenerator"]->Create({{"error_stage", "run"}});
  auto* generator = dynamic_cast<VGenerator*>(filter.get());
  ASSERT_NE(generator, nullptr);

  try {
    (*generator)();
    FAIL() << "Expected generator run to fail";
  } catch (const std::runtime_error& error) {
    EXPECT_STREQ(error.what(), "expected Fortran run error");
  }
}
