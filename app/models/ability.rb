# frozen_string_literal: true

class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  include Sufia::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns, :admins_can_read_solr_documents, :registered_users_can_search_persons]
 
  def editor_abilities
    super
    if admin?
      can :create, TinymceAsset
      can [:create, :update], ContentBlock
    end
    can :read, ContentBlock
  end

  def stats_abilities
    super
    can :admin_stats, User if admin?
  end

  def admin?
    current_user.administrator?
  end

  def registered?
    current_user.group_list.include? 'registered' or 'umg/up.dlt.scholarsphere-users'
  end

  # Remove if/when projecthydra/curation_concerns#1118 is resolved
  def admins_can_read_solr_documents
    can :read, SolrDocument if admin?
  end

  def registered_users_can_search_persons
    if registered?
      can :name_query, Person
    end
  end
end
