# Doc-lint validation rules

## 1. Size Thresholds

| File Type | Recommended | WARNING | CRITICAL | Rationale |
|-----------|:------------:|:-------:|:--------:|-------------|
| `COMMON.md` | ≤120 | >120 | >200 | Always in context, this is SSOT |
| `CLAUDE.md` / `AGENTS.md` ​​/ `GEMINI.md` | ≤60 | >60 | >120 | Anchor files must be short |
| `SKILL.md` | ≤300 | >300 | >500 | The skill must remain compact |
| `agents/*.md` | ≤120 | >120 | >220 | Role cards, not big system prompts |
| docs/*.md | ≤400 | >500 | >700 | Microsoft Docs: 200-800 ideal range |
| README.md | ≤300 | >500 | >700 | Entry point + workshop guide |
| YAML config (.yaml, .yml) | ≤200 | >300 | >500 | Config, not prose |
| Generic .md (fallback) | ≤400 | >500 | >700 | Fallback for others markdown |

### File classification

Priority (top to bottom, first match):

1. Name `SKILL.md` → SKILL.md
2. The path contains `agents/` → agents/*.md
3. Name `COMMON.md` → `COMMON.md`
4. Name `CLAUDE.md`, `AGENTS.md` ​​or `GEMINI.md` → anchor file
5. Name `README.md` → README.md
6. Extension `.yaml` or `.yml` ​​→ YAML config
7. The path contains `docs/` → docs/*.md
8. Extension `.md` → Generic .md

---

## 2. Known Duplicate Signatures

Pre-registered patterns for quick search via Grep:

| ID | Pattern | Grep signature | Min match |
|----|---------|----------------|-----------|
| KP-1 | Core Rules block | `Trust No One` + `Minimal Diff` ​​+ `Production Ready` | 3 lines within 12 lines |
| KP-2 | COMMON as SSOT | `COMMON.md` + `SSOT` ​​| 2 lines |
| KP-3 | Anchor duplication | `Read Order` + `COMMON.md` ​​+ `core rules` | 3 lines |
| KP-4 | Skill Size Limit | `500 lines` or `≤500` ​​in the context of skill | 1 line |
| KP-5 | Legacy process | `gardener` or `Protocol Injection` ​​or `Escalation Protocol` | 1 line |

### KP-match rule

The file is considered to contain a pattern if ALL lines from the "Min match" column are found.
Duplicate = pattern found in ≥2 files.

---

## 3. SSOT Ownership Matrix

| Content Category | SSOT Owner | Rationale |
|--------------------|------------|-------------|
| Core rules, build/test, general conventions | `COMMON.md` | Basic context for all runtimes |
| Runtime entry instructions | `CLAUDE.md` / `AGENTS.md` ​​/ `GEMINI.md` | Anchor layer for specific runtime |
| Skill authoring rules | `COMMON.md` + skill-specific refs | Do not duplicate in anchor files |
| Algorithm for a specific skill | `SKILL.md` | Scoped context |
| Tutorials, guides | `docs/*.md` | Documentation layer |
| Project Overview | `README.md` | Entry point |

### SSOT Rule

If content from category X is found outside the SSOT Owner, it is WARNING (near-duplicate) or CRITICAL (exact duplicate >5 lines). Recommendation: replace with the `→ see {SSOT Owner}` link.

---

## 4. Diataxis Type Detection

Markers to determine the document type:

| Type | Markers | Examples |
|-----|---------|---------|
| **Tutorial** | "step 1", "step 1", "let's create", "let's create", step-by-step instructions with increasing difficulty | Workshop guides |
| **How-to** | “how to make”, “how to”, “to do X, do Y”, targeted recipes | Trouble shooting |
| **Reference** | parameter tables, API signatures, enum values, pure facts without narrative | API docs, config refs |
| **Explanation** | "why", "why", "architecture", "principle", conceptual explanations | Architecture docs |

### Diataxis Rule

One file contains markers of ≥2 types → INFO "Mixed Diataxis types". Not critical, but it is recommended to separate.

## 5. Structure Rules

| Rule | Criterion | Severity |
|---------|----------|----------|
| Skip title level | H1→H3 or H2→H4 | CRITICAL |
| Anchor-file inflated | anchor file > warning threshold | WARNING |
| Section imbalance | One section >40% of file | WARNING |
| Empty section | Header without content | WARNING |
| Wall-of-text | >20 lines in a row without structure | WARNING |
| Long lines | >200 characters | INFO |
