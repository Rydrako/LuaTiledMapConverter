-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

--- UI Module
local ui = {}
local conversionTool = require("conversionTool")
local uiUtil = require("uiUtil")
local util = require("util")

--Menu items
item_exit = iup.item{title="&Quit\tCtrl+Q", 
	action=(function ()
		return iup.CLOSE
	end)}
item_about = iup.item{title="&About\tCtrl+A"}

-- About Dialog Layout
abt_btn = iup.button{title="OK", expand="HORIZONTAL"}

abt_box = iup.vbox{
		iup.label{title="Lua-Tiled Map Converter", font="Helvetica, 16", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="Version " .. SOFTWARE_VERSION, font="Helvetica, 8", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="Copyright © 2021 Rydrako", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="You may modify and redistribute this program under the terms of the GPL \n(version 3 or later)\nRepo Link:", alignment="acenter", 
			expand="HORIZONTAL"},
		iup.text{value="https://github.com/Rydrako/LuaTiledMapConverter", expand="HORIZONTAL", alignment="acenter", readonly="YES"},
		iup.label{separator="HORIZONTAL"},
		abt_btn,
		alignment="aright",
		margin="10x10",
		gap="10"
	}

abt_dlg = iup.dialog{
		abt_box,
		title = "About",
		size = "QUARTERxQUARTER",
		resize = "NO"
	}

function item_about:action ()
	abt_dlg:showxy(iup.CENTER,iup.CENTER)
end

function abt_btn:action ()
	abt_dlg:hide()
end

-- File and Help Menu
file_menu = iup.menu{item_open, iup.separator{}, item_tiled, item_lua, item_exit}
help_menu = iup.menu{item_about}
sub1_menu = iup.submenu{file_menu, title = "&File"}
sub2_menu = iup.submenu{help_menu, title = "&Help"}
menu = iup.menu{sub1_menu, sub2_menu}

--- Starts the process for converting the file(s) and 
--- returns a table with title and message for an iup pop up
--
-- @param 	function 	process 				the conversion method to execute, requires the params (string, ..), 
--																		see conversionTools methods for details

function export_files (file_field, export_field, process)

	if util.is_nil_or_empty(file_field.txt.value) then
		return {title="Error", msg="Please enter a valid input file"}
	elseif util.is_nil_or_empty(export_field.txt.value) then
		return {title="Error", msg="Please enter a valid output directory or file name"}
	end

	local files = util.split(file_field.txt.value, "|")

	if #files > 1 then

		local dir = files[1]
		local fails = 0
		local error_msg = "\n\nError occured converting the following files:"
		local error_log = ""
		local successes = 0

		for i=2,#files-1 do

			local op_result = process(dir .. "\\" .. files[i])
			if not op_result["success"] then

				fails = fails + 1
				error_log = error_log .. "\n" .. files[i] .. "\n\t " .. op_result["message"] .. "\n"
			else
				successes = successes + 1
			end
		end

		local _title = "Success"
		local _msg = "Successfully converted " .. successes .. "/" .. #files-2 .. " files!"

		if fails > 0 then
			_title = successes == 0 and "Error" or "Warning"
			_msg = successes == 0 and "Errors occured converting files" or (_msg .. error_msg)
		end

		return {title=_title, msg=_msg, log=error_log}
	else

		if not process(file_field.txt.value) then

			return {title="Error", msg="Error occured converting " .. util.get_filename(file_field.txt.value)}
		else

			return {title="Success", msg="Successfully converted " .. util.get_filename(file_field.txt.value)}
		end
	end
end

-- Tab containers

