# frozen_string_literal: true

module GroupsHelper
  def types
    %w[InstanceGroup AuthorityGroup CountyGroup]
  end

  def references(type)
    return Authority.authorized if type == 'AuthorityGroup'
    return County.authorized if type == 'CountyGroup'
    Instance.all
  end

  def reference_label(type)
    type.remove(/Group$/).constantize.model_name.human
  end
end
