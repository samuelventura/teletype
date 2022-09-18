# mix run scripts/kmpts.exs
# exit with Ctrl+c

alias Teletype.Pts

pts = Pts.open()
Pts.write!(pts, "\ec\e[?25l\e[?1000h\e[?1006h\e[3 q")
Enum.any?(Stream.cycle(0..1), fn _ ->
  data = Pts.read!(pts)
  IO.puts("#{inspect(data)}\r")
  data == <<3>>
end)
Pts.close(pts)
