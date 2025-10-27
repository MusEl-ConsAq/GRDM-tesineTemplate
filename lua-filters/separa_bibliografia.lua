-- multi-bib.lua

-- La funzione principale che viene eseguita sull'intero documento Pandoc (AST).
function Pandoc (doc)
  -- Controlla se esistono metadati della bibliografia. Se no, non fare nulla.
  if not doc.meta.bibliography then
    return doc
  end

  -- Tavole per separare le referenze in base al loro tipo.
  local bib_items = {}
  local web_items = {}
  local disc_items = {}

  -- Scorre tutte le referenze caricate da Pandoc.
  -- Grazie a `nocite: '@*'`, qui ci saranno TUTTE le referenze del file .bib.
  for _, ref in ipairs(doc.meta.bibliography) do
    -- Controlla il campo 'type' di ogni referenza.
    -- ref.type è una stringa semplice se il valore nel .bib è {web}.
    if ref.type == 'bib' then
      table.insert(bib_items, ref)
    elseif ref.type == 'web' then
      table.insert(web_items, ref)
    elseif ref.type == 'disc' then
      table.insert(disc_items, ref)
    end
  end

  -- Adesso abbiamo tre liste popolate. Procediamo a generare le sezioni.
  -- Creeremo una lista di nuovi blocchi da aggiungere alla fine del documento.
  local new_blocks = {}

  -- 1. Sezione BIBLIOGRAFIA
  if #bib_items > 0 then
    -- Aggiunge l'intestazione
    table.insert(new_blocks, pandoc.Header(1, "BIBLIOGRAFIA"))
    -- Usa pandoc.utils.citeproc per formattare SOLO le referenze di tipo 'bib'
    -- Il risultato è una lista di blocchi (di solito un Div con le referenze)
    local formatted_bib = pandoc.utils.citeproc(bib_items, doc.meta)
    for _, block in ipairs(formatted_bib) do
      table.insert(new_blocks, block)
    end
  end

  -- 2. Sezione SITOGRAFIA
  if #web_items > 0 then
    table.insert(new_blocks, pandoc.Header(1, "SITOGRAFIA"))
    local formatted_web = pandoc.utils.citeproc(web_items, doc.meta)
    for _, block in ipairs(formatted_web) do
      table.insert(new_blocks, block)
    end
  end

  -- 3. Sezione DISCOGRAFIA
  if #disc_items > 0 then
    table.insert(new_blocks, pandoc.Header(1, "DISCOGRAFIA"))
    local formatted_disc = pandoc.utils.citeproc(disc_items, doc.meta)
    for _, block in ipairs(formatted_disc) do
      table.insert(new_blocks, block)
    end
  end

  -- Aggiunge tutti i nuovi blocchi generati (intestazioni + referenze)
  -- alla fine del corpo del documento.
  for _, block in ipairs(new_blocks) do
    table.insert(doc.blocks, block)
  end

  -- Ritorna il documento modificato.
  return doc
end
