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
local _VERSION = "0.1"

-- Internalization
local foreach = table.foreach
local setmetatable, require, assert = setmetatable, require, assert
local floor = math.floor

-- Base config
local DefaultBaseExternalFontPath = 'assets/fonts/'
local DefaultBaseImagePath = 'assets/img/'
local DefaultBaseAudioPath = 'assets/audio/'

local DefaultBaseAudioFormats = {".ogg", ".wav", ".mp3"}
local DefaultBaseImgFormats = {'.png|', '.jpg'}
local DefaultBaseFontSize = 12

-- Private helpers
local checkDirExistence = function(path) 
  path = path:match('/$') and path or path..'/'
  assert(love.filesystem.isDirectory(path),'Folder not found!')
  return path
end

local function getFilePath(fileName,basePath,validFormats)
  local file
  for ext in pairs(validFormats) do
    filePath = basePath .. fileName.. ext
    if love.filesystem.isFile(filePath) then return filePath end
  end
end

local function getFolderTree(baseFolder)
  local tree = {__folder = baseFolder}
  for i,v in ipairs(love.filesystem.enumerate(baseFolder)) do
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


loader.Font = {}
loader.externalFont = {}
loader.Image = {}
loader.staticAudio = {}
loader.streamingAudio = {}

function loader.init()  
  -- Access to Love's default font (Vera.ttf)
  loader.Font = setmetatable({}, {__index = function(self,k)
    assert(type(k) == 'number' and floor(k) == k, ('Wrong argument type. Number expected, got %s'):format(type(k)))
    self[k] = love.graphics.newFont(k)
    return self[k]
    end,
    __call = function(self,k) 
      k = k or DefaultBaseFontSize 
      return self[k] 
  end})
  
  -- Custom *.ttf font loading 
  foreach(love.filesystem.enumerate(DefaultBaseExternalFontPath), function(_,font)
  local f = font:match('(.+)%.ttf$')
    if f then
      loader.externalFont[f] = setmetatable({__name = font},{__index = function(self,k)
      self[k] = love.graphics.newFont(DefaultBaseExternalFontPath .. self.__name)
      return self[k]
      end,
      __call = function(self,k)
        k = k or DefaultBaseFontSize
        return self[k] 
      end})
    end    
  end)
  
  -- Image loading
  loader.Image = recurseSetImgMeta(getFolderTree(DefaultBaseImagePath))
  
  -- Load static audio sources
  loader.staticAudio = setmetatable({}, {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,DefaultBaseAudioPath,DefaultBaseAudioFormats),'static')
    return self[k]
    end,
    __call = function(self,k) 
    return self[k] 
  end})

  -- Load streaming audio sources
  loader.streamingAudio = setmetatable({}, {__index = function(self,k)
    self[k] = love.audio.newSource(getFilePath(k,DefaultBaseAudioPath,DefaultBaseAudioFormats),'stream')
    return self[k]
    end,
    __call = function(self,k) 
      return self[k] 
  end})

end

return loader