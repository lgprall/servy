defmodule ServerTest do
  use ExUnit.Case
  doctest Servy
  
  alias Servy.HttpClient

  spawn Servy.HttpServer, :start, [4000]

  test "wildthings" do
    request = """ 
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser 1.0\r
    Accept: */*\r
    \r
    """
    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """

  end

  test "wildlife" do
    request = """ 
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "DELETE" do
    request = """
    DELETE /bear/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 403 Forbidden\r
    Content-Type: text/html\r
    Content-Length: 40\r
    \r
    You are not allowed to delete an animal.
    """
  end
  
  test "/bears" do
    request = """ 
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 427\r
    \r
      <h1>All The Bears!</h1>

      <ul>
	  
          <li>(6) - Brutus  - Grizzly </li>
        
          <li>(9) - Iceman  - Polar </li>
        
          <li>(10) - Kenai  - Grizzly </li>
        
          <li>(3) - Paddington  - Brown </li>
        
          <li>(8) - Roscoe  - Panda </li>
        
          <li>(7) - Rosie  - Black </li>
        
          <li>(4) - Scarface  - Grizzly </li>
        
          <li>(2) - Smokey  - Black </li>
        
          <li>(5) - Snow  - Polar </li>
        
          <li>(1) - Teddy  - Brown </li>
        
      </ul>
    """
    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "/bear/1" do

    request = """ 
    GET /bear/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response === """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 71\r
    \r
    <h1>Show Bear</h1>
    <p>Is Teddy hibernating? <strong>true</strong>
    </p>

    """
  end

  test "/bear?id=6" do
    request = """ 
    GET /bear?id=6 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 73\r
    \r
    <h1>Show Bear</h1>
    <p>Is Brutus hibernating? <strong>false</strong>
    </p>

    """
  end

  test "/bear/two" do
    request = """ 
    GET /bear/two HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 403 Forbidden\r
    Content-Type: text/html\r
    Content-Length: 18\r
    \r
    Invalid query: two
    """
  end

  test "GET /bigfoot" do

    request = """ 
    GET /bigfoot HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response === """
    HTTP/1.1 404 Not Found\r
    Content-Type: text/html\r
    Content-Length: 17\r
    \r
    No /bigfoot here!
    """
  end

  test "GET /lions 2" do

    request = """ 
    GET /lions/2 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 6\r
    \r
    Lion 2
    """
  end

  test "GET /tigers?id=4" do
    request = """ 
    GET /tigers?id=4 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 7\r
    \r
    Tiger 4
    """
  end

  test "GET /about" do
    request = """ 
    GET /about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 324\r
    \r
    <h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe as one great dewdrop, 
    striped and dotted with continents and islands, flying through 
    space with other stars all singing and shining together as one, 
    the whole universe appears as an infinite storm of beauty. 
    -- John Muir
    </blockquote>

    """
  end

  test "/bears/new" do
    request = """ 
    GET /bears/new HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 240\r
    \r
    <form action="/bears" method="POST">
      <p>
        Name:<br/>
        <input type="text" name="name">    
      </p>
      <p>
        Type:<br/>
        <input type="text" name="type">    
      </p>
      <p>
        <input type="submit" value="Create Bear">
      </p>
    </form>

    """
  end

  test "GET/pages/contacts" do

    request = """ 
    GET /pages/contacts HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """


    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 16\r
    \r
    Contact data...

    """
  end

  test "GET /pages/faq.md" do
    request = """ 
    GET /pages/faq.md HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """
        
    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 664\r
    \r
    <h1>
    Frequently Asked Questions</h1>
    <ul>
      <li>
        <p>
    <strong>Have you really seen Bigfoot?</strong>    </p>
        <p>
      Yes! In this <a href="https://www.youtube.com/watch?v=v77ijOO8oAk">totally believable video</a>!    </p>
      </li>
      <li>
        <p>
    <strong>No, I mean seen Bigfoot <em>on the refuge</em>?</strong>    </p>
        <p>
      Oh! Not yet, but we&#39;re <em>still looking</em>...    </p>
      </li>
      <li>
        <p>
    <strong>Can you just show me some code?</strong>    </p>
        <p>
      Sure! Here&#39;s some Elixir:    </p>
        <pre><code class="elixir">  [&quot;Bigfoot&quot;, &quot;Yeti&quot;, &quot;Sasquatch&quot;] |&gt; Enum.random()</code></pre>
      </li>
    </ul>

    """
      end

  test "POST /bears" do

    request = """ 
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-encoded\r
    Content-length: 21\r
    \r
    name=Baloo&type=Brown
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 201 Created\r
    Content-Type: text/html\r
    Content-Length: 32\r
    \r
    Create a Brown bear named Baloo!
    """
  end

  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 605\r
    \r
    [{"type":"Brown","name":"Teddy","id":1,"hibernating":true},
     {"type":"Black","name":"Smokey","id":2,"hibernating":false},
     {"type":"Brown","name":"Paddington","id":3,"hibernating":false},
     {"type":"Grizzly","name":"Scarface","id":4,"hibernating":true},
     {"type":"Polar","name":"Snow","id":5,"hibernating":false},
     {"type":"Grizzly","name":"Brutus","id":6,"hibernating":false},
     {"type":"Black","name":"Rosie","id":7,"hibernating":true},
     {"type":"Panda","name":"Roscoe","id":8,"hibernating":false},
     {"type":"Polar","name":"Iceman","id":9,"hibernating":true},
     {"type":"Grizzly","name":"Kenai","id":10,"hibernating":false}]
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /api/bears" do
	request = """
	POST /api/bears HTTP/1.1\r
	Host: example.com\r
	User-Agent: ExampleBrowser/1.0\r
	Accept: */*\r
	Content-Type: application/json\r
	Content-Length: 21\r
	\r
	{"name": "Breezly", "type": "Polar"}
	"""

	response = HttpClient.send_request(request)

	assert response == """
	HTTP/1.1 201 Created\r
	Content-Type: text/html\r
	Content-Length: 35\r
	\r
	Created a Polar bear named Breezly!
	"""
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end 
end
