#!/usr/bin/env python
import re, subprocess
 
def get_passwordstore(item=None):
    params = {
        'item': item,
    }
    command = "pass show %(item)s" %params
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT).rstrip()
 
    return output
