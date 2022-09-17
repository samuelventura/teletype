#mix run scripts/nifreset.exs

alias Teletype.Nif

:ok = Nif.ttyreset(Nif.ttypath())
