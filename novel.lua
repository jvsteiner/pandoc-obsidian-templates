-- lettrine_filter.lua
-- Utility function to process the first few words of a paragraph/sentence
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

            -- Ensure the effect does not go beyond the first sentence
            -- local sentence_end = false
            -- if end_index then
            --     for j = end_index + 1, #content do
            --         if content[j].t == "Str" and content[j].text:match("%.") then
            --             sentence_end = true
            --             break
            --         end
            --     end
            -- end

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

-- Function to operate on each section
function Pandoc(doc)
    local in_section = false
    for i, blk in ipairs(doc.blocks) do
        if blk.t == "Header" then
            in_section = true
        elseif in_section and (blk.t == "Para" or blk.t == "Plain") then
            doc.blocks[i] = lettrine_first_few_words(blk)
            in_section = false
        end
    end
    return doc
end

-- Return the table with the function(s) as a Pandoc filter
return {{Pandoc = Pandoc}}
