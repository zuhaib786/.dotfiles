local utils = require("zuhaib.utils")

return {
  {
    "https://github.com/nvim-orgmode/orgmode",
    enabled = function()
      return not utils.is_inside_vscode()
    end,
    dependencies = {
      "https://github.com/nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("orgmode").setup({
        org_agenda_files       = { "~/Downloads/Projects/org/**/*" },
        org_default_notes_file = "~/Downloads/Projects/org/inbox.org",
        org_startup_folded     = "content",
        org_hide_leading_stars = true,
        org_log_done           = "time",
        org_log_into_drawer    = "LOGBOOK",
        org_todo_keywords = { "TODO", "IN-PROGRESS", "DONE", "CANCELLED"},
        org_todo_keyword_faces = {
          TODO        = ":foreground red :weight bold",
          ["IN-PROGRESS"] = ":foreground orange :weight bold",
          DONE        = ":foreground green",
          CANCELLED   = ":foreground gray :slant italic",
        },
        mappings = {
          disable_all = true,
          global = {
            org_agenda  = "<Leader>oa",
            org_capture = "<Leader>occ",
          },
        },
      })

      -- Wire org-buffer-only keys via autocmd so disable_all doesn't eat them
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "org",
        callback = function()
          local o = { silent = true, buffer = true }
          -- cycle TODO → IN-PROGRESS → DONE
          vim.keymap.set("n", "cit",
            function() require("orgmode").action("org_mappings.todo_next_state") end,
            vim.tbl_extend("force", o, { desc = "Org: cycle todo forward" }))
          -- cycle backwards
          vim.keymap.set("n", "ciT",
            function() require("orgmode").action("org_mappings.todo_prev_state") end,
            vim.tbl_extend("force", o, { desc = "Org: cycle todo backward" }))
          -- schedule
          vim.keymap.set("n", "<Leader>os",
            function() require("orgmode").action("org_mappings.org_schedule") end,
            vim.tbl_extend("force", o, { desc = "Org: schedule" }))
          -- deadline
          vim.keymap.set("n", "<Leader>od",
            function() require("orgmode").action("org_mappings.org_deadline") end,
            vim.tbl_extend("force", o, { desc = "Org: deadline" }))
          -- follow link
          vim.keymap.set("n", "<CR>",
            function() require("orgmode").action("org_mappings.open_at_point") end,
            vim.tbl_extend("force", o, { desc = "Org: follow link" }))
          -- fold cycle
          vim.keymap.set("n", "<Tab>",
            function() require("orgmode").action("org_mappings.cycle") end,
            vim.tbl_extend("force", o, { desc = "Org: cycle fold" }))
          vim.keymap.set("n", "<S-Tab>",
            function() require("orgmode").action("org_mappings.global_cycle") end,
            vim.tbl_extend("force", o, { desc = "Org: global fold cycle" }))
        end,
      })
    end,
  },

  {
    "https://github.com/chipsenkbeil/org-roam.nvim",
    enabled = function()
      return not utils.is_inside_vscode()
    end,
    dependencies = {
      "https://github.com/nvim-orgmode/orgmode",
    },
    lazy = false,
    config = function()
      require("org-roam").setup({
        directory = "~/Downloads/Projects/org/roam",
        org_files  = { "~/Downloads/Projects/org/**/*" },
        bindings = {
          prefix = "<Leader>on",
        },
      })

      -- export all roam notes to markdown
      vim.keymap.set("n", "<Leader>one", function()
        local out = vim.fn.expand("~/Downloads/Projects/org/export")
        vim.fn.mkdir(out, "p")
        local cmd = string.format(
          "find ~/Downloads/Projects/org/roam -name '*.org' | "
          .. "xargs -I{} pandoc {} --from org --to markdown "
          .. "-o %s/$(basename {} .org).md",
          out
        )
        vim.fn.jobstart(cmd, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("Exported to " .. out, vim.log.levels.INFO)
            else
              vim.notify("Export failed — is pandoc installed?", vim.log.levels.ERROR)
            end
          end,
        })
      end, { silent = true, desc = "Roam: export all notes → Markdown" })
    end,
  },
}
