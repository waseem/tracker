# A very basic Cache implementation.
#
# Default storage is a Hash. You can change it by injecting a storage object
# into initialize method. The storage object should behave like a normal Ruby
# Hash.
#
# hasher is an object that is used to hash the keys correspondig to which
# values will be saved in the cache. A hasher object responds to a #hash
# method. It accepts a key and returns its hashed value.
#
# expire_after is milliseconds after which an object in the storage will
# be considered stale and on next fetch, it'll be updated. A 0 value
# indicates that object is always stale, and will always be fetched.
class Cache
  attr_reader :storage # For debugging purposes

  def initialize(hasher, logger, expire_after = 0)
    @storage      = {}
    @hasher       = hasher
    @logger       = logger
    @expire_after = expire_after.to_i.abs
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
      @logger.info "Cache: Hit for key: #{hashed_key}"

      value = get(key)
      return value['_object'] if is_fresh?(value)

      @logger.info "Cache: Stale object for key: #{hashed_key}"
    else
      @logger.info "Cache: Miss for key: #{hashed_key}"
    end

    result = yield
    value = { '_object' => result, 'expire_at' => expiration_time }
    store(key, value)
    return result
  end

  def is_fresh?(value)
    (expire_at = value['expire_at']) && expire_at > Time.now
  end

  private

  def expiration_time
    Time.now + @expire_after / 1000
  end
end
