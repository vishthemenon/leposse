class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :first_name, :last_name, :gender, :handphone,
  				  :password, :password_confirmation, :remember_me, :uid, :provider,
            :year_of_birth, :location, :username

  has_and_belongs_to_many :games, :uniq => true


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(
      					   first_name:auth.extra.raw_info.first_name,
      					   last_name:auth.extra.raw_info.last_name,
      					   gender:auth.extra.raw_info.gender,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20]
                           )
    end
    user
  end

  def self.new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
      end
    end

    def update_with_password(params={}) 
      if params[:password].blank? 
        params.delete(:password) 
        params.delete(:password_confirmation) if params[:password_confirmation].blank? 
      end 
      update_attributes(params) 
    end

    def password_required?
      super && provider.blank?
    end

end
