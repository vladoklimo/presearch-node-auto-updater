### Author: Vladimir Klimo
### 
### This is a simple auto-updater for presearch node running under Windows version of Docker
### As early releases of nodes's (beta)versions does not handle everything flawlessly.
### I was looking for a more comfortable way of handling node's updates.
### So this scripts is something like a small program which checks docker's logs on local machine.
### If it finds out a specific error statement "Nodes version is too old" then program executes the
### update procedure and start the node again, but with latest version of node itself.
### 
### Please be aware that I do not take any responsibility for your actions with this script.
### Use at your own risk. No guarantees.
###

###
### Few configuration things before you execute anythng
###
# set the name of docker container, presearch is using "presearch.node" as default name, so be it
$container_name = "presearch.node"
# set the registration code for your node, this can be obtained from https://nodes.presearch.org/dashboard after you login to your account
$presearch_registration_code = "<PUT-YOUR-PRESEARCH-CODE-HERE>"

###
### Configuration done
###

### After this line, edit at your own risk

function Check-Presearch-Node-Version {
    $oldNodeIndicator = docker container logs $container_name  --since 10m | Select-String  -Pattern "Node version is too old" -SimpleMatch | measure | % { $_.Count }
	If ($oldNodeIndicator -gt 0) {
		Write-Host "Checking status: Node version is too old."
		Write-Host "Stopping the docker $container_name container"
		#now stop to container & cleanup the old one
		docker container stop $container_name | out-null
		docker container rm $container_name | out-null
		
		# update image to the latest version
		Write-Host "Updating node image to latest version"
		docker image pull presearch/node:latest | out-null
		
		# run the node
		Write-Host "Starting node with"
		$container_id = docker run -dt -v presearch-node-storage:/app/node --restart=unless-stopped --network  host --name $container_name -e REGISTRATION_CODE=$presearch_registration_code presearch/node
		
		# finishing
		Write-Host "Container started ... checking logs"
		for ($i = 10; $i -gt 0; $i--) {
			Start-Sleep -Seconds 1
			Write-Host -NoNewline "...$i"
		} 
		docker container logs $container_id
	}
	else {
		Write-Host "Nothing to do"
	}
}

Check-Presearch-Node-Version
Exit 