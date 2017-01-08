require 'spec_helper_acceptance'

config = '/etc/postfix/main.cf'

describe 'preferred servers', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  pp = <<-EOS
      class { '::postfix':
        relayhost     => 'sendgrid.net',
        relay_domains => 'example.com',
      }
  EOS

  it 'applies cleanly' do
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
  end

  describe file("#{config}") do
    it { should be_file }
    its(:content) { should match /relayhost = sedgrid.net/     }
    its(:content) { should match /relay_domains = example.com/ }
  end
end
