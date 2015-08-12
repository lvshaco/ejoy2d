/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

//BEGIN_INCLUDE(all)
#include <jni.h>
#include <errno.h>

#include <EGL/egl.h>
#include <GLES2/gl2.h>

#include <android/asset_manager.h>
#include <android/sensor.h>
#include <android/log.h>
#include <android_native_app_glue.h>

/* include some silly stuff */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "winfw.h"
#include "platform_print.h"

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


/**
 * Our saved state data.
 */
struct saved_state {
    float angle;
    int32_t x;
    int32_t y;
};

/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;

    /*ASensorManager* sensorManager;
    const ASensor* accelerometerSensor;
    ASensorEventQueue* sensorEventQueue;
    */
    int animating;
    EGLDisplay display;
    EGLSurface surface;
    EGLContext context;
    int32_t width;
    int32_t height;
    struct saved_state state;
};

/**
 * Initialize an EGL context for the current display.
 */
static int engine_init_display(struct engine* engine) {
    pf_log("DemoRenderer_nativeInit");

    //// initialize OpenGL ES and EGL

    /*
     * Here specify the attributes of the desired configuration.
     * Below, we select an EGLConfig with at least 8 bits per color
     * component compatible with on-screen windows
     */
    //const EGLint attribs[] = {
            //EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            //EGL_BLUE_SIZE, 8,
            //EGL_GREEN_SIZE, 8,
            //EGL_RED_SIZE, 8,
            //EGL_NONE
    //};
    //EGLint w, h, dummy, format;
    //EGLint numConfigs;
    //EGLConfig config;
    //EGLSurface surface;
    //EGLContext context;

    //EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);

    //eglInitialize(display, 0, 0);

    /* Here, the application chooses the configuration it desires. In this
     * sample, we have a very simplified selection process, where we pick
     * the first EGLConfig that matches our criteria */
    //eglChooseConfig(display, attribs, &config, 1, &numConfigs);

    /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
     * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
     * As soon as we picked a EGLConfig, we can safely reconfigure the
     * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
    //eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);

    //ANativeWindow_setBuffersGeometry(engine->app->window, 0, 0, format);

    //surface = eglCreateWindowSurface(display, config, engine->app->window, NULL);
    //context = eglCreateContext(display, config, NULL, NULL);

    //if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
        //pf_log("Unable to eglMakeCurrent");
        //return -1;
    //}

    //eglQuerySurface(display, surface, EGL_WIDTH, &w);
    //eglQuerySurface(display, surface, EGL_HEIGHT, &h);

    //engine->display = display;
    //engine->context = context;
    //engine->surface = surface;
    //engine->width = w;
    //engine->height = h;
    //engine->state.angle = 0;

    //// Initialize GL state.
    //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    //glEnable(GL_CULL_FACE);
    //glShadeModel(GL_SMOOTH);
    //glDisable(GL_DEPTH_TEST);

    const EGLint configAttribs[] =
    {
        EGL_RENDERABLE_TYPE, EGL_WINDOW_BIT,
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_DEPTH_SIZE, 24,
        EGL_NONE
    };
    const EGLint contextAttribs[] =
    {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };
    EGLDisplay display;
    display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if(display == EGL_NO_DISPLAY)
    {
        return EGL_FALSE;
    }
    EGLint major, minor;
    if(!eglInitialize(display, &major, &minor))
    {
        return EGL_FALSE;
    }
    EGLConfig config;
    EGLint numConfigs;
    if(!eglChooseConfig(display, configAttribs, &config, 1,
                &numConfigs)) {
        return EGL_FALSE;
    }
    EGLSurface surface;
    surface = eglCreateWindowSurface(display, config, engine->app->window, NULL);
    if(surface== EGL_NO_SURFACE)
    {
        return EGL_FALSE;
    }
    EGLContext context;
    context = eglCreateContext(display, config, EGL_NO_CONTEXT,
            contextAttribs);
    if(context == EGL_NO_CONTEXT)
    {
        return EGL_FALSE;
    }
    if(!eglMakeCurrent(display, surface, surface, context))
    {
        return EGL_FALSE;
    }

    EGLint w, h;
    eglQuerySurface(display, surface, EGL_WIDTH, &w);
    eglQuerySurface(display, surface, EGL_HEIGHT, &h);

    engine->display = display;
    engine->context = context;
    engine->surface = surface;
    engine->width = w;
    engine->height = h;
    engine->state.angle = 0;

    ANativeActivity *act = engine->app->activity;

    FILE *fp = fopen("/mnt/sdcard/ejoy2d-config", "r");
    if (fp == NULL) {
        char cfgfile[256];
        snprintf(cfgfile, sizeof(cfgfile), "%s/config/config", act->internalDataPath);
        fp = fopen(cfgfile, "r");
        if (fp == NULL) {
            pf_log("can not open config");
            exit(1);
        }
    }
    char buf[64];
    char *name = fgets(buf, sizeof(buf), fp);
    if (name == NULL) {
        exit(1);
    }
    fclose(fp);
    char mainlua[256];
    snprintf(mainlua, sizeof(mainlua), "examples/%s.lua", name);
	ejoy2d_win_init(w,h,1.0f,act->internalDataPath, mainlua);
	font_init();
    //glViewport(0, 0, w, h);
	//glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    //ANativeActivity *act = engine->app->activity;
    //ANativeActivity_showSoftInput(0, 0);
    return 0;
}

