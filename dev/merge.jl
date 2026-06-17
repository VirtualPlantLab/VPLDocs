using FileIO

function merge_markdown_files(directory, merged_content="")
    items = readdir(directory; join=true)
    for item in items
        if isdir(item)
            merged_content = merge_markdown_files(item, merged_content)
        elseif occursin(".md", item)
            content = read(item, String)
            merged_content *= content * "\n\n"
        end
    end
    return merged_content
end

merged_content = merge_markdown_files("docs/src")
write(joinpath("dev", "merged.md"), merged_content)
