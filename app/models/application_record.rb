# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  has_paper_trail

  self.abstract_class = true
end
