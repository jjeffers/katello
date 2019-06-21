require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateContentHttpProxyTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/update_content_default_http_proxy'
      Rake::Task['katello:update_default_http_proxy'].reenable
      Rake::Task.define_task(:environment)
      @setting = Setting::Content.where(name: 'content_default_http_proxy').first
      assert @setting
    end

    def test_without_name_fails
      assert_equal 0, HttpProxy.all.count
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '-u', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 2, exit_code.status, "Task didn't exit with expected exit code."
      assert_equal 0, HttpProxy.all.count
    end

    def test_without_url_fails
      assert_equal 0, HttpProxy.all.count
      exit_code = assert_raises SystemExit do
        ARGV.concat(['--', '-n', 'a new proxy'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 2, exit_code.status, "Task didn't exit with expected exit code."
      assert_equal 0, HttpProxy.all.count
    end

    def test_update_proxy_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      @setting.update_attribute(:value, current_default_proxy.name)
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, @setting.reload.value
    end

    def test_update_proxy_updates_url
      proxy = FactoryBot.create(:http_proxy, url: 'http://someurl')
      assert_raises SystemExit do
        ARGV.concat(['--', '--name', proxy.name, '--url', 'http://someotherurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal 'http://someotherurl', proxy.reload.url
    end

    def test_update_proxy_by_short_option_name_sets_default
      current_default_proxy = FactoryBot.create(:http_proxy)
      @setting.update_attribute(:value, current_default_proxy.name)
      proxy = FactoryBot.create(:http_proxy)
      assert_raises SystemExit do
        ARGV.concat(['--', '-n', proxy.name, '-url', proxy.url])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end
      assert_equal proxy.name, @setting.reload.value
    end

    def test_update_proxy_by_proxy_name_and_url_creates_new_proxy
      assert 0, HttpProxy.all.count

      assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'new_proxy', '--url', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end

      assert_equal 1, HttpProxy.count
      assert_equal 'new_proxy', HttpProxy.last.name
      assert_equal 'http://someurl', HttpProxy.last.url
    end

    def test_update_proxy_by_proxy_name_and_short_url_option_creates_new_proxy
      assert 0, HttpProxy.all.count

      assert_raises SystemExit do
        ARGV.concat(['--', '--name', 'new_proxy', '-u', 'http://someurl'])
        Rake::Task['katello:update_default_http_proxy'].invoke
      end

      assert_equal 1, HttpProxy.count
      assert_equal 'new_proxy', HttpProxy.last.name
      assert_equal 'http://someurl', HttpProxy.last.url
    end

  end
end
