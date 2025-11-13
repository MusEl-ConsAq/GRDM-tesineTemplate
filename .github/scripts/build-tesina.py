def main():
    # ==========================================
    # 1. TROVA E ORDINA I FILE DELLE SEZIONI
    # ==========================================
    docs_dir = Path("docs/sezioni")
    print("[*] Finding and sorting markdown section files...")
    if not docs_dir.exists():
        print(f"[ERROR] Directory {docs_dir} not found!")
        return 1
    
    files = sorted([f for f in docs_dir.glob("*.md")])
    
    if not files:
        print(f"[WARN] No section .md files found in {docs_dir} (excluding RIASSUNTO.md).")
    
    # ==============================================================================
    # 2. SCANSIONE AUTOMATICA BIBLIOGRAFIA
    # ==============================================================================
    print("[*] Automatically scanning for bibliography files in docs/...")
    bib_dir = Path("docs")
    found_bib_files = {}

    # Ordiniamo i file trovati per avere un output deterministico
    for file_path in sorted(bib_dir.glob("*.bib")):
        stem = file_path.stem
        base_key = stem[:3].lower()
        final_key = base_key
        
        # Se la chiave base è già presa, cerca una chiave numerata libera
        counter = 1
        while final_key in found_bib_files:
            final_key = f"{base_key}{counter}"
            counter += 1
            
        path_value = str(file_path).replace('\\', '/')
        found_bib_files[final_key] = path_value

        if final_key != base_key:
             print(f"    [INFO] Key '{base_key}' was taken. Using new key '{final_key}' for {file_path.name}")
        else:
             print(f"    [OK] Found: {file_path.name} -> Mapped to key '{final_key}'")

    if found_bib_files:
        with open("bibliography.yaml", "w", encoding='utf-8') as bib_file:
            bib_file.write("---\n")
            bib_file.write("bibliography:\n")
            for key, path in sorted(found_bib_files.items()):
                bib_file.write(f"  {key}: {path}\n")
            bib_file.write("---\n")
    else:
        print("[WARN] No bibliography files found. Skipping bibliography.yaml.")

    # ==========================================
    # 3. CREA README.MD CON CONTENUTI
    # ==========================================
    print("[*] Creating README.md with full frontmatter...")
    with open("README.md", "w", encoding='utf-8') as out:        
        # --- Concatena i file markdown delle sezioni ---
        print("[*] Concatenating markdown files...")
        for i, file in enumerate(files, 1):
            print(f"    [{i}] {file.name}")
            out.write(file.read_text(encoding='utf-8') + "\n\n")
        
        # =================================================================
        #3.1 AGGIUNGI I DIV PER LE BIBLIOGRAFIE MULTIPLE
        # =================================================================
        print("[*] Appending bibliography placeholder divs...")
        if found_bib_files:
            for key in sorted(found_bib_files.keys()):
                path_str = found_bib_files[key]
                filename_stem = Path(path_str).stem
                section_title = filename_stem.upper()
                section_id = key # Ora userà 'bib', 'bib1', etc.
                
                print(f"    [+] Appending section '{section_title}' with ID #refs-{section_id}")
                
                out.write(f"# {section_title}\n\n")
                out.write(f"::: {{#refs-{section_id}}}\n")
                out.write(f":::\n\n")

    print(f"[SUCCESS] Merged {len(files)} section files and added bibliography sections to README.md")
    return 0

if __name__ == "__main__":
    exit(main())
