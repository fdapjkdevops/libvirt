# 2. ----> We fetch the smallest ubuntu image from the cloud image repo
resource "libvirt_volume" "ubuntu-jammy-qcow2" {
  name   = "ubuntujammy.qcow2"
  pool   = "default" ## ---> This should be same as your disk pool name
 source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
 name           = "commoninit0100-vm.iso"
 pool           = "default" #CHANGEME
 user_data      = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
 template = file("${path.module}/cloud_init0100vm.cfg")
}

# 5. -----> Create the compute vm
resource "libvirt_domain" "ubuntu0100vm" {
  name   = "ubuntu0100vm"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id  
  network_interface {
     network_name = "default" ## ---> This should be the same as your network name 
  }

  console { # ----> define a console for the domain.
     type        = "pty"
     target_port = "0"
     target_type = "serial" 
  }
  disk {   
     volume_id = "${libvirt_volume.ubuntu-jammy-qcow2.id}"
  } # ----> map/attach the disk 
  graphics { ## ---> graphics settings
     type        = "spice"
     listen_type = "address"
     autoport    = "true"
  }
}
