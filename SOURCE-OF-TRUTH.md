# Source of truth

**Editable source:** `draft-mih-sato-agent-accountability-composition.md` (kramdown-rfc2629 /
Markdown). All content edits happen here. Every other artifact in this repo is generated from it
and must not be hand-edited.

**Authoritative generated artifact:** `draft-mih-sato-agent-accountability-composition.xml`. It is
the direct output of `kramdown-rfc2629` run against the Markdown source, and it is in turn the
*input* xml2rfc renders everything else from — so it is upstream of every other generated file,
not derived from one of them. It is what gets submitted to the datatracker.

`draft-mih-sato-agent-accountability-composition.txt` is a rendering of the XML, produced by
`xml2rfc <xml> --text --out <txt>`. It is published for convenience and byte-for-byte
reproducibility is verified (`xml2rfc` on the committed XML reproduces the committed TXT exactly),
but the XML is the artifact of record if the two ever disagree.

**`.html` is dropped from the submission set entirely for this draft.** It is not built, not
committed, and not part of the hashed artifact set. (Decision: Steven, 2026-08-14.) The `Makefile`
no longer has an `.html` target.

## Build reproducibility

The Markdown front matter pins an explicit `date:` field (`kramdown-rfc2629`'s YAML header), so
the `<date .../>` element in the generated XML — and therefore the rendered TXT — is fixed to that
date regardless of the calendar day the build actually runs on. Previously this field was left
unset and `kramdown-rfc2629` defaulted it to `Date.today`, which meant every rebuild on a new
calendar day silently produced a different XML/TXT even with no content change. Bump the `date:`
field by hand only when cutting a new pin.

## Regenerating

```
make          # draft.md -> draft.xml -> draft.txt
```
