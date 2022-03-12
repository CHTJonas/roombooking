class Current < ActiveSupport::CurrentAttributes
  attribute :override, :overridable
  attribute :blocking_out

  def can_override?
    !!self.overridable
  end
end
