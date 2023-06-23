#include <jni.h>
#include <cstdint>
#include <android/log.h>
#include <dobby.h>
#include <memory.h>
#include <dlfcn.h>
#include <cstdio>
#include <cstdlib>
#include "Utils.h"
#include <string>
#include <thread>
#include <pthread.h>
#include <string.h>
#include <libgen.h>
#include "Config.h"
#include <cocos2d.h>
#include "libmadomagi.h"
#include "rest/MagiaRest.h"

const char* libName = "libmadomagi_native.so";
const char* hookName = "libuwasa.so";

JavaVM* gJvm = nullptr;
static jobject gClassLoader;
static jmethodID gFindClassMethod;
uintptr_t libBase = 0;

//namespace fs = std::filesystem; ndk 22+ required

struct hook_loop_args {
    std::string libso;
};

uintptr_t storyMessageUnitStartOffset = 0;
uintptr_t storyMessageUnitCreateMessageAreaOffset = 0;
uintptr_t storyLogUnitAddMessageOffset = 0;
uintptr_t storyLogUnitAddNarrationOffset = 0;
uintptr_t storyCharaUnitonTextHomeOffset = 0;
uintptr_t storyNarrationUnitCreateLabelOffset = 0;
uintptr_t initCenterWidthOutline = 0;

int max_threads = 10;

void* openMessageBoxPtr = nullptr;
uintptr_t* resourceUrlPtr = nullptr;

bool initialized = false;

const std::string assetBase = "/magica/resource";
const std::string assetTrunk = "/download/asset/master";
const std::string assetScenario = "/resource/scenario";
std::vector<std::shared_ptr<std::string>> urlEndpoints(3);

const std::string koruriFont("fonts/koruri-semibold.ttf");

typedef int *(*setUrlType)(int *);
typedef int *(*setResourceType)(int *, unsigned int *);
typedef uintptr_t *(*UrlConfigImplResourceType)(uintptr_t &a1, int a2, unsigned int a3, int a4);

// Hooked functions
void *(*setPositionHooked)(uintptr_t label, cocos2d::Vec2 const& position);
void *(*setMaxLineWidthHooked)(uintptr_t label, float length);
void *(*setDimensionsHooked)(uintptr_t label, float width, float a3);

const std::string* (*urlConfigResourceHooked)(void* a1, UrlConfigResourceType type); // There is also api, chat, web, etc for other endpoints

//void* urlConfig_ImplObj = nullptr;

// Cocos functions
typedef cocos2d::Director* (*director_type)(void* dummy);
typedef const cocos2d::Size& (*get_win_size_type)(cocos2d::Director* director);
typedef cocos2d::Vec2 (*get_visible_origin_type)(cocos2d::Director* director);

director_type getDirector;
get_win_size_type getWinSize;
get_visible_origin_type getVisibleOrigin;

/* BROKEN
void testDialogue() {
    if (openMessageBoxPtr != nullptr) {
        auto x = DialogueBoxProxy();
        x.DialogueBox(openMessageBoxPtr);
    }
}*/
jclass findClass(JNIEnv* env, const char* name) {
    return static_cast<jclass>(env->CallObjectMethod(gClassLoader, gFindClassMethod, env->NewStringUTF(name)));
}

void displayMessage(const std::string& title, const std::string& description) {
    auto env = getEnv(gJvm);
    const char* cocosHelper = "org/cocos2dx/lib/Cocos2dxHelper";
    const char* showDialogueBox = "showDialog";
    std::string signature = "(" + std::string(getJNISignature(title, description)) + ")V";

    jclass klass = findClass(env, cocosHelper);
    if (klass == nullptr) {
        LOGE("No Cocos2dxHelper found.");
        return;
    }

    jmethodID mid = env->GetStaticMethodID(klass, showDialogueBox, signature.c_str());
    if (mid == nullptr) {
        LOGE("No showDialog found.");
        return;
    }
    jstring str1 = env->NewStringUTF(title.c_str());
    jstring str2 = env->NewStringUTF(description.c_str());
    env->CallStaticObjectMethod(klass, mid, str1, str2);
}

int *(*sceneLayerManagerCreateSceneLayerOld)(uintptr_t *sceneLayerManager, BaseSceneLayerInfo* sceneLayerInfo);

