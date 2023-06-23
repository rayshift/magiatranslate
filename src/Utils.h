#ifndef UTILS_H
#define UTILS_H

#include <jni.h>
#include <unistd.h>
#include <cstdint>
#include <android/log.h>
#include <dlfcn.h>
#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>
#include <string>
#include <memory>
#include <stdexcept>

#ifdef NDEBUG
#define RELEASE_BUILD
#else
#define DEBUG_BUILD
#endif

#ifdef DEBUG_BUILD
#define LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG, "MagiaHook", __VA_ARGS__)
#else 
#define LOGD(...)  do {} while(false)
#endif
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO, "MagiaHook", __VA_ARGS__)
#define LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, "MagiaHook", __VA_ARGS__)
#define LOGW(...)  __android_log_print(ANDROID_LOG_WARN, "MagiaHook", __VA_ARGS__)

typedef unsigned long DWORD;

uintptr_t get_libBase(const char* libName);

std::string get_libFoldername(const char* libName);

void* lookup_symbol(const char* path, const char* symbolname);

bool file_exists (const std::string& name);

std::string getJNISignature();
std::string getJNISignature(bool);
std::string getJNISignature(char);
std::string getJNISignature(short);
std::string getJNISignature(int);
std::string getJNISignature(long);
std::string getJNISignature(float);
std::string getJNISignature(double);
std::string getJNISignature(const char*);
std::string getJNISignature(const std::string&);

template <typename T>
std::string getJNISignature(T x) {
    // This template should never be instantiated
    static_assert(sizeof(x) == 0, "Unsupported argument type");
    return "";
}

template <typename T, typename... Ts>
std::string getJNISignature(T x, Ts... xs) {
    return getJNISignature(x) + getJNISignature(xs...);
}


JNIEnv* getEnv(JavaVM* gJvm);
jclass findClass(JNIEnv* env, jobject gClassLoader, jmethodID gFindClassMethod, const char* name);

// https://stackoverflow.com/a/26221725/9665729
template<typename ... Args>
std::string string_format( const std::string& format, Args ... args )
{
    size_t size = snprintf( nullptr, 0, format.c_str(), args ... ) + 1; // Extra space for '\0'
    if( size <= 0 ){ throw std::runtime_error( "Error during formatting." ); }
    std::unique_ptr<char[]> buf( new char[ size ] ); 
    snprintf( buf.get(), size, format.c_str(), args ... );
    return std::string( buf.get(), buf.get() + size - 1 ); // We don't want the '\0' inside
}

std::string longlong_to_string( unsigned long long value );
#endif
