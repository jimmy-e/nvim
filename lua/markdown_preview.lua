local M = {}

local function setup_highlights()
  vim.api.nvim_set_hl(0, "MdPreviewH1", { fg = "#89b4fa", bold = true, underline = true })
  vim.api.nvim_set_hl(0, "MdPreviewH2", { fg = "#cba6f7", bold = true })
  vim.api.nvim_set_hl(0, "MdPreviewH3", { fg = "#f9e2af", bold = true })
  vim.api.nvim_set_hl(0, "MdPreviewH4", { fg = "#a6e3a1", bold = true })
  vim.api.nvim_set_hl(0, "MdPreviewCode", { fg = "#a6e3a1", bg = "#313244" })
  vim.api.nvim_set_hl(0, "MdPreviewCodeBlock", { fg = "#cdd6f4", bg = "#313244" })
  vim.api.nvim_set_hl(0, "MdPreviewCodeLang", { fg = "#585b70", bg = "#313244", italic = true })
  vim.api.nvim_set_hl(0, "MdPreviewBold", { fg = "#cdd6f4", bold = true })
  vim.api.nvim_set_hl(0, "MdPreviewItalic", { fg = "#cdd6f4", italic = true })
  vim.api.nvim_set_hl(0, "MdPreviewBoldItalic", { fg = "#cdd6f4", bold = true, italic = true })
  vim.api.nvim_set_hl(0, "MdPreviewBullet", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "MdPreviewLinkText", { fg = "#89b4fa", underline = true })
  vim.api.nvim_set_hl(0, "MdPreviewLinkUrl", { fg = "#585b70", italic = true })
  vim.api.nvim_set_hl(0, "MdPreviewHR", { fg = "#585b70" })
  vim.api.nvim_set_hl(0, "MdPreviewBlockquote", { fg = "#a6adc8", italic = true })
  vim.api.nvim_set_hl(0, "MdPreviewBlockquoteBar", { fg = "#585b70" })
  vim.api.nvim_set_hl(0, "MdPreviewCheckDone", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "MdPreviewCheckTodo", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "MdPreviewText", { fg = "#cdd6f4" })
end

