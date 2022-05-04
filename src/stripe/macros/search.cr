module StripeMethods
  extend self

  macro add_search_method(*arguments)
{% begin %}
  def self.search(client : Stripe::Client, query : String, limit : Int32? = nil, page : String? = nil) :  List({{@type.id}})
  io = IO::Memory.new
  builder = ParamsBuilder.new(io)

  builder.add("query", query)
  builder.add("limit", limit) unless limit.nil?
  builder.add("page", page) unless page.nil?

  response = client.http_client.get("/v1/#{"{{@type.id.gsub(/Stripe::/, "").underscore.gsub(/::/, "/")}}"}s/search", form: io.to_s)

  if response.status_code == 200
    List({{@type.id}}).from_json(response.body)
  else
    raise Error.from_json(response.body, "error")
  end
  end

{% end %}
  end
end
