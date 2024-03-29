# frozen_string_literal: true

class BatchImportJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: 'roombooking_jobs'
  sidekiq_throttle concurrency: { limit: 1 }

  def perform(user_id, result_id)
    result = BatchImportResult.lock.find(result_id)
    result.update!(started: Time.now)

    user = User.find(user_id)
    Sentry.set_user({ id: user.id, name: user.name, email: user.email })
    PaperTrail.request.whodunnit = user_id

    shows = ShowEnumerationService.perform
    shows_imported_successfully = []
    shows_imported_unsuccessfully = []
    shows_already_imported = []

    shows.each do |camdram_show|
      # First we check if the show has already been imported
      # and if it has, we skip to the next one.
      if CamdramShow.find_by(camdram_id: camdram_show.id)
        shows_already_imported << camdram_show.id
        next
      end

      # We need to import the show. Do this in a single
      # transaction so that we either import the show and
      # make all its block bookings successfully, or we
      # rollback and ignore just that show. The exception
      # to this is if we can't identify what kind of show
      # (Main or Late) it is, in which case we just import
      # it and don't make any block bookings.
      ActiveRecord::Base.transaction do
        show = CamdramShow.create_from_camdram(camdram_show)
        if show.block_out_bookings(user)
          shows_imported_successfully << camdram_show.id
        else
          # TODO shows_imported_successfully_but_unidentified
          shows_imported_successfully << camdram_show.id
        end
      end
    rescue => e
      shows_imported_unsuccessfully << camdram_show.id
      Sentry.set_extras({ camdram_id: camdram_show.id })
      Sentry.capture_exception(e)
      send_import_error_email(user, camdram_show, e)
      next
    end

    PaperTrail.request.whodunnit = nil
    UserPermissionRefreshJob.perform_async
    result.with_lock do
      result.completed = Time.now
      result.shows_imported_successfully = shows_imported_successfully
      result.shows_imported_unsuccessfully = shows_imported_unsuccessfully
      result.shows_already_imported = shows_already_imported
      result.save!
    end
  end

  private

  def send_import_error_email(user, camdram_show, e)
    ApplicationMailer.new.mail(
      to: user.email,
      bcc: 'charlie@charliejonas.co.uk',
      subject: '[Room Booking System] Show Import Failure',
      body: <<~END
        Hello,

        This is an automated email from the ADC Room Booking System. Please do
        not reply.

        The following show was *not* imported. The exact error was:
        #{e}

        ====================
        #{camdram_show.name}
        (Camdram ID #{camdram_show.id})
        #{camdram_show.performances.map { |p| error_email_helper(p) }.join("\n")}
        ====================

        Kind regards,

        The friendly Room Booking Robots
      END
    ).deliver
  end

  def error_email_helper(performance)
    if performance.repeat_until.nil?
      "#{performance.start_at.to_s(:rfc822)} at #{get_performance_venue_name(performance)}"
    else
      "#{performance.start_at.to_s(:rfc822)} until #{performance.repeat_until.to_s(:rfc822)} at #{get_performance_venue_name(performance)}"
    end
  end

  # TODO extract this method out into camdram-ruby lib
  def get_performance_venue_name(performance)
    if performance.venue
      performance.venue.name
    else
      performance.other_venue
    end
  end
end
