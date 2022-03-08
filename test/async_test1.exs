defmodule ServerTest1 do
  use ExUnit.Case
  doctest Servy

  test "test async running of tests " do
    spawn(Servy.HttpServer, :start, [4000])

    parent = self()

    for _ <- 1..5 do
      spawn(fn ->
        {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")
        send(parent, {:ok, response})
      end)
    end

    for _ <- 1..5 do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
  end
end
