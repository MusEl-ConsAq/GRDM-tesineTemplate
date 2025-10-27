-- separa_bibliografia.lua

local keywords_map = {
  bib = "refs-bibl",
  web = "refs-sito",
  disc = "refs-disc"
}

local utils = require 'pandoc.utils'
local citeproc = utils.citeproc
local stringify = utils.stringify
local List = require 'pandoc.List'

-- deepcopy custom
local function deepcopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local copy = {}
  for k, v in pairs(tbl) do
    copy[k] = deepcopy(v)
  end
  return copy
end

function Pandoc(doc)
  local all_refs = utils.references(doc)

  if not all_refs or #all_refs == 0 then
    return doc
  end

  local sections = { bib = {}, web = {}, disc = {} }

  for _, ref in ipairs(all_refs) do
    local kw = "bib"
    if ref.keywords then
      kw = stringify(ref.keywords):lower()
    end
    if sections[kw] then
      table.insert(sections[kw], ref)
    end
  end

  local function make_div(id, refs)
    if #refs == 0 then return nil end

    local tmp_refs = {}
    for _, r in ipairs(refs) do
      local rcopy = deepcopy(r)
      rcopy.id = id .. "-" .. rcopy.id
      table.insert(tmp_refs, rcopy)
    end

    local tmp_doc = pandoc.Pandoc({}, {
      references = List(tmp_refs),
      nocite = pandoc.Inlines{
        pandoc.Cite('@*', {pandoc.Citation('*', 'NormalCitation')})
      }
    })

    local blocks = citeproc(tmp_doc).blocks

    return pandoc.Div(blocks, {id = id, class = "references"})
  end

  for kw, id in pairs(keywords_map) do
    local div = make_div(id, sections[kw])
    if div then
      table.insert(doc.blocks, pandoc.RawBlock('latex', '\n'))
      table.insert(doc.blocks, pandoc.Header(1, kw:upper()))
      table.insert(doc.blocks, div)
    end
  end

  return doc
end
