# frozen_string_literal: true

class Ldap
  class << self
    def config
      @config ||= Settings::Ldap
    end

    def login(username, password)
      ldap = conn
      ldap.auth "#{config.identifier}=#{username},#{config.base}", password
      if ldap.bind &&
         ldap.search(base: config.base, filter: "#{config.identifier}=#{username}").try(:first)
        return true
      end
      false
    end

    def search(pattern)
      ldap = conn
      ldap.auth config.username, config.password
      raise 'Authentication Error!' unless ldap.bind
      ldap.search(base: config.base, filter: ldap_filter(pattern)).as_json.select do |object|
        object if search_group_members.include?(object['myhash'][config.identifier].first)
      end
    end

    private

    def conn
      Net::LDAP.new host: config.host, port: config.port, encryption: config.encryption
    end

    def search_group_members
      return @group_members unless @group_members.blank?
      ldap = conn
      ldap.auth config.username, config.password
      if ldap.bind && (object = ldap.search(base: config.base, filter: config.search_group).first)
        @group_members = object.as_json['myhash']['memberuid']
      end
      @group_members
    end

    def ldap_filter(pattern)
      filter = nil
      config.search_attributes.split(',').each do |attr|
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
