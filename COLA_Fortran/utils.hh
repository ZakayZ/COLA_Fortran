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
 
 #include <cstdlib>
 #include <memory>
 #include <stdexcept>
 #include <string>
 #include <unordered_map>
 #include <vector>
 
 #include <COLA.hh>
 
 namespace cola::fortran {
     using FortranParametersMap = std::vector<std::pair<std::string, std::string>>;
 
     FortranParametersMap ToFortranParametersMap(const std::unordered_map<std::string, std::string>& params);
 
     template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
     class GenericFortranFilter {
       public:
         using HandlePtr = std::unique_ptr<void, void (*)(void*)>;
         using ErrorPtr = std::unique_ptr<char, decltype(&std::free)>;
 
         GenericFortranFilter(const std::unordered_map<std::string, std::string>& params)
             : handle_(ConstructHandle(params)) {}
 
       protected:
         void* GetHandle() {
             return handle_.get();
         }
 
         const void* GetHandle() const {
             return handle_.get();
         }
 
         static void ThrowOnError(char* errRaw, const char* fallback) {
             auto err = ErrorPtr(errRaw, &std::free);
             if (err != nullptr) {
                 throw std::runtime_error(ErrorOrDefault(err.get(), fallback));
             }
         }
 
       private:
         static std::string ErrorOrDefault(const char* err, const char* fallback) {
             if (err != nullptr) {
                 return std::string(err);
             }
             return std::string(fallback);
         }
 
         static HandlePtr ConstructHandle(const std::unordered_map<std::string, std::string>& params) {
             auto fortranParams = ToFortranParametersMap(params);
             char* errRaw = nullptr;
             auto handle = HandlePtr(CreateFunc(&fortranParams, &errRaw), DestroyFunc);
 
             ThrowOnError(errRaw, "Fortran init failed");
             if (handle == nullptr) {
                 throw std::runtime_error("Fortran init failed");
             }
             return handle;
         }
 
         HandlePtr handle_;
     };
 
     template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
     class GenericFortranGenerator: GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>, public cola::VGenerator {
       public:
         GenericFortranGenerator(const std::unordered_map<std::string, std::string>& params)
             : GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>(params) {}
 
         std::unique_ptr<cola::EventData> operator()() override {
             static const auto DefaultErrorMessage = "Fortran run failed";
 
             char* errRaw = nullptr;
             auto data = std::unique_ptr<cola::EventData>(static_cast<EventData*>(RunFunc(this->GetHandle(), &errRaw)));
             this->ThrowOnError(errRaw, DefaultErrorMessage);
             if (data == nullptr) {
                 throw std::runtime_error(DefaultErrorMessage);
             }
             return data;
         }
     };
 
     template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
     class GenericFortranWriter: GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>, public cola::VWriter {
       public:
         GenericFortranWriter(const std::unordered_map<std::string, std::string>& params)
             : GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>(params) {}
 
         void operator()(std::unique_ptr<cola::EventData>&& data) override {
             static const auto DefaultErrorMessage = "Fortran run failed";
 
             char* errRaw = nullptr;
             RunFunc(this->GetHandle(), data.get(), &errRaw);
 
             this->ThrowOnError(errRaw, DefaultErrorMessage);
         }
     };
 
     template <auto CreateFunc, auto DestroyFunc, auto RunFunc>
     class GenericFortranConverter: GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>, public cola::VConverter {
       public:
         GenericFortranConverter(const std::unordered_map<std::string, std::string>& params)
             : GenericFortranFilter<CreateFunc, DestroyFunc, RunFunc>(params) {}
 
         std::unique_ptr<cola::EventData> operator()(std::unique_ptr<cola::EventData>&& data) override {
             static const auto DefaultErrorMessage = "Fortran run failed";
 
             char* errRaw = nullptr;
             RunFunc(this->GetHandle(), data.get(), &errRaw);
             this->ThrowOnError(errRaw, DefaultErrorMessage);
             return data;
         }
     };
 
 } // namespace cola::fortran
 
 #endif // COLA_FORTRAN_UTIL_HH
 