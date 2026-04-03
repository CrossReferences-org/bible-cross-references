"""
Parser for CrossReferences.org TSV export files.

Each line in the TSV has five columns:
    book, chapter, verse, anchor, references

References are pipe-separated, e.g.:
    Pr 8:22-24|Pr 16:4|Mc 13:19|Jn 1:1-3

Usage:
    from parse_crossreferences import parse_file

    for entry in parse_file('crossreferences_s21.tsv'):
        print(entry['book'], entry['chapter'], entry['verse'])
        print(entry['anchor'])
        for ref in entry['references']:
            print(f"  {ref['book']} {ref['chapter']}:{ref['verses']}")
"""

import re

REF_PATTERN = re.compile(
    r'^\s*(.+?)\s+(\d+):([\d,\s\-]+)\s*$'
)


def parse_reference(ref_str):
    """
    Parse a single reference string like 'Pr 8:22-24' into:
        {'book': 'Pr', 'chapter': 8, 'verses': '22-24', 'raw': 'Pr 8:22-24'}
    Returns None if the string cannot be parsed.
    """
    m = REF_PATTERN.match(ref_str)
    if not m:
        return None
    return {
        'book': m.group(1).strip(),
        'chapter': int(m.group(2)),
        'verses': m.group(3).strip(),
        'raw': ref_str.strip(),
    }


def parse_line(line):
    """
    Parse a single TSV line into a structured dict.
    """
    parts = line.rstrip('\n').split('\t')
    if len(parts) < 5:
        return None

    book, chapter, verse, anchor, refs_raw = parts[0], parts[1], parts[2], parts[3], parts[4]

    references = []
    for ref_str in refs_raw.split('|'):
        ref_str = ref_str.strip()
        if not ref_str:
            continue
        # Handle the rare case of multi-book entries (joined by "; ")
        for sub_ref in ref_str.split('; '):
            parsed = parse_reference(sub_ref)
            if parsed:
                references.append(parsed)

    return {
        'book': book,
        'chapter': int(chapter),
        'verse': int(verse),
        'anchor': anchor,
        'references': references,
    }


def parse_file(filepath, encoding='utf-8'):
    """
    Generator that yields one parsed entry per line, skipping the header.
    """
    with open(filepath, 'r', encoding=encoding) as f:
        next(f)  # skip header
        for line in f:
            entry = parse_line(line)
            if entry:
                yield entry
