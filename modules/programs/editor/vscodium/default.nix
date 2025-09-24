{
  lib,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["vscode"];
  home-manager.sharedModules = [
    (_: {
      programs.vscode = {
        enable = true;
        # mutableExtensionsDir = true; # TODO: test with home-manager
        package = pkgs.vscodium.fhs;
	      # package = pkgs.vscode;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
	          mkhl.direnv
            #jeanp413.open-remote-ssh
            bbenoist.nix
            arrterian.nix-env-selector
	          github.vscode-github-actions
            yzhang.markdown-all-in-one
            # asvetliakov.vscode-neovim
            # vscodevim.vim
            tamasfe.even-better-toml
            jnoortheen.nix-ide
            # redhat.vscode-yaml
            # vadimcn.vscode-lldb
            rust-lang.rust-analyzer
            ms-vscode.cpptools
            ms-vscode.cmake-tools
            ms-vscode.makefile-tools
            ziglang.vscode-zig
            # ms-dotnettools.csharp
            # python
            ms-python.python
            njpwerner.autodocstring
            ms-python.debugpy
            charliermarsh.ruff
            wholroyd.jinja
            samuelcolvin.jinjahtml
            batisteo.vscode-django
            usernamehw.errorlens
            # JavaScript
            # esbenp.prettier-vscode
            # ms-python.pylint
      	    enkia.tokyo-night
          ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
              name = "remote-ssh-edit";
              publisher = "ms-vscode-remote";
              version = "0.47.2";
              sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      	  }
          {
              name = "remote-server";
              publisher	= "ms-vscode";
              version = "1.6.2025091709";
              sha256 = "1v322paf8fkzns0c4zqy7yz97apyf9kdbzq7rx3h9mxcisbm5kby";
          }
    	];  
	
          keybindings = [
            {
              key = "ctrl+q";
              command = "editor.action.commentLine";
              when = "editorTextFocus && !editorReadonly";
            }
            {
              key = "ctrl+s";
              command = "workbench.action.files.saveFiles";
            }
          ];
          userSettings = {
            "update.mode" = "none";
            # "extensions.autoUpdate" = false; # Fixes vscode freaking out when theres an update
            "python.defaultInterpreterPath"="./.pixi/envs/default/bin/python";
            "ruff.nativeServer"="on";
            "window.titleBarStyle" = "custom"; # needed otherwise vscode crashes, see https://github.com/NixOS/nixpkgs/issues/246509
            "window.menuBarVisibility" = "classic";
            "window.zoomLevel" = 0.5;
            "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'SymbolsNerdFont', 'monospace', monospace";
            "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'SymbolsNerdFont'";
            "editor.fontSize" = 14;
            "workbench.colorTheme" = "Tokyo Night";
            "catppuccin.accentColor" = "lavender";
            "vsicons.dontShowNewVersionMessage" = true;
            "explorer.confirmDragAndDrop" = false;
            "editor.fontLigatures" = true;
            "workbench.startupEditor" = "none";
            "telemetry.enableCrashReporter" = false;
            "telemetry.enableTelemetry" = false;

            "security.workspace.trust.untrustedFiles" = "open";

            "git.enableSmartCommit" = true;
            "git.autofetch" = true;
            "git.confirmSync" = false;

            "editor.semanticHighlighting.enabled" = true;
            "gopls" = {"ui.semanticTokens" = true;};

            "editor.codeActionsOnSave" = {"source.organizeImports" = "explicit";};
            "editor.inlineSuggest.enabled" = true;
            "editor.formatOnSave" = true;
            "editor.formatOnPaste" = true;

            "editor.minimap.enabled" = false;
            "workbench.sideBar.location" = "left";
            "workbench.layoutControl.type" = "menu";
            "workbench.editor.limit.enabled" = true;
            "workbench.editor.limit.value" = 10;
            "workbench.editor.limit.perEditorGroup" = true;
            "explorer.openEditors.visible" = 0;
            "breadcrumbs.enabled" = true;
            "editor.renderControlCharacters" = false;
            "editor.stickyScroll.enabled" = false; # Top code preview
            "editor.scrollbar.verticalScrollbarSize" = 2;
            "editor.scrollbar.horizontalScrollbarSize" = 2;
            "editor.scrollbar.vertical" = "hidden";
            "editor.scrollbar.horizontal" = "hidden";
            "workbench.layoutControl.enabled" = false;

            "editor.mouseWheelZoom" = true;
          };
        };
      };
    })
  ];
}
