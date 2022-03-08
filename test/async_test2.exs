defmodule ServerTest1a do
  use ExUnit.Case
  doctest Servy

  test "test running tests with Task" do
    spawn(Servy.HttpServer, :start, [4000])

    [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/bear/1",
      "http://localhost:4000/bears",
      "http://localhost:4000/api/bears"
    ]
    |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_suc_res/1)
  end

  defp assert_suc_res({:ok, response}) do
    assert response.status_code == 200
  end
end
