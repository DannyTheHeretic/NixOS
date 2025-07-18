{...}: {
  home-manager.sharedModules = [
    (_: {
      programs.fastfetch = {
        enable = true;
        settings = { 
          logo = {
            source= "~/NixOS/.images/icon.png";
            type= "kitty";
            height= 14;
          };
          display= {
              separator= " ";
          };
          modules= [
              {
                type= "title";
                keyWidth= 10;
              }
              {
                  type= "os";
                  key= " ";
                  keyColor= "34";
              }
              {
                  type= "kernel";
                  key= " ";
                  keyColor= "34";
              }
              {
                  type= "packages";
                  key= " ";
                  format="{} (nix-system)";
                  keyColor= "34";  
              }
              {
                  type= "shell";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "terminal";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "wm";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "cursor";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "terminalfont";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "uptime";
                  key= " ";
                  keyColor= "34"; 
              }
              {
                  type= "datetime";
                  format= "{1}-{3}-{11}";
                  key= " ";
                  keyColor= "34";
              }
              {
                  type= "media";
                  key= "󰝚 ";
                  keyColor= "34"; 
              }
          ];
        };
      };
    }
    )
  ];
}
