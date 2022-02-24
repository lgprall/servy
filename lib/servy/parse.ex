defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, param_strings] = String.split(request, "\r\n\r\n" )

    [request_line | header_lines] = String.split(top, "\r\n")

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

  @doc """
  Parses the given param string with the form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
    iex> param_string = "Name=Baloo&Type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-encoded",param_string)
    iex> %{ "Name" => "Baloo", "Type" => "Brown" }
    iex> Servy.Parser.parse_params("multipart/form-data",param_string)
    iex> %{}

  """

  def parse_params("application/x-www-form-encoded",param_string) do
    param_string |> String.trim |> URI.decode_query
  end

  def parse_params(_,_), do: %{}

end
