#!/usr/bin/env python3
"""
build-tesina.py
Estrae metadati da config.yml, legge il riassunto da un file dedicato,
e concatena i file markdown delle sezioni in un unico README.md.
"""
import yaml
from pathlib import Path

def main():
    # ==========================================
    # 1. LEGGI CONFIG.YML
    # ==========================================
    print("[*] Reading config.yml...")
    with open('config.yml', 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    tesina_data = config.get('tesina', {})

    # ==========================================
    # 2. LEGGI IL RIASSUNTO (ABSTRACT) DA FILE
    # ==========================================
    print("[*] Reading abstract from RIASSUNTO.md...")
    docs_dir = Path("docs/sezioni")
    riassunto_file = docs_dir / "RIASSUNTO.md"
    abstract_content = ""

    if riassunto_file.exists():
        content = riassunto_file.read_text(encoding='utf-8').strip()
        if content:
            abstract_content = content
            print("    [OK] Abstract loaded from file.")
        else:
            abstract_content = "Riassunto ancora non compilato."
            print("    [WARN] RIASSUNTO.md is empty. Using default text.")
    else:
        abstract_content = "File RIASSUNTO.md non trovato."
        print(f"    [WARN] {riassunto_file} not found. Using default text.")

    # ==========================================
    # 3. TROVA E ORDINA I FILE DELLE SEZIONI
    # ==========================================
    print("[*] Finding and sorting markdown section files...")
    if not docs_dir.exists():
        print(f"[ERROR] Directory {docs_dir} not found!")
        return 1
    
    files = sorted([f for f in docs_dir.glob("*.md") if f.name != "RIASSUNTO.md"])
    
    if not files:
        print(f"[WARN] No section .md files found in {docs_dir} (excluding RIASSUNTO.md).")
    
    # =========================================================
    # 3.5. NUOVA SEZIONE: TROVA DINAMICAMENTE I FILE BIBLIOGRAFICI
    # =========================================================
    print("[*] Finding bibliography files in docs/...")
    bib_dir = Path("docs")
    
    # Definisci qui la mappatura tra chiave e nome del file
    bib_mapping = {
        "bib": "bibliografia.bib",
        "sit": "sitografia.bib",
        "dis": "discografia.bib"
    }

    found_bib_files = {} # Un dizionario per contenere i file trovati
    for key, filename in bib_mapping.items():
        file_path = bib_dir / filename
        if file_path.exists():
            # Usiamo il percorso relativo corretto per il frontmatter
            found_bib_files[key] = str(file_path).replace('\\', '/')
            print(f"    [OK] Found: {file_path}")
        else:
            print(f"    [INFO] Skipping (not found): {file_path}")

    # ==========================================
    # 4. CREA README.MD CON FRONTMATTER E CONTENUTI
    # ==========================================
    print("[*] Creating README.md with full frontmatter...")
    with open("README.md", "w", encoding='utf-8') as out:
        # --- Scrivi il frontmatter YAML completo ---
        out.write("---\n")
        
        # Variabili standard di Pandoc
        out.write(f"title: \"{tesina_data.get('titolo', 'Senza Titolo')}\"\n")
        out.write(f"subtitle: \"{tesina_data.get('sottotitolo', '')}\"\n")
        out.write(f"author: \"{tesina_data.get('autore', 'Autore Sconosciuto')}\"\n")
        out.write(f"date: \"{tesina_data.get('data', '')}\"\n")
        
        # Le nostre variabili personalizzate per il template
        out.write(f"conservatorio: \"{tesina_data.get('conservatorio', '')}, {tesina_data.get('citta', '')}\"\n")
        out.write(f"corso: \"{tesina_data.get('corso', '')}\"\n")
        out.write(f"esame: \"{tesina_data.get('esame', '')}\"\n")

        # Inseriamo il contenuto del riassunto (abstract)
        out.write("abstract: |\n")
        for line in abstract_content.split('\n'):
            out.write(f"  {line}\n")

        # Includi lo stile e altre opzioni di Pandoc
        out.write("header-includes:\n")
        out.write("  - \\usepackage{styles/tesina}\n")
        out.write("documentclass: article\n")
        out.write("toc: true\n")
        out.write("toc-depth: 2\n")

        # === Configurazione bibliografia CiteProc (MODIFICATA) ===
        if found_bib_files:
            out.write("bibliography:\n")
            for key, path in found_bib_files.items():
                out.write(f"  {key}: {path}\n")
        else:
            print("[WARN] No bibliography files found. 'bibliography' field will not be added to frontmatter.")

        out.write("csl: styles/consAq-author-date.csl\n")
        out.write(r'nocite: "@*"' + "\n")

        out.write("---\n\n")
        
        # --- Concatena i file markdown delle sezioni ---
        print("[*] Concatenating markdown files...")
        for i, file in enumerate(files, 1):
            print(f"    [{i}] {file.name}")
            out.write(file.read_text(encoding='utf-8') + "\n\n")
    
    print(f"[SUCCESS] Merged {len(files)} section files into README.md")
    return 0

if __name__ == "__main__":
    exit(main())
