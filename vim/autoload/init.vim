fun! init#SetupVAM()
    " set advanced options like this:
    " let g:vim_addon_manager = {}
    " let g:vim_addon_manager['key'] = value

    " YES, you can customize this vam_install_path path and everything 
    " still works!
    let vam_install_path = expand('$HOME') . '/.vim/vim-addons'
    exec 'set runtimepath+='.vam_install_path.'/vim-addon-manager'

    " * unix based os users may want to use this code checking out VAM
    " * windows users want to use http://mawercer.de/~marc/vam/index.php
    "   to fetch VAM, VAM-known-repositories and the listed plugins
    "   without having to install curl, unzip, git tool chain first
    " -> BUG [4] (git-less installation)
    if !filereadable(vam_install_path.'/vim-addon-manager/.git/config')
                \&& 1 == confirm("Clone VAM into ".vam_install_path."?","&Y\n&N")
        " I'm sorry having to add this reminder. Eventually it'll pay off.
        call confirm("Remind yourself that most plugins ship with ".
                    \"documentation (README*, doc/*.txt). It is your ".
                    \"first source of knowledge. If you can't find ".
                    \"the info you're looking for in reasonable ".
                    \"time ask maintainers to improve documentation")
        call mkdir(vam_install_path, 'p')
        execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.shellescape(vam_install_path, 1).'/vim-addon-manager'
        " VAM runs helptags automatically when you install or update 
        " plugins
        exec 'helptags '.fnameescape(vam_install_path.'/vim-addon-manager/doc')
    endif

    " Example: drop git sources unless git is in PATH. Same plugins can
    " be installed form www.vim.org. Lookup MergeSources to get more control
    " let g:vim_addon_manager['drop_git_sources'] = !executable('git')

    " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0})
    "  - look up source from pool (<c-x><c-p> complete plugin names):
    "    ActivateAddons(["foo",  ..
    "  - name rewritings: 
    "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
    "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
    " Also see section "2.2. names of addons and addon sources" in VAM's documentation
endfun
