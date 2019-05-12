require 'test_helper'

class CamdramSocietyTest < ActiveSupport::TestCase
  test "should not save if max_meetings is not an integer" do
    soc = camdram_societies(:cuadc)
    soc.max_meetings = 'some string'
    assert_not soc.save
    soc.max_meetings = :some_symbol
    assert_not soc.save
    soc.max_meetings = true
    assert_not soc.save
    soc.max_meetings = 5.5
    assert_not soc.save
    soc.max_meetings = 12
    assert soc.save
  end

  test "should return society's camdram object" do
    soc = camdram_societies(:camdram)
    obj = soc.camdram_object
    assert_equal 38, obj.id
    assert_equal "camdram", obj.slug
    assert_equal "Camdram", obj.name
    assert_equal "Camdram's meta-page on Camdram. We don't fund any shows, but we help others to put on shows using this website.\r\n\r\nThe site is maintained by volunteers in their spare time. If you have a question or problem, or you\u2019re interested in helping, contact us at [support@camdram.net](mailto:support@camdram.net).", obj.description
  end
end
