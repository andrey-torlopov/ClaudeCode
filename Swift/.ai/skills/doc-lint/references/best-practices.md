# Corporate documentation practices

Brief excerpts from the industry standards on which the doc-lint rules are based.

---

## 1. Google Technical Writing

- **Single Source of Truth (SSOT):** Every fact in exactly one place. The rest are referred.
- **One idea per sentence:** One sentence = one thought. Easier to translate, easier to test.
- **Link, don't duplicate:** If the content already exists, put a link, don't copy.

> Source: [Google Technical Writing](https://developers.google.com/tech-writing)

---

## 2. Amazon 6-Pager

- **Length discipline:** A hard limit forces you to prioritize.
- **Narrative is more important than slides:** Structured text > a scattering of bullet points.
- **The principle of "Working backwards":** Start with the result for the reader, then the details.

> Source: Amazon Leadership Principles, internal docs practice

---

## 3. Diataxis Framework

Four types of documents - do not mix in one file:

| Type | Goal | Orientation |
|-----|------|------------|
| **Tutorial** | Teach | Learning-oriented |
| **How-to** | Solve the problem | Task-oriented |
| **Reference** | Give facts | Information-oriented |
| **Explanation** | Explain "why" | Understanding-oriented |

> Source: [diataxis.fr](https://diataxis.fr)

---

## 4. Microsoft Docs

- **200-800 lines:** Ideal range for a single document.
- **Consistent hierarchy:** H1→H2→H3, without skipping levels.
- **Scannable:** Headings, lists, tables - the reader must find what he needs in 30 seconds.
- **TOC for long documents:** >200 lines require table of contents.

> Source: [Microsoft Style Guide](https://learn.microsoft.com/style-guide)

---

## 5. GitLab Handbook

- **DRI (Directly Responsible Individual):** Each document has one person responsible.
- **Link, don't duplicate:** Strict rule: if duplication is found, merge request to delete the copy.
- **Single source of truth:** Handbook is the only source of truth, wiki is prohibited.

> Source: [GitLab Handbook](https://handbook.gitlab.com)

---

## 6. Stripe Docs

- **Cross-reference instead of copying:** Each piece of code/table lives in one place.
- **Progressive disclosure:** Basic example → advanced options → edge cases.
- **Versioning:** Documentation is tied to the API version.

> Source: [Stripe API Docs](https://stripe.com/docs/api)

---

## Synthesis for doc-lint

| Practice | Rule in doc-lint |
|----------|--------------------|
| SSOT (Google, GitLab) | Cross-file duplicate detection + SSOT Owner |
| Length Discipline (Amazon, Microsoft) | Size thresholds per file type |
| Do not mix types (Diataxis) | Mixed Diataxis type detection |
| Consistent Headers (Microsoft) | Heading hierarchy check |
| Cross-reference (Stripe, GitLab) | Recommendation "link instead of copy" |
| Progressive Disclosure (Stripe) | Already implemented in skill architecture |
