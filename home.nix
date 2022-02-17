# https://rycee.gitlab.io/home-manager/options.html
{ config, pkgs, my-xmobar, ... }:
let
  user = import ./user.nix;
in
{
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    inherit (user.home) username homeDirectory;
    language = {
      base = "ja_JP.UTF-8";
    };
    packages = with pkgs; [
      aws-sam-cli
      awscli2
      bat
      curl
      deno
      # TODO docker group に自身を追加する
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
      ### my packages
      my-xmobar
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
      # xmonad: set LOCALE_ARCHIVE -- XXX もっと良い方法があるのでは
      ".xmonad/xmonad-session-rc".source = ./files/.xmonad/xmonad-session-rc;
      # font
      ".config/fontconfig/conf.d/20-illusion-fonts.conf".source = ./files/.config/fontconfig/conf.d/20-illusion-fonts.conf;
      # my script
      ".local/bin/myfzf".source = ./files/.local/bin/myfzf;
      ".local/bin/myclip".source = ./files/.local/bin/myclip;
      ".local/bin/my-xmobar-volume".source = ./files/.local/bin/my-xmobar-volume;
      ".local/bin/my-xmonad-borderwidth".source = ./files/.local/bin/my-xmonad-borderwidth;
    };
    sessionVariables = {
      EDITOR = "nvim";
      LANG = "ja_JP.UTF-8";
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
          "codeLens.enable" = true;
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
      extraConfig = ''
        source  ~/.config/tmux/real-tmux.conf
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
        core.editor = "nvr-git";
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
      enable = true;
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
  fonts.fontconfig.enable = true;
  services.dropbox.enable = true;
  xsession.windowManager.xmonad = {
    # XXX ~/.xmonad/xmonad-session-rc を以下の内容で置く必要がある。
    #   export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    # もっといい方法がないか探そう
    enable = true;
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
