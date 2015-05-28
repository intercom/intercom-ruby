module Intercom
  module Options
    def options(*opts)
      previous = nil
      opts.each do |opt|
        previous = opt.call(self)
      end
      previous
    end
  end
end
