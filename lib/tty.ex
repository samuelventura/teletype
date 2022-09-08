defmodule Teletype.Tty do
  alias Teletype.Slave

  def open(tty), do: Slave.open(tty)

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
end
