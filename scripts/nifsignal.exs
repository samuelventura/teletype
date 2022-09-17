#mix run scripts/nifsignal.exs

alias Teletype.Nif

:ok = Nif.ttysignal()

receive do
  :SIGWINCH -> IO.puts("SIGWINCH")
end
