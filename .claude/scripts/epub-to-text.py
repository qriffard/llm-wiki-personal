#!/usr/bin/env python3
"""Extract plain text (in reading order) from an EPUB, stdlib only.

Usage: epub-to-text.py <input.epub> <output.md>

Used by this wiki's Ingest > EPUB route (see CLAUDE.md). No pandoc/calibre
dependency: parses META-INF/container.xml -> OPF spine for reading order,
then strips HTML tags from each chapter.
"""
import sys
import re
import zipfile
import posixpath
import xml.etree.ElementTree as ET
from html.parser import HTMLParser


class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []
        self.skip_depth = 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self.skip_depth += 1
        if tag in ("p", "br", "div", "h1", "h2", "h3", "h4", "h5", "h6", "li"):
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if tag in ("script", "style") and self.skip_depth:
            self.skip_depth -= 1

    def handle_data(self, data):
        if not self.skip_depth:
            self.parts.append(data)

    def text(self):
        raw = "".join(self.parts)
        raw = re.sub(r"[ \t]+", " ", raw)
        raw = re.sub(r"\n\s*\n\s*\n+", "\n\n", raw)
        return raw.strip()


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: epub-to-text.py <input.epub> <output.md>")
    src, dst = sys.argv[1], sys.argv[2]

    with zipfile.ZipFile(src) as z:
        container = ET.fromstring(z.read("META-INF/container.xml"))
        ns_c = {"c": "urn:oasis:names:tc:opendocument:xmlns:container"}
        opf_path = container.find(".//c:rootfile", ns_c).get("full-path")
        opf_dir = posixpath.dirname(opf_path)

        opf = ET.fromstring(z.read(opf_path))
        ns_o = {"o": "http://www.idpf.org/2007/opf"}

        manifest = {
            item.get("id"): item.get("href")
            for item in opf.findall(".//o:manifest/o:item", ns_o)
        }
        title_el = opf.find(".//{http://purl.org/dc/elements/1.1/}title")
        title = title_el.text if title_el is not None else src

        spine = opf.findall(".//o:spine/o:itemref", ns_o)
        chapters = []
        for itemref in spine:
            idref = itemref.get("idref")
            href = manifest.get(idref)
            if not href:
                continue
            path = posixpath.normpath(posixpath.join(opf_dir, href))
            try:
                raw_html = z.read(path).decode("utf-8", errors="replace")
            except KeyError:
                continue
            extractor = TextExtractor()
            extractor.feed(raw_html)
            chapters.append(extractor.text())

    with open(dst, "w") as f:
        f.write(f"# {title}\n\n")
        f.write("\n\n---\n\n".join(c for c in chapters if c))

    print(f"wrote {dst} ({len(chapters)} chapters, title={title!r})")


if __name__ == "__main__":
    main()
