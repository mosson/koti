require 'yaml'

module Koti
  class BootLoader
    attr_accessor :environment, :target, :configurations
    def initialize(target, configurations = [], environment = nil)
      @target = target
      @environment = environment
      @configurations = load(configurations)
    end

    def load(configurations)
      configurations.map { |cfg| conf(cfg, environment) }
    end

    def conf(cfg, env)
      Config.new(cfg, env).source
    end

    def invoke!
      configurations.each(&method(:set))
    end

    def set(source)
      source.each do |k, v|
        next if v.is_a? Hash
        if v.is_a? String
          target[k] = v.encoding('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        else
          target[k] = v
        end
      end
    end

    class Config
      attr_reader :config, :environment
      def initialize(file, environment)
        check! file.to_s
        @config = YAML.load_file(file.to_s)
        @environment = environment
      end

      def check!(conf)
        fail(
          Errno::ENOENT,
          "configuration missing: #{conf}"
        ) unless File.exist? conf
      end

      def source
        @source ||= deep_dup(config).merge! config.fetch(environment, {})
      end

      def deep_dup(hash)
        duplicate = hash.dup
        duplicate.each_pair do |k, v|
          tv = duplicate[k]
          duplicate[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_dup(tv) : v
        end
        duplicate
      end
    end
  end
end
