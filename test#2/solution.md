# Mettre en place un système de notifications pour les tâches en retard des onboardees

---

## Objectif

Lors du parcours d’intégration, les onboardees ont des tâches à effectuer avant une date d’échéance.  
Nous souhaitons les notifier lorsque ces tâches sont en retard, à travers deux canaux :

- **(A)** Une notification affichée dans la barre de navigation (interface)  
- **(B)** Un email récapitulatif envoyé chaque mardi matin

Les notifications doivent être générées de manière **asynchrone**, via des crons, afin de ne pas impacter les performances de l’application.

---

## Critères d’acceptation

- Une tâche est en retard si elle n’est pas marquée comme faite **et** que sa date d’échéance est dépassée.
- Les onboardees voient leurs notifications dans l’application.
- Un email hebdomadaire est envoyé chaque mardi matin avec les tâches toujours en retard.
- Chaque notification correspond à une tâche en retard unique.
- Le nombre de jours de retard est visible.
- Les notifications sont mises à jour automatiquement chaque jour.
- Les notifications ne sont pas recalculées à l’affichage.
- Une notification est archivée lorsque la tâche est terminée.

---

## 🧩 Modèle de données `Notification`

| Champ               | Type       | Description |
|---------------------|------------|-------------|
| Utilisateur         | Référence  | L’onboardee concerné |
| Tâche               | Référence  | La tâche en retard |
| Vue (`seen`)        | Booléen    | Permet l'affichage dans la navbar |
| Jours de retard     | Entier     | Calculé chaque jour |
| Date d’envoi email  | Date       | Dernier envoi d’email associé à cette notification |
| Archivée (`archived_at`) | Date | Marque la notification comme terminée |

---

## Cron jobs à mettre en place

### 1. Cron quotidien - Création ou mise à jour des notifications

- Identifie les tâches en retard (non faites + échéance dépassée)
- Si une notification n’existe pas pour la tâche : création
- Si elle existe :
  - Met à jour le `days_late`
  - Remet `seen: false` si la tâche est toujours en retard

### 2. Cron quotidien - Archivage des notifications résolues

- Parcourt les **notifications non archivées**
- Vérifie si la **tâche liée a été complétée**
- Si oui, remplit le champ `archived_at`

### 3. Cron hebdomadaire - Envoi des emails

- Parcourt les notifications non archivées
- Pour chaque utilisateur ayant au moins une notification :
  - Regroupe les messages
  - Envoie un email récapitulatif des tâches en retard
  - Met à jour la `last_email_sent_at` de chaque notification concernée

**Note:** Doit être lancé après les crons quotidiens

---

## Affichage dans l’interface

L’application récupère les notifications et appartenant au current_user.

Affiche :
- Un badge ou compteur dans la navbar
- Un message de type : *"La tâche “X” est en retard depuis 5 jours"*
- Un bouton ou interaction pour marquer la notification comme "vue"

---

## Endpoints à prévoir

| Méthode | Route                          | Description                          |
|--------|--------------------------------|--------------------------------------|
| GET    | `/notifications`               | Liste les notifications              |
| POST   | `/notifications/:id/mark_seen` | Marque une notification comme vue    |
