#include "StringsProxy.h"
#include <iostream>
#include <string>

using namespace std;

/*extern "C" StringsProxy* create_object(uintptr_t str)
{
  return new StringsProxy(str);
}
extern "C" StringsProxy* create_object(const char* str)
{
  return new StringsProxy(str);
}

extern "C" void destroy_object( StringsProxy* object )
{
  delete object;
}*/
__attribute__((visibility("default")))
extern "C" StringsProxy::StringsProxy(const char* contents)
{
    set_string = std::string(contents);
}
__attribute__((visibility("default")))
extern "C" StringsProxy::StringsProxy(uintptr_t str) {
    set_string = *reinterpret_cast<proxy_string*>(str);
}
__attribute__((visibility("default")))
extern "C" const char* StringsProxy::c_str() {
    return set_string.c_str();
}
__attribute__((visibility("default")))
extern "C" const uintptr_t* StringsProxy::ptr() {
    return reinterpret_cast<uintptr_t *>(&set_string);
}
__attribute__((visibility("default")))
extern "C" StringsProxy::~StringsProxy() {
}