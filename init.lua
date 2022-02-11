-- mod-version:2 -- lite-xl 2.0
local core = require 'core'
local common = require 'core.common'
local command = require 'core.command'
local DocView = require 'core.docview'

local av = nil
local proc = nil
local started = false

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
	if ext then
		ftype = ext:sub(2)
		if ext == '.md' then ftype = 'markdown' end
	end

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
