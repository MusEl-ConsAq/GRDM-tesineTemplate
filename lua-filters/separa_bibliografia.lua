-- separa_bibliografia.lua
-- Divide tutte le voci in tre sezioni finali secondo il campo 'type'

local utils = require 'pandoc.utils'
local citeproc = utils.citeproc
local stringify = utils.stringify
local List = require 'pandoc.List'

-- deepcopy semplice
local function deepcopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local copy = {}
  for k, v in pairs(tbl) do
    copy[k] = deepcopy(v)
  end
  return copy
end

-- Mappa type -> titolo e id del div
local sections_map = {
  bib = {title = "BIBLIOGRAFIA", id = "refs-bibl"},
  web = {title = "SITOGRAFIA", id = "refs-sito"},
  disc = {title = "DISCOGRAFIA", id = "refs-disc"}
}

function Pandoc(doc)
  -- Prendi tutte le references
  local all_refs = utils.references(doc)
  if not all_refs or #all_refs == 0 then return doc end

  -- Dividi le references per type
  local sections = {bib = {}, web = {}, disc = {}}
  for _, ref in ipairs(all_refs) do
    local t = ref.type and tostring(ref.type):lower() or "bib"
    if sections[t] then
      table.insert(sections[t], ref)
    end
  end

  -- Genera div per ogni sezione
  for t, data in pairs(sections_map) do
    local refs = sections[t]
    if #refs > 0 then
      -- Rendi id unici per evitare warning LaTeX
      local tmp_refs = {}
      for _, r in ipairs(refs) do
        local copy = deepcopy(r)
        copy.id = data.id .. "-" .. copy.id
        table.insert(tmp_refs, copy)
      end

      -- Crea Pandoc temporaneo con nocite per tutte le voci filtrate
      local tmp_doc = pandoc.Pandoc({}, {
        references = List(tmp_refs),
        nocite = pandoc.Inlines{
          pandoc.Cite('@*', {pandoc.Citation('*', 'NormalCitation')})
        }
      })

      local blocks = citeproc(tmp_doc).blocks

      -- Inserisci titolo e div
      table.insert(doc.blocks, pandoc.Header(1, data.title))
      table.insert(doc.blocks, pandoc.Div(blocks, {id = data.id, class = "references"}))
    end
  end

  return doc
end
