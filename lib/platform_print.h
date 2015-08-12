#ifndef __PLATFORM_PRINT_H__
#define __PLATFORM_PRINT_H__

#ifdef __ANDROID__
    #include <android/log.h>
    #include <jni.h>
    #define  LOG_TAG                    "ejoy2d"
    #define  pf_log(...)                __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
    #define  pf_vprint(format, ap)      __android_log_vprint(ANDROID_LOG_DEBUG, LOG_TAG, (format), (ap))
#else
    #include <stdarg.h>
    #include <stdio.h>
    static inline void my_printf(const char *fmt, ...) {
        char buf[2048] = {0};
        va_list ap;
        va_start(ap, fmt);
        int n =vsnprintf(buf, sizeof(buf), fmt, ap);
        buf[n] = '\n';
        buf[n+1] = '\0';
        va_end(ap);
        fprintf(stderr, "%s", buf);
    }
    #define pf_log                      my_printf
    #define pf_vprint                   vprintf
#endif

#endif
