require 'open3'

project_root = File.expand_path '..', __dir__
bin_path     = File.expand_path 'bin', project_root
ENV["PATH"]  = "#{bin_path}:#{ENV["PATH"]}"

module IntegrationTestHelpers
  def proving_grounds_dir
    File.expand_path 'proving_grounds', __dir__
  end

  def delete_files_in(dir)
    glob = File.join(dir, '*')
    Dir[glob].each &File.method(:delete)
    expect(Dir[glob]).to be_empty
  end

  def cd_proving_grounds(&block)
    Dir.mkdir proving_grounds_dir unless Dir.exist? proving_grounds_dir
    Dir.chdir proving_grounds_dir do
      delete_files_in '.'
      block.call
    end
  end

  Result = Struct.new :stdout, :stderr, :status do
    def success?
      status.success?
    end
  end

  def run(*args)
    Result.new *Open3.capture3(*args)
  end
end
