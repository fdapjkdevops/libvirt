#
# variables.tf:
#    This is the declaration of the variables in scope.


variable "VMWorkers" {
    default = "2"
}

variable "worker_names" {
#   type = list(string)
   type = set(string)
   
   default = ["worker1","worker2"]
   description="Worker VMs to create"
}

variable "worker_vcpu" {
   default = "2"
}

variable "worker_mem" {
   default = "512"
}

variable "master_names" {
   type = set(string)
   default = ["master1","master2"]
   description="Master VMs to create"
}

variable "master_vcpu" {
   default = "1"
}

variable "master_mem" {
   default = "1024"
}

