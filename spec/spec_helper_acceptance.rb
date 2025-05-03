require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  c.formatter = :documentation

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    hosts.each do |host|
      case fact('os.family')
      when 'Debian'
        on host, puppet('module', 'install', 'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      when 'RedHat'
        # Soft dep on epel for Passenger
        install_package(host, 'epel-release')
      end
    end
  end
end
