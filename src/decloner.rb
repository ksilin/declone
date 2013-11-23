require 'find'

class Decloner

  CRITERIA = [:name, :digest] # phash for images


  def get_common(path1, path2)

    files1 = read_dir path1
    files2 = read_dir path2

    basenames1 = make_basename_hash(files1)
    basenames2 = make_basename_hash(files2)

    merged = basenames1.merge(basenames2) { |k, v1, v2| v1.push(*v2).uniq.tap{|a| p a}}
    merged.reject { |k, v| v.size < 2 }
  end

  def read_dir(path = File.dirname(__FILE__))
    Find.find(path).reject{|f| File.directory?(f)}.sort
    #Dir.glob(path + '**/').reject{|f| File.directory?(f)}.sort
  end

  def make_basename_hash(files1)
    files1.inject(Hash.new { |h, k| h[k]=[] }) do |res, file_path|
      basename = File.basename(file_path).to_sym
      #res[basename] ||= []
      res[basename] << file_path
      res
    end
  end

  def diff(one, other)
    (one.keys + other.keys).uniq.reduce({}) do |diff, key|
      unless is_key_in_both(key, one, other) && one[key] == other[key] # disregard identical entries
        diff[key] = [key_or_placeholder(key, one), key_or_placeholder(key, other)]
      end
      diff
    end
  end

  def key_or_placeholder(key, one)
    one.key?(key) ? one[key] : :_no_key
  end

  def is_key_in_both(key, one, other)
    one.key?(key) && other.key?(key)
  end

end