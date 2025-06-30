
from sh import losetup

loop0 = losetup('-f', '--show', "2024-07-04-raspios-bookworm-arm64-lite-autologin-ssh").strip()

print(loop0)

