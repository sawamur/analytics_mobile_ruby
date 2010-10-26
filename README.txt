
Google Analytics Mobile (Beta) Server-Side code for Ruby

This code is written based on Perl version.
http://code.google.com/mobile/analytics/docs/web/

== USAGE

 class SomeController
   ..
   def ga
    ga = GoogleAnlyticsMobile.new(params,request.env,cookies)
    cookies[ga.cookie_name] = ga.cookie_value
    send_data ga.gif_data,ga.render_options
   end
   ...
 end	
