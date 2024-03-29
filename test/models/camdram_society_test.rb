require 'test_helper'
require 'slack_test_helper'

class CamdramSocietyTest < ActiveSupport::TestCase
  include SlackTestHelper

  test 'should not save if max_meetings is not an integer' do
    soc = camdram_societies(:cuadc)
    soc.max_meetings = 'some string'
    assert_not soc.save
    soc.max_meetings = :some_symbol
    assert_not soc.save
    soc.max_meetings = true
    assert_not soc.save
    soc.max_meetings = 5.5
    assert_not soc.save
    soc.max_meetings = -2
    assert_not soc.save
    soc.max_meetings = 12
    assert soc.save
  end

  test 'should validate Slack webhook URLs' do
    soc = CamdramSociety.new(camdram_id: 19)
    validates_slack_webhook(soc)
  end

  test 'should not allow duplicate societies' do
    soc = CamdramSociety.new(camdram_id: 38)
    assert_not soc.save
  end

  test "should preserve a society's historic booking data" do
    society = camdram_societies(:camdram)
    society.update!(max_meetings: 2)
    booking = Booking.create!(
      name:          'Data Preservation Test',
      start_time:    DateTime.tomorrow + 8.weeks + 12.hours,
      end_time:      DateTime.tomorrow + 8.weeks + 14.hours,
      purpose:       'meeting_of',
      camdram_model: society,
      room:          rooms(:one),
      user:          users(:charlie)
    )
    assert_not_equal 0, society.bookings.count
    assert_not society.destroy
    society.bookings.destroy_all
    assert_equal 0, society.bookings.count
    assert society.destroy
  end

  test "should return society's camdram object" do
    soc = camdram_societies(:camdram)
    obj = soc.camdram_object
    assert_equal 38, obj.id
    assert_equal 'camdram', obj.slug
    assert_equal 'Camdram', obj.name
    assert_equal "Camdram's meta-page on Camdram. We don't fund any shows, but we help others to put on shows using this website.\r\n\r\nThe site is maintained by volunteers in their spare time. If you have a question or problem, or you\u2019re interested in helping, contact us at [support@camdram.net](mailto:support@camdram.net).", obj.description
  end

  test 'should create society from a Camdram object' do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_society(7)
      assert_nothing_raised do
        CamdramSociety.create_from_camdram(obj)
      end
    end
    # We end up creating a Camdram entity so we need to remove the generated
    # cache warmup jobs.
    CamdramEntityCacheWarmupJob.clear
  end

  test 'should find society from a Camdram object' do
    Roombooking::CamdramApi.with do |client|
      obj = client.get_society(38)
      soc = camdram_societies(:camdram)
      assert soc == CamdramSociety.find_from_camdram(obj)
    end
  end

  test 'should return camdram object name' do
    soc = camdram_societies(:camdram)
    assert_equal 'Camdram', soc.name
  end

  test 'should return camdram object url' do
    soc = camdram_societies(:camdram)
    assert_equal 'https://www.camdram.net/societies/camdram', soc.url
  end
end
