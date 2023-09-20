# terraform.tfvars:
#   This is to establish what the values of the variables are for this environment

#VMvcpu = "2"

#VMmem = "1024"

#VMdisksize = "10737418240"

# Really need to use workspaces for the multi environment settings

#VMWorkers = "1"

worker_vcpu = "2"
worker_mem = "4096"

master_vcpu = "2"
master_mem = "4096"

#worker_names = ["work1","work2"]
worker_names = ["k8worker1" ,"k8worker2"]
master_names = ["k8master"]


