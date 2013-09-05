class User < ActiveRecord::Base
  attr_accessible :email, :name, :provider, :uid

  has_many :workitems
  has_many :share_codes

  def active_share_code
    ShareCode.find_by_user_id_and_is_active(self.id, true)
  end

  def self.from_omniauth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid']) || User.create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['name']
      user.email = auth['info']['email']
    end
  end

  def display
    name
  end

end
