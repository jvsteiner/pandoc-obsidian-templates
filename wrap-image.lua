-- Helper function to convert Pandoc elements to LaTeX
local function convert_to_latex(element)
    -- Create a Pandoc document containing the element
    local doc = pandoc.Pandoc({element})
    -- Convert the document to LaTeX
    return pandoc.write(doc, "latex")
end

function add_to_header(meta)
    -- LaTeX command to include a package
    local use_package = pandoc.RawBlock('latex', '\\usepackage{wrapfig}')

    -- LaTeX macro definition
    local custom_macro = pandoc.RawBlock('latex', [[
\usepackage{wrapfig}
\makeatletter
\newcommand{\checkheight}[1]{%
    \par \penalty-100\begingroup%
    \setlength{\dimen@}{#1}%
    \dimen@ii\pagegoal \advance\dimen@ii-\pagetotal
    \ifdim \dimen@>\dimen@ii
        \break
    \fi\endgroup}
\makeatother
  ]])

    local header_includes
    if meta['header-includes'] and meta['header-includes'].t == 'MetaList' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList {meta['header-includes']}
    end
    header_includes[#header_includes + 1] = pandoc.MetaBlocks {custom_macro}
    meta['header-includes'] = header_includes
    return meta
end

function Pandoc(doc)
    for i, block in ipairs(doc.blocks) do
        -- Check if the block is a Figure
        -- doc.blocks[i] is a Figure
        if block.t == "Figure" then
            for j, inline in ipairs(block.content) do
                -- doc.blocks[i].content[j] is a Plain
                if inline.t == "Plain" then
                    -- Get the image element
                    -- doc.blocks[i].content[j].content[1] is an Image
                    image = inline.content[1]
                    -- Convert the caption to a single string
                    local alt_text = pandoc.utils.stringify(image.caption)
                    -- Match the pattern, allowing the alt text to contain spaces
                    new_caption, width, height = alt_text:match(
                                                     "^(.-)%s*|%s*(%d+)%s*x%s*(%d+)%s*$")
                    -- If the pattern matches, apply the size to the image
                    -- print(new_caption, width, height)
                    if new_caption and width and height then
                        -- Remove the size part from the alt text
                        image.caption = {pandoc.Str(new_caption)}
                        -- Set the width and height attributes for the image
                        image.attributes.width = width
                        image.attributes.height = height
                    end
                    -- break
                    local wrapfig_begin =
                        pandoc.RawBlock('latex', '\\checkheight{' .. height ..
                                            'pt}\n\\begin{wrapfigure}{r}{0.5\\textwidth}')
                    local wrapfig_end = pandoc.RawBlock('latex',
                                                        '\\end{wrapfigure}')
                    local latex_caption = pandoc.Div({
                        pandoc.Para({
                            pandoc.RawInline('latex',
                                             '\\caption{' .. new_caption .. '}')
                        })
                    })
                    local checked_div = pandoc.Div({
                        wrapfig_begin, image, latex_caption, wrapfig_end
                    })
                    doc.blocks[i] = checked_div
                end
                -- set the Figure caption
                block.caption = {pandoc.Str(new_caption)}
            end
        end
    end
    return doc
end

-- Return the filter that processes Div elements
return {{Pandoc = Pandoc}}
