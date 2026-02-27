# 🖥️ Armonie IBM i Skills — Plugin Claude Code

> Collection complète de skills IBM i pour les équipes **Armonie Group / NOTOS**.  
> Transforme Claude Code en expert IBM i : développement RPG, SQL DB2, administration système et plus.

**Auteur** : Sylvain AKTEPE — NOTOS / Armonie Group  
**Version** : 1.0.0  
**IBM Champion 2025**

---

## 📦 Skills inclus

| Skill | Commande slash | Description |
|-------|---------------|-------------|
| **RPG ILE Expert** | `/armonie-ibmi-skills:rpg-ile-expert` | RPG ILE full free, SQLRPGLE, webservices REST, écrans 5250, sous-fichiers |
| **RPG III Expert** | `/armonie-ibmi-skills:rpg3-expert` | RPG III (RPG/400) format colonnes, indicateurs, DSPF, migration vers ILE |
| **RPG II Cycle Expert** | `/armonie-ibmi-skills:rpg2-cycle-expert` | Cycle logique RPG II (programme GAP), 16 étapes, ruptures de contrôle |
| **DB2 SQL Expert** | `/armonie-ibmi-skills:db2-sql-expert` | Procédures stockées, indexation avancée, Visual Explain, services QSYS2, JSON/XML |
| **IBM i Admin Expert** | `/armonie-ibmi-skills:ibmi-admin-expert` | Sous-systèmes, JOBQ, JOBD, profils, spools, sécurité, référence 2399 commandes |
| **Sysadmin Expert** | `/armonie-ibmi-skills:sysadmin-expert` | BRMS, sauvegarde/restauration, PRA, monitoring multi-plateforme Linux + IBM i |

## 🚀 Installation

### Option 1 — Depuis un répertoire local

```bash
# Cloner le dépôt
git clone https://github.com/armonie-group/armonie-ibmi-skills.git

# Installer le plugin
claude plugin add /chemin/vers/armonie-ibmi-skills
```

### Option 2 — Test local (sans installation)

```bash
# Lancer Claude Code avec le plugin en mode dev
claude --plugin-dir /chemin/vers/armonie-ibmi-skills
```

### Option 3 — Partage via settings.json du projet

Ajouter dans le fichier `.claude/settings.json` de votre projet :

```json
{
  "plugins": [
    "/chemin/partagé/armonie-ibmi-skills"
  ]
}
```

Tous les collaborateurs qui clonent le projet verront le plugin automatiquement.

## 🔧 Vérification

Après installation, lancez Claude Code et vérifiez :

```bash
# Lister les skills disponibles
/skills

# Tester un skill directement
/armonie-ibmi-skills:rpg-ile-expert Écris un programme RPG ILE qui lit un fichier client
```

Claude utilisera aussi les skills **automatiquement** quand votre question correspond au domaine (ex: "comment créer un index EVI ?" déclenchera db2-sql-expert).

## 📁 Structure du plugin

```
armonie-ibmi-skills/
├── .claude-plugin/
│   └── plugin.json              # Manifeste du plugin
├── skills/
│   ├── rpg-ile-expert/
│   │   ├── SKILL.md             # Instructions principales
│   │   ├── references/          # Documentation RPG ILE
│   │   └── scripts/             # Exemples de code RPG ILE
│   ├── rpg3-expert/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── scripts/
│   ├── rpg2-cycle-expert/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── scripts/
│   ├── db2-sql-expert/
│   │   └── SKILL.md
│   ├── ibmi-admin-expert/
│   │   ├── SKILL.md
│   │   └── references/
│   └── sysadmin-expert/
│       ├── SKILL.md
│       └── references/
└── README.md
```

## 🎯 Cas d'usage

- **Développeurs RPG** : Écrire du code RPG ILE/III, créer des écrans 5250, des sous-fichiers, consommer des APIs REST
- **DBA DB2** : Optimiser des requêtes, créer des procédures stockées, analyser des plans d'exécution
- **Administrateurs système** : Gérer les sous-systèmes, configurer BRMS, planifier les sauvegardes
- **Formateurs NOTOS** : Support pédagogique pour les étudiants en formation IBM i
- **TMA / Projets clients** : Référence rapide pour les équipes en mission

## 🔄 Mises à jour

```bash
# Si installé via git clone
cd armonie-ibmi-skills
git pull

# Redémarrer Claude Code pour charger les modifications
```

## 📝 Contribuer

Les collaborateurs Armonie peuvent proposer des améliorations :

1. Créer une branche depuis `main`
2. Modifier/ajouter des skills dans `skills/`
3. Tester avec `claude --plugin-dir .`
4. Soumettre une Pull Request

## 📜 Licence

MIT — Armonie Group / NOTOS

---

*Créé par Sylvain AKTEPE — IBM Champion 2025 — NOTOS / Armonie Group*
