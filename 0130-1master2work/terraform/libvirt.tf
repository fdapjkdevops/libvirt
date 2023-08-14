# Image for workers.   These are from the raw ubuntu, unexpanded
# 
resource "libvirt_volume" "jammy_worker_image" {
  name   = "ubuntujammy.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-2204base.qcow2"
  format = "qcow2"
}

# Image for masters.   These are from an expanded raw image (ubuntu-master.qcow2)
resource "libvirt_volume" "jammy_master_image" {
  name   = "ubuntui_master_image.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-master.qcow2"
  format = "qcow2"
}

# iso for worker user_data
resource "libvirt_cloudinit_disk" "commoninitworker" {
 name           = "commoninitworker.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_worker_data.rendered
}

# iso for master user_data
resource "libvirt_cloudinit_disk" "commoninitmaster" {
 name           = "commoninitmaster.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_master_data.rendered
}

data "template_file" "user_worker_data" {
  template = file("${path.module}/cloud_worker_init.cfg")
}

data "template_file" "user_master_data" {
  template = file("${path.module}/cloud_master_init.cfg")
}

resource "libvirt_volume" "worker" {
   for_each = var.worker_names
   name = "worker_${each.value}.qcow2"
   base_volume_id = libvirt_volume.jammy_worker_image.id
}

resource "libvirt_volume" "master" {
   for_each = var.master_names
   name = "master_${each.value}.qcow2"
   base_volume_id = libvirt_volume.jammy_master_image.id
}

resource "libvirt_domain" "ubi_0120vmworker" {
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
}

# Masters
resource "libvirt_domain" "ubi_0120vmmaster" {
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

#  provisioner "file" {
#   source = "ansiuser.conf"
#   destination = "/etc/sudoers.d/ansiuser.conf"
#  }
}

