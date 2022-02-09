-- mod-version:2 -- lite-xl 2.0
local core = require 'core'
local common = require 'core.common'
local DocView = require 'core.docview'

local av = nil
local lpPath = USERDIR .. '/plugins/litepresence/litepresence'
local proc = process.start {lpPath}

local function send(data)
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
	local ftype = ''
	if ext then
		ftype = ext:sub(2)
		if ext == '.md' then ftype = 'markdown' end
	else
		ftype = 'unknown'
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
	proc:terminate()
	coreQuit(force)
end

local coreRestart = core.restart
function core.restart(force)
	proc:terminate()
	coreRestart(force)
end
