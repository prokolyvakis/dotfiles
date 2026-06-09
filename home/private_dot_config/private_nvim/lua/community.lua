-- AstroCommunity plugins and AI completion
-- Uses Claude via codecompanion.nvim with Anthropic provider.
-- Set ANTHROPIC_API_KEY in your environment to authenticate.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.recipes.ai" },
  { import = "astrocommunity.completion.codecompanion-nvim" },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-sonnet-4-20250514",
              },
            },
          })
        end,
      },
    },
  },
}
