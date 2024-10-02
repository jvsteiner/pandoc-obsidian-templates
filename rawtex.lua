function CodeBlock(c)
    if (c.classes[1] == "language-rawtex" or c.classes[1] == "rawtex") then
        local t = c.text:gsub("\nCopy" .. "$", "")
        return {pandoc.RawBlock("latex", t)}
    end
end

-- Function to split a string by a delimiter
local function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function CodeBlockMathPlugin(el)
    -- Check if the code block has a class "math"
    if el.classes:includes("math") then
        -- Split the text into lines
        local lines = split(el.text, "\n")

        -- Remove the first two lines
        table.remove(lines, 1) -- Remove first line
        table.remove(lines, 1) -- Remove second line

        -- Add leading & to each line for proper left alignment
        for i, line in ipairs(lines) do
            if line ~= "" then
                lines[i] = "& " .. line
                print(line)
            else
                lines[i] = "\newline" -- Preserve blank lines as empty strings
            end
        end

        -- Combine the remaining lines with `\\` for LaTeX flalign environment, ensuring the equations are left-aligned
        local combined_lines = "\\begin{flalign*}\n" ..
                                   table.concat(lines, " & \\\\\n") ..
                                   "\n\\end{flalign*}"

        -- Return the combined lines as a single Math block
        return pandoc.Para {pandoc.RawInline('latex', combined_lines)}
    end
end

-- Add the split function to the string table for ease of use
string.split = split

function Code(c)
    local cb = "\\begin{align*}\n\\chessboard\n\\end{align*}"
    if c.text:sub(1, 11) == "\\chessboard" then
        return {pandoc.RawInline("latex", cb)}
    end
    if c.text:sub(1, 1) == "\\" then
        return {pandoc.RawInline("latex", c.text)}
    end
end
