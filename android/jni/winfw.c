#include "opengl.h"
#include "ejoy2dgame.h"
#include "fault.h"
#include "screen.h"
#include "winfw.h"
#include "platform_print.h"
#include <lauxlib.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

struct WINDOWGAME {
	struct game *game;
	int intouch;
};

static const int BUFSIZE = 2048;

static struct WINDOWGAME *G = NULL;

static const char * startscript =
"local path,script = ...\n"
"assert(script, 'I need a script name')\n"
"require(\"ejoy2d.framework\").WorkDir = path..'/';\n"
"package.path =path..[[/?.lua;]]..path..[[/?/init.lua;]]\n"//"..path..[[/main/?.lua;]]\n"
"local f = assert(loadfile(path..'/'..script))\n"
"f(script)\n"
;

static struct WINDOWGAME *
create_game() {
	struct WINDOWGAME * g = (struct WINDOWGAME *)malloc(sizeof(*g));
	g->game = ejoy2d_game();
	g->intouch = 0;
	return g;
}

static int
traceback(lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg)
		luaL_traceback(L, L, msg, 1);
	else if (!lua_isnoneornil(L, 1)) {
	if (!luaL_callmeta(L, 1, "__tostring"))
		lua_pushliteral(L, "(no error message)");
	}
	return 1;
}

#ifdef __APPLE__
static const char*
_read_exepath() {
    return getenv("_");
}
#define read_exepath(buf,bufsz) _read_exepath()

#else
static const char*
read_exepath(char * buf, int bufsz) {
    int  count;
    count = readlink("/proc/self/exe", buf, bufsz);

    if (count < 0)
        return NULL;
    return buf;
}
#endif

extern int javabridge_tolua(lua_State *L);
extern int luaopen_socket_c(lua_State *L);
extern int luaopen_socketbuffer_c(lua_State *L);
extern int luaopen_asset_c(lua_State *L);
extern int luaopen_audio_c(lua_State *L);

static uint32_t
_gettime(void) {
	uint32_t t;
#if !defined(__APPLE__)
	struct timespec ti;
	clock_gettime(CLOCK_MONOTONIC, &ti);
	t = (uint32_t)(ti.tv_sec & 0xffffff) * 1000;
	t += ti.tv_nsec / 1000000;
#else
	struct timeval tv;
	gettimeofday(&tv, NULL);
	t = (uint32_t)(tv.tv_sec & 0xffffff) * 1000;
	t += tv.tv_usec / 1000;
#endif

	return t;
}

void
ejoy2d_win_init(int w, int h, float scale, const char *path, const char *mainlua) {
	pf_log("ejoy2d_win_init start: w:%d,h%d,path:%s,mainlua:%s",w,h,path,mainlua);
    
	G = create_game();
	lua_State *L = ejoy2d_game_lua(G->game);
    
    int top = lua_gettop(L);
    luaL_requiref(L, "asset.c", luaopen_asset_c, 0);
    luaL_requiref(L, "javabridge.c", javabridge_tolua, 0);
    luaL_requiref(L, "socket.c", luaopen_socket_c, 0);
    luaL_requiref(L, "socketbuffer.c", luaopen_socketbuffer_c, 0);
    luaL_requiref(L, "audio.c", luaopen_audio_c, 0);
    lua_settop(L, top);

    asset_path_set(path);

    uint32_t t1 = _gettime();
    asset_extract("ejoy2d", path, ".lua");
    asset_extract("util", path, ".lua");
    asset_extract("", path, ".lua");
    asset_extract("asset", path, ".lua");
    asset_extract("asset", path, ".mp3");
    asset_extract("asset", path, ".wav");
    uint32_t t2 = _gettime();
    pf_log("c copy use time:%d",t2-t1);

    lua_pushcfunction(L, traceback);
	int tb = lua_gettop(L);

	int err = luaL_loadstring(L, startscript);
	if (err) {
		const char *msg = lua_tostring(L,-1);
		fault("%s", msg);
	}
    lua_pushstring(L, path);
    lua_pushstring(L, mainlua);

    screen_init(w,h,1.0f);
    pf_log("lua_pcall start.");
	err = lua_pcall(L, 2, 0, tb);
	pf_log("lua_pcall end.");
	if (err) {
		const char *msg = lua_tostring(L,-1);
		fault("%s", msg);
	}

	lua_pop(L,1);

    ejoy2d_game_start(G->game);
    pf_log("ejoy2d_game_start end");
    //ejoy2d_win_resize(w,h);
}

void 
ejoy2d_win_fini() {
    pf_log("ejoy2d_win_fini end");

    if (G) {
        if (G->game) {
            ejoy2d_game_exit(G->game);
            G->game = NULL;
        }
        free(G);
        G = NULL;
    }
}

void
ejoy2d_win_update(float s) {

	ejoy2d_game_update(G->game, s);
	//pf_log("ejoy2d_win_update end");
}

void
ejoy2d_win_frame() {
	//pf_log("ejoy2d_win_frame begin");
	glClear(GL_COLOR_BUFFER_BIT);
    //pf_log("ejoy2d_win_frame draw ...");
	ejoy2d_game_drawframe(G->game);
	//pf_log("ejoy2d_win_frame end");
}

void
ejoy2d_win_touch(int x, int y,int touch) {
	switch (touch) {
	case TOUCH_BEGIN:
		G->intouch = 1;
		break;
	case TOUCH_END:
		G->intouch = 0;
		break;
	case TOUCH_MOVE:
		if (!G->intouch) {
			return;
		}
		break;
	}
	// windows only support one touch id (0)
	int id = 0;
	ejoy2d_game_touch(G->game, id, x,y,touch);
}

void
ejoy2d_win_resume(){
    pf_log("ejoy2d_win_resume");
    if (G && G->game) {
        ejoy2d_game_resume(G->game);
    }
}

void
ejoy2d_win_pause(){
    pf_log("ejoy2d_win_pause");
    if (G && G->game) {
        ejoy2d_game_pause(G->game);
    }
}

void
ejoy2d_win_resize(int w, int h) {
    pf_log("ejoy2d_win_resize %d, %d", w,h);
    if (G && G->game) {
        screen_init(w,h,1.0f);
        ejoy2d_game_resize(G->game, w, h);
    }
}
