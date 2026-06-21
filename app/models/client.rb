class Client < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def expired?
    return false if trial_ends_at.nil?
    trial_ends_at < Time.current
  end

  def check_and_upgrade_expired_trial
    return unless expired?
    # Add logic to upgrade expired trial if needed
  end
end
