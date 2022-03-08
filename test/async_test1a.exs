defmodule ServerTest1a do
  use ExUnit.Case
  doctest Servy

  test "test running tests with Task" do
    url = "http://localhost:4000/wildthings"
    spawn(Servy.HttpServer, :start, [4000])

    1..5
    |> Enum.map(fn _ -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_suc_res/1)
  end

  defp assert_suc_res({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end
end
