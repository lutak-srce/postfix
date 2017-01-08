require 'spec_helper'

describe 'postfix::postmap', :type => :define do

  let :pre_condition do
    'include postfix'
  end

  context '=> content text <=' do
    let :title do
      'relay_passwd'
    end
    let :default_params do
      {
        :content => "smtp.example.com AKIAPASSW0RD\n"
      }
    end

    context "on RedHat based systems" do
      let :default_facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :operatingsystem        => 'RedHat',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end

      let :params do default_params end
      let :facts do default_facts end

      it { is_expected.to contain_file("/etc/postfix/relay_passwd").with(
        :ensure  => 'file',
        :content => "smtp.example.com AKIAPASSW0RD\n",
      ) }

      it { is_expected.to contain_exec("postfix_update_postmap_relay_passwd").with(
        :cwd         => '/etc/postfix',
        :command     => "/usr/sbin/postmap relay_passwd",
        :refreshonly => true,
      ) }

    end
  end
end
