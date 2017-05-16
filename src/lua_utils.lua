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

local lua_utils={}

local log_output="console"
local log_file="info.log"
local log_type_wrap={
  ["unknown"]={"?","?"},
  ["string"]={"\"","\""},
  ["number"]={"(",")"},
  ["boolean"]={"[","]"},
  ["table"]={"{","}"}
}
local log_depth_blank="\t"
local log_kv_seperator="="

function lua_utils.text2bool(text)
  if text == "true"
  then
    return true
  else
    return false
  end
end

function lua_utils.bool2text(bool)
  if bool
  then
    return "true"
  else
    return "false"
  end
end

function lua_utils.log_console(data)
  if type(data) == "string"
  then
    print(data)
  elseif type(data) == "table"
  then
    
  elseif type(data) == "boolean"
  then
    print(lua_utils.bool2text(data))
  else
    
  end
end

function lua_utils.log(data)
  if log_output == "console"
  then
    lua_utils.log_console(data)
  else
    
  end
end

function lua_utils.log_table(content_table)
  if type(content_table) ~= "table"
  then
    print("utils.log_table():".."wrong input type:"..type(content_table))
    return
  end
  print(log_type_wrap["table"][1])
  lua_utils.print_table_itr(print,1,content_table)
  print(log_type_wrap["table"][2])
end

function lua_utils.print_table_itr(output,depth,table)
  kv_sp=log_kv_seperator
  t_wrap=log_type_wrap
  bool2text=lua_utils.bool2text
  get_blanks=function(depth)
    return log_depth_blank:rep(depth)
  end
  for k,v in pairs(table)
  do
    local value_type=type(v)
    local key_type=type(k)
    local key=nil

    if key_type=="boolean"
    then
      key=bool2text(k)
    else
      key=k
    end

    if value_type == "table"
    then
      output(get_blanks(depth)..t_wrap[key_type][1]..key..t_wrap[key_type][2]
        ..kv_sp..t_wrap[value_type][1].."\n")
      lua_utils.print_table_itr(output,depth+1,v)
      output(get_blanks(depth)..t_wrap[value_type][2].."\n")
    else
      local value=nil
      if value_type == "boolean"
      then
        value=bool2text(v)
      elseif value_type == "string"
      then
        value=v:gsub("\n"," ")
        value=value:gsub("\r"," ")
      else
        value=v
      end

      output(get_blanks(depth)..t_wrap[key_type][1]..key..t_wrap[key_type][2]
        ..kv_sp..t_wrap[value_type][1]..value..t_wrap[value_type][2].."\n")
    end
  end
end

function lua_utils.logline(data)
  lua_utils.log(data.."\n")
end

function lua_utils.clear_list(list)
  local index=#list
  
  while index > 0
  do
    table.remove(list,index)
    index=index-1
  end
  
end

function lua_utils.table_merge(dst_table,src_table)
  for key,value in pairs(src_table)
  do
    dst_table[key]=value
  end
end

function lua_utils.array_merge(dst_array,src_array)
  for key,value in ipairs(src_array)
  do
    table.insert(dst_array,value)
  end
end

function lua_utils.clear_table(data_table)
  for key,value in pairs(data_table)
  do
    data_table[key]=nil
  end
end

function lua_utils.log_list(head,list)
  print(head..table.concat(list,","))
end

function lua_utils.get_table_keys(src_table)
  local keys={}
  
  for key,value in pairs(src_table)
  do
    table.insert(keys,key)
  end
  
  return keys
end

function lua_utils.get_table_size(src_table)
  local size=0
  for key,value in pairs(src_table)
  do
    size=size+1
  end
  return size
end

function lua_utils.get_first_table_key(src_table)
  for key,value in pairs(src_table)
  do
    return key
  end
end

function lua_utils.table_contains(src_table,target)
  for key,value in pairs(src_table)
  do
    if value == target
    then
      return true
    end
  end
  return false
end

function lua_utils.get_array_item_index(src_array,item)
  for index,value in pairs(src_array)
  do
    if value == item
    then
      return index
    end
  end
  return nil
end

return lua_utils