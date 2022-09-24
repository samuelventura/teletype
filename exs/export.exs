# mix run exs/export.exs
# exit with Ctrl+c

alias Teletype.Tcp
alias Teletype.Nif

{:ok, _} = Tcp.start_link(port: 8010)
IO.puts("Exporting #{Nif.ttyname()} to port 8010")

receive do
  {:EXIT, _, _} -> nil
end
