#!/bin/bash

# Script pour ajouter un bouton de retour à toutes les pages HTML dans le dossier "objectif rewrite"

# Parcourir tous les fichiers HTML dans le dossier "objectif rewrite"
find objectif\ rewrite -name "*.html" | while read file; do
    echo "Traitement du fichier: $file"
    
    # Vérifier si le fichier contient déjà un bouton de retour
    if grep -q "back-button" "$file"; then
        echo "Le bouton de retour existe déjà dans $file"
    else
        # Ajouter le bouton de retour avant la balise </body>
        sed -i 's|</body>|<div style="text-align: center; margin: 20px 0;"><a href="../../index.html" class="back-button">Retour à la liste des dossiers</a></div>\n</body>|' "$file"
        echo "Bouton de retour ajouté à $file"
    fi
done

echo "Terminé!"