-- Aparência das janelas.
--
-- Carrega depois dos defaults do Omarchy E depois dos overrides do tema, então
-- o que estiver aqui vence os dois. É de propósito: o rounding abaixo estava
-- vindo do tema "solitude" (o único de fábrica que mexe nisso), e mudaria
-- sozinho na próxima troca de tema.

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 6,
  },

  decoration = {
    rounding = 6,
    rounding_power = 3,

    -- Janela focada opaca, as demais levemente translúcidas.
    active_opacity = 1.0,
    inactive_opacity = 0.9,
  },
})

-- O default do Omarchy desliga a animação de troca de workspace; religa aqui.
-- Equivale ao antigo `animation = workspaces, 1, 4, easeOutQuint`.
-- A curva easeOutQuint já vem definida pelos defaults do Omarchy.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint" })

-- Suaviza a troca entre active_opacity e inactive_opacity ao mudar o foco.
-- O default do Omarchy desliga este leaf, o que deixa o corte 1.0 -> 0.9 seco.
-- speed é medido em decisegundos: 3 ≈ 300ms.
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3, bezier = "easeOutQuint" })
