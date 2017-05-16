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

local iup_utils={}

function iup_utils.parse_file_dialog_result(result)
  local filenames={}
  local dir=""
  local index=result:find("|")
  local next=0
  local length=result:len()
  if index == nil
  then
    local filename=result:gsub("(.*)\\","")
    table.insert(filenames,filename)
    dir=result:match("(.*)\\").."\\"
  else
    index=index+1
    while index < length-1
    do
      next=result:find("|",index)
      table.insert(filenames,result:sub(index,next-1))
      index=next+1
    end
    dir=result:match("(.-)|").."\\"
  end
  return dir,filenames
end

function iup_utils.parse_list_value(value)
  local selected_index={}
  local selected_sign="+"
  
  local sign_dex=selected_sign:byte(1)
  for i=1,value:len()
  do
    if value:byte(i) == sign_dex
    then
      table.insert(selected_index,i)
    end
  end
  
  return selected_index
end

--[[
  table : {ctrl_name="",ctrl_name="",...}
]]
function iup_utils.set_label(ctrl_array,label_text,format)
  local iconv_utils=require "iconv_utils"
  iconv_utils.set_mode("utf-8",format)
  for key,value in pairs(ctrl_array)
  do
    if label_text[key] ~= nil
    then
      for inner_key,inner_value in pairs(label_text[key])
      do
        ctrl_array[key][inner_key]=iconv_utils.convert(inner_value)
      end
    else
      print("iup_utils: control "..key.." don't have label\n")
    end
  end
end

--[[
  table : {ctrl_name={title="",description="",...},...}
]]
function iup_utils.get_language_table(filename)
  local language_file,err_msg=io.open(filename,"r")
  if language_file == nil
  then
    print("language file: "..filename.." not found!")
    return;
  else
    local language_table={}
    local format="utf-8"
    for line in language_file:lines()
    do
      local has_prop=line:find(".",1,true)
      local key=line:match("(.-)%.")
      local prop=line:match("%.(.-)=")
      local value=line:match("=(.*)")
      if has_prop == nil
      then
        format=value
      elseif line ~= "" and line ~= nil
      then
        if language_table[key] == nil
        then
          language_table[key]={}
        end
        language_table[key][prop]=value
      end
    end
    return language_table,format
  end
end

function iup_utils.set_label_from_file(ctrl_table,filename,target_format)
  local language_table,format=iup_utils.get_language_table(filename)
  iup_utils.set_label(ctrl_table,language_table,format)
end

function iup_utils.add_items_to_list(list,item_array)
  for index,value in ipairs(item_array)
  do
    list.appenditem=value
  end
end

return iup_utils
