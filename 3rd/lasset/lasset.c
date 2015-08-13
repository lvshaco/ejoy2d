#ifdef __ANDROID__

#include "platform_print.h"
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <android/asset_manager_jni.h>

static AAssetManager *__A;

void
asset_setmanager(AAssetManager* assetmgr) {
    __A = assetmgr;
}

static int
endswith(const char *fname, const char *ext, size_t extlen) {
    size_t l = strlen(fname);
    if (l > extlen) {
        return strcmp(fname+l-extlen, ext) == 0;
    }
    return 0;
}

int
asset_extract(const char *assetdir, const char *topath, const char *ext) {
    char fromdir[PATH_MAX];
    if (assetdir[0] == '\0') {
        strcpy(fromdir, "files");
    } else {
        snprintf(fromdir, sizeof(fromdir), "files/%s", assetdir);
    }
    AAssetDir *dir = AAssetManager_openDir(__A, fromdir);
    if (dir == NULL) {
        pf_log("[!no asset dir] %s", fromdir);
        return 1;
    }
    char buf[2048];
    char todir[PATH_MAX];
    if (assetdir[0] == '\0') {
        strcpy(todir, topath);
    } else {
        snprintf(todir, sizeof(todir), "%s/%s", topath, assetdir);
    }
    mkdir(todir, 0770);

    size_t extlen = strlen(ext);

    char fromfile[PATH_MAX];
    char tofile[PATH_MAX];
    const char *fname;
    while (fname = AAssetDir_getNextFileName(dir)) {
        if (endswith(fname, ext, extlen)) {
            snprintf(fromfile, sizeof(fromfile), "%s/%s", fromdir, fname);
            snprintf(tofile, sizeof(tofile), "%s/%s", todir, fname);
            pf_log("%s -> %s", fromfile, tofile);
            AAsset *asset = AAssetManager_open(__A, fromfile, 2);
            if (asset) {
                FILE *fp = fopen(tofile, "w+");
                if (fp == NULL) {
                    pf_log("asset extract fail: %s", tofile);
                }
                int rd;
                while ((rd = AAsset_read(asset, buf, sizeof(buf))) > 0) {
                    fwrite(buf, rd, 1, fp);
                }
                fclose(fp);
                AAsset_close(asset);
            } else {
                pf_log("[!no asset] %s", fromfile);
            }
        }
    }
    AAssetDir_close(dir);
    return 0;
}

static int
lopen(lua_State *L) {
    const char *fname = luaL_checkstring(L,1);
    char from[PATH_MAX];
    snprintf(from, sizeof(from), "files/%s", fname);
    AAsset *asset = AAssetManager_open(__A, from, 2);
    if (asset == NULL) {
        lua_pushnil(L);
        lua_pushfstring(L, "asset open fail:%s", from);
        return 2;
    }
    off_t l = AAsset_getLength(asset);
    const void *p = AAsset_getBuffer(asset);
    lua_pushlightuserdata(L,(void*)p);
    lua_pushinteger(L,l);
    lua_pushlightuserdata(L,asset);
    return 3; 
}

static int
lclose(lua_State *L) {
    AAsset *asset = lua_touserdata(L,1);
    if (asset) {
        AAsset_close(asset);
    }
    return 0;
}

int
luaopen_asset_c(lua_State *L) {
	luaL_Reg l[] = {
        {"open", lopen},
        {"close", lclose},
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}

#endif
