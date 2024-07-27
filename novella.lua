local function stringify(inlines)
    local result = {}
    for _, inline in ipairs(inlines) do
        table.insert(result, pandoc.utils.stringify(inline))
    end
    return table.concat(result, " ")
end

local function lettrine_first_few_words(para)
    if para.t == "Para" or para.t == "Plain" then
        local content = para.content
        if #content > 0 then
            local words = {}
            local word_count = 0
            local end_index = nil

            -- Iterate over the inline elements to gather the first few words
            for i, inline in ipairs(content) do
                if inline.t == "Str" then
                    for word in inline.text:gmatch("%S+") do
                        if word:match("%.") then
                            table.insert(words, word)
                            end_index = i
                            sentence_end = true
                            break
                        end
                        table.insert(words, word)
                        word_count = word_count + 1
                        if word_count >= 5 then
                            end_index = i
                            break
                        end
                    end
                elseif inline.t == "Space" then
                    table.insert(words, " ")
                elseif inline.t == "SoftBreak" or inline.t == "LineBreak" then
                    table.insert(words, " ")
                elseif inline.t == "Strong" or inline.t == "Emph" then
                    local str = pandoc.utils.stringify(inline)
                    for word in str:gmatch("%S+") do
                        table.insert(words, word)
                        word_count = word_count + 1
                        if word_count >= 5 then
                            end_index = i
                            break
                        end
                    end
                end
                if end_index then break end
            end

            -- Create the lettrine LaTeX command
            if #words > 0 then
                local lettrine_content = table.concat(words, "")
                lettrine_content = lettrine_content:gsub("^%s*(.-)%s*$", "%1") -- Trim leading/trailing spaces
                para.content = {
                    pandoc.RawInline('latex',
                                     "\\lettrine{" .. lettrine_content:sub(1, 1) ..
                                         "}{" .. lettrine_content:sub(2) .. "} ")
                }
                for k = end_index + 1, #content do
                    table.insert(para.content, content[k])
                end
                if not sentence_end and content[end_index] then
                    table.insert(para.content, 2, content[end_index])
                end
            end
        end
    end
    return para
end

-- Function to handle headings
function process_header(elem)
    if elem and elem.content then
        -- Convert heading content to a string
        local content = stringify(elem.content)
        -- Create a raw LaTeX block with the content in italic
        local raw_latex = "\\h{" .. content .. "}"
        -- Return the raw LaTeX block
        return pandoc.RawBlock("latex", raw_latex)
    end
end

-- Function to process the first block of a section
local function process_block(block)
    if block.t == "Para" or block.t == "Plain" then
        local content = block.content
        if content and #content > 0 then
            local first = content[1]

            if first.t == "Str" then
                local new_first = pandoc.RawInline("latex", "\\l{" ..
                                                       pandoc.utils
                                                           .stringify(first):sub(
                                                           1, 1) .. "}")
                local rest = pandoc.Str(pandoc.utils.stringify(first):sub(2))

                block.content = {new_first, rest}
                -- Append any remaining content
                for i = 2, #content do
                    table.insert(block.content, content[i])
                end
            elseif first.t == "Emph" or first.t == "Strong" then
                -- If the first element is emphasized or strong, handle nested content
                local first_nested = first.c[1]
                if first_nested and first_nested.t == "Str" then
                    local new_first = pandoc.RawInline("latex", "\\l{" ..
                                                           pandoc.utils
                                                               .stringify(
                                                               first_nested):sub(
                                                               1, 1) .. "}")
                    local rest = pandoc.Str(
                                     pandoc.utils.stringify(first_nested):sub(2))

                    table.insert(first.c, 1, new_first)
                    first.c[2] = rest
                end
            end
        end
    end
    return block
end

-- Function to operate on each section
function Pandoc(doc)
    for i, blk in ipairs(doc.blocks) do
        if blk.t == "Header" and doc.blocks[i + 1] then
            doc.blocks[i] = process_header(doc.blocks[i])
            doc.blocks[i + 1] = process_block(doc.blocks[i + 1]) -- this
            -- or
            -- doc.blocks[i + 1] = lettrine_first_few_words(doc.blocks[i + 1])
        end
    end
    return doc
end

-- Return the functions to be used as the filter
return {{Pandoc = Pandoc}}
