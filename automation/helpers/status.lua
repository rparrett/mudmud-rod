rod.status_sections = rod.status_sections or {}

function rod.status_header(title)
    return {
        { text = "━━", foreground = ansi.bright_magenta, bold = true },
        { text = " " .. title, foreground = ansi.bright_cyan, bold = true },
        "\n",
    }
end

function rod.render_status()
    local output = {}
    local order = { "character", "opponent", "area", "affects", "equipment" }

    for index, section_name in ipairs(order) do
        if index > 1 then
            table.insert(output, "\n")
        end
        table.insert(output, rod.status_sections[section_name] or {})
    end

    rod.buffers.status:set(output)
end

function rod.set_status_section(section_name, content)
    rod.status_sections[section_name] = content
    rod.render_status()
end

rod.status_sections.affects = rod.status_sections.affects or rod.status_header("Affects")
rod.update_equipment_status()
