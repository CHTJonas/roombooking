# == Schema Information
#
# Table name: batch_import_results
#
#  jid                           :string           not null, primary key
#  queued                        :datetime         not null
#  started                       :datetime
#  completed                     :datetime
#  shows_imported_successfully   :integer          is an Array
#  shows_imported_unsuccessfully :integer          is an Array
#  shows_already_imported        :integer          is an Array
#
class BatchImportResult < ApplicationRecord
  validates :jid, presence: true
  validates :queued, presence: true

  self.primary_key = :jid
end
