
require 'rubygems'
require 'active_support'
require 'digest/md5'
require 'open-uri'
require 'cgi'

class AnalyticsMobile
  VERSION = '4.4sp';
  COOKIE_NAME = '__utmmobile';  
  GA_PIXEL = "/ga.rb"
  GIF_DATA = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
              0x01, 0x00, 0x01, 0x00, 0x80, 0xff,
              0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
              0x00, 0x2c, 0x00, 0x00, 0x00, 0x00,
              0x01, 0x00, 0x01, 0x00, 0x00, 0x02,
              0x02, 0x44, 0x01, 0x00, 0x3b]
  
  attr_accessor :env,:params,:cookies

  def initialize(params={},env={},cookies={})
    @params = params
    @env = env
    @cookies = cookies
  end

  def remote_addr
    env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"]
  end
  
  def get_ip
    return "" if remote_addr.blank?
    if remote_addr =~ /^((\d{1,3}\.){3})\d{1,3}$/
      $1 + "0";
    else
      "";
    end
  end

  def get_random_number 
    rand(0x7fffffff).to_i
  end

  def visitor_id
    account = params[:utmac]
    user_agent = env['HTTP_USER_AGENT']
    cookie = cookies[COOKIE_NAME]
    guid = env['HTTP_X_DCMGUID'] || env['HTTP_X_UP_SUBNO']
    
    return cookie unless cookie.blank?
    unless guid.blank?
      message = guid.to_s + account.to_s
    else
      message = user_agent + get_random_number.to_s
    end
    md5_string = Digest::MD5.hexdigest(message)
    "0x" + md5_string[0, 16];
  end

  def render_options
    { :type => 'image/gif',
      :cache_control => 'private, no-cache, no-cache=Set-Cookie, proxy-revalidate',
      :pragma => 'no-cache',
      :expires => 1.day.ago }
  end

  def gif_data
    GIF_DATA.pack("C35")
  end

  def send_request_to_google_analytics
    opt = { 'Accept-Language' => env["HTTP_ACCEPT_LANGUAGE"],
            'User-Agent' => env["HTTP_USER_AGENT"]   }
    begin
      timeout(3) do
        open(utm_url,opt).read
      end
    rescue
    end
  end

  def utm_url
    user_agent = env['HTTP_USER_AGENT']
    cookie = cookies[COOKIE_NAME]
    utm_gif_location = "http://www.google-analytics.com/__utm.gif"
    
    utm_gif_location + '?' +
      'utmwv=' +  VERSION +
      '&utmn=' +  get_random_number().to_s +
      '&utmhn=' + uri_escape(env["SERVER_NAME"]) +
      '&utmr=' + uri_escape(params[:utmr]) +
      '&utmp=' + uri_escape(params[:utmp]) +
      '&utmac=' + params[:utmac].to_s + 
      '&utmcc=__utma%3D999.999.999.999.999.1%3B' +
      '&utmvid=' + visitor_id +
      '&utmip=' + get_ip
  end

  def uri_escape(txt)
    txt.nil? ? "" : CGI.escape(txt)
  end

  def cookie_name
    COOKIE_NAME
  end
  
  def cookie_value
    { 
      :value => visitor_id,
      :path => "/",
      :expires => 2.years.from_now
    }
  end
  
  def self.beacon(account_id,env={})
    ref = CGI.escape( env['HTTP_REFERER'] )
    path = CGI.escape( env['REQUEST_URI'] )
    "#{GA_PIXEL}?utmac=#{account_id}&utmn=#{rand(0xffffffff)}&utmr=#{ref}&utmp=#{path}&guid=ON"
  end
end

