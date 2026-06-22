#!/usr/bin/env python3
"""
Resume Generator: YAML -> LaTeX -> PDF
Compact, minimalist CS resume builder with tag filtering support.
"""

import yaml
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

# ============================================================================
# CONFIGURATION
# ============================================================================

TECH_FOCUS = True

# When True, a section that would be split by a page break is pushed wholesale
# to the next page instead. Set False to let page breaks cut sections anywhere.
KEEP_SECTIONS_TOGETHER = True

INCLUDE_SECTIONS = {
    "blurbs", "education", "work_experience", "volunteer_experience",
    "skills", "personal_projects", "achievements", "hobbies",
}

INCLUDE_TAGS = {
    "ai_ml", "software_engineering", "data_science", "web_dev", "hardware",
    "cybersecurity", "research", "leadership", "management", "communication",
    "conflict_resolution", "organization", "automation", "design", "engineering",
    "teamwork", "writing", "humanities", "language", "core_cs", "it",
    "data_management", "3d_printing", "certification", "competition", "music",
    "creative", "teaching", "problem_solving", "games", "hands_on",
    "entrepreneurship", "networking", "utility", "math", "freelance",
    "nonprofit", "policy", "ui", "local_lm",
}

EXCLUDE_TAGS_FOR_TECH = {"exclude_tech"}

ACTIVE_BLURB = "tech_professional"

OUTPUT_DIR = Path.cwd()
OUTPUT_NAME = "Eli Pinals Resume"

# ============================================================================
# HELPERS
# ============================================================================


def is_empty(value: Any) -> bool:
    if value is None:
        return True
    if isinstance(value, str):
        v = value.strip().lower()
        return v == "" or "todo" in v
    if isinstance(value, list):
        return len(value) == 0
    return False


def escape_latex(text: Any) -> str:
    if text is None:
        return ""
    repl = {
        "&": "\\&", "%": "\\%", "$": "\\$", "#": "\\#", "_": "\\_",
        "{": "\\{", "}": "\\}", "~": "\\textasciitilde{}",
        "^": "\\textasciicircum{}",
    }
    text = str(text)
    for c, e in repl.items():
        text = text.replace(c, e)
    return text


def format_url(url: str, label: str = None) -> str:
    if is_empty(url):
        return ""
    label = (label or url).replace("_", "\\_").replace("&", "\\&")
    return f"\\href{{{url}}}{{{label}}}"


def dates(start: str, end: str) -> str:
    """Build a 'start -- end' string from whatever parts exist."""
    if is_empty(start) and is_empty(end):
        return ""
    if is_empty(end):
        return str(start).strip()
    if is_empty(start):
        return str(end).strip()
    return f"{start} -- {end}".strip()


def should_include_item(item: Dict) -> bool:
    tags = item.get("tags", []) if isinstance(item, dict) else []
    if TECH_FOCUS and any(t in EXCLUDE_TAGS_FOR_TECH for t in tags):
        return False
    if not tags:
        return True
    return any(t in INCLUDE_TAGS for t in tags)


# ============================================================================
# LATEX GENERATION
# ============================================================================


