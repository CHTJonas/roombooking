require 'test_helper'

class CamdramMarkdownTest < ActionDispatch::IntegrationTest
  test 'bare link' do
    markdown = 'https://www.adctheatre.com'
    expected_html = "<p><a href=\"https://www.adctheatre.com\" rel=\"nofollow\" target=\"_blank\">https://www.adctheatre.com</a></p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'markdown link' do
    markdown = '[ADC Website](https://www.adctheatre.com)'
    expected_html = "<p><a href=\"https://www.adctheatre.com\" rel=\"nofollow\" target=\"_blank\">ADC Website</a></p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'legacy links' do
    markdown = 'For more information, see the [L:https://www.cuadc.org;CUADC website].'
    expected_html = "<p>For more information, see the <a href=\"https://www.cuadc.org\" rel=\"nofollow\" target=\"_blank\">CUADC website</a>.</p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'legacy mailto links' do
    markdown = 'Contact the [L:mailto:president@cuadc.org;CUADC president].'
    expected_html = "<p>Contact the <a href=\"mailto:president@cuadc.org\" rel=\"nofollow\" target=\"_blank\">CUADC president</a>.</p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'bold text' do
    markdown = '<b>This is bold text</b>'
    expected_html = "<p><strong>This is bold text</strong></p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'italic text' do
    markdown = '<i>This is bold text</i>'
    expected_html = "<p><em>This is bold text</em></p>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'horizontal rule' do
    markdown = '<hr>'
    expected_html = "<hr>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
    markdown = "<hr\>"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
    markdown = "<hr \>"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'level one markdown headings' do
    markdown = '# Heading 1'
    expected_html = "<h3>Heading 1</h3>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'level two markdown headings' do
    markdown = '## Heading 2'
    expected_html = "<h3>Heading 2</h3>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'level three markdown headings' do
    markdown = '### Heading 3'
    expected_html = "<h4>Heading 3</h4>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end

  test 'level four markdown headings' do
    markdown = '#### Heading 4'
    expected_html = "<h5>Heading 4</h5>\n"
    actual_html = Roombooking::Markdown.render_like_camdram(markdown)
    assert_equal expected_html, actual_html
  end
end
