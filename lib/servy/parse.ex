defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, param_strings] = String.split(request, "\n\n" )

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{} )

    params = parse_params(headers["Content-Type"], param_strings)

    %Conv{
      method:  method,
      path:    path,
      params:  params,
      headers: headers
    }
  end

  def parse_headers([head|tail], headers) do

    [key,value] = String.split(head, ": ")

    headers = Map.put(headers, key, value) 

    parse_headers(tail, headers)

  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-encoded",param_strings) do
    param_strings |> String.trim |> URI.decode_query
  end

  def parse_params(_,_), do: %{}

end
