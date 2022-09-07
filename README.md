virsh-usb-attach-script
---
- Convinient way of attaching / detaching / reattaching usb devices to KVM domain
- Help a lot if you have several devices with same VID:PID which need to be reconnected 
---
### Usage
- ```bash ./attach-usb.sh -d my_domain -v 12ab -p 34bc``` - required opt
- ```-m [attach/detach]``` - reattach or deattach
- ```-i``` - interactive
