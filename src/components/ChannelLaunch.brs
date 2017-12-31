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
  ' setting callbacks for url request and response
  m.top.observeField("vimeoId", "LaunchVimeo")
end sub

Sub LaunchVimeo()
  vimeoId = m.top.vimeoId
  ipDict = CreateObject("roDeviceInfo").GetIPAddrs()
  ipAddr = ipDict[ipDict.Keys()[0]]
  request = CreateObject("roUrlTransfer")
  request.SetUrl("http://" + ipAddr + "/launch/1980?contentid=" + vimeoId)
  request.PostFromString("")
End Sub
