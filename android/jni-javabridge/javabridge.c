#include <lua.h>
#include <lauxlib.h>
#include <assert.h>
#include <string.h>
#include "jni_helper.h"
#include "platform_print.h"

static int idfunc_table_index;
static int funcid_table_index;
static int count_table_index;

static lua_State *_L;
static int ID;

#define VT_VOID 0
#define VT_BOOLEAN 1
#define VT_INT 2
#define VT_FLOAT 3
#define VT_STRING 4
#define VT_FUNCTION 5

struct _value_info {
    int type;
    union {
    int i;
    float f;
    jstring s;
    };
};

static int
_nextid() {
    ++ID;
    if (ID== 0) ID= 1;
    return ID;
}

static void
_get_gtable(lua_State *L, void *p) {
    lua_rawgetp(L, LUA_REGISTRYINDEX, p);
    luaL_checktype(L, -1, LUA_TTABLE);
}

static void
_push_gtable(lua_State *L, void *p) {
    lua_rawgetp(L, LUA_REGISTRYINDEX, p);
    if (lua_istable(L,-1)) return;
    lua_pop(L,1);
    lua_newtable(L);
    lua_pushvalue(L,-1);
    lua_rawsetp(L, LUA_REGISTRYINDEX, p);
}

static int
_ref_function(lua_State *L, int index) {
    //
    _push_gtable(L, &funcid_table_index);
    lua_pushvalue(L,index);
    lua_rawget(L,-2);
    int functionid;
    if (lua_type(L,-1) != LUA_TNUMBER) {
        lua_pop(L,1);
        functionid = _nextid();
        lua_pushvalue(L,index);
        lua_pushinteger(L,functionid);
        lua_rawset(L,-3);
    } else {
        functionid = lua_tointeger(L,-1);
        lua_pop(L,1);
    }
    lua_pop(L,1);
    //
    _push_gtable(L, &idfunc_table_index);
    lua_pushinteger(L,functionid);
    lua_rawget(L,-2);
    if (lua_type(L,-1) != LUA_TFUNCTION) {
        lua_pop(L,1);
        lua_pushinteger(L,functionid);
        lua_pushvalue(L,index);
        lua_rawset(L,-3);
    } else {
        lua_pop(L,1);
    }
    lua_pop(L,1);

    //
    _push_gtable(L, &count_table_index);
    lua_pushinteger(L,functionid);
    lua_rawget(L,-2);
    int count;
    if (lua_type(L,-1) != LUA_TNUMBER)
        count = 1;
    else
        count = lua_tointeger(L,-1)+1;
    lua_pop(L,1);
    lua_pushinteger(L,functionid);
    lua_pushinteger(L,count);
    lua_rawset(L,-3);
    lua_pop(L,1);

    _push_gtable(L, &count_table_index);
    lua_pushinteger(L,functionid);
    lua_pushinteger(L,1);
    lua_rawset(L,-3);
    lua_pop(L,1);
    return functionid;
}

static void
_release_function(lua_State *L, int functionid) {
    _get_gtable(L, &count_table_index);
    lua_pushinteger(L,functionid);
    lua_rawget(L,-2);
    int count = luaL_checkinteger(L,-1);
    lua_pop(L,1);
    count--;
    if (count > 0) {
        lua_pushinteger(L,functionid);
        lua_pushinteger(L,count);
        lua_rawset(L,-3);
        lua_pop(L,1);
    } else {
        assert(count==0);
        lua_pushinteger(L,functionid);
        lua_pushnil(L);
        lua_rawset(L,-3);
        lua_pop(L,1);

        _get_gtable(L,&idfunc_table_index);
        lua_pushinteger(L,functionid);
        lua_rawget(L,-2); // top is function
        lua_pushinteger(L,functionid);
        lua_pushnil(L);
        lua_rawset(L,-4); // top is function, table
        
        _get_gtable(L,&funcid_table_index); // top +table
        lua_pushvalue(L,-2);
        lua_pushnil(L);
        lua_rawset(L,-3);
        lua_pop(L,3);
    }
}

