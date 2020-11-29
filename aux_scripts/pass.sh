#!/usr/bin/env bash

# ------------------
# ANSIBLE-MAKEFILE v0.15.0
# Run ansible commands with ease
# ------------------
#
# Copyright (C) 2017 Paul(r)B.r
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# ########################
#
# Output your vault passphrase within this script
#
# ===============
#
# = Recommended approach is to use a password manager:
#   1- GPG encrypted password manager (https://www.passwordstore.org/)
#   2- Vault from Hashicorp for example (https://www.hashicorp.com/blog/vault.html)
#   3- ...
#
# ===============
#
# This script is 1- GPG password manager "pass"
#
# ########################

set -e

env=${env:-}

if (command -v pass >/dev/null 2>&1)
then
    existingVault=$(pass "ansible-vault/${env}" || true)

    if [ -n "${existingVault}" ]
    then
        >&2 echo "Using passphrase found at 'ansible-vault/${env}' in your password store."
        echo "${existingVault}"
    else
        >&2 echo "No passphrase found at 'ansible-vault/${env}' in your password store."
        >&2 echo "Defaulting to an random vault pass. Don't trust it if you are using vaulted variables!"
        echo "invalid_vault_pass"
    fi
fi