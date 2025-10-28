-- debug_references.lua
-- Stampa le references nel documento per debug

function Pandoc(doc)
  -- ottieni tutte le references citate o tramite nocite
  local refs = pandoc.utils.references(doc)

  -- genera un blocco Markdown per visualizzare le references
  local blocks = {}

  table.insert(blocks, pandoc.Header(1, "DEBUG REFERENCES"))

  for i, ref in ipairs(refs) do
    -- ref è una tabella CSL JSON, usiamo stringify per convertire in testo semplice
    local text = pandoc.Str(ref.id .. ": " .. (ref.title or "(nessun titolo)"))
    table.insert(blocks, pandoc.Para{text})
  end

  -- aggiungiamo i blocchi generati all'inizio del documento
  doc.blocks = pandoc.List(blocks) .. doc.blocks

  return doc
end
