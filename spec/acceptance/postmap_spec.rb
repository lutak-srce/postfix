require 'spec_helper_acceptance'

describe 'postfix::postmap define' do

  it 'prepare env' do
    if (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '14.04')
      shell("echo localhost | sudo tee /etc/mailname")
    end

    shell('rm -f /tmp/virtual_local')
    shell('echo "valentina  catchmail" >> /tmp/virtual_local')
    shell('echo "zuzanna    catchmail" >> /tmp/virtual_local')

    shell('rm -f /tmp/virtual_local.erb')
    shell('echo "<%= @postfix_test_var %>" >> /tmp/virtual_local.erb')
  end

  context '=> content text <=' do
    it 'should add text from content' do
      pp = <<-EOS
          class { '::postfix': }
          ::postfix::postmap { 'relay_passwd':
            content => "smtp.example.com AKIAPASSW0RD\n",
          }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end

    describe file("/etc/postfix/relay_passwd") do
      it { should be_file }
      its(:content) { should match 'PASSW0RD' }
      its(:content) { should match 'smtp.example.com' }
    end
  end

  context '=> source <=' do
    it 'should add text from source' do
      pp = <<-EOS
          class { '::postfix': }
          ::postfix::postmap { 'virtual_local':
            source => '/tmp/virtual_local',
          }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end

    describe file("/etc/postfix/virtual_local") do
      it { should be_file }
      its(:content) { should match 'valentina' }
      its(:content) { should match 'zuzanna'   }
      its(:content) { should match 'catchmail' }
    end
  end

  context '=> template <=' do
    it 'should add text from template' do
      pp = <<-EOS
          class { '::postfix': }
	  $postfix_test_var = 'some_test_string   some@email.com'
          ::postfix::postmap { 'virtual_local':
            template => '/tmp/virtual_local.erb',
          }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end

    describe file("/etc/postfix/virtual_local") do
      it { should be_file }
      its(:content) { should match 'some_test_string' }
      its(:content) { should match 'some@email.com'   }
    end
  end

  context '=> template and content <=' do
    it 'should report error' do
      pp = <<-EOS
          class { '::postfix': }
	  $postfix_test_var = 'some_test_string   some@email.com'
          ::postfix::postmap { 'virtual_local':
            template => '/tmp/virtual_local.erb',
	    content  => "foobar",
          }
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/error/i)
      end
    end
  end

end
