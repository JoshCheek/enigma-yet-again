require 'stringio'
require 'spec_helper'
require 'enigma/cli'

RSpec.describe Enigma::CLI do
  include IntegrationTestHelpers
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  describe 'parsing the arguments', t:true do
    # need to figure out what the date is
    def parse(argv)
      Enigma::CLI.parse(argv)
    end

    def expect_parses(argv, assertions)
      assertions.each do |methodname, expected_value|
        actual_value = parse(argv).__send__(methodname)
        expect(actual_value).to eq expected_value
      end
    end

    it 'considers the input file to be the argument to --in' do
      expect_parses ['--in', 'abc'], input_filename: 'abc'
      expect_parses [],              input_filename: nil
    end

    it 'considers the output file to be the argument to --out' do
      expect_parses ['--out', 'abc'], :output_filename, 'abc'
      expect_parses [],               :output_filename, nil
    end

    it 'considers the date file to be the argument to --date' do
      expect_parses ['--date', 'abc'], :date, 'abc'
      expect_parses [],                :date, nil
    end

    it 'considers the key file to be the argument to --key' do
      expect_parses ['--key', 'abc'], :key, 'abc'
      expect_parses [],               :key, nil
    end

    it 'uses the default date, formatted to 6 digits, if no date was provided' do
      pending 'figure out how to parse a date and how to pass it'
    end

    it 'uses a random key, if no key was provided' do
      unique_keys = 100.times.map { parse([]).key }.uniq.length
      expect(unique_keys).to be > 1
    end

    it 'parses the command as the non-argument' do
      expect_parses ['encrypt'],          command: 'encrypt'
      expect_parses ['--key', 'encrypt'], command: nil
      expect_parses [],                   command: nil
    end
  end

  describe 'validating the arguments' do
    it 'adds an error if no command was given'
    it 'adds an error if no argument was given to --in'
    it 'adds an error if no argument was given to --out'
    it 'adds an error if no argument was given to --date'
    it 'adds an error if no argument was given to --key'
    it 'adds an error if the date is not 6 digits'
    it 'adds an error if the key is not 4 digits'
    it 'adds an error if the input file does not exist'
  end

  it 'runs the given command (encrypt, decrypt, crack)'

  describe 'encrypt' do
    it 'writes the encrypted input file into the output file'
  end

  describe 'decrypt' do
    it 'writes the decrypted input file into the output file'
  end

  describe 'crack' do
    it 'writes the cracked input file into the output file'
  end

  specify 'on successful invocation, it exits with 0 (success), prints no errors, and prints a summary' do
    cd_proving_grounds do
      File.write 'i', 'body'
      exitstatus = Enigma::CLI.call(stdout, stderr, ['--in', 'i', '--out', 'theoutfile'], Time.now)
      expect(exitstatus).to eq 0
      expect(stderr).to be_empty
      expect(stdout).to include 'theoutfile'
    end
  end

  specify 'on unsuccessful invocation, it exits with 1 (failure) and prints any errors' do
    exitstatus = Enigma::CLI.call(stdout, stderr, ['--key', 'this is a bad key'], Time.now)
    expect(exitstatus).to eq 1
    expect(stdout).to be_empty
    expect(stderr).to include 'this is a bad key'
  end
end
