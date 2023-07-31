# 2. ----> We fetch the smallest ubuntu image from the cloud image repo
resource "libvirt_volume" "jammy_image" {
  name   = "ubuntujammy.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
  source = "file:///var/lib/libvirt/images/ubuntu-2204base.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_volume" "worker" {
   for_each = var.worker_names
   name = "worker_${each.value}.qcow2"
#   name = worker_${each.value}.qcow2
   base_volume_id = libvirt_volume.jammy_image.id
}

# 5. -----> Create the compute vm
resource "libvirt_domain" "ubi_0120vm" {
#  name   = "ubuntu0100vm"
  for_each = var.worker_names
  name = each.value
  memory = var.worker_mem
  vcpu   = var.worker_vcpu

#  cloudinit = libvirt_cloudinit_disk.commoninit.id  
  network_interface {
     network_name = "default" ## ---> This should be the same as your network name 
  }

  console { # ----> define a console for the domain.
     type        = "pty"
     target_port = "0"
     target_type = "serial" 
  }
  #disk {   
  #   volume_id = "${libvirt_volume.ubuntu-jammy-qcow2.id}"
  #} # ----> map/attach the disk

  #disk {
  #  volume_id = libvirt_volume.volume.id
  # } 
  disk  {
     #volume_id = "libvirt_volume.worker_[each.value].id"
     #volume_id = libvirt_volume.worker_[each.value].id
     #volume_id = libvirt_volume.worker.id   # got the one with[each.key]
     volume_id = libvirt_volume.worker[each.value].id
  }


  graphics { ## ---> graphics settings
     type        = "spice"
     listen_type = "address"
     autoport    = "true"
  }
}
