
# Registry

## requirements:



## local provisioning with virtualbox

  - deploy the cluster: `make deploy`

  - destroy the cluster: `nixops destroy -d registry && nixops delete -d registry && rm .created`

## AWS cloud provisioning

  - deploy the cluster: `make deploy-ec2`

  - destroy the cluster: `nixops destroy -d registry && nixops delete -d registry && rm .ec2-created`



# TODO:

 - 
