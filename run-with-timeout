#!/usr/bin/python

import os
import sys
import time
import errno
import signal



def safe_kill(pid, sig):
    """Send the signal 'sig' to the process with the PID specified by 'pid'.
    Do nothing if there is no such process.

    """
    try:
        return os.kill(pid, sig)
    except OSError, err:
        if err.errno != errno.ESRCH:
            raise


def safe_killpg(pgid, sig):
    """Send the signal 'sig' to the process group with the group id specified
    by 'pgid'.  Do nothing if there is no such process group.

    """
    try:
        return os.killpg(pgid, sig)
    except OSError, err:
        if err.errno != errno.ESRCH:
            raise


if len(sys.argv) < 3:
    print ("""\
Usage: %s TIMEOUT[:KILL_TIMEOUT] [-SIG] COMMAND [ARGS]"

Run COMMAND, and send it a signal (SIGTERM by default) after TIMEOUT seconds.
If it's still alive, and KILL_TIMEOUT is specified, wait for KILL_TIMEOUT
additional seconds and send it SIGKILL.

SIG can be specified as a number or a name from `kill -l`.
""" % sys.argv[0])

    sys.exit()

if ':' in sys.argv[1]:
    timeout, kill_timeout = sys.argv[1].split(':', 1)
else:
    timeout, kill_timeout = sys.argv[1], 0

timeout, kill_timeout = float(timeout), float(kill_timeout)

if sys.argv[2].startswith('-'):
    # -SIG specified
    sig = sys.argv.pop(2)[1:].upper()

    # Can be number or string, with or without the 'SIG'
    if sig.isdigit():
        timeout_signal = int(sig)
    elif not sig.startswith('SIG'):
        timeout_signal = getattr(signal, 'SIG' + sig)
    else:
        timeout_signal = getattr(signal, sig)

else:
    timeout_signal = signal.SIGTERM


command = sys.argv[2:]


# run main child process in separate session/process group
setsid_child_pid = os.fork()
if setsid_child_pid == 0:
    os.setsid()
    os.execvp(command[0], command)
    sys.exit(1)  # exec failed

# set up watcher process to kill main child process group after timeout
watcher_child_pid = os.fork()
if watcher_child_pid == 0:
    time.sleep(timeout)
    sys.stderr.write("Timeout hit, sending signal %d\n" % timeout_signal)
    safe_killpg(setsid_child_pid, timeout_signal)
    if kill_timeout:
        time.sleep(kill_timeout)
        sys.stderr.write("Kill timeout hit, sending signal %d\n" % signal.SIGKILL)
        safe_killpg(setsid_child_pid, signal.SIGKILL)
    sys.exit()

# wait for main child job to complete (or to have been killed)
_, status = os.waitpid(setsid_child_pid, 0)

# kill watcher once the child exits
safe_kill(watcher_child_pid, signal.SIGTERM)

# reap watcher
os.waitpid(watcher_child_pid, 0)

# get the return code based on how the child exited
if os.WIFEXITED(status):
    # normal exit
    return_code = os.WEXITSTATUS(status)
else:
    # killed by a signal
    return_code = 128 + os.WTERMSIG(status)

sys.exit(return_code)

