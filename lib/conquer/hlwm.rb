require 'celluloid/current'
require 'celluloid/notifications'
require 'conquer/hlwm/version'

module Conquer
  module Hlwm
    class Listener
      include Celluloid
      include Celluloid::Notifications

      def initialize
        async.run
      end

      def run
        ::IO.popen(%w(herbstclient --idle)) do |io|
          io.each do |line|
            event, *params = line.split("\t")
            event = event.delete("\n")
            publish(:"hlwm_#{event}", *params)
          end
        end
      end
    end
  end

  module Helpers
    module_function

    def hlwm_tags(monitor = 0)
      tags = {}
      `herbstclient tag_status #{monitor}`.split("\t").each do |tag|
        next if tag.strip.length.zero?
        status = tag[0]
        name = tag[1..-1]

        tags[name] = {
          name: name,
          status: status
        }
      end
      tags
    end
  end
end
