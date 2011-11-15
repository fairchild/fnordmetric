class FnordMetric::Event  

  attr_accessor :time, :type, :event_id

  #def self.track!(event_type, event_data)
  #end

  def self.all(opts)    
    set_key = "#{opts[:namespace_prefix]}-timeline"
    event_ids = opts[:redis].zrevrange(set_key, 0, -1, :withscores => true)
    event_ids.in_groups_of(2).map do |event_id, ts|
      find(event_id, opts).tap{ |s| s.time = ts }
    end
  end

  def self.find(event_id, opts)
    self.new(event_id, opts).tap do |event|
      event.fetch!
    end
  end

  def initialize(event_id, opts)
    @opts = opts
    @event_id = event_id
  end

  def fetch!
    @data = JSON.parse(fetch_json).tap do |event|
      @type = event.delete("_type")
    end
  end

  def fetch_json
    @opts[:redis].get(redis_key)
  end

  def redis_key
    [@opts[:redis_prefix], :event, @event_id].join("-")
  end

  def id
    @event_id
  end
  
  def data(key=nil)
    key ? @data[key.to_s] : @data
  end

  alias :[] :data

end