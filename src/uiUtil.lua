-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

--- UI Utility Module
local uiUtil = {}

--- returns an hbox of a standard file input field included with a label and browse button
--
-- @param	string 		label 			the label that is displayed on the right of the text field
-- @param	string 		columns 		width of the text field
-- @param	function 	action 			the function that will become the browse button's action

function uiUtil.file_input (label, columns, action)

	local lbl = iup.label{title=label}
	local txt = iup.text{visiblecolumns=columns}
	local btn = iup.button{title="Browse..."}

	function btn:action()
		action(txt)
	end

	local box = iup.hbox{
			lbl,
			txt,
			btn,
			txt=txt,
			btn=btn,
			alignment="acenter",
			gap = "10",
			margin = "10x10"
		}

	function txt:dropfiles_cb(filename, n, x, y)
		txt.value = filename
	end

	return box
end

--- Shows a file choice dialog and sets the given text field's value to the selected file path. 
--- Should generally be used as a file input's action.
--
-- @param 	iup.filedlg _filedlg 		the dialog to display
-- @param 	iup.text 	_txt_field		text field

function uiUtil.file_dialog (filedlg, txt_field)

	filedlg:popup(iup.CENTER, iup.CENTER)

	if (tonumber(filedlg.status) ~= -1) then

		local filename = filedlg.value

		if filename then
			txt_field.value = filename
		end
	end
	filedlg:destroy()
end

return uiUtil