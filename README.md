# Teletype

Elixir TTY/PTY native nif/ports.

See [terminal](https://github.com/samuelventura/terminal) for a modern reactish API.

## Future

- NIF ptc
- TTY reset
- PTC resize

## Issues

- ttyname(0) works from a nif
- ttyname(0) fails from a port (NULL)
- ports fail to acquire a controlling tty
- ports fail to receive SIGWINCH signals
- ports fail to become session leaders (setsid)
