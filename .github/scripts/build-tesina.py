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
    # 4. CREATE README with frontmatter
    # ==========================================
    with open("README.md", "w") as out:
        # Scrivi il frontmatter YAML
        out.write("---\n")
        #out.write(f"title: {meta.get('titolo', 'Untitled')}\n")
        #out.write(f"subtitle: {meta.get('sottotitolo', '')}\n")
        out.write("header-includes:\n")
        out.write("  - \\usepackage{styles/mystyle}\n")
        out.write("---\n\n")
        
        # Concatena i file markdown
        for i, file in enumerate(files, 1):
            print(f"    [{i}] {file.name}")
            with open(file, "r") as f:
                out.write(f.read() + "\n\n")
    
    print(f"[SUCCESS] Merged {len(files)} markdown files in README.md")
    return 0

if __name__ == "__main__":
    exit(main())
