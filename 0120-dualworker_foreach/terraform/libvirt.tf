# ISO for the master instances
resource "libvirt_volume" "ubuntu-master-image" {
  name   = "ubuntujammymaster.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-master.qcow2"
#  source = "file:///var/lib/libvirt/images/ubuntu-2204base.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu-worker-image" {
  name   = "ubuntujammyworker.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-2204base.qcow2"
  format = "qcow2"
}

# User_DATA ISO for the master numbered
resource "libvirt_cloudinit_disk" "commoninitmaster" {
 name           = "commoninitmast-vmN.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_data_master.rendered
}

data "template_file" "user_data_master" {
 template = file("${path.module}/cloud_initmast.cfg")
}

resource "libvirt_volume" "master" {
   for_each = var.master_names
   name = "master_${each.value}.qcow2"
   base_volume_id = libvirt_volume.ubuntu-master-image.id
}

# Masters
resource "libvirt_domain" "ubi0120vmmaster" {
  for_each = var.master_names
  name = each.value
  memory = var.master_mem
  vcpu   = var.master_vcpu

  #--------------------------------------------------------------
  #
  # CLOUDINIT SECTION
  #
  #--------------------------------------------------------------
  cloudinit = libvirt_cloudinit_disk.commoninitmaster.id  
  network_interface {
     network_name = "default" ## ---> This should be the same as your network name 
  }

  console { # ----> define a console for the domain.
     type        = "pty"
     target_port = "0"
     target_type = "serial" 
  }

  disk  {
     volume_id = libvirt_volume.master[each.value].id
  }


  graphics { ## ---> graphics settings
     type        = "spice"
     listen_type = "address"
     autoport    = "true"
  }

  connection {
     type     = "ssh"
     user     = "root"
     password = "unix1234"
     # host     = "${var.host}"
     host = each.value
  }

}

# User_DATA ISO for the worker numbered
resource "libvirt_cloudinit_disk" "commoninitworker" {
 name           = "commoninitwork-vmN.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_data_worker.rendered
}

data "template_file" "user_data_worker" {
 template = file("${path.module}/cloud_initwork.cfg")
}

resource "libvirt_volume" "worker" {
   for_each = var.worker_names
   name = "worker_${each.value}.qcow2"
   base_volume_id = libvirt_volume.ubuntu-worker-image.id
}

# Workers
resource "libvirt_domain" "ubi0120vmworker" {
  for_each = var.worker_names
  name = each.value
  memory = var.worker_mem
  vcpu   = var.worker_vcpu

  #--------------------------------------------------------------
  #
  # CLOUDINIT SECTION
  #
  #--------------------------------------------------------------
  cloudinit = libvirt_cloudinit_disk.commoninitworker.id  
  network_interface {
     network_name = "default" ## ---> This should be the same as your network name 
  }

  console { # ----> define a console for the domain.
     type        = "pty"
     target_port = "0"
     target_type = "serial" 
  }

  disk  {
     volume_id = libvirt_volume.worker[each.value].id
  }


  graphics { ## ---> graphics settings
     type        = "spice"
     listen_type = "address"
     autoport    = "true"
  }

  connection {
     type     = "ssh"
     user     = "root"
     password = "unix1234"
     # host     = "${var.host}"
     host = each.value
  }

}