int *sceneLayerManagerCreateSceneLayer(uintptr_t *sceneLayerManager, BaseSceneLayerInfo* sceneLayerInfo) {
    auto sceneType = sceneLayerInfo->layerType;
    if (sceneType >= BaseSceneLayerType::BaseSceneLayerTypeMaxValue || sceneType < 0) {
        LOGW("Unknown scene triggered. %d", sceneType);
    }
    else {
        LOGI("Scene layer changed to: %s", BaseSceneLayerTypeStrings[sceneType]);
    }

    if (!initialized && sceneType == BaseSceneLayerType::WebSceneLayer) { // Set up everything here
        auto rest = MagiaRest(gJvm);
        switch(rest.Endpoint()) {
            case MAGIAREST_EMPTY:
            {
                auto emptyMessage = string_format("Unable to connect to the translation server. Restart the app to retry, or continue to play in Japanese. (Response length: %zu)", 
                rest.EndpointStringLength());

                displayMessage("MagiaTranslate Error", emptyMessage.c_str());
                break;
            }
            case MAGIAREST_ERROR:
            {
                auto errorMessage = string_format("An error has occurred. Restart the app to retry, or continue to play in Japanese.\nError: %s", rest.GetEndpointError().c_str());
                displayMessage("MagiaTranslate Error", errorMessage.c_str());
                break;
            }
            case MAGIAREST_SUCCESS:
            {
                auto ver = rest.GetEndpointVersion();
                if (MT_VERSION < ver) {
                    LOGI("Version update required.");
                    auto updateMessage = string_format("A new version of MagiaTranslate is available, please update your app at kamihama.io. Continuing may result in crashes.\nApp version installed: %d\nApp version available: %d",
                    MT_VERSION, ver);
                    displayMessage("MagiaTranslate Update", updateMessage.c_str());
                }
                auto endpointUrl = rest.GetEndpointUrl();
                if (endpointUrl.empty()) {
                    LOGW("Empty endpoint URL.");
                    displayMessage("MagiaTranslate Error", "Error 115 has occurred, the returned translate endpoint URL is empty, please try again later.");
                    break;
                }

                // Set max download threads
                auto mt = rest.GetMaxThreads();
                if (mt > 0) {
                    LOGD("Set maximum threads from API, value %d.", mt);
                    max_threads = mt;
                }

                const std::string assetNameBase = endpointUrl + assetBase;
                const std::string assetNameFull = endpointUrl + assetBase + assetTrunk;
                const std::string assetNameScript = endpointUrl + assetBase + assetTrunk + assetScenario;

                //std::string assetNameBaseProxy(assetNameBase.c_str());
                //std::string assetNameFullProxy(assetNameFull.c_str());
                //std::string assetNameScriptProxy(assetNameScript.c_str());

                LOGD("Setting endpoint URLs.");
                LOGD("%s", assetNameScript.c_str());

                urlEndpoints.at(UrlConfigResourceType::BaseUrl) = std::make_shared<std::string>(assetNameBase);
                urlEndpoints.at(UrlConfigResourceType::TrunkUrl) = std::make_shared<std::string>(assetNameFull);
                urlEndpoints.at(UrlConfigResourceType::ScenarioUrl) = std::make_shared<std::string>(assetNameScript);
                LOGD("Finished setting endpoint URLs.");
                break;
            }
        }

        initialized = true;
        auto y = sceneLayerManagerCreateSceneLayerOld(sceneLayerManager, sceneLayerInfo);
        return y;
    }

    return sceneLayerManagerCreateSceneLayerOld(sceneLayerManager, sceneLayerInfo);
    
}

// Change function to fetch resource URLs
const std::string* urlConfigResource(void* a1, UrlConfigResourceType type) {
    LOGD("Fetching URL config resource %d", (int)type);
    if (type < UrlConfigResourceType::UrlConfigResourceTypeMaxValue) {
        try {
            if (urlEndpoints.at(type) != nullptr && urlEndpoints.at(type).get() != nullptr) {
                auto url = (urlEndpoints.at(type)).get();
                LOGD("URL: %s", url->c_str());
                return url;
            }
            else {
                LOGW("Empty endpoint found for endpoint type %d!", (int)type);
            }
        }
        catch (std::out_of_range const& exc) {
            LOGW("Out of range for endpoint type %d!", (int)type);
        }
    }
    return urlConfigResourceHooked(a1, type);
}


