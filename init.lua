-- mod-version:2 -- lite-xl 2.0
local core = require 'core'
local common = require 'core.common'
local command = require 'core.command'
local DocView = require 'core.docview'

local av = nil
local proc = nil
local started = false
-- extensions mapped to language names
local extTbl = {
    ['asm'] = 'assembly',
    ['c,h'] = 'c',
    ['cpp,hpp'] = 'cpp',
    ['cr'] = 'crystal',
    ['cs'] = 'cs',
    ['css'] = 'css',
    ['dart'] = 'dart',
    ['ejs,tmpl'] = 'ejs',
    ['ex,exs'] = 'elixir',
    ['gitignore,gitattributes,gitmodules'] = 'git',
    ['go'] = 'go',
    ['hs'] = 'haskell',
    ['htm,html,mhtml'] = 'html',
    ['png,jpg,jpeg,jfif,gif,webp'] = 'image',
    ['java,class,properties'] = 'java',
    ['js'] = 'javascript',
    ['json'] = 'json',
    ['kt'] = 'kotlin',
    ['lua'] = 'lua',
    ['md,markdown'] = 'markdown',
    ['t'] = 'perl',
    ['php'] = 'php',
    ['py,pyx'] = 'python',
    ['jsx,tsx'] = 'react',
    ['rb'] = 'ruby',
    ['rs'] = 'rust',
    ['sh,bat'] = 'shell',
    ['swift'] = 'swift',
    ['txt,rst,rest'] = 'text',
    ['toml'] = 'toml',
    ['ts'] = 'typescript',
    ['vue'] = 'vue',
    ['xml,svg,yml,yaml,cfg,ini']= 'xml',
}

local function extToFtype(origext)
	for exts, ftype in pairs(extTbl) do
		for ext in exts:gmatch('([^,]+)') do
			if ext == origext then return ftype end
		end
	end
	
	return 'unknown'
end

local function send(data)
	if not started then
		core.log 'presene isnt started'
		return
	end

	for k, v in pairs(data) do
		proc:write(k .. ' ' .. v .. '\n')
	end
	proc:write 'send\n'
end

local function update_presence()
	local filename = 'unsaved file'
	local doc = av.doc
	if doc.filename then	
		filename = common.basename(doc.filename)
	end
	
	local ext = filename:match('^.+(%..+)$')
	local ftype = 'unknown'
	if ext then ftype = extToFtype(ext:sub(2)) end

	local projDir = common.basename(core.project_dir)
	local state = 'Project: ' .. projDir
	local details = 'Editing ' .. filename
	send({
		state = state,
		details = details,
		bigImg = ftype,
		bigText = ''
	})
end

local function start()
	if started then
		core.log 'Rich presence has already started'
		return
	end
	local lpPath = USERDIR .. '/plugins/litepresence/litepresence'
	started = true
	proc = process.start {lpPath}
end

start()

local function stop()
	if not started then
		core.log 'Rich presence is not running'
		return
	end
	started = false
	proc:terminate()
end

local function restart()
	stop()
	start()
	update_presence()
end

local setActiveView = core.set_active_view
function core.set_active_view(view)
	if getmetatable(view) == DocView and view ~= av then
		av = view
		update_presence()
	end
	setActiveView(view)
end

local coreQuit = core.quit
function core.quit(force)
	stop()
	coreQuit(force)
end

local coreRestart = core.restart
function core.restart(force)
	stop()
	coreRestart(force)
end

command.add('core.docview', {
	['litepresence:stop-rich-presence'] = stop,
	['litepresence:start-rich-presence'] = start,
	['litepresence:restart-rich-presence'] = restart
})
