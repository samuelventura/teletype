#mix run scripts/nifraw.exs

alias Teletype.Nif

:ok = Nif.ttyraw(Nif.ttypath())
