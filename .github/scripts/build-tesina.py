#!/usr/bin/env python3
"""
build-tesina.py
Estrae metadati da config.yml e concatena markdown files ordinati
"""
import yaml
import os
from pathlib import Path
def main():
    # ==========================================
    # 1. EXTRACT config.yml
    # ==========================================
    print("[*] Reading config.yml...")
    with open('config.yml', 'r') as f:
        config = yaml.safe_load(f)
    
    meta = config.get('metadata', {})
    cand = config.get('candidato', {})
    esame = config.get('esame', {})
    cons = config.get('conservatorio', {})
    
    # ==========================================
    # 2. WRITE to GITHUB_ENV (for workflow access)
    # ==========================================
    print("[*] Exporting variables to GITHUB_ENV...")
    env_file = os.environ.get('GITHUB_ENV', '.env')
    
    with open(env_file, 'a') as env:
        env.write(f"TITOLO={meta.get('titolo', 'Untitled')}\n")
        env.write(f"SOTTOTITOLO={meta.get('sottotitolo', '')}\n")
        env.write(f"CANDIDATO={cand.get('nome', 'Candidato')}\n")
        env.write(f"MATERIA={esame.get('materia', '')}\n")
        env.write(f"DATA={esame.get('data', '')}\n")
        env.write(f"CONSERVATORIO={cons.get('nome', '')}\n")
        env.write(f"CITTÀ={cons.get('città', '')}\n")
        env.write(f"CORSO={cons.get('corso', '')}\n")
    
    print(f"    [OK] TITOLO: {meta.get('titolo', 'N/A')}")
    print(f"    [OK] CANDIDATO: {cand.get('nome', 'N/A')}")
    print(f"    [OK] MATERIA: {esame.get('materia', 'N/A')}")
    print(f"    [OK] DATA: {esame.get('data', 'N/A')}")
    
    # ==========================================
    # 3. CONCATENATE markdown files (ordered)
    # ==========================================
    print("[*] Concatenating markdown files...")
    docs_dir = Path("docs/sezioni")
    
    if not docs_dir.exists():
        print(f"[ERROR] Directory {docs_dir} not found!")
        return 1
    
    files = sorted([f for f in docs_dir.glob("*.md")])
    
    if not files:
        print(f"[ERROR] No .md files found in {docs_dir}!")
        return 1
    
    # ==========================================
    # 4. CREATE README with COMPLETE frontmatter
    # ==========================================
    print("[*] Creating README.md with full frontmatter...")

    # Recuperiamo i dati da config (assumendo la nuova struttura)
    tesina_data = config.get('tesina', {})

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

        # Includi lo stile e altre opzioni di Pandoc
        out.write("header-includes:\n")
        out.write("  - \\usepackage{styles/tesina}\n")
        out.write("documentclass: report\n") # Esempio: impostiamo la classe del documento
        out.write("toc: true\n") # Abilitiamo il sommario
        out.write("toc-depth: 2\n") # Impostiamo la profondità del sommario

        out.write("---\n\n")
        
        # --- Concatena i file markdown ---
        for i, file in enumerate(files, 1):
            print(f"    [{i}] {file.name}")
            with open(file, "r", encoding='utf-8') as f:
                out.write(f.read() + "\n\n")
    
    print(f"[SUCCESS] Merged {len(files)} markdown files in README.md")
    return 0

  

if __name__ == "__main__":
    exit(main())
