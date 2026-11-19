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

-- O Omarchy 4.5 passou a dar a cada monitor seus próprios workspaces 1-10
-- (default/hypr/monitor-workspaces.lua), o que briga com a divisão acima.
-- Aqui os workspaces voltam a ser globais: o 3 é sempre o 3, no DP-3.

-- Sem isso, ao recarregar a config ou conectar um monitor, o módulo renumera
-- os workspaces para o bloco de cada monitor (11-20 no DP-3).
o.workspaces.reconcile = function() end

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  local id = tostring(workspace)
  o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = id }))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = id, follow = true }))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = id, follow = false }))
end

-- A versão do módulo também renumeraria o workspace movido.
for _, direction in ipairs({ "l", "r", "u", "d" }) do
  local name = ({ l = "left", r = "right", u = "up", d = "down" })[direction]
  o.rebind("SUPER + SHIFT + ALT + " .. string.upper(name), "Move workspace to " .. name .. " monitor", function()
    -- Mover para onde não há monitor vira um erro na tela.
    local target = hl.get_monitor(direction)
    if target then
      hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))
    end
  end)
end