/**
 * Just the current frame in the display.
 */
static void engine_draw_frame(struct engine* engine) {
    pf_log("DemoRenderer_nativeRender");
    if (engine->display == NULL) {
        // No display.
        return;
    }
	
    ejoy2d_win_frame();

    uint32_t old = timestamp;
    timestamp= _gettime();

    if (timestamp - old >= UPDATE_INTERVAL) {
        ejoy2d_win_update();
        update_frame();
        eglSwapBuffers(engine->display, engine->surface);    
    }
    else
        usleep(1000);

    //
    //// Just fill the screen with a color.
    //glClearColor(((float)engine->state.x)/engine->width, engine->state.angle,
            //((float)engine->state.y)/engine->height, 1);
    //glClear(GL_COLOR_BUFFER_BIT);

    //eglSwapBuffers(engine->display, engine->surface);
    
    pf_log("DemoRenderer_nativeRender end");
}

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(struct engine* engine) {
    pf_log("DemoRenderer_nativeDone");

    if (engine->display != EGL_NO_DISPLAY) {
        ejoy2d_win_fini();
        eglMakeCurrent(engine->display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (engine->context != EGL_NO_CONTEXT) {
            eglDestroyContext(engine->display, engine->context);
        }
        if (engine->surface != EGL_NO_SURFACE) {
            eglDestroySurface(engine->display, engine->surface);
        }
        eglTerminate(engine->display);
    }
    engine->animating = 0;
    engine->display = EGL_NO_DISPLAY;
    engine->context = EGL_NO_CONTEXT;
    engine->surface = EGL_NO_SURFACE;

}

/**
 * Process the next input event.
 */
static int32_t engine_handle_input(struct android_app* app, AInputEvent* event) {
    pf_log("DemoGLSurfaceView_nativeTouch");

    //if (event == NULL) {
        //return;
    //}
    struct engine* engine = (struct engine*)app->userData;
    pf_log("event %p, app %p, engine %p", event, app, engine);
    int type = AInputEvent_getType(event);
    if (type == AINPUT_EVENT_TYPE_MOTION) {
        int touch = AMotionEvent_getAction(event);
        int x = AMotionEvent_getX(event, 0);
        int y = AMotionEvent_getY(event, 0);
        ejoy2d_win_touch(x,y,touch);
        engine->animating = 1;
        return 1;
    }
    return 0;

    //struct engine* engine = (struct engine*)app->userData;
    //if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
        //engine->animating = 1;
        //engine->state.x = AMotionEvent_getX(event, 0);
        //engine->state.y = AMotionEvent_getY(event, 0);
        //return 1;
    //}
    //return 0;

}

/**
 * Process the next main command.
 */
static void engine_handle_cmd(struct android_app* app, int32_t cmd) {
    struct engine* engine = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_SAVE_STATE:
            // The system has asked us to save our current state.  Do so.
            engine->app->savedState = malloc(sizeof(struct saved_state));
            *((struct saved_state*)engine->app->savedState) = engine->state;
            engine->app->savedStateSize = sizeof(struct saved_state);
            break;
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (engine->app->window != NULL) {
                engine_init_display(engine);
                engine_draw_frame(engine);
            }
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            break;
        case APP_CMD_GAINED_FOCUS:
            // When our app gains focus, we start monitoring the accelerometer.
            /*if (engine->accelerometerSensor != NULL) {
                ASensorEventQueue_enableSensor(engine->sensorEventQueue,
                        engine->accelerometerSensor);
                // We'd like to get 60 events per second (in us).
                ASensorEventQueue_setEventRate(engine->sensorEventQueue,
                        engine->accelerometerSensor, (1000L/60)*1000);
            }*/
            break;
        case APP_CMD_LOST_FOCUS:
            // When our app loses focus, we stop monitoring the accelerometer.
            // This is to avoid consuming battery while not being used.
            /*if (engine->accelerometerSensor != NULL) {
                ASensorEventQueue_disableSensor(engine->sensorEventQueue,
                        engine->accelerometerSensor);
            }*/
            // Also stop animating.
            engine->animating = 0;
            pf_log("lost focus ...");
            engine_draw_frame(engine);
            pf_log("lost focus end");
            break;
    }
}

