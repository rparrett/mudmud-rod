local container = string.trim(matches.container or "")
if container == "" then
    return
end

rod._container_tracking = container
rod._container_contents_working = {}
