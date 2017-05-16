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

local video_name_formatter={}

--[[
output_template={
	seq="$(NAME).S$(SEASON)E$(EPISODE).$(TITLE).$(SRC).$(RES).$(TYPE).$(AUDIO).$(VIDEO)-$(TEAM)",
	name="",
	season="",
	episode="",
	title="",
	src="",
	res="1080p",
	type="BDRip",
	audio="DD5.1",
	video="h264",
	team="user"
}
]]

--[[
  input_pattern="<NAME>.S<SEASON>E<EPISODE>.<TITLE>.*p"
]]

local pattern_any_number="<#>"
local match_tag="<.->"
local match_tag_number="<#.->"
local match_tag_optional="<!.-!>"
local match_extract_tag="<(.-)>"
local match_extract_number="(%%d-)"
local match_extract_string="(.-)"
local lua_pattern_string=".-"
local lua_pattern_number="%%d-"
local lua_pattern_predefined="[.%+-()%[%]]"
local filename_symbols="[.%W]"

function video_name_formatter.invalidate_special_symbols(text)
  return text:gsub("("..lua_pattern_predefined..")","%%%1")
end

function video_name_formatter.parse_video_name_optional(filename,input_pattern,has_optional)
  local result={}
  local prepared_pattern=video_name_formatter.invalidate_special_symbols(input_pattern)
  prepared_pattern=prepared_pattern:gsub(pattern_any_number,lua_pattern_number)
  
  if has_optional
  then
    prepared_pattern=prepared_pattern:gsub("<!","")
    prepared_pattern=prepared_pattern:gsub("!>","")
  else
    prepared_pattern=prepared_pattern:gsub(match_tag_optional,"")
  end

  local succeed=false
  for tag in prepared_pattern:gmatch(match_extract_tag)
  do
    local capture_pattern=""
    if tag:match("#") ~= nil
    then
      capture_pattern=prepared_pattern:gsub("<"..tag..">",match_extract_number)
      tag=tag:match("#(.*)")
    else
      capture_pattern=prepared_pattern:gsub("<"..tag..">",match_extract_string)
    end
    capture_pattern=capture_pattern:gsub(match_tag_number,lua_pattern_number)
    capture_pattern=capture_pattern:gsub(match_tag,lua_pattern_string)
    local value=filename:match(capture_pattern)
    if value ~= nil
    then
      result[tag:lower()]=value
      succeed=true
    end
  end
  
  if succeed or has_optional
  then
    return result
  else
    return video_name_formatter.parse_video_name_optional(filename,input_pattern,true)
  end
end

function video_name_formatter.parse_video_name(filename,input_pattern)
  return video_name_formatter.parse_video_name_optional(filename,input_pattern,false)
end

--[[
  params={name="",year="",type="",..}
]]
function video_name_formatter.generate_video_name(template,params)

  for tag in template:gmatch(match_extract_tag)
  do
    template=template:gsub("<"..tag..">","<"..tag:lower()..">")
  end
  
  local replace_tag=function(tag_name,content)
    template=template:gsub("<"..tag_name..">",content)
  end
  
  for tag,value in pairs(params)
  do
    replace_tag(tag,value)
  end
  
  template=template:gsub(match_tag,"")
  
  local start_index,end_index=template:find(filename_symbols.."+",1)
  while start_index ~= nil
  do
    local invalidated=video_name_formatter.invalidate_special_symbols(template:sub(start_index,end_index))
    template=template:gsub(invalidated,template:sub(end_index,end_index))
    start_index,end_index=template:find(filename_symbols.."+",end_index+1)
  end
  
  local last_char=template:sub(-1)
  
  if last_char:match("("..filename_symbols..")") ~= nil
  then
    template=template:sub(1,-2)
  end
  
  return template
end

return video_name_formatter
