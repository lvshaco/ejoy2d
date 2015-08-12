#include <jni.h>
#include <android/asset_manager_jni.h>
#include "platform_print.h"

extern void asset_setmanager(AAssetManager *assetmgr);
void
Java_com_example_testej2d_MyHelper_nativeSetContext(JNIEnv *env, jobject thiz, 
        jobject context, jobject assetmgr)
{
    asset_setmanager(AAssetManager_fromJava(env, assetmgr));
}
