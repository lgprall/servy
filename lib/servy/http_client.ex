defmodule Servy.HttpClient do
  def send_request(host \\ 'localhost', request) do
    {:ok, sock} = :gen_tcp.connect(host, 4000,
                         [:binary, packet: :raw, active: :false])
    :ok = :gen_tcp.send(sock, request)
    {:ok, response} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    response
  end
end
