#include <jni.h>

/* include some silly stuff */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "winfw.h"
#include "platform_print.h"
#include "jni_helper.h"

#define UPDATE_INTERVAL 1       /* 10ms */
uint32_t timestamp = 0;

void font_init();
static uint32_t _gettime(void);

static uint32_t
_gettime(void) {
	uint32_t t;
#if !defined(__APPLE__)
	struct timespec ti;
	clock_gettime(CLOCK_MONOTONIC, &ti);
	t = (uint32_t)(ti.tv_sec & 0xffffff) * 100;
	t += ti.tv_nsec / 10000000;
#else
	struct timeval tv;
	gettimeofday(&tv, NULL);
	t = (uint32_t)(tv.tv_sec & 0xffffff) * 100;
	t += tv.tv_usec / 10000;
#endif

	return t;
}

static void
update_frame() {
	ejoy2d_win_frame();
//    glXSwapBuffers(g_X.display, g_X.wnd);
}


char * arg[] = {"[holdplace]","examples/ex01.lua"};
/* Call to initialize the graphics state */

jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    jni_helper_set_javavm(vm);
    openal_jni_onload(vm, reserved);
    return JNI_VERSION_1_4;
}

void
Java_com_example_testej2d_DemoRenderer_nativeInit( JNIEnv*  env,jobject thiz, jstring path, jstring main)
{
	pf_log("DemoRenderer_nativeInit");
    const char *str1 = (*env)->GetStringUTFChars(env, path, 0);
    const char *str2 = (*env)->GetStringUTFChars(env, main, 0);
    font_init();
    ejoy2d_win_init(1024,768,1.0f,str1, str2);
    
    (*env)->ReleaseStringUTFChars(env, path, str1);	
    (*env)->ReleaseStringUTFChars(env, main, str2);	
}

void
Java_com_example_testej2d_DemoRenderer_nativeResize( JNIEnv*  env, jobject  thiz, jint w, jint h )
{
    ejoy2d_win_resize((int)w, (int)h); 
}

/* Call to render the next GL frame */
void
Java_com_example_testej2d_DemoRenderer_nativeRender( JNIEnv*  env,jobject thiz )
{
	//pf_log("DemoRenderer_nativeRender");
	//ejoy2d_win_frame();

    uint32_t current = _gettime();
    if (current < timestamp) {
        timestamp = current;
        return;
    }
    uint32_t elapsed = current - timestamp;
    if (elapsed >= UPDATE_INTERVAL) {
        if (elapsed > UPDATE_INTERVAL*10)
            elapsed = UPDATE_INTERVAL*10;
        timestamp = current;
        ejoy2d_win_update(elapsed*0.01f);
        update_frame();
	} else {
        ejoy2d_win_frame();
		usleep(1000);
    }
	//pf_log("DemoRenderer_nativeRender end");
}

/* Call to finalize the graphics state */
void
Java_com_example_testej2d_DemoRenderer_nativeDone( JNIEnv*  env,jobject thiz )
{
    ejoy2d_win_fini();
}


void
Java_com_example_testej2d_DemoRenderer_nativeTouch(JNIEnv* env,jobject thiz,float x,float y,int event)
{
	ejoy2d_win_touch(x,y,event);
}

void
Java_com_example_testej2d_DemoRenderer_nativePause( JNIEnv*  env,jobject thiz )
{
    ejoy2d_win_pause();
}

void
Java_com_example_testej2d_DemoRenderer_nativeResume( JNIEnv*  env )
{
    ejoy2d_win_resume();
}
