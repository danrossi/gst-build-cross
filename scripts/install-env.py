#!/usr/bin/env python3

import argparse
import glob
import json
import os
import platform
import re
import shlex
import shutil
import subprocess
import tempfile
import pathlib
import signal
from functools import lru_cache
from pathlib import PurePath, Path
from sys import exit

from typing import Any


PREFIX_DIR = "/opt/gstreamer"

def str_to_bool(value: Any) -> bool:
    """Return whether the provided string (or any value really) represents true. Otherwise false.
    Just like plugin server stringToBoolean.
    """
    if not value:
        return False
    return str(value).lower() in ("y", "yes", "t", "true", "on", "1")


def listify(o):
    if isinstance(o, str):
        return [o]
    if isinstance(o, list):
        return o
    raise AssertionError('Object {!r} must be a string or a list'.format(o))


def stringify(o):
    if isinstance(o, str):
        return o
    if isinstance(o, list):
        if len(o) == 1:
            return o[0]
        raise AssertionError('Did not expect object {!r} to have more than one element'.format(o))
    raise AssertionError('Object {!r} must be a string or a list'.format(o))


def prepend_env_var(env, var, value, sysroot):
    if var is None:
        return
    if value.startswith(sysroot):
        value = value[len(sysroot):]
    # Try not to exceed maximum length limits for env vars on Windows
    if os.name == 'nt':
        value = win32_get_short_path_name(value)
    env_val = env.get(var, '')
    val = os.pathsep + value + os.pathsep
    # Don't add the same value twice
    if val in env_val or env_val.startswith(value + os.pathsep):
        return
    env[var] = val + env_val
    env[var] = env[var].replace(os.pathsep + os.pathsep, os.pathsep).strip(os.pathsep)


def get_target_install_filename(target, filename):
    '''
    Checks whether this file is one of the files installed by the target
    '''
    basename = os.path.basename(filename)
    for install_filename in listify(target['install_filename']):
        if install_filename.endswith(basename):
            return install_filename
    return None


def get_pkgconfig_variable_from_pcfile(pcfile, varname):
    variables = {}
    substre = re.compile(r'\$\{[^${}]+\}')
    with pcfile.open('r', encoding='utf-8') as f:
        for line in f:
            if '=' not in line:
                continue
            key, value = line[:-1].split('=', 1)
            subst = {}
            for each in substre.findall(value):
                substkey = each[2:-1]
                subst[each] = variables.get(substkey, '')
            for k, v in subst.items():
                value = value.replace(k, v)
            variables[key] = value
    return variables.get(varname, '')


@lru_cache()
def get_pkgconfig_variable(builddir, pcname, varname):
    '''
    Parsing isn't perfect, but it's good enough.
    '''
    pcfile = Path(builddir) / 'meson-private' / (pcname + '.pc')
    if pcfile.is_file():
        return get_pkgconfig_variable_from_pcfile(pcfile, varname)
    return subprocess.check_output(['pkg-config', pcname, '--variable=' + varname],
                                   universal_newlines=True, encoding='utf-8')


def is_gio_module(target, filename, builddir):
    if target['type'] != 'shared module':
        return False
    install_filename = get_target_install_filename(target, filename)
    if not install_filename:
        return False
    giomoduledir = PurePath(get_pkgconfig_variable(builddir, 'gio-2.0', 'giomoduledir'))
    fpath = PurePath(install_filename)
    if fpath.parent != giomoduledir:
        return False
    return True


def is_library_target_and_not_plugin(target, filename):
    '''
    Don't add plugins to PATH/LD_LIBRARY_PATH because:
    1. We don't need to
    2. It causes us to exceed the PATH length limit on Windows and Wine
    '''
    if target['type'] != 'shared library':
        return False
    # Check if this output of that target is a shared library
    if not SHAREDLIB_REG.search(filename):
        return False
    # Check if it's installed to the gstreamer plugin location
    install_filename = get_target_install_filename(target, filename)
    if not install_filename:
        return False
    global GSTPLUGIN_FILEPATH_REG
    if GSTPLUGIN_FILEPATH_REG is None:
        GSTPLUGIN_FILEPATH_REG = re.compile(GSTPLUGIN_FILEPATH_REG_TEMPLATE)
    if GSTPLUGIN_FILEPATH_REG.search(install_filename.replace('\\', '/')):
        return False
    return True


