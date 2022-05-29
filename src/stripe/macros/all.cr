module StripeMethods
  extend self

  macro add_all_method(arguments)
{% begin %}
  def self.all(client : Stripe::Client, batch_size : Int32 = 100) : List({{@type.id}})
    items = List({{@type.id}}).empty
    {% for key, values in arguments %}
      {% for value in values %}
        items.add_list(list(client, limit: batch_size, {{key}}: {{value}}))
        while items.has_more
          page = list(client, limit: batch_size, {{key}}: {{value}}, starting_after: items.data.last.id)
          items.add_list(page)
        end
      {% end %}
    {% end %}
    return items
  end
{% end %}
  end
end
