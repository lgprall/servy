defmodule ServerTestx do
  use ExUnit.Case
  doctest Servy

  test "test async running of tests " do
    urls = [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/bear/1",
      "http://localhost:4000/bears",
      "http://localhost:4000/api/bears"
    ]

    spawn(Servy.HttpServer, :start, [4000])
    parent = self()

    for url <- urls do
      spawn(fn ->
        send(
          parent,
          HTTPoison.get(url)
        )
        receive do
          {:ok, message} -> 
          assert message.status_code == 200
        end
      end)
    end
  end
end
