' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' A context node has a parameters and response field
' - parameters corresponds to everything related to an HTTP request
' - response corresponds to everything related to an HTTP response
' Component Variables:
'   m.port: the UriFetcher message port
'   m.jobsById: an AA containing a history of HTTP requests/responses

' init(): UriFetcher constructor
' Description: sets the execution function for the UriFetcher
' 						 and tells the UriFetcher to run
sub init()
  ' create the message port
  m.port = createObject("roMessagePort")

  ' setting callbacks for url request and response
  m.top.observeField("vimeoId", m.port)

  ' setting the task thread function
  m.top.functionName = "go"
  m.top.control = "RUN"
end sub

sub go()
	'Event loop
  while true
    msg = wait(0, m.port)
    mt = type(msg)
    print "Received event type '"; mt; "'"
    ' If a request was made
    if mt = "roSGNodeEvent"
      if msg.getField()="vimeoId"
        LaunchVimeo()
      else
        print "Error: unrecognized field '"; msg.getField() ; "'"
      end if
    else
	   print "Error: unrecognized event type '"; mt ; "'"
    end if
  end while
end sub

Sub LaunchVimeo()
  vimeoId = m.top.vimeoId
  ipDict = CreateObject("roDeviceInfo").GetIPAddrs()
  ipAddr = ipDict[ipDict.Keys()[0]]
  request = CreateObject("roUrlTransfer")
  url = "http://" + ipAddr + ":8060/launch/1980?contentid=" + vimeoId
  print "Launching URL " + url
  request.SetUrl(url)
  request.PostFromString("")
End Sub
