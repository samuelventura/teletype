# mix run exs/close.exs
# exit with Ctrl+c

alias Teletype.Pts
alias Teletype.Nif

pts = Pts.open()
:timer.sleep(400)
System.cmd("killall", ["-9", "pts"])
:timer.sleep(400)
# check tty reset despite ArgumentError
# stack trace expected to show on screen
Pts.close(pts)
