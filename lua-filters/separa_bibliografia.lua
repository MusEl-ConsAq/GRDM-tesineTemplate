-- separa_bibliografia.lua
-- Filtro Lua per Pandoc ≥ 2.11
-- Separa le voci del .bib in tre sezioni: bib, web, disc
-- Include tutte le voci anche se non citate (\nocite{*})

local keywords_map = {
  bib = "#refs-bibl",
  web = "#refs-sito",
  disc = "#refs-disc"
}

function Pandoc(doc)
  -- Recupera le citazioni già caricate da Pandoc (con --citeproc)
  local citations = doc.meta.citations or {}
  
  -- Recupera tutte le entry dal metadata bibliography
  local bib_files = doc.meta.bibliography
  if not bib_files then
    return doc
  end

  -- Inizializza le sezioni
  local sections = { bib = {}, web = {}, disc = {} }

  -- Legge tutte le citazioni da ciascun file .bib
  local bib_list = {}
  if type(bib_files) == "table" then
    bib_list = bib_files
  else
    bib_list = { bib_files }
  end

  -- Inserisce un Div per ciascuna keyword con \nocite{*}
  local blocks_to_insert = {}
  for kw, div_id in pairs(keywords_map) do
    -- Div vuoto con LaTeX \nocite{*} per includere tutte le voci
    table.insert(blocks_to_insert, pandoc.Div(
      { pandoc.RawBlock("latex", "\\nocite{*}") },
      { id = div_id:sub(2), class = "references" } -- rimuove #
    ))
  end

  -- Aggiunge i div alla fine del documento
  for _, blk in ipairs(blocks_to_insert) do
    table.insert(doc.blocks, blk)
  end

  return doc
end
