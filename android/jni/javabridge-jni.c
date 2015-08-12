#include <jni.h>
#include "javabridge.h"
#include "platform_print.h"

void
Java_com_example_testej2d_JavaBridge_nativeCalllua( JNIEnv*  env,jobject thiz, int functionid, jstring args)
{
    const char *str = (*env)->GetStringUTFChars(env, args, 0);
    //pf_log("nativeCalllua %d %s", (int)functionid, str);
    javabridge_calllua(functionid, str);
    (*env)->ReleaseStringUTFChars(env, args, str);	
}
