class CamdramObject < ActiveRecord::Base
  enum ref_type: [ :show, :society ]
  has_many :booking

  # Create a CamdramObject model object from a Camdram::Show object.
  def self.create_from_show(refobj)
    cdobj = self.create_from_camdram(refobj, 'show')
  end

  # Create a CamdramObject model object from a Camdram::Organisation object.
  def self.create_from_society(refobj)
    cdobj = self.create_from_camdram(refobj, 'society')
  end

  private
    # Shared code from the create_from helpers.
    def self.create_from_camdram(refobj, type)
      create! do |cdobj|
        cdobj.name = refobj.name
        cdobj.camdram_id = refobj.id
        cdobj.ref_type = type
      end
    end

end
