#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <stddef.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>

#define UNUSED(x) (void)(x)
#define MAX(x, y) (x>y?x:y)

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

void make_raw(int fd) {
  struct termios ts;
  if (tcgetattr(fd, &ts)) crash("tcgetattr %d", fd);
  ts.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
                  | INLCR | IGNCR | ICRNL | IXON);
  ts.c_oflag &= ~OPOST;
  ts.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
  ts.c_cflag &= ~(CSIZE | PARENB);
  ts.c_cflag |= CS8;
  if (tcsetattr(fd, TCSAFLUSH, &ts)) crash("tcsetattr %d", fd);
}

int main(int argc, char *argv[]) {
  unsigned char buf[256];
  fd_set fds;
  const char* ttypath = argc < 2? ttyname(0) : argv[1];
  if (ttypath==NULL) crash("ttypath NULL");
  int fd = open(ttypath, O_RDWR|O_NOCTTY);
  if (fd<0) crash("open %d", fd);
  make_raw(fd);
  int max = MAX(fd, STDIN_FILENO);
  while (1) {
    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    FD_SET(STDIN_FILENO, &fds);
    int r = select(max + 1, &fds, 0, 0, 0);
    if (r <= 0) crash("select %d", r);
    if (FD_ISSET(fd, &fds)) {
      int n = read(fd, buf, sizeof(buf));
      if (n <= 0) crash("read fd %d", n);
      int w = write(STDOUT_FILENO, buf, n);
      if (w != n) crash("write STDOUT_FILENO %d!=%d", w, n);
    }
    if (FD_ISSET(STDIN_FILENO, &fds)) {
      int n = read(STDIN_FILENO, buf, sizeof(buf));
      if (n == 0) return 0;
      if (n <= 0) crash("read STDIN_FILENO %d", n);
       //rpiX compiler complains (& 0xFFFF -> hack)
      int w = write(fd, buf, n & 0xFFFF);
      if (w != n) crash("write fd %d", w);
    }
  }
  return 0;
}