class ResumeLaTeX:
    def __init__(self, data: Dict):
        self.data = data
        self.latex: List[str] = []

    def add(self, text: str):
        self.latex.append(text)

    def section_header(self, title: str):
        self.add(f"\\section{{{title}}}\n")

    # ---- keep-whole-section-together ------------------------------------

    def _wrap_keep_together(self, body: str) -> str:
        """
        Measure a section's full height into a box. If it fits within a page,
        reserve that much space (\\needspace) so the section is pushed wholesale
        to the next page rather than splitting. If it's taller than a full page
        (can't fit anywhere), release it with \\unvbox so it flows/breaks
        normally instead of overflowing off the bottom.
        """
        return (
            "\\begingroup\n"
            "\\setbox\\sectionbox=\\vbox{%\n" + body + "}%\n"
            "\\sectionheight=\\dimexpr\\ht\\sectionbox+\\dp\\sectionbox\\relax\n"
            "\\ifdim\\sectionheight>\\textheight\n"
            "  \\unvbox\\sectionbox\n"
            "\\else\n"
            "  \\needspace{\\sectionheight}\\box\\sectionbox\n"
            "\\fi\n"
            "\\endgroup\n"
        )

    def buffered(self, render_fn):
        """Run a section renderer, capture its LaTeX, emit it kept-together."""
        if not KEEP_SECTIONS_TOGETHER:
            render_fn()
            return
        saved = self.latex
        self.latex = []
        render_fn()
        body = "".join(self.latex)
        self.latex = saved
        if body.strip():
            self.add(self._wrap_keep_together(body))

    # ---- reusable building block ---------------------------------------

    def entry(self, title_parts: List[str], right: str = "",
              subtitle: str = "", lines: List[str] = None,
              bullet_items: List[str] = None, gap: str = "0.1in"):
        """
        Generic resume block used by every section.
          title_parts -> joined by ' | ' (caller applies bold/italic)
          right       -> right-aligned italic (usually dates)
          subtitle    -> small italic line under the title
          lines       -> extra small plain lines
          bullet_items-> detail bullets ([] / None = none)

        Text lines are joined with '\\\\' (line breaks) and the block ALWAYS
        ends by closing the paragraph -- either with '\\par' or with the
        itemize environment. Leaving the paragraph open (the old trailing
        '\\\\' + '\\vspace' pattern) caused the next block's first line to be
        treated as a continuation: spurious indent + an oversized gap.
        """
        out = []
        tp = [p for p in (title_parts or []) if not is_empty(p)]
        if tp:
            line = " \\textbar\\ ".join(tp)
            if not is_empty(right):
                line += f" \\hfill \\textit{{{escape_latex(right)}}}"
            out.append(line)
        if not is_empty(subtitle):
            out.append(f"\\small {{\\textit{{{escape_latex(subtitle)}}}}}")
        for l in (lines or []):
            if not is_empty(l):
                out.append(f"\\small {escape_latex(l)}")

        bullets = [escape_latex(d) for d in (bullet_items or []) if not is_empty(d)]

        if out:
            self.add(" \\\\\n".join(out))
            self.add(" \\\\\n" if bullets else "\\par\n")

        if bullets:
            self.add("\\vspace{-0.15in}\n")
            self.add("\\begin{itemize}[leftmargin=0.15in,labelsep=0.05in,topsep=0pt,nosep]\n")
            for d in bullets:
                self.add(f"\\item \\small {d}\n")
            self.add("\\end{itemize}\n")

        self.add(f"\\vspace{{{gap}}}\n")

    def _section(self, key: str, default_title: str) -> Optional[Dict]:
        """Common gate: returns the section dict if it should render, else None."""
        sect = self.data.get(key, {})
        if not sect or key not in INCLUDE_SECTIONS:
            return None
        return sect

    # ---- header & blurb -------------------------------------------------

    def generate_header(self):
        personal = self.data.get("personal", {})
        name = personal.get("preferred_name") or personal.get("full_name", "Name")
        contact = personal.get("contact", {})

        parts = []
        if not is_empty(contact.get("email")):
            e = contact["email"]
            parts.append(f"\\href{{mailto:{e}}}{{{e}}}")
        if not is_empty(contact.get("phone")):
            p = contact["phone"]
            parts.append(f"\\href{{tel:{p}}}{{{escape_latex(p)}}}")

        links = personal.get("links", {})
        for key in ["linkedin", "github"]:
            data = links.get(key)
            entries = data if isinstance(data, list) else [data] if data else []
            for ld in entries:
                if isinstance(ld, dict) and not is_empty(ld.get("url")):
                    parts.append(format_url(ld["url"], ld.get("label", key.capitalize())))

        contact_line = " \\textbar\\ ".join(parts)

        # Location: the address labeled "main" (fallback to first), shown as "City, ST"
        addresses = contact.get("addresses", []) or []
        main = next((a for a in addresses if a.get("type") == "main"), None)
        if main is None and addresses:
            main = addresses[0]
        location = ""
        if main:
            city, state = main.get("city"), main.get("state")
            if not is_empty(city) and not is_empty(state):
                location = f"{city}, {state}"
            elif not is_empty(city):
                location = str(city)

        name_block = f"\\textbf{{\\Large {escape_latex(name)}}}"
        if location:
            name_block += f"\\, \\small \\textit{{{escape_latex(location)}}}"
        self.add(f"\\noindent {name_block} \\hfill \\small {contact_line}\\par\n")
        self.add("\\vspace{0.04in}\n")

    def generate_blurbs(self):
        blurbs = self.data.get("blurbs")
        if not blurbs or "blurbs" not in INCLUDE_SECTIONS or ACTIVE_BLURB is None:
            return

        content = None
        if isinstance(blurbs, dict):
            item = blurbs.get(ACTIVE_BLURB)
            content = item.get("content") if isinstance(item, dict) else item
        elif isinstance(blurbs, list):
            for item in blurbs:
                if isinstance(item, dict) and str(item.get("type", "")).strip() == ACTIVE_BLURB:
                    content = item.get("content")
                    break

        if is_empty(content):
            return

        # Simple, flush-left paragraph (no group/raggedright quirks)
        self.add(f"\\noindent {escape_latex(content)}\\par\n")
        self.add("\\vspace{0.06in}\n")

    # ---- content sections ----------------------------------------------

    def generate_education(self):
        sect = self._section("education", "Education")
        if not sect:
            return
        items = [e for e in sect.get("items", []) if should_include_item(e)]
        if not items:
            return
        self.section_header(sect.get("title", "Education"))
        for edu in items:
            honors = [h for h in edu.get("honors", []) if not is_empty(h)]
            courses = [c.get("name") for c in edu.get("relevant_coursework", [])
                       if should_include_item(c) and not is_empty(c.get("name"))]
            clubs = [a.get("name") for a in edu.get("activities", [])
                     if should_include_item(a) and not is_empty(a.get("name"))]
            edu_details = [d for d in edu.get("details", []) if not is_empty(d)]
            projects = [p for p in edu.get("projects", [])
                        if should_include_item(p) and not is_empty(p.get("name"))]
            lines = []
            if courses:
                lines.append("Relevant Coursework: " + ", ".join(courses))
            if clubs:
                lines.append("Clubs & Activities: " + ", ".join(clubs))
            for d in edu_details:
                lines.append(d)
            for p in projects:
                desc = p.get("description", "")
                lines.append(f"{p.get('name')}: {desc}" if not is_empty(desc)
                             else p.get("name"))
            self.entry(
                [f"\\textbf{{{escape_latex(edu.get('institution'))}}}" if not is_empty(edu.get("institution")) else "",
                 f"\\textit{{{escape_latex(edu.get('degree'))}}}" if not is_empty(edu.get("degree")) else ""],
                right=dates(edu.get("start_date"), edu.get("end_date")),
                subtitle=", ".join(honors) if honors else "",
                lines=lines,
            )

    def generate_work_experience(self):
        sect = self._section("work_experience", "Experience")
        if not sect:
            return
        self.section_header(sect.get("title", "Experience"))
        for job in sect.get("items", []):
            if not should_include_item(job) or is_empty(job.get("company")):
                continue
            company = job.get("company")
            for pos in job.get("positions", []):
                if not should_include_item(pos) or is_empty(pos.get("title")):
                    continue
                self.entry(
                    [f"\\textbf{{{escape_latex(company)}}}",
                     f"\\textbf{{{escape_latex(pos.get('title'))}}}"],
                    right=dates(pos.get("start_date"), pos.get("end_date")),
                    bullet_items=pos.get("details", []),
                )

    def generate_volunteer_experience(self):
        sect = self._section("volunteer_experience", "Volunteer Experience")
        if not sect:
            return
        items = [v for v in sect.get("items", []) if should_include_item(v)]
        if not items:
            return
        self.section_header(sect.get("title", "Volunteer Experience"))
        for vol in items:
            if is_empty(vol.get("organization")) and is_empty(vol.get("role")):
                continue
            ds = vol.get("dates", [])
            self.entry(
                [escape_latex(vol.get("organization")) if not is_empty(vol.get("organization")) else "",
                 f"\\textbf{{{escape_latex(vol.get('role'))}}}" if not is_empty(vol.get("role")) else ""],
                right=ds[0] if ds and not is_empty(ds[0]) else "",
                bullet_items=vol.get("details", []),
            )

    def generate_projects(self):
        sect = self._section("personal_projects", "Projects")
        if not sect:
            return
        items = [p for p in sect.get("items", [])
                 if should_include_item(p) and not is_empty(p.get("name"))]
        if not items:
            return
        self.section_header(sect.get("title", "Projects"))
        for proj in items:
            self.entry(
                [f"\\textbf{{{escape_latex(proj.get('name'))}}}"],
                right=dates(proj.get("start_date"), proj.get("end_date")),
                subtitle=proj.get("description", ""),
                bullet_items=proj.get("details", []),
            )

    def generate_achievements(self):
        sect = self._section("achievements", "Achievements")
        if not sect:
            return
        items = [a for a in sect.get("items", [])
                 if should_include_item(a) and not is_empty(a.get("title"))]
        if not items:
            return
        self.section_header(sect.get("title", "Achievements"))
        for ach in items:
            self.entry(
                [f"\\textbf{{{escape_latex(ach.get('title'))}}}",
                 escape_latex(ach.get("organization")) if not is_empty(ach.get("organization")) else ""],
                lines=[ach.get("description")] if not is_empty(ach.get("description")) else [],
                gap="0.04in",
            )

    def generate_skills(self):
        sect = self._section("skills", "Skills")
        if not sect:
            return
        categories = sect.get("categories", {})
        if not categories:
            return
        self.section_header(sect.get("title", "Skills"))
        for category, skill_list in categories.items():
            skills = [escape_latex(s) for s in (skill_list or []) if not is_empty(s)]
            if not skills:
                continue
            cat = category.replace("_", " ").title()
            self.add(f"\\textbf{{{cat}:}} {', '.join(skills)}\\\\\n")
        self.add("\\vspace{0.04in}\n")

    def generate_hobbies(self):
        sect = self._section("hobbies", "Hobbies")
        if not sect:
            return
        items = [h for h in sect.get("items", [])
                 if should_include_item(h) and not is_empty(h.get("name"))]
        if not items:
            return
        self.section_header(sect.get("title", "Hobbies"))
        for hob in items:
            line = f"\\textbf{{{escape_latex(hob.get('name'))}}}:"
            if not is_empty(hob.get("description")):
                line += f" {escape_latex(hob.get('description'))}"
            self.add(line + "\\\\\n")
        self.add("\\vspace{0.04in}\n")

    # ---- document assembly ---------------------------------------------

    def generate(self) -> str:
        self.add(r"""\documentclass[11pt]{article}
\usepackage[margin=0.5in]{geometry}
\usepackage{hyperref}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{needspace}

\newsavebox{\sectionbox}
\newlength{\sectionheight}

\pagestyle{empty}

\hypersetup{colorlinks=true, urlcolor=blue, linkcolor=black}

\titleformat{\section}{\Large\bfseries}{}{0pt}{}[\titlerule]
\titlespacing{\section}{0pt}{1pt}{2pt}
\titlespacing{\subsection}{0pt}{4pt}{2pt}

\setlist[itemize]{noitemsep, topsep=0pt, partopsep=0pt, itemsep=0pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

\begin{document}

""")
        self.generate_header()
        self.generate_blurbs()
        for fn in (
            self.generate_education,
            self.generate_work_experience,
            self.generate_volunteer_experience,
            self.generate_skills,
            self.generate_projects,
            self.generate_achievements,
            self.generate_hobbies,
        ):
            self.buffered(fn)
        self.add("\\end{document}\n")
        return "".join(self.latex)


