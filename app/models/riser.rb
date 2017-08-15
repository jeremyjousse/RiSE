class Riser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

   def self.find_for_facebook_oauth(auth)
    riser_params = auth.slice(:provider, :uid)
    riser_params.merge! auth.info.slice(:email, :first_name, :last_name)
    riser_params[:facebook_picture_url] = auth.info.image
    riser_params[:token] = auth.credentials.token
    riser_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    riser_params = riser_params.to_h

    riser = Riser.find_by(provider: auth.provider, uid: auth.uid)
    riser ||= Riser.find_by(email: auth.info.email) # riser did a regular sign up in the past.

    if riser
      riser.update(riser_params)
    else
      riser = Riser.new(riser_params)
      riser.password = Devise.friendly_token[0,20]  # Fake password for validation
      riser.save
    end

    return riser
  end
end