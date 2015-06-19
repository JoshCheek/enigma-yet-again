require 'enigma'

class Enigma::CLI
  Args = Struct.new :command, :input_filename, :output_filename, :date, :key, :errors do
    def initialize
      self.errors = []
    end
  end

  def self.parse(argv)
    args = Args.new
  end
end
