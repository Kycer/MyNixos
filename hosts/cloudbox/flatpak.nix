{
  my.flatpak = {
    enable = true;

    remotes = {
      flathub = {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        url = "https://mirrors.ustc.edu.cn/flathub";
      };
      flatpark = {
        location = "https://dl.flatpark.org/flatpark.flatpakrepo";
        url = "https://dl.flatpark.org/";
      };
    };

    packages = {
      flathub = [
        "app.zen_browser.zen"
        "com.github.tchx84.Flatseal"
        # "com.tencent.WeChat"
        # "com.tencent.wemeet"
        "com.usebruno.Bruno"
      ];
      flatpark = [
        "com.dbxio.dbx"
        "com.motrix.next"
        "io.github.yituorou.meatshell"
      ];
    };
  };
}
