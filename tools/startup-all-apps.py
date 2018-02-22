#!/usr/local/bin/python3

import argparse
import subprocess
from multiprocessing import Pool as thread_pool

app_list = [
    ['build-terraform-project.sh','-c "apply --auto-approve"','-e "staging"','-s "govuk"','-d ../govuk-aws-data/data','-p "apt-apt"']
    ]
 
app_count = app_list.__len__()

pool = thread_pool(app_count)
results = pool.map(print,app_list)

pool.close()
pool.join()
