if not rod._scan_direction then
    rod.scan = {}
end

rod._scan_direction = matches[2]
rod.scan[rod._scan_direction] = {}
