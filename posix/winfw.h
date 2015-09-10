#ifndef ejoy2d_windows_fw_h
#define ejoy2d_windows_fw_h

#define WIDTH 800
#define HEIGHT 600 

#define TOUCH_BEGIN 0
#define TOUCH_END 1
#define TOUCH_MOVE 2

void ejoy2d_win_init();
void ejoy2d_win_frame();
void ejoy2d_win_update(float s);
void ejoy2d_win_touch(int x, int y,int touch);
void ejoy2d_win_key(int key, int type);
void ejoy2d_win_resize(int w, int h);

#endif
