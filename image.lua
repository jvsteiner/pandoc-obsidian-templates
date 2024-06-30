function Pandoc(doc)
    for i, block in ipairs(doc.blocks) do
        if block.t == "Figure" then
            for j, inline in ipairs(block.content) do
                if inline.t == "Plain" then
                    -- Get the image element
                    el = inline.content[1]
                    -- Convert the caption to a single string
                    local alt_text = pandoc.utils.stringify(el.caption)
                    -- Match the pattern, allowing the alt text to contain spaces
                    new_caption, width, height = alt_text:match(
                                                     "^(.-)%s*|%s*(%d+)%s*x%s*(%d+)%s*$")
                    -- If the pattern matches, apply the size to the image
                    -- print(new_caption, width, height)
                    if new_caption and width and height then
                        -- Remove the size part from the alt text
                        el.caption = {pandoc.Str(new_caption)}
                        -- Set the width and height attributes for the image
                        el.attributes.width = width
                        el.attributes.height = height
                    end
                    -- break
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
