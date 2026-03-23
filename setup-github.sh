#!/bin/bash
# Setup script — run this once to initialize and push to GitHub
# Usage: bash setup-github.sh your-github-username

USERNAME=${1:-"your-username"}
REPO="clinic-platform"

echo "Setting up $REPO for GitHub user: $USERNAME"

# Init git
git init
git add .
git commit -m "feat: initial clinic platform architecture and portfolio"

# Create repo on GitHub (requires GitHub CLI — brew install gh)
# gh repo create $REPO --public --description "HIPAA-compliant clinic platform — architecture, K8s deployment, CI/CD, audit logging"

# Or add remote manually:
git remote add origin https://github.com/$USERNAME/$REPO.git
git branch -M main
git push -u origin main

echo ""
echo "Done! Your repo is at: https://github.com/$USERNAME/$REPO"
echo "Portfolio site: open portfolio/index.html"
echo ""
echo "Next steps:"
echo "  1. Enable GitHub Pages: Settings → Pages → Source: main /portfolio"
echo "  2. Your portfolio will be live at: https://$USERNAME.github.io/$REPO"
