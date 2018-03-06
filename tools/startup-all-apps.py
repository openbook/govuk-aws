#!/usr/local/bin/python3

import argparse
import subprocess
from multiprocessing import Pool as thread_pool



app_list = [
    ]
 
app_count = app_list.__len__()

pool = thread_pool(4)
results = pool.map(subprocess.run,app_list)

pool.close()
pool.join()
