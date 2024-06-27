function CodeBlock(c)
    if (c.classes[1] == "language-rawtex" or c.classes[1] == "rawtex") then
        local t = c.text:gsub("\nCopy" .. "$", "")
        return {pandoc.RawBlock("latex", t)}
    end
end

function Code(c)
    local cb = "\\begin{align*}\n\\chessboard\n\\end{align*}"
    if c.text:sub(1, 11) == "\\chessboard" then
        return {
            pandoc.RawInline("latex", cb)
        }
    end
    if c.text:sub(1, 1) == "\\" then
        return {pandoc.RawInline("latex", c.text)}
    end
end
