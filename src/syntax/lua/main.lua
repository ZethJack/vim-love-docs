package.path = package.path .. ';../love-api/love_api.lua;love-api/?.lua'
local api = require 'love-api/love_api'

local funcstr = ''
local typestr = ''
local callbackstr = ''

print( 'syntax include @loveconf <sfile>:p:h/love-conf.vim' )

local function extractData( tab, index )
	for i, v in pairs( tab ) do
		if i == 'functions' or i == 'callbacks' then
			if tab.name and ( tab.name or '' ):sub( 1, 1 ):match( '%l' ) then funcstr = funcstr .. tab.name .. '\\.\\%(' end
			local func = false
			local typ = false
			local callback = false
			for _, vv in pairs( v ) do
				if tab.name then
					if tab.name:sub( 1, 1 ):match( '%l' ) then
						func = true
						funcstr = funcstr .. vv.name .. '\\|'
					else -- types
						typ = true
						typestr = typestr .. vv.name .. '\\|'
					end
				else
					callback = true
					callbackstr = callbackstr .. vv.name .. '\\|'
				end
			end
			if func then
				-- We don't want to be able to have underscores after the word
				funcstr = funcstr:sub( 1, -3 ) .. '\\)\\)\\|\\%('
			end
			if typ then
				-- We don't want to be able to have underscores after the word or highlight the . or :
				typestr = typestr:sub( 1, -3 ) .. '\\)\\|\\%('
			end
			if callback then
				-- We don't want to be able to have underscores after the word
				callbackstr = callbackstr:sub( 1, -3 ) .. '\\)\\|\\%('
			end
		end
		if type( v ) == 'table' then extractData( v ) end
	end
end
extractData( api )

local function limit( text, pre, post )
	while #text > 0 do
		local start, stop = text:sub( 1, 2500 ):find( '.*\\%)\\|' )
		local current
		if start then
			current = text:sub( start, stop - 2 )
			text = text:sub( stop + 1 )
		else
			current = text .. ')'
			text = ''
		end
		print( pre .. current .. post )
	end
end

limit( '\\%(' .. funcstr:sub( 1, -7 ), 'syntax match lovefunction "\\<love\\.\\%(', '\\)\\>"' )
limit( '\\%(' .. typestr:sub( 1, -7 ), 'syntax match lovetype "[\\:\\.]\\%(', '\\)\\_[^_a-zA-Z]"ms=s+1,me=e-1' )
limit( '\\%(' .. callbackstr:sub( 1, -7 ), 'syntax match lovecallback "\\<love\\.\\%(', '\\)\\>"' )

print( 'syntax region loveconfregion start="\\<love\\.conf\\>" end="\\<end\\>"me=e-3,he=e-3,re=e-3 skipwhite skipempty contains=ALL' )

print( 'execute( "highlight lovefunction " . g:lovedocs_colors )' )
print( 'execute( "highlight lovetype " . g:lovedocs_colors )' )
print( 'execute( "highlight lovecallback " . g:lovedocs_colors )' )
print( 'execute( "highlight loveconf " . g:lovedocs_colors )' )

love.event.quit()
