# frozen_string_literal: true

module GroupsHelper
  def types
    Group.distinct(:type).uniq.reverse
  end

  def references(type)
    return Authority.authorized if type == 'AuthorityGroup'
    return County.authorized if type == 'CountyGroup'
    Instance.all
  end
end
