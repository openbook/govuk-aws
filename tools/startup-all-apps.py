#!/usr/local/bin/python3

import argparse
import subprocess
from multiprocessing import Pool as thread_pool

app_list = [
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-apt'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-asset-master'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-backend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-backend-redis'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-bouncer'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-cache'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-calculators-frontend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-content-store'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-db-admin'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-deploy'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-docker-management'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-draft-cache'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-draft-content-store'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-draft-frontend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-frontend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-graphite'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-jumpbox'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-logs-cdn'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-mapit'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-mirrorer'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-mongo'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-monitoring'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-mysql'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-performance-backend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-performance-frontend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-performance-mongo'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-postgresql'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-publishing-api'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-puppetmaster'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-rabbitmq'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-router-backend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-rummager-elasticsearch'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-search'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-transition-db-admin'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-transition-postgresql'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-whitehall-backend'],
['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging"-s "blue" -d ../govuk-aws-data/data -p app-whitehall-frontend'],
    ]
 
app_count = app_list.__len__()

#pool = thread_pool(app_count)
pool = thread_pool(4)
results = pool.map(subprocess.run,app_list)

pool.close()
pool.join()
