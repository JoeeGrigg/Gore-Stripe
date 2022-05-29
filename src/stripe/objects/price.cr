class Stripe::Price
  include JSON::Serializable
  include StripeMethods

  add_list_method(
    active : Bool? = nil,
    product : String? = nil,
    currency : String? = nil,
    type : String? = nil,
    lookup_keys : Array(String)? = nil,
    recurring : Hash(String, String | Int32 | Nil)? = nil,
    limit : Int32? = nil,
    created : Hash(String, Int32)? = nil,
    starting_after : String? = nil,
    ending_before : String? = nil
  )
  add_all_method({active: [true, false]})
  add_retrieve_method
  add_search_method

  getter id : String
  getter active : Bool?
  getter currency : String?
  getter metadata : Hash(String, String)?
  getter nickname : String?
  getter product : String? | Stripe::Product?
  getter type : String?
  getter unit_amount : Int32?
  getter billing_scheme : String?
  @[JSON::Field(converter: Time::EpochConverter)]
  getter created : Time
  getter livemode : Bool
  getter unit_amount_decimal : String?

  def money_amount : Money?
    return nil unless unit_amount && currency
    Money.new(unit_amount.not_nil!, currency.not_nil!)
  end

  def formatted_unit_amount : String
    money_amount ? money_amount.not_nil!.format : ""
  end

  def self.create(
    client : Stripe::Client,
    product : String,
    currency : String,
    unit_amount : Int32,
    active : Bool? = nil,
    metadata : Hash? = nil,
    nickname : String? = nil
  ) : Price forall T, U
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(product currency unit_amount active metadata nickname) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = client.http_client.post("/v1/prices", form: io.to_s)

    if response.status_code == 200
      Price.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end

  def self.update(
    client : Stripe::Client,
    id : String,
    currency : String? = nil,
    unit_amount : Int32? = nil,
    active : Bool? = nil,
    metadata : Hash? = nil,
    nickname : String? = nil
  ) : Price forall T, U
    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(currency unit_amount active metadata nickname) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = client.http_client.post("/v1/prices/#{id}", form: io.to_s)

    if response.status_code == 200
      Price.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
