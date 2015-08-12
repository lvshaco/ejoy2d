/*
 * lsocket.h
 *
 *  Created on: 2014-3-20
 *      Author: bing
 */
#include <lua.h>

#ifndef LSOCKET_H_
#define LSOCKET_H_

static int
lstart(lua_State *L);

int
luaopen_ldebug_socket(lua_State *L);

#endif /* LSOCKET_H_ */
