require 'rspec'
require_relative '../src/decloner'

describe 'read filesystem' do

  it 'should read the contentsof a directory' do
    with_temp_dir [:foo, :bar] do |path|
      common_files = Decloner.new.read_dir(path)
      common_files.should eq %W(#{path}/bar #{path}/foo)
    end
  end

  it 'should read contents of two directories' do
    with_temp_dir [:foo, :bar] do |path|
      common_files = Decloner.new.get_common(path, path)
      p common_files
      common_files.keys.should eq [:bar, :foo]
      common_files.values.flatten.should eq Dir.glob(path + '**/*').sort
    end
  end

  it 'should return some class' do
    path = File.dirname(__FILE__)
    p Decloner.new.get_common(path, path)[0].class
    p Dir.glob(path + '**/*')
  end

  it 'should map filenames to paths' do
    with_temp_dir [:foo, :bar] do |path|
      Decloner.new.basename_hash(Dir.glob(path + '**/*')).keys.should eq [:bar, :foo]
    end
  end

  def with_temp_dir(filenames = [])
    Dir.mktmpdir() { |dir|

      # use join
      filenames.each { |name| open("#{dir}/#{name}", 'w') }

      yield dir
    }
  end

  # TODO- fill the files with repeated digests of their names
  def with_two_temp_dirs(filenames1 = [], filenames2 = [])
    Dir.mktmpdir() { |dir1|
      filenames1.each { |name| open("#{dir1}/#{name}", 'w') }

      Dir.mktmpdir() { |dir2|
        filenames2.each { |name| open("#{dir2}/#{name}", 'w') }

        yield dir1, dir2
      }
    }
  end

end

