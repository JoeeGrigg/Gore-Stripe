class Stripe::Product
  include JSON::Serializable
  include StripeMethods

  add_list_method(
    active : Bool? = nil,
    created : Hash(String, Int32)? = nil,
    ids : Array(String)? = nil,
    shippable : Bool? = nil,
    url : String? = nil,
    limit : Int32? = nil,
    starting_after : String? = nil,
    ending_before : String? = nil
  )
  add_retrieve_method
  add_search_method

  getter id : String

  getter name : String
  getter active : Bool
  getter description : String?
  getter metadata : Hash(String, String)
  getter default_price : String?

  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time

  @[JSON::Field(converter: Time::EpochConverter)]
  getter updated : Time

  getter livemode : Bool
  getter statement_descriptor : String?
  getter type : String
  getter unit_label : String?

  def self.create(
    client : Stripe::Client,
    name : String,
    active : Bool? = nil,
    description : String? = nil,
    metadata : Hash? = nil,
    images : Array(String)? = nil,
    statement_descriptor : String? = nil,
    unit_label : String? = nil,
    type : String? = nil
  ) : Product forall T, U
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(name active description metadata images statement_descriptor unit_label) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = client.http_client.post("/v1/products", form: io.to_s)

    if response.status_code == 200
      Product.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end

  def self.update(
    client : Stripe::Client,
    id : String,
    name : String? = nil,
    active : Bool? = nil,
    description : String? = nil,
    metadata : Hash? = nil,
    images : Array(String)? = nil,
    statement_descriptor : String? = nil,
    unit_label : String? = nil,
    type : String? = nil,
    default_price : String? = nil
  ) : Product forall T, U
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(name active description metadata images statement_descriptor unit_label default_price) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = client.http_client.post("/v1/products/#{id}", form: io.to_s)

    if response.status_code == 200
      Product.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
