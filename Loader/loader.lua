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
local DefaultBaseExternalFontPath = 'assets/fonts/'
local DefaultBaseImagePath = 'assets/img/'
local DefaultBaseAudioPath = 'assets/audio/'

local DefaultBaseAudioFormats = {'.ogg', '.wav', '.mp3'}
local DefaultBaseImgFormats = {'.png', '.jpg', '.bmp'}
local DefaultBaseFontSize = 12

-- Private helpers
local checkDirExistence = function(path) 
  path = path:match('/$') and path or path..'/'
  assert(love.filesystem.isDirectory(path),'Folder not found!')
  return path
end

local function getFilePath(fileName,basePath,validFormats)
  local filePath
  for _,ext in ipairs(validFormats) do
    filePath = basePath .. fileName.. ext
    if love.filesystem.isFile(filePath) then return filePath end
  end
end

local function getFolderTree(baseFolder)
  local tree = {__folder = baseFolder}
  for i,v in ipairs(love.filesystem.getDirectoryItems(baseFolder)) do
    if love.filesystem.isDirectory(baseFolder..v) then
      tree[v] = getFolderTree(baseFolder..v..'/')
    end
  end
  return tree
end

local baseImgMetatable = {__index = function(t,k)
  local file = getFilePath(k,t.__folder,DefaultBaseImgFormats)
  t[k] = love.graphics.newImage(file)
  return t[k]
end}

local baseFontMetatable = {__index = function(self,k)
    self[k] = love.graphics.newFont(k)
    return self[k]
  end,
  __call = function(self,k) 
    k = k or DefaultBaseFontSize 
    return self[k] 
  end}
    
local baseExtFontMetatable = {__index = function(self,k)
    self[k] = love.graphics.newFont(DefaultBaseExternalFontPath .. self.__fontFile)
    return self[k]
  end,
  __call = function(self,k)
    k = k or DefaultBaseFontSize
    return self[k] 
end}

local baseAudioStaticMetatable = {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,DefaultBaseAudioPath,DefaultBaseAudioFormats),'static')
    return self[k]
  end,
  __call = function(self,k) 
    return self[k] 
end}
 
local baseAudioStreamMetatable = {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,DefaultBaseAudioPath,DefaultBaseAudioFormats),'stream')
    return self[k]
  end,
  __call = function(self,k) 
    return self[k] 
end}     

function setImgMeta(t)
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
loader.setBaseFontDir = function(path)
  dirPath = checkDirExistence(path)
  DefaultBaseExternalFontPath = dirPath or DefaultBaseExternalFontPath
end

loader.setBaseImageDir = function(path)
  dirPath = checkDirExistence(path)
  DefaultBaseImagePath = dirPath or DefaultBaseImagePath
end

loader.setBaseAudioDir = function(path)
  dirPath = checkDirExistence(path)
  DefaultBaseAudioPath = dirPath or DefaultBaseAudioPath
end

loader.setBaseFontSize = function(number)
  assert(tonumber(number) and number > 1 and floor(number)==number,
    ('Wrong argument type. Positive integer expected, got %s'):format(type(number)))
  DefaultBaseFontSize = number
end

-- Base Getters
loader.getBaseFontDir = function() return DefaultBaseExternalFontPath end
loader.getBaseImageDir = function() return DefaultBaseImagePath end
loader.getBaseAudioDir = function() return DefaultBaseAudioPath end
loader.getBaseFontSize = function() return DefaultBaseFontSize end

function loader.init()  
  -- Access to Love's default font (Vera.ttf)
  if love._modules.graphics then
    loader.Font = {}
    loader.Font = setmetatable({}, baseFontMetatable)
  
    -- Custom *.ttf font loading 
    loader.extFont = {}
    foreach(love.filesystem.getDirectoryItems(DefaultBaseExternalFontPath), function(_,font)
    local f = font:match('(.+)%.ttf$')
      if f then
        loader.extFont[f] = setmetatable({__fontFile = font},baseExtFontMetatable)
      end    
    end)
  end
  -- Image loading
  if love._modules.graphics and love._modules.image then
    loader.Image = {}
    loader.Image = recurseSetImgMeta(getFolderTree(DefaultBaseImagePath))
  end
  -- Load static audio sources
  if love._modules.audio and love._modules.sound then
    loader.Audio = {}
    loader.Audio.Static = setmetatable({}, baseAudioStaticMetatable)

    -- Load streaming audio sources
    loader.Audio.Stream = setmetatable({}, baseAudioStreamMetatable)
  end
end

return loader