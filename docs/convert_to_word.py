"""
Convert Sweet Delights markdown documentation to Microsoft Word (.docx).
Run: python docs/convert_to_word.py
Output: docs/word/*.docx
"""

from __future__ import annotations

import re
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor

DOCS_DIR = Path(__file__).resolve().parent
OUT_DIR = DOCS_DIR / "word"

# Order for combined report (skip README)
DOC_FILES = [
    "01_Project_Proposal.md",
    "09_Feasibility_Study.md",
    "02_SRS_Software_Requirements_Specification.md",
    "03_System_Design_Document.md",
    "04_Database_Design.md",
    "05_UML_Diagrams.md",
    "06_Test_Plan_and_Test_Cases.md",
    "07_User_Manual.md",
    "11_Requirements_Traceability_Matrix.md",
    "12_SDLC_Phase_Summary.md",
    "08_Project_Report.md",
    "10_Presentation_Outline.md",
]


def setup_styles(doc: Document) -> None:
    normal = doc.styles["Normal"]
    normal.font.name = "Calibri"
    normal.font.size = Pt(11)
    normal._element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")

    for level in range(1, 5):
        style = doc.styles[f"Heading {level}"]
        style.font.name = "Calibri"
        style.font.color.rgb = RGBColor(0x5C, 0x1A, 0x1A)
        style._element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")


def add_formatted_runs(paragraph, text: str, bold_default: bool = False) -> None:
    """Parse **bold**, *italic*, and `code` inline markers."""
    pattern = re.compile(
        r"(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`|\[[^\]]+\]\([^)]+\)|[^*`\[\\]+)"
    )
    for part in pattern.findall(text):
        if part.startswith("**") and part.endswith("**"):
            run = paragraph.add_run(part[2:-2])
            run.bold = True
        elif part.startswith("*") and part.endswith("*"):
            run = paragraph.add_run(part[1:-1])
            run.italic = True
        elif part.startswith("`") and part.endswith("`"):
            run = paragraph.add_run(part[1:-1])
            run.font.name = "Consolas"
            run.font.size = Pt(10)
            run.font.color.rgb = RGBColor(0x33, 0x33, 0x33)
        elif part.startswith("[") and "](" in part:
            m = re.match(r"\[([^\]]+)\]\(([^)]+)\)", part)
            if m:
                run = paragraph.add_run(m.group(1))
                run.underline = True
                run.font.color.rgb = RGBColor(0x05, 0x63, 0xC1)
        else:
            run = paragraph.add_run(part)
            if bold_default:
                run.bold = True


def parse_table_row(line: str) -> list[str]:
    line = line.strip().strip("|")
    return [cell.strip() for cell in line.split("|")]


def is_table_separator(line: str) -> bool:
    return bool(re.match(r"^\|?[\s\-:|]+\|?$", line.strip()))


def add_table(doc: Document, rows: list[list[str]]) -> None:
    if not rows:
        return
    cols = max(len(r) for r in rows)
    table = doc.add_table(rows=len(rows), cols=cols)
    table.style = "Table Grid"
    for i, row in enumerate(rows):
        for j in range(cols):
            cell_text = row[j] if j < len(row) else ""
            cell = table.rows[i].cells[j]
            cell.text = ""
            p = cell.paragraphs[0]
            add_formatted_runs(p, cell_text, bold_default=(i == 0))
    doc.add_paragraph()


def add_code_block(doc: Document, lines: list[str], language: str = "") -> None:
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.25)
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(6)
    if language == "mermaid":
        note = p.add_run("[UML Diagram — see Mermaid source below or draw in Visio/draw.io]\n")
        note.italic = True
        note.font.size = Pt(10)
    for line in lines:
        run = p.add_run(line + "\n")
        run.font.name = "Consolas"
        run.font.size = Pt(9)
        run.font.color.rgb = RGBColor(0x2D, 0x2D, 0x2D)