def is_binary_target_and_in_path(target, filename, bindir):
    if target['type'] != 'executable':
        return False
    # Check if this file installed by this target is installed to bindir
    install_filename = get_target_install_filename(target, filename)
    if not install_filename:
        return False
    fpath = PurePath(install_filename)
    if fpath.parent != bindir:
        return False
    return True


def setup_gdb(options):
    python_paths = set()

    if not shutil.which('gdb'):
        return python_paths

    bdir = pathlib.Path(options.builddir).resolve()
    for libpath, gdb_path in [
            (os.path.join("subprojects", "gstreamer", "gst"),
             os.path.join("subprojects", "gstreamer", "libs", "gst", "helpers")),
            (os.path.join("subprojects", "glib", "gobject"), None),
            (os.path.join("subprojects", "glib", "glib"), None)]:

        if not gdb_path:
            gdb_path = libpath

        autoload_path = (pathlib.Path(bdir) / 'gdb-auto-load').joinpath(*bdir.parts[1:]) / libpath
        autoload_path.mkdir(parents=True, exist_ok=True)
        for gdb_helper in glob.glob(str(bdir / gdb_path / "*-gdb.py")):
            python_paths.add(str(bdir / gdb_path))
            python_paths.add(os.path.join(options.srcdir, gdb_path))
            try:
                if os.name == 'nt':
                    shutil.copy(gdb_helper, str(autoload_path / os.path.basename(gdb_helper)))
                else:
                    os.symlink(gdb_helper, str(autoload_path / os.path.basename(gdb_helper)))
            except (FileExistsError, shutil.SameFileError):
                pass

    gdbinit_line = 'add-auto-load-scripts-directory {}\n'.format(bdir / 'gdb-auto-load')
    try:
        with open(os.path.join(options.srcdir, '.gdbinit'), 'r') as f:
            if gdbinit_line in f.readlines():
                return python_paths
    except FileNotFoundError:
        pass

    with open(os.path.join(options.srcdir, '.gdbinit'), 'a') as f:
        f.write(gdbinit_line)

    return python_paths


def is_bash_completion_available(options):
    return os.path.exists(os.path.join(options.builddir, 'subprojects/gstreamer/data/bash-completion/helpers/gst'))


def get_subprocess_env(options, gst_version):
    env = os.environ.copy()
    env["GST_VERSION"] = gst_version
    env["GST_ENV"] = gst_version


    env["GST_PLUGIN_SYSTEM_PATH"] = ""

    if os.name == 'nt':
        lib_path_envvar = 'PATH'
    elif platform.system() == 'Darwin':
        # DYLD_LIBRARY_PATH is stripped when new shells are spawned and can
        # cause issues with runtime linker resolution, so only set it when
        # using --only-environment
        lib_path_envvar = None
        if options.only_environment:
            lib_path_envvar = 'DYLD_LIBRARY_PATH'
    else:
        lib_path_envvar = 'LD_LIBRARY_PATH'

    prepend_env_var(env, "GST_PLUGIN_PATH", os.path.join(PREFIX_DIR, 'lib',
                                                        'gstreamer-1.0'),
                    options.sysroot)

    prepend_env_var(env, "GST_VALIDATE_SCENARIOS_PATH",
                    os.path.join(PREFIX_DIR, 'share', 'gstreamer-1.0',
                                 'validate', 'scenarios'),
                    options.sysroot)
    
    prepend_env_var(env, "GI_TYPELIB_PATH", os.path.join(PREFIX_DIR, 'lib', 'girepository-1.0'),
                    options.sysroot)
    prepend_env_var(env, "PKG_CONFIG_PATH", os.path.join(PREFIX_DIR, 'lib', 'pkgconfig'),
                    options.sysroot)

  
    # Library and binary search paths
    prepend_env_var(env, "PATH", os.path.join(PREFIX_DIR, 'bin'),
                    options.sysroot)
    if lib_path_envvar != 'PATH':
        prepend_env_var(env, lib_path_envvar, os.path.join(PREFIX_DIR, 'lib'),
                        options.sysroot)
        prepend_env_var(env, lib_path_envvar, os.path.join(PREFIX_DIR, 'lib64'),
                        options.sysroot)
        prepend_env_var(env, "PATH", os.path.join(PREFIX_DIR, 'bin'), options.sysroot)
    elif 'QMAKE' in os.environ:
        # There's no RPATH on Windows, so we need to set PATH for the qt5 DLLs
        prepend_env_var(env, 'PATH', os.path.dirname(os.environ['QMAKE']),
                        options.sysroot)
    
    python_path = os.path.join(PREFIX_DIR, 'lib', "python3", "dist-packages")

    prepend_env_var(env, 'PYTHONPATH', python_path, options.sysroot)
    prepend_env_var(env, '_GI_OVERRIDES_PATH', os.path.join(python_path, "gi", "overrides"), options.sysroot)

    return env



