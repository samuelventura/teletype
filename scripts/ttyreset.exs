#mix run scripts/ttyreset.exs

alias Teletype.Nif

:ok = Nif.ttyreset(Nif.ttypath())
