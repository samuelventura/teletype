#include "erl_nif.h"
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define UNUSED(x) (void)(x)

static ERL_NIF_TERM nif_ttyraw(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "Invalid argument count", ERL_NIF_LATIN1));
  }
  ErlNifBinary device;
  if (!enif_inspect_binary(env, argv[0], &device)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "Argument 0 is not a binary", ERL_NIF_LATIN1));
  }  
  const char *ttyname = (const char *)device.data;
  int fd = open(ttyname, O_RDWR|O_NOCTTY);
  if (fd<0) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open failed", ERL_NIF_LATIN1));
  }
  struct termios ts;
  if (tcgetattr(fd, &ts)) {
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
  if (argc != 1) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "Invalid argument count", ERL_NIF_LATIN1));
  }
  ErlNifBinary device;
  if (!enif_inspect_binary(env, argv[0], &device)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "Argument 0 is not a binary", ERL_NIF_LATIN1));
  }  
  int fd = posix_openpt(O_RDWR|O_NOCTTY);
  struct termios ts;
  if (tcgetattr(fd, &ts)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcgetattr failed", ERL_NIF_LATIN1));
  }
  if (close(fd)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close1 failed", ERL_NIF_LATIN1));
  }
  const char *ttyname = (const char *)device.data;
  fd = open(ttyname, O_RDWR|O_NOCTTY);
  if (fd<0) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "open failed", ERL_NIF_LATIN1));
  }  
  if (tcsetattr(fd, TCSAFLUSH, &ts)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "tcsetattr failed", ERL_NIF_LATIN1));
  }
  if (close(fd)) {
    return enif_make_tuple2(
        env, enif_make_atom(env, "er"),
        enif_make_string(env, "close2 failed", ERL_NIF_LATIN1));
  }
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM nif_ttyname(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  return enif_make_string(env, ttyname(0), ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] = {
  {"ttyreset", 1, nif_ttyreset, 0},
  {"ttyname", 0, nif_ttyname, 0},
  {"ttyraw", 1, nif_ttyraw, 0},
};

ERL_NIF_INIT(Elixir.Teletype.Nif, nif_funcs, NULL, NULL, NULL, NULL)
