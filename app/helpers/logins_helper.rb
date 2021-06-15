# frozen_string_literal: true

module LoginsHelper
  def users
    User.all.map { |u| [[u.last_name, u.first_name].filter_map(&:presence).join(', '), u.id] }
  end
end
