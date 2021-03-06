defmodule Servy.Handler do

  import Servy.Plugins, only: [log: 1, track: 1, rewrite_path: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.Conv, only: [content_length: 1]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

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
    |> content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/sensors" } = conv) do

    task = Task.async(Servy.Tracker, :get_location,["bigfoot"])
    snapshots =
    ["cam-1","cam-2","cam-3"]
    |> Enum.map(&Task.async(VideoCam, :get_snapshot,[&1]))
    |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{conv | status: 200, resp_body: inspect({snapshots, where_is_bigfoot})}
  end

  def route(%Conv{method: "GET", path: "/kaboom" }= _conv) do
    raise("Kaboom!")
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    String.to_integer(time) |> :timer.sleep
    %{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{method: "DELETE", path: "/bear/" <> _id} = conv) do
    IO.inspect(conv)
    BearController.delete(conv)
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
    if Regex.match?(~r/\.md$/, target) do
      proc_markdown(conv, target)
    else
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
  end

  def route(%Conv{method: "GET", path:  "/wildthings"} = conv  )do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end
    
  def route(%Conv{method: "GET", path:  "/bears"} = conv  ) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv ) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path:  "/api/bears"} = conv  ) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path:  "/api/bears"} = conv  ) do
    Servy.Api.BearController.create(conv)
  end
 
  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    file = @pages_path
        |> Path.join("form.html")
    result = File.read(file)
    handle_file(result, conv)
  end

  def route(%{method: "GET", path:  "/bear/" <> id} = conv  ) do
    if Integer.parse(id) != :error and String.to_integer(id) <= Enum.count(Servy.Wildthings.list_bears) do
      params = Map.put(conv.params, "id", id)
      BearController.show(conv, params)
    else
        %{conv | status: 403, resp_body: "Invalid query: #{id}"}
    end

  end

  def route(%Conv{ path: path} = conv) do
    if target =  Regex.named_captures(~r/(?<thing>\w+)\/(?<id>\d+)/, path) do
      thing = target["thing"]; id = target["id"]
      thing = thing |> String.capitalize
      if Regex.match?(~r/s$/, thing) do
        t = thing|> String.reverse
              |> String.to_charlist
              |> tl
              |> List.to_string
              |> String.reverse
        %{ conv | status: 200, resp_body: "#{t} #{id}" }
      else
        %{ conv | status: 200, resp_body: "#{thing} #{id}" }
      end
    else
    %{ conv | status: 404, resp_body: "No #{path} here!"}
    end
  end

  def proc_markdown(conv, target) do
    file = @pages_path |> Path.join(target)
    contents = File.read!(file)
                |> Earmark.as_html!
    pfix = ~s(<meta charset="UTF-8">\n)
    %{ conv | status: 200, resp_body: pfix <> contents }
  end

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
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{conv.resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end

end

