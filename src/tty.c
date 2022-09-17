#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <stddef.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>
#include <signal.h>
#include <pthread.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef __linux__
#include <linux/vt.h>
#include <linux/kd.h>
#endif

#define UNUSED(x) (void)(x)

void crash(const char* fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  fprintf(stderr, "crash: ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\r\n");
  fprintf(stderr, "error: %d %s", errno, strerror(errno));
  fprintf(stderr, "\r\n");
  fflush(stderr);
  exit(-1);
  abort();
}


int main(int argc, char *argv[]) {
#ifdef __linux__
  if (argc < 2) crash("argc %d", argc);
  int tn = atoi(argv[1]);
  int fd = open("/dev/tty0", O_RDWR);
  if (fd < 0) crash("open /dev/tty0");
  if (ioctl(fd, VT_ACTIVATE, tn)) crash("tty VT_ACTIVATE");
  if (ioctl(fd, VT_WAITACTIVE, tn)) crash("tty VT_WAITACTIVE");
  if (close(fd)) crash("close /dev/tty0");
#else
  UNUSED(argc);
  UNUSED(argv);
  crash("unsupported OS");
#endif
  return 0;
}
