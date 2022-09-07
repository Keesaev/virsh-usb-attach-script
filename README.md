### virsh-usb-attach-script
Parses lsusb for bus and device numbers, generates xml and performs attach-device / deattach-device to add or remove usb to KVM.
- Useful if you have **several devices with same VID:PID**;
- Helps a lot if you have to constantly reconnect usb because device number changes every time;
### usage
- ```bash ./attach-usb.sh -d my_domain -v 12ab -p 34bc``` - required opt
- ```-m [attach/detach]``` - reattach or deattach
- ```-i``` - interactive
