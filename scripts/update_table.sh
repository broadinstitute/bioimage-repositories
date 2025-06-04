#!/bin/bash

# Update README table from repositories.yaml
# Usage: ./scripts/update_table.sh

set -e  # Exit on error

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "❌ yq is not installed. Install with: brew install yq"
    exit 1
fi

# Check if files exist
if [ ! -f "data/repositories.yaml" ]; then
    echo "❌ data/repositories.yaml not found"
    exit 1
fi

if [ ! -f "README.md" ]; then
    echo "❌ README.md not found"
    exit 1
fi

echo "🔄 Generating table from YAML..."

# Create temporary table file
# Table headers correspond to YAML fields as follows:
# Repository -> .name | URL -> .short_url/.url | Best For -> .description | Qualifications -> .qualifications
# Size Limit -> .size_limit | Cost -> .cost | Metadata -> .metadata_requirements
cat > /tmp/table.md << 'EOF'

*Auto-generated from [data/repositories.yaml](data/repositories.yaml)*

| Repository | URL | Best For | Qualifications | Size Limit | Cost | Metadata |
|------------|-----|----------|----------------|------------|------|----------|
EOF

# Generate table rows from YAML and append to the table file
# This yq command does the following:
# 1. Iterates through each repository in the .repositories[] array from the YAML file
# 2. For each repository, creates a markdown table row by concatenating:
#    - .name (wrapped in **bold** markdown)
#    - .short_url and .url (formatted as a markdown link)
#    - .description, .size_limit, .cost, .metadata_requirements (as plain text columns)
# 3. Outputs each row in this format: | **Name** | [short_url](url) | description | size_limit | cost | metadata |
#
# To modify the table structure:
# - Add/remove columns by editing the string concatenation
# - Change column order by rearranging the " + .field_name + " parts
# - Modify formatting by changing the markdown syntax (**, [], etc.)
# - Add new fields by referencing them as .new_field_name (must exist in YAML)
yq eval '.repositories[] | "| **" + .name + "** | [" + .short_url + "](" + .url + ") | " + .description + " | " + .qualifications + " | " + .size_limit + " | " + .cost + " | " + .metadata_requirements + " |"' data/repositories.yaml >> /tmp/table.md

echo "" >> /tmp/table.md

echo "📝 Updating README.md..."

# Use GNU sed for consistent behavior across platforms
if command -v gsed &> /dev/null; then
    SED=gsed
else
    SED=sed
fi

# Replace content between markers using sed
$SED -i '/<!-- AUTO-GENERATED TABLE START -->/,/<!-- AUTO-GENERATED TABLE END -->/{
    /<!-- AUTO-GENERATED TABLE START -->/r /tmp/table.md
    /<!-- AUTO-GENERATED TABLE START -->/!d
}' README.md

# Clean up
rm /tmp/table.md

echo "🎨 Formatting markdown..."

# Format with prettier if available
if command -v prettier &> /dev/null; then
    prettier --write README.md
    echo "✅ Markdown formatted with prettier"
else
    echo "⚠️  prettier not found, skipping formatting"
fi

echo "✅ Table updated successfully!"
echo "💡 Check the changes with: git diff README.md"
