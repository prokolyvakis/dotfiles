-- AstroCommunity plugins and AI completion recipe
-- recipes.ai includes copilot-lua integration.
-- Run :Copilot auth on first launch to authenticate.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.recipes.ai" },
}
