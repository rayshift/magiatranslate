#ifndef MAGIAREST_H
#define MAGIAREST_H
#include <jni.h>
#include <nlohmann/json.hpp>
#include <string.h>

using json = nlohmann::json;

#define MAGIAREST_EMPTY   0
#define MAGIAREST_SUCCESS    1
#define MAGIAREST_ERROR 2

// Rest class using JNI
class MagiaRest {
    public:
        MagiaRest(JavaVM* gJvm);

        int Endpoint();

        size_t EndpointStringLength();

        std::string GetEndpointUrl();

        std::string GetEndpointError();
        int GetEndpointVersion();

        int GetMaxThreads();

        ~MagiaRest();
    private:
        JNIEnv* env;
        jclass klass;
        jobject magiaRestObj;

        jstring endpointJString = NULL;
        const char *endpointChar = NULL;

        bool endpointValid = false;
        json endpointJson = NULL;

};

#endif