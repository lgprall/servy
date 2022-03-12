defmodule Servy.View do
  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, path, binding \\ []) do

    content = 
      @templates_path
      |> Path.join(path)
      |> EEx.eval_file(binding)

    %{ conv | status: 200, resp_body: content }
  end
end
