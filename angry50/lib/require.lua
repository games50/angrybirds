--[[
https://github.com/kikito/fay/blob/master/src/lib/require.lua
]]

local oldRequire = require

require = {}

setmetatable(require, {__call = function(_,path) return oldRequire(path) end})

-- require.tree private functions
--
local lfs   = love.filesystem
local cache = {}

local function toFSPath(requirePath) return requirePath:gsub("%.", "/") end
local function toRequirePath(fsPath) return fsPath:gsub('/','.') end
local function noExtension(path)     return path:gsub('%.lua$', '') end
local function noEndDot(str)         return str:gsub('%.$', '') end

function require.tree(requirePath)
  if not cache[requirePath] then
    local result = {}

    local fsPath = toFSPath(requirePath)
    local entries = lfs.getDirectoryItems(fsPath)

    for _,entry in ipairs(entries) do
      fsPath = toFSPath(requirePath .. '.' .. entry)
      if lfs.isDirectory(fsPath) then
        result[entry] = require.tree(toRequirePath(fsPath))
      elseif string.sub(entry, 1, 1) == '.' then
        -- skip dotfiles
      else
        entry = noExtension(entry)
        result[entry] = require(toRequirePath(requirePath .. '/' .. entry))
      end
    end

    cache[requirePath] = result
  end

  return cache[requirePath]
end

function require.path(filePath)
  return noEndDot(noExtension(filePath):match("(.-)[^%.]*$"))
end

function require.relative(...)
  local args = {...}
  local first, last = args[1], args[#args]
  local path = require.path(first)
  return require(path .. '.' .. last)
end