void* (*cocosCreateLabelHooked)(const uintptr_t* textPtr, const std::string &fontPtr, float textSize, cocos2d::Size const& cocosSize, cocos2d::TextHAlignment hAlign, cocos2d::TextVAlignment vAlign);
void* cocosCreateLabel(const uintptr_t* textPtr, const std::string &fontPtr, float textSize, cocos2d::Size const& cocosSize, cocos2d::TextHAlignment hAlign, cocos2d::TextVAlignment vAlign) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(__builtin_extract_return_addr(__builtin_return_address(0)));
    LOGD("Label created at %p (%p), size %.1f.", (void*) addr, (void*)(addr - libBase), textSize);
    if (storyMessageUnitCreateMessageAreaOffset != 0 && addr >= storyMessageUnitCreateMessageAreaOffset) {
        uintptr_t difference = addr - storyMessageUnitCreateMessageAreaOffset;
        if (difference <= 0x200) {
            LOGD("Setting new text font for main story text.");
            if (textSize == 27.0) {
                textSize = 30.0;
            }
            return cocosCreateLabelHooked(textPtr, koruriFont, textSize, cocosSize, hAlign, vAlign);
        }
    }
    if (storyNarrationUnitCreateLabelOffset != 0 && addr >= storyNarrationUnitCreateLabelOffset) {
        uintptr_t difference = addr - storyNarrationUnitCreateLabelOffset;

        if (difference <= 0x200) { // 0x8e
            LOGD("Setting new narration text font. Difference: %p", (void*)difference);
            return cocosCreateLabelHooked(textPtr, koruriFont, textSize, cocosSize, hAlign, vAlign);
        }
    }
    if (initCenterWidthOutline != 0 && addr >= initCenterWidthOutline) {
        uintptr_t difference = addr - initCenterWidthOutline;

        if (difference <= 0x200) {
            LOGD("Setting new home text font and size.");
            textSize = textSize * 0.85;
            return cocosCreateLabelHooked(textPtr, koruriFont, textSize, cocosSize, hAlign, vAlign);
        }
    }
    if (storyLogUnitAddMessageOffset != 0 && addr >= storyLogUnitAddMessageOffset) {
        uintptr_t difference = addr - storyLogUnitAddMessageOffset;

        if (difference <= 0x640) { // 0xec, 0x54e
            LOGD("Setting new log text font. Difference: %p", (void*)difference);
            return cocosCreateLabelHooked(textPtr, koruriFont, textSize, cocosSize, hAlign, vAlign);
        }
    }
    if (storyLogUnitAddNarrationOffset != 0 && addr >= storyLogUnitAddNarrationOffset) {
        uintptr_t difference = addr - storyLogUnitAddNarrationOffset;
        if (difference <= 0x640) { // 0x43e, 0x5b0
            LOGD("Setting new log text font (narration). Difference: %p", (void*)difference);
            return cocosCreateLabelHooked(textPtr, koruriFont, textSize, cocosSize, hAlign, vAlign);
        }
    }
    return cocosCreateLabelHooked(textPtr, fontPtr, textSize, cocosSize, hAlign, vAlign);

}

// New functions
void *setPositionNew(uintptr_t label, cocos2d::Vec2 const& position) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(__builtin_extract_return_addr(__builtin_return_address(0)));
    //LOGI("Move at %p to x: %.2f, y: %.2f", (addr - libBase), position.x, position.y);
    
    // Story message boxes
    if (storyMessageUnitStartOffset != 0 && addr >= storyMessageUnitStartOffset) {
        uintptr_t difference = addr - storyMessageUnitStartOffset;
        
        // Alignment of main text in box
        if (difference <= 0x200) { // Offset = 0x76 as of 2.15
            LOGD("Moving story text.");
            //LOGI("Difference: %p", difference);
            //LOGD("old [message] x: %.2f, y: %.2f", position.x, position.y);
            
            // Move text to the left and up a bit
            if (position.x == -222.0 && position.y == 20.0) {
                cocos2d::Vec2 newPosition = cocos2d::Vec2(-368.0, 25.0);
                //LOGD("new 1 x: %.2f, y: %.2f", newPosition.x, newPosition.y);
                return setPositionHooked(label, newPosition);
            }
            else if (position.x == -207.0 && position.y == 30.0) {
                cocos2d::Vec2 newPosition = cocos2d::Vec2(-360.0, 40.0);
                //LOGD("new 2 x: %.2f, y: %.2f", newPosition.x, newPosition.y);
                return setPositionHooked(label, newPosition);
            }
        }
        
    }  

    
    // Names alignment
    if (storyMessageUnitCreateMessageAreaOffset != 0 && addr >= storyMessageUnitCreateMessageAreaOffset) {
            
        uintptr_t difference = addr - storyMessageUnitCreateMessageAreaOffset;
        //LOGI("Difference: %p", difference);
        
        // Move names into the right place
        if (difference <= 0x600) { // Offset = 0x35e as of 2.15
            //LOGD("old [name] x: %.2f, y: %.2f", position.x, position.y);
            LOGD("Moving story name.");
            if (position.x == -215.0 && position.y == 57.0) { // Left names
                cocos2d::Vec2 newPosition = cocos2d::Vec2(-320.0, 55.0);
                //LOGD("new l-1 x: %.2f, y: %.2f", newPosition.x, newPosition.y);
                return setPositionHooked(label, newPosition);
            }
            else if (position.x == -55.0 && position.y == 57.0) { // Center names
                cocos2d::Vec2 newPosition = cocos2d::Vec2(30.0, 55.0);
                //LOGD("new m-1 x: %.2f, y: %.2f", newPosition.x, newPosition.y);
                return setPositionHooked(label, newPosition);
            }
            else if (position.x == 215.0 && position.y == 57.0) { // Right names
                cocos2d::Vec2 newPosition = cocos2d::Vec2(320.0, 55.0);
                //LOGD("new r-1 x: %.2f, y: %.2f", newPosition.x, newPosition.y);
                return setPositionHooked(label, newPosition);
            }
        }
        
    }
    
    // History
    if (storyLogUnitAddMessageOffset != 0 && addr >= storyLogUnitAddMessageOffset) {
        uintptr_t difference = addr - storyLogUnitAddMessageOffset;
        LOGD("LOG MESSAGE: %.2f %.2f", position.x, position.y);
        LOGD("Difference: %p", (void *)difference);
        //if (position.y >= 55.50 && position.y <= 56.50 && difference <= 0x1000) {
        if ((position.y >= 37.5 && position.y <= 39.5 && difference <= 0x1300)
        || (position.y >= 55.00 && position.y <= 56.00 && difference <= 0x1300)) {
            float newPosX = position.x + 125.0;
            LOGD("Moved log text from %.2f to %.2f", position.x, newPosX);
            cocos2d::Vec2 newPosition = cocos2d::Vec2(newPosX, 66.50);
            return setPositionHooked(label, newPosition);
        }
        else if (difference <= 0x400 && position.x == 70.00) {
            LOGD("Moving left-aligned name down in the log.");
            auto newY = position.y;
            cocos2d::Vec2 newPosition = cocos2d::Vec2(position.x, newY);
            return setPositionHooked(label, newPosition);
        }
        else if (difference <= 0x400 && position.x == 500.00) { // Names on the right
            LOGD("Moving name further to the right in log.");
            auto newX = position.x + 200;
            //auto newY = position.y - 15.0;
            auto newY = position.y;
            cocos2d::Vec2 newPosition = cocos2d::Vec2(newX, newY);
            return setPositionHooked(label, newPosition);
        }
        else if (difference <= 0x400 && position.x == 280.00) { // Names in the center, 280.00?
            LOGD("Moving center name to the left in the log.");
            auto newX = 71.50;
            auto newY = position.y;
            cocos2d::Vec2 newPosition = cocos2d::Vec2(newX, newY);
            return setPositionHooked(label, newPosition);
        }
    }
    return setPositionHooked(label, position);
}

