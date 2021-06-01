# frozen_string_literal: true

class Client
  @clients ||= Config.for(:clients)

  def self.[](key)
    @clients[key.to_s].try(:with_indifferent_access)
  end

  def self.keys
    @clients.keys.map(&:to_s)
  end
end
