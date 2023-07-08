#!/usr/bin/env python3
# pylint: disable=missing-module-docstring,missing-function-docstring

# configure.py
#
# Copyright 2023 JCWasmx86 <JCWasmx86@t-online.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0-or-later

import subprocess
import tempfile

import inquirer


def extract_plugins():
    ret = []
    with open("meson_options.txt", encoding="utf-8") as filep:
        lines = filep.readlines()
        for line in lines:
            if line.startswith("option('plugin_"):
                ret.append(line.split("'")[1].replace("plugin_", ""))
    return ret


def main():
    plugins = extract_plugins()
    questions = [
        inquirer.Checkbox(
            "plugins", message="Which plugins do you want to install?", choices=plugins
        )
    ]
    answers = inquirer.prompt(questions)
    if answers is None:
        return
    to_install = answers["plugins"]
    plugins_to_disable = set(plugins)
    for plugin in to_install:
        plugins_to_disable.remove(plugin)
    command = ["meson", "--buildtype", "release"]
    for plugin in plugins_to_disable:
        command.append("-Dplugin_" + plugin + "=disabled")
    with tempfile.TemporaryDirectory() as tmpdirname:
        command.append(tmpdirname)
        subprocess.run(command, check=True)
        command = ["ninja", "install", "-C", tmpdirname]
        subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
