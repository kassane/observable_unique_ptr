#include <oup/observable_unique_ptr.hpp>
#include <array>
#include <string>
#include <memory>

template<typename T>
void use_object(T&) noexcept {}

template void use_object<int>(int&) noexcept;
template void use_object<std::string>(std::string&) noexcept;
template void use_object<std::array<int,65'536>>(std::array<int,65'536>&) noexcept;

template void use_object<int*>(int*&) noexcept;
template void use_object<std::string*>(std::string*&) noexcept;
template void use_object<std::array<int,65'536>*>(std::array<int,65'536>*&) noexcept;

template void use_object<std::unique_ptr<int>>(std::unique_ptr<int>&) noexcept;
template void use_object<std::unique_ptr<std::string>>(std::unique_ptr<std::string>&) noexcept;
template void use_object<std::unique_ptr<std::array<int,65'536>>>(std::unique_ptr<std::array<int,65'536>>&) noexcept;

template void use_object<std::shared_ptr<int>>(std::shared_ptr<int>&) noexcept;
template void use_object<std::shared_ptr<std::string>>(std::shared_ptr<std::string>&) noexcept;
template void use_object<std::shared_ptr<std::array<int,65'536>>>(std::shared_ptr<std::array<int,65'536>>&) noexcept;

template void use_object<std::weak_ptr<int>>(std::weak_ptr<int>&) noexcept;
template void use_object<std::weak_ptr<std::string>>(std::weak_ptr<std::string>&) noexcept;
template void use_object<std::weak_ptr<std::array<int,65'536>>>(std::weak_ptr<std::array<int,65'536>>&) noexcept;

template void use_object<oup::observable_unique_ptr<int>>(oup::observable_unique_ptr<int>&) noexcept;
template void use_object<oup::observable_unique_ptr<std::string>>(oup::observable_unique_ptr<std::string>&) noexcept;
template void use_object<oup::observable_unique_ptr<std::array<int,65'536>>>(oup::observable_unique_ptr<std::array<int,65'536>>&) noexcept;

template void use_object<oup::observable_sealed_ptr<int>>(oup::observable_sealed_ptr<int>&) noexcept;
template void use_object<oup::observable_sealed_ptr<std::string>>(oup::observable_sealed_ptr<std::string>&) noexcept;
template void use_object<oup::observable_sealed_ptr<std::array<int,65'536>>>(oup::observable_sealed_ptr<std::array<int,65'536>>&) noexcept;

template void use_object<oup::observer_ptr<int>>(oup::observer_ptr<int>&) noexcept;
template void use_object<oup::observer_ptr<std::string>>(oup::observer_ptr<std::string>&) noexcept;
template void use_object<oup::observer_ptr<std::array<int,65'536>>>(oup::observer_ptr<std::array<int,65'536>>&) noexcept;
