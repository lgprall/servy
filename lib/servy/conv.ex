defmodule Servy.Conv do
  defstruct( method: "",
             path: "",
             params: %{},
             headers: %{},
             resp_headers: %{ "Content-Type" => "text/html" },
             resp_body: "",
             status: nil
  )
  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  def put_resp_content_type(conv, string) do
    %{ conv | resp_headers: Map.put(conv.resp_headers, "Content-Type", string) }
  end

  def content_length(conv) do
    %{ conv | resp_headers: Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))}
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
  
end
