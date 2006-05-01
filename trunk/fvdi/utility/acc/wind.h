#ifndef _WIND_H
#define _WIND_H

#define MAX_WINDOWS 32

typedef struct _Window {
   struct _Window *next;
   int handle;
   int (*handler)(struct _Window *, int, short *, int, int, int, int, int, int);
   void *ptr;
   int (*func)(int);
   int new;
   short tmp[8];
} Window;
#endif
