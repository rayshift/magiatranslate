#ifndef __DIALOGUEBOX_H__
#define __DIALOGUEBOX_H__
#include <cstdint>
#include "cocos/base/CCRef.h"

class DialogueBoxProxy {
    public:
        DialogueBoxProxy();
        virtual ~DialogueBoxProxy();
        virtual void DialogueBox(void* dialogueBoxPointer);
        virtual void testCallback(cocos2d::Ref* sender);
    private:
        std::function<void(cocos2d::Ref*)> dialogueCallback;
};

#endif