if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="gst-env")

    parser.add_argument("--sysroot",
                        default='',
                        help="The sysroot path used during cross-compilation")

    parser.add_argument("--only-environment",
                        action='store_true',
                        default=False,
                        help="Do not start a shell, only print required environment.")
    options, args = parser.parse_known_args()

    # The following incantation will retrieve the current branch name.
    """
    try:
        gst_version = git("rev-parse", "--symbolic-full-name", "--abbrev-ref", "HEAD",
                          repository_path=options.srcdir).strip('\n')
    except subprocess.CalledProcessError:
        gst_version = "unknown"
    """
    gst_version = "1.0"

    env = get_subprocess_env(options, gst_version)
    

    if not args:
        if os.name != 'nt':
            args = [os.environ.get("SHELL", os.path.realpath("/bin/bash"))]
        prompt_export = f'export PS1="[{gst_version}] $PS1"'
        if args[0].endswith('bash') and not str_to_bool(os.environ.get("GST_BUILD_DISABLE_PS1_OVERRIDE", r"FALSE")):
            # Let the GC remove the tmp file
            tmprc = tempfile.NamedTemporaryFile(mode='w')
            bashrc = os.path.expanduser('~/.bashrc')
            if os.path.exists(bashrc):
                with open(bashrc, 'r') as src:
                    shutil.copyfileobj(src, tmprc)
            tmprc.write('\n' + prompt_export)
            tmprc.flush()
            args.append("--rcfile")
            args.append(tmprc.name)
        elif args[0].endswith('fish'):
            prompt_export = None  # FIXME
            # Ignore SIGINT while using fish as the shell to make it behave
            # like other shells such as bash and zsh.
            # See: https://gitlab.freedesktop.org/gstreamer/gst-build/issues/18
            signal.signal(signal.SIGINT, lambda x, y: True)
            # Set the prompt
            args.append('--init-command')
            prompt_cmd = '''functions --copy fish_prompt original_fish_prompt
            function fish_prompt
                echo -n '[{}] '(original_fish_prompt)
            end'''.format(gst_version)
            args.append(prompt_cmd)
        elif args[0].endswith('zsh'):
            prompt_export = f'export PROMPT="[{gst_version}] $PROMPT"'
            tmpdir = tempfile.TemporaryDirectory()
            # Let the GC remove the tmp file
            tmprc = open(os.path.join(tmpdir.name, '.zshrc'), 'w')
            zshrc = os.path.expanduser('~/.zshrc')
            if os.path.exists(zshrc):
                with open(zshrc, 'r') as src:
                    shutil.copyfileobj(src, tmprc)
            tmprc.write('\n' + prompt_export)
            tmprc.flush()
            env['ZDOTDIR'] = tmpdir.name
    try:
        if options.only_environment:
            for name, value in env.items():
                print('{}={}'.format(name, shlex.quote(value)))
                print('export {}'.format(name))
            if prompt_export:
                print(prompt_export)
        else:
            if os.environ.get("CI_PROJECT_NAME"):
                print("Ignoring SIGINT when running on the CI,"
                      " as we get spurious sigint in there for some reason.")
                signal.signal(signal.SIGINT, signal.SIG_IGN)
            exit(subprocess.call(args, close_fds=False, env=env))

    except subprocess.CalledProcessError as e:
        exit(e.returncode)
