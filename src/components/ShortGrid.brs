function init()
  print "Grid Init"

  m.top.setFocus(true)
  m.top.observeField("postJson", "onJsonChanged")

  m.rowList = m.top.findNode("theRowList")
  m.rowList.ObserveField("rowItemFocused", "onRowItemFocused")
  m.rowList.ObserveField("rowItemSelected", "onRowItemSelected")

  m.btnWatch = m.top.findNode("btnWatch")
  m.btnWatch.observeField("buttonSelected", "onButtonSelected")

  m.launch = CreateObject("roSGNode", "ChannelLaunch")

  m.screenWidth = CreateObject("roDeviceInfo").GetDisplaySize().w

  m.firstPageLoaded = false
  m.firstFocus = false
  m.rowData = {}
  m.state = "list"
  m.selectedItem = {}
end function

sub onJsonChanged()
  print "Parsing"
  posts = ParseJson(m.top.postJson).data

  if not m.firstPageLoaded then
    m.firstPageLoaded = true
    data = CreateObject("roSGNode", "ContentNode")
    m.top.findNode("theRowList").content = data

    row = data.CreateChild("ContentNode")
    row.title = "Newest Releases"
    m.rowData.newest = row

    row = data.CreateChild("ContentNode")
    row.title = "Drama"
    m.rowData.drama = row

    row = data.CreateChild("ContentNode")
    row.title = "Documentary"
    m.rowData.docs = row

    row = data.CreateChild("ContentNode")
    row.title = "Animation"
    m.rowData.anim = row

    row = data.CreateChild("ContentNode")
    row.title = "Comedy"
    m.rowData.comedy = row

    row = data.CreateChild("ContentNode")
    row.title = "Sci-Fi"
    m.rowData.scifi = row
  end if

  for i = 0 to posts.Count() - 1
    post = posts[i]
    if post.type = "video" then
      item = m.rowData.newest.CreateChild("SimpleRowListItemData")
      item.thumbnailUrl = "https:" + post.thumbnail
      if m.screenWidth > 1300 and len(post.background_image) > 0 then
        item.fullImgUrl = "https:" + post.background_image
      else
        item.fullImgUrl = "https:" + post.thumbnail
      end if
      item.labelText = post.post_title
      item.duration = post.duration
      item.excerpt = post.post_excerpt
      item.mature = IsArray(post.labels)
      item.genre = post.genre.display_name
      item.topic = post.topic.display_name
      item.style = post.style.display_name
      item.country = post.country.display_name
      if left(post.play_link, 25) = "https://player.vimeo.com/" then
        urlParts = post.play_link.split("/")
        item.vimeoId = urlParts[urlParts.Count() - 1]
      else
        item.vimeoId = ""
      end if

      makers = post.filmmaker.split(" &amp; ")
      if makers.Count() = 1 then
        item.filmmaker = makers[0]
      elseif makers.Count() = 2 then
        item.filmmaker = Trim(makers[0]) + " & " + Trim(makers[1])
      else
        item.filmmaker = Trim(makers[0]) + " & " + (makers.Count() - 1).toStr() + " Others"
      end if
      date = CreateObject("roDateTime")
      date.FromISO8601String(post.post_date)
      item.date = date.GetYear().toStr() + "/" + date.GetMonth().toStr()

      if post.genre.slug = "drama" then
        altItem = m.rowData.drama.CreateChild("SimpleRowListItemData")
        CopyFields(item, altItem)
      else if post.genre.slug = "documentary" then
        altItem = m.rowData.docs.CreateChild("SimpleRowListItemData")
        CopyFields(item, altItem)
      else if post.genre.slug = "comedy" then
        altItem = m.rowData.comedy.CreateChild("SimpleRowListItemData")
        CopyFields(item, altItem)
      else if post.genre.slug = "sci-fi" then
        altItem = m.rowData.scifi.CreateChild("SimpleRowListItemData")
        CopyFields(item, altItem)
      end if

      if post.style.slug = "animation" then
        altItem = m.rowData.anim.CreateChild("SimpleRowListItemData")
        CopyFields(item, altItem)
      end if
    end if
  end for

  if m.firstFocus then onRowItemFocused()
end sub

Function IsArray(value As Dynamic) As Boolean
  Return GetInterface(value, "ifArray") <> invalid
End Function

Function IsString(value As Dynamic) As Boolean
  Return GetInterface(value, "ifString") <> invalid
End Function

Function Trim(value as String) as String
  start = 1
  while start <= len(value) and IsWhitespace(asc(mid(value, start, 1)))
    start = start + 1
  end while

  last = len(value)
  while last >= 1 and IsWhitespace(asc(mid(value, last, 1)))
    last = last - 1
  end while

  Return mid(value, start, last - start + 1)
End Function

Function IsWhitespace(asc as integer) as Boolean
  Return asc < 33 or asc = 160
end function

function onRowItemFocused() as void
  m.firstFocus = true
  row = m.rowList.rowItemFocused[0]
  col = m.rowList.rowItemFocused[1]

  item = m.rowList.content.getChild(row).getChild(col)
  m.selectedItem = item
  m.top.findNode("lblSubTitle").text = item.genre + " / " + item.filmmaker + " / " + item.duration + " min"

  excerpt = m.top.findNode("lblExcerpt")

  title = m.top.findNode("lblTitle")
  title.text = UCase(item.labelText)
  if title.boundingRect()["height"] < 60 then
    excerpt.maxLines = 4
  end if
  excerpt.text = item.excerpt
  m.top.findNode("lblMature").visible = item.mature

  poster = m.top.findNode("posSelected")
  if item.thumbnailUrl <> item.fullImgUrl then
    poster.loadingBitmapUri = item.thumbnailUrl
  end if
  poster.uri = item.fullImgUrl
end function

sub onRowItemSelected()
  setState("detail")
end sub

function CopyFields(fromObj as Object, toObj as Object)
  fields = fromObj.getFields()
  fields.delete("id")
  fields.delete("focusedChild")
  fields.delete("focusable")
  fields.delete("change")
  toObj.setFields(fields)
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
  print ">>> HomeScene >> OnkeyEvent"
  result = false
  if press then
    if key = "back"
      print "------ [back pressed] ------"
      if m.state = "detail" then
        setState("list")
        result = true
      end if
    else if key = "OK"
      print "------- [ok pressed] -------"
    else if key = "options"
      print "------ [options pressed] ------"
    end if
  end if
  return result
end function

sub setState(newState as string)
  txtContent = m.top.findNode("txtContent")
  lblExcerpt = m.top.findNode("lblExcerpt")
  lblTitle = m.top.findNode("lblTitle")

  m.rowList.visible = (newState = "list")
  m.btnWatch.visible = (newState = "detail")

  if newState = "detail" then
    item = m.selectedItem
    lblExcerpt.maxLines = 6

    m.btnWatch.setFocus(true)
  else if newState = "list" then

    m.rowList.setFocus(true)
  end if
  m.state = newState
end sub

sub onButtonSelected()
  m.launch.vimeoId = m.selectedItem.vimeoId
end sub
