#!/usr/bin/env bash
# يفعّل core library desugaring المطلوب من flutter_local_notifications.
# يُستدعى بعد توليد scaffold أندرويد وقبل بناء APK.
set -euo pipefail

python3 - <<'PY'
import re
from pathlib import Path

DESUGAR = 'com.android.tools:desugar_jdk_libs:2.1.4'


def insert_after_block(text: str, pattern: str, line: str) -> str:
    match = re.search(pattern, text, re.MULTILINE)
    if match is None:
        return text
    indent = match.group(1)
    end = match.end()
    return text[:end] + '\n' + indent + '    ' + line + text[end:]


def add_block(text: str, anchor: str, block: str) -> str:
    idx = text.find(anchor)
    if idx < 0:
        return text.rstrip() + '\n\n' + block
    return text[:idx] + block + text[idx:]


def patch_kts(text: str) -> str:
    if 'isCoreLibraryDesugaringEnabled' in text:
        return text
    marker = r'^([ \t]*)compileOptions[ \t]*\{'
    if re.search(marker, text, re.MULTILINE):
        text = insert_after_block(
            text, marker, 'isCoreLibraryDesugaringEnabled = true'
        )
    else:
        block = (
            '    compileOptions {\n'
            '        isCoreLibraryDesugaringEnabled = true\n'
            '        sourceCompatibility = JavaVersion.VERSION_11\n'
            '        targetCompatibility = JavaVersion.VERSION_11\n'
            '    }\n'
        )
        text = add_block(text, '    defaultConfig {', block)

    dependency = f'    coreLibraryDesugaring("{DESUGAR}")\n'
    if 'dependencies {' in text:
        text = text.replace('dependencies {', 'dependencies {\n' + dependency, 1)
    else:
        text = text.rstrip() + '\n\ndependencies {\n' + dependency + '}\n'
    return text


def patch_groovy(text: str) -> str:
    if 'coreLibraryDesugaringEnabled' in text:
        return text
    marker = r'^([ \t]*)compileOptions[ \t]*\{'
    if re.search(marker, text, re.MULTILINE):
        text = insert_after_block(text, marker, 'coreLibraryDesugaringEnabled true')
    else:
        block = (
            '    compileOptions {\n'
            '        coreLibraryDesugaringEnabled true\n'
            '        sourceCompatibility JavaVersion.VERSION_11\n'
            '        targetCompatibility JavaVersion.VERSION_11\n'
            '    }\n'
        )
        text = add_block(text, '    defaultConfig {', block)

    dependency = f"    coreLibraryDesugaring '{DESUGAR}'\n"
    if 'dependencies {' in text:
        text = text.replace('dependencies {', 'dependencies {\n' + dependency, 1)
    else:
        text = text.rstrip() + '\n\ndependencies {\n' + dependency + '}\n'
    return text


kts = Path('android/app/build.gradle.kts')
groovy = Path('android/app/build.gradle')
if kts.exists():
    target = kts
    updated = patch_kts(kts.read_text())
elif groovy.exists():
    target = groovy
    updated = patch_groovy(groovy.read_text())
else:
    raise SystemExit('No android/app/build.gradle(.kts) found')

target.write_text(updated)
print('Core library desugaring enabled in', target)
PY
