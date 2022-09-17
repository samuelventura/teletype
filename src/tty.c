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

int name(int argc, char *argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  printf("%s\n", ttyname(0));
  return 0;
}

int raw(int argc, char *argv[]) {
  UNUSED(argc);
  const char *ttypath = argc < 3? ttyname(0) : argv[2];
  int fd = open(ttypath, O_RDWR|O_NOCTTY);
  if (fd<0) crash("open %s", ttypath);
  struct termios ts;
  if (tcgetattr(fd, &ts)) crash("tcgetattr %s", ttypath);
  ts.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
                  | INLCR | IGNCR | ICRNL | IXON);
  ts.c_oflag &= ~OPOST;
  ts.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
  ts.c_cflag &= ~(CSIZE | PARENB);
  ts.c_cflag |= CS8;
  if (tcsetattr(fd, TCSAFLUSH, &ts)) crash("tcsetattr %s", ttypath);
  if (close(fd)) crash("close %s", ttypath);
  return 0;
}

int reset(int argc, char *argv[]) {
  UNUSED(argc);
  const char *ttypath = argc < 3? ttyname(0) : argv[2];
  int fd = posix_openpt(O_RDWR|O_NOCTTY);
  struct termios ts;
  if (tcgetattr(fd, &ts)) crash("tcgetattr %s", ttypath);
  if (close(fd)) crash("close1 %s", ttypath);
  fd = open(ttypath, O_RDWR|O_NOCTTY);
  if (fd<0) crash("open %s", ttypath);
  if (tcsetattr(fd, TCSAFLUSH, &ts)) crash("tcsetattr %s", ttypath);
  if (close(fd)) crash("close %s", ttypath);
  return 0;
}

int chvt(int argc, char *argv[]) {
#ifdef __linux__
  if (argc < 3) crash("argc %d", argc);
  int tn = atoi(argv[2]);
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

int main(int argc, char *argv[]) {
  if (argc < 2) crash("argc %d", argc);
  if (strcmp(argv[1], "name") == 0) 
  {
    return name(argc, argv);
  }
  if (strcmp(argv[1], "chvt") == 0) 
  {
    return chvt(argc, argv);
  }
  if (strcmp(argv[1], "raw") == 0) 
  {
    return raw(argc, argv);
  }
  if (strcmp(argv[1], "reset") == 0) 
  {
    return reset(argc, argv);
  }
  crash("invalid option: %s", argv[1]);
  return 0;
}
