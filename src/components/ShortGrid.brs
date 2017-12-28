function init()
  print "Grid Init"

  m.top.setFocus(true)
  
  m.top.observeField("postJson", "onJsonChanged")
  
  m.myLabel = m.top.findNode("myLabel")
  
  'Set the font size
  'm.myLabel.font.size=92

  'Set the color to light blue
  m.myLabel.color="0x72D7EEFF"

  '**
  '** The full list of editable attributes can be located at:
  '** http://sdkdocs.roku.com/display/sdkdoc/Label#Label-Fields
  '**

  m.lblVideo = m.top.findNode("lblVideo")
  m.rowList = m.top.findNode("theRowList")
  m.rowList.ObserveField("rowItemFocused", "onRowItemFocused")
end function

sub onJsonChanged()
  print "Parsing"
  print Left(m.top.postJson, 200)
  posts = ParseJson(m.top.postJson).data

  data = CreateObject("roSGNode", "ContentNode")
  row = data.CreateChild("ContentNode")
  row.title = "Videos"
  for i = 0 to 19
    if posts[i].type = "video" then
      item = row.CreateChild("SimpleRowListItemData")
      item.posterUrl = "https:" + posts[i].thumbnail
      item.labelText = posts[i].post_title
    end if
  end for
  m.top.findNode("theRowList").content = data
end sub

function onRowItemFocused() as void
  row = m.rowList.rowItemFocused[0]
  col = m.rowList.rowItemFocused[1]

  print "Row Focused: " + stri(row)
  print "Col Focused: " + stri(col)

  item = m.rowList.content.getChild(row).getChild(col)
  m.lblVideo.text = item.labelText
end function
