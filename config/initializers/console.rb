Rails.application.configure do
  console do
    # PaperTrail.request.whodunnit = ->() {
    PaperTrail.request.whodunnit = proc {
      @paper_trail_whodunnit ||= (
        email = nil
        user = nil
        until email.present? && user.present? do
          print 'In order to audit history correctly, please enter the email associated with you Roombooking account: '
          email = gets.chomp
          user = User.find_by(email: email)
        end
        user.id
      )
    }
  end
end
