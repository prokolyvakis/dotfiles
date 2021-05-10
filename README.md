# An Ansible Playbook for my Dotfiles Configuration

It automates the setup and configuration of the software I use for development on Ubuntu & Darwin distributions using [ansible](https://www.ansible.com/)! 

## What It Does
- Installs packages.
- Sets up my dotfiles.
  - Super-custom git config
  - Sets up [Oh My Zsh](https://ohmyz.sh/) with the [Spaceship ZSH](https://github.com/denysdovhan/spaceship-prompt) theme.
  - Sets up my [zshrc](./files/link/zshrc) file.
- Installs [SpaceVim](https://spacevim.org/)
- Configures tmux with the [Oh My Tmux](https://github.com/gpakosz/.tmux) configuration.
- Installs proper fonts.

## Installation Process
1. Install Ansible and git: `make bootstrap`
2. Clone this repo and cd inside it: 
   
    ```
    git clone https://github.com/prokolyvakis/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
    ```

3. Install the required Ansible roles: `ansible-galaxy install -r requirements.yml`
4. Adapt accordingly the [config file](./group_vars/all/all.yml).
5. Run it: `ansible-playbook -i inventory main.yml -b -K --skip-tags user`

## Testing Process 
 `make docker-test`, it requires docker!

## Miscellaneous
1. To update this repo, run: `make repo-update `
2. Check the [Unofficial guide to dotfiles](https://dotfiles.github.io/) for more ideas!
3. With regard to terminal:
   1. On Darwin, the [Material Design theme](https://github.com/MartinSeeler/iterm2-material-design) on iTerm is pretty cool.
   2. On GNU/Linux, check [Gogh](https://mayccoll.github.io/Gogh/)!
   3. [Starship terminal](https://starship.rs/) is *maybe* worth exploring!
4. Last but not least, the [Hack font](https://sourcefoundry.org/hack/) is pretty awesome!
