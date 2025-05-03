require 'spec_helper_acceptance'

config = '/etc/postfix/main.cf'

describe 'preferred servers' do
  pp = <<-EOS
      class { '::postfix':
        relayhost     => 'sendgrid.net',
        relay_domains => 'example.com',
      }
  EOS

  it 'applies cleanly' do
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(%r{error}i)
    end
  end

  describe file(config) do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{relayhost = sedgrid.net}     }
    its(:content) { is_expected.to match %r{relay_domains = example.com} }
  end
end
