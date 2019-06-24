#? stdtmpl(subsChar = '$', metaChar = '#')
#import xmltree, strutils, times, sequtils, uri
#import ../types, ../formatters, ../utils
#
#proc renderHeading(tweet: Tweet): string =
#if tweet.retweetBy.isSome:
  <div class="retweet">
    <span>🔄 ${tweet.retweetBy.get()} retweeted</span>
  </div>
#end if
#if tweet.pinned:
  <div class="pinned">
    <span>📌 Pinned Tweet</span>
  </div>
#end if
<div class="media-heading">
  <div class="heading-name-row">
    <img class="avatar" src=${tweet.profile.getUserpic("_bigger").getSigUrl("pic")}>
    <div class="name-and-account-name">
      ${linkUser(tweet.profile, "h4", class="username", username=false)}
      ${linkUser(tweet.profile, "", class="account-name")}
    </div>
    <span class="heading-right">
      <a href="${tweet.link}" class="timeago faint-link">
        <time title="${tweet.time.format("d/M/yyyy', ' HH:mm:ss")}">${tweet.shortTime}</time>
      </a>
    </span>
  </div>
</div>
#end proc
#
#proc renderQuote(quote: Quote): string =
#let hasMedia = quote.thumb.isSome()
<div class="quote">
  <div class="quote-container" href="${quote.link}">
    <a class="quote-link" href="${quote.link}"></a>
    #if hasMedia:
    <div class="quote-media-container">
      <div class="quote-media">
        <img src=${quote.thumb.get().getSigUrl("pic")}>
        #if quote.badge.isSome:
        <div class="quote-badge">
          <div class="quote-badge-text">${quote.badge.get()}</div>
        </div>
        #end if
      </div>
    </div>
    #end if
    <div class="profile-card-name">
      ${linkUser(quote.profile, "b", class="username", username=false)}
      ${linkUser(quote.profile, "span", class="account-name")}
    </div>
    <div class="quote-text">${linkifyText(xmltree.escape(quote.text))}</div>
  </div>
</div>
#end proc
#
#proc renderMediaGroup(tweet: Tweet): string =
#let groups = if tweet.photos.len > 2: tweet.photos.distribute(2) else: @[tweet.photos]
#let display = if groups.len == 1 and groups[0].len == 1: "display: table-caption;" else: ""
#var first = true
<div class="attachments media-body" style="${display}">
#for photos in groups:
  #let margin = if not first: "margin-top: .25em;" else: ""
  #let flex = if photos.len > 1 or groups.len > 1: "display: flex;" else: ""
  <div class="gallery-row cover-fit" style="${margin}">
    #for photo in photos:
    <div class="attachment image">
      ##TODO: why doesn't this work?
      <a href=${getSigUrl(photo & "?name=orig", "pic")} target="_blank" class="image-attachment">
        <div class="still-image" style="${flex}">
          <img src=${getSigUrl(photo, "pic")} referrerpolicy="">
        </div>
      </a>
    </div>
    #end for
  </div>
  #first = false
#end for
</div>
#end proc
#
#proc renderVideo(video: Video): string =
<div class="attachments media-body">
  <div class="gallery-row" style="max-height: unset;">
    <div class="attachment image">
    <video poster=${video.thumb.getSigUrl("pic")} autoplay muted loop></video>
    <div class="video-overlay">
      <p>Video playback not supported</p>
    </div>
    </div>
  </div>
</div>
#end proc
#
#proc renderGif(gif: Gif): string =
<div class="attachments media-body media-gif">
  <div class="gallery-row" style="max-height: unset;">
    <div class="attachment image">
      <video class="gif" poster=${gif.thumb.getSigUrl("pic")} autoplay muted loop>
        <source src=${gif.url.getSigUrl("video")} type="video/mp4">
      </video>
    </div>
  </div>
</div>
#end proc
#
#proc renderStats(tweet: Tweet): string =
<div class="tweet-stats">
  <span class="tweet-stat">💬 ${$tweet.replies}</span>
  <span class="tweet-stat">🔄 ${$tweet.retweets}</span>
  <span class="tweet-stat">👍 ${$tweet.likes}</span>
</div>
#end proc
#
#proc renderTweet*(tweet: Tweet; class=""): string =
#if class.len > 0:
<div class="${class}">
#end if
<div class="status-el">
  <div class="status-body">
    ${renderHeading(tweet)}
    <div class="status-content-wrapper">
      <div class="status-content media-body">
        ${linkifyText(xmltree.escape(tweet.text))}
      </div>
    </div>
    #if tweet.photos.len > 0:
    ${renderMediaGroup(tweet)}
    #elif tweet.video.isSome:
    ${renderVideo(tweet.video.get())}
    #elif tweet.gif.isSome:
    ${renderGif(tweet.gif.get())}
    #elif tweet.quote.isSome:
    ${renderQuote(tweet.quote.get())}
    #end if
    ${renderStats(tweet)}
  </div>
</div>
#if class.len > 0:
</div>
#end if
#end proc
