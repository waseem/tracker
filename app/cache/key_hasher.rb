# Very simple hashing function
#
# KeyHasher.hash returns md5 of the provided string
module KeyHasher
  def self.hash(key)
    Digest::MD5.hexdigest(key.to_s)
  end
end
