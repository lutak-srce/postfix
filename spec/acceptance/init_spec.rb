require 'spec_helper_acceptance'

describe 'postfix class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = 'include postfix'

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to eq(%r{error}i)
   
        #expect(r.exit_code).to be_zero
        # bug in 14.04: init script not detecting Postfix running
        expect(r.exit_code).to be_zero unless (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '14.04')
      end
    end

    # do some basic checks
    pkg = 'postfix'
    describe package(pkg) do
      it { is_expected.to be_installed }
    end

    describe service('postfix') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end

  context 'service_ensure => stopped:' do
    it 'runs successfully' do
      pp = "class { 'postfix': status => disabled }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
    end
  end

  context 'service_ensure => running:' do
    it 'runs successfully' do
      pp = "class { 'postfix': status => enabled }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
    end
  end
end
