require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Sets the content default http proxy to an existing http proxy based on supplied URL."
  task :update_default_http_proxy => :environment do
    setting = ::Setting::Content.where(name: 'content_default_http_proxy').first
    options = {}
    o = OptionParser.new
    o.banner = "Usage: rake katello:update_content_default_http_proxy [options]"
    o.on("-n", "--name HTTP_PROXY_NAME") do |name|
      options[:name] = name
    end
    o.on("-u", "--url HTTP_PROXY_URL") do |url|
      options[:url] = url
    end
    o.on("-h, --help", "Prints this help") do
      puts o
      exit
    end
    ordered_args = o.order!(ARGV) {}
    o.parse!(ordered_args)

    unless options.key?(:name)
      $stderr.print("ERROR: Missing required option for --name HTTP_PROXY_NAME")
      exit 2
    end

    User.current = User.anonymous_api_admin
    http_proxy = HttpProxy.where(name: options[:name]).first

    if http_proxy
      setting.update_attribute(:value, http_proxy.name)
      puts "Content default http proxy set to #{http_proxy.name_and_url}."
    else
      if options.key?(:url)
        uri = URI(options[:url])
        username = uri.user
        password = uri.password
        new_proxy = ::HttpProxy.new(name: options[:name], url: options[:url],
                                  username: username, password: password,
                                  organizations: Organization.all,
                                  locations: Location.all)
        if new_proxy.save!
          setting.update_attribute(:value, new_proxy.name)
          puts "Default content http proxy set to \"#{new_proxy.name_and_url}\"."
        end
      else
        $stderr.print("ERROR: No http proxy found with name \"#{options[:name]}\".")
        exit 1
      end
    end
    exit
  end

  desc "Displays the current defined http proxies."
  task http_proxy_list: [:environment] do
    ::HttpProxy.all.each { |proxy| puts "#{proxy.name_and_url}" }
  end
end
