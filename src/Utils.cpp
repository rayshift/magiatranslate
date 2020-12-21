#include "Utils.h"
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
#include <sstream>
#include <stdexcept>
#include <errno.h>
#include <error.h>

typedef unsigned long DWORD;

uintptr_t get_libBase(const char* libName) {
    FILE *fp;
    uintptr_t addr = 0;
    char filename[32], buffer[1024];
    snprintf(filename, sizeof(filename), "/proc/%d/maps", getpid());
    fp = fopen(filename, "rt");
    if (fp != NULL) {
        while (fgets(buffer, sizeof(buffer), fp)) {
            if (strstr(buffer, libName)) {
                addr = (uintptr_t) strtoul(buffer, NULL, 16);
                break;
            }
        }
        fclose(fp);
    }
    return addr;
}

std::string get_libFoldername(const char* libName) {
    FILE *fp;
    uintptr_t addr = 0;
    char filename[32], buffer[1024];
    snprintf(filename, sizeof(filename), "/proc/%d/maps", getpid());
    fp = fopen(filename, "rt");
    if (fp != NULL) {
        while (fgets(buffer, sizeof(buffer), fp)) {
            if (strstr(buffer, libName)) {
                std::string delimiter = "/";
                std::string strBuffer = buffer;
                std::string token = strBuffer.substr(strBuffer.find(delimiter), std::string::npos); 
                return token;
                break;
            }
        }
        fclose(fp);
    }
    return "";
}

//uintptr_t getRealOffset(const char* libName, uintptr_t address) {
    //if (libBase == 0) {
        //libBase = get_libBase(libName);
    //}
    //return (libBase + address);
//}

void* lookup_symbol(const char* path, const char* symbolname)
{
    void *imagehandle = dlopen(path, RTLD_GLOBAL | RTLD_NOW);
    if (imagehandle != NULL){
        void * sym = dlsym(imagehandle, symbolname);
        if (sym != NULL){
            return sym;
            }
        else{
            LOGI("(lookup_symbol) dlsym didn't work\n");
            return NULL;
        }
    }
    else{
        LOGI("(lookup_symbol) dlerror: %s\n",dlerror());
        return NULL;
    }
}

bool file_exists (const std::string& name) {
  struct stat buffer;   
  return (stat (name.c_str(), &buffer) == 0); 
}

std::string getJNISignature() {
    return "";
}

std::string getJNISignature(bool) {
    return "Z";
}

std::string getJNISignature(char) {
    return "C";
}

std::string getJNISignature(short) {
    return "S";
}

std::string getJNISignature(int) {
    return "I";
}

std::string getJNISignature(long) {
    return "J";
}

std::string getJNISignature(float) {
    return "F";
}

std::string getJNISignature(double) {
    return "D";
}

std::string getJNISignature(const char*) {
    return "Ljava/lang/String;";
}

std::string getJNISignature(const std::string&) {
    return "Ljava/lang/String;";
}

JNIEnv* getEnv(JavaVM* gJvm) {
    JNIEnv *env;
    int status = gJvm->GetEnv((void**)&env, JNI_VERSION_1_6);
    if(status < 0) {    
        status = gJvm->AttachCurrentThread(&env, NULL);
        if(status < 0) {    
            LOGW("Null JNIEnv obtained!");
            return nullptr;
        }
    }
    return env;
}

jclass findClass(JNIEnv* env, jobject gClassLoader, jmethodID gFindClassMethod, const char* name) {
    return static_cast<jclass>(env->CallObjectMethod(gClassLoader, gFindClassMethod, env->NewStringUTF(name)));
}

std::string longlong_to_string( unsigned long long value ){
    std::ostringstream os;
    os << value;
    return os.str();
}