NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= root

SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p $(NIXPORT) root@$(NIXADDR) "\
		parted /dev/nvme0n1 -- mklabel gpt;\
		parted /dev/nvme0n1 -- mkpart root ext4 512MB -8GB;\
		parted /dev/nvme0n1 -- mkpart swap linux-swap -8GB 100\%;\
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB;\
		parted /dev/nvme0n1 -- set 3 esp on;\
		sleep 1;\
		\
		mkfs.ext4 -L nixos /dev/nvme0n1p1;\
		mkswap -L swap /dev/nvme0n1p2;\
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3;\
		sleep 1;\
		\
		mount /dev/disk/by-label/nixos /mnt;\
		mkdir -p /mnt/boot;\
		mount -o umask=077 /dev/disk/by-label/boot /mnt/boot;\
		swapon /dev/nvme0n1p2;\
		nixos-generate-config --root /mnt;\
		\
		sed --in-place '/system\.stateVersion = .*/a\
			nix.package = pkgs.nixVersions.latest;\n\
			nix.extraOptions =\"experimental-features = nix-command flakes\";\n\
			services.openssh.enable = true;\n\
			services.openssh.settings.PasswordAuthentication = true;\n\
			services.openssh.settings.PermitRootLogin =\"yes\";\n\
			users.users.root.initialPassword =\"root\";\n'\
		/mnt/etc/nixos/configuration.nix;\
		\
		nixos-install --no-root-passwd && reboot;\
	"

vm/copy-secrets:
	rsync -av -e 'ssh $(SSH_OPTIONS)'\
		--exclude='environment'\
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh
