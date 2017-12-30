'*************************************************************
'** Hello World example 
'** Copyright (c) 2015 Roku, Inc.  All rights reserved.
'** Use of the Roku Platform is subject to the Roku SDK Licence Agreement:
'** https://docs.roku.com/doc/developersdk/en-us
'*************************************************************

sub Main()
    print "in showChannelSGScreen"
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    
    'Create a scene and load /components/ShortGrid.xml'
    scene = screen.CreateScene("ShortGrid")
    scene.backgroundColor="0x152426FF"
    scene.postJson = ApiLoad()
    screen.show()
    
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

Function ApiLoad() As String
  url = createObject("roUrlTransfer")
  url.SetCertificatesFile("common:/certs/ca-bundle.crt") ' or another appropriate certificate
  url.InitClientCertificates()
  url.setUrl("https://www.shortoftheweek.com/api/v1/mixed/?limit=20")
  return url.GetToString()
End Function