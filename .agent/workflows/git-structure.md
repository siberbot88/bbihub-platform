---
description: Git Repository Structure - Dual Repo Setup
---

# 🔄 Git Repository Structure

## IMPORTANT: This project uses SEPARATE Git repositories!

```
BBIHUB/
├── backend/.git/  → https://github.com/*/bbihub-core-api.git
└── mobile/.git/   → https://github.com/*/bbi-hub-flutter-app.git
```

## Key Points

- **Backend dan Mobile TIDAK dalam satu repository**
- Masing-masing memiliki GitHub repository yang BERBEDA
- Folder parent `BBIHUB` hanya untuk mempermudah development, BUKAN git repository
- Setiap perubahan harus di-commit dan push TERPISAH

## Git Commands

### For Backend Changes
```bash
cd E:\BBIHUB\backend
git add .
git commit -m "Your message"
git push origin main
```

### For Mobile Changes
```bash
cd E:\BBIHUB\mobile
git add .
git commit -m "Your message"
git push origin main
```

### Check Status Both Repos
```bash
# Backend
cd E:\BBIHUB\backend && git status

# Mobile  
cd E:\BBIHUB\mobile && git status
```

## Reminder
⚠️ **ALWAYS** specify which repository (backend or mobile) when working with Git commands!
⚠️ Do NOT assume changes in one repo affect the other repo!
⚠️ Each repo has its own branches, commits, and history!
