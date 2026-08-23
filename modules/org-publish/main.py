import re
import shutil
import subprocess
from pathlib import Path

source_path = Path("~/notes/org").expanduser()
target_path = Path("./org")
private_tags = {"private"}
private_dirs = {"agenda"}

shutil.rmtree(target_path, ignore_errors=True)
target_path.mkdir(parents=True, exist_ok=True)
filetags_pattern = re.compile(r"^#\+filetags:\s*(.*)$", re.IGNORECASE | re.MULTILINE)
inline_math_pattern = re.compile(r"\$[^\n]*?\$")
display_math_pattern = re.compile(r"^\s*\$\s*$.*?^\s*\$\s*$", re.MULTILINE | re.DOTALL)
file_link_pattern = re.compile(r"\[\[file:(.*?\/assets\/.*?)\]\]")

def translate_math(typst):
    t2l_result = subprocess.run(
        ["t2l", "-d", "t2l", "--strict"],
        input=typst,
        text=True,
        capture_output=True,
        check=True,
    )
    tex = t2l_result.stdout.strip()
    return tex

def translate_inline_math(match):
    return translate_math(match.group(0).strip())

def translate_display_math(match):
    tex = translate_math(match.group(0).strip())
    tex = (
            tex
            .replace(r"\begin{align}", r"\begin{aligned}")
            .replace(r"\end{align}", r"\end{aligned}")
           )
    return f"\n{tex}\n"

for file_path in source_path.rglob("*.org"):
    relative_path = file_path.relative_to(source_path)

    skip = False
    for d in private_dirs:
        if str(relative_path).startswith(d):
            skip = True
            break
    if skip:
        continue

    if not file_path.is_file():
        continue
    content = file_path.read_text(encoding="utf-8")

    tags = set()
    match = filetags_pattern.search(content)
    if match:
        tags = {t for tag in match.group(1).split(":") if (t:=tag.strip().replace(":", ""))}

    if tags.intersection(private_tags):
        continue

    def replace_file_link(match, file_path=file_path, relative_path=relative_path):
        asset_relative_str = match.group(1).strip()
        asset_source_path = (file_path.parent / asset_relative_str).resolve()
        asset_relative_path = asset_source_path.relative_to(source_path)
        if asset_source_path.is_file():
            asset_dest_path = (target_path / relative_path.parent / asset_relative_str).resolve()
            asset_dest_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(asset_source_path, asset_dest_path)
        return f"[[file:./{asset_relative_path}]]"

    content = file_link_pattern.sub(replace_file_link, content)
    content = inline_math_pattern.sub(translate_inline_math, content)
    content = display_math_pattern.sub(translate_display_math, content)

    destination_path = target_path / relative_path
    destination_path.parent.mkdir(parents=True, exist_ok=True)
    destination_path.write_text(content, encoding="utf-8")
