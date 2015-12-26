#!/usr/bin/python

import os
import sys
import time
import errno
import signal


if len(sys.argv) < 4:
    print "Usage: %s TIMEOUT HARDTIMEOUT COMMAND [ARGS]" % sys.argv[0]
    print "Run COMMAND, sending it SIGTERM after TIMEOUT seconds."
    print "If it's still alive, wait for HARDTIMEOUT additional seconds and send it SIGKILL."
    sys.exit()

timeout = float(sys.argv[1])
hardtimeout = float(sys.argv[2])
command = sys.argv[3:]
timeout_return_code = 99
timeout_signal = signal.SIGTERM
hardtimeout_signal = signal.SIGKILL

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
    try:
        os.killpg(setsid_child_pid, timeout_signal)
        if hardtimeout:
            time.sleep(hardtimeout)
            os.killpg(setsid_child_pid, hardtimeout_signal)
    except OSError, err:
        # we might get "no such process" if the child has already
        # exited; ignore that, raise others.
        if err.errno != errno.ESRCH:
            raise
    # sleep for long enough for parent to kill us
    time.sleep(60)

# wait for main child job to complete (or to have been killed)
_, status = os.waitpid(setsid_child_pid, 0)

# kill watcher if child exited normally (ie, without timeout)
if os.WIFEXITED(status):
    return_code = os.WEXITSTATUS(status)
else:
    return_code = timeout_return_code

os.kill(watcher_child_pid, signal.SIGTERM)

# reap watcher
os.waitpid(watcher_child_pid, 0)

sys.exit(return_code)
