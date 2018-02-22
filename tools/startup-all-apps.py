#!/usr/local/bin/python3

import argparse
import subprocess
from multiprocessing import Pool as thread_pool

app_list = [
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-apt'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-asset-master'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-backend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-backend-redis'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-bouncer'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-cache'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-calculators-frontend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-content-store'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-db-admin'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-deploy'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-docker-management'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-draft-cache'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-draft-content-store'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-draft-frontend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-frontend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-graphite'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-jumpbox'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-logs-cdn'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-mapit'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-mirrorer'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-mongo'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-monitoring'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-mysql'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-performance-backend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-performance-frontend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-performance-mongo'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-postgresql'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-publishing-api'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-puppetmaster'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-rabbitmq'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-router-backend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-rummager-elasticsearch'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-search'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-transition-db-admin'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-transition-postgresql'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-whitehall-backend'\], stdout=subprocess.PIPE,
\['tools/build-terraform-project.sh',' -c "apply --auto-approve" -e "staging" -s "blue" -d ../govuk-aws-data/data -p app-whitehall-frontend'\], stdout=subprocess.PIPE,
    ]
 
app_count = app_list.__len__()

#pool = thread_pool(app_count)
pool = thread_pool(4)
results = pool.map(subprocess.run,app_list)

pool.close()
pool.join()
