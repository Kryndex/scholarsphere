# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'socket'
require 'sprockets'
require 'resolv'
require 'uri'
require 'webmock' unless Rails.env.production?

WebMock.disable! if Rails.env.development?

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module ScholarSphere
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    def get_vhost_by_host
      hostname = Socket.gethostname
      vhost = config.hosts_vhosts_map[hostname] || "https://#{hostname}/"
      uri = URI.parse(vhost)
      service = uri.host
      port = uri.port
      service << "-#{port}" unless port == 443
      [service, vhost]
    end

    def google_analytics_id
      vhost = get_vhost_by_host[0]
      ga_id = config.ga_host_map[vhost]
      ga_id || Rails.application.secrets.google_analytics_tracking_id
    end

    def ffmpeg_path
      vhost = get_vhost_by_host[0]
      path = config.ffmpeg_path_map[vhost]
      path || 'ffmpeg'
    end

    config.scholarsphere_version = "v2.8"
    config.scholarsphere_release_date = "October 24, 2016"
    config.redis_namespace = "scholarsphere"
    config.persistent_hostpath = "http://scholarsphere.psu.edu/files/"
    # # of fits array items shown on the Generic File show page
    config.fits_message_length = 5

    # Map hostnames onto Google Analytics tracking IDs
    config.ga_host_map = {
      'scholarsphere-test.dlt.psu.edu' => 'UA-33252017-1',
      'scholarsphere.psu.edu' => 'UA-33252017-2',
      'scholarsphere-qa.dlt.psu.edu' => 'UA-33252017-3',
      'scholarsphere-demo.dlt.psu.edu' => 'UA-33252017-4',
      'scholarsphere-staging.dlt.psu.edu' => 'UA-33252017-5'
    }

    # Map hostnames onto ffmpeg paths
    config.ffmpeg_path_map = {
      'scholarsphere.psu.edu' => '/dlt/scholarsphere/ffmpeg/ffmpeg-production',
      'scholarsphere-qa.dlt.psu.edu' => '/dlt/scholarsphere/ffmpeg/ffmpeg-qa',
      'scholarsphere-staging.dlt.psu.edu' => '/dlt/scholarsphere/ffmpeg/ffmpeg-staging',
      'scholarsphere-demo.dlt.psu.edu' => '/dlt/scholarsphere/ffmpeg/ffmpeg-demo'
    }

    config.hosts_vhosts_map = {
      'ss2test' => 'https://scholarsphere-test.dlt.psu.edu/',
      'ss1demo' => 'https://scholarsphere-demo.dlt.psu.edu/',
      'ss1qa' => 'https://scholarsphere-qa.dlt.psu.edu/',
      'ss2qa' => 'https://scholarsphere-qa.dlt.psu.edu/',
      'ssjobs1qa' => 'https://scholarsphere-qa.dlt.psu.edu/',
      'ss1stage' => 'https://scholarsphere-staging.dlt.psu.edu/',
      'ss2stage' => 'https://scholarsphere-staging.dlt.psu.edu/',
      'ssjobs1stage' => 'https://scholarsphere-staging.dlt.psu.edu/',
      'ss1prod' => 'https://scholarsphere.psu.edu/',
      'ss2prod' => 'https://scholarsphere.psu.edu/',
      'ssjobs1prod' => 'https://scholarsphere.psu.edu/'
    }

    config.assets.enabled = true
    config.assets.compress = !Rails.env.development?

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += %W(#{config.root}/app/models/datastreams)

    config.i18n.enforce_available_locales = true

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    def config.stats_email
      vhost = ScholarSphere::Application.get_vhost_by_host[0]
      if vhost == 'scholarsphere.psu.edu'
        'ScholarSphere Stats <umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu>'
      else
        "\"ScholarSphere Stats #{vhost}\" <umg-up.its.sas.scholarsphere-qa-email@groups.ucs.psu.edu>"
      end
    end
    config.stats_from_email = 'ScholarSphere Stats <umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu>'

    config.max_upload_file_size = 15 * 1024 * 1024 * 1024 # 15GB which matches with the amount of temp space on the servers

    # html maintenance response
    config.middleware.use 'Rack::Maintenance',
                          file: Rails.root.join('public', 'maintenance.html')
    config.ldap_unwilling_sleep = 2 # seconds

    # allow errors to be raised in callbacks
    config.active_record.raise_in_transactional_callbacks = true

    # Needed for ScholarsphereLockManager, remove this when we've upgraded to Redis 2.6+
    config.statefile = '/tmp/lockmanager-state'

    # Set the  system to read only mode.  Does not allow new uploads, file edits, new collections, and collection edits
    # config.read_only = true
  end
end
