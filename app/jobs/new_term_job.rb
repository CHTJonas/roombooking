class NewTermJob < ApplicationJob
  def perform
    CamdramShow.all.each do |show|
      show.update(dormant: true)
    end
  end
end
