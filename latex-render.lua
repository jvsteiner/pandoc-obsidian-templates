function CodeBlock(block)
    -- Check if the code block is of class 'latex'
    if (block.classes[1] == "language-latex" or block.classes[1] == "latex") then
        local filtered_content = {}
        -- Split the code block content into lines
        for line in block.text:gmatch("[^\r\n]+") do
            -- Check if the line should be filtered
            if not line:match("^\\usepackage{") and line ~= "\\begin{document}" and
                line ~= "\\end{document}" then
                -- If the line doesn't match any of the filter conditions, keep it
                table.insert(filtered_content, line)
            end
        end
        -- Update the code block with filtered content
        block.text = table.concat(filtered_content, "\n")
        return pandoc.RawBlock("latex", block.text)
        --   return block
    end
end
