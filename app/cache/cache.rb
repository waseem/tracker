# A very basic Cache implementation.
#
# Default storage is a Hash. You can change it by injecting a storage object
# into initialize method. The storage object should behave like a normal Ruby
# Hash.
#
# hasher is an object that is used to hash the keys correspondig to which
# values will be saved in the cache. A hasher object responds to a #hash
# method. It accepts a key and returns its hashed value.
class Cache
  attr_reader :storage # For debugging purposes

  def initialize(hasher, logger)
    @storage = {}
    @hasher  = hasher
    @logger  = logger
  end

  def get(key)
    @storage[@hasher.hash(key)]
  end

  def store(key, value)
    @storage[@hasher.hash(key)] = value
  end

  def fetch(key, &block)
    hashed_key = @hasher.hash(key)
    if @storage.has_key?(hashed_key)
      @logger.info "Cache Hit for key: #{hashed_key}"
      return get(key)
    end
    @logger.info "Cache Miss for key: #{hashed_key}"

    value = yield
    store(key, value)
  end
end
