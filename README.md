# Notes to future self

after reinstalling or updating tex, you might need to run

```bash
tlmgr conf auxtrees add ~/.local/share/pandoc/templates/texmf
```

to add the pandoc templates to the search path for `tlmgr`.
https://stackoverflow.com/questions/74921228/install-custom-tex-packages

confirm with

```bash
kpsewhich lix.sty
```

## Novella template

Chapters do not work with markdown syntax, use `\h{My Chapter name}` instead of `# My Chapter name`

Letterine chapter starts can be accessed via `\l{I}` command, assuming the rawtex filter is applied.
