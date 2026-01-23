-- image-width.lua
-- A Pandoc Lua filter to adjust image widths based on caption format
-- Format: ![Caption text|width](image.png)
-- Function to create a new caption from text
function create_caption(text)
    -- For simple captions, we can just use a Str element
    if text:find("^%s*$") then
        -- Empty caption
        return {}
    else
        -- Non-empty caption
        return pandoc.Inlines(pandoc.Str(text))
    end
end

-- Function to process the image and extract width from caption
function process_image(img)

    -- Convert the caption to a single string
    local caption_text = pandoc.utils.stringify(img.caption)

    -- Check if the caption contains a pipe followed by a number
    -- Using a more flexible pattern that looks for a pipe character followed by digits
    local pipe_pos = caption_text:find("|")

    if pipe_pos then

        -- Extract the parts before and after the pipe
        local new_caption = caption_text:sub(1, pipe_pos - 1)
        local width_part = caption_text:sub(pipe_pos + 1)

        -- Extract the width number from the width part
        local width = width_part:match("(%d+)")

        if width then

            -- Update the image caption without the width part
            img.caption = create_caption(new_caption)

            -- Set the width attribute for the image (in pixels)
            img.attributes.width = width .. "px"

            -- Log the attributes
            for k, v in pairs(img.attributes) do end

            -- Return the modified image
            return img
        else
        end
    else
    end

    -- If no width specification was found, return the image unchanged
    return img
end

-- Handler for standalone images
function Image(img) return process_image(img) end

-- Handler for Figure blocks (which may contain images)
function Figure(fig)

    -- Check if the figure has an image
    for i, block in ipairs(fig.content) do
        if block.t == "Plain" then
            for j, inline in ipairs(block.content) do
                if inline.t == "Image" then
                    -- Process the image
                    local processed_image = process_image(inline)
                    -- Update the image in the figure
                    block.content[j] = processed_image

                    -- Also update the figure caption if needed
                    if processed_image.caption then
                        -- Extract the caption text
                        local caption_text =
                            pandoc.utils.stringify(processed_image.caption)
                        -- Update the figure caption
                        fig.caption = create_caption(caption_text)
                    end
                end
            end
        end
    end

    return fig
end

-- Log when the filter is loaded

-- Return the filter
return {{Image = Image}, {Figure = Figure}}
