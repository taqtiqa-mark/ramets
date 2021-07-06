# frozen_string_literal: true

require_relative "dsl"

module ROM
  # @api private
  module Components
    # @api private
    class Provider < Module
      attr_reader :provider

      attr_reader :types

      # @api private
      def initialize(types)
        @provider = nil
        @types = types
      end

      # @api private
      def extended(provider)
        super
        @provider = provider
        provider.extend(mod)
        provider.extend(Components)
      end

      # @api private
      def mod
        @mod ||=
          begin
            mod = Module.new {
              private

              # @api private
              def dsl(type, **options)
                type.new(**options, provider: self)
              end
            }
            types.each do |type|
              mod.define_method(type) { |*args, **opts, &block|
                DSL.instance_method(type).bind(self).(*args, **opts, &block)
              }
            end
            mod
          end
      end
    end
  end
end