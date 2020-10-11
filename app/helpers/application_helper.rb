# frozen_string_literal: true

module ApplicationHelper
  def delete_confirm(name, model)
    link_to name, url_for(model), method: :delete, data: { confirm: "Are you sure you want to delete #{model.name}?" }
  end
end
