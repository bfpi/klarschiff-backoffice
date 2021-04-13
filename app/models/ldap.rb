# frozen_string_literal: true

class Ldap
  class << self
    def config
      @config ||= Settings::Ldap
    end

    def login(username, password)
      conn(username: username, password: password).bind
    end

    def search(pattern)
      return unless conn.bind
      return unless (result = conn.search(base: config.search_user_base, filter: ldap_filter(pattern)))
      result.as_json.select do |object|
        search_group_members.include?(object['myhash'][config.user_identifier].first)
      end
    end

    def conn(host: config.host, port: config.port, encryption: config.encryption,
      username: config.username, password: config.password)
      @conn ||= Net::LDAP.new(host: host, port: port, encryption: encryption)
      @conn.auth username, password if username.present? && password.present?
      @conn
    end

    private

    def search_group_members
      return @group_members if @group_members.present?
      if conn.bind && (object = conn.search(base: config.search_group).first)
        @group_members = object.as_json['myhash'][config.group_userlist]
      end
      @group_members
    end

    def ldap_filter(pattern)
      filter = nil
      config.search_user_attributes.split(',').each do |attr|
        filter = if filter.blank?
                   Net::LDAP::Filter.eq(attr, "*#{pattern}*")
                 else
                   Net::LDAP::Filter.intersect(filter, Net::LDAP::Filter.eq(attr, "*#{pattern}*"))
                 end
      end
      filter
    end
  end
end
