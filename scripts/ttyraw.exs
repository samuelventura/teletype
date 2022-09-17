#mix run scripts/ttyraw.exs

alias Teletype.Nif

:ok = Nif.ttyraw(Nif.ttypath())
