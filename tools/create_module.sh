#!/usr/bin/env bash
# Generate a new module from modules/module_template.
#
# Usage:
#   tools/create_module.sh <module_name>
#
# Examples:
#   tools/create_module.sh f_profile      # feature module
#   tools/create_module.sh d_auth         # data module
#
# After running, wire the module's manifest into modules/app/lib/modules.dart
# and run `melos bootstrap`.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/modules/module_template"
MODULES_DIR="$ROOT_DIR/modules"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <module_name>" >&2
  exit 1
fi

NAME="$1"
TARGET_DIR="$MODULES_DIR/$NAME"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template not found at $TEMPLATE_DIR" >&2
  exit 1
fi

if [[ -d "$TARGET_DIR" ]]; then
  echo "Module '$NAME' already exists at $TARGET_DIR" >&2
  exit 1
fi

cp -R "$TEMPLATE_DIR" "$TARGET_DIR"

# Replace the template package name with the new module name in all files.
find "$TARGET_DIR" -type f \( -name '*.dart' -o -name '*.yaml' \) -print0 \
  | xargs -0 sed -i '' "s/module_template/$NAME/g"

# Rename files that embed the template name (e.g. module_template_module.dart).
find "$TARGET_DIR" -type f -name '*module_template*' | while read -r file; do
  mv "$file" "${file//module_template/$NAME}"
done

echo "Created module '$NAME' at $TARGET_DIR"
echo "Next steps:"
echo "  1. Register its manifest in modules/app/lib/modules.dart"
echo "  2. Add it to modules/app/pubspec.yaml dependencies"
echo "  3. Run: melos bootstrap"
