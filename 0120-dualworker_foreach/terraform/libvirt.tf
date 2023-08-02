# 2. ----> We fetch the smallest ubuntu image from the cloud image repo
resource "libvirt_volume" "jammy_image" {
  name   = "ubuntujammy.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-2204base.qcow2"
  format = "qcow2"
}

# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
 name           = "commoninitworker.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_volume" "worker" {
   for_each = var.worker_names
   name = "worker_${each.value}.qcow2"
   base_volume_id = libvirt_volume.jammy_image.id
}

resource "libvirt_domain" "ubi_0120vm" {
  for_each = var.worker_names
  name = each.value
  memory = var.worker_mem
  vcpu   = var.worker_vcpu

  #--------------------------------------------------------------
  #
  # CLOUDINIT SECTION
  #
  #--------------------------------------------------------------
  cloudinit = libvirt_cloudinit_disk.commoninit.id  
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

