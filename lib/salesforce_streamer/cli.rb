module SalesforceStreamer
  class CLI
    def initialize(argv)
      @argv = argv
      @config = Configuration.instance
      setup_options
      @parser.parse! @argv
    end

    def run
      Launcher.new.run
    end

    private

    def setup_options
      @parser = OptionParser.new do |o|
        o.on '-C', '--config PATH', 'Load PATH as a config file' do |arg|
          @config.config_file = arg
        end

        o.on '-e', '--environment ENVIRONMENT', 'The environment to run the app on (default development)' do |arg|
          @config.environment = arg
        end

        o.on '-r', '--require PATH', 'Load PATH as the entry point to your application' do |arg|
          @config.require_path = arg
        end

        o.on '--verbose-restforce', 'Activate the Restforce logger' do
          @config.restforce_logger!
        end

        o.on '-v', '--verbose LEVEL', 'Set the log level (default no logging)' do |arg|
          @config.logger = Logger.new($stderr, level: arg)
        end

        o.on '-V', '--version', 'Print the version information' do
          puts "streamer version #{SalesforceStreamer::VERSION}"
          exit 0
        end

        o.on '-x', '--topics', 'Activate PushTopic Management (default off)' do
          @config.manage_topics = true
        end

        o.banner = 'bundle exec streamer OPTIONS'

        o.on_tail '-h', '--help', 'Show help' do
          puts o
          exit 0
        end
      end
    end
  end
end
