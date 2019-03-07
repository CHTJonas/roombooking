# frozen_string_literal: true

module Search
  class UsersController < ApplicationController
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
