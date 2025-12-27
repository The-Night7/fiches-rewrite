#!/usr/bin/env bash
set -euo pipefail

# Dossier contenant tes fichiers HTML
ROOT_DIR="objectif rewrite"

# Lien du bouton (à adapter si besoin)
BACK_HREF='../../index.html'

# Marqueur pour éviter les doublons
MARKER_CLASS="back-button"
WRAPPER_CLASS="back-button-wrap"

# Bloc HTML injecté (juste avant </body>)
read -r -d '' BACK_HTML <<EOF || true
<div class="$WRAPPER_CLASS">
  <a href="$BACK_HREF" class="$MARKER_CLASS">Retour à la liste des dossiers</a>
</div>
EOF

# Bloc CSS injecté (dans <style> ... </style>)
read -r -d '' BACK_CSS <<'EOF' || true

/* --- BACK BUTTON (AUTO-ADDED) --- */
.back-button-wrap{
  display:flex;
  justify-content:center;
  margin: 18px 0 0;
}

.back-button{
  display:inline-block;
  text-decoration:none;
  padding: 10px 14px;
  border: 2px solid var(--dr-green);
  color: var(--dr-green);
  background: transparent;
  font-weight: bold;
  letter-spacing: 1px;
  text-transform: uppercase;
  font-size: 0.85rem;
  transition: 0.15s ease-in-out;
}

.back-button:hover,
.back-button:focus{
  background: var(--dr-green);
  color: white;
  outline: none;
}
EOF

echo "Recherche des fichiers HTML dans : $ROOT_DIR"
find "$ROOT_DIR" -type f -name "*.html" -print0 | while IFS= read -r -d '' file; do
  echo "Traitement : $file"

  # 1) Si le bouton existe déjà, on skip
  if grep -q "$MARKER_CLASS" "$file"; then
    echo "  -> Déjà présent (skip)"
    continue
  fi

  tmp="$(mktemp)"

  # 2) Injection CSS avant </style> (si on trouve une balise style)
  if grep -qi "</style>" "$file"; then
    # Ajoute le CSS juste avant la première occurrence de </style>
    awk -v css="$BACK_CSS" '
      BEGIN{done=0}
      {
        if (!done && tolower($0) ~ /<\/style>/) {
          print css
          done=1
        }
        print
      }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
  else
    echo "  -> Attention: pas de </style> trouvé, CSS non injecté."
    rm -f "$tmp"
  fi

  # 3) Injection HTML juste avant </body>
  tmp="$(mktemp)"
  if grep -qi "</body>" "$file"; then
    awk -v html="$BACK_HTML" '
      BEGIN{done=0}
      {
        if (!done && tolower($0) ~ /<\/body>/) {
          print html
          done=1
        }
        print
      }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
    echo "  -> Bouton ajouté"
  else
    echo "  -> ERREUR: pas de </body> trouvé, bouton non ajouté."
    rm -f "$tmp"
  fi
done

echo "Terminé."