void *setMaxLineWidthNew(uintptr_t label, float length) {
    //LOGI("Hook triggered - line length");
    uintptr_t addr = reinterpret_cast<uintptr_t>(__builtin_extract_return_addr(__builtin_return_address(0)));
    //LOGI("%p", (addr - libBase));
    
    if (storyMessageUnitCreateMessageAreaOffset != 0 && addr >= storyMessageUnitCreateMessageAreaOffset) {
        uintptr_t difference = addr - storyMessageUnitCreateMessageAreaOffset;
        //LOGI("Difference: %p", difference);
        
        // Make lines longer
        if (difference <= 0x244 && length == 410.0) { // Offset = 0x144 as of 2.15
            LOGD("Set line length from 410.0 to 810.0");
            length = 810.0;
        }
    }
    return setMaxLineWidthHooked(label, length);
}

void *setDimensionsNew(uintptr_t label, float width, float height) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(__builtin_extract_return_addr(__builtin_return_address(0)));
    uintptr_t difference = addr - storyLogUnitAddMessageOffset;
    //LOGI("Difference [dimensions]: %p, addr: %p", difference, addr);
    
    if (storyLogUnitAddMessageOffset != 0 && addr >= storyLogUnitAddMessageOffset) {
        //LOGI("%p, %.2f, %.2f", label, width, a3);
        if (difference <= 0x900 && width == 410.0) { // Offset = 0x5ac as of 2.15
            LOGD("Set dimensions for log from 410.0 to 710.0.");
            return setDimensionsHooked(label, 710.0, height);
        }            
    }
    //LOGD("Dimensions: %f, %f", width, height);
    return setDimensionsHooked(label, width, height);
}

