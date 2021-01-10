# presearch-node-auto-updater
Set of support scripts to help presearch node community or operators to handle common update tasks.

# Installation steps
1. Download the installation script named: install_presearch_node_auto_updater.ps1
2. Execute the script over elevated powershell

		2.a Script downloads the node updater script to location C:\presearch_node_updater
		2.b Configures the update script meaining stores your Presearch registration code for later usage  
		2.c Register a recurring Windows Scheduler Task to check for node version updates

# What does the Node Updater Script
1. Checks docker container logs for version updates
2. Executes neccessary commands to pull latest presearch/node image and restarts your node accordingly
