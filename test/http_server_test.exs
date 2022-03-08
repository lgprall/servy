defmodule HttpServerTest do
  use ExUnit.Case
  doctest Servy

  spawn(Servy.HttpServer, :start, [4000])

  test "wildthings" do
    response = HTTPoison.get!("http://localhost:4000/wildthings")

    assert response.body == "Bears, Lions, Tigers"
    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "20"}]
    assert response.status_code == 200
  end

  test "wildlife" do
    response = HTTPoison.get!("http://localhost:4000/wildlife")

    assert response.body == "Bears, Lions, Tigers"
    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "20"}]
    assert response.status_code == 200
  end

  test "DELETE" do
    response = HTTPoison.delete!("http://localhost:4000/bear/1")

    assert response.body == "You are not allowed to delete an animal."
    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "40"}]
    assert response.status_code == 403
  end

  test "/bears" do
    response = HTTPoison.get!("http://localhost:4000/bears")
    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "427"}]
    assert response.status_code == 200

    expected_response = """
    <h1>All The Bears!</h1>

    <ul>

        <li>(6) - Brutus  - Grizzly</li>
      
        <li>(9) - Iceman  - Polar</li>
      
        <li>(10) - Kenai  - Grizzly</li>
      
        <li>(3) - Paddington  - Brown</li>
      
        <li>(8) - Roscoe  - Panda</li>
      
        <li>(7) - Rosie  - Black</li>
      
        <li>(4) - Scarface  - Grizzly</li>
      
        <li>(2) - Smokey  - Black</li>
      
        <li>(5) - Snow  - Polar</li>
      
        <li>(1) - Teddy  - Brown</li>
      
     </ul>
    """

    assert remove_whitespace(response.body) == remove_whitespace(expected_response)
  end

  test "/bear/1" do
    response = HTTPoison.get!("http://localhost:4000/bear/1")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "71"}]
    assert response.status_code == 200

    assert response.body == """
           <h1>Show Bear</h1>
           <p>Is Teddy hibernating? <strong>true</strong>
           </p>
           """
  end

  test "/bear?id=6" do
    response = HTTPoison.get!("http://localhost:4000/bear?id=6")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "73"}]
    assert response.status_code == 200

    assert response.body == """
           <h1>Show Bear</h1>
           <p>Is Brutus hibernating? <strong>false</strong>
           </p>
           """
  end

  test "/bear/two" do
    response = HTTPoison.get!("http://localhost:4000/bear/two")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "18"}]
    assert response.status_code == 403
    assert response.body == "Invalid query: two"
  end

  test "GET /bigfoot" do
    response = HTTPoison.get!("http://localhost:4000/bigfoot")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "17"}]
    assert response.status_code == 404
    assert response.body == "No /bigfoot here!"
  end

  test "GET /lions 2" do
    response = HTTPoison.get!("http://localhost:4000/lions/2")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "6"}]
    assert response.status_code == 200
    assert response.body == "Lion 2"
  end

  test "GET /tigers?id=4" do
    response = HTTPoison.get!("http://localhost:4000/tigers?id=4")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "7"}]
    assert response.status_code == 200
    assert response.body == "Tiger 4"
  end

  test "GET /about" do
    response = HTTPoison.get!("http://localhost:4000/about")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "324"}]
    assert response.status_code == 200

    assert response.body == """
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
    response = HTTPoison.get!("http://localhost:4000/bears/new")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "240"}]
    assert response.status_code == 200

    assert response.body == """
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
    response = HTTPoison.get!("http://localhost:4000/pages/contacts")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "16"}]
    assert response.status_code == 200
    assert response.body == "Contact data...\n"
  end

  test "GET /pages/faq.md" do
    response = HTTPoison.get!("http://localhost:4000/pages/faq.md")

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "664"}]
    assert response.status_code == 200

    assert response.body == """
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
    response =
      HTTPoison.post!("http://localhost:4000/bears", "name=Baloo&type=Brown", [
        {"Content-Type", "application/x-www-form-encoded"}
      ])

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "32"}]
    assert response.status_code == 201
    assert response.body == "Create a Brown bear named Baloo!"
  end

  test "GET /api/bears" do
    response = HTTPoison.get!("http://localhost:4000/api/bears")

    assert response.headers == [{"Content-Type", "application/json"}, {"Content-Length", "605"}]
    assert response.status_code == 200

    expected_response = """
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

    assert remove_whitespace(response.body) == remove_whitespace(expected_response)
  end

  test "POST /api/bears" do
    response =
      HTTPoison.post!("http://localhost:4000/api/bears", '{"name": "Breezly", "type": "Polar"}', [
        {"Content-Type", "application/json"}
      ])

    assert response.headers == [{"Content-Type", "text/html"}, {"Content-Length", "35"}]
    assert response.status_code == 201
    assert response.body == "Created a Polar bear named Breezly!"
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
