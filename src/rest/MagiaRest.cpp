#include <jni.h>
#include "../Utils.h"
#include "../Config.h"
#include <nlohmann/json.hpp>
#include <string.h>
#include <string>
#include "MagiaRest.h"

const char* restClient = "io/kamihama/magianative/RestClient";
using json = nlohmann::json;

MagiaRest::MagiaRest(JavaVM* gJvm) {
    LOGD("Setting up MagiaRest.");
    env = getEnv(gJvm);
    klass = env->FindClass(restClient);
    jmethodID clientCtor = env->GetMethodID(klass, "<init>", "()V");
    magiaRestObj = env->NewObject(klass, clientCtor);
    LOGD("Finished setting up MagiaRest.");
}

int MagiaRest::Endpoint() {
    const char* callHandshake = "GetEndpoint";
    std::string signature = "(I)Ljava/lang/String;";
    jmethodID messageid = env->GetMethodID(klass, callHandshake, signature.c_str());

    LOGD("Calling GetEndpoint via JNI.");
    endpointJString = (jstring)env->CallObjectMethod(magiaRestObj, messageid, MT_VERSION);
    endpointChar = env->GetStringUTFChars(endpointJString, 0);

    if (strcmp(endpointChar, "") == 0) {
        LOGW("Null response returned from endpoint, an error has occurred, or Kamihama is down.");
        return MAGIAREST_EMPTY;
    }
    LOGD("Successfully retrieved Endpoint JSON.");

    if (json::accept(endpointChar)) {
        endpointValid = true;
        endpointJson = json::parse(endpointChar);

        if (endpointJson["status"] != 200) {
            LOGW("Non-success result returned.");
            return MAGIAREST_ERROR;
        }
    }
    return endpointValid ? MAGIAREST_SUCCESS : MAGIAREST_EMPTY;
}

size_t MagiaRest::EndpointStringLength() {
    if (endpointChar == NULL) {
        return MAGIAREST_EMPTY;
    }
    else {
        auto size = std::strlen(endpointChar);
        return size;
    }
}

std::string MagiaRest::GetEndpointUrl() {
    if (endpointJson != NULL && endpointJson.contains("response") && endpointJson["response"].contains("endpoint")) {
        return endpointJson["response"]["endpoint"];
    }
    LOGW("No endpoint URL found in JSON response.");
    return "";
}

std::string MagiaRest::GetEndpointError() {
    if (endpointJson != NULL && endpointJson.contains("message")) {
        return endpointJson["message"];
    }
    LOGW("No message found in JSON response.");
    return "";
}
int MagiaRest::GetEndpointVersion() {
    if (endpointJson != NULL && endpointJson.contains("response") && endpointJson["response"].contains("version")) {
        return (int)endpointJson["response"]["version"];
    }
    LOGW("No version number found in JSON response.");
    return 0;
}

int MagiaRest::GetMaxThreads() {
    if (endpointJson != NULL && endpointJson.contains("response") && endpointJson["response"].contains("max_threads")) {
        return (int)endpointJson["response"]["max_threads"];
    }
    LOGW("No version number found in JSON response.");
    return 0;
}

MagiaRest::~MagiaRest() {
    if (endpointJString != NULL || endpointChar != NULL) {
        env->ReleaseStringUTFChars(endpointJString, endpointChar);
    }
}