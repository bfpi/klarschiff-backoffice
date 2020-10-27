# frozen_string_literal: true

class Ldap
  class << self
    def config
      @config ||= Settings::Ldap
    end

    def login(username, password)
      ldap = conn
      ldap.auth username, password
      return true if ldap.bind
      false
    end

    def search(pattern)
      ldap = conn
      ldap.auth config.username, config.password if config.username.present? && config.password.present?
      if ldap.bind &&
         (result = ldap.search(base: config.search_user_base, filter: ldap_filter(pattern)))
        result.as_json.select do |object|
          object if search_group_members.include?(object['myhash'][config.user_identifier].first)
        end
      end
    end

    private

    def conn
      Net::LDAP.new host: config.host, port: config.port, encryption: config.encryption
    end

    def search_group_members
      return @group_members if @group_members.present?
      ldap = conn
      ldap.auth config.username, config.password if config.username.present? && config.password.present?
      if ldap.bind && (object = ldap.search(base: config.search_group).first)
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
