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

local file_utils={}

local lfs=require "lfs"
local lu=require "lua_utils"

--[[
  scan files in dir
  return table:
  {{filename="",dir="",extension=""},...}
]]

function file_utils.remove_extension(filename)
  local reversed=filename:reverse()
  local ext_index=reversed:find(".",1,true)
  return filename:sub(1,filename:len()-ext_index)
end

function file_utils.get_extension(filename)
  local reversed=filename:reverse()
  local ext_index=reversed:find(".",1,true)
  return filename:sub(filename:len()-ext_index+1,filename:len())
end

function file_utils.get_files(dir,recursive,validate)
  local file_list={}
  for file in lfs.dir(dir)
    do
      if file ~= "." and file ~= ".."
      then
        local file_attr=lfs.attributes(dir..file)
        
        if file_attr == nil
        then
          lu.logline(dir..file.." is unrecognizable")
          return file_list
        end
        
        if file_attr.mode ~= "directory"
          and validate(dir..file) == true
        then
          local new_file={}
          new_file.filename=file_utils.remove_extension(file)
          new_file.dir=dir
          new_file.extension=file_utils.get_extension(file)
          table.insert(file_list,new_file)
        elseif file_attr.mode == "directory" 
          and recursive == true
        then
          lu.logline("entering dir: "..dir..file)
          lu.table_merge(file_list,file_utils.get_files(dir..file.."\\",recursive,validate))
        end
      end
    end
    return file_list
end

return file_utils