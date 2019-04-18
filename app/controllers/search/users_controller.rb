# frozen_string_literal: true

module Search
  class UsersController < ApplicationController
    before_action :must_be_admin!

    def search
      query = params['q']
      page = params['page']
      @users = User
        .order(name: :asc)
        .accessible_by(current_ability, :read)
        .search_by_name_and_email(query)
        .page(page)
    end
  end
end
