defmodule Teletype.Tty do
  alias Teletype.Slave

  def open(opts \\ []) do
    tty = Teletype.Nif.ttypath()
    tty = Keyword.get(opts, :tty, tty)
    Slave.open(tty)
  end

  def handle(port, {port, {:data, data}}), do: {port, true, data}
  def handle(port, _), do: {port, false}

  def write!(port, data) do
    Slave.write!(port, data)
    port
  end

  def read!(port) do
    data = Slave.read!(port)
    {port, data}
  end

  def close(port) do
    Slave.close(port)
  end
end
