let mapleader =","

if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
    autocmd VimEnter * PlugInstall
endif

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
" Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
" Plug 'junegunn/goyo.vim'
Plug 'PotatoesMaster/i3-vim-syntax'
" Plug 'jreybert/vimagit'
" Plug 'lukesmithxyz/vimling'
Plug 'vimwiki/vimwiki'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
"Plug 'kovetskiy/sxhkd-vim'
Plug 'ap/vim-css-color'
if v:version >= 800
    Plug 'ludovicchabant/vim-gutentags' " create, maintain tags (using universal-ctags)
endif
Plug 'NLKNguyen/papercolor-theme'
Plug 'hillenr14/tech_support'
Plug 'tpope/vim-fugitive'

call plug#end()

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

set bg=light
set go=a
set mouse=a
set nohlsearch

" clipboard settings ---------------------- {{{
    " set clipboard+=unnamedplus
    func! GetSelectedText()
        normal gv"xy
        let result = getreg("x")
        return result
    endfunc
	if executable("clip.exe")
		noremap <C-C> :call system('clip.exe', GetSelectedText())<CR>
		noremap <C-X> :call system('clip.exe', GetSelectedText())<CR>gvx
		noremap <C-Insert> :call system('clip.exe', GetSelectedText())<CR>
		noremap <S-Del> :call system('clip.exe', GetSelectedText())<CR>gvx
    else
        vnoremap <C-X> "+x
        vnoremap <S-Del> "+x

        vnoremap <C-C> "+y
        vnoremap <C-Insert> "+y

        map <C-V> "+gP
        map <S-Insert> "+gP

        cmap <C-V> <C-R>+
        cmap <S-Insert> <C-R>+
    endif
" }}}
" General settings ---------------------- {{{
    set path+=**
    set encoding=utf-8
    set expandtab
    set fileformats=unix,dos
    set shiftwidth=4
    set showmatch
    set softtabstop=4
    set tabstop=4
    set number
    set relativenumber
    set ttyfast
    set undolevels=255
    set visualbell
    set wrap
    set cursorline
    set mouse=a
    set scrolloff=5
    set ignorecase
    set smartcase
    set grepprg=grep\ -nH
    syntax on
    set hlsearch incsearch
    set backspace=indent,eol,start
    set guitablabel=\[%N\]\ %t\ %M
    set keymodel=startsel
    set virtualedit=block
    set switchbuf=usetab,newtab
    set cscopequickfix=s-,c-,d-,i-,t-,e-
    set cscopetag
    set cscopepathcomp=1
    set guioptions+=A
    set guioptions-=T
    set nocompatible
    filetype plugin on
    set splitbelow splitright
    " Enable autocompletion:
    set wildmode=longest,list,full
" }}}
" key mappings ---------------------- {{{
    if !exists(":Bd")
        command Bd bp | sp | bn | bd
    endif
    " Nerd tree
    map <leader>n :NERDTreeToggle<CR>
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    nnoremap <c-s> :wr<cr>
    nnoremap c "_c
    let mapleader = ","
    nnoremap <leader>sv :source $MYVIMRC<cr>
    nnoremap <leader>ev :execute ":tabnew " . $MYVIMRC<cr>
    nnoremap <leader>j :lnext<cr>
    nnoremap <leader>k :lprevious<cr>
    nnoremap <leader>N :setlocal number!<cr>
    if  has('mac')
        nnoremap <leader>gd :exe 'silent !open "http://dts.mv.usa.alcatel.com/dts/cgi-bin/viewReport.cgi?report_id="' .
        \ matchstr(expand("<cword>"), '\v\d{6}')<cr>
    else
        nnoremap <leader>gd :exe 'silent ! start http://dts.mv.usa.alcatel.com/dts/cgi-bin/viewReport.cgi?report_id=' .
        \ matchstr(expand("<cword>"), '\v\d{6}')<cr>
    endif

    " vimling:
    nm <leader>d :call ToggleDeadKeys()<CR>
    imap <leader>d <esc>:call ToggleDeadKeys()<CR>a
    nm <leader>i :call ToggleIPA()<CR>
    imap <leader>i <esc>:call ToggleIPA()<CR>a
    nm <leader>q :call ToggleProse()<CR>

    " Shortcutting split navigation, saving a keypress:
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l

    " Replace ex mode with gq
    map Q gq

    " Check file in shellcheck:
    map <leader>s :!clear && shellcheck %<CR>

    " Replace all is aliased to S.
    nnoremap S :%s//g<Left><Left>

    " Compile document, be it groff/LaTeX/markdown/etc.
    map <leader>c :w! \| !compiler <c-r>%<CR>

    " Open corresponding .pdf/.html or preview
    map <leader>p :!opout <c-r>%<CR><CR>

    " Goyo plugin makes text more readable when writing prose:
    map <leader>f :Goyo \| set bg=light \| set linebreak<CR>

    " Spell-check set to <leader>o, 'o' for 'orthography':
    map <leader>o :setlocal spell! spelllang=en_us<CR>

    " Save file as sudo on files that require root permission
    cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
" }}}
"File type specific settings ---------------------- {{{
    augroup filetype_s
        autocmd!
        autocmd FileType vim setlocal foldmethod=marker | setlocal foldcolumn=2
        autocmd FileType tech_sup setlocal foldcolumn=2
    augroup END
" }}}
" Global auto commands ---------------------- {{{
    augroup global
        autocmd!
        autocmd BufReadPost * if len(tabpagebuflist()) == 1 | :tabmove | endif
    augroup END
" }}}
" Plugin settings
" papercolor-theme
set background=dark
colorscheme PaperColor

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Ensure files are read as what I want:
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_list = [{'path': '~/drop/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
autocmd BufRead,BufNewFile *.tex set filetype=tex
" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritepre * %s/\n\+\%$//e

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif
