#!/bin/bash

# Interactive script to create and publish blog posts

echo "🚀 Blog Post Creator"
echo "=================="

# Get post title
echo -n "Enter post title: "
read -e title

# Get tags
echo -n "Enter tags (comma-separated): "
read -e tags

# Generate timestamp and slug
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
filename="${timestamp}-${slug}.md"
filepath="priv/static/posts/${filename}"

# Create the markdown file
cat > "$filepath" << EOF
tags: $tags

# $title

EOF

echo "📝 Created: $filepath"
echo "Opening in vim..."

# Open in vim
vim "$filepath"

# After vim exits, add to git and commit
echo "📦 Adding to git..."
git add "$filepath"
git commit -m "add post"

echo "🚀 Pushing to gigalixir..."
git push gigalixir

echo "✅ Post published successfully!"