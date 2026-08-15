-- Distribuição de workspaces entre monitores.
-- Ímpares no DP-3, pares no HDMI-A-1.

local monitors = {
  odd = "DP-3",
  even = "HDMI-A-1",
}

for workspace = 1, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = workspace % 2 == 1 and monitors.odd or monitors.even,

    -- Workspaces 1 e 2 são os que abrem por padrão em cada monitor.
    default = workspace <= 2 or nil,
  })
end
