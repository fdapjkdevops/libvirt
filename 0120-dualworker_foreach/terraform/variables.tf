#
# variables.tf:
#    This is the declaration of the variables in scope.

variable "VMWorkers" {
    default = "1"
}

variable "worker_names" {
#   type = list(string)
   type = set(string)
   default = []
   description="Worker VMs to create"
}

variable "worker_vcpu" {
   default = "1"
}

variable "worker_mem" {
   default = "512"
}


