local uv = vim.loop

local function needs_weekly_update()
  local data_dir = vim.fn.stdpath("data")
  local stamp    = data_dir .. "/mason_last_update"
  local stat     = uv.fs_stat(stamp)
  if not stat then
    return true
  end
  local last_ts = stat.mtime.sec
  local now_ts  = uv.now() / 1000
  return (now_ts - last_ts) >= (7 * 24 * 60 * 60)
end

if needs_weekly_update() then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      if vim.fn.exists(":MasonUpdateAllPackages") == 2 then
        vim.cmd("MasonUpdateAllPackages")
      end
      local data_dir = vim.fn.stdpath("data")
      local stamp    = data_dir .. "/mason_last_update"
      local fd       = vim.loop.fs_open(stamp, "w")
      if fd then
        vim.loop.fs_close(fd)
      end
    end,
  })
end

