class Stripe::List(T)
  include JSON::Serializable
  include Enumerable(T)

  getter data : Array(T)
  getter has_more : Bool
  getter total_count : Int32?
  getter url : String
  getter next_page : String?

  def self.empty
    from_json("{\"data\": [], \"has_more\": false, \"url\": \"\"}")
  end

  def each(&block)
    data.each do |i|
      yield i
    end
  end

  def add_list(list : List(T), merge_attributes : Bool = true)
    list.each do |i|
      data.push i
    end
    if merge_attributes
      @has_more = list.has_more
      @total_count = list.total_count
      @url = list.url
      @next_page = list.next_page
    end
  end
end