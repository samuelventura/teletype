#include "erl_nif.h"
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <termios.h>

#define UNUSED(x) (void)(x)
ErlNifMutex *mutex = NULL;
ErlNifPid pid;

static void signal_handler(int sig) {
  switch(sig) {
    case SIGWINCH:
    enif_mutex_lock(mutex);
    enif_send(NULL, &pid, NULL, enif_make_atom(NULL, "SIGWINCH"));
    enif_mutex_unlock(mutex);
    break;
  }
}

static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM load_info) {
  UNUSED(env);
  UNUSED(priv);
  UNUSED(load_info);
  mutex = enif_mutex_create("SIGWINCH");
  enif_set_pid_undefined(&pid);
  return 0;
}

static ERL_NIF_TERM nif_ttysignal(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  enif_mutex_lock(mutex);
  int undefined = enif_is_pid_undefined(&pid);
  if (!enif_self(env, &pid)) {
    enif_mutex_unlock(mutex);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "enif_self failed", ERL_NIF_LATIN1));
  }
  if (undefined) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = signal_handler;
    sa.sa_flags = 0;
    if (sigaction(SIGWINCH, &sa, 0)) {
      enif_mutex_unlock(mutex);
      return enif_make_tuple2(
          env, enif_make_atom(env, "er"),
          enif_make_string(env, "sigaction failed", ERL_NIF_LATIN1));
    }
  }
  enif_mutex_unlock(mutex);
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM nif_ttyraw(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  const char *ttypath = ttyname(0);
  int fd = open(ttypath, O_RDWR|O_NOCTTY);
  if (fd<0) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open failed", ERL_NIF_LATIN1));
  }
  struct termios ts;
  if (tcgetattr(fd, &ts)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcgetattr failed", ERL_NIF_LATIN1));
  }
  ts.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
                  | INLCR | IGNCR | ICRNL | IXON);
  ts.c_oflag &= ~OPOST;
  ts.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
  ts.c_cflag &= ~(CSIZE | PARENB);
  ts.c_cflag |= CS8;
  if (tcsetattr(fd, TCSAFLUSH, &ts)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcsetattr failed", ERL_NIF_LATIN1));
  }
  if (close(fd)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close failed", ERL_NIF_LATIN1));
  }
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM nif_ttyreset(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  int fd = posix_openpt(O_RDWR|O_NOCTTY);
  if (fd<0) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open1 failed", ERL_NIF_LATIN1));
  }
  if (unlockpt(fd)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "unlockpt failed", ERL_NIF_LATIN1));
  }
  if (grantpt(fd)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "grantpt failed", ERL_NIF_LATIN1));
  }
  char * ptsn = ptsname(fd);
  int sfd = open(ptsn, O_RDWR|O_NOCTTY);
  if (sfd<0) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open2 failed", ERL_NIF_LATIN1));
  }
  //tcgetattr fails on master on macos
  struct termios ts;
  if (tcgetattr(sfd, &ts)) {
    close(sfd);
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcgetattr failed", ERL_NIF_LATIN1));
  }
  if (close(sfd)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close1 failed", ERL_NIF_LATIN1));
  }
  if (close(fd)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close2 failed", ERL_NIF_LATIN1));
  }
  const char *ttypath = ttyname(0);
  fd = open(ttypath, O_RDWR|O_NOCTTY);
  if (fd<0) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open3 failed", ERL_NIF_LATIN1));
  }
  // disable mouse && show cursor
  // \ec reset
  // \e[?25h show cursor
  const char reset[8] = {(char)0x1b, 'c', (char)0x1b, '[', '?', '2', '5', 'h'};
  if (write(fd, reset, 8)!=8) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "write failed", ERL_NIF_LATIN1));
  }
  if (tcsetattr(fd, TCSAFLUSH, &ts)) {
    close(fd);
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcsetattr failed", ERL_NIF_LATIN1));
  }
  if (close(fd)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close3 failed", ERL_NIF_LATIN1));
  }
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM nif_ttyname(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  return enif_make_string(env, ttyname(0), ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] = {
  {"ttysignal", 0, nif_ttysignal, 0},
  {"ttyreset", 0, nif_ttyreset, 0},
  {"ttyname", 0, nif_ttyname, 0},
  {"ttyraw", 0, nif_ttyraw, 0},
};

ERL_NIF_INIT(Elixir.Teletype.Nif, nif_funcs, &load, NULL, NULL, NULL)
