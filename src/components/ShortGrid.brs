function init()
  print "Grid Init"

  m.top.setFocus(true)
  m.top.observeField("postJson", "onJsonChanged")

  m.rowList = m.top.findNode("theRowList")
  m.rowList.ObserveField("rowItemFocused", "onRowItemFocused")
end function

sub onJsonChanged()
  print "Parsing"
  print Left(m.top.postJson, 200)
  posts = ParseJson(m.top.postJson).data

  data = CreateObject("roSGNode", "ContentNode")
  row = data.CreateChild("ContentNode")
  row.title = "Newest Releases"
  for i = 0 to 19
    if posts[i].type = "video" then
      item = row.CreateChild("SimpleRowListItemData")
      item.thumbnailUrl = "https:" + posts[i].thumbnail
      item.fullImgUrl = "https:" + posts[i].thumbnail
      item.labelText = posts[i].post_title
      item.duration = posts[i].duration
      item.excerpt = posts[i].post_excerpt
      item.genre = posts[i].genre.display_name
      item.filmmaker = posts[i].filmmaker
      item.mature = IsArray(posts[i].labels)
      date = CreateObject("roDateTime")
      date.FromISO8601String(posts[i].post_date)
      item.date = date.GetYear().toStr() + "/" + date.GetMonth().toStr()
    end if
  end for
  m.top.findNode("theRowList").content = data
end sub

Function IsArray(value As Dynamic) As Boolean
    Return GetInterface(value, "ifArray") <> invalid
End Function

Function IsString(value As Dynamic) As Boolean
    Return GetInterface(value, "ifString") <> invalid
End Function

function onRowItemFocused() as void
  row = m.rowList.rowItemFocused[0]
  col = m.rowList.rowItemFocused[1]

  item = m.rowList.content.getChild(row).getChild(col)
  m.top.findNode("lblSubTitle").text = item.genre + " / " + item.filmmaker + " / " + item.duration + " min"

  excerpt = m.top.findNode("lblExcerpt")

  title = m.top.findNode("lblTitle")
  title.text = item.labelText
  if title.boundingRect()["height"] < 60 then
    excerpt.maxLines = 4
  end if
  excerpt.text = item.excerpt
  m.top.findNode("lblMature").visible = item.mature
  m.top.findNode("posSelected").uri = item.fullImgUrl

end function
