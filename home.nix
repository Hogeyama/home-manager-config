# https://rycee.gitlab.io/home-manager/options.html
{ config, pkgs, ... }:
let
  user = import ./user.nix;
in
{
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    packages = with pkgs; [
      aws-sam-cli
      awscli2
      bat
      curl
      deno
      docker
      docker-compose
      fd
      fuse
      fzf
      go
      golangci-lint
      google-cloud-sdk
      htop
      jq
      mercurial
      nodejs
      nodePackages.npm
      # openjdk8
      openjdk11
      ripgrep
      rnix-lsp
      unar
      wget
      yq
      tridactyl-native # for firefox
      neovim-remote
      ### my packages
      ### font
      rounded-mgenplus
      (import ./external/fonts/illusion { inherit fetchzip unzip; })
    ];
    file = {
      # neovim
      ".config/nvim/real-init.vim".source = ./files/.config/nvim/init.vim;
      ".config/nvim/snippets" = {
        source = ./files/.config/nvim/snippets;
        recursive = true;
      };
      # tmux
      ".config/tmux/real-tmux.conf".source = ./files/.config/tmux/.tmux.conf;
      # font
      ".config/fontconfig/conf.d/20-illusion-fonts.conf".source = ./files/.config/fontconfig/conf.d/20-illusion-fonts.conf;
      # firefox
      ".local/share/tridactyl/native_main".source = ./files/.local/share/tridactyl/native_main;
      # my script
      ".local/bin/myfzf".source = ./files/.local/bin/myfzf;
      ".local/bin/myclip".source = ./files/.local/bin/myclip;
      ".local/bin/my-xmonad-borderwidth".source = ./files/.local/bin/my-xmonad-borderwidth;
    };
    sessionVariables = {
      EDITOR = "nvim";
    };
  };
  programs = {
    home-manager = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    neovim = {
      enable = true;
      withNodeJs = true;
      withPython3 = true;
      extraConfig = ''
        source  ~/.config/nvim/real-init.vim
      '';
      coc = {
        enable = true;
        settings = {
          "suggest.keepCompleteopt" = true;
          "diagnostic.virtualText" = true;
          "diagnostic.virtualTextPrefix" = "-- ";
          "diagnostic.enableSign" = false;
          "coc.preferences.useQuickfixForLocations" = false;
          "coc.preferences.formatOnSaveFiletypes" = [
            "nix"
            "json"
            "javascript"
            "typescript"
            "typescriptreact"
            "haskell"
          ];
          "codeLens.enable" = false;
          languageserver = {
            haskell = {
              command = "haskell-language-server-wrapper";
              args = [
                "--lsp"
                "-d"
                "-l"
                "/tmp/LanguageServer.log"
              ];
              rootPatterns = [
                "*.cabal"
                "stack.yaml"
                "cabal.project"
                "package.yaml"
                "hie.yaml"
              ];
              filetypes = [
                "haskell"
                "lhaskell"
              ];
              initializationOptions = {
                haskell = {
                  formattingProvider = "fourmolu";
                };
              };
            };
            "ocaml-language-server" = {
              command = "ocamllsp";
              args = [
                "--log-file"
                "/tmp/LanguageServer.log"
              ];
              filetypes = [
                "ocaml"
              ];
            };
            "bash-language-server" = {
              command = "bash-language-server";
              args = [
                "start"
              ];
              filetypes = [
                "sh"
              ];
            };
            nix = {
              command = "rnix-lsp";
              filetypes = [
                "nix"
              ];
            };
          };
          "java.home" = "/usr/lib/jvm/java11";
          "java.jdt.ls.home" = "/usr/local/share/jdt-language-server";
          "java.signatureHelp.enabled" = true;
          "java.import.gradle.enabled" = true;
          "java.configuration.runtimes" = [
            {
              name = "JavaSE-1.8";
              path = "/usr/lib/jvm/java8";
              default = true;
            }
            {
              name = "JavaSE-11";
              path = "/usr/lib/jvm/java11";
            }
          ];
          "yaml.customTags" = [
            "!Ref"
            "!Sub"
            "!ImportValue"
            "!GetAtt"
          ];
        };
      };
    };
    tmux = {
      enable = true;
      terminal = "tmux-256color";
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.logging;
          extraConfig = ''
            # log
            set-option -g @logging_key "M-p"
            set-option -g @logging-path "$HOME/log/tmux"
            set-option -g @logging-filename "%Y%m%dT%H%M%S.log"
            # history
            set-option -g @save-complete-history-key "P"
            set-option -g @save-complete-history-path "$HOME/log/tmux"
            set-option -g @save-complete-history-filename "%Y%m%dT%H%M%S.history"
            set-option -g history-limit 100000
            # screen-capture
            set-option -g @screen-capture-key "M-Z"
          '';
        }
        {
          plugin = tmuxPlugins.jump;
        }
        {
          plugin = tmuxPlugins.nord;
        }
      ];
      extraConfig = ''
        ################################################################################
        # Basic
        ################################################################################

        # prefix=C-q
        set -g prefix C-q
        # Enable Italic
        set-option -g default-terminal "tmux-256color"
        # Enable True Color on xterm-256color
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        # status bar on top
        set-option -g status-position top
        # no mouse
        set-option -g mouse off

        ################################################################################
        # Pane
        ################################################################################

        # vimのキーバインドでペインを移動する
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # vimのキーバインドでペインをリサイズする
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # | でペインを縦分割する
        bind | split-window -h

        # - でペインを縦分割する
        bind - split-window -v

        ################################################################################
        # Copy / Paste
        ################################################################################

        setw -g mode-keys vi

        bind C-q copy-mode

        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi V send -X select-line
        bind -T copy-mode-vi C-v send -X rectangle-toggle

        bind -T copy-mode-vi K send-keys -X -N 5 scroll-up
        bind -T copy-mode-vi J send-keys -X -N 5 scroll-down

        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "myclip"
        bind -T copy-mode-vi y     send-keys -X copy-pipe-and-cancel "myclip"
      '';
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;
      autocd = true;
      history.extended = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "docker-compose"
          # "z"
        ];
        theme = "frisk";
        # theme = "kphoen";
      };
      loginExtra = ''
        export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
      '';
      profileExtra = ''
        export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
      '';
      envExtra = ''
        export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
        source-if-exists() {
          [ -e $1 ] && . $1
        }
        test -z "''${ZSHENV_LOADED}" || return
        export ZSHENV_LOADED=1
        export PATH="$PATH:$HOME/.local/bin"
        export PATH="$PATH:$HOME/.deno/bin"
        export PATH="$PATH:/usr/local/go/bin"
        export PATH="$PATH:/usr/local/google-cloud-sdk/bin"
        source-if-exists "$HOME/.ghcup/env"
        source-if-exists "$HOME/.cargo/env"
        source-if-exists "$HOME/.opam/opam-init/init.zsh"
        source-if-exists "$HOME/.nix-profile/etc/profile.d/nix.sh"
        source-if-exists "$HOME/.autojump/etc/profile.d/autojump.sh"
        source-if-exists "$HOME/.poetry/env"
        source-if-exists "$HOME/.zshenv.local"
        export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      '';
      initExtra = ''
        zstyle ':completion:*:*:nvim:*' file-patterns '^*.(aux|log|pdf|cmo|cmi|cmt|cmx):source-files' '*:all-files'
        # drwxrwxrwxなるディレクトリ(other writable)が見にくいのを直す
        eval $(dircolors | sed 's/ow=[^:]*:/ow=01;34:/') #青背景白文字
        # bindkey
        bindkey "^K" up-line-or-history
        bindkey "^J" down-line-or-history
        bindkey "^I" expand-or-complete-prefix
        # nix home-manager
        export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels''${NIX_PATH:+:$NIX_PATH}
        # functions & aliases
        cd-ls(){
          \cd $* && \ls --group-directories-first --color=always
        }
        mkcd(){
          mkdir $1 && cd $1
        }
        neovim(){
          if [[ -z "$NVIM_LISTEN_ADDRESS" ]]
          then
            nvim "$@"
          else
            nvr -p "$@"
          fi
        }
        ncd() {
          nvr -c "cd '$(realpath $1)'"
        }
        alias ls='ls --color=always'
        alias cd='cd-ls'
        alias mv='mv -i'
        alias cp='cp -iL'
        alias l='ls -CF'
        alias ll='ls -ahlF'
        alias la='ls -A'
        alias DU='du -hd1 | sort -h'
        alias open=xdg-open
        alias v='neovim'
        alias vi='neovim'
        alias vim='neovim'
        alias gs='git status'
        # extra source
        source-if-exists $HOME/.fzf.zsh
        source-if-exists $HOME/.zshrc.local
        source-if-exists $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
        which direnv 2>&1 > /dev/null && eval "$(direnv hook zsh)" || true
      '';
    };
    git = {
      enable = true;
      inherit (user.git) userName userEmail;
      extraConfig = {
        #core.editor = "nvr-git";
        core.autoCRLF = false;
        core.autoLF = false;
        fetch.prune = true;
        rebase.missingCommitsCheck = "warn";
        merge.ff = false;
        merge.conflictstyle = "diff3";
        merge.tool = "my-nvimdiff3";
        mergetool.my-nvimdiff3.cmd = "nvim -d -c 'wincmd J' $MERGED $LOCAL $BASE $REMOTE";
        pull.rebase = true;
        init.defaultBranch = "main";
        alias.stash-all = "stash save --include-untracked";
      };
      delta.enable = true;
    };
    zoxide = {
      enable = true;
    };
    gnome-terminal = {
      enable = false;
      showMenubar = false;
      profile = {
        test = {
          default = true;
          visibleName = "test";
          font = "Illusion N 13";
          allowBold = true;
          audibleBell = false;
          colors = {
            foregroundColor = "#cacacececdcd";
            backgroundColor = "#111112121313";
            boldColor = "#cacacececdcd";
            cursor = {
              foreground = "#111112121313";
              background = "#cacacececdcd";
            };
            palette = [
              "#323232323232"
              "#c2c228283232"
              "#8e8ec4c43d3d"
              "#e0e0c6c64f4f"
              "#4343a5a5d5d5"
              "#8b8b5757b5b5"
              "#8e8ec4c43d3d"
              "#eeeeeeeeeeee"
              "#323232323232"
              "#c2c228283232"
              "#8e8ec4c43d3d"
              "#e0e0c6c64f4f"
              "#4343a5a5d5d5"
              "#8b8b5757b5b5"
              "#8e8ec4c43d3d"
              "#ffffffffffff"
            ];

          };
        };
      };
    };
  };
  #fonts.fontconfig.enable = true;
  services.dropbox.enable = true;
  xsession.windowManager.xmonad = {
    # XXX ~/.xmonad/xmonad-session-rc を以下の内容で置く必要がある。
    #   export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    # もっといい方法がないか探そう
    enable = false;
    config = ./files/.xmonad/xmonad.hs;
    haskellPackages = pkgs.haskell.packages.ghc8107.override {
      overrides = haskellPackagesNew: haskellPackagesOld: {
        xmonad = haskellPackagesOld.xmonad_0_17_0;
        xmonad-contrib = haskellPackagesOld.xmonad-contrib_0_17_0;
        xmobar = haskellPackagesOld.xmobar.overrideAttrs (old: {
          configureFlags = "-f all_extensions";
        });
      };
    };
    extraPackages = haskellPackags: with haskellPackags; [
      containers
      filepath
      process
      rio
      split
      transformers
      xmonad
      xmonad-contrib
      X11
      GenericPretty
    ];
  };
  # TODO
  # * 未対応
  #   * gnome-terminal
  #   * tomcat
}
# vim:foldmethod=indent:
