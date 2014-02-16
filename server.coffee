### server.coffee
Camera POC for Catchy.
- 2014-02-16: use port from env, if specified.
- 2014-02-10: Enough. Canvas clip bug, still.
- 2014-02-04: Converted to Zappa.
###

stylus=require 'stylus'

require('zappajs') parseInt(process.env.PORT || process.env.npm_package_config_port || 3000,10),->
	@use 'partials'
	@enable 'default layout'
	@with css:'stylus'
	@io.set 'log level',1 # Shut up already!

	@view index:->
		section ->
			h1 @title
			p '''Just to demo how browsers use the camera on any device (that has a camera). Doesn't yet work on all browsers — see <a href="http://caniuse.com/#feat=stream">Can I use… getUserMedia/Stream API</a> for status and resources.'''

	@client '/app.js':->
		$ ->
			say=$('p')
			sect=$('section')
			w=h=0 # Make these "global".
			$('<button id="cam">Open the camera</button>').appendTo(sect)

			sect.on 'click','#cam',(ev)->
				w=sect.width(); h=w*3/4 # Measure again. Floats are OK! Or listen to resize?
				$('#cam,canvas').remove() # Make room.
				say.text 'Give browser permission to open camera.'
				v=$('<video autoplay>').width(w).height(h).appendTo(sect).get(0)

				getmederr=(err)->
					say.text "ERROR: video capture failed (#{err.code}). Please tell us what devide and browser you're using."
				vidshow=(stream)->
					if navigator.getUserMedia
						v.src=stream
					else if navigator.webkitGetUserMedia
						v.src=window.webkitURL.createObjectURL stream
					else if navigator.mozGetUserMedia
						v.src=window.URL.createObjectURL stream
					# Video on now.
					$('<button id="shoot">Take a picture!</button>').appendTo(sect)

				if navigator.getUserMedia
					navigator.getUserMedia {video:true,audio:false},vidshow,getmederr
				else if navigator.webkitGetUserMedia
					navigator.webkitGetUserMedia {video:true,audio:false},vidshow,getmederr
				else if navigator.mozGetUserMedia
					navigator.mozGetUserMedia {video:true,audio:false},vidshow,getmederr
				else
					# Unsupported?
					say.text 'ERROR: getUserMedia unavailable. Does device have a camera? Please tell us what devide and browser you\'re using.'

				ev.preventDefault()

			sect.on 'click','#shoot',(ev)->
				cv=$("<canvas width=\"#{w}\" height=\"#{h}\">").width(w).height(h).appendTo(sect)
				cv.get(0).getContext('2d').drawImage $('video').get(0),0,0 #??? Might throw exceptions!
				say.text "Snapshot! (#{w}x#{h})"
				$('video,button').remove() # Don't need them no more.
				$('<button id="cam">Another one?</button>').appendTo(sect)
				ev.preventDefault()

	@get '/':->
		@render index:
			title:'Cross-Platform Web Camera POC'
			scripts:'''
				/zappa/Zappa-simple.js
				/app.js
				'''.match /[^\s]+/g
			style:stylus.render '''
body
	font-family Ubuntu,sans-serif
	font-size larger
	background url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAaklEQVQYV2NkYGAwBuKzQAwC9UA8C4ifQ/n/GaEMkCIfIG6E8iWB9DMgZoQpAOncgmTSfyBbCmQSSAFIEqYTZNIZkE6YSSAGyDi4nUC2CbKb4CphdqK7CaYAbieSb8BuAikASSKblIbsJgCKXBfTNjWx1AAAAABJRU5ErkJggg==") repeat
	text-align center
	section
		max-width 30em
		margin 1em auto
		background-color rgba(255,255,255,0.7)
		border-radius 1em
		padding 1em
		h1
			margin 0
		button
			padding 1em
			background-color lightseagreen
			font-size inherit
			border-radius 1em
'''
