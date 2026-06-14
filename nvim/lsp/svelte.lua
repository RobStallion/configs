return {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_markers = { "package.json", "svelte.config.js", ".git" },
  single_file_support = true,
}
