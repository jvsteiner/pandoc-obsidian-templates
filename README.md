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
