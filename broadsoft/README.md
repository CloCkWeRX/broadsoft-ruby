## What is this?
A fork of the old rubyforge project for interacting with the Broadsoft API.


## Original
We're really happy to be partnering on with Broadsoft as part of their
developer's and extended marketplace. This is the first part of three posts
we'll be doing on the work we've been doing with their platform. In this first
part, we'll be talking about the ruby gem we've written to be the basis for
our work.

Before we get there, of all the carrier platform choices we could make, it was
clear that Broadsoft was the one worthy of our attention. First, a few weeks
ago, they announced the BroadSoft Xtended program targeted to "Personalize
Voice Communications Technologies Through Web 2.0 Integrated Applications."
Secondly, I received repeated assurances that they had a commitment to an open
marketplace and an open approach to supporting their developers. Third, and I
can give you my assurance of this as an ex-CTO of their competitor,
Netcentrex, Broadsoft is winning in the marketplace. Directly from their site,
"BroadSoft provides VoIP applications to 7 of the top 10 and 13 of the top 25
largest carriers worldwide, as measured by recent annual revenue, including
Korea Telecom, KPN, SingTel, Sprint, Telefonica de Espana, Telstra, Deutsche
Telecom's T-Systems, and Verizon. To date, our platform has been deployed in
the most IP multimedia subsystem (IMS) networks worldwide." When Scott Wharton
asked my team to write some stuff for them, I couldn't say yes fast enough.

Our first job was to get a development environment that we could deal with. In
the medium term, Broadsoft engineering is planning a complete REST interface
to the platform. Until then, they have an XML based interface called "CAP2".
Nothing wrong with that from a carrier perspective, but if you haven't
noticed, I'm a Web 2.0 guy now. (Out damn spot). So, we've written a ruby gem
to interface our software to a Broadsoft switch. We've received permission
from Ruby Forge, and we're posting it up there today. Using this gem, it's
drop dead easy to install, configure and manage a user account.

First, installation is simple. From any ruby development machine with gems
installed, say :

```
gem install broadsoft
```

That's it. You're ready to go. If you want to play around with it, jump into
the interactive ruby browser (irb), and have at it. First, include gems and
the broadsoft gem:

```
irb(main):001:0> require 'rubygems'
=> true
irb(main):002:0> require 'broadsoft'
=> true
```
then all you need to do is login.

```
bs = Broadworks.new("example.broadsoft.com", "2208", "demo@broadsoft.com", "youdontcare")

=> #<Broadworks:0x11bc6b8 @user_uid="270384658", @port="2208", @t=#<TCPSocket:0x11bc604>, @host="example.broadsoft.com", @password="youdontcare", @logger=#<Logger:0x11bc67c @logdev=#<Logger::LogDevice:0x11bc618 @shift_age=nil, @filename=nil, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x11bc5f0 @mon_waiting_queue=[], @mon_entering_queue=[], @mon_count=0, @mon_owner=nil>, @dev=#<IO:0x2e7d4>, @shift_size=nil>, @formatter=nil, @default_formatter=#<Logger::Formatter:0x11bc654 @datetime_format=nil>, @level=2, @progname=nil>, @call_client="demo@broadsoft.com">
```
that's it. Your'e ready to go. Want to make your phone call somebody? Eeeeasy.
```
bs.dial "15088154321"
```
We also implemented answer, hold and release. (Still have some of the more
exotic park and conferencing stuff to implement; we'll see who actually cares
about those.) Call notifications? Eeeeasy too, and in fine Ruby fashion:
```
bs.assign_call_function { |info|

# your code goes here.
}
```
As happens in ruby, info is an object containing all of the call variables we
need. In our business intelligence application, we use these callbacks to
populate a database so we can use it to drive our user interface from a ruby
on rails application. Here's what we actually did:
```
# Create your AR class
class Call < ActiveRecord::Base
end

bs.assign_call_function { |info|
  # We need to put this information into the database.  Let's try that, shall we?
  
  c = Call.find_by_callid(info["callId"])
  if c.nil?
    c = Call.new
    c.user = info["user"][0] unless info["user"].nil?
    c.remote_country_code = info["remoteCountryCode"][0] unless info["remoteCountryCode"].nil?
    c.personality = info["personality"][0] unless info["personality"].nil?
    c.callid = info["callId"]
    c.calltype = info["callType"][0] unless info["callType"].nil?
    c.release_cause = info["releaseCause"][0] unless info["releaseCause"].nil?
    c.remote_number = info["remoteNumber"][0] unless info["remoteNumber"].nil?
    c.appearance = info["appearance"][0] unless info["appearance"].nil?
    c.extTrackingid = info["extTrackingId"]
    c.remote_name = info["remoteName"][0] unless info["remoteName"].nil?
    c.state = info["state"][0] unless info["state"].nil?
    c.save
  else
    case info["state"][0]
    when "5"
      c.destroy
    else
      c.state = info["state"][0]
      c.save
    end
  end
}
```
And that's pretty much it. In the next two posts, we'll explain how you can
use this gem to implement a business intelligence mashup using 37 signal's
Highrise product, and then we'll show you how we did a quick and simple click
to call on the browser using this gem, ruby on rails and a greasemonkey
script.