// Fix the position of homeText under live2d girls
cocos2d::Size (*lbGetViewPositionHooked)(float x, float y);
cocos2d::Size lbGetViewPositionNew(float x, float y) {
    uintptr_t addr = reinterpret_cast<uintptr_t>(__builtin_extract_return_addr(__builtin_return_address(0)));
    uintptr_t difference = addr - storyCharaUnitonTextHomeOffset;
    //LOGD("Difference (viewPos): %p, addr: %p", (void*)difference, (void*)addr);
    
    if (storyCharaUnitonTextHomeOffset != 0 && addr >= storyCharaUnitonTextHomeOffset) {      
        if (difference <= 0x1300) {
            auto oldx = x;
            auto oldy = y;
            if (x > -100.0) {
                x = -120.0;
            }
            if (x == -100.0) {
                x = -250.0;
            }
            x = x - 30.0;
            y = y - 30.0;
            LOGD("Set live2d subtitle dimensions from (%f, %f) to (%f, %f).", oldx, oldy, x, y);
        }
    }

#if defined(__aarch64__)
    return lbGetViewPositionHooked(x, y);
#endif
    //LOGI("Size 1: %f, size 2: %f", sizes.width, sizes.height);            

    // Reimplement from scratch because arm is bugged (also this segfaults on arm64)
    auto director = getDirector((void *)0x00);
    //LOGI("Obtained director at %p.", (void*) director);

    auto dirSize = getWinSize(director);
    //LOGI("Obtained winsize, %f %f.", dirSize.width, dirSize.height);
    auto origin = getVisibleOrigin(director);
    //LOGI("Obtained visible origin, %f %f.", origin.x, origin.y);
    auto sizes = cocos2d::Size();
    sizes.width = origin.x + x + (float)dirSize.width * 0.5;
    sizes.height = origin.y + y + (float)dirSize.height * 0.5;
    //sizes.width = origin.x + x + (float)dirSize.width * 0.5;
    //sizes.height = origin.y + y + (float)dirSize.height * 0.5;

    //LOGI("NEW size 1: %f, size 2: %f", sizes.width, sizes.height);  
    return sizes;
}


pthread_mutex_t *(*setUriDebugOld)(uintptr_t a1, const std::string &st);
pthread_mutex_t *setUriDebug(uintptr_t a1, const std::string &stri) {
    auto mut = setUriDebugOld(a1, stri);

    auto outstr = stri.c_str();
    LOGI("Uri base set: %s", outstr);
    return mut;
}

pthread_mutex_t *(*http2SessionSetMaxConnectionNumOld)(uintptr_t *session, int max);

pthread_mutex_t *http2SessionSetMaxConnectionNum(uintptr_t *session, int max) {
    if (max == 4) {
        max = max_threads;
    }
    LOGD("Set max number of connections to %d.", max);
    return http2SessionSetMaxConnectionNumOld(session, max);
}

uint32_t (*criNcv_GetHardwareSamplingRate_ANDROID_Hooked)();

uint32_t criNcv_GetHardwareSamplingRate_ANDROID() {
    auto value = criNcv_GetHardwareSamplingRate_ANDROID_Hooked();
    if (value == 44100) {
        return 48000;
    }
    return value;
}

void initialization_error(const char* error) {
    LOGE("%s", error);
    auto errorMsg = string_format("A critical error has occurred, MagiaTranslate will not work properly and may crash. Please report this error on GitHub or Discord.\n%s", error);
    displayMessage("MagiaTranslate Error", errorMsg);
}

