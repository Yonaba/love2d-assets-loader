-- Copyright (c) 2012 Roland Yonaba
--[[
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- Checks for Love2D namespace
assert(love, 'Love 2D framework is required')

-- loader version
local _VERSION = "0.2.2"

-- Internalization
local foreach = table.foreach
local setmetatable, require, assert = setmetatable, require, assert
local floor = math.floor

-- Base config
local base_font_path = 'assets/fonts/'
local base_image_path = 'assets/img/'
local base_audio_path = 'assets/audio/'

local base_audio_formats = {'.ogg', '.wav', '.mp3'}
local base_image_formats = {'.png', '.jpg', '.bmp'}
local base_font_size = 12

-- Private helpers
local checkDirExistence = function(path) 
  path = path:match('/$') and path or path..'/'
  assert(love.filesystem.getInfo(path, 'directory'),'Folder not found!')
  return path
end

local function getFilePath(fileName,basePath,validFormats)
  local filePath
  for _,ext in ipairs(validFormats) do
    filePath = basePath .. fileName.. ext
    if love.filesystem.getInfo(filePath, 'file') then return filePath end
  end
end

local function getFolderTree(baseFolder)
  local tree = {__folder = baseFolder}
  for i,v in ipairs(love.filesystem.getDirectoryItems(baseFolder)) do
    if love.filesystem.getInfo(baseFolder..v, 'directory') then
      tree[v] = getFolderTree(baseFolder..v..'/')
    end
  end
  return tree
end

local baseImgMetatable = {__index = function(t,k)
  local file = getFilePath(k,t.__folder,base_image_formats)
  t[k] = love.graphics.newImage(file)
  return t[k]
end}

local baseFontMetatable = {__index = function(self,k)
    self[k] = love.graphics.newFont(k)
    return self[k]
  end,
  __call = function(self,k) 
    k = k or base_font_size 
    return self[k] 
  end}

local baseExtFontMetatable = {__index = function(self,k)
    self[k] = love.graphics.newFont(base_font_path .. self.__fontFile)
    return self[k]
  end,
  __call = function(self,k)
    k = k or base_font_size
    return self[k]
end}

local baseAudioStaticMetatable = {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,base_audio_path,base_audio_formats),'static')
    return self[k]
  end,
  __call = function(self,k) 
    return self[k]
end}

local baseAudioStreamMetatable = {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,base_audio_path,base_audio_formats),'stream')
    return self[k]
  end,
  __call = function(self,k) 
    return self[k]
end}

local function setImgMeta(t)
  return setmetatable(t,baseImgMetatable)
end

local function recurseSetImgMeta(base)
  for _,v in pairs(base) do
    if type(v)=='table' then v = recurseSetImgMeta(v) end
  end
  return setImgMeta(base)
end

-- Loader
local loader = {}

-- Base Setters
loader.set_base_font_dir = function(path)
  local dirPath = checkDirExistence(path)
  base_font_path = dirPath or base_font_path
end

loader.set_base_image_dir = function(path)
  local dirPath = checkDirExistence(path)
  base_image_path = dirPath or base_image_path
end

loader.set_base_audio_dir = function(path)
  local dirPath = checkDirExistence(path)
  base_audio_path = dirPath or base_audio_path
end

loader.set_base_font_size = function(number)
  assert(tonumber(number) and number > 1 and floor(number)==number,
    ('Wrong argument type. Positive integer expected, got %s'):format(type(number)))
  base_font_size = number
end

-- Base Getters
loader.get_base_font_dir = function() return base_font_path end
loader.get_base_image_dir = function() return base_image_path end
loader.get_base_audio_dir = function() return base_audio_path end
loader.get_base_font_size = function() return base_font_size end

function loader.init()  
  if love._modules.graphics then
    -- Custom *.ttf font loading and Love's default font (Vera.ttf)
    loader.font = {}
    foreach(love.filesystem.getDirectoryItems(base_font_path), function(_,font)
    local f = font:match('(.+)%.ttf$')
      if f then
        loader.font[f] = setmetatable({__fontFile = font},baseExtFontMetatable)
      end
    end)
    loader.font.default = setmetatable({}, baseFontMetatable)
  end
  -- Image loading
  if love._modules.graphics and love._modules.image then
    loader.image = {}
    loader.image = recurseSetImgMeta(getFolderTree(base_image_path))
  end
  -- Load static audio sources
  if love._modules.audio and love._modules.sound then
    loader.audio = {}
    loader.audio.static = setmetatable({}, baseAudioStaticMetatable)

    -- Load streaming audio sources
    loader.audio.stream = setmetatable({}, baseAudioStreamMetatable)
  end
end

return loader
