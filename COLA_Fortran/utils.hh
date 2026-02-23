/**
 * Copyright (c) 2024-2025 Alexandr Svetlichnyi, Savva Savenkov, Artemii Novikov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef COLA_FORTRAN_UTIL_HH
#define COLA_FORTRAN_UTIL_HH

#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

#include <COLA.hh>

namespace cola::fortran {
    using FortranParametersMap = std::vector<std::pair<std::string, std::string>>;

    FortranParametersMap ToFortranParametersMap(const std::unordered_map<std::string, std::string>& params);

    template <auto CreateFunc, auto DestroyFunc>
    class GenericFortranFilter {
      public:
        using HandlePtr = std::unique_ptr<void, void (*)(void*)>;

        GenericFortranFilter(const std::unordered_map<std::string, std::string>& params)
            : handle_(ConstructHandle(params)) {}

      protected:
        void* GetHandle() {
            return handle_.get();
        }

        const void* GetHandle() const {
            return handle_.get();
        }

      private:
        static HandlePtr ConstructHandle(const std::unordered_map<std::string, std::string>& params) {
            auto fortranParams = ToFortranParametersMap(params);
            return HandlePtr(CreateFunc(&fortranParams), DestroyFunc);
        }

        HandlePtr handle_;
    };

    template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
    class GenericFortranGenerator: GenericFortranFilter<CreateFunc, DestroyFunc>, public cola::VGenerator {
      public:
        GenericFortranGenerator(const std::unordered_map<std::string, std::string>& params)
            : GenericFortranFilter<CreateFunc, DestroyFunc>(params) {}

        std::unique_ptr<cola::EventData> operator()() override {
            return std::unique_ptr<cola::EventData>(static_cast<EventData*>(RunFunc(this->GetHandle())));
        }
    };

    template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
    class GenericFortranWriter: GenericFortranFilter<CreateFunc, DestroyFunc>, public cola::VWriter {
      public:
        GenericFortranWriter(const std::unordered_map<std::string, std::string>& params)
            : GenericFortranFilter<CreateFunc, DestroyFunc>(params) {}

        void operator()(std::unique_ptr<cola::EventData>&& data) override {
            RunFunc(this->GetHandle(), data.get());
        }
    };

    template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
    class GenericFortranConverter: GenericFortranFilter<CreateFunc, DestroyFunc>, public cola::VConverter {
      public:
        GenericFortranConverter(const std::unordered_map<std::string, std::string>& params)
            : GenericFortranFilter<CreateFunc, DestroyFunc>(params) {}

        std::unique_ptr<cola::EventData> operator()(std::unique_ptr<cola::EventData>&& data) override {
            RunFunc(this->GetHandle(), data.get());
            return data;
        }
    };

} // namespace cola::fortran

#endif // COLA_FORTRAN_UTIL_HH
