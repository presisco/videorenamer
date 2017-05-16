--[[
  Copyright (C) 2017 presisco
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

local iup=require "iuplua"
local vnf=require "video_name_formatter"
local fu=require "file_utils"
local iu=require "iup_utils"
local lu=require "lua_utils"
local mi=require "media_info_api"
local cm=require "config_manager"
local llthread=require "llthreads2.ex"

local version="1.0"

-- UI Definition
local function get_button(title)
  return iup.button{title=title,size="80x"}
end

local function get_button_small(title)
  return iup.button{title=title,size="40x"}
end

local function hlabel(text,control)
  if type(text) == "string"
  then
    return iup.hbox{
      iup.label{title=text},
      control;
      alignment="acenter",
      gap="2x"
    }
  else
    return iup.hbox{
      text,
      control;
      alignment="acenter",
      gap="2x"
    }
  end
end

local function vlabel(text,control)
  if type(text) == "string"
  then
    return iup.vbox{
      iup.label{title=text},
      control;
      alignment="aleft",
      gap="2x"
    }
  else
    return iup.vbox{
      text,
      control;
      alignment="aleft",
      gap="2x"
    }
  end
end

local function get_dropdown_edit_small()
  return iup.list{size="80x",dropdown="yes",multiple="no",editbox="yes"}
end

local ctrl_table={}

-- pattern bar
ctrl_table.label_input_pattern=iup.label{title="pattern"}
ctrl_table.list_input_pattern=get_dropdown_edit_small()
ctrl_table.label_input_seq=iup.label{title="pattern sequence"}
ctrl_table.text_input_seq=iup.text{size="320x"}
ctrl_table.button_save_pattern=get_button_small("save")
ctrl_table.button_delete_pattern=get_button_small("delete")

-- template bar
ctrl_table.label_output_template=iup.label{title="pattern"}
ctrl_table.list_output_template=get_dropdown_edit_small()
ctrl_table.label_output_seq=iup.label{title="pattern sequence"}
ctrl_table.text_output_seq=iup.text{size="320x"}
ctrl_table.button_save_template=get_button_small("save")
ctrl_table.button_delete_template=get_button_small("delete")

-- template option bar
ctrl_table.button_save_options=get_button_small("save")
ctrl_table.label_type=iup.label{title="type"}
ctrl_table.list_type=get_dropdown_edit_small()
ctrl_table.label_source=iup.label{title="src"}
ctrl_table.list_source=get_dropdown_edit_small()
ctrl_table.label_team=iup.label{title="team"}
ctrl_table.list_team=get_dropdown_edit_small()
ctrl_table.toggle_detect_res=iup.toggle{title="detect resolution"}
ctrl_table.toggle_detect_video_format=iup.toggle{title="detect video codec"}
ctrl_table.toggle_detect_audio_format=iup.toggle{title="detect audio codec"}
ctrl_table.toggle_replace_space_with_dot=iup.toggle{title="replace space with dot"}

-- settings bar
ctrl_table.button_set_mediainfo=get_button("set mediainfo")
ctrl_table.label_language=iup.label{title="language"}
ctrl_table.list_language=iup.list{size="50x",dropdown="yes",multiple="no"}
ctrl_table.button_refresh=get_button("refresh")
ctrl_table.button_about=get_button("about")

-- mid list
ctrl_table.list_original_file=iup.list{expand="yes",multiple="yes"}
ctrl_table.label_original_file=iup.label{title="original file"}
ctrl_table.list_renamed_file=iup.list{expand="yes",multiple="yes"}
ctrl_table.label_renamed_file=iup.label{title="renamed file"}

-- bottom bar
ctrl_table.button_add_files=get_button("add files")
ctrl_table.button_scan_dir=get_button("scan dir")
ctrl_table.button_delete_selected=get_button("delete selected")
ctrl_table.button_delete_all=get_button("delete all")
ctrl_table.toggle_scan_recursive=iup.toggle{title="scan child dir",size="80x"}
ctrl_table.button_process=get_button("process")

-- informative dialog
ctrl_table.progress_dlg_rename=iup.progressdlg{title="renaming",description="renaming file"}

-- main dialog
ctrl_table.main_dialog = iup.dialog{
  iup.vbox{
    iup.hbox{
      ctrl_table.button_save_pattern,
      vlabel(ctrl_table.label_input_pattern,ctrl_table.list_input_pattern),
      ctrl_table.button_delete_pattern,
      vlabel(ctrl_table.label_input_seq,ctrl_table.text_input_seq);
      alignment="abottom",
      gap="5x",
      margin="0x0"
    },
    iup.frame{
      iup.vbox{
        iup.hbox{
          ctrl_table.button_save_template,
          vlabel(ctrl_table.label_output_template,ctrl_table.list_output_template),
          ctrl_table.button_delete_template,
          vlabel(ctrl_table.label_output_seq,ctrl_table.text_output_seq);

          alignment="abottom",
          gap="5x",
          margin="0x0"
        },
        iup.hbox{
          ctrl_table.button_save_options,
          vlabel(ctrl_table.label_type,ctrl_table.list_type),
          vlabel(ctrl_table.label_source,ctrl_table.list_source),
          vlabel(ctrl_table.label_team,ctrl_table.list_team),
          iup.vbox{
            iup.hbox{
              ctrl_table.toggle_detect_res,
              ctrl_table.toggle_detect_video_format,
              ctrl_table.toggle_detect_audio_format;
              alignment="abottom",
              gap="5x",
              margin="0x0"
            },
            iup.hbox{
              ctrl_table.toggle_replace_space_with_dot;
              alignment="abottom",
              gap="5x",
              margin="0x0"
            }
          };
          alignment="abottom",
          gap="5x",
          margin="0x0"
        }
      }
    },
    iup.hbox{
      hlabel(ctrl_table.label_language,ctrl_table.list_language),
      ctrl_table.button_set_mediainfo,
      ctrl_table.button_refresh,
      ctrl_table.button_about;
      gap="5x",
      margin="0x0"
    },
    iup.hbox{
      vlabel(ctrl_table.label_original_file,ctrl_table.list_original_file),
      vlabel(ctrl_table.label_renamed_file,ctrl_table.list_renamed_file);
      gap="5x",
      margin="0x0"
    },
    iup.hbox{
      ctrl_table.button_add_files,
      ctrl_table.button_scan_dir,
      ctrl_table.toggle_scan_recursive,
      ctrl_table.button_delete_selected,
      ctrl_table.button_delete_all,
      ctrl_table.button_process;
      gap="5x",
      alignment="acenter",
      margin="0x0"
    };
    gap="5x0",
    margin="10x10"
  }; title="Video Renamer",size="HALFxHALF"}
ctrl_table.scan_progress_dlg=iup.progressdlg{title="progress",description="scanning directories",parentdialog=ctrl_table.main_dialog}

-- Data Definition
--[[ files={{filename="",dir="",extension="",info={}},...} ]]
local files={}

local input_patterns={
  ["default tv show"]="<NAME>.S<#SEASON>E<#EPISODE>.<TITLE>.<#>p",
  ["default movie"]="<NAME>.<#YEAR><!.<TYPE>!>.<#>p"
}

local output_templates={
  ["default tv show"]="<NAME>.S<SEASON>E<EPISODE>.<TITLE>.<SRC>.<RES>.<TYPE>.<AFORMAT>.<VFORMAT>-<TEAM>",
  ["default movie"]="<NAME>.<YEAR><!.<TYPE>!>.<RES>.<SRC>.<AFORMAT>.<VFORMAT>-<TEAM>"
}

local preference={
  teams={"","NONE","VideoRenamer"},
  types={"","PROPER","AMZN","NF","PREAiR"},
  sources={"","WEB-DL","WEBRip","Bluray","BDRip","HDTV"},
  team="VideoRenamer",
  type="",
  source="WEBRip",
  detect_resolution="ON",
  detect_video_format="ON",
  detect_audio_format="ON",
  replace_space_with_dot="ON",
  input_pattern="default movie",
  output_template="default movie",
  language="chs",
  media_info_path="MediaInfo.exe",
  scan_recursive="OFF"
}

local languages={
  "chs",
  "eng"
}

local function update_ui_language()
  iu.set_label_from_file(ctrl_table,"lan\\"..preference.language..".txt","gbk")
end

local function set_input_pattern()
  ctrl_table.text_input_seq.value=input_patterns[preference.input_pattern]
end

local function load_pattern_list()
  ctrl_table.list_input_pattern.removeitem="all"
  iu.add_items_to_list(ctrl_table.list_input_pattern,lu.get_table_keys(input_patterns))
  ctrl_table.list_input_pattern.value=preference.input_pattern
  set_input_pattern()
end

local function set_output_template()
  ctrl_table.text_output_seq.value=output_templates[preference.output_template]
end

local function load_template_list()
  ctrl_table.list_output_template.removeitem="all"
  iu.add_items_to_list(ctrl_table.list_output_template,lu.get_table_keys(output_templates))
  ctrl_table.list_output_template.value=preference.output_template
  set_output_template()
end

local function get_formatted_name(original_name,info,input_pattern,output_template)
  local extracted_info=vnf.parse_video_name(original_name,input_pattern)
  local rename_params={}
  lu.table_merge(rename_params,extracted_info)
  
  if preference.source ~= ""
  then
    rename_params.src=preference.source
  end
  
  if preference.team ~= ""
  then
    rename_params.team=preference.team
  end
  
  if preference.type ~= ""
  then
    rename_params.type=preference.type
  end

  if preference.detect_resolution == "ON"
  then
    rename_params["res"]=mi.get_resolution_code(info.Video[1])
  end

  if preference.detect_audio_format == "ON"
  then
    rename_params["aformat"]=mi.get_audio_format_code(info.Audio[1])
  end

  if preference.detect_video_format == "ON"
  then
    rename_params["vformat"]=mi.get_video_format_code(info.Video[1])
  end

  local renamed_filename=vnf.generate_video_name(output_template,rename_params)
  return renamed_filename:gsub("%s+",".")
end

local function update_list()
  ctrl_table.list_original_file.removeitem="all"
  ctrl_table.list_renamed_file.removeitem="all"
  local input_pattern=ctrl_table.text_input_seq.value
  local output_template=ctrl_table.text_output_seq.value
  for index,file in ipairs(files)
  do
    ctrl_table.list_original_file.appenditem=file.filename..file.extension
    local renamed_filename=get_formatted_name(file.filename,file.info,input_pattern,output_template)
    ctrl_table.list_renamed_file.appenditem=renamed_filename..file.extension
  end
end


-- callbacks

function ctrl_table.button_set_mediainfo:action()
  local file_dlg=iup.filedlg{multiplefiles="no",dialogtype="open",file="mediainfo.exe"}
  file_dlg:popup()

  if file_dlg.status == "0"
  then
    preference.media_info_path=file_dlg.value
    mi.set_media_info_path(preference.media_info_path)
  end
end

function ctrl_table.list_language:action(text,item,state)
  if state == 1
  then
    preference.language=text
    update_ui_language()
  end
end

function ctrl_table.button_add_files:action()
  local add_file_dialog=iup.filedlg{multiplefiles="yes",dialogtype="open"}
  add_file_dialog:popup()

  if add_file_dialog.status == "0"
  then
    local directory,new_files=iu.parse_file_dialog_result(add_file_dialog.value)
    for i=1,#new_files
    do
      if mi.is_video_file(directory..new_files[i])
      then
        local new_file={}
        --lu.log("picked file: "..new_files[i].." in dir: "..directory)
        new_file.filename=fu.remove_extension(new_files[i])
        new_file.dir=directory
        new_file.extension=fu.get_extension(new_files[i])
        local info_table=mi.get_file_info(new_file.dir..new_file.filename..new_file.extension)
        if info_table["Video"] ~= nil
        then
          new_file.info=info_table
          table.insert(files,new_file);
        end
      end
    end
  end
  update_list()
end

function ctrl_table.button_scan_dir:action()
  local add_dir_dialog=iup.filedlg{dialogtype="dir"}
  add_dir_dialog:popup()

  if add_dir_dialog.status == "0"
  then
    local new_dir=add_dir_dialog.value.."\\"
    local detected_files={}
    local recursive=false
    if ctrl_table.toggle_scan_recursive.value == "ON"
    then
      recursive=true
    end

    ctrl_table.scan_progress_dlg:show()

    local detected_files=fu.get_files(new_dir,recursive,mi.is_video_file)

    for i=1,#detected_files
    do
      detected_files[i].info=mi.get_file_info(detected_files[i].dir..detected_files[i].filename..detected_files[i].extension)
    end

    lu.table_merge(files,detected_files)
    update_list()
    ctrl_table.scan_progress_dlg:hide()
  end
end

function ctrl_table.button_delete_selected:action()
  local selected_index=iu.parse_list_value(list_original_file.value)
  for i=1,#selected_index
  do
    ctrl_table.list_original_file.removeitem=selected_index[i]-i+1
    ctrl_table.list_renamed_file.removeitem=selected_index[i]-i+1
    table.remove(files,selected_index[i]-i+1)
  end
end

function ctrl_table.button_delete_all:action()
  ctrl_table.list_original_file.removeitem="all"
  ctrl_table.list_renamed_file.removeitem="all"
  lu.clear_list(files)
end

function ctrl_table.button_save_pattern:action()
  local pattern_name=ctrl_table.list_input_pattern.value
  local pattern_seq=ctrl_table.text_input_seq.value
  input_patterns[pattern_name]=pattern_seq
  cm.save_props("input_patterns.conf",input_patterns)
  load_pattern_list()
end

function ctrl_table.button_delete_pattern:action()
  if lu.get_table_size(input_patterns) < 2
  then
    iup.Message("Warning","no less than 1")
    return
  end

  input_patterns[preference.input_pattern]=nil
  preference.input_pattern=lu.get_first_table_key(input_patterns)

  load_pattern_list()

end

function ctrl_table.button_save_template:action()
  local template_name=ctrl_table.list_output_template.value
  local template_seq=ctrl_table.text_output_seq.value
  output_templates[template_name]=template_seq
  cm.save_props("outout_templates.conf",output_templates)
  load_template_list()
end

function ctrl_table.button_delete_template:action()
  if lu.get_table_size(output_templates) < 2
  then
    iup.Message("Warning","no less than 1")
    return
  end

  output_templates[preference.output_template]=nil
  preference.output_template=lu.get_first_table_key(output_templates)

  load_template_list()
end

function ctrl_table.button_save_options:action()
  preference.team=ctrl_table.list_team.value
  preference.type=ctrl_table.list_type.value
  preference.source=ctrl_table.list_source.value

  if not lu.table_contains(preference.teams,preference.team)
  then
    table.insert(preference.teams,preference.team)
    ctrl_table.list_team.removeitem="all"
    iu.add_items_to_list(ctrl_table.list_team,preference.teams)
    ctrl_table.list_team.value=preference.team
  end

  if not lu.table_contains(preference.types,preference.type)
  then
    table.insert(preference.preference.type)
    ctrl_table.list_type.removeitem="all"
    iu.add_items_to_list(ctrl_table.list_type,preference.types)
    ctrl_table.list_type.value=preference.type
  end

  if not lu.table_contains(preference.sources,preference.source)
  then
    table.insert(preference.sources,preference.source)
    ctrl_table.list_source.removeitem="all"
    iu.add_items_to_list(ctrl_table.list_source,preference.sources)
    ctrl_table.list_source.value=preference.source
  end
  cm.save_props("preference.conf",preference)
end

function ctrl_table.button_refresh:action()
  ctrl_table.list_renamed_file.removeitem="all"

  local input_pattern=ctrl_table.text_input_seq.value
  local output_template=ctrl_table.text_output_seq.value

  preference.team=ctrl_table.list_team.value
  preference.type=ctrl_table.list_type.value
  preference.source=ctrl_table.list_source.value
  preference.detect_audio_format=ctrl_table.toggle_detect_audio_format.value
  preference.detect_video_format=ctrl_table.toggle_detect_video_format.value
  preference.detect_resolution=ctrl_table.toggle_detect_res.value
  preference.replace_space_with_dot=ctrl_table.toggle_replace_space_with_dot.value

  for index,file in ipairs(files)
  do
    local renamed_filename=get_formatted_name(file.filename,file.info,input_pattern,output_template)
    ctrl_table.list_renamed_file.appenditem=renamed_filename..file.extension
  end
end

function ctrl_table.button_about:action()
  local about_dialog=iup.dialog{
    iup.vbox{
      iup.label{title="Version: "..version},
      iup.hbox{
        iup.label{title="Author: presisco"},
        iup.link{url="https://github.com/presisco",title="https://github.com/presisco"};
        margin="0x",
        gap="5x"
      },
      iup.hbox{
        iup.label{title="Project Site:"},
        iup.link{url="https://github.com/presisco/videorenamer",title="https://github.com/presisco/videorenamer"};
        margin="0x",
        gap="5x"
      };
      margin="10x10",
      alignment="aleft",
      gap="5x"
    };
    title="about",shrink="yes"
  }
  about_dialog:popup()
end

function ctrl_table.button_process:action()
  ctrl_table.progress_dlg_rename:show()

  local rename_table={}
  for index=1,#files
  do
    os.rename(files[index].dir..ctrl_table.list_original_file[index],files[index].dir..ctrl_table.list_renamed_file[index])
  end

  ctrl_table.progress_dlg_rename:hide()
end

function ctrl_table.list_input_pattern:action(text,item,state)
  if state == 1
  then
    preference.input_pattern=text
    set_input_pattern()
  end
end

function ctrl_table.list_output_template:action(text,item,state)
  if state == 1
  then
    preference.output_template=text
    set_output_template()
  end
end

local function load_data()
  preference=cm.load_props("preference.conf",preference)
  mi.set_media_info_path(preference.media_info_path)
  input_patterns=cm.load_props("input_patterns.conf",input_patterns)
  output_templates=cm.load_props("output_templates.conf",output_templates)
end

local function prepare_ui()
  --update_ui_language()

  ctrl_table.main_dialog:map()

  update_ui_language()

  ctrl_table.main_dialog:show()

  ctrl_table.toggle_scan_recursive.value=preference.scan_recursive
  ctrl_table.toggle_detect_audio_format.value=preference.detect_audio_format
  ctrl_table.toggle_detect_video_format.value=preference.detect_video_format
  ctrl_table.toggle_detect_res.value=preference.detect_resolution
  ctrl_table.toggle_replace_space_with_dot.value=preference.replace_space_with_dot

  function ctrl_table.main_dialog:close_cb()
    preference.scan_recursive=ctrl_table.toggle_scan_recursive.value
    preference.detect_audio_format=ctrl_table.toggle_detect_audio_format.value
    preference.detect_video_format=ctrl_table.toggle_detect_video_format.value
    preference.detect_resolution=ctrl_table.toggle_detect_res.value
    cm.save_props("preference.conf",preference)
    cm.save_props("input_patterns.conf",input_patterns)
    cm.save_props("output_templates.conf",output_templates)
  end

  iu.add_items_to_list(ctrl_table.list_language,languages)
  ctrl_table.list_language.value=lu.get_array_item_index(languages,preference.language)

  iu.add_items_to_list(ctrl_table.list_source,preference.sources)
  ctrl_table.list_source.value=preference.source

  iu.add_items_to_list(ctrl_table.list_type,preference.types)
  ctrl_table.list_type.value=preference.type

  iu.add_items_to_list(ctrl_table.list_team,preference.teams)
  ctrl_table.list_team.value=preference.team

  load_pattern_list()
  load_template_list()

end

local function main()
  load_data()
  prepare_ui()
  iup.MainLoop()
end

main()
