-- AstroCommunity plugins and AI completion recipe
-- Run :Copilot auth on first launch to authenticate.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.recipes.ai" },
  { import = "astrocommunity.completion.copilot-lua" },
}
