su
curl https://www.hipchat.com/keys/hipchat-linux.key | \
  GNUPGHOME=/etc/pacman.d/gnupg gpg --import 
echo '[atlassian]
SigLevel = PackageOptional DatabaseRequired TrustAll
Server = http://downloads.hipchat.com/linux/arch/$arch
' >> /etc/pacman.conf
pacman -Syy
pacman -S hipchat
