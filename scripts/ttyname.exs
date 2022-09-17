#mix run scripts/ttyname.exs

#c lang ttyname() fails from within the beam
#priv/tty name works from bash
{:ok, name} = Teletype.name()
name |> IO.puts
