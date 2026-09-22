#!/bin/sh
# Xcode Cloud runs this after checkout, before every build action.
set -eu
set +x
umask 077
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export CINESEEKER_IOS_ROOT="$(dirname "$SCRIPT_DIR")"
python3 - <<'PY'
import os
import re
from pathlib import Path

token = os.environ.get('TMDB_READ_TOKEN', '').strip()
if not re.fullmatch(r'[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+', token):
    raise SystemExit('Missing or invalid TMDB_READ_TOKEN. Set it as a secret in the Xcode Cloud workflow.')
config = Path(os.environ['CINESEEKER_IOS_ROOT']) / 'Config' / 'Config.xcconfig'
config.write_text('TMDB_READ_TOKEN = ' + token + '\n')
config.chmod(0o600)
print('CineSeeker catalog configuration prepared.')
PY