static char *
_parse_args(lua_State *L, JNIEnv *env, jvalue *args, int argc, char *param) {
    char *p = param;
    *p++ = '(';
    int i;
    for (i=0; i<argc; ++i) {
        int idx = i+4;
        int type = lua_type(L,idx);
        switch (type) {
        case LUA_TBOOLEAN:
            args[i].z = lua_toboolean(L,idx)!=0 ? JNI_TRUE: JNI_FALSE;
            *p++ = 'Z';
            break;
        case LUA_TNUMBER: {
            float f = lua_tonumber(L,idx);
            int n = (int)f;
            if (f >n) { args[i].f = f; *p++ = 'F';
            } else {    args[i].i = n; *p++ = 'I';
            }}
            break;
        case LUA_TSTRING:
            args[i].l = (*env)->NewStringUTF(env, lua_tostring(L,idx));
            memcpy(p, "Ljava/lang/String;", 18);
            p+=18;
            break;
        default:
            luaL_argerror(L,idx,"Invalid arg type");
        }
    }
    return p;
}

static char *
_parse_ret(lua_State *L, const char *s, struct _value_info *ret, char *p) {
    switch (s[0]) {
    case 'V': ret->type = VT_VOID;    *p++ = 'V'; break;
    case 'Z': ret->type = VT_BOOLEAN; *p++ = 'Z'; break;
    case 'I': ret->type = VT_INT;     *p++ = 'I'; break;
    case 'F': ret->type = VT_FLOAT;   *p++ = 'F'; break;
    case 'S': ret->type = VT_STRING;  memcpy(p,"Ljava/lang/String;",18); p+=18; break;
    default: luaL_error(L, "invalid return type");
    }
    return p;
}

static void
_execute(struct jni_methodinfo *info, 
        struct _value_info *ret) {
    switch (ret->type) {
    case VT_VOID:
        (*info->env)->CallStaticVoidMethod(info->env, info->jc, info->jmid);
        break;
    case VT_BOOLEAN:
        ret->i = (*info->env)->CallStaticBooleanMethod(info->env, info->jc, info->jmid);
        break;
    case VT_INT:
        ret->i = (*info->env)->CallStaticIntMethod(info->env, info->jc, info->jmid);
        break;
    case VT_FLOAT:
        ret->f = (*info->env)->CallStaticFloatMethod(info->env, info->jc, info->jmid);
        break;
    case  VT_STRING:
        ret->s = (jstring)(*info->env)->CallStaticObjectMethod(info->env, info->jc, info->jmid);
        break;
    }
}

static void
_execute_withargs(struct jni_methodinfo *info, 
        jvalue *args, 
        struct _value_info *ret) {
    switch (ret->type) {
    case VT_VOID:
    case VT_FUNCTION:
        (*info->env)->CallStaticVoidMethodA(info->env, info->jc, info->jmid, args);
        break;
    case VT_BOOLEAN:
        ret->i = (*info->env)->CallStaticBooleanMethodA(info->env, info->jc, info->jmid, args);
        break;
    case VT_INT:
        ret->i = (*info->env)->CallStaticIntMethodA(info->env, info->jc, info->jmid, args);
        break;
    case VT_FLOAT:
        ret->f = (*info->env)->CallStaticFloatMethodA(info->env, info->jc, info->jmid, args);
        break;
    case  VT_STRING:
        ret->s = (jstring)(*info->env)->CallStaticObjectMethodA(info->env, info->jc, info->jmid, args);
        break;
    }
}

static int
_push_ret(lua_State *L, JNIEnv *env, struct _value_info *ret) {
    switch (ret->type) {
    case VT_BOOLEAN:
        lua_pushboolean(L,ret->i);
        return 1;
    case VT_INT:
    case VT_FUNCTION:
        lua_pushinteger(L,ret->i);
        return 1;
    case VT_FLOAT:
        lua_pushnumber(L,ret->f);
        return 1;
    case VT_STRING: {
        const char *s = (*env)->GetStringUTFChars(env,ret->s,0);
        lua_pushstring(L,s);
        (*env)->ReleaseStringUTFChars(env,ret->s,s);
        return 1;
        }
    default: return 0;
    }
}

