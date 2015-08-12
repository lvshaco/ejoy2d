#include "opengl.h"
#include "ejoy2dgame.h"
#include "fault.h"
#include "screen.h"
#include "winfw.h"

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
"require(\"ejoy2d.framework\").WorkDir = ''\n"
"assert(script, 'I need a script name')\n"
"path = string.match(path,[[(.*)/[^/]*$]])\n"
"package.path = path .. [[/?.lua;]] .. path .. [[/?/init.lua]]\n"
"local f = assert(loadfile(script))\n"
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
_read_exepath(char * buf, int bufsz) {
    return getenv("_");
}
#define read_exepath(buf,bufsz) _read_exepath(buf,bufsz)

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

extern int luaopen_socket_c(lua_State *L);
extern int luaopen_socketbuffer_c(lua_State *L);
extern int luaopen_audio_c(lua_State *L);

void
ejoy2d_win_init(int argc, char *argv[]) {
	G = create_game();
	lua_State *L = ejoy2d_game_lua(G->game);
    int top = lua_gettop(L);
    luaL_requiref(L, "socket.c", luaopen_socket_c, 0);
    luaL_requiref(L, "socketbuffer.c", luaopen_socketbuffer_c, 0);
    luaL_requiref(L, "audio.c", luaopen_audio_c, 0);
    lua_settop(L, top);

    lua_pushcfunction(L, traceback);
	int tb = lua_gettop(L);

    char buf[BUFSIZE];
    const char *pathbuf = read_exepath(buf, BUFSIZE);
    if (pathbuf == NULL)
        fault("can't read exepath");

	int err = luaL_loadstring(L, startscript);
	if (err) {
		const char *msg = lua_tostring(L,-1);
		fault("%s", msg);
	}

    lua_pushstring(L, pathbuf);
	int i;
	for (i=1;i<argc;i++) {
		lua_pushstring(L, argv[i]);
	}
    screen_init(WIDTH,HEIGHT,1.0f);
	err = lua_pcall(L, argc, 0, tb);
	if (err) {
		const char *msg = lua_tostring(L,-1);
		fault("%s", msg);
	}

	lua_pop(L,1);	
	ejoy2d_game_start(G->game);
}

void
ejoy2d_win_update(float s) {
	ejoy2d_game_update(G->game, s); 
}

void
ejoy2d_win_frame() {
	ejoy2d_game_drawframe(G->game);
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
ejoy2d_win_resize(int w, int h) {
    if (G && G->game) {
        screen_init(w,h,1.0f);
        ejoy2d_game_resize(G->game, w, h);
    }
}
