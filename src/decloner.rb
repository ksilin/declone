
class Decloner

  CRITERIA = [:name, :digest] # phash for images

  def read_dir(path = File.dirname(__FILE__))
      Dir.glob(path + '**/*').sort
  end

  def get_common(path1, path2)
    files1 = read_dir path1
    files2 = read_dir path2

    basenames1 = basename_hash(files1)
    basenames2 = basename_hash(files2)

    basenames1.merge basenames2
  end

  def basename_hash(files1)
    files1.inject({}) do |res, file_path|
      basename = File.basename(file_path).to_sym
      res[basename] ||= []
      res[basename] << file_path
      res
    end
  end

end