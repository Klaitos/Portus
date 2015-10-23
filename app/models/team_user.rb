# Class describing a member of a team
#
# Meaning of the role column:
#   * viewer: has RO access to the namespaces associated with the team
#   * contributor: has RW access to the namespaces associated with the team
#   * owner: like contributor, but can also manage the team
class TeamUser < ActiveRecord::Base
  enum role: [:viewer, :contributor, :owner]

  scope :enabled, -> { joins(:user).where("users.enabled" => true).distinct }

  validates :team, presence: true
  validates :user, presence: true, uniqueness: { scope: :team }

  belongs_to :team
  belongs_to :user

  # Create the activity regarding this team member. If no parameters are
  # specified, then it's assumed: { role: role }.
  def create_activity!(type, owner, parameters = nil)
    params = parameters || { role: role }
    team.create_activity type, owner: owner, recipient: user, parameters: params
  end

  # Returns true if the member of this team is the only owner of it.
  def only_owner?
    team.owners.exists?(user.id) && team.owners.count == 1
  end
end