function create_tiled_tab ()

	local file_field = uiUtil.file_input("*File(s): ", "30", function (_txt) 

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "OPEN",
				filter = "*.lua;",
				filterinfo = "Lua Files",
				multiplefiles = "Yes"
			},
			_txt, "Drag & Drop or Browse for one or more files here for conversion.")
	end)

	local export_field = uiUtil.file_input(" *Path: ", "30", function (_txt)

			uiUtil.file_dialog(iup.filedlg{
					dialogtype = "DIR"
				},
				_txt, "Drag & Drop or Browse for a folder or file to output to.")
		end)

	local img_field = uiUtil.file_input("", "30", function (_txt)

			uiUtil.file_dialog(iup.filedlg{
					dialogtype = "DIR"
				},
				_txt)
		end)

	img_field["active"] = "NO"

	local tileset_field = uiUtil.file_input("   Tileset Path: ", "27", function (_txt)

			uiUtil.file_dialog(iup.filedlg{
					dialogtype = "DIR"
				},
				_txt)
		end)

	local package_tgl = iup.toggle{title = "Add package names to Path", 
	value="ON", 
	tip="If enabled this option concetates packages within file names to the Output Path.\n\n" ..
			"For Example, a file with the name \"world1.level1.map.lua\" will output to the directory:\n" ..
			"<Output Path>/world1/level1/map.json"
	}

	local tileset_tgl = iup.toggle{title = "Use Output Path", 
		action=(function (self)
				img_field["active"] = self.value=="ON" and "NO" or "YES"
			end), 
		value="ON"}

	local margin = iup.text{SPIN="Yes", spinmin=0, rastersize="48x",}
	local spacing = iup.text{SPIN="Yes", spinmin=0, rastersize="48x"}

	function export_tiled (file)

		return conversionTool.toTiled(file, 
													export_field.txt.value, 
													tileset_tgl.value=="OFF" and img_field.txt.value or nil, 
													margin.value, spacing.value, 
													package_tgl.value=="ON")
	end

	return iup.vbox{
		iup.label{title="         Input", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		file_field, --Input section
		iup.label{title="         Output", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		iup.vbox{  --Export section

					export_field,
					iup.hbox{
						package_tgl,
						gap = "10",
						margin = "57x10"
					}
			},
		iup.label{title="         Tilesets", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		iup.vbox{ --Tilesets section

			iup.hbox{
				iup.label{title="Dir:"},
				tileset_tgl,
				gap = "15",
				margin = "25x10"
			},
			iup.hbox{
				img_field,
				margin = "35x0"
			},
			iup.hbox{

					iup.label{title="Margin: "},
					margin,
					iup.label{title="Spacing: "},
					spacing,
					alignment="acenter",
					gap = "10",
					margin = "10x10"

			}
		},
		iup.label{separator="HORIZONTAL"},
		iup.hbox{
			iup.button{title="Export to .JSON", expand="HORIZONTAL",
				action=(function ()
					local result = export_files(file_field, export_field, export_tiled)

					if result["details"] ~= nil then
						uiUtil.message(result["title"], result["msg"], result["details"])
					else
						iup.Message(result["title"], result["msg"])
					end
				end)
			},
			alignment="acenter",
			gap = "10",
			margin = "50x10",
		},
		tabtitle = "Tiled",
		tip="Convert files to JSON"
	}
end

function create_lua_tab ()

	local file_field = uiUtil.file_input("*File(s): ", "30", function (_txt) 

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "OPEN",
				filter = "*.lua;*.json",
				filterinfo = "Lua & Tiled Files",
				multiplefiles = "Yes"
			},
			_txt, "Drag & Drop or Browse for one or more files here for conversion.")
	end)

	local export_field = uiUtil.file_input(" *Path: ", "30", function (_txt)

			uiUtil.file_dialog(iup.filedlg{
					dialogtype = "DIR"
				},
				_txt, "Drag & Drop or Browse for a folder or file to output to.")
		end)

	local tileset_field = uiUtil.file_input("  *Tileset Path: ", "27", function (_txt)

			uiUtil.file_dialog(iup.filedlg{
					dialogtype = "DIR"
				},
				_txt)
		end)

	local tileset_tgl = iup.toggle{title = "Use Output Path", 
		action=(function (self)
				img_field["active"] = self.value=="ON" and "NO" or "YES"
			end), 
		value="ON"}

	function export_lua (file)

		return conversionTool.toLua(file, 
												export_field.txt.value, 
												tileset_field.txt.value)
	end

	return iup.vbox{
		iup.label{title="         Input", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		file_field, --Input section
		iup.label{title="         Output", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		iup.vbox{  --Export section

					export_field,
					iup.hbox{
						package_tgl,
						gap = "10",
						margin = "57x10"
					}
			},
		iup.label{title="         Tilesets", fgcolor="100 100 100"},
		iup.label{separator="HORIZONTAL"},
		iup.vbox{ --Tilesets section
			tileset_field
		},
		iup.label{separator="HORIZONTAL"},
		iup.hbox{
			iup.button{title="Export to Lua", expand="HORIZONTAL",
				action=(function ()
					local result = export_files(file_field, export_field, export_lua)

					if result["log"] ~= nil then
						uiUtil.message(result["title"], result["msg"], result["log"])
					else
						iup.Message(result["title"], result["msg"])
					end
				end)
			},
			alignment="acenter",
			gap = "10",
			margin = "50x10",
		},
		tabtitle = "Lua",
		tip="Convert files to Lua"
	}
end

tiled_tab = create_tiled_tab()
lua_tab = create_lua_tab()

ui = iup.dialog{
  iup.hbox{
  	iup.tabs{
  		tiled_tab,
  		lua_tab
  	}
  },
  title = "Lua-Tiled Map Converter",
  size = "QUARTERx230",
  menu = menu,
  resize = "NO"
}

-- Hot keys
function ui:k_any(c)

	if c == iup.K_cA then
		item_about:action()
	elseif c == iup.K_cQ then
		item_exit:action()
	end
end

return ui;