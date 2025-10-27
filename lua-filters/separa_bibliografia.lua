-- separa_bibliografia.lua
-- Divide tutte le voci bibliografiche in tre sezioni finali secondo keyword
-- Compatibile con Pandoc >=2.11, autore-anno

local keywords_map = {
  bib = "refs-bibl",
  web = "refs-sito",
  disc = "refs-disc"
}

local utils = require 'pandoc.utils'
local citeproc = utils.citeproc
local stringify = utils.stringify
local List = require 'pandoc.List'

function Pandoc(doc)
  local all_refs = utils.references(doc)

  if not all_refs or #all_refs == 0 then
    return doc
  end

  -- Crea una tabella per ciascuna keyword
  local sections = { bib = {}, web = {}, disc = {} }

  for _, ref in ipairs(all_refs) do
    local kw = "bib"  -- default
    if ref.keywords then
      kw = stringify(ref.keywords):lower()
    end
    if sections[kw] then
      table.insert(sections[kw], ref)
    end
  end

  -- Funzione per creare un div con tutte le voci filtrate
  local function make_div(id, refs)
    if #refs == 0 then return nil end

    -- Modifica gli id di ogni reference per sezione (evita warning LaTeX)
    local tmp_refs = {}
    for _, r in ipairs(refs) do
      local rcopy = pandoc.utils.deepcopy(r)
      rcopy.id = id .. "-" .. rcopy.id
      table.insert(tmp_refs, rcopy)
    end

    -- Crea un Pandoc temporaneo con nocite per tutte le voci
    local tmp_doc = pandoc.Pandoc({}, {
      references = List(tmp_refs),
      nocite = pandoc.Inlines{
        pandoc.Cite('@*', {pandoc.Citation('*', 'NormalCitation')})
      }
    })

    local blocks = citeproc(tmp_doc).blocks

    return pandoc.Div(blocks, {id = id, class = "references"})
  end

  -- Inserisce i div finali nel documento
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
