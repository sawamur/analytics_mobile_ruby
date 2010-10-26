
require 'test/unit'
require 'ga'


class GaTest < Test::Unit::TestCase
  def setup
  end

  def test_get_ip
    ga = GoogleAnalyticsMobile.new({},{"REMOTE_ADDR" => "124.455.3.123"})
    assert_equal "124.455.3.0",ga.get_ip
  end

  def test_get_ip_with_proxy
    ga = GoogleAnalyticsMobile.new({},{"HTTP_X_FORWARDED_FOR" => "124.455.3.123"})
    assert_equal "124.455.3.0",ga.get_ip
  end

  def test_get_rondom_number
    ga = GoogleAnalyticsMobile.new
    assert ga.get_random_number.kind_of?(Integer)
  end
  
  def test_visitor_id
    ga = GoogleAnalyticsMobile.new({:utmac => "hige"},
                                   { "HTTP_USER_AGENT" => "mozilla",
                                     "HTTP_X_DCMGUID" => "hoge" })

    assert_equal "0x624c880082a99f6e",ga.visitor_id

    ga2 = GoogleAnalyticsMobile.new({},{ "HTTP_USER_AGENT" => "mozilla"})
    assert_not_nil ga2.visitor_id
  end

  def test_gif_data
    ga = GoogleAnalyticsMobile.new
    assert_not_nil ga.gif_data
    assert_match /GIF89/,ga.gif_data
  end
  
  def test_render_options
    ga = GoogleAnalyticsMobile.new
    assert_not_nil ga.render_options[:type]
    assert_not_nil ga.render_options[:cache_control]
  end

  def test_cookie
    ga = GoogleAnalyticsMobile.new({:utmac => "hige"},
                                   { "HTTP_USER_AGENT" => "mozilla",
                                     "HTTP_X_DCMGUID" => "hoge" })
    assert_not_nil ga.cookie_name
    assert_equal GoogleAnalyticsMobile::COOKIE_NAME,ga.cookie_name
    assert ga.cookie_value.kind_of?(Hash)
    assert_match /0x\w+/,ga.cookie_value[:value]
  end

  def test_utm_url
    ga = GoogleAnalyticsMobile.new({:utmac => "hige"},
                                   { "HTTP_USER_AGENT" => "mozilla",
                                     "HTTP_X_DCMGUID" => "hoge" })
    puts ga.utm_url
  end


end