-- Strip inline markdown syntax and return {rendered_text, highlights}
-- highlights = list of {start_col, end_col, hl_group}
local function render_inline(text)
  local result = ""
  local highlights = {}
  local i = 1
  local len = #text

  while i <= len do
    -- Inline code `...`
    if text:sub(i, i) == "`" and text:sub(i, i + 1) ~= "``" then
      local close = text:find("`", i + 1, true)
      if close then
        local start = #result
        local code = text:sub(i + 1, close - 1)
        result = result .. code
        table.insert(highlights, { start, #result, "MdPreviewCode" })
        i = close + 1
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Bold+Italic ***...***
    elseif text:sub(i, i + 2) == "***" then
      local close = text:find("***", i + 3, true)
      if close then
        local start = #result
        local inner = text:sub(i + 3, close - 1)
        result = result .. inner
        table.insert(highlights, { start, #result, "MdPreviewBoldItalic" })
        i = close + 3
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Bold **...**
    elseif text:sub(i, i + 1) == "**" then
      local close = text:find("**", i + 2, true)
      if close then
        local start = #result
        local inner = text:sub(i + 2, close - 1)
        result = result .. inner
        table.insert(highlights, { start, #result, "MdPreviewBold" })
        i = close + 2
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Bold __...__
    elseif text:sub(i, i + 1) == "__" then
      local close = text:find("__", i + 2, true)
      if close then
        local start = #result
        local inner = text:sub(i + 2, close - 1)
        result = result .. inner
        table.insert(highlights, { start, #result, "MdPreviewBold" })
        i = close + 2
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Italic *...*
    elseif text:sub(i, i) == "*" and text:sub(i + 1, i + 1) ~= "*" then
      local close = text:find("*", i + 1, true)
      if close and close > i + 1 then
        local start = #result
        local inner = text:sub(i + 1, close - 1)
        result = result .. inner
        table.insert(highlights, { start, #result, "MdPreviewItalic" })
        i = close + 1
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Italic _..._
    elseif text:sub(i, i) == "_" and text:sub(i + 1, i + 1) ~= "_" then
      local close = text:find("_", i + 1, true)
      if close and close > i + 1 then
        local start = #result
        local inner = text:sub(i + 1, close - 1)
        result = result .. inner
        table.insert(highlights, { start, #result, "MdPreviewItalic" })
        i = close + 1
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Link [text](url)
    elseif text:sub(i, i) == "[" then
      local bracket_close = text:find("]", i + 1, true)
      if bracket_close and text:sub(bracket_close + 1, bracket_close + 1) == "(" then
        local paren_close = text:find(")", bracket_close + 2, true)
        if paren_close then
          local link_text = text:sub(i + 1, bracket_close - 1)
          local start = #result
          result = result .. link_text
          table.insert(highlights, { start, #result, "MdPreviewLinkText" })
          i = paren_close + 1
        else
          result = result .. text:sub(i, i)
          i = i + 1
        end
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    -- Image ![alt](url) - show as [alt]
    elseif text:sub(i, i + 1) == "![" then
      local bracket_close = text:find("]", i + 2, true)
      if bracket_close and text:sub(bracket_close + 1, bracket_close + 1) == "(" then
        local paren_close = text:find(")", bracket_close + 2, true)
        if paren_close then
          local alt = text:sub(i + 2, bracket_close - 1)
          local start = #result
          result = result .. "[" .. alt .. "]"
          table.insert(highlights, { start, #result, "MdPreviewLinkText" })
          i = paren_close + 1
        else
          result = result .. text:sub(i, i)
          i = i + 1
        end
      else
        result = result .. text:sub(i, i)
        i = i + 1
      end
    else
      result = result .. text:sub(i, i)
      i = i + 1
    end
  end

  return result, highlights
end

-- Transform raw markdown lines into rendered display lines + highlight data
local function render_markdown(raw_lines)
  local display = {}    -- rendered text lines
  local hl_data = {}    -- per-line highlight info: list of {start, end, group}
  local in_code_block = false
  local code_lang = nil

  for _, line in ipairs(raw_lines) do
    -- Code block fence
    if line:match("^```") then
      if not in_code_block then
        in_code_block = true
        code_lang = line:match("^```(%S+)")
        if code_lang then
          table.insert(display, "  " .. code_lang)
          table.insert(hl_data, { { 0, -1, "MdPreviewCodeLang" } })
        end
      else
        in_code_block = false
        code_lang = nil
      end

    -- Inside code block - show as-is with bg
    elseif in_code_block then
      table.insert(display, "  " .. line)
      table.insert(hl_data, { { 0, -1, "MdPreviewCodeBlock" } })

    -- Horizontal rule
    elseif line:match("^%-%-%-+%s*$") or line:match("^%*%*%*+%s*$") or line:match("^___+%s*$") then
      local rule = string.rep("─", 60)
      table.insert(display, rule)
      table.insert(hl_data, { { 0, -1, "MdPreviewHR" } })

    -- Headers
    elseif line:match("^######%s+(.+)") then
      local text = line:match("^######%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH4" } })
      else
        table.insert(hl_data, hls)
      end
    elseif line:match("^#####%s+(.+)") then
      local text = line:match("^#####%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH4" } })
      else
        table.insert(hl_data, hls)
      end
    elseif line:match("^####%s+(.+)") then
      local text = line:match("^####%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH4" } })
      else
        table.insert(hl_data, hls)
      end
    elseif line:match("^###%s+(.+)") then
      local text = line:match("^###%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH3" } })
      else
        table.insert(hl_data, hls)
      end
    elseif line:match("^##%s+(.+)") then
      local text = line:match("^##%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH2" } })
      else
        table.insert(hl_data, hls)
      end
    elseif line:match("^#%s+(.+)") then
      local text = line:match("^#%s+(.+)")
      local rendered, hls = render_inline(text)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewH1" } })
      else
        table.insert(hl_data, hls)
      end

    -- Blockquote
    elseif line:match("^>%s?(.*)") then
      local text = line:match("^>%s?(.*)")
      local rendered, hls = render_inline(text)
      local bar = "  │ "
      table.insert(display, bar .. rendered)
      local offset = #bar
      local line_hls = { { 0, offset, "MdPreviewBlockquoteBar" } }
      for _, hl in ipairs(hls) do
        table.insert(line_hls, { hl[1] + offset, hl[2] + offset, hl[3] })
      end
      if #hls == 0 then
        table.insert(line_hls, { offset, -1, "MdPreviewBlockquote" })
      end
      table.insert(hl_data, line_hls)

    -- Checkbox list - [x] done
    elseif line:match("^(%s*)[%-*+]%s+%[x%]%s+(.+)") then
      local indent, text = line:match("^(%s*)[%-*+]%s+%[x%]%s+(.+)")
      local rendered, hls = render_inline(text)
      local prefix = indent .. "  ✓ "
      table.insert(display, prefix .. rendered)
      local offset = #prefix
      local line_hls = { { 0, offset, "MdPreviewCheckDone" } }
      for _, hl in ipairs(hls) do
        table.insert(line_hls, { hl[1] + offset, hl[2] + offset, hl[3] })
      end
      table.insert(hl_data, line_hls)

    -- Checkbox list - [ ] todo
    elseif line:match("^(%s*)[%-*+]%s+%[%s%]%s+(.+)") then
      local indent, text = line:match("^(%s*)[%-*+]%s+%[%s%]%s+(.+)")
      local rendered, hls = render_inline(text)
      local prefix = indent .. "  ○ "
      table.insert(display, prefix .. rendered)
      local offset = #prefix
      local line_hls = { { 0, offset, "MdPreviewCheckTodo" } }
      for _, hl in ipairs(hls) do
        table.insert(line_hls, { hl[1] + offset, hl[2] + offset, hl[3] })
      end
      table.insert(hl_data, line_hls)

    -- Bullet list
    elseif line:match("^(%s*)[%-*+]%s+(.+)") then
      local indent, text = line:match("^(%s*)[%-*+]%s+(.+)")
      local rendered, hls = render_inline(text)
      local prefix = indent .. "  • "
      table.insert(display, prefix .. rendered)
      local offset = #prefix
      local line_hls = { { 0, offset, "MdPreviewBullet" } }
      for _, hl in ipairs(hls) do
        table.insert(line_hls, { hl[1] + offset, hl[2] + offset, hl[3] })
      end
      table.insert(hl_data, line_hls)

    -- Numbered list
    elseif line:match("^(%s*)(%d+)%.%s+(.+)") then
      local indent, num, text = line:match("^(%s*)(%d+)%.%s+(.+)")
      local rendered, hls = render_inline(text)
      local prefix = indent .. "  " .. num .. ". "
      table.insert(display, prefix .. rendered)
      local offset = #prefix
      local line_hls = { { 0, offset, "MdPreviewBullet" } }
      for _, hl in ipairs(hls) do
        table.insert(line_hls, { hl[1] + offset, hl[2] + offset, hl[3] })
      end
      table.insert(hl_data, line_hls)

    -- Empty line
    elseif line:match("^%s*$") then
      table.insert(display, "")
      table.insert(hl_data, {})

    -- Normal paragraph text
    else
      local rendered, hls = render_inline(line)
      table.insert(display, rendered)
      if #hls == 0 then
        table.insert(hl_data, { { 0, -1, "MdPreviewText" } })
      else
        table.insert(hl_data, hls)
      end
    end
  end

  return display, hl_data
end

function M.open()
  local src_buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[src_buf].filetype
  local fname = vim.api.nvim_buf_get_name(src_buf)

  if ft ~= "markdown" and not fname:match("%.md$") then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  setup_highlights()

  local raw = vim.api.nvim_buf_get_lines(src_buf, 0, -1, false)
  local content, hl_data = render_markdown(raw)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.min(#content + 2, math.floor(vim.o.lines * 0.85))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local title = " " .. (vim.fn.fnamemodify(fname, ":t") or "Markdown Preview") .. " "

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = false

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("markdown_preview")
  for i, hls in ipairs(hl_data) do
    for _, hl in ipairs(hls) do
      vim.api.nvim_buf_add_highlight(buf, ns, hl[3], i - 1, hl[1], hl[2])
    end
  end

  -- Close handlers
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

return M
