require 'spec_helper'

RSpec.describe 'integration tests' do
  include IntegrationTestHelpers

  let(:unencrypted_filename) { 'unencrypted' }
  let(:encrypted_filename)   { 'encrypted' }
  let(:decrypted_filename)   { 'decrypted' }
  let(:cracked_filename)     { 'cracked' }

  let(:message)              { 'this is a message..end..' }
  let(:encrypted_message)    { 'fmotmfzwptg' }
  let(:key)                  { '26340' }
  let(:date)                 { '190615' }

  it 'encrypts / decrypts / cracks a message' do
    cd_proving_grounds do
      File.write unencrypted_filename, message

      # encrypt
      result = run 'enigma', 'encrypt', '--in',   unencrypted_filename,
                                        '--out',  encrypted_filename,
                                        '--date', date,
                                        '--key',  key
      expect(result).to be_success
      expect(result.stderr).to be_empty
      expect(result.stdout).to eq "Created '#{encrypted_filename}' with the key #{key} and date #{date}\n"
      expect(File.read encrypted_filename).to eq encrypted_message

      # decrypt
      result = run 'enigma', 'decrypt', '--in',   unencrypted_filename,
                                        '--out',  decrypted_filename,
                                        '--date', date,
                                        '--key',  key
      expect(result).to be_success
      expect(result.stderr).to be_empty
      expect(result.stdout).to eq "Created '#{decrypted_filename}' with the key #{key} and date #{date}\n"

      # crack
      result = run 'enigma', 'crack', '--in', encrypted_filename, '--out', cracked_filename
      expect(result).to be_success
      expect(result.stderr).to be_empty
      expect(result.stdout).to eq "Created '#{cracked_filename}' with the key #{key} and date #{date}\n"

      # files look right, and did not change
      expect(File.read unencrypted_filename).to eq message
      expect(File.read encrypted_filename).to_not eq message
      expect(File.read encrypted_filename).to eq encrypted_message
      expect(File.read decrypted_filename).to eq message
      expect(File.read cracked_filename).to eq message
    end
  end

  it '(sanity) incorrectly decrypts messages when its date / key are wrong' do
    # encrypt
    result = run 'enigma', 'encrypt', '--in',   unencrypted_filename,
                                      '--out',  encrypted_filename,
                                      '--date', '111111',
                                      '--key',  '1111'
    expect(result).to be_success

    # decrypt bad date
    result = run 'enigma', 'decrypt', '--in',   unencrypted_filename,
                                      '--out',  decrypted_filename,
                                      '--date', '222222',
                                      '--key',  '1111'
    expect(result).to be_success
    decrypted_with_bad_date = File.read decrypted_filename
    expect(decrypted_with_bad_date).to_not eq message

    # decrypt bad key
    result = run 'enigma', 'decrypt', '--in',   unencrypted_filename,
                                      '--out',  decrypted_filename,
                                      '--date', '111111',
                                      '--key',  '2222'
    expect(result).to be_success
    decrypted_with_bad_key = File.read decrypted_filename
    expect(decrypted_with_bad_key).to_not eq message

    expect(decrypted_with_bad_key).to_not eq decrypted_with_bad_date
  end
end
