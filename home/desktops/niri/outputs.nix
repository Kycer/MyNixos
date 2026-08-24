_:

{
  my.niri.fragments."20-outputs" = ''
    output "eDP-1" {
        mode "2560x1600@60"
        scale 1.25
    }

    output "DP-1" {
        mode "1920x1080@60"
        scale 1.0
        position x=0 y=0
    }
  '';
}
