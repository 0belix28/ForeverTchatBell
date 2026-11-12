# ForeverTchatBell - Historique des versions

Format des versions : **0.X.Y**
- **X** : mise à jour majeure (nouvelle fonctionnalité importante)
- **Y** : mise à jour mineure (correction, petit ajout)
- Passage en **1.0.0** quand l'addon sera terminé et stable.

Le numéro de version se change à un seul endroit : la ligne `## Version:` de `ForeverTchatBell.toc`.

---

## 0.2.1 - Logo cloche

- Nouveau logo : une cloche dorée sur fond transparent (Media\Logo.tga, 128×128), à la place du logo de ForeverEgo.
  Utilisé dans le panneau d'options et comme icône dans la liste des AddOns.
- Media\Logo_source.png : la même cloche détourée en grande taille (non utilisée par le jeu, pour retouches).

## 0.2.0 - Panneau au style ForeverEgo

- Le panneau d'options reprend la direction artistique de ForeverEgo : logo, grand titre doré, version,
  gros bouton, encadrés sombres à bord doré avec lignes alternées.
- Trois encadrés : « Réglages », « Sons par canal » et « Commandes ».
- Le gros bouton du haut active / désactive tous les sons (affiche l'état en vert / rouge).
- Le panneau défile si le menu Options est trop petit.
- Logo Forever ajouté (Media\Logo.tga), aussi utilisé comme icône dans la liste des AddOns.

## 0.1.0 - Première version (remplace ForeverGuildBell)

- Un son joué à chaque message reçu, réglable canal par canal : Guilde, Officiers, Chuchotements,
  Chuchotements Battle.net, Groupe, Raid, Avertissement de raid, Instance, Dire, Crier,
  Canaux (Commerce, Général...), Communautés.
- Son par défaut : la cloche d'ouverture de l'hôtel des ventes. Seule la Guilde est activée au départ.
- Panneau de configuration dans Échap > Options > AddOns > ForeverTchatBell (aussi `/ftb` et le compartiment d'addons) :
  - activer / désactiver chaque canal ;
  - bouton « Écouter » ;
  - bouton « Changer... » : ouvre ForeverSoundLibrary (0.3.0 ou plus) pour choisir le son ;
  - bouton « Défaut » : remet la cloche de l'hôtel des ventes.
- Réglages généraux : activer tout, jouer aussi pour ses propres messages, canal audio Master, délai anti-spam (2 s par défaut, par canal).
- Commandes : `/ftb` (panneau), `/ftb toggle`, `/ftb test`, `/ftb help`.
