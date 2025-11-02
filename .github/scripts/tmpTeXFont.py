#!/usr/bin/env python3
import yaml

# File di input e output
config_file = "config.yml"
output_file = "styles/config_fonts.tex"

# Leggi il YAML
with open(config_file, "r") as f:
    config = yaml.safe_load(f)

# Prendi il font dal YAML, default 'liberation'
font = cfg.get("environment", {}).get("font", "liberation").lower()

# Validazione base: accetta solo 'arial' o 'liberation'
if chosen_font not in ["arial", "liberation"]:
    print(f"Font '{chosen_font}' non riconosciuto. Uso 'liberation' come default.")
    chosen_font = "liberation"

# Scrivi il file .tex
with open(output_file, "w") as f:
    f.write(f"\\def\\chosenfont{{{chosen_font}}}\n")

print(f"File '{output_file}' generato con \\chosenfont = '{chosen_font}'")
