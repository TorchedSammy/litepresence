-- mod-version:3
local core = require 'core'
local command = require 'core.command'
local common = require 'core.common'
local config = require 'core.config'
local process = require 'process'
local Doc = require 'core.doc'
local DocView = require 'core.docview'
local EmptyView = require 'core.emptyview'
local pragtical = EmptyView().title == 'Pragtical'

local function merge(orig, tbl)
	if tbl == nil then return orig end
	for k, v in pairs(tbl) do
		orig[k] = v
	end

	return orig
end

local function localPath()
   local str = debug.getinfo(2, 'S').source:sub(2)
   return str:match('(.*[/\\])')
end

local function makeTbl(tbl)
	local t = {}
	for exts, ftype in pairs(tbl) do
		for ext in exts:gmatch('[^,]+') do
			t[ext] = ftype
		end
	end
	return t
end

local conf = merge({
	binPath = localPath() .. 'litepresence',
	projectTime = false,
	clientID = '749282810971291659'
}, config.plugins.litepresence)

local av = nil
local proc = nil
local started = false
-- extensions mapped to language names
local extTbl = makeTbl {
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
    ['pl,pm,t'] = 'perl',
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
    ['xml,svg,yml,yaml,cfg,ini'] = 'xml',
}

local function send(data)
	for k, v in pairs(data) do
		proc:write(k .. ' ' .. v .. '\n')
	end
	proc:write 'send\n'
end

local function update_presence()
	if not started then return end
	local data
	local avMt = getmetatable(av)
	if avMt == DocView then
		local filename = 'unsaved file'
		local doc = av.doc
		if doc.filename then
			filename = common.basename(doc.filename)
		end

		local ext = filename:match('^.+(%..+)$')
		local ftype = 'unknown'
		if ext then ftype = extTbl[ext:sub(2)] or 'unknown' end

		local projDir = common.basename(core.project_dir or core.root_project().path)
		local state = 'Project: ' .. projDir
		local details = 'Editing ' .. filename
		data = {
			state = state,
			details = details,
			bigImg = ftype,
			bigText = '',
			smallImg = not pragtical and 'litexl' or 'pragtical',
			smallText = not pragtical and 'Lite XL' or 'Pragtical'
		}
	elseif avMt == EmptyView then
		data = {
			state = 'Idling',
			details = '',
			bigImg = 'afk',
			bigText = 'Idling',
			smallImg = not pragtical and 'litexl' or 'pragtical',
			smallText = not pragtical and 'Lite XL' or 'Pragtical'
		}
	end
	if data then
		if not conf.projectTime then data.timestamp = 'y' end
		send(data)
	end
end

local function start()
	if started then
		core.log 'Rich presence has already started'
		return
	end
	started = true
	proc = process.start {conf.binPath, '-id', conf.clientID}
end

core.add_thread(function()
	while true do
		if not proc:running() and started then
			local err = proc:read_stdout() or proc:read_stderr() or '!? Binary quit unexpectedly'
			core.error('Litepresence: ' .. err)
			started = false
		end
		coroutine.yield(0.5)
	end
end)

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

local docSave = Doc.save
function Doc:save(...)
	if self.new_file then
		docSave(self, ...)
		update_presence()
	end
	docSave(self, ...)
end

local setActiveView = core.set_active_view
function core.set_active_view(view)
	if view ~= av then
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
