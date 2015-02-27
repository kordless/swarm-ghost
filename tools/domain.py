import os
import json

# open the swarm.json file for reading
swarm = open('swarm.json', 'r')

# pull into a python object
swarm_json = json.loads(swarm.read())

# loop through existing services
for service in swarm_json['services']:

    # look for 'ghost-service'
    if "service_name" in service and "components" in service:

		# check if service name is ghost-service
		if service['service_name'] == "ghost-service":

			# loop over the component
			for component in service['components']:
				
				# look for the component name
				if "component_name" in component:
					if component["component_name"] == "ghost":

						# finally find the domain
						if "domains" in component:
							for key in component['domains']:
								print key
								break

						break
