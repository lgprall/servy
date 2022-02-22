defmodule Servy.Handler do

  import Servy.Plugins, only: [log: 1, track: 1, rewrite_path: 1]
  import Servy.Parser, only: [parse: 1]

  alias Servy.Conv
  alias Servy.BearController

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms an HTTP request in to a response"
  def handle(request) do
    request 
    |> parse
    |> log
    |> rewrite_path
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{method: "DELETE"} = conv) do
    %{ conv | status: 403, resp_body: "You are not allowed to delete an animal."}
  end
  
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    file = @pages_path
          |> Path.join("about.html")
      
    case File.read(file) do
      {:ok, contents } ->
        %{ conv | status: 200, resp_body: contents }
      {:error, :enoent } ->
        %{ conv | status: 404, resp_body: "File not found!" }
      {:error, reason }  ->
        %{ conv | status: 500, resp_body: "System error: #{reason}" }
    end
  end

  def route(%Conv{method: "GET", path: "/pages/" <> target} = conv) do
    file = @pages_path
        |> Path.join(target)
      
    case File.read(file) do
      {:ok, contents } ->
        %{ conv | status: 200, resp_body: contents }
      {:error, :enoent } ->
        %{ conv | status: 404, resp_body: "File not found!" }
      {:error, reason }  ->
        %{ conv | status: 500, resp_body: "System error: #{reason}" }
    end
  end

  def route(%Conv{method: "GET", path:  "/wildthings"} = conv  )do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end
    
  def route(%Conv{method: "GET", path:  "/bears"} = conv  ) do
    BearController.index(conv)
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv ) do
  # name=Baloo&type=Brown
    %{ conv | status: 201,
           resp_body: "Create a #{conv.params["type"]} bear named #{conv.params["name"]}!"
    }
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    file = @pages_path
        |> Path.join("form.html")
    result = File.read(file)
    handle_file(result, conv)
  end

  def route(%{method: "GET", path:  "/bears/" <> id} = conv  )do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%Conv{ path: path} = conv) do
    if target =  Regex.named_captures(~r/(?<thing>\w+)\/(?<id>\d+)/, path) do
      thing = target["thing"]; id = target["id"]
      thing = thing
              |> String.reverse
              |> String.to_charlist
              |> tl
              |> List.to_string
              |> String.reverse
              |> String.capitalize
    %{ conv | status: 200, resp_body: "#{thing} #{id}" }
    else
    %{ conv | status: 404, resp_body: "No #{path} here!"}
    end
  end



#  def route(%{ path:  path} = conv  )do
#   %{ conv | status: 404, resp_body: "No #{path} here!"}
#  end

  def handle_file({:error, :enoent}, conv ) do
    %{conv | status: 404, resp_body: "File not found!" }
  end

  def handle_file({:error, reason}, conv ) do
    %{conv | status: 500, resp_body: "System error: #{reason}" }
  end
    
  def handle_file({:ok, contents}, conv ) do
    %{conv | status: 200, resp_body: contents }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
  
    """
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser 1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears?id=6 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/two HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /lions/2 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /tigers?id=4 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /pages/contacts HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


request = """
GET /pages/faq.md HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-encoded
Content-length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response