#define MAX_ARGS 9
static int 
lcallstaticmethod(lua_State* L) { 
    int top = lua_gettop(L);
    if (top < 3) {
        luaL_error(L, "no engouht argument");
    }
    if (top > MAX_ARGS+3) {
        luaL_error(L, "too much argments");
    }
    JNIEnv *env = jni_helper_env();
    jvalue args[MAX_ARGS+1];
    char param[(MAX_ARGS+1)*18+3];
    int argc = top-3;
    char *p = _parse_args(L, env, args, argc, param);
    
    struct _value_info ret;
    switch (lua_type(L,3)) {
    case LUA_TSTRING: {
        size_t l;
        const char *s = luaL_checklstring(L,3,&l);
        if (l==0) {
            luaL_argerror(L,3,"return type is empty");
        }
        *p++ = ')';
        pf_log("_parse_ret: %s", s);
        p = _parse_ret(L,s,&ret,p);
        break;
        }
    case LUA_TFUNCTION:
        memcpy(p,"I)V",3); 
        p+=3;
        int id = _ref_function(L,3);
        args[argc++].i = id;
        ret.type = VT_FUNCTION;
        ret.i = id;
        break;
    default:
        luaL_argerror(L,3,"invalid return type");
    }
    *p='\0';
    const char *class = luaL_checkstring(L,1);
    const char *method = luaL_checkstring(L,2);
    struct jni_methodinfo info;
    if (!jni_helper_getstaticmethodinfo(class, method, param, &info)) { 
        if (argc >0) _execute_withargs(&info, args, &ret);
        else _execute(&info, &ret);
        return _push_ret(L,info.env,&ret);
    } else
        return 0;
}

//static int
//test(lua_State *L) {
    //luaL_checktype(L,1,LUA_TFUNCTION);
    //int id = _ref_function(L,1);
    //_release_function(L,id);
//}

int
javabridge_tolua(lua_State *L) {
    _L = L;
    luaL_Reg l[] = { 
        { "callstaticmethod", lcallstaticmethod },
        //{ "test", test},
        { NULL, NULL },
    }; 
    luaL_newlib(L, l);
    return 1;
}

static int                                        
_traceback(lua_State *L) {                        
    const char *msg = lua_tostring(L, 1);
    if (msg) luaL_traceback(L, L, msg, 1);
    else lua_pushliteral(L, "(no error message)");
    return 1;
}

int
javabridge_calllua(int functionid, const char *arg) {
    pf_log("javabridge_calllua id=%d ...", functionid);
    assert(_L);
    lua_State *L = _L;
    
    int top = lua_gettop(L);
    lua_rawgetp(L, LUA_REGISTRYINDEX, &idfunc_table_index);
    if (!lua_istable(L,-1)) { 
        pf_log("javabridge_calllua no table");
        lua_settop(L, top);
        return 1;
    }
    //lua_pushcfunction(L,_traceback);
    //int trace = lua_gettop(L);

    lua_pushinteger(L,functionid);
    lua_rawget(L, -2);

    if (lua_type(L, -1) != LUA_TFUNCTION) {
        lua_settop(L,top); 
        pf_log("javabridge_calllua no function");
        return 1;
    }
    lua_pushinteger(L,functionid);
    lua_pushstring(L, arg);

    _release_function(L, functionid);
    int r = lua_pcall(L, 2, 0, 0);
    if (r != LUA_OK) {
        pf_log("javabridge_calllua fail %s", lua_tostring(L,-1));
    } else {
        pf_log("javabridge_calllua ok");
    }
    lua_settop(L,top);
    
    return r != LUA_OK ? 1 : 0;
}
