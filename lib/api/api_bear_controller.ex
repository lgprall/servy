defmodule Servy.Api.BearController do

  import Servy.Conv, only: [put_resp_content_type: 2]

  def index(conv) do
    json = 
      Servy.Wildthings.list_bears()
      |> Poison.encode!
    conv = put_resp_content_type( conv, "application/json" )
    %{conv | status: 200,  resp_body: json }
  end

  def create(conv) do

    %{ conv |
      status: 201,
      resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!" }
  end

end

