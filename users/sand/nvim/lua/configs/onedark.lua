return { 'navarasu/onedark.nvim', lazy = false, priority = 1000, config = function()
  require('onedark').setup {
    style = 'dark',
    code_style = {
      comments = 'italic',
      keywords = 'italic',
      functions = 'italic',
      strings = 'none',
      variables = 'italic',
    },
  }
  require('onedark').load()
end }
