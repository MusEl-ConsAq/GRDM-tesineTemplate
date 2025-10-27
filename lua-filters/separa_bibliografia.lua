-- separa_bibliografia.lua
-- Dividi le voci bibliografiche in tre sezioni finali secondo keyword
-- Compatibile con Pandoc >=2.11, autore-anno

local keywords_map = {
  bib = "refs-bibl",
  web = "refs-sito",
  disc = "refs-disc"
}

local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local citeproc = utils.citeproc
local stringify = utils.stringify

-- Funzione principale
function Pandoc(doc)
  local meta = doc.meta

  -- Prendi tutte le references generate dal motore interno citeproc
  local all_refs = utils.references(doc)

  if not all_refs or #all_refs == 0 then
    return doc
  end

  -- Crea una tabella per ciascuna keyword
  local sections = { bib = {}, web = {}, disc = {} }

  for _, ref in ipairs(all_refs) do
    local kw = (ref.keyword or ref.keywords or "bib"):lower()
    if sections[kw] then
      table.insert(sections[kw], ref)
    end
  end

  -- Funzione per creare un div con \nocite{*} filtrato
  local function make_div(id, refs)
    if #refs == 0 then return nil end
    -- Crea un Pandoc metadata temporaneo
    local tmp_meta = pandoc.Meta()
    tmp_meta.references = refs
    tmp_meta.nocite = pandoc.Inlines{pandoc.Cite('@*', {pandoc.Citation('*', 'NormalCitation')})}

    -- Genera i blocchi tramite citeproc
    local blocks = citeproc(pandoc.Pandoc({}, tmp_meta)).blocks

    -- Avvolgi in un Div con id unico
    return pandoc.Div(blocks, {id = id, class = "references"})
  end

  -- Genera i tre div finali
  for kw, id in pairs(keywords_map) do
    local div = make_div(id, sections[kw])
    if div then
      table.insert(doc.blocks, pandoc.RawBlock('latex', '\n')) -- aggiunge spazio
      table.insert(doc.blocks, pandoc.Header(1, kw:upper()))    -- intestazione
      table.insert(doc.blocks, div)
    end
  end

  return doc
end
