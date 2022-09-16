#include "erl_nif.h"
#include <unistd.h>

#define UNUSED(x) (void)(x)

static ERL_NIF_TERM nif_ttyname(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  UNUSED(argc);
  UNUSED(argv);
  return enif_make_string(env, ttyname(0), ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] = {
  {"ttyname", 0, nif_ttyname, 0}
};

ERL_NIF_INIT(Elixir.Teletype.Nif, nif_funcs, NULL, NULL, NULL, NULL)
