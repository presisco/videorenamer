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
local media_info_api={}

local media_info_cmd_path="MediaInfo.exe"
local cmd_get_all_info=media_info_cmd_path.." \"#PATH\""
local cmd_have_video_stream=media_info_cmd_path.." --Output=\"General;%VideoCount%\" \"#PATH\""
local media_info_sectors="General;Video;Audio;Text;Other;Image;Menu;Max"
local resolution_align_percentage=0.1
local standard_resolution_width={3840,1920,1280,853}
local standard_resolution_height={2160,1080,720,480}
local display_ratio_align_percentage=0.05
local standard_display_ratio=16/9

local function match_standard_resolution_height(height)
  for index=1,#standard_resolution_height
  do
    local diff=standard_resolution_height[index]-height
    if (math.abs(diff/height) < resolution_align_percentage)
    then
      return index
    end
  end
  return nil
end

local function match_standard_resolution_width(width)
  for index=1,#standard_resolution_width
  do
    local diff=standard_resolution_width[index]-width
    if (math.abs(diff/width) < resolution_align_percentage)
    then
      return index
    end
  end
  return nil
end

function media_info_api.set_media_info_path(filepath)
  media_info_cmd_path=filepath
end

function media_info_api.is_video_file(filepath)
  local result=io.popen(cmd_have_video_stream:gsub("#PATH",filepath),"r")

  for line in result:lines()
  do
    --print("media_info_api: raw line: "..line)
    if line:match("%d") ~= nil
    then
      return true
    end
  end

  return false
end

function media_info_api.get_file_info(filepath)
--print("media_info_api: get info from file: "..filepath.."\n")

  local info_table={}
  
--print("media_info_api: final cmd: "..cmd_get_all_info:gsub("#PATH",filepath))
  
  local result=io.popen(cmd_get_all_info:gsub("#PATH",filepath),"r")
  
  local current_sector_id=nil
  local current_sector=nil
  local current_key=nil
  for line in result:lines()
  do
--    print("media_info_api: raw input line: "..line)
    local mid_index = line:find(":")
    if mid_index == nil and line ~= ""
    then
      local sector_id=line:match("#(%d*)")
      if sector_id == nil
      then
        current_sector=line
        info_table[current_sector]={}
        current_sector_id=1
        info_table[current_sector][current_sector_id]={}
      else
        current_sector=line:match("(.-) ")
        if info_table[current_sector] == nil
        then
          info_table[current_sector]={}
        end
        current_sector_id=tonumber(sector_id)
        info_table[current_sector][current_sector_id]={}
      end
      --print("media_info_api: picked sector: "..line)
    elseif mid_index ~= nil
    then
      local key=line:match("(.-)%s*:")
      local value=line:match(": (.*)")
      --print("media_info_api: picked key: "..key..", picked value: "..value)
      local current_key=key
      info_table[current_sector][current_sector_id][current_key]=value
    elseif line ~= ""
    then
      --print("media_info_api: picked multi-line value: "..line.." for key: "..current_key)
      info_table[current_sector][current_sector_id][current_key]=info_table[current_sector][current_sector_id][current_key]..line
    end
  end
  
  return info_table
end

function media_info_api.get_resolution_code(video_stream_info)
  local result=""
  
  local raw_height_string=video_stream_info.Height:match("(.*)pixels")
  raw_height_string=raw_height_string:gsub(" ","")
  
  local raw_width_string=video_stream_info.Width:match("(.*)pixels")
  raw_width_string=raw_width_string:gsub(" ","")
  
  local raw_height=tonumber(raw_height_string)
  local raw_width=tonumber(raw_width_string)
  
  local aspect_radio=raw_width/raw_height
  
  local aligned_height=0
  if aspect_radio > (standard_display_ratio*(1+display_ratio_align_percentage))
  then
    local standard_index=match_standard_resolution_width(raw_width)
    if standard_index == nil
    then
      aligned_height=raw_height
    else
      aligned_height=standard_resolution_height[standard_index]
    end
  else
    local standard_index=match_standard_resolution_height(raw_height)
    if standard_index == nil
    then
      aligned_height=raw_height
    else
      aligned_height=standard_resolution_height[standard_index]
    end
  end
  
  if video_stream_info["Scan type"]=="Interlaced"
  then
    result=aligned_height.."i"
  else
    result=aligned_height.."p"
  end
  
  return result
end

function media_info_api.get_video_format_code(video_stream_info)
  local format_code_map={
    ["AVC"]="H264",
    ["HEVC"]="H265",
    ["MPEG-4 Visual"]="MPEG4"
  }
  
  if format_code_map[video_stream_info.Format] ~= nil
  then
    return format_code_map[video_stream_info.Format]
  else
    return video_stream_info.Format
  end 
end

function media_info_api.get_video_codec_code(video_stream_info)
  
end

function media_info_api.get_audio_format_code(audio_stream_info)
  local result=audio_stream_info.Format

  local format_code_map={
    ["AAC"]="AAC",
    ["AC-3"]="DD",
    ["MPEG Audio"]="MP3",
    ["FLAC"]="FLAC",
    ["DTS"]="DTS"
  }
  
  local channel_code_map={
    ["1 channels"]="1.0",
    ["2 channels"]="2.0",
    ["3 channels"]="2.1",
    ["6 channels"]="5.1",
    ["8 channels"]="7.1"
  }
  
  if format_code_map[audio_stream_info.Format] ~= nil
  then
    result=format_code_map[audio_stream_info.Format]
  end
  
  if channel_code_map[audio_stream_info["Channel(s)"]] ~= nil
  then
    result=result..channel_code_map[audio_stream_info["Channel(s)"]]
  end
  
  return result
end

function media_info_api.get_audio_codec_code(audio_stream_info)
  
end

return media_info_api