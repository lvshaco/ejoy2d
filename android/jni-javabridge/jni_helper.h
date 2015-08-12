#ifndef __jni_helper_h__
#define __jni_helper_h__

#include <jni.h>

struct jni_methodinfo {
    JNIEnv *env;
    jclass jc;
    jmethodID jmid;
};

void jni_helper_set_javavm(JavaVM *vm);
int  jni_helper_getstaticmethodinfo(const char *class, 
        const char *method, 
        const char *param,
        struct jni_methodinfo *info);
JNIEnv *jni_helper_env();

#endif