static int copy_dir(AAssetManager *mgr, const char *asset_dir, const char *topath, const char *todir) {
    AAssetDir *dir = AAssetManager_openDir(mgr, asset_dir);
    if (dir == NULL) {
        pf_log("asset %s no found", asset_dir);
        return 1;
    }
    char buf[1024];

    char fromfile[256];
    int fromdiff = strlen(asset_dir);
    memcpy(fromfile, asset_dir, fromdiff);
    fromfile[fromdiff++] = '/';

    char tofile[256];
    int todiff = 0;
    int sz; 
    sz = strlen(topath);
    memcpy(tofile, topath, sz); 
    todiff+=sz;
    tofile[todiff++] = '/';
    sz = strlen(todir);
    memcpy(tofile+todiff, todir, sz); 
    todiff+=sz;
    tofile[todiff++] = '/';
    tofile[todiff] = '\0';
    mkdir(tofile, 0770);

    const char *fname;
    while (fname = AAssetDir_getNextFileName(dir)) {
        strncpy(fromfile+fromdiff, fname, sizeof(fromfile)-fromdiff-1);
        AAsset *asset = AAssetManager_open(mgr, fromfile, 2);
        if (asset) {
            strncpy(tofile+todiff, fname, sizeof(tofile)-todiff-1);
            FILE *fp = fopen(tofile, "w+");
            if (fp == NULL) {
                pf_log("copy file %s fail", tofile);
                exit(1);
            }
            int rd;
            while ((rd = AAsset_read(asset, buf, sizeof(buf))) > 0) {
                fwrite(buf, rd, 1, fp);
            }
            fclose(fp);
            AAsset_close(asset);
        }
    }
    AAssetDir_close(dir);
    return 0;
}

/**
 * This is the main entry point of a native application that is using
 * android_native_app_glue.  It runs in its own thread, with its own
 * event loop for receiving input events and doing other things.
 */
void android_main(struct android_app* state) {
    ANativeActivity *activity = state->activity;

    AAssetManager *asset = activity->assetManager;
    copy_dir(activity->assetManager, "files/ejoy2d", activity->internalDataPath, "ejoy2d");
    copy_dir(activity->assetManager, "files/examples", activity->internalDataPath, "examples");
    copy_dir(activity->assetManager, "files/examples/asset", activity->internalDataPath, "examples/asset");
    copy_dir(activity->assetManager, "files/config", activity->internalDataPath, "config");
 
    struct engine engine;

    // Make sure glue isn't stripped.
    app_dummy();

    memset(&engine, 0, sizeof(engine));
    state->userData = &engine;
    state->onAppCmd = engine_handle_cmd;
    state->onInputEvent = engine_handle_input;
    engine.app = state;

    // Prepare to monitor accelerometer
    /*engine.sensorManager = ASensorManager_getInstance();
    engine.accelerometerSensor = ASensorManager_getDefaultSensor(engine.sensorManager,
            ASENSOR_TYPE_ACCELEROMETER);
    engine.sensorEventQueue = ASensorManager_createEventQueue(engine.sensorManager,
            state->looper, LOOPER_ID_USER, NULL, NULL);
    */
    if (state->savedState != NULL) {
        // We are starting with a previous saved state; restore from it.
        engine.state = *(struct saved_state*)state->savedState;
    }

    // loop waiting for stuff to do.

    while (1) {
        // Read all pending events.
        int ident;
        int events;
        struct android_poll_source* source;

        // If not animating, we will block forever waiting for events.
        // If animating, we loop until all events are read, then continue
        // to draw the next frame of animation.
        while ((ident=ALooper_pollAll(engine.animating ? 0 : -1, NULL, &events,
                (void**)&source)) >= 0) {

            // Process this event.
            if (source != NULL) {
                source->process(state, source);
            }

            // If a sensor has data, process it now.
            /*if (ident == LOOPER_ID_USER) {
                if (engine.accelerometerSensor != NULL) {
                    ASensorEvent event;
                    while (ASensorEventQueue_getEvents(engine.sensorEventQueue,
                            &event, 1) > 0) {
                        //pf_log("accelerometer: x=%f y=%f z=%f",
                                //event.acceleration.x, event.acceleration.y,
                                //event.acceleration.z);
                    }
                }
            }*/

            // Check if we are exiting.
            if (state->destroyRequested != 0) {
                engine_term_display(&engine);
                return;
            }
        }

        if (engine.animating) {
            // Done with events; draw next animation frame.
            engine.state.angle += .01f;
            if (engine.state.angle > 1) {
                engine.state.angle = 0;
            }

            // Drawing is throttled to the screen update rate, so there
            // is no need to do timing here.
            pf_log("update ...");
            engine_draw_frame(&engine);
            pf_log("update end");
        }
    }
}
//END_INCLUDE(all)
