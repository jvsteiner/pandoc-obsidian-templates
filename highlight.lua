-- highlight.lua
-- Pandoc Lua filter to convert ==highlighted text== to LaTeX highlighting
-- Function to escape special LaTeX characters
local function escape_latex(text)
    local escapes = {
        ['{'] = '\\{',
        ['}'] = '\\}',
        ['\\'] = '\\textbackslash{}',
        ['#'] = '\\#',
        ['$'] = '\\$',
        ['%'] = '\\%',
        ['&'] = '\\&',
        ['_'] = '\\_',
        ['^'] = '\\textasciicircum{}',
        ['~'] = '\\textasciitilde{}'
    }
    return text:gsub('([{}\\#$%%&_^~])', escapes)
end

-- Define the LaTeX command for highlighting at the beginning of the document
local highlight_setup = [[
\usepackage{soul}
\definecolor{HighlightColor}{RGB}{255, 255, 0}
\sethlcolor{HighlightColor}
]]

-- Add the LaTeX packages to the document header
function Meta(meta)
    -- Initialize header-includes if it doesn't exist
    if not meta['header-includes'] then
        meta['header-includes'] = pandoc.MetaList {}
    end

    -- Add our highlight setup
    table.insert(meta['header-includes'], pandoc.MetaInlines {
        pandoc.RawInline("latex", highlight_setup)
    })

    return meta
end

function Inlines(inlines)
    local buffer = {}
    local in_highlight = false
    local highlight_text = {}

    for i, elem in ipairs(inlines) do
        if elem.text then
            if elem.text:match("^==") then
                in_highlight = true
                -- Remove the == from the start
                local text = elem.text:gsub("^==", "")
                if text:match("==$") then
                    -- Single word highlight
                    in_highlight = false
                    text = text:gsub("==$", "")
                    local escaped_text = escape_latex(text)
                    table.insert(buffer, pandoc.RawInline("latex", "\\hl{" ..
                                                              escaped_text ..
                                                              "}"))
                else
                    table.insert(highlight_text, text)
                end
            elseif elem.text:match("==$") and in_highlight then
                -- End of highlight
                in_highlight = false
                local text = elem.text:gsub("==$", "")
                table.insert(highlight_text, text)
                local full_text = table.concat(highlight_text, " ")
                local escaped_text = escape_latex(full_text)
                table.insert(buffer, pandoc.RawInline("latex", "\\hl{" ..
                                                          escaped_text .. "}"))
                highlight_text = {}
            elseif in_highlight then
                table.insert(highlight_text, elem.text)
            else
                table.insert(buffer, elem)
            end
        else
            if not in_highlight then
                table.insert(buffer, elem)
            else
                table.insert(highlight_text, " ")
            end
        end
    end

    if #buffer > 0 then return buffer end
end

-- Return the filter
return {Meta = Meta, Inlines = Inlines}
