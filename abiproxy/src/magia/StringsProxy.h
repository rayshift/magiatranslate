#ifndef __STRINGSPROXY_H__
#define __STRINGSPROXY_H__
#include <string>

typedef std::basic_string<char> proxy_string;

class StringsProxy
{
public:
  /* Initialize StringsProxy with a pointer to an existing string */

  StringsProxy(uintptr_t str);
  /* Initialize StringsProxy with a new string */

  StringsProxy(const char* str);
  /* Get C string */

  virtual const char* c_str();
  /* Get pointer to string for injection */

  const virtual uintptr_t* ptr();

  virtual ~StringsProxy();
private:
  proxy_string set_string;
};
#endif