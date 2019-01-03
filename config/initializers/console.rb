Rails.application.configure do
  console do
    PaperTrail.request.whodunnit = lambda {
      @paper_trail_whodunnit ||= (
        email = nil
        user = nil
        until email.present? && user.present? do
          print 'Please enter the email associated with your Roombooking account (or none): '
          email = gets.chomp
          return nil if email == 'none'
          user = User.find_by(email: email)
        end
        user.id
      )
    }
  end
end
