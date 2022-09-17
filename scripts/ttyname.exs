#mix run scripts/ttyname.exs

{:ok, name} = Teletype.name()
name |> IO.puts
