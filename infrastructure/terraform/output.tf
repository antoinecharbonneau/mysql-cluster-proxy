output "key_pair" {
  sensitive = true
  value = module.key_pair.private_key_openssh
}

output "single_node_public_ip" {
  value = module.ec2_instance_single_node.public_ip
}

output "master_public_ip" {
  value = module.ec2_instance_master.public_ip
}

output "slave_1_public_ip" {
  value = module.ec2_instance_slaves["1"].public_ip
}

output "slave_2_public_ip" {
  value = module.ec2_instance_slaves["2"].public_ip
}

output "slave_3_public_ip" {
  value = module.ec2_instance_slaves["3"].public_ip
}

output "proxy_public_ip" {
  value = module.ec2_instance_proxy.public_ip
}