# frozen_string_literal: true

module Yardstick
  # A string decorator for applying unix console codes
  class Decorator
    include Concord.new(:color, :mode)
    include Adamantium

    FORMAT = "\e[%<mode>d;%<color>dm%<string>s\e[0m"

    COLOR_CODES = IceNine.deep_freeze(
      red: 31,
      yellow: 33
    )

    MODE_CODES = IceNine.deep_freeze(
      bold: 1,
      underline: 4
    )

    private_constant(*constants(false))

    # Initializes new string decorator instance
    #
    # @param color [Symbol] name of color to use for formatting
    # @param mode [Symbol] mode for formatting text
    #
    # @return [undefined]
    #
    # @api private
    def initialize(color, mode)
      super(COLOR_CODES.fetch(color), MODE_CODES.fetch(mode))
    end

    # Decorate a string
    #
    # @param string [String] unformatted string
    #
    # @return [String]
    #
    # @api private
    def decorate(string)
      FORMAT % { mode: mode, color: color, string: string }
    end

    NONE = Class.new(self) do
      def initialize; end # rubocop:disable Lint/MissingSuper

      def decorate(string)
        string
      end
    end.new

    RED_BOLD          = new(:red, :bold)
    YELLOW_UNDERLINED = new(:yellow, :underline)
  end
end
