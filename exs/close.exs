# mix run exs/close.exs
# exit with Ctrl+c

alias Teletype.Pts

# should not except
pts = Pts.open()
:ok = Pts.close(pts)

# should except but still reset
pts = Pts.open()
:timer.sleep(400)
System.cmd("killall", ["-9", "pts"])
:timer.sleep(400)
# check tty reset despite ArgumentError
:ok = Pts.close(pts)
