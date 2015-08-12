#include "jni_helper.h"
#include "platform_print.h"
#include <pthread.h>
#include <assert.h>

static JavaVM *VM;
static pthread_key_t KEY;

static void
_detach_current_thread(void *p) {
    (*VM)->DetachCurrentThread(VM);
}

static JNIEnv *
_getenv() {
    JNIEnv *env = pthread_getspecific(KEY);
    if (env) return env;

    jint ret = (*VM)->GetEnv(VM, (void**)&env, JNI_VERSION_1_4);
    switch (ret) {
    case JNI_OK:
        pthread_setspecific(KEY, env);
        return env;
    case JNI_EDETACHED:
        if ((*VM)->AttachCurrentThread(VM,&env, NULL) < 0) {
            pf_log("JavaVM attach thread fail");
            return NULL;
        }
        pthread_setspecific(KEY, env);
        return env;
    case JNI_EVERSION:
        pf_log("JNI version 1.4 not supported");
        return NULL;
    default:
        pf_log("JavaVM GetEnv fail");
        return NULL;
    }
}

JNIEnv *
jni_helper_env() {
    return _getenv();
}

void 
jni_helper_set_javavm(JavaVM *vm) {
    VM = vm;
    pthread_key_create(&KEY, _detach_current_thread);
}

int
jni_helper_getstaticmethodinfo(const char *class, 
        const char *method, 
        const char *param,
        struct jni_methodinfo *info) {
    assert(class);
    assert(method);
    assert(param);

    JNIEnv *env = _getenv();
    if (env == NULL)
        return 1;

    jclass jc = (*env)->FindClass(env, class);
    if (!jc) {
        pf_log("failed to find class %s", class);
        (*env)->ExceptionClear(env);
        return 1;
    }
    jmethodID jmid = (*env)->GetStaticMethodID(env, jc, method, param);
    if (!jmid) {
        pf_log("failed to find static method %s", method);
        (*env)->ExceptionClear(env);
        return 1;
    }
    info->env = env;
    info->jc = jc;
    info->jmid = jmid;
    return 0;
}
