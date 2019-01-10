module Search
  class UsersController < ApplicationController
    def search
      query = params['q']
      page = params[:page]
      @users = User.accessible_by(current_ability, :read).search_by_name_and_email(query).page(page)
    end
  end
end
