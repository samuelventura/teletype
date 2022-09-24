# mix run exs/kmpts.exs
# exit with Ctrl+c

alias Teletype.Pts

pts = Pts.open()
# do not include cursor hide
Pts.write!(pts, "\ec\e[?1000h\e[?1006h\e[3 q")

Enum.any?(Stream.cycle(0..1), fn _ ->
  data = Pts.read!(pts)
  IO.puts("#{inspect(data)}\r")
  data == <<3>>
end)

Pts.close(pts)
