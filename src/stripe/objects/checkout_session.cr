class Stripe::CheckoutSession
  include JSON::Serializable
  include StripeMethods

  add_retrieve_method
  add_list_method(
    limit : Int32? = nil,
    starting_after : String? = nil,
    ending_before : String? = nil
  )

  enum Mode
    Payment
    Setup
    Subscription
  end

  enum PaymentStatus
    Paid
    Unpaid
    NoPaymentRequired
  end

  enum BillingAddressCollection
    Auto
    Required
  end

  enum SubmitType
    Auto
    Pay
    Book
    Donate
  end

  getter id : String
  getter object : String? = "checkout.session"

  @[JSON::Field(converter: Enum::StringConverter(Stripe::CheckoutSession::Mode))]
  getter mode : String | Mode
  getter payment_method_types : Array(String)

  getter cancel_url : String
  getter success_url : String

  getter client_reference_id : String?
  getter customer : String? | Stripe::Customer?
  getter customer_email : String?

  getter line_items : Array(Hash(String, String | Int32))?

  getter metadata : Hash(String, String)?

  @[JSON::Field(converter: Enum::StringConverter(Stripe::CheckoutSession::PaymentStatus))]
  getter payment_status : PaymentStatus

  getter allow_promotion_codes : Bool?

  getter amount_subtotal : Int32?
  getter amount_total : Int32?

  @[JSON::Field(converter: Enum::StringConverter(Stripe::CheckoutSession::BillingAddressCollection))]
  getter billing_address_collection : BillingAddressCollection?

  getter currency : String?

  getter livemode : Bool?

  getter shipping : Hash(String, String | Hash(String, String))?

  getter shipping_address_collection : Hash(String, Array(String))?

  @[JSON::Field(converter: Enum::StringConverter(Stripe::CheckoutSession::SubmitType))]
  getter submit_type : SubmitType?

  def self.create(
    client : Stripe::Client,
    mode : String | Stripe::CheckoutSession::Mode,
    cancel_url : String,
    success_url : String,
    payment_method_types : Array(String)? = nil,
    client_reference_id : String? = nil,
    customer : String? | Stripe::Customer? = nil,
    customer_email : String? = nil,
    line_items : Array(NamedTuple(quantity: Int32, price: String))? = nil,
    expand : Array(String)? = nil,
    subscription_data : NamedTuple(metadata: Hash(String, String)?)? = nil,
    allow_promotion_codes : Bool? = nil,
    metadata : Hash(String, String)? = nil,
    discounts : Array(NamedTuple(coupon: String) | NamedTuple(promotion_code: String))? = nil
  ) : Stripe::CheckoutSession
    customer = customer.not_nil!.id if customer.is_a?(Customer)

    io = IO::Memory.new
    builder = ParamsBuilder.new(io)

    {% for x in %w(mode payment_method_types cancel_url success_url client_reference_id customer customer_email line_items expand subscription_data allow_promotion_codes metadata discounts) %}
      builder.add({{x}}, {{x.id}}) unless {{x.id}}.nil?
    {% end %}

    response = client.http_client.post("/v1/checkout/sessions", form: io.to_s)

    if response.status_code == 200
      Stripe::CheckoutSession.from_json(response.body)
    else
      raise Error.from_json(response.body, "error")
    end
  end
end
