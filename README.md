# love2d-assets-loader

__love2d-assets-loader__ is a library for assets loading on demand.  It works
with [Löve2D](http://love2d.org) framework (compatible with Löve __0.8.0__).
The aim of this utility is to simplify in-game assets (fonts, audio, images)
loading and management.

__love2d-assets-loader__ have been highy inspired by
[Vrld](https://github.com/vrld/)'s
[Proxy](https://github.com/vrld/Princess/blob/master/main.lua) function.

##Features

* Loads required assets __on demand__.

* __Automatic resources caching__ : when an asset is called for the first time,
  it is loaded and stored within the loader. Next calls will return the stored
  value.

* Grants access to Löve's default [font](https://love2d.org/wiki/Font)
  (__Vera.ttf__)

* Loads external [True Type](https://en.wikipedia.org/wiki/TrueType) (__.ttf__)
  [fonts](https://love2d.org/wiki/Font) with custom size

* Loads [.wav](https://en.wikipedia.org/wiki/WAV),
  [.ogg](http://en.wikipedia.org/wiki/Ogg) and
  [.mp3](http://en.wikipedia.org/wiki/MP3) audio formats as [static or
  streaming](https://love2d.org/wiki/SourceType)
  [sources](https://love2d.org/wiki/Source).

* Loads [.png](http://en.wikipedia.org/wiki/PNG),
  [.jpg](https://en.wikipedia.org/wiki/JPEG) and
  [.bmp](http://en.wikipedia.org/wiki/BMP_file_format)
  [images](https://love2d.org/wiki/Image)

## Installation

- Put the file
  [loader.lua](https://github.com/Yonaba/love2d-assets-loader/blob/master/loader.lua)
  inside your project folder.

- Call it using the __require__ function.

- It will return a reference to the public interface as a regular Lua table.

## Usage

__love2d-assets-loader__ is very simple to use.  Say that your project folder
is organized this way:

```
.
├── audio
├── fonts
└── img
```

You will have to specify the paths to your __Audio__, __Font__ and __Image__
assets to the loader, and then __initialize__ it.  This should be done inside
`love.load` callback.

```lua
function love.load()  
  loader = require 'loader'
  loader.setBaseImageDir('img')
  loader.setBaseAudioDir('audio')
  loader.setBaseFontDir('fonts')
  loader.init() -- Do not forget this!
end  
```

And that's it!

## Loading Fonts

### Loading Löve default font

Löve default font can be accessed via `loader.Font`

```lua
function love.draw()
  love.graphics.setFont(loader.Font[15]) -- Love default with size 15
  love.graphics.setFont(loader.Font(15)) -- Same as before
  
  love.graphics.setFont(loader.Font[18]) -- Love default with size 18
  love.graphics.setFont(loader.Font(18)) -- Same as before
  
  love.graphics.setFont(loader.Font()) -- Whith no arg, will use a customisable default font size
end
```

### Loading custom True-Type fonts

Löve custom fonts can be accessed via `loader.extFont`

```lua
function love.draw()
  -- Assuming you have a font named Arial.ttf inside your base font folder.
  love.graphics.setFont(loader.extFont.Arial[15]) -- Arial font size 15
  love.graphics.setFont(loader.extFont.Arial(15)) -- Same as before
  
  love.graphics.setFont(loader.extFont.Arial[18]) -- Arial font size 18
  love.graphics.setFont(loader.extFont.Arial(18)) -- Same as before
  
  love.graphics.setFont(loader.extFont.Arial()) -- Whith no arg, will use a customisable default font size
end
```

## Loading Audio

Audio files (.ogg, .wav and .mp3) can be loaded via `loader.Audio.Stream`
(streaming playback) or `loader.Audio.Static` (static playback).

```lua
  -- Assuming you have an audio file name 'Love.ogg' in your base audio folder
  love.audio.play(loader.Audio.Stream.Love) -- Will be streamed
  love.audio.play(loader.Audio.Static.Love) -- will be decoded before playback
  
  -- Assuming you have an audio file name 'tick.wav' in your base audio folder
  love.audio.play(loader.Audio.Stream.tick) -- Will be streamed
  love.audio.play(loader.Audio.Static.tick) -- will be decoded before playback

  -- Assuming you have an audio file name 'stream.mp3' in your base audio folder
  love.audio.play(loader.Audio.Stream.stream) -- Will be streamed
  love.audio.play(loader.Audio.Static.stream) -- will be decoded before playback
```

## Loading Images

Images files (.png and .jpg) can be loaded via `loader.Image`

```lua
function love.draw()
  -- Assuming you have a 'player.png' or 'player.jpg' file in your base image folder
  love.graphics.draw(loader.Image.player,0,0)
end
```

A very interesting feature here is that `loader.Image` supports nested folders.
Say that in your base image folder (here, __"img/"__) you have the following tree:

    img/
    --> (folder) Maps/
       --> (file) map1.jpg
       --> (file) map2.jpg
  		 --> (folder) Ground/
			    --> (file) g1.png
			    --> (file) g2.png
    --> (file) player.png 
	
```lua
function love.draw()
  love.graphics.draw(loader.Image.Maps.Ground.g1,0,0) -- draws 'img/Maps/Ground/g1.png'
  love.graphics.draw(loader.Image.Maps.map2,0,0) -- draws 'img/Maps/map2.jpg'
  love.graphics.draw(loader.Image.player,0,0) -- draws 'img/player.png'
end
```

## Public Interface

### Setters

* `loader.setBaseFontDir(dir)`: sets `dir` as the base font folder.
* `loader.setBaseImageDir(dir)`: sets `dir` as the base image folder
* `loader.setBaseAudioDir(dir)`: sets `dir` as the base audio folder
* `loader.setBaseFontSize(integer)`: sets `integer` as the default font size

### Getters

* `loader.getBaseFontDir(dir)`: returns the base font folder.
* `loader.getBaseImageDir(dir)`: returns the base image folder
* `loader.getBaseAudioDir(dir)`: returns the base audio folder
* `loader.getBaseFontSize(integer)`: returns the default font size

### Initialization

* `loader.init()`: Inits the loader. Should be called after using setters.

### Loading routines

* `loader.Font`: access to Löve default font
* `loader.extFont`: access to custom true type fonts
* `loader.Audio.Stream`: loads audio files for streaming playback.
* `loader.Audio.Static`: loads audio files for static playback.
* `loader.Image`: loads images

## Final Notes

__love2d-assets-loader__ checks for `love` namespace before running, to prevent
this lib being used without [Love2D](https://love2d.org).  Also, parts of
__love2d-assets-loader__ are relevant to [Love2D](https://love2d.org)'s
modules.

* `loader.Audio` requires `love.audio` and `love.sound`
* `loader.Image` requires `love.image` and `love.graphics`
* `loader.Font` and `loader.extFont` both require `love.graphics`

Be sure to have these modules activated through your [configuration
file](https://love2d.org/wiki/Config_Files).

## License

This work is released under the terms of
[MIT-LICENSE](http://www.opensource.org/licenses/mit-license.php)

Copyright (c) 2012 Roland Yonaba

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
