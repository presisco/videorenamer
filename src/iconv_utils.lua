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

local iconv_utils={}

local iconv=require "luaiconv"

local converter=nil
local current_src_code="utf-8"
local target_target_code="utf-8"

function iconv_utils.set_mode(src_code,target_code)
  converter=iconv.new(target_code,src_code)
end

function iconv_utils.convert(text)
  return converter:iconv(text)
end

function iconv_utils.convert_array(string_table,target_code)
  local iconv_converter=iconv.new(target_code,"utf-8")
  for key,value in pairs(string_table)
  do
    string_table[key]=iconv_converter:iconv(value)
  end
end

function iconv_utils.convert_array(string_table,src_code,target_code)
  local iconv_converter=iconv.new(target_code,src_code)
  for key,value in pairs(string_table)
  do
    string_table[key]=iconv_converter:iconv(value)
  end
end

return iconv_utils