-- separa_bibliografia.lua
-- Filtro Lua per Pandoc: separa le voci del .bib in tre sezioni
-- basate su keyword: bib, web, disc
-- Funziona con tutte le voci anche non citate (\nocite{*})

local keywords_map = {
  bib = "#refs-bibl",
  web = "#refs-sito",
  disc = "#refs-disc"
}

function Pandoc(doc)
  -- Verifica se esiste il file .bib
  local bib_file = doc.meta.bibliography
  if not bib_file then
    return doc
  end

  -- Funzione per leggere le voci del .bib usando pandoc-citeproc
  local json_file = os.tmpname()
  os.execute(string.format("pandoc-citeproc --bib2json %s > %s", bib_file, json_file))
  local bib_json = pandoc.read(json_file, 'json').blocks

  -- Inizializza tabelle per ciascuna sezione
  local sections = { bib = {}, web = {}, disc = {} }

  -- Distribuisci le voci in base al campo keyword
  for _, entry in ipairs(bib_json) do
    local kw = entry.keyword or entry.keywords or "bib"
    kw = kw:lower()
    if sections[kw] then
      table.insert(sections[kw], entry)
    end
  end

  -- Genera i div Markdown con \nocite{*} per ciascuna sezione
  local blocks_to_insert = {}
  for kw, div_id in pairs(keywords_map) do
    table.insert(blocks_to_insert, pandoc.Div(
      { pandoc.Para({ pandoc.RawInline("latex", "\\nocite{*}") }) },
      { id = div_id:sub(2), class = "references" }  -- remove # dal div id
    ))
  end

  -- Inserisci i div alla fine del documento
  for _, blk in ipairs(blocks_to_insert) do
    table.insert(doc.blocks, blk)
  end

  return doc
end
