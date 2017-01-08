require 'spec_helper_acceptance'

describe 'postfix class:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should run successfully' do
    pp = "class { 'postfix': }"

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to eq(/error/i)

      #expect(r.exit_code).to be_zero
      # bug in 14.04: init script not detecting Postfix running
      expect(r.exit_code).to be_zero unless (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '14.04')
    end
  end

  context 'service_ensure => stopped:' do
    it 'runs successfully' do
      pp = "class { 'postfix': status => disabled }"

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end
  end

  context 'service_ensure => running:' do
    it 'runs successfully' do
      pp = "class { 'postfix': status => enabled }"

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
    end
  end
end
