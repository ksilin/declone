require 'rspec'
require_relative '../src/decloner'

describe 'read filesystem' do

  it 'should read the contents of a directory' do
    with_temp_dir [:foo, :bar] do |path|
      common_files = Decloner.new.read_dir(path)
      common_files.should eq %W(#{path}/bar #{path}/foo)
    end
  end

  it 'should not list subdirectories'
  
  it 'should list hidden files'

  it 'should read the contents of a subdirectory' do
    with_temp_dir ["/sub/foo".to_sym, "/sub/bar".to_sym] do |path|
      common_files = Decloner.new.read_dir(path)
      common_files.should eq %W(#{path}/sub/bar #{path}/sub/foo)
    end
  end


  it 'should return no files when comparing directory to itself' do
    with_temp_dir [:foo, :bar] do |path|
      common_files = Decloner.new.get_common(path, path)
      p common_files
      common_files.keys.should eq []
    end
  end

  it 'should return no files when comparing directory to empty directory' do
    with_two_temp_dirs [:foo, :bar] do |path|
      common_files = Decloner.new.get_common(path, path)
      p common_files
      common_files.keys.should eq []
    end
  end

  it 'should return all files when duplicates are in a subdirectory of the first dir' do
    with_two_temp_dirs ["/sub/foo".to_sym, "/sub/bar".to_sym, :bar, :foo] do |path|
      common_files = Decloner.new.get_common(path, path)
      p common_files
      common_files.keys.should eq [:bar, :foo]
    end
  end

  it 'should return all files when comparing directory with identically named files' do
    with_two_temp_dirs [:foo, :bar], [:foo, :bar]  do |path, path2|
      common_files = Decloner.new.get_common(path, path2)
      p common_files
      common_files.keys.should eq [:bar, :foo]
      common_files.each {|k, v| v.size.should eq 2}
    end
  end

  it 'should identify duplicate files by name in nested directories' do
    with_two_temp_dirs [:foo, :bar], [:foo, :bla] do |path, path2|
      common_files = Decloner.new.get_common(path, path2)
      p common_files
      common_files.keys.should eq [:foo]
      common_files[:foo].size.should eq 2
    end
  end


  # just to know, probably useless test
  it 'should return a hash' do
    path = File.dirname(__FILE__)
    Decloner.new.get_common(path, path).should be_kind_of Hash
  end

  it 'should map filenames to paths' do
    with_temp_dir [:foo, :bar] do |path|
      Decloner.new.make_basename_hash(Dir.glob(path + '**/*')).keys.should eq [:bar, :foo]
    end
  end

end

def with_temp_dir(filenames = [])
  Dir.mktmpdir() { |dir|
    create_temp_files(dir, filenames)

    yield dir
  }
end

# TODO- fill the files with repeated digests of their names
def with_two_temp_dirs(filenames1 = [], filenames2 = [])
  Dir.mktmpdir() { |dir1|
    create_temp_files(dir1, filenames1)

    Dir.mktmpdir() { |dir2|
      create_temp_files(dir2, filenames2)

      yield dir1, dir2
    }
  }
end

def create_temp_files(dir, filenames)
  filenames.each { |name|
    file_name = File.join(dir, name.to_s)
    p "filename: #{file_name}"
    FileUtils.mkdir_p(File.dirname(file_name))
    open(file_name, 'w')
  }
end