# ============================================================================
# MAIN
# ============================================================================


def main():
    yaml_path = Path.cwd() / "resume_data.yaml"
    if not yaml_path.exists():
        print(f"Error: resume_data.yaml not found in {Path.cwd()}")
        sys.exit(1)

    with open(yaml_path) as f:
        data = yaml.safe_load(f)
    if not data:
        print("Error: YAML file is empty")
        sys.exit(1)

    print("\u2713 YAML loaded" + ("  |  tech focus on" if TECH_FOCUS else ""))

    latex_content = ResumeLaTeX(data).generate()
    latex_path = OUTPUT_DIR / f"{OUTPUT_NAME}.tex"
    latex_path.write_text(latex_content)

    try:
        result = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode",
             "-output-directory", str(OUTPUT_DIR), str(latex_path)],
            capture_output=True, text=True, timeout=30,
        )
        if result.returncode == 0:
            print(f"\u2713 Resume created: {OUTPUT_DIR / f'{OUTPUT_NAME}.pdf'}")
            for ext in (".tex", ".aux", ".log", ".out"):
                (OUTPUT_DIR / f"{OUTPUT_NAME}{ext}").unlink(missing_ok=True)
        else:
            print(f"\u26a0 pdflatex error ({result.returncode})")
            print(result.stdout[-500:])
    except FileNotFoundError:
        print("\u26a0 pdflatex not found. Install: sudo apt-get install texlive-latex-base")
    except subprocess.TimeoutExpired:
        print("\u26a0 pdflatex timed out")
    except Exception as e:
        print(f"\u26a0 Compilation error: {e}")


if __name__ == "__main__":
    main()