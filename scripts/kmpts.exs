# mix run scripts/kmpts.exs
# exit with Ctrl+c

alias Teletype.Pts

pts = Pts.open()

Enum.any?(Stream.cycle(0..1), fn _ ->
  data = Pts.read!(pts)
  IO.puts("#{inspect(data)}\r")
  data == <<3>>
end)

Teletype.reset()
