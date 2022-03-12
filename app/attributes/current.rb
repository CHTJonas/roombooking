class Current < ActiveSupport::CurrentAttributes
  attribute :override, :overridable

  def can_override?
    !!self.overridable
  end
end
