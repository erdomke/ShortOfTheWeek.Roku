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
    m.scene = screen.CreateScene("ShortGrid")
    m.scene.postJson = ApiLoadPage("1")
    screen.show()

    for i = 2 to 10
      m.scene.postJson = ApiLoadPage(i.toStr())
    end for

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

Function ApiLoadPage(page as String) as String
  request = CreateObject("roUrlTransfer")
  request.SetCertificatesFile("common:/certs/ca-bundle.crt") ' or another appropriate certificate
  request.InitClientCertificates()
  port = CreateObject("roMessagePort")
  request.SetMessagePort(port)
  request.SetUrl("https://www.shortoftheweek.com/api/v1/mixed/?limit=20&page=" + page)
  if (request.AsyncGetToString())
    while (true)
      msg = wait(0, port)
      if (type(msg) = "roUrlEvent")
        code = msg.GetResponseCode()
        if (code = 200)
          return msg.GetString()
        endif
      else if (event = invalid)
        request.AsyncCancel()
      end if
    end while
  end if
  return ""
End Function

