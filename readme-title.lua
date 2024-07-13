function Pandoc(doc)
    doc.blocks:walk{
        Header = function(h)
            -- use top-level heading as title, unless the doc
            -- already has a title
            if h.level == 1 and not doc.meta.title then
                doc.meta.title = h.content
                return {} -- remove this heading from the body
            end
        end
    }
    return doc
end
