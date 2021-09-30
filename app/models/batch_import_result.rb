# == Schema Information
#
# Table name: batch_import_results
#
#  id                            :bigint           not null, primary key
#  jid                           :string
#  queued                        :datetime         not null
#  started                       :datetime
#  completed                     :datetime
#  shows_imported_successfully   :integer          is an Array
#  shows_imported_unsuccessfully :integer          is an Array
#  shows_already_imported        :integer          is an Array
#
class BatchImportResult < ApplicationRecord
  validates :queued, presence: true
end
