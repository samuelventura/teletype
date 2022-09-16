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

#define UNUSED(x) (void)(x)
#define MAX(x, y) (x>y?x:y)
#define MAX3(x, y, z) (x>y?MAX(x,z):MAX(y,z))

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

int fd;
int pfd;

static void signal_handler(int sig) {
  switch(sig) {
    case SIGWINCH:
    if (write(pfd, &sig, 1)!=1) crash("pipe write");
    break;
  }
}

static void signal_setup(int sig) {
  struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = signal_handler;
	sa.sa_flags = 0;
	if (sigaction(sig, &sa, 0)) crash("sigaction %d", sig);
}

//during development pts wont receive resize signal because it 
//doesn't have a controlling tty, during production no resize
//will be needed.
//pts will need to update if resize signal is ever needed in 
//the future and it is not paired with this devel ptm.
void copy_size(int send) {
  struct winsize ts;
  if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ts)) crash("ioctl TIOCGWINSZ %d", fd);
  if (ioctl(fd, TIOCSWINSZ, &ts)) crash("ioctl TIOCSWINSZ %d", fd);
  if (send) dprintf(fd, "\x1B[%d;%dR", ts.ws_row, ts.ws_col);
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

// ptm transmits the resize escape sequence so that the
// development pts does not have to register a signal handler
// which in turn requires ioctl(fd, TIOCSCTTY) which severes
// the ptm pts on pts port exit.
// cat and echo over the pts pts can reuse the same pts pts
// (by keeping the pts device open from the ptm)
// but 'mix run tryout/try_hello.exs', which talks to tty_pts
// over an erlang port, puts the ptm pts on a unrecoverable
// state where select return immediately and read 0 bytes despite
// fcntl(fd, F_GETFD) returning 0.
int main(int argc, char *argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  int rp[2];
  fd_set fds;
  unsigned char buf[256];
  char *link = "/tmp/teletype.pts";
  if (argc>1) link = argv[1];
  unlink(link);
  fd = posix_openpt(O_RDWR|O_NOCTTY);
  if (fd<0) crash("open ptm %d", fd);
  if (unlockpt(fd)) crash("unlockpt %d", fd);
  if (grantpt(fd)) crash("grantpt %d", fd);
  char * ptsn = ptsname(fd);
  if (symlink(ptsn, link)) crash("symlink");
  //for pts reuse and stty changes preservation
  int sfd = open(ptsn, O_RDWR|O_NOCTTY);
  if (sfd<0) crash("open pts %d", sfd);
  if (pipe(rp)) crash("pipe");
  pfd = rp[1];
  make_raw(STDIN_FILENO);
  signal_setup(SIGWINCH);
  make_raw(fd); //prevent size echo
  copy_size(0);
  int max = MAX3(rp[0], fd, STDIN_FILENO);
  while (1) {
    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    FD_SET(rp[0], &fds);
    FD_SET(STDIN_FILENO, &fds);
    int r = select(max + 1, &fds, 0, 0, 0);
    if (r <= 0) continue; //-1 on resize signal
    if (FD_ISSET(fd, &fds)) {
      int n = read(fd, buf, sizeof(buf));
      if (n <= 0) crash("read fd %d", n);
      int w = write(STDOUT_FILENO, buf, n);
      if (w != n) crash("write STDOUT_FILENO %d!=%d", w, n);
    }
    if (FD_ISSET(STDIN_FILENO, &fds)) {
      int n = read(STDIN_FILENO, buf, sizeof(buf));
      if (n <= 0) crash("read STDIN_FILENO %d", n);
      int w = write(fd, buf, n);
      if (w != n) crash("write fd %d", w);
    }
    if (FD_ISSET(rp[0], &fds)) {
      int n = read(rp[0], buf, sizeof(buf));
      if (n <= 0) crash("read rp[0] %d", n);
      copy_size(1);
    }
  }
  return 0;
}
