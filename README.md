# Pandoc Templates for Obsidian

This repository lets you export notes from [Obsidian](https://obsidian.md) to pdf and html using a variety of nice looking templates. It is intended to allow you to use Obsidian as a primary writing instrument, but enable nicely formatted typeset output, without the trouble of going through an intermediate step of using Latex.

It provides a set of templates for exporting notes to various formats using [Pandoc](https://pandoc.org).

In order to make use of them, you should have a few things installed:

- [Pandoc](https://pandoc.org)
- [Texlive](https://www.tug.org/texlive/)
- [Obsidian](https://obsidian.md) plus some plugins
- [Obsidian Pandoc plugin](https://github.com/OliverBalfour/obsidian-pandoc)

**NOTE**: Currently, you need to use [my fork](https://github.com/jvsteiner/obsidian-pandoc) of the Obsidian Pandoc plugin to make use of a feature I added that allows you to include additional pandoc arguments in the frontmatter. This enables you to specify different templates for different notes, which is not currently possible with the main repository. This is not yet merged into the main repository, but I hope it will be soon. Other benefits include the ability to have a table of contents in some but not all notes, via `--toc`, or use other specific pandoc flags on a per note basis.

The idea is that you write a note as usual, but include all required metadata in the frontmatter of the note. This metadata will be used by the Pandoc plugin to determine which template to use when exporting the note. By using the adapted templates in this repository, you can export your notes to pdf or html with a variety of different styles.

## Installation

Clone this repository to your local machine into the pandoc template directory. This is usually `~/.local/share/pandoc/templates/` on Linux/MacOS or `C:\Users\USERNAME\AppData\Roaming\pandoc\templates` on Windows. You can find the location of the pandoc template directory by running `pandoc --version` and looking for the line that says `Default user data directory:`.

I have included a folder `texmf` in this repository, and this is used to supplement your tex installation with any customized styles or classes that are required by these templates, since they are not available on CTAN. You can add this to your tex installation by running the included script:

```bash
./addtex
```

and confirm with

```bash
kpsewhich lix.sty # this should return a path to the lix.sty file from this repository
```

## Usage

Here is some sample frontmatter to show what you can include in your notes:

```yaml
title: Galactic Requiem
subtitle: Heroes and Havoc in the Shadows of the Stars
author: Boba Fett
additional-pandoc-arguments:
  - --template novella
  - --pdf-engine=pdflatex
  - --lua-filter=/Users/bobafett/.local/share/pandoc/templates/rawtex.lua
  - --lua-filter=/Users/bobafett/.local/share/pandoc/templates/novella.lua
export-from: md
output:
  pdf_document:
    keep_tex: yes
```

## Templates

The PDF templates included in this repository are:

- `novella` - a template for writing a novel or novella, with chapters and a cover page
- `letter` - a template for writing a letter. There are actually separate templates: letter2 and letter-din. You can experiment with these to see which you prefer.
- `eisvogel` - a mature template for writing a scientific paper, with a cover page, abstract, and bibliography. This is not my work, [but is copied](https://github.com/Wandmalfarbe/pandoc-latex-template).
- `chess` - a two column template for writing chess articles with chess notation and board support.
- `manuscript` - a template for exporting to a [standard manuscript format](https://en.wikipedia.org/wiki/Standard_manuscript_format) for submission to a publisher. Supports both times new roman and monospace fonts, via the `mainfont` variable in the frontmatter.
- `example.docx` - a template for exporting to docx format.
- various html templates for exporting to html format.

## Frontmatter Options

The frontmatter options are as follows. Note, not all of these are required, or even supported, for every template. Some might be required for certain templates.

- `title` - the title of the document
- `subtitle` - the subtitle of the document
- `author` - the author of the document
- `date` - the date of the document
- `abstract` - an abstract for the document
- `keywords` - keywords for the document
- `additional-pandoc-arguments` - a list of additional pandoc arguments to pass to pandoc when exporting the document. This is a list of strings, each of which should be a valid pandoc argument. This is used to specify the template to use, and lua filters among other things.
- `header-includes` - a list of strings to include in the latex header of the document for pdf export. This is used to include custom latex commands or packages.
- `export-from` - the format to export from. This should usually be `md` for markdown, but might need to be `html` for html related markup.
- `output` - a dictionary of output formats to export to. The keys should be the format to export to, and the values should be a dictionary of options for that format. For example, for pdf export, you might want to include the option `keep_tex: yes` to keep the intermediate tex file.
- `mainfont` - the main font to use in the document. This is used in the manuscript template to switch between times new roman and monospace fonts.
- `quote` - a quote to include on the cover page of the document. This is used in the chess template.
- `quote-author` - the author of the quote to include on the cover page of the document. This is used in the chess template.
- `titlepage` - a boolean to include a title page in the document. This is used in the eisvogel template.
- `titlepage-color` - the color of the rule on title page in the document. This is used in the eisvogel template.
- `titlepage-background` - the background image or pdf of the title page in the document. This is used in the eisvogel template.
- `titlepage-text-color` - the color of the text on the title page in the document. This is used in the eisvogel template.
- `publisher` - the publisher of the document. This is used in the novel template.
- `isbn` - the ISBN of the document. This is used in the novel template.
- `year` - the year of the document. This is used in the novel template.

There are more tags that might be available depending on the template you are using. You can look at the templates themselves to see what is available. They usually $s like $tag-example$ in the templates, for example `$fontsize$` is also available in some templates.
