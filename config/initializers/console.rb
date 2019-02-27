# frozen_string_literal: true

Rails.application.configure do
  console do
    PaperTrail.request.whodunnit = lambda {
      unless @paper_trail_whodunnit_set
        email = nil
        user = nil
        until email.present? && user.present? do
          print 'Please enter the email associated with your Roombooking account (or none): '
          email = gets.chomp
          if email == 'none'
            @paper_trail_whodunnit_set = true
            return nil
          else
            user = User.find_by(email: email)
          end
        end
        @paper_trail_whodunnit = user.id
        @paper_trail_whodunnit_set = true
      end
      @paper_trail_whodunnit
    }
  end
end
