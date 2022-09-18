# Informations générales
- [Ajout d'une clé ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- Téléchargement de [git LFS](https://git-lfs.github.com/)
  - Taper ``git lfs install`` dans le terminal en étant dans le fichier cloné
- [Bases du markdown](https://www.markdownguide.org/basic-syntax/)

# Bases de git bash
- Clôner le repository avec une clé ssh
```    
  git clone <ssh key> 
```
- Mettre à jour son code local
```    
  git pull
```
- Vérifier l'état de son code par rapport à l'origine
```
  git status
```
- Changer de branche 
```
  git checkout <initiales>/<nom de la branche> 
```
- Créer une nouvelle branche 
```
  git checkout -b <initiales>/<nom de la branche> 
```
- Supprimer une branche en local
```
  git branch -D <initiales>/<nom de la branche>
```
- Étapes pour push du code
  1. Sauvegarder tout fichiers modifiés
  2. `` git status `` pour vérifier tous les fichiers modifiés
  3. `` git add <fichier à commit> `` ou `` git add . `` pour ajouter les fichiers (à éviter)
  4. `` git commit -m "<messgae>" (les fichiers sont maintenant permanents sur votre ordinateur)
  5. `` git push `` (le code est maintant en ligne)
  6. Créer une pull request
