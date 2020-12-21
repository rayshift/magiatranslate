#include <cstdint>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <functional>
#include "cocos/base/CCRef.h"
#include "cocos2d.h"
#include <android/log.h>
#include "DialogueBox.h"
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO, "MagiaHook", __VA_ARGS__)

typedef std::function<void(cocos2d::Ref*)> ccMenuCallback;
typedef int *(*openMessageBoxType)(char const* title, char const* body, char const* button, const ccMenuCallback& callback, bool xButton);

__attribute__((visibility("default")))
void DialogueBoxProxy::DialogueBox(void* dialogueBoxPointer) {
    LOGI("Called extern dialogue box");
    auto openMessageBoxFunc = reinterpret_cast<openMessageBoxType>(dialogueBoxPointer);

    auto dontDisappear = std::bind(&DialogueBoxProxy::testCallback, this, std::placeholders::_1);

    openMessageBoxFunc("Update required", "An update for Magia Translate is strongly recommended! 2", "OK", 
    dontDisappear, false);
    //sleep(100);
}

//void DialogueBoxProxy::motdBox(void * dialogueboxPointer, void * loadContinuePointer);

void DialogueBoxProxy::testCallback(cocos2d::Ref* sender) {
    LOGI("Recalled VALUE");
}

__attribute__((visibility("default")))
DialogueBoxProxy::DialogueBoxProxy() {
 
}
__attribute__((visibility("default")))
DialogueBoxProxy::~DialogueBoxProxy() {
}
