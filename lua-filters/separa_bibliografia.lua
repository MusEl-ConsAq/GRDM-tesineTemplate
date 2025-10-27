-- File: lua-filters/separa_bibliografia.lua (versione con debug)

function Pandoc (doc)
  -- Tavola per raccogliere i messaggi di debug
  local debug_messages = {}

  -- Aggiunge un messaggio alla tavola di debug
  local function log(msg)
    table.insert(debug_messages, msg)
  end

  log("--- FILTRO LUA DI DEBUG AVVIATO ---")

  -- 1. Controlliamo se i metadati della bibliografia sono stati caricati
  if not doc.meta.bibliography then
    log("ERRORE CRITICO: I metadati 'bibliography' non sono stati trovati.")
    log("Possibili cause:")
    log("  - Il front matter YAML non è stato letto (il file di input era sbagliato?).")
    log("  - Il percorso del file .bib nel campo 'bibliography' è errato.")
  else
    local ref_count = #doc.meta.bibliography
    log("SUCCESSO: Metadati 'bibliography' trovati.")
    log("Numero totale di referenze caricate da Pandoc: " .. ref_count)

    if ref_count == 0 then
      log("ATTENZIONE: 0 referenze caricate. Il file .bib è vuoto o illeggibile?")
    end

    -- Liste per separare le referenze
    local bib_items = {}
    local web_items = {}
    local disc_items = {}

    -- 2. Analizziamo ogni referenza individualmente
    log("\n--- ANALISI DELLE SINGOLE REFERENZE ---")
    for i, ref in ipairs(doc.meta.bibliography) do
      -- Usiamo tostring() per evitare errori se 'type' fosse nil
      local ref_type = tostring(ref.type)
      log("  - Ref #" .. i .. ": id='" .. ref.id .. "', type='" .. ref_type .. "'")
      
      -- Logica di smistamento
      if ref.type == 'bib' then
        table.insert(bib_items, ref)
      elseif ref.type == 'web' then
        table.insert(web_items, ref)
      elseif ref.type == 'disc' then
        table.insert(disc_items, ref)
      end
    end

    -- 3. Controlliamo il risultato dello smistamento
    log("\n--- RISULTATO DELLO SMISTAMENTO ---")
    log("Voci in BIBLIOGRAFIA: " .. #bib_items)
    log("Voci in SITOGRAFIA:   " .. #web_items)
    log("Voci in DISCOGRAFIA:  " .. #disc_items)
    log("-------------------------------------")

    -- Logica originale per aggiungere le sezioni
    local new_blocks = {}
    if #bib_items > 0 then
      table.insert(new_blocks, pandoc.Header(1, "BIBLIOGRAFIA"))
      local formatted_bib = pandoc.utils.citeproc(bib_items, doc.meta)
      for _, block in ipairs(formatted_bib) do table.insert(new_blocks, block) end
    end
    if #web_items > 0 then
      table.insert(new_blocks, pandoc.Header(1, "SITOGRAFIA"))
      local formatted_web = pandoc.utils.citeproc(web_items, doc.meta)
      for _, block in ipairs(formatted_web) do table.insert(new_blocks, block) end
    end
    if #disc_items > 0 then
      table.insert(new_blocks, pandoc.Header(1, "DISCOGRAFIA"))
      local formatted_disc = pandoc.utils.citeproc(disc_items, doc.meta)
      for _, block in ipairs(formatted_disc) do table.insert(new_blocks, block) end
    end
    
    -- Aggiunta dei blocchi al documento
    for _, block in ipairs(new_blocks) do
      table.insert(doc.blocks, block)
    end
  end

  -- 4. Creiamo il blocco di debug e lo inseriamo all'inizio del PDF
  -- Uniamo tutti i messaggi in una singola stringa
  local debug_output_string = table.concat(debug_messages, "\n")
  -- Creiamo un blocco di codice Pandoc
  local debug_block = pandoc.CodeBlock(debug_output_string)
  -- Lo inseriamo come primissimo elemento del documento
  table.insert(doc.blocks, 1, debug_block)
  
  log("\n--- DEBUG COMPLETATO ---")
  
  -- Restituisce il documento modificato
  return doc
end