def md_to_docx(md_path: Path, doc: Document | None = None, page_break_before: bool = False) -> Document:
    if doc is None:
        doc = Document()
        setup_styles(doc)
        for section in doc.sections:
            section.top_margin = Inches(1)
            section.bottom_margin = Inches(1)
            section.left_margin = Inches(1)
            section.right_margin = Inches(1)

    if page_break_before:
        doc.add_page_break()

    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    i = 0
    in_code = False
    code_lines: list[str] = []
    code_lang = ""
    table_rows: list[list[str]] = []
    in_table = False
    list_buffer: list[tuple[str, str]] = []  # (type, text) type = ul|ol

    def flush_list() -> None:
        nonlocal list_buffer
        for kind, item in list_buffer:
            style = "List Bullet" if kind == "ul" else "List Number"
            p = doc.add_paragraph(style=style)
            add_formatted_runs(p, item)
        list_buffer = []

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Code fence
        if stripped.startswith("```"):
            if not in_code:
                flush_list()
                in_code = True
                code_lang = stripped[3:].strip().lower()
                code_lines = []
            else:
                add_code_block(doc, code_lines, code_lang)
                in_code = False
                code_lines = []
                code_lang = ""
            i += 1
            continue

        if in_code:
            code_lines.append(line)
            i += 1
            continue

        # Table
        if stripped.startswith("|") and "|" in stripped[1:]:
            if not in_table:
                flush_list()
                in_table = True
                table_rows = []
            if not is_table_separator(stripped):
                table_rows.append(parse_table_row(stripped))
            i += 1
            continue
        elif in_table:
            add_table(doc, table_rows)
            in_table = False
            table_rows = []

        # Horizontal rule
        if stripped in ("---", "***", "___"):
            flush_list()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
            run = p.add_run("─" * 60)
            run.font.color.rgb = RGBColor(0xCC, 0xCC, 0xCC)
            i += 1
            continue

        # Headers
        m = re.match(r"^(#{1,4})\s+(.+)$", stripped)
        if m:
            flush_list()
            level = len(m.group(1))
            p = doc.add_heading("", level=level)
            add_formatted_runs(p, m.group(2))
            i += 1
            continue

        # Unordered list
        m = re.match(r"^[-*+]\s+(.+)$", stripped)
        if m:
            list_buffer.append(("ul", m.group(1)))
            i += 1
            continue

        # Ordered list
        m = re.match(r"^\d+\.\s+(.+)$", stripped)
        if m:
            list_buffer.append(("ol", m.group(1)))
            i += 1
            continue

        # Empty line
        if not stripped:
            flush_list()
            i += 1
            continue

        # Normal paragraph
        flush_list()
        p = doc.add_paragraph()
        add_formatted_runs(p, stripped)
        i += 1

    flush_list()
    if in_table and table_rows:
        add_table(doc, table_rows)
    if in_code and code_lines:
        add_code_block(doc, code_lines, code_lang)

    return doc


def title_page(doc: Document) -> None:
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("\n\n\nSweet Delights\n")
    run.bold = True
    run.font.size = Pt(28)
    run.font.color.rgb = RGBColor(0x5C, 0x1A, 0x1A)

    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r2 = p2.add_run("Cake Online Shopping Android Application\n")
    r2.font.size = Pt(16)

    p3 = doc.add_paragraph()
    p3.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r3 = p3.add_run(
        "\n\nSoftware Engineering Project Documentation\n\n"
        "Course: Software Engineering\n"
        "Institution: [Your College Name]\n"
        "Department: [Your Department]\n"
        "Academic Year: 2025–2026\n\n"
        "Submitted By:\n"
        "[Member 1] — [Roll No.]\n"
        "[Member 2] — [Roll No.]\n"
        "[Member 3] — [Roll No.]\n"
        "[Member 4] — [Roll No.]\n\n"
        "Guide: [Supervisor Name]\n"
        "Date: June 2026\n"
    )
    r3.font.size = Pt(12)
    doc.add_page_break()


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Individual files
    for name in DOC_FILES:
        src = DOCS_DIR / name
        if not src.exists():
            print(f"Skip missing: {name}")
            continue
        out_name = name.replace(".md", ".docx")
        doc = md_to_docx(src)
        out_path = OUT_DIR / out_name
        doc.save(out_path)
        print(f"Created: {out_path}")

    # Combined submission file for faculty
    combined = Document()
    setup_styles(combined)
    title_page(combined)
    for idx, name in enumerate(DOC_FILES):
        src = DOCS_DIR / name
        if src.exists():
            md_to_docx(src, combined, page_break_before=(idx > 0))

    combined_path = OUT_DIR / "Sweet_Delights_Complete_Project_Documentation.docx"
    combined.save(combined_path)
    print(f"\nCombined file: {combined_path}")
    print(f"\nAll Word files saved in: {OUT_DIR}")


if __name__ == "__main__":
    main()