// Hook loop function. We run this in a separate thread so it doesn't block the main thread.
void *hook_loop(void *arguments) {
    std::unique_ptr<hook_loop_args> args((struct hook_loop_args *)arguments);
    auto libLocation = (args->libso).c_str();

    LOGI("Library location: %s", libLocation);

    while(libBase == 0) { 
        libBase = get_libBase(libName); 
    }   
    LOGI("Base address: %p", (void*)libBase);
   
    // Hook resource endpoint
    void *resourceHook = lookup_symbol(libLocation, "_ZNK9UrlConfig8resourceENS_8Resource4TypeE"); // UrlConfig::resource(UrlConfig::Resource::Type)const
    if (DobbyHook(resourceHook, (void *)urlConfigResource, (void **)&urlConfigResourceHooked) == RS_SUCCESS) {
        LOGI("Successfully hooked UrlConfig::resource.");
    }
    else {
        initialization_error("Failed to hook UrlConfig::resource.");
        pthread_exit(NULL);
    }


    // Hook scene creator
    void *sceneHook = lookup_symbol(libLocation, "_ZN17SceneLayerManager16createSceneLayerEP18BaseSceneLayerInfo"); //_DWORD __fastcall SceneLayerManager::createSceneLayer(SceneLayerManager *__hidden this, BaseSceneLayerInfo *)
    if (DobbyHook(sceneHook, (void *)sceneLayerManagerCreateSceneLayer, (void **)&sceneLayerManagerCreateSceneLayerOld) == RS_SUCCESS) {
        LOGI("Successfully hooked SceneLayerManager::createSceneLayer.");
    }
    else {
        initialization_error("Failed to hook SceneLayerManager::createSceneLayer.");
        pthread_exit(NULL);
    }

    // Speed up downloads
    void *maxDlHook = lookup_symbol(libLocation, "_ZN5http212Http2Session19setMaxConnectionNumEi"); //_DWORD __fastcall http2::Http2Session::setMaxConnectionNum(http2::Http2Session *__hidden this, int)
    if (DobbyHook(maxDlHook, (void *)http2SessionSetMaxConnectionNum, (void **)&http2SessionSetMaxConnectionNumOld) == RS_SUCCESS) {
        LOGI("Successfully hooked http2::Http2Session::setMaxConnectionNum.");
    }
    else {
        LOGW("Failed to hook http2::Http2Session::setMaxConnectionNum.");
    }


    //openMessageBoxPtr = lookup_symbol(libLocation, "_ZN10MessageBox4openEPKcS1_S1_RKSt8functionIFvPN7cocos2d3RefEEEb");
    //LOGI("Set openMessageBox ptr to %p", openMessageBoxPtr);
    
    // For debugging
    //DobbyHook(lookup_symbol(libLocation, "_ZN5http212Http2Session6setURIERKSs"), (void *)setUriDebug, (void **)&setUriDebugOld); - crashes arm32 now.

    // speed fix
    void *audioSampleRateFix = lookup_symbol(libLocation, "criNcv_GetHardwareSamplingRate_ANDROID");

    if (audioSampleRateFix != nullptr) {
        LOGD("Found criNcv_GetHardwareSamplingRate_ANDROID at %p.", (void *)audioSampleRateFix);
        if (DobbyHook(audioSampleRateFix, (void *)criNcv_GetHardwareSamplingRate_ANDROID, (void **)&criNcv_GetHardwareSamplingRate_ANDROID_Hooked) == RS_SUCCESS) {
            LOGI("Successfully hooked criNcv_GetHardwareSamplingRate_ANDROID.");
        }
        else {
            initialization_error("Unable to hook criNcv_GetHardwareSamplingRate_ANDROID.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook criNcv_GetHardwareSamplingRate_ANDROID.");
        pthread_exit(NULL);
    }
    

    // Hooks
    void *cocos2dnodeSetPosition = lookup_symbol(libLocation, "_ZN7cocos2d4Node11setPositionERKNS_4Vec2E"); 
    // cocos2d::Node::setPosition(cocos2d::Vec2 const&)    
    if (cocos2dnodeSetPosition != nullptr) {
        LOGD("Found cocos2d::Node::setPosition at %p.", (void *)cocos2dnodeSetPosition);
        if (DobbyHook(cocos2dnodeSetPosition, (void *)setPositionNew, (void **)&setPositionHooked) == RS_SUCCESS) {
            LOGI("Successfully hooked cocos2d::Node::setPosition.");
        }
        else {
            initialization_error("Unable to hook cocos2d::Node::setPosition.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook cocos2d::Node::setPosition.");
        pthread_exit(NULL);
    }
    
    void *cocos2dlineLength = lookup_symbol(libLocation, "_ZN7cocos2d5Label15setMaxLineWidthEf"); 
    // cocos2d::Label::setMaxLineWidth(float)
    if (cocos2dlineLength != nullptr) {
        LOGD("Found cocos2d::Label::setMaxLineWidth at %p.", (void *)cocos2dlineLength);
        if (DobbyHook(cocos2dlineLength, (void *)setMaxLineWidthNew, (void **)&setMaxLineWidthHooked)  == RS_SUCCESS) {
            LOGI("Successfully hooked cocos2d::Label::setMaxLineWidth.");
        }
        else {
            initialization_error("Unable to hook cocos2d::Label::setMaxLineWidth.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook cocos2d::Label::setMaxLineWidth.");
        pthread_exit(NULL);
    }
    
    void *cocos2dsetDimensions = lookup_symbol(libLocation, "_ZN7cocos2d5Label13setDimensionsEff"); 
    //_DWORD __fastcall cocos2d::Label::setDimensions(cocos2d::Label *__hidden this, float, float)
    if (cocos2dsetDimensions != nullptr) {
        LOGD("Found cocos2d::Label::setDimensions at %p.", (void *)cocos2dsetDimensions);
        if (DobbyHook(cocos2dsetDimensions, (void *)setDimensionsNew, (void **)&setDimensionsHooked) == RS_SUCCESS) {
            LOGI("Successfully hooked cocos2d::Label::setDimensions.");
        }
        else {
            initialization_error("Unable to hook cocos2d::Label::setDimensions.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook cocos2d::Label::setDimensions.");
        pthread_exit(NULL);
    }

    // For moving live2d subtitles
    void *lbGetViewPosition = lookup_symbol(libLocation, "_ZN9LbUtility15getViewPositionEff"); 
    //_DWORD __fastcall LbUtility::getViewPosition(LbUtility *__hidden this, float, float)
    if (lbGetViewPosition != nullptr) {
        LOGD("Found LbUtility::getViewPosition at %p.", (void *)lbGetViewPosition);
        if (DobbyHook(lbGetViewPosition, (void *)lbGetViewPositionNew, (void **)&lbGetViewPositionHooked) == RS_SUCCESS) {
            LOGI("Successfully hooked LbUtility::getViewPosition.");
        }
        else {
            initialization_error("Unable to hook LbUtility::getViewPosition.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook LbUtility::getViewPosition.");
        pthread_exit(NULL);
    }

    // Change font
    void *cocosCreateLabelPtr = lookup_symbol(libLocation, "_ZN7cocos2d5Label13createWithTTFERKNSt6__ndk112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEES9_fRKNS_4SizeENS_14TextHAlignmentENS_14TextVAlignmentE");

    if (cocosCreateLabelPtr != nullptr) {
        LOGD("Found cocos2d::Label::createWithTTF at %p.", (void *)cocosCreateLabel);
        if (DobbyHook(cocosCreateLabelPtr, (void*) cocosCreateLabel, (void **)& cocosCreateLabelHooked) == RS_SUCCESS) {
            LOGI("Successfully hooked cocos2d::Label::createWithTTF.");
        }
        else {
            initialization_error("Unable to hook cocos2d::Label::createWithTTF.");
            pthread_exit(NULL);
        }
    }
    else {
        initialization_error("Unable to hook cocos2d::Label::createWithTTF.");
        pthread_exit(NULL);
    }
   
    
    // Find key functions, TODO: Tidy up into 1 nice loop

    void *storyMessageUnitTextStart = lookup_symbol(libLocation, "_ZN16StoryMessageUnit9textStartENS_11TextPosType13TextPosType__E"); 
    // StoryMessageUnit::textStart(StoryMessageUnit::TextPosType::TextPosType__)
    if (storyMessageUnitTextStart == nullptr) {
        initialization_error("Unable to find a pointer for StoryMessageUnit::textStart.");
        pthread_exit(NULL);
    }
    storyMessageUnitStartOffset = reinterpret_cast<uintptr_t>(storyMessageUnitTextStart);
    
    void *storyMessageUnitCreateMessageArea = lookup_symbol(libLocation, "_ZN16StoryMessageUnit17createMessageAreaENS_11TextPosType13TextPosType__E"); 
    // StoryMessageUnit::createMessageArea(StoryMessageUnit::TextPosType::TextPosType__)
    if (storyMessageUnitCreateMessageArea == nullptr) {
        initialization_error("Unable to find a pointer for StoryMessageUnit::createMessageArea.");
        pthread_exit(NULL);
    }
    storyMessageUnitCreateMessageAreaOffset = reinterpret_cast<uintptr_t>(storyMessageUnitCreateMessageArea);
    
    void *storyLogUnitAddMessage = lookup_symbol(libLocation, "_ZN12StoryLogUnit10addMessageENS_11MessageType13MessageType__ERKNSt6__ndk112basic_stringIcNS2_11char_traitsIcEENS2_9allocatorIcEEEE");
    
    if (storyLogUnitAddMessage == nullptr) {
        initialization_error("Unable to find a pointer for StoryLogUnit::addMessage.");
        pthread_exit(NULL);
    }
    storyLogUnitAddMessageOffset = reinterpret_cast<uintptr_t>(storyLogUnitAddMessage);

    void *storyLogUnitAddNarrationOffsetPtr = lookup_symbol(libLocation, "_ZN12StoryLogUnit19addNarrationMessageERKNSt6__ndk112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEE");

    if (storyLogUnitAddNarrationOffsetPtr == nullptr) {
        initialization_error("Unable to find a pointer for StoryLogUnit::addNarrationMessage.");
        pthread_exit(NULL);
    }

    storyLogUnitAddNarrationOffset = reinterpret_cast<uintptr_t>(storyLogUnitAddNarrationOffsetPtr);

    void *storyCharaUnitonTextHome = lookup_symbol(libLocation, "_ZN14StoryCharaUnit10onTextHomeENSt6__ndk110shared_ptrI16StoryTurnCommandEEb");
    // StoryCharaUnit::onTextHome(std::shared_ptr<StoryTurnCommand>, bool)
    
    if (storyCharaUnitonTextHome == nullptr) {
        initialization_error("Unable to find a pointer for StoryCharaUnit::onTextHome.");
        pthread_exit(NULL);
    }
    storyCharaUnitonTextHomeOffset = reinterpret_cast<uintptr_t>(storyCharaUnitonTextHome);

    void *initLabelCWO = lookup_symbol(libLocation, "_ZN9LbUtility27initLabelCenterWidthOutlineEPN7cocos2d4NodeERPNS0_5LabelEPKcfNS0_4Vec2EiNS0_4SizeEiNS0_7Color4BEiSA_");
    // LbUtility::initLabelCenterWidthOutline(cocos2d::Node *, cocos2d::Label *&, char const*, float, cocos2d::Vec2, int, cocos2d::Size, int, cocos2d::Color4B, int, cocos2d::Color4B)

    if (initLabelCWO == nullptr) {
        initialization_error("Unable to find a pointer for LbUtility::initLabelCenterWidthOutline.");
        pthread_exit(NULL);
    }
    initCenterWidthOutline = reinterpret_cast<uintptr_t>(initLabelCWO);

    void* storyNarrationUnitCreateLabelPtr = lookup_symbol(libLocation, "_ZN18StoryNarrationUnit11createLabelEv");

    if (storyNarrationUnitCreateLabelPtr == nullptr) {
        initialization_error("Unable to find a pointer for StoryNarrationUnit::createLabel.");
        pthread_exit(NULL);
    }
    
    storyNarrationUnitCreateLabelOffset = reinterpret_cast<uintptr_t>(storyNarrationUnitCreateLabelPtr);

    // Cocos functions
    void *directorPtr = lookup_symbol(libLocation, "_ZN7cocos2d8Director11getInstanceEv");
    if (directorPtr == nullptr) {
        initialization_error("Unable to find a pointer for cocos2d::Director::getInstance()");
        pthread_exit(NULL);
    }
    getDirector = (director_type) directorPtr;

    void* getWinSizePtr = lookup_symbol(libLocation, "_ZNK7cocos2d8Director10getWinSizeEv");
    if (getWinSizePtr == nullptr) {
        initialization_error("Unable to find a pointer for cocos2d::Director::getWinSize()");
        pthread_exit(NULL);
    }
    getWinSize = (get_win_size_type) getWinSizePtr;

    void* getVisibleOriginPtr = lookup_symbol(libLocation, "_ZNK7cocos2d8Director16getVisibleOriginEv");
    if (getVisibleOriginPtr == nullptr) {
        initialization_error("Unable to find a pointer for cocos2d::Director::getVisibleOrigin()");
        pthread_exit(NULL);
    }
    getVisibleOrigin = (get_visible_origin_type) getVisibleOriginPtr;



    LOGI("Exiting hook thread.");
    pthread_exit(NULL);
}

__attribute__((constructor))
void hook_main() {

}

extern "C" jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    LOGI("Starting MagiaHook.");

    gJvm = vm;  // cache the JavaVM pointer
    Dl_info dlInfo;
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK)
    {
        return -1;
    }

    // https://stackoverflow.com/a/16302771/9665729
    // Cache ClassLoader object due to threading bug
    auto randomClass = env->FindClass("org/cocos2dx/lib/Cocos2dxHelper");
    jclass classClass = env->GetObjectClass(randomClass);
    auto classLoaderClass = env->FindClass("java/lang/ClassLoader");
    auto getClassLoaderMethod = env->GetMethodID(classClass, "getClassLoader",
                                             "()Ljava/lang/ClassLoader;");
    gClassLoader = env->NewGlobalRef(env->CallObjectMethod(randomClass, getClassLoaderMethod));
    gFindClassMethod = env->GetMethodID(classLoaderClass, "findClass",
                                    "(Ljava/lang/String;)Ljava/lang/Class;");
    

    if (dladdr((const void*) hook_main, &dlInfo))
    {
        //fs::path ilso = fs::path(dlInfo.dli_fname).remove_filename(); ndk 22+ required
        //ilso /= "il2cpp.so"; ndk 22+ required
        hook_loop_args* args = new hook_loop_args;
        auto ilso = (std::string) dirname((char *)dlInfo.dli_fname);

        ilso += "/";
        ilso += libName;

        //if (fs::exists(ilso)) { ndk 22+ required
        if (!file_exists(ilso)) {
            // Fix for some devices
            auto this_ilso = get_libFoldername(hookName);
            if (this_ilso.empty()) {
                LOGE("Failed to locate shared library %s. Checked: %s", libName, ilso.c_str());
                return JNI_VERSION_1_6;
            }

            auto ilso2 = this_ilso.substr(0, this_ilso.length() - strlen(hookName) - 1);
            ilso2 += libName;
            if (!file_exists(ilso2)) {
                LOGE("Failed to load shared library %s. Checked: %s", libName, ilso2.c_str());
                return JNI_VERSION_1_6;
            }
            args->libso = ilso2;
        }
        else {
            args->libso = ilso;
        }
        pthread_t ptid;
        if (pthread_create(&ptid, NULL, &hook_loop, args) != 0) {
            LOGE("Hooking thread failed to start.");
            return JNI_VERSION_1_6;
        }
    }
    return JNI_VERSION_1_6;
